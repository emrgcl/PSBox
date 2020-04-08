# Certificates

- to Show which template the certificate is genereted from;
```PowerShell
Get-ChildItem -Path Cert:\LocalMachine\My | Select-Object -Property Thumbprint,@{Name='Path';Expression={"$(($_.PSParentPath  -split '\:\:')[1])\$($_.Thumbprint)"}
},@{Name='DaysToExpire';Expression={($_.NotAfter)}},@{Name='IssuerName';Expression={$_.IssuerName.Name}},HasPrivateKey,DnsNameList, @{Name='NetbiosComputerName';Expression={$env:COMPUTERNAME}},@{Name='SignatureAlgorithm';Expression={$_.SignatureAlgorithm.FriendlyName}},@{Name='Certificate Template Name';Expression= {(($_.Extensions).Where({$_.Oid.FriendlyName -eq 'Certificate Template Name'})).Format(0)} },@{Name='Subject Alternative Name';Expression= {(($_.Extensions).Where({$_.Oid.FriendlyName -eq 'Subject Alternative Name'})).Format(0)} } 

```

# DateTime

Converting Datetime to CIMDatetime
```
Function Get-CIMDateTime {

<#



HighLEvel Steps

1) Get String with UTC ofsset pattern. Ie: 20200408115224.000000+03:00 while doing so get the UTCSign and the UTCHour
2) Split the the hour and make calculatations to convert to 3 digit minutes
3) Replace the +3:00 with the calculated 180


#>
$CimDateString= get-date -Format "yyyyMMddHHmmss.000000K"
if ($CimDateString -match '(?<UTCSign>\+|-)(?<UTC>.+)')

{

$UTCArray = $Matches['UTC'] -split ':'

$UTCMinutes =  "{0:d3}" -f  ([int]$UTCArray[0] *60 + [int]$UTCArray[1])

$CimDateString -replace '\+(.+)' ,"$($Matches['UTCSign'])$UTCMinutes"
}

}
```
