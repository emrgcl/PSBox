# Certificates

Importing a PFX and Cer Certificate.

```PowerShell

$Pass = '1234'
$Cert = Get-ChildItem -Path 'C:\scom\Certs\Certs\IST5WINEXTWEB1_.pfx'
$RootCA = Get-ChildItem -Path 'C:\scom\certs\Certs\rootca.cer'
$Cert | Import-PFXCertificate -CertStoreLocation 'Cert:\LocalMachine\My' -Password (ConvertTo-SecureString -String $Pass -AsPlainText -Force)
$RootCA | Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root'


```
