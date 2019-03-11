<#
.Synopsis
   Installs scom agent Silenlty for the specified management server
.DESCRIPTION
   Installs scom agent Silenlty for the specified management server
.EXAMPLE
   .\Install-ScomAgent.ps1 -SourcePath 'C:\Source\AMD64' -MGName 'Your_ManagementGroup_Name' -PrimaryMS 'ms1.contoso.com'
   VERBOSE: [3/11/2019 1:49:09 PM] Running on server SRVDMZ1MOBILE2
   VERBOSE: [3/11/2019 1:49:09 PM] CommandLine is msiexec.exe /i C:\Source\AMD64\MOMAgent.msi /qn USE_SETTINGS_FROM_AD=0 MANAGEMENT_GROUP=Your_ManagementGroup_Name MANAGEMENT_SERVER_DNS=ms1.contoso.com MANAGEMENT_SERVER_AD_NAME=ms1.contoso.com ACTIONS_USE_COMPUTER_ACCOUNT=1 USE_MANUALLY_SPECIFIED_SETTINGS=1 AcceptEndUserLicenseAgreement=1
#>

    [CmdletBinding()]
    Param
    (
        # Source path to momagent.msi
        [Parameter(Mandatory=$true)]
        [string]$SourcePath='.',

        [Parameter(Mandatory=$true)]
        [string]$PrimaryMS='SRVDMZ1SCOM.emlakdmz.local',

        [Parameter(Mandatory=$true)]
        [string]$MGName='SCOM_EMLAK_GROUP'

    )



$CommandLine="msiexec.exe /i $SourcePath\MOMAgent.msi /qn USE_SETTINGS_FROM_AD=0 MANAGEMENT_GROUP=$MGName MANAGEMENT_SERVER_DNS=$PrimaryMS MANAGEMENT_SERVER_AD_NAME=$PrimaryMS ACTIONS_USE_COMPUTER_ACCOUNT=1 USE_MANUALLY_SPECIFIED_SETTINGS=1 AcceptEndUserLicenseAgreement=1"
Write-Verbose "[$(Get-Date -Format G)] Running on server $($env:COMPUTERNAME)"
Write-Verbose "[$(Get-Date -Format G)] CommandLine is $CommandLine"
Invoke-Expression $commandline -Verbose:$VerbosePreference 
