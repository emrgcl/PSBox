<#
.Synopsis
   Runs test-netconnection powershell against specified computername.
.DESCRIPTION
   Runs test-netconnection powershell against specified computername. requires 'scom management' management pack by Kevin Holman
.EXAMPLE
   .\Execute-SCOMAgentTelnet.ps1 -ComputerName '10.86.36.130' -ManagementServer $env:COMPUTERNAME -Port 9200 -ServerListPath C:\temp\servers.txt

   PingSucceeded    : 10 ms
   RemoteAddress    : 10.86.36.130
   ComputerName     : 10.86.36.130
   RemotePort       : 9200
   SourceAddress    : 172.30.34.230
   InterfaceAlias   : Ethernet
   TcpTestSucceeded : True

   PingSucceeded    : 0 ms
   RemoteAddress    : 10.86.36.130
   ComputerName     : 10.86.36.130
   RemotePort       : 9200
   SourceAddress    : 10.86.67.167
   InterfaceAlias   : LAN1
   TcpTestSucceeded : True
#>
[cmdletbinding()]
Param(

[string]$ComputerName,
[string]$ManagementServer,
[string]$Port,
[string]$ServerListPath

)
Import-Module OperationsManager
if (!(Get-SCOMManagementGroupConnection).Isactive) {

New-SCOMManagementGroupConnection -ComputerName $ManagementServer

}
$Override = @{
ScriptBody = "Test-NetConnection -ComputerName $ComputerName -port $Port"
}
$ServerList = Get-Content -Path $ServerListPath
$PSTask = Get-SCOMTask -DisplayName 'Execute any PowerShell'
$Instances = Get-SCOMClass -Name 'SCOM.Management.Class' | Get-SCOMClassInstance
$SelectedInstances = $Instances.Where({$ServerList -contains $_.DisplayName})
$startedtasks = Start-SCOMTask -Instance $SelectedInstances -Task $PSTask -Override $Override
foreach ($startedtask in $startedtasks) {
do {
$TaskResult = Get-SCOMTaskResult -Id $startedtask.Id.Guid

[xml]$xml=$TaskResult.Output
if ($xml.DataItem.Description -match '(?s)ComputerName\s+\:\s(?<ComputerName>\S+)\sRemoteAddress\s+\:\s(?<RemoteAddress>\S+)\sRemotePort\s+\:\s(?<RemotePort>\S+)\sInterfaceAlias\s+\:\s(?<InterfaceAlias>\S+)\sSourceAddress\s+\:\s(?<SourceAddress>\S+)\sPingSucceeded\s+\:\s(?<PingSucceeded>\S+)\sPingReplyDetails\s\(RTT\)\s+\:\s(?<PingSucceeded>\S+\sms)\sTcpTestSucceeded\s+\:\s(?<TcpTestSucceeded>\S+)'){

[PsCustomobject]@{

PingSucceeded=$Matches['PingSucceeded']
RemoteAddress=$Matches['RemoteAddress']
ComputerName=$Matches['ComputerName']
RemotePort=$Matches['RemotePort']
SourceAddress=$Matches['SourceAddress']
InterfaceAlias=$Matches['InterfaceAlias']
TcpTestSucceeded=[bool]$Matches['TcpTestSucceeded']
}

}
} until ($TaskResult.Output -and $true)
}
