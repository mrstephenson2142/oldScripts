<#

Release messages from quarantine.
Provide a list of Internet Message IDs in the for of a txt file to the script.
IDs must be on individual lines. Script will prompt for the file with a file picker. 

Usage: ./releaseFromQuarantine 

#>


$ErrorActionPreference = "silentlycontinue"  

function EOConnected {
   
    Get-HostedContentFilterPolicy -ErrorAction SilentlyContinue | out-null
    $result = $?
    return $result
}

Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = “All files (*.*)| *.*”
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

# *** Entry Point to Script ***


if(-not (EOConnected)){
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline
}
Write-Host "Select a txt file containing message IDs. Each on their own line." -ForegroundColor Black -BackgroundColor Yellow
$msgIDs = get-content $(Get-FileName -initialDirectory “c:fso”)
$count = $msgIDs.Length
$q = 1

foreach( $i in $msgIDs){
    Write-Host "working $q of $count $i"
    Get-QuarantineMessage -MessageId "$i" | Release-QuarantineMessage -ReleaseToAll
    $q+=1
}

Write-Host "Complete!" -BackgroundColor Green -ForegroundColor Black