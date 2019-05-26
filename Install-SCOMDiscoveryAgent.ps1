#Requires -Modules ActiveDirectory,OperationsManager
$cred = Get-Credential
Import-Module OperationsManager,ActiveDirectory
$ManagementServer=Get-SCOMManagementServer -Name $Env:ComputerName*
$ADFilter = '(&(operatingSystem=*Server*)(objectClass=computer))'
$DaysOld=90
$OldDays=[DateTime]::Today.AddDays(-1*$DaysOld)
$Computers = Get-ADComputer -LDAPFilter $ADFilter -Properties PasswordLastSet,OperatingSystem | where {$_.PasswordLastSet -ge $OldDays}

$Ms = (Get-SCOMManagementServer).DisplayName
$agents=get-scomagent
$Agentless=(Get-SCOMAgentlessManagedComputer).DisplayName
$AgentsInProgress=(Get-SCOMPendingManagement | ? {$_.AgentPendingActionType -match 'PushInstall'}).AgentName
$ServersWithoutAgents=$Computers.DnsHostName |ForEach-Object {if($Agents.DisplayName -notcontains $_ -and $AgentsInProgress -notcontains $_ -and $Agentless -notcontains $_ -and $ms -notcontains $_){ $_}}


Install-SCOMAgent -PrimaryManagementServer $ManagementServer -Name $ServersWithoutAgents -ActionAccount $cred
