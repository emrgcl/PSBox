$LastHours = 8
Get-SCOMTask | where {$_.Identifier -match 'Microsoft\.SystemCenter\.PushAgentInstaller'} | Get-SCOMTaskResult | where {$_.TimeFinished -ge (Get-date).AddHours(-1*$LastHours)} | ForEach-Object {

if($_.Output -match "(?s)<ErrorCode>(?<ErrorCode>\d+)</ErrorCode>.+<AgentName>(?<AgentName>\S+)</AgentName>") {
[PSCustomobject]@{
ServerName = "$($Matches["AgentName"])"
ErrorCode = "$($Matches["ErrorCode"])"

} 
}

} | Group-Object -Property ErrorCode
