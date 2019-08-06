# Install nuget provider so that Install-Module and Register-Repository cmdlets works successfully.
if (!(test-path -path 'C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208\Microsoft.PackageManagement.NuGetProvider.dll')) {
    Copy-Item -Path \\SERVER\PowerShellGet\PackageManagement -Destination 'C:\Program Files' -Recurse -Force
    }
    
    # if sqlserver is not installed Register our localpository which is afile sahre and Install module using this local share
    if ((Get-Module -Name 'SQLServer' -ListAvailable).Count -eq 0){
        $LocalRepository = '\\server\Psrepository'
        if ((Get-PSRepository).Name -notcontains 'localPSrepo') {
        Register-PSRepository -Name LocalPSRepo -SourceLocation $LocalRepository -ScriptSourceLocation $LocalRepository -InstallationPolicy Trusted
        }
        Install-Module -Repository LocalPSRepo -Name SQLserver
    }
