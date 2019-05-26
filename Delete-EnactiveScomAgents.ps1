#THis script deletes the scoma agents if the computer account of the scom agent did not reset thes computer account password older than $daysold.
#Requires -Modules ActiveDirectory,OperationsManager
 
 
Import-Module OperationsManager,ActiveDirectory
 
$ManagementServer=Get-SCOMManagementServer -Name $Env:ComputerName*
$ADFilter = '(&(operatingSystem=*Server*)(objectClass=computer))'
$DaysOld=90
function New-Collection ( [type] $type ) 
{
                $typeAssemblyName = $type.AssemblyQualifiedName;
                $collection = new-object "System.Collections.ObjectModel.Collection``1[[$typeAssemblyName]]";
                return ,($collection);
}
 
Function Delete-Agent {
Param(
  [string[]]$AgentComputerName,
  [string]$MSServer
)
[System.Reflection.Assembly]::Load("Microsoft.EnterpriseManagement.Core, Version=7.0.5000.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
[System.Reflection.Assembly]::Load("Microsoft.EnterpriseManagement.OperationsManager, Version=7.0.5000.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
 
 
 
 
 
# Connect to management group
Write-output "Connecting to management group"
$ConnectionSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MSServer)
$admin = $ConnectionSetting.GetAdministration()
 
Write-output "Getting agent managed computers"
$agentManagedComputers = $admin.GetAllAgentManagedComputers()
# Get list of agents to delete
foreach ($name in $AgentComputerName) 
{
    Write-output "Checking for $name"
    foreach ($agent in $agentManagedComputers)
    {
        if ($deleteCollection -eq $null) 
        {
            $deleteCollection = new-collection $agent.GetType()
        }
        
        if (@($agent.PrincipalName -eq $name))
        {
                    Write-output "Matched $name"
            $deleteCollection.Add($agent)
            break
        }
    }
}
if ($deleteCollection.Count -gt 0) 
{
    Write-output "Deleting agents"
    $admin.DeleteAgentManagedComputers($deleteCollection)
    if($?){ Write-output "Agents deleted" }
}
}
 
 
 
 
$OldDays=[DateTime]::Today.AddDays(-1*$DaysOld)
$Computers = Get-ADComputer -LDAPFilter $ADFilter -Properties PasswordLastSet,OperatingSystem | where {$_.PasswordLastSet -le $OldDays}
 
Delete-Agent -AgentComputerName $Computers.DnsHostName -MSServer $Env:ComputerName
