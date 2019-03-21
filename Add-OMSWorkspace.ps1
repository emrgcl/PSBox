<#
.Synopsis
   Adds the group members to specified OMS Workspace
.DESCRIPTION
   Script requires scom agent management pack please install and impor the management pack from:
   https://gallery.technet.microsoft.com/SCOM-Agent-Management-b96680d5
.EXAMPLE
   .\Add-OMSWorkspace.ps1 -WorkspaceKey 'xxxxxx' -WorkspaceID 'yyyyyyyy' -ManagementServer 'ms1.contoso.com' -GroupDisplayName 'SQL Computers' -ProxyURL 'omsgateway.contoso.com:8080' -Verbose
#>
[CmdLetBinding()]
Param(
[string]$ManagementServer,
[string]$GroupDisplayName,
[string]$WorkspaceKey,
[string]$WorkspaceID,
[string]$ProxyURL
)

import-module operationsmanager
if (!(Get-SCOMManagementGroupConnection)) 
{
Write-Verbose "[$(Get-Date -f G)] Connecting to $ManagementServer"
New-SCOMManagementGroupConnection -ComputerName $ManagementServer
if ($?){
Write-Verbose "[$(Get-Date -f G)] Connected to $ManagementServer"
} else {
Write-Verbose "[$(Get-Date -f G)] Could not connect to $ManagementServer. Error: $($Error[0].Exception.Message)"
}
}

#We requrie the SCOM Management Pack to be installed
if (Get-SCOMManagementPack -Name 'SCOM.Management') {

#Setting Task Override Parameters
$Override=@{
WorkspaceKey=$WorkspaceKey
WorkspaceID=$WorkspaceID
ProxyURL=$ProxyURL
}
Write-Verbose "[$(Get-Date -f G)] Workspace Parameters are: `nWorkspace Key: $($Override.WorkspaceKey)`nWorkpsaceID: $($Override.WorkspaceID)`nProxyURL: $($Override.ProxyURL)"
#Getting servers those are member of the Group
$Servers=(Get-SCOMGroup -DisplayName $GroupDisplayName).GetRelatedMonitoringObjects()

#Getting the agent management objects those are hosted on the servers above
$ID=(get-scomclass | where {$_.Name -eq 'SCOM.Management.Agent.Class'}).ID
$Helpers=$Servers | ForEach-Object {$_.GetRelatedMonitoringObjects() | Where-Object {$_.MonitoringClassIds -eq $ID}} 
#Task wont work if the object is not available
$AvailableHelpers = $helpers | Where-Object {$_.IsAvailable -eq $true}
Write-Verbose "[$(Get-Date -f G)] Tasks will run for the following Agents`n-------------------------------------------------"
$AvailableHelpers| ForEach-Object {Write-Verbose "[$(Get-Date -f G)] $($_.DisplayName)" -Verbose}
#getting the task to be executed
$Task = Get-SCOMTask -DisplayName "OMS Workspace - ADD"
#starting the task
Start-SCOMTask -Task $Task -Instance $helpers -Override $override | Out-Null
if($?) {
Write-Verbose "[$(Get-Date -f G)] Successfully started task!"
}
} else {
#if the mp is not installed refer to the intallation site.
Write-Host "SCOM Agent Management Pack is not Installed. `n`nPlease download the management pack from https://gallery.technet.microsoft.com/SCOM-Agent-Management-b96680d5" -ForegroundColor Red

}
