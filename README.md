# PSBox
Powershell Scripts for Everyone
## Test-PSRemoting.ps1
This script tests PowerShell Remoting using **Test-WSMan** cmdLet and returns a Custom PSobject with ServerName and Result.

You can use this script in large sets of servers. In an environment of 500 servers script ends around 3 minutes.
### Examples
+ Pipe from SCOM
```ps 
get-scomagent | test-psremoting -HideSuccess | export-csv -Path c:\temp\wsmanresult.csv
````
+ get-content | test-psremoting | Group-Object -PropertyName ErrorCode
+ test-psremoting -ServerName "server1","server2","server3"
