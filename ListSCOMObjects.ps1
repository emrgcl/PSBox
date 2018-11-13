<#
.Synopsis
   Retrieves the instances of the given class along with health
.DESCRIPTION
   Retrieves the instances of the given class along with health and and agent status. Please be aware that objects can have multiple tiers IF thats the case script splits and dynamicaly creates ObjectsHostxxx.
.EXAMPLE
    .\ListSCOMObjects.ps1 -ManagementServer ms1fqdn -Class "IIS Web Site"

This example class has only one child object

ServerName            		Object                                      AgentHealth ObjectHealth
----------            		------                                      ----------- ------------
DrcSkypeFe1.litware.com 	Skype for Business Server External Web Site        True      Success
LyncW16Fe3.litware.com  	Skype for Business Server External Web Site        True      Success
DrcSkypeFe5.litware.com 	Skype for Business Server External Web Site        True      Success
DrcSkypeFe4.litware.com 	Skype for Business Server External Web Site        True      Success
LyncW16Fe1.litware.com  	Skype for Business Server External Web Site        True      Success

.EXAMPLE
   .\ListSCOMObjects.ps1 -ManagementServer ms1fqdn -Class "sql database" | Group-Object -Property ServerName | Select-Object -Property Name,Count | Sort-Object -Property Count -desc

Since we return custom objects group-objects can easily be used for inventory reporting purposes.

Name                      Count
----                      -----
tstFGSDB.litware.com          117
MSSQL1.litware.com             96
MSSQLT1.litware.com            93
SPS13SQLTEST.litware.com       75
MSSQL2.litware.com             74
HDHMICRO01.litware.com         62
ovwccncdbstb.litware.com       60
tstTestDB1.litware.com         56
HDHELEKTR1.litware.com         46
SPS2013SQL.litware.com         44

.EXAMPLE 
    .\ListSCOMObjects.ps1 -ManagementServer ms1fqdn -Class "sql database"

In this example between the database and the server theres the ObjectHost1 which is the sql server instance.

OjectHost1   : MSSQLSERVER
ServerName   : hdhTestDB.srvdmz.com
Object       : model
AgentHealth  : True
ObjectHealth : Success

OjectHost1   : SQLT1
ServerName   : MSSQLXX1.litware.com
Object       : Prcher_Config_621
AgentHealth  : True
ObjectHealth : Success

OjectHost1   : SQL1
ServerName   : tstDBLIVE1.litware.com
Object       : xxxBBS
AgentHealth  : True
ObjectHealth : Success

OjectHost1   : SQL2
ServerName   : CASQL1-V.litware.com
Object       : yyy_Reporting
AgentHealth  : True
ObjectHealth : Success

.EXAMPLE
    .\ListSCOMObjects.ps1 -ManagementServer ms1fqdn -Class "sql database" | ft -AutoSize

OjectHost1   ServerName                Object                                                                                  AgentHealth  ObjectHealth
----------   ----------                ------                                                                                  -----------  ------------
MSSQLSERVER  cccc.litware.com	         cbslog                                                                                          True       Success
MSSQLSERVER  tststst.litware.com       ETA_KKST_2015                                                                                   True       Success
WINCCT        test1.litware.com        DB1                                                                                             True       Success
MSSQLSERVER  WWWSQL1.srvdmz.com        DB2                                                                                             True       Warning
MSSQLSERVER  tstFGSDB.litware.com      DBXXX                                                                                           True       Success
SQLT1        MSSQLXX1.litware.com      prjtest                                                                                         True       Success
MSSQLSERVER  yyyy.litware.com          KOTAX                                                                                           True       Success

.EXAMPLE
    .\ListSCOMObjects.ps1 -ManagementServer ms1fqdn -Class "sql database" |  Export-Csv -Path C:\Temp\result.csv
    This example lists the objects and then export to a csv file.
.OUTPUTS
   PScustomObject
.NOTES
   Please be aware that objects can have multiple tiers IF thats the case script splits and dynamicaly creates ObjectsHostxxx.
#>

    [CmdletBinding( 
                  SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([PSCustomOBject])]
    Param
    (
        # ManagementServer to connect
        [Parameter(Mandatory=$true)]
        [ValidateSet("ms1fqdn", "ms2fqdn", "ms1fqdn3")]
        [Alias("ms")] 
        [string]$ManagementServer,

        # Class to Report

        [string]$Class    
        )

    Process
    {
Import-module OperationsManager
if(!$(Get-SCOMManagementGroupConnection)) {
New-SCOMManagementGroupConnection -ComputerName $ManagementServer
}
Get-SCOMClass -DisplayName $Class | Get-SCOMClassInstance  | ForEach-Object {

$SplitResult=$_.Path -split ";"
if ($SplitResult.Count -eq 1) {

$Props=@{}
$Props.ServerName=$SplitResult[0]
$Props.Object=$_.DisplayName
$Props.ObjectHealth=$_.HealthState
$Props.AgentHealth=$_.IsAvailable
New-Object -TypeName PSCustomObject -Property $props | Write-Output
} else {
$Props=@{}
$Props.ServerName=$SplitResult[0]
$Props.ObjectHealth=$_.HealthState
$Props.Object=$_.DisplayName
$Props.AgentHealth=$_.IsAvailable

$i=1
Do {
#New-Variable -Name "Props.Property$i" -Value $SplitResult[$i]
$Props.Add("OjectHost$($i)",$SplitResult[$i])
}
while(++$i -le $SplitResult.Count-1)
New-Object -TypeName PSCustomObject -Property $props | Write-Output
}

}
}    
