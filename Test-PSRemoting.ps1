<#
.Synopsis
   This script tests PowerShell Remoting using Test-WSMan cmdLet.
.DESCRIPTION
   This script tests PowerShell Remoting using Test-WSMan cmdLet and returns a Custom PSobject with ServerName and Result.
.EXAMPLE
   test-psremoting -ServerName "server1","server2","server3"
.EXAMPLE
    get-scomagent | test-psremoting -HideSuccess | export-csv -Path c:\temp\wsmanresult.csv
.EXAMPLE
    get-content | test-psremoting -HideSuccess
.EXAMPLE
    get-content | test-psremoting | Group-Object -PropertyName ErrorCode
.INPUTS
   System.String
.OUTPUTS
   System.Management.Automation.PSCustomObject
.FUNCTIONALITY
   You can use this script in large sets of servers. In an environment of 500 servers script ends around 3 minutes.
#>
<#
 Author: Emre Güçlü
 Date: 9 October 2018
#>
[CmdletBinding( 
    SupportsShouldProcess = $true, 
    HelpUri = 'http://www.microsoft.com/',
    ConfirmImpact = 'Medium')]
[OutputType([String])]
Param
(
    # The Server list
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        ValueFromRemainingArguments = $false, 
        Position = 0)]
    [Alias("Server", "Host", "Node", "NetworkName", "DnsHostName", "fqdn", "DispLayName")] 
    [String[]]$ServerName,

    # Switch Parameter to hide success results.
    [Parameter(Mandatory = $false)]
    [switch]$HideSuccess
)
Process {
    foreach ($Server in $ServerName) {
        #running test-wsman against each server in pipeline. Dont need any Input I will control it:)
        test-wsman $Server -ErrorAction SilentlyContinue | Out-Null
        # if scuesss add 0 as error code to the custom object
        if ($?) {
            if (!$HideSuccess) {
                $objInfo = @{}
                $objInfo.ServerName = $Server
                $objInfo.ErrorCode = 0
                $objInfo.Message = 'Success'
                New-Object -TypeName PSObject -Property $objInfo|Write-Output 
            }
        }
        else {
            # else catch the errorcode using regex and add the errorcode to the custom object
            if ($Error[0].Exception.Message -match '(?<pre>Code=")(?<ErrorCode>\d+)(?<post>")(?<Mid>.+)(?<Pre1><f:Message>)(?<Message>.+)(?<Post1></f:Message>)') {
                $objInfo = @{}
                $objInfo.ServerName = $Server
                $objInfo.ErrorCode = $Matches["ErrorCode"]
                $objInfo.Message = $Matches["Message"]
                New-Object -TypeName PSObject -Property $objInfo|Write-Output 
            }
        }
    }
}