[CmdletBinding()]
Param()
Function Process-Queue {
[CmdletBinding()]
Param(
[System.Collections.Queue]$Queue
)
do {
Write-Verbose "Current number of items in the Queue: $($Queue.Count)"
$FileToMove = $Queue.Peek()
Write-Verbose $FileToMove
Move-Item -Path $FileToMove.FullName  C:\temp\Target | Out-Null
Write-Verbose -Message "Moved $($FileToMove.FullName)"
$queue.Dequeue() | out-null
Export-Clixml -Path 'c:\temp\Queue.xml' -InputObject $Queue
Write-Verbose -Message 'Sleeping 15 seconds'
start-sleep -Seconds 15

} until ($Queue.Count -eq 0)
}

if (Test-Path -Path C:\temp\Queue.xml) {
[System.Collections.Queue]$OldQueue=Import-Clixml -Path C:\temp\Queue.xml
Write-Verbose -Message "Found existing Queue. $($OldQueue.Count) items in the queue"
process-Queue -Queue $OldQueue
}



$Files = gci -Path C:\temp\ | where {$_.Name -like '*.ps1'}

#Queue objectini oluşturalım
$Queue = New-Object -TypeName 'System.Collections.Queue'

#dosyaları queueya atalım
Foreach ($File in $files) {
$Queue.Enqueue($File)
}

Write-Verbose -Message "Number of Queue Items: $($Queue.Count)"

# Snapshotı alalım
Export-Clixml -Path 'c:\temp\Queue.xml' -InputObject $Queue
process-Queue -Queue $Queue

if($Queue.Count -eq 0) {

Remove-Item 'C:\temp\Queue.xml'

}



