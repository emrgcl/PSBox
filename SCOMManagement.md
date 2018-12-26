The following line lists scom Gateways with their failover servers.
```powershell
Get-SCOMGatewayManagementServer | Select-Object -Property DisplayName, @{Name="PrimaryServer"; Expression={($_.GetPrimaryManagementServer()).DisplayName}},@{Name="FailOverServer"; Expression={($_.GetFailoverManagementServers()).DisplayName}}
```
The following line returns top 20 active alerts in scom console
```powershell
Get-SCOMAlert | where ResolutionState -eq 0 | Group-Object -Property Name | Sort-Object -Property Count -Descending  | Select-Object -Property Count,Name -First 20
```
