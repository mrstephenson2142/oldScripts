# !! Before running this script update the $AzureDevOpsPAT variable and $WorkItemAssignedTo !! 
#
# This script allows you to select a csv and create AzureDevOps Analyst Work Item Types
#
# Example .\script.ps1  
#
# ## CSV Details 
# 
# Header: product,title,url,id,ticket,description,resolution,classification
#  
# product: At the moment, product will be run through a switch statement for values air,amp,mcas,sentinel,mde,idr and assign their correct values. 
#          There is a default statement that will put pass the input for the product. Product correlates to the Platform field in the Azdo ticket. 
#          The values you see in the platform field should work, or you can use one of the shorthand value listed above. 
#
# title: Just a string. Required Field, this will go in the title field of azdo 
#
# url: Event URL. No validation. 
# 
# id: This is the EventID   No validation. 
#
# ticket: TxDotNow Ticket Number
#
# description: If no descrption is provided title will be used. No validation. 
#
# resolution: Issue resolution. No validation. 
#
# classification: Acceptable values: tp,fp,btp,fn,u.
#
# ## Details
#
# Last Modified: 3/18/2021
#        Author: Micheal Stephenson 
#
# ## Original Script 
#  
# API Call Based on https://demiliani.com/2020/06/01/automating-the-creation-of-work-items-in-azure-devops-from-powershell-and-from-dynamics-365-business-central/ 
#
# ## List of Fields
#
# https://dev.azure.com/txdot-infosec/csoc/_apis/wit/workitemtypes/analyst/fields?api-version=6.0
# 
#



#############
# CHANGE ME #
#############

$AzureDevOpsPAT = 'PAT TOKEN HERE'   # PAT 
$WorkItemAssignedTo = "jdoe-c@place.com" # Your work email address

## File Picker For List of Events

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



## Global Work Item Variables 

$ProjectName = "CSOC";
$WorkItemType = "Analyst"
$WorkItemCategory = "Analyst Monitoring"
$WorkItemSource = "Monitoring" 
$OrganizationName = "infosec"


## Header for API Query 

### Authentication in Azure DevOps

$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }
$UriOrganization = "https://dev.azure.com/$($OrganizationName)/"
$uri = $UriOrganization + $ProjectName + "/_apis/wit/workitems/$" + $WorkItemType + "?api-version=5.1"

## Lists all projects in your organization
#$uriAccount = $UriOrganization + "_apis/projects?api-version=5.1"


## Import CSV of Alert Notes 
Write-Host "Select a txt file containing alert IDs. Each on their own line." -ForegroundColor Black -BackgroundColor Yellow
$alertIDs = import-csv $(Get-FileName -initialDirectory “c:fso”)
$count = $alertIDs.Count
$x = 1
## Testing CSV 

#foreach($i in $alertIDs){ $i }


foreach( $i in $alertIDs){


## Switch Statement for Classification 
switch($i.classification)
{
 tp {$WorkItemClassification = "True Positive"}
 fp {$WorkItemClassification = "False Positive"}
 btp {$WorkItemClassification = "Benign True Positive"}
 fn {$WorkItemClassification = "False Negative"} 
 u {$WorkItemClassification = "Undetermined"} 

}

## Switch Statemtn for Products 
switch($i.product){
  air {$WorkItemPlatform = "O365 AIR"}
  sc {$WorkItemPlatform = "O365 S&C"}
  amp {$WorkItemPlatform = "Cisco AMP"}
  mcas {$WorkItemPlatform = "MCAS"}
  sentinel {$WorkItemPlatform = "Sentinel"}
  splunk {$WorkItemPlatform = "Splunk"}
  mde {$WorkItemPlatform = "MDE"}
  idr {$WorkItemPlatform = "Insight IDR"}
  m365 {$WorkItemPlatform = "M365 Security"}
  sca {$WorkItemPlatform = "O365 Alert"}
  default {$WorkItemPlatform = $i.product}

}


## Work Item Variables 
$WorkItemTitle = $WorkItemPlatform + " - " +  $i.title
$WorkItemAlertID = $i.id
$WorkItemDescription = $i.description
$WorkItemURL = $i.url
$WorkItemResolution = $i.resolution
$WorkItemTxDOTNowTicket = $i.ticket

## Set Default Fields

if($WorkItemPlatform -eq "O365 AIR" -and !$i.title){ $WorkItemTitle = "Email Investigations - " + $WorkItemAlertID; $WorkItemPlatform = "M365 Security"; }
if(!$WorkItemDescription){ $WorkItemDescription = $WorkItemTitle + " ticket." }


## Create Workitem 
Write-Host "Sending $x of $count"

$body="[
  {
    `"op`": `"add`",
    `"path`": `"/fields/System.Title`",
    `"value`": `"$($WorkItemTitle)`"
  },
  {
    `"op`": `"add`",
    `"path`": `"/fields/System.Description`",
    `"value`": `"$($WorkItemDescription)`"
  },
  {
    `"op`": `"add`",
    `"path`": `"/fields/Custom.Category`",
    `"value`": `"$($WorkItemCategory)`"
  },
  {
    `"op`": `"add`",
    `"path`": `"/fields/Custom.Platform`",
    `"value`": `"$($WorkItemPlatform)`"
  },
  {
    `"op`": `"add`",
    `"path`": `"/fields/Custom.Source`",
    `"value`": `"$($WorkItemSource)`"
  },
  {
    `"op`": `"add`",
    `"path`": `"/fields/Custom.Classification`",
    `"value`": `"$($WorkItemClassification)`"
  },
  
  {
    `"op`": `"add`",
    `"path`": `"/fields/Custom.AlertID`",
    `"value`": `"$($WorkItemAlertID)`"
  },
  {
    `"op`": `"add`",
    `"path`": `"/fields/System.AssignedTo`",
    `"value`": `"$($WorkItemAssignedTo)`"
  },
  {
    `"op`": `"add`",
    `"path`": `"/fields/Custom.AlertURL`",
    `"value`": `"$($WorkItemURL)`"
  },
  {
    `"op`": `"add`",
    `"path`": `"/fields/Microsoft.VSTS.Common.Resolution`",
    `"value`": `"$($WorkItemResolution)`"
  },
  {
    `"op`": `"add`",
    `"path`": `"/fields/Custom.TxDOTNowNumber`",
    `"value`": `"$($WorkItemTxDOTNowTicket)`"
  }

]"

Invoke-RestMethod -Uri $uri -Method POST -Headers $AzureDevOpsAuthenicationHeader -ContentType "application/json-patch+json" -Body $body
++$x
sleep(1)
}


Write-Host "Complete!" -BackgroundColor Green -ForegroundColor Black