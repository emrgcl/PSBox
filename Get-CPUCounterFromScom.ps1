<#
14 February 2019

Notes to self: 
1)if the group member is a cluster computer object it will thrown an error, I wasnt able to find
2) there are servers whose objects cannot be populated. The handlying for these objects are not yet implemented as well.
3) script runs around 4-5 minutes for 1500 servers, not sure if better error handling helps in decreasing script duration.

#>

$ErrorActionPreference = "SilentlyContinue"
New-SCOMManagementGroupConnection -ComputerName $ms
$GroupDisplayName = "All Windows Computers"
$CounterName = '% Processor Time'
$InstanceName = '_Total'
$Objectname = 'Processor Information'
$UTCDiff = 3
#Write-Output "Script Start at $(Get-date -f "HH:m:ss")"
$Samples = @()
$Servers = (Get-SCOMGroup -DisplayName $GroupDisplayName).GetRelatedMonitoringObjects()
#$Exclude=(Get-SCOMClass -Name "Microsoft.Windows.Server.Computer" | Get-SCOMClassInstance | where {($_."[Microsoft.Windows.Server.Computer].IsVirtualNode").Value -eq $true}).DisplayName
#$servers | ForEach-Object {$_.GetRelatedMonitoringObjects()  | where FullName -match "LogicalDisk" | ft -Property Path,DisplayName}
ForEach ($server in $Servers) {
    $Instances = $Server.GetRelatedMonitoringObjects() | where FullName -match "OperatingSystem" 
    if (!$?) {
        Write-Output "Error occured during enumarting instances: $($Server.DisplayName) on disk $($Instance.DisplayName). Error message:$($Error[0].Exception.Message)" | Out-File -FilePath "d:\temp\out.txt" -Append
    }
    foreach ($instance in $Instances) {
        $Data = ($Instance.GetMonitoringPerformanceData() | ? { $_.Objectname -eq $Objectname -and $_.CounterName -eq $CounterName -and $_.Instancename -eq $InstanceName }).GetValues((Get-Date).AddHours(-8), (Get-Date)) 
        if (!$?) {
            Write-Output "Error occured during enumarting instances: $($Server.DisplayName) on disk $($Instance.DisplayName). Error message:$($Error[0].Exception.Message)" | Out-File -FilePath "d:\temp\out.txt" -Append
        }
        #$property=$LogicalDisk.GetMonitoringProperties() | where {$_.Name -match 'SizeInMB'}


        $Result = [PSCustomObject]@{
            Server         = $Server.DisplayName
            OS             = $Instance.DisplayName
            SampleCount    = $Data.Count
            Max            = ($Data.SampleValue | Measure-Object -Maximum).Maximum
            Min            = ($Data.SampleValue | Measure-Object -Minimum).Minimum
            Avg            = ($Data.SampleValue | Measure-Object -Average).Average
            Last           = ($Data | Select-Object -Last 1).SampleValue
            LastSampleTime = ($Data | Select-Object -Last 1).TimeSampled.AddHours($UTCDiff)
            LastHourAvg    = (($Data | where { $_.TimeSampled.Hour -eq ($Data.TimeSampled | Select-Object -last 1).Hour }).SampleValue | Measure-Object -Average).Average
            Samples        = ($Data | Select-Object -Property TimeSampled, SampleValue)
        }

        $Samples += $Result

    }
}
#Write-Output "Script End at $(Get-date -f "HH:m:ss")"
$ErrorActionPreference = "Continue"
$Samples | Sort-Object -Descending -Property LastHourAvg | Out-GridView

