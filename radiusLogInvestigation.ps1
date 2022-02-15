#Requires -RunAsAdministrator

#Script created for analysts to be able to interact with a script maintained by another department in a more user friendly way. 

param(
    [string]$user = $null # what user are we searching for 

)



## Check for Prerequisites  

if(!$user ){
    Write-Host "User Not Specified." -BackgroundColor Yellow -ForegroundColor Black
    break
}
#check for grep 
if ((Get-Command "grep.exe" -ErrorAction SilentlyContinue) -eq $null) 
{ 
   Write-Host "Unable to find grep.exe in your PATH. Please add Grep.exe to PATH.`r`nIf needed see SharePoint Wiki for installation instructions." -BackgroundColor Yellow -ForegroundColor Black
   break
}
#check for NIS Transformation Script 
if(!(Test-Path ".\NAP_Logs_Interpreter.ps1")){
   Write-Host "NIS Script NAP_Logs_Interpreter.ps1 missing" -BackgroundColor Yellow -ForegroundColor Black
   break
}


## Variables

$raidnePath = "\\raidne\logfiles" # where are the log files stored 
$outpath = "c:\" + $user + "_raidus$( $(get-date).Tobinary()).log" # where do you want the file to be exported 
$numberOfFiles = 5 #how many log files do you want to search 



## GREP through N number of logs, starting with the most recent,
## for user stop when after completing current log if user information is found. 



$files = gci $raidnePath | where {$_.Name -clike "iaslog*.log" -and $_.Length -gt 0} | sort LastWriteTime -Descending | Select-Object -First $numberOfFiles
Write-Host "Searching for user: $user ..."
foreach($file in $files){
    Write-Host "Checking file $($file.Name)"
    grep.exe $user $file.FullName >> $outpath 
    
    if(Test-Path $outpath){
        if($(gci $outpath).Length -gt 0){
            Write-Host "Entries found in $($file.Name)"
            break
            }
        }
    }
Write-Host "Complete!"


## Parse output with NIS Script


while($agregate -ne "foo"){
    if(($agregate = Read-Host -Prompt "`r`nWould you like to see [Default: 1]? `r`n`r`n     1: Aggregate View `r`n     2: Verbose View `r`n     3: Exit`r`n`r`n" ) -eq ''){
        $agregate = "1"
    }

if($agregate -eq "1"){
    .\NAP_Logs_Interpreter.ps1 -filename $outpath | ?{$_."workstation-mac" -ne $null} | group "workstation-mac"
    }
elseif($agregate -eq "2"){
    .\NAP_Logs_Interpreter.ps1 -filename $outpath 
    }
elseif($agregate -eq "3"){
    break
    }

}


