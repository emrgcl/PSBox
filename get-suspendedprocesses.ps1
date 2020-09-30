<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Below is an example on returning the suspended process with the SearchUI process (which is suspended) excluded.
    
   PS C:\SCRIPTS> .\Get-SuspendedProcesses.ps1 -ExcludedProcesses 'SearchUI'

   Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName                                                                                                                       
   -------  ------    -----      -----     ------     --  -- -----------                                                                                                                       
   779      32        21192      63384     0,80       64  3  ShellExperienceHost                                                                                                               
   1140     0         124        1168      1.179,25    4  0  System                                                                                                                            


.EXAMPLE
   Below is an example on returning the suspended process only within the IncludedProcesses parameter.

   PS D:\SCOM_SCRIPTS> .\Get-SuspendedProcesses.ps1 -IncludedProcesses 'SearchUI','NonExistingProcess'

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName                                                                                                                       
-------  ------    -----      -----     ------     --  -- -----------                                                                                                                       
    953      61    51924     107392       1,64   6176   3 SearchUI                                                                                                                          

#>
[CmdletBinding()]
Param(
    [Parameter(ParameterSetName='Included',Mandatory = $true)]
    [string[]]$IncludedProcesses,
    [Parameter(ParameterSetName='Excluded',Mandatory = $true)]
    [string[]]$ExcludedProcesses

)
$Suspended = 5
switch ($PSCmdlet.ParameterSetName)
{
    'Included' {Get-Process | Where-Object { $_.Threads.WaitReason.Value__ -contains $Suspended -and $_.Name -in $IncludedProcesses}}
    'Excluded' {Get-Process | Where-Object { $_.Threads.WaitReason.Value__ -contains $Suspended -and $_.Name -notin $ExcludedProcesses}}
}

