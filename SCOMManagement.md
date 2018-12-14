The following line lists scom Gateways with their failover servers.
```powershell
Get-SCOMGatewayManagementServer | Select-Object -Property DisplayName, @{Name="PrimaryServer"; Expression={($_.GetPrimaryManagementServer()).DisplayName}},@{Name="FailOverServer"; Expression={($_.GetFailoverManagementServers()).DisplayName}}
```
