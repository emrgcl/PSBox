$i = 0
$Seconds  = 5
$RetryCount = 3
$ServiceName = 'Print Spooler'


$scomApi=New-Object -ComObject Mom.ScriptApi
$InformationValue = 0
$ErrorValue = 1
$WarningValue =2 
$ScriptName = "Retry-FailedService.ps1"

$SuccessEventID = 1982
$ErrorEventID =1983
$DisabledEventID=1984


do 
{
    try 
    {

        $Service = Get-Service -DisplayName $ServiceName -ErrorAction Stop
        if ($Service.StartType -ne 'Disabled') 
        {
        $Service | Start-Service -ErrorAction Stop
        $Message = "[$ServiceName] is started after $i retries."
        $scomApi.LogScriptEvent($ScriptName,$SuccessEventID,$InformationValue,$Message)
        $Message
        }
        else
        {
        $Message = "[$ServiceName] is disabled not retrying.."
        $scomApi.LogScriptEvent($ScriptName,$DisabledEventID,$InformationValue,$Message)
        $Message
        
        }
     }
    catch 
    {

        $i+=1 

        $Message = "[$ServiceName] `nRetry Count: $i`nError Occured. Error: $($Error[0].Exception.Message).`nWill retry $RetryCount times.`nSleeping $Seconds seconds."
        $scomApi.LogScriptEvent($ScriptName,$ErrorEventID,$ErrorValue,$Message)
        $Message 
        Start-Sleep -Seconds $Seconds

    }
}
until ($i -eq $RetryCount -or $Service.Status -eq 'Running' -or $Service.StartType -eq 'Disabled')

