<#
.Synopsis
   Installs Scom Agent using hardcoded dynamic settings
.DESCRIPTION
   Installs Scom Agent using hardcoded dynamic settings
.EXAMPLE 
    .\Install-ScomAgent.ps1 -MGName 'SCOMMNG' -Verbose
    
    VERBOSE: Cannot install agent on SRVDMZ1SCOMGW. IT can be a managementserver or an agent is already installed.
    
   
.EXAMPLE 
    .\Install-ScomAgent.ps1 -MGName 'SCOMMNG' -WhatIf -Verbose

    What if: Performing the operation "msiexec.exe /i zzzz\MOMAgent.msi /qn USE_SETTINGS_FROM_AD=0 MANAGEMENT_GROUP=SCOMMNG MANAGEMENT_SERVER_DNS=srvdmz1scomgw.DMZDOMAIN.local MANAGEMENT_SERVER_AD_NAME=srvdmz1scomgw.DMZDOMAIN.local ACTIONS_US
E_COMPUTER_ACCOUNT=1 USE_MANUALLY_SPECIFIED_SETTINGS=1 AcceptEndUserLicenseAgreement=1" on target "SRVDMZ1SCOMGW".
    

    Script supports simiulating the operation. 
#>
[CmdletBinding(SupportsShouldProcess=$true)]
Param(

[Parameter(Mandatory = $true)]
[string]$MGName

)

$ManagementServerRegistry = @{

'LOCALDOMAIN' = @(@{PrimaryMS = 'srvscomms1.LOCALDOMAIN.local';SourcePath = '\\fileserver\d$\Sccm_sources\Software\SCOM2019\Agent\AMD64'},@{PrimaryMS='srvscomms2.LOCALDOMAIN.local';SourcePath='\\fileserver\d$\Sccm_sources\Software\SCOM2019\Agent\AMD64'})

'DMZDOMAIN' = @{ 

            '172.20.1' =@{PrimaryMS='srvdmz1scomgw.DMZDOMAIN.local';SourcePath='zzzz'}
            '172.20.2' =@{PrimaryMS='srvdmz2scomgw.DMZDOMAIN.local';SourcePath='ttttt'}

           }


}

$CanInstallAgent='srvdmz1scomgw','srvdmz2scomgw','srvscomms1','srvscomms2' -notcontains $env:COMPUTERNAME


$Settings = switch ($env:USERDOMAIN) {


'LOCALDOMAIN' {$ManagementServerRegistry.LOCALDOMAIN | Get-Random}
'DMZDOMAIN' {$ManagementServerRegistry.DMZDOMAIN."$((Get-NetIPAddress).IPAddress | ForEach-Object  {if($_ -match '(?<DMZ>172\.20\.(1|2))') {$Matches['DMZ']}})"}


}

$ScomAgent = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq 'Microsoft Monitoring Agent'}| Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

if(!$ScomAgent -and $CanInstallAgent) {

$CommandLine="msiexec.exe /i $($Settings.SourcePath)\MOMAgent.msi /qn USE_SETTINGS_FROM_AD=0 MANAGEMENT_GROUP=$MGName MANAGEMENT_SERVER_DNS=$($Settings.PrimaryMS) MANAGEMENT_SERVER_AD_NAME=$($Settings.PrimaryMS) ACTIONS_USE_COMPUTER_ACCOUNT=1 USE_MANUALLY_SPECIFIED_SETTINGS=1 AcceptEndUserLicenseAgreement=1"
Write-Verbose "[$(Get-Date -Format G)] Running on server $($env:COMPUTERNAME)"
Write-Verbose "[$(Get-Date -Format G)] CommandLine is $CommandLine"
if ($pscmdlet.ShouldProcess($Env:ComputerName, $CommandLine))
{
        
Invoke-Expression $commandline -Verbose:$VerbosePreference 
}

} else {

Write-Verbose -Message "Cannot install agent on $($Env:ComputerName). IT can be a managementserver or an agent is already installed."
} 
