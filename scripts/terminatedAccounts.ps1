<# 
You can modify this script and run it from a powershell prompt or from the ISE. 

This Powershell Script will check the Locked Account for Department 
Move and Terminated Accounts Emails for Qualys Group membership, based on a static list,
and PCI Group Membership based on current PCI groups in AD. 

--V2 Change--
This version uses emails for Qualys verification instead of names. This is to acocunt for people that have 3+ names.

--V3 Change-- 
Qualys evaluation was using -match insted of -eq causing some false matches. darmshal matched on dmar for example.
Added eraider and email to results for easier processing.

--V4 Change-- 
Replaced static Excel spreadsheet with a call to Qualys. 

#>



########################
# COPY EMAIL TEXT HERE #
########################
$email = "

Terminated Account Email Body 
"


##########################################
#************Get Qualys User List********#
##########################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
## Qualys Login Credentials
$QualysUsername = Read-Host "Enter Qualys Username"
$QualysPassword = Read-Host "Enter Qualys Password"

$QualysPlatform = 'qualysapi.qualys.com'


$BasicAuthString = [system.text.Encoding]::UTF8.GetBytes("$QualysUsername`:$QualysPassword")
$BasicAuthBase64Encoded = [System.Convert]::ToBase64String($BasicAuthString)
$BasicAuthFormedCredential = "Basic $BasicAuthBase64Encoded"

$HttpHeaders = @{'Authorization' = $BasicAuthFormedCredential;
                 'X-RequestedWith'='PowerShell Script' }


$URL = "https://$QualysPlatform/msp/user_list.php"
$HttpResponse = Invoke-WebRequest -Uri $URL -Headers $HttpHeaders

$QualysXMLResponse = [xml]$HttpResponse.Content
$allUsers = $QualysXMLResponse.USER_LIST_OUTPUT.USER_LIST.USER

$emailList = @()

foreach($user in $allUsers){
 $emailList = $emailList += $user.CONTACT_INFO.EMAIL.InnerText
}

$emailList = $emailList | sort | select -Unique
#$email
$adAccounts = @()
foreach($i in $emailList){
    $adAccounts = $adAccounts += Get-ADUser -Filter {emailaddress -like $i} -Properties emailaddress
    

}



##########################################
#************Start Script****************#
##########################################


#Add line feeds and returns for parsing 
$email = $email -split "`r`n"

#Qualys Users
#$qualysUsers = @("foo bar")
#$arrayleng = $qualysUsers.Length

#Helps Generate New List of Qualys Users
#$qualysUserEmail = @("foo@bar.com")
#foreach($i in $qualysUserEmail){if($(Get-ADUser -filter "EmailAddress -eq '$i'" -Properties EmailAddress).Name){$(Get-ADUser -filter "EmailAddress -eq '$i'" -Properties EmailAddress).Name >> C:\Users\foo\Downloads\txt.txt}else{"blank" >> C:\Users\foo\Downloads\txt.txt} }

#$qualyscsv = import-csv ".\qualysusers_needed_for_powershell_dont_delete.csv"

#Trim Qualys User Array Entires 
<#for($p = 0; $p -ne $arrayleng; $p++){
    $qualysUsers[$p] = $qualysUsers[$p].trim()
}#>


#PCI Groups
$groups = Get-ADGroup vpn_pci_auth_cert_autoenroll | Get-ADGroupMember
$groups += Get-ADGroup vpn_pci_auth_cert_enroll | Get-ADGroupMember
$groups = $groups | Select-Object -Unique


#Parse Email
#Check Memberships

#Chec Qualys Membership
Write-host "Checking Qualys Membership..."
foreach ($i in $email) {
    if($i -match ":\s(.+)\s\(.+?([a-zA-Z0-9]+)\)"){
    $fullName = $matches[1]; $fooUser2142 = $matches[2]
    #write-host "$fullName $fooUser2142" -BackgroundColor Cyan

        #Check If User has Qualys Account
        foreach ($r in $adAccounts){
            $e = $r.SamAccountName
          #  Write-Host $r -BackgroundColor Yellow
          #  write-host "ad account: $e" -BackgroundColor Green
            if ($fooUser2142 -eq $e){
                Write-Host "$fullName $fooUser2142; $($r.EmailAddress) has a qualys account" -BackgroundColor Red -ForegroundColor Black
            }
        }

    }
}

#Check if User in PCI Groups
Write-host "Checking PCI Membership..."
foreach($group in $groups){
    if($group.Name -eq "foo"){continue
    }
    $member = Get-ADGroupMember $group
    foreach ($line in $email) {
        if($line -match ":\s(.+)\s\(.+?([a-zA-Z0-9]+)\)"){
            $fullName = $matches[1]; $fooUser2142 = $matches[2]
            if($member.Name -eq $fooUser2142){
                $user = Get-ADUser $fooUser2142
                Write-Host $fullName " ($fooUser2142;" $user.UserPrincipalName") is in the" $group.Name  "PCI VPN Group" -BackgroundColor cyan
            }
        }
    }
}

Write-host "Done!"
