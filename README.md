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