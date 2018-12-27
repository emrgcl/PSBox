# PSBox
Powershell Scripts for Everyone
## Test-PSRemoting.ps1
This script tests PowerShell Remoting using **Test-WSMan** cmdLet and returns a Custom PSobject with ServerName and Result.

You can use this script in large sets of servers. In an environment of 500 servers script ends around 3 minutes.
### Examples
+ Pipe from SCOM
```powershell 
get-scomagent | .\test-psremoting.ps1 -HideSuccess | export-csv -Path c:\temp\wsmanresult.csv
````
+ Pipe From a text file and group object to make a summary report 
```powershell
get-content | .\test-psremoting.ps1 | Group-Object -PropertyName ErrorCode
```
+ Dont pipe just provide the Server Names
```powershell
.\test-psremoting.ps1 -ServerName "server1","server2","server3"
```
## Disable-SCOMCollection.ps1

## ListSCOMObjects.ps1
Lists the objects of a class and parses the path so that the every single parent host is reported on the object. 
Great to check the number of instances of a class on a Server.

### Examples
+  Lists the objects and formats as table
```powershell 
.\ListSCOMObjects.ps1 -ManagementServer ms1fqdn -Class "sql database" | ft -AutoSize
powershell 

OjectHost1   ServerName                Object                                                                                  AgentHealth  ObjectHealth
----------   ----------                ------                                                                                  -----------  ------------
MSSQLSERVER  cccc.litware.com	         cbslog                                                                                          True       Success
MSSQLSERVER  tststst.litware.com       ETA_KKST_2015                                                                                   True       Success
WINCCT        test1.litware.com        DB1                                                                                             True       Success
MSSQLSERVER  WWWSQL1.srvdmz.com        DB2                                                                                             True       Warning
MSSQLSERVER  tstFGSDB.litware.com      DBXXX                                                                                           True       Success
SQLT1        MSSQLXX1.litware.com      prjtest                                                                                         True       Success
MSSQLSERVER  yyyy.litware.com          KOTAX                                                                                           True       Success
