<#
.Synopsis
   Sends Group Membership data to OMS
.DESCRIPTION
   Gets the membership of the groups specified and sends data as a custom log to OMS
   https://gallery.technet.microsoft.com/SCOM-Agent-Management-b96680d5
.EXAMPLE
   .\Send-OMSGroupMembers.ps1 -WorkspaceKey 'FEfstXxZl6BL4O55Eo7c85Z0smg8C1dfCp0MzMq/QtSUtELd245DDe+k7Hi++a7cwVwLWElofWy0L67QtrrdZA==' -WorkspaceID 'f13c1e8b-2956-4a35-9f5f-fd671ca8ea2d' -ManagementServer 'ovwscommng1' -GroupFilter 'PowerBI-*' -LogType 'GroupMember' -Verbose
#>
[CmdLetBinding()]
Param(
    [string]$ManagementServer,
    [string]$GroupFilter,
    [string]$WorkspaceKey,
    [string]$WorkspaceID,
    [string]$LogType
)



# Create the function to create the authorization signature
Function Build-Signature ($WorkspaceID, $WorkspaceKey, $date, $contentLength, $method, $contentType, $resource) {
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($WorkspaceKey)
    Write-Verbose "[$(Get-Date -f G)] KeyBytes: $keyBytes "
    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $WorkspaceID, $encodedHash
    return $authorization
}


# Create the function to create and post the request
Function Post-LogAnalyticsData($WorkspaceID, $WorkspaceKey, $body, $logType) {
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -WorkspaceID $WorkspaceID `
        -WorkspaceKey $WorkspaceKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $WorkspaceID + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization"        = $signature;
        "Log-Type"             = $logType;
        "x-ms-date"            = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    Write-Verbose "[$(Get-Date -f G)] Uri: $uri "
    return $response.StatusCode
    Write-Verbose "[$(Get-Date -f G)] StatusCode: $(response.statuscode)"

}


Import-Module operationsmanager -Verbose:$false
if (!(Get-SCOMManagementGroupConnection)) {
    Write-Verbose "[$(Get-Date -f G)] Connecting to $ManagementServer"
    New-SCOMManagementGroupConnection -ComputerName $ManagementServer -Verbose:$false
    if ($?) {
        Write-Verbose "[$(Get-Date -f G)] Connected to $ManagementServer"
    }
    else {
        Write-Verbose "[$(Get-Date -f G)] Could not connect to $ManagementServer. Error: $($Error[0].Exception.Message)"
    }
}
else {

    Write-Verbose "[$(Get-Date -f G)] Already connected to $ManagementServer"
}

Write-Verbose "[$(Get-Date -f G)] Getting Groups"

$Groups = Get-SCOMGroup -DisplayName 'PowerBI-*' 

Write-Verbose "[$(Get-Date -f G)] Filter Returned $($Groups.Count) Groups."
$Objects = foreach ($Group in $Groups) {
    if ($Group.Count -eq 0) {
        Write-Verbose "[$(Get-Date -f G)] $($Groups.DisplayName) has 0 members. Skipping..."

    }
    else {

        Write-Verbose "[$(Get-Date -f G)] Working on $($Groups.DisplayName)."

        $Group | Get-SCOMClassInstance | ForEach-Object {

            [PSCustomObject]@{
                GroupName  = $Group.DisplayName
                ServerName = $_.DisplayName
            }

        }



    }
}


$result = $Objects | ForEach-Object { 
    $ServerName = $_ | Select-Object -ExpandProperty ServerName
    $GroupName =  $_ | Select-Object -ExpandProperty GroupName
@"
{
   "ServerName" : "$ServerName",
   "GroupName"  : "$GroupName"
}
"@
}   
$json = "[" + ($result -Join ",`n") + "]"

Write-Verbose "[$(Get-Date -f G)] The json built: $json"
# You can use an optional field to specify the timestamp from the data. If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
$TimeStampField = ""



# Submit the data to the API endpoint

Post-LogAnalyticsData -WorkspaceID $WorkspaceID -WorkspaceKey $WorkspaceKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType  

