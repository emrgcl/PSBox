<#
DO NOT DELETE
Sample script to drop a custom event to event log.

#>
[CmdletBinding()]
Param(

[String]$LogName,
[String]$Message,
[int32]$EventID,
[string]$Source,
[ValidateSet("Information", "Error", "FailureAudit","SuccessAudit","Warning")]
[string]$EntryType = 'Information'

)
if (![System.Diagnostics.EventLog]::SourceExists($Source)) {
New-EventLog -Source $Source -LogName $LogName
}
Write-EventLog -LogName $LogName -EntryType $EntryType -EventId $EventID -Source $Source -Message $Message
