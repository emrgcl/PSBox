<#
.Synopsis
   Removes selected recoveries
   Please use Whatif first. and -Verbose always
.EXAMPLE
    .\remove-scomrecovery.ps1 -ManagementServer ms1.contoso.com -ManagementPack "Contoso.ServiceMonitor" -Verbose
    
    VERBOSE: [17.06.2019 15:28:08] Connected to ms1.contoso.com
    VERBOSE: Performing the operation "Deleting Recovery Task" on target "TestRecovery1-GateXXX".
    VERBOSE: [17.06.2019 15:28:34]Successfully Deleted TestRecovery1-GateXXX

    Above example with verbose output

.EXAMPLE
    .\remove-scomrecovery.ps1 -ManagementServer ms1.contoso.com -ManagementPack "Contoso.ServiceMonitor" -WhatIf
   to simulate Operation please use Whatif.
#>
[CmdLetBinding(
SupportsShouldProcess=$true
)]
Param(
[string]$ManagementServer,
[string]$ManagementPack
)

if (!(Get-SCOMManagementGroupConnection)) 
{
New-SCOMManagementGroupConnection -ComputerName $ManagementServer
} else {
Write-Verbose "[$(Get-Date -Format G)] Connected to $ManagementServer"
}

$mg=Get-SCOMManagementGroup
$DeleteState = [Microsoft.EnterpriseManagement.Configuration.ManagementPackElementStatus]::PendingDelete

$SelectedRecoveries=Get-SCOMManagementPack -DisplayName $ManagementPack | Get-SCOMRecovery | Out-GridView -PassThru
$SelectedRecoveries | ForEach-Object {

$rec=$mg.Monitoring.GetRecovery.Invoke($_.Id)
$rec.Status = $DeleteState
$mp=$rec.GetManagementPack()
        if ($pscmdlet.ShouldProcess($_.Displayname, "Deleting Recovery Task"))
        {

        try
        {
        
            $mp.AcceptChanges()
            $Message="[$(Get-Date -Format G)] Successfully Deleted $($_.DisplayName)"
        
        }
        catch 
        {
            $Message= "[$(Get-Date -Format G)] Error Occured during save. Error: $($error[0].Exception.Message)"
        }
        
        Write-Verbose $Message
        
        }


}
