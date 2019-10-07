# Certificates

- to Show which template the certificate is genereted from;
```PowerShell
Get-ChildItem -Path Cert:\LocalMachine\My | Select-Object -Property Thumbprint,@{Name='Path';Expression={"$(($_.PSParentPath  -split '\:\:')[1])\$($_.Thumbprint)"}
},@{Name='DaysToExpire';Expression={($_.NotAfter)}},@{Name='IssuerName';Expression={$_.IssuerName.Name}},HasPrivateKey,DnsNameList, @{Name='NetbiosComputerName';Expression={$env:COMPUTERNAME}},@{Name='SignatureAlgorithm';Expression={$_.SignatureAlgorithm.FriendlyName}},@{Name='Certificate Template Name';Expression= {(($_.Extensions).Where({$_.Oid.FriendlyName -eq 'Certificate Template Name'})).Format(0)} },@{Name='Subject Alternative Name';Expression= {(($_.Extensions).Where({$_.Oid.FriendlyName -eq 'Subject Alternative Name'})).Format(0)} } 

```
