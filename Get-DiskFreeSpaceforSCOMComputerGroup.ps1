<#
This script(let) gets the disk free space for a computer group and is going to be used to be apart of the Powershell Universal DAshboard
#>


Import-Module OperationsManager
$GroupDisplayName="SQL Computers"
$CounterName="% Free Space"
$Samples = @()
$Servers=(Get-SCOMGroup -DisplayName $GroupDisplayName).GetRelatedMonitoringObjects()
#$servers | ForEach-Object {$_.GetRelatedMonitoringObjects()  | where FullName -match "LogicalDisk" | ft -Property Path,DisplayName}
ForEach ($server in $Servers) {
$LogicalDisks=$Server.GetRelatedMonitoringObjects()  | where FullName -match "LogicalDisk" 
foreach ($LogicalDisk in $LogicalDisks) {
$Data=($LogicalDisk.GetMonitoringPerformanceData() | ? {$_.CounterName -eq $CounterName}).GetValues((Get-Date).AddHours(-5),(Get-Date)) | Select-Object -Last 1
if ($Data.Count -ne 0) {
#$property=$LogicalDisk.GetMonitoringProperties() | where {$_.Name -match 'SizeInMB'}
$Result=[PSCustomObject]@{
Server         = $Server.DisplayName
Disk           = $LogicalDisk.DisplayName
Counter        = $CounterName
Value          = $Data.SampleValue
TimeSampled    = $Data.TimeSampled
}

$Samples+=$Result
} else {
Write-Output "Error occured for Server: $($Server.DisplayName) on disk $($LogicalDisk.DisplayName)" | Out-File -FilePath "d:\temp\out.txt" -Append

$Result=[PSCustomObject]@{
Server         = $Server.DisplayName
Disk           = $LogicalDisk.DisplayName
Counter        = $CounterName
Value          = "N/A"
TimeSampled    = "N/A"
}
$Samples+=$Result
}
}
}
$Samples | Out-GridView


