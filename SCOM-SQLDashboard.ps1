<# 

This script is a base script for a sql dashboard based on Powersell Universall Dashboard.

#>


Import-Module universaldashboard.community
if(Get-UDDashboard | where {$_.Port -eq 10030}) {Stop-UDDashboard -port 10030}

$Color="#00FF00","#FFA500","#000080","#FFFF00","#FF0000","#4169E1","#9ACD32","#FF6347","#EE82EE","#40E0D0","#F0FFFF","#00FFFF"
$ms=$env:computername

$ProblemServerCount={
New-SCOMManagementGroupConnection -ComputerName $ms
$MonitorColl = @()
$MonitorColl = New-Object "System.Collections.Generic.List[Microsoft.EnterpriseManagement.Configuration.ManagementPackMonitor]"

$objects = get-scomclass -DisplayName "Health Service Watcher" | Get-SCOMClassInstance
$monitor = Get-SCOMMonitor -DisplayName 'Computer Not Reachable'
$Servers= @()
#Add this monitor to a collection
#$MonitorColl.Add($Monitor)

#Get the state associated with this specific monitor
#$State=$Object.getmonitoringstates($MonitorColl)

ForEach ($object in $objects)
{
    #Set the monitor collection to empty and create the collection to contain monitors
    $MonitorColl = @()
    $MonitorColl = New-Object "System.Collections.Generic.List[Microsoft.EnterpriseManagement.Configuration.ManagementPackMonitor]"

    #Get specific monitors matching a displayname for this instance of URLtest ONLY
    #$Monitor = Get-SCOMMonitor -Instance $object -Recurse| where {$_.DisplayName -eq "Computer Not Reachable"} 
    
    #Add this monitor to a collection
    $MonitorColl.Add($Monitor)

    #Get the state associated with this specific monitor
    $State=$object.getmonitoringstates($MonitorColl)
if ($state.HealthState -eq 'Error') {  
$Props=@{}
$Props.ServerName=$Object.DisplayName
$Props.Reachable=$state.HealthState
$Server=New-Object -TypeName PSCustomObject -Property $props
$Servers+=$Server
}
}
$Servers.Count
}

$PageLifeExpactency = {

New-SCOMManagementGroupConnection -ComputerName $ms
$MonitorColl = @()
$MonitorColl = New-Object "System.Collections.Generic.List[Microsoft.EnterpriseManagement.Configuration.ManagementPackMonitor]"

$objects = get-scomclass -DisplayName "SQL DB Engine" | Get-SCOMClassInstance
$monitors = Get-SCOMMonitor -DisplayName 'Page Life Expectancy'
$Servers= @()
#Add this monitor to a collection
#$MonitorColl.Add($Monitor)

#Get the state associated with this specific monitor
#$State=$Object.getmonitoringstates($MonitorColl)

ForEach ($object in $objects)
{
    #Set the monitor collection to empty and create the collection to contain monitors
    $MonitorColl = @()
    $MonitorColl = New-Object "System.Collections.Generic.List[Microsoft.EnterpriseManagement.Configuration.ManagementPackMonitor]"

    #Get specific monitors matching a displayname for this instance of URLtest ONLY
    #$Monitor = Get-SCOMMonitor -Instance $object -Recurse| where {$_.DisplayName -eq "Computer Not Reachable"} 
    
    #Add this monitor to a collection
    $monitor = $monitors | where {$_.Target.Identifier.Path -eq $object.GetMostDerivedClasses().Identifier.Path}
    
    <#if ($monitor.Target.Identifier.Path -contains $object.GetMostDerivedClasses().Identifier.Path){
    $MonitorColl.Add($Monitor)
    }#>

    $MonitorColl.Add($Monitor)

    #Get the state associated with this specific monitor
    $State=$object.getmonitoringstates($MonitorColl)
if ($state.HealthState -eq 'Error') {  
$Props=@{}
$Props.ServerName=$Object.DisplayName
$Props.Reachable=$state.HealthState
$Server=New-Object -TypeName PSCustomObject -Property $props
$Servers+=$Server
}
}
$Servers.Count



}

$TopServerRestarts={
New-SCOMManagementGroupConnection -ComputerName $ms
$rule=get-scomrule -DisplayName "Collection Rule for Windows Restarted Events"
$restarts=Get-SCOMEvent -Rule $rule | where {$_.TimeGenerated -gt (Get-Date).AddDays(-7) } | Group-Object -Property LoggingComputer  |Sort-Object -Property Count -Descending | Select-Object -first 10 -Property Count,@{Name='Name';Expression={$_.Name -split "\."|select-object -first 1}}
$restarts | Out-UDChartData -LabelProperty "Name" -Dataset @(New-UdChartDataset -DataProperty "Count" -BackgroundColor ($Color|get-random -Count 10) -HoverBorderColor red)
} 

$ServerGenaratingAlerts={
New-SCOMManagementGroupConnection -ComputerName $ms
$alerts=Get-SCOMAlert | where {$_.ResolutionState -eq 0 -and $_.NetbiosComputerName -ne $null}  | Group-Object -Property NetbiosComputerName | Sort-Object -Property Count -Descending |Select-Object -Property Name,Count -first 10
$alerts| Out-UDChartData -LabelProperty "Name" -Dataset @(New-UdChartDataset -DataProperty "Count" -BackgroundColor ($Color|get-random -Count 10) -HoverBorderColor red)
}

$OSVersions={
New-SCOMManagementGroupConnection -ComputerName $ms
$OS=get-scomclass -Name "SQL.DB.Engine" | get-scomclassInstance | Group-Object -Property `[Microsoft.SQLServer.DBEngine].Edition | Sort-Object -Property Count -Descending | Select-Object Count,Name
$os| Out-UDChartData -LabelProperty "Name" -Dataset @(New-UdChartDataset -DataProperty "Count" -BackgroundColor ($Color|get-random -Count 10) -HoverBorderColor red)
}

$SQLEditions={
New-SCOMManagementGroupConnection -ComputerName $ms
$editions=get-scomclass -Name "Microsoft.SQLServer.DBEngine" | get-scomclassinstance |Select-Object -ExpandProperty *.Edition | Group-Object -Property Value | Select-Object -Property Count,Name
$editions | Out-UDChartData -LabelProperty "Name" -Dataset @(New-UdChartDataset -DataProperty "Count" -BackgroundColor ($Color|get-random -Count 10) -HoverBorderColor red)
}

$PHome=New-UDPage -Name "Home" -icon dashboard -Content {

New-UDRow {

New-UDColumn -Size 2 -Content { 
    New-UDCounter -Format "0000" -Title "Unreachable Servers" -AutoRefresh -RefreshInterval 300 -Endpoint $ProblemServerCount -FontColor "White" -TextSize Small -TextAlignment center -BackgroundColor "black"
    
    }

}
New-UDRow {
New-UdColumn -Size 3 -Content{

New-UdChart -Title "Top Server Restarts" -Type HorizontalBar  -Endpoint $TopServerRestarts -AutoRefresh -RefreshInterval 600 


}

New-UdColumn -Size 3 -Content{

New-UdChart -Title "Top Alerting Servers" -Type HorizontalBar  -Endpoint $ServerGenaratingAlerts -AutoRefresh -RefreshInterval 600 


}

New-UdColumn -Size 6 -Content{

New-UdChart -Title "Server OS" -Type Pie  -Endpoint $OSVersions -AutoRefresh -RefreshInterval 600 


}

}
}
$Theme = Get-UDTheme -Name Azure
$Dashboard=New-UDDashboard  -Title "Server Information" -Footer $footer -Pages @($PHome) -Theme $Theme
Start-UDDashboard -Dashboard $Dashboard -Port 10018

#@{Name='Name';Expression={$_.Name -split "\."|select-object -first 1}} 

'`[Microsoft.SQLServer.DBEngine].Edition'
