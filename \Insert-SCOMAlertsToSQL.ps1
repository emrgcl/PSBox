<#
.Synopsis
   Inserts selected scom alerts to custom database
.DESCRIPTION
   Inserts selected scom alerts to custom database
.EXAMPLE
   .\Insert-SCOMAlertsToSQL.ps1 -AlertTablePath .\SCOMAlerts.psd1 -ManagementServer 'scomms1' -SQLServer 'scomdb1' -Instance 'default,1981' -Database 'SCOMDashboard' -Verbose

   VERBOSE: [5.03.2020 18:27:50] Script Started.
   VERBOSE: [5.03.2020 18:27:50] Already connected to a Management Group.
   VERBOSE: [5.03.2020 18:27:50] Returned 17 number of alert names
   VERBOSE: [5.03.2020 18:28:04]Found Alerts Table dropping.
   WARNING: Using provider context. Server = opwscomdb1\default,1977, Database = [SCOMDashboard].
   VERBOSE: [5.03.2020 18:28:05] Inserted 682 number of alerts
   VERBOSE: [5.03.2020 18:28:05] Script ended.Script dutation is 15.1515768
#>

#requires -version 5.1 -Modules SqlServer,OperationsManager


[CmdletBinding()]
Param(

[Parameter(Mandatory= $true)]
[ValidateScript({test-path $_})]
[string]$AlertTablePath,

[Parameter(Mandatory= $true)]
[string]$ManagementServer='Ovwscommng1',

[Parameter(Mandatory= $true)]
[string]$SQLServer,

[Parameter(Mandatory= $true)]
[string]$Instance,

[Parameter(Mandatory= $true)]
[string]$Database


)

Function Connect-ToSCOM {

    [CmdletBinding()]
    Param(
    
    [Parameter(Mandatory=$true)]
    [string]$ManagementServer
    
    )

    if (!(Get-SCOMManagementGroup)) {

        try {
        
       New-SCOMManagementGroupConnection -ComputerName  $ManagementServer -ErrorAction Stop
        }
        Catch {
        
        throw "Could not connect to $ManagementServer . Error: $($_.Exception.Message)"
        
        }
    
    } else {Write-Verbose "[$(Get-date -Format G)] Already connected to a Management Group."}

}

Function Get-AlertNames {

    [CmdletBinding()]
    Param(
    
    [Parameter(Mandatory=$true)]
    [Hashtable]$AlertTable
    )
    $Result = @()
    $AlertTable.Values | ForEach-Object {$Result += $_}
    $Result

    Write-Verbose "[$(Get-date -Format G)] Returned $(($Result).Count) number of alert names"
}

$ScriptStart = Get-date
$SelectAlertTable = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG='$database' and TABLE_NAME = 'Alerts'"

Write-Verbose "[$(Get-Date -Format G)] Script Started."




try {
Connect-ToSCOM -ManagementServer $ManagementServer -ErrorAction Stop

$AlertTable = Import-PowerShellDataFile -Path $AlertTablePath -Verbose:$false

$AlertNames = Get-AlertNames -AlertTable $AlertTable

$ClassId = @{Name = 'ClassId'; Expression = {$_.ClassId.Guid}}
$ManagementGroup = @{Name = 'ManagementGroup'; Expression = {$_.ManagementGroup.Tostring()}}
$ManagementGroupId = @{Name = 'ManagementGroupId'; Expression = {$_.ManagementGroupId.Guid}}
$MonitoringClassId = @{Name = 'MonitoringClassId'; Expression = {$_.MonitoringClassId.Guid}}
$MonitoringObjectId = @{Name = 'MonitoringObjectId'; Expression = {$_.MonitoringObjectId.Guid}}
$ProblemId = @{Name = 'ProblemId'; Expression = {$_.ProblemId.Guid}}
$RuleId = @{Name = 'RuleId'; Expression = {$_.RuleId.Guid}}
$Id = @{Name = 'Id'; Expression = {$_.Id.Guid}}
$Category = @{Name = 'Category'; Expression = {$_.Category.Tostring()}}

$MonitoringRuleId = @{Name = 'MonitoringRuleId'; Expression = {$_.MonitoringRuleId.Guid}}
$MonitoringObjectHealthState = @{Name = 'MonitoringObjectHealthState'; Expression = {$_.MonitoringObjectHealthState.ToString()}}
$Priority = @{Name = 'Priority'; Expression = {$_.Priority.ToString()}}
$ResolutionState = @{'Name' = 'ResolutionState';Expression = {$_.ResolutionState.ToString()}}
$Severity = @{Name = 'Severity'; Expression = {$_.Severity.ToString()}}


$Alerts = (Get-SCOMAlert).Where({$_.Name -in $AlertNames}) | Select-Object -Property $ClassId,Context,CustomField1,CustomField2,CustomField3,CustomField4,CustomField5,CustomField6,CustomField7,CustomField8,CustomField9,CustomField10,Description,$Id,IsmonitorAlert,LastModified, LastModifiedBy,LastModifiedByNonConnector,MaintenanceModeLastModified,$ManagementGroup,$ManagementGroupId,$MonitoringClassId,MonitoringObjectPath,MonitoringObjectDisplayName,MonitoringObjectFullName,MonitoringObjectName,$MonitoringObjectHealthState,$MonitoringObjectId,$MonitoringRuleId,MonitoringObjectInMaintenanceMode,Name,NetbiosComputerName,NetbiosDomainName,Owner,PrincipalName,$Priority,$ProblemId,RepeatCount,$ResolutionState,ResolvedBy,$RuleId,$Severity,SiteName,StateLastModified,TfsWorkItemID,TfsWorkItemOwner,TicketID,TimeAdded,TimeRaised,TimeResolutionStateLastModified,TimeResolved, UnformattedDescription
}

catch {

Throw "Could not connect and get alerts from the scom server $ManagementServer.`nError: $($_.Exception.Message)"

}

Try {

if((Invoke-Sqlcmd -ServerInstance "$SQLServer\$Instance" -Database $Database -Query $SelectAlertTable -ErrorAction stop)) {

Write-Verbose "[$(Get-date -Format G)]Found Alerts Table dropping."

Invoke-Sqlcmd -ServerInstance "$SQLServer\$Instance" -Database $Database -Query 'DROP TABLE [dbo].[Alerts]' -ErrorAction Stop

}
} catch {

Throw "[$(Get-Date -Format G)] Select or delete Alert Table`nError: $($_.Exception.Message)"

}

try {

New-PSDrive -Name SCOMDashboard -PSProvider 'SQLServer' -root "SQLSERVER:\SQL\$SQLServer\$Instance\Databases\$Database" -ErrorAction stop | Out-Null
cd 'SCOMDashboard:\Tables'
Write-SqlTableData -TableName Alerts -InputData $Alerts -Force -SchemaName dbo -ErrorAction Stop
Write-Verbose "[$(Get-Date -Format G)] Inserted $($Alerts.Count) number of alerts"

} 

Catch {

Throw "[$(Get-Date -Format G)] Couldnt Insert to SQL.`nError: $($_.Exception.Message)"


} 
Finally {
cd c:\
Remove-PSDrive SCOMDashboard
}


Write-verbose "[$(Get-date -Format G)] Script ended.Script dutation is $(((Get-date) - $ScriptStart).TotalSeconds)"
