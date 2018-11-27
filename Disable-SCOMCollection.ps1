<#
.Synopsis
   Disables Performance or Event Collection Events
.DESCRIPTION
   Disables Performance or Event Collection Events
.EXAMPLE
   Get-SCOMManagementPack | where {$_.Name -match 'SQL.+2014\.Monitoring'}| .\Disable-SCOMCollection.ps1 -ManagementServer tgarscmmgs01 -OverrideMP "Test MP" -DisableTarget PerformanceCollection -WhatIf

   What if: Performing the operation "Disabling PerformanceCollection Rule in (Test MP)" on target "MSSQL 2014: DB File Allocated Free Space (MB)".
   What if: Performing the operation "Disabling PerformanceCollection Rule in (Test MP)" on target "MSSQL 2014: Parallel GC work item/sec".
   What if: Performing the operation "Disabling PerformanceCollection Rule in (Test MP)" on target "MSSQL 2014: Used amount of memory in the resource pool (KB)"
#>
    [CmdletBinding(SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    Param
    (
        
        # ManagementPacks to be disabled
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        $SourceMP,
        
        
        # Param2 help description
        [Parameter(Mandatory=$true)]
        [string]$OverrideMP,
        
        # ManagementServer to be selected
        [Parameter(Mandatory=$true)]
        [ValidateSet("ptekscmmgs01","ptekscmmgs02","tgarscmmgs01","tgarscmmgs02","pfinscmmgs01","pfinscmmgs02","pdmzscmmgs01","pdmzscmmgs02")]
        [string]$ManagementServer,

        #DisableTarget
        [Parameter(Mandatory=$true)]
        [ValidateSet("EventCollection","PerformanceCollection")]
        [string]$DisableTarget

    )

    Begin
    {
        Import-Module OperationsManager -Verbose:$false
        if ((Get-SCOMManagementGroupConnection|where {$_.IsActive}).ManagementServerName -notmatch "$ManagementServer") {
         New-SCOMManagementGroupConnection -ComputerName $ManagementServer
         Write-Verbose "Connected to management server: $($ManagementServer)"
        } else {
        Write-Verbose "Already connected to $((Get-SCOMManagementGroupConnection|where {$_.IsActive}).ManagementServerName)"
        
        if (!(Get-SCOMManagementPack -DisplayName $OverrideMP)) {
        Throw "OverrideMP not found. Please create it before the script"
        }
        }
    }
    Process
        {

        $Rules=$_ | Get-SCOMRule | where {$_.Category -eq $DisableTarget}
        foreach ($Rule in $Rules) {
        
        if ($pscmdlet.ShouldProcess($Rule.DisplayName, "Disabling $($DisableTarget) Rule in ($OverrideMP)"))
        {
        
        #Disable-SCOMRule -Rule $PerfRules -ManagementPack $overridesmp
        
        Disable-SCOMRule -Rule $Rule -ManagementPack $overridesmp | Out-Null
        
        }
        }
    }

