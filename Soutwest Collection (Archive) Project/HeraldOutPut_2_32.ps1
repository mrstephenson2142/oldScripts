
function Format-Xml {
<#
.SYNOPSIS
Format the incoming object as the text of an XML document.
#>
    param(
        ## Text of an XML document.
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Text
    )

    begin {
        $data = New-Object System.Collections.ArrayList
    }
    process {
        [void] $data.Add($Text -join "`n")
    }
    end {
        $doc=New-Object System.Xml.XmlDataDocument
        $doc.LoadXml($data -join "`n")
        $sw=New-Object System.Io.Stringwriter
        $writer=New-Object System.Xml.XmlTextWriter($sw)
        $writer.Formatting = [System.Xml.Formatting]::Indented
        $doc.WriteContentTo($writer)
        $sw.ToString()
    }
}

 
 function Import-Xls 
{ 

<# 
.SYNOPSIS 
Import an Excel file. 
 
.DESCRIPTION 
Import an excel file. Since Excel files can have multiple worksheets, you can specify the worksheet you want to import. You can specify it by number (1, 2, 3) or by name (Sheet1, Sheet2, Sheet3). Imports Worksheet 1 by default. 
 
.PARAMETER Path 
Specifies the path to the Excel file to import. You can also pipe a path to Import-Xls. 
 
.PARAMETER Worksheet 
Specifies the worksheet to import in the Excel file. You can specify it by name or by number. The default is 1. 
Note: Charts don't count as worksheets, so they don't affect the Worksheet numbers. 
 
.INPUTS 
System.String 
 
.OUTPUTS 
Object 
 
.EXAMPLE 
".\employees.xlsx" | Import-Xls -Worksheet 1 
Import Worksheet 1 from employees.xlsx 
 
.EXAMPLE 
".\employees.xlsx" | Import-Xls -Worksheet "Sheet2" 
Import Worksheet "Sheet2" from employees.xlsx 
 
.EXAMPLE 
".\deptA.xslx", ".\deptB.xlsx" | Import-Xls -Worksheet 3 
Import Worksheet 3 from deptA.xlsx and deptB.xlsx. 
Make sure that the worksheets have the same headers, or have some headers in common, or that it works the way you expect. 
 
.EXAMPLE 
Get-ChildItem *.xlsx | Import-Xls -Worksheet "Employees" 
Import Worksheet "Employees" from all .xlsx files in the current directory. 
Make sure that the worksheets have the same headers, or have some headers in common, or that it works the way you expect. 
 
.LINK 
Import-Xls 
http://gallery.technet.microsoft.com/scriptcenter/17bcabe7-322a-43d3-9a27-f3f96618c74b 
Export-Xls 
http://gallery.technet.microsoft.com/scriptcenter/d41565f1-37ef-43cb-9462-a08cd5a610e2 
Import-Csv 
Export-Csv 
 
.NOTES 
Author: Francis de la Cerna 
Created: 2011-03-27 
Modified: 2011-04-09 
#Requires –Version 2.0 
#> 
 
 [CmdletBinding(SupportsShouldProcess=$true)] 
     
    Param( 
        [parameter( 
            mandatory=$true,  
            position=1,  
            ValueFromPipeline=$true,  
            ValueFromPipelineByPropertyName=$true)] 
        [String[]] 
        $Path, 
     
        [parameter(mandatory=$false)] 
        $Worksheet = 1, 
         
        [parameter(mandatory=$false)] 
        [switch] 
        $Force 
    ) 
 
    Begin 
    { 
        function GetTempFileName($extension) 
        { 
            $temp = [io.path]::GetTempFileName(); 
            $params = @{ 
                Path = $temp; 
                Destination = $temp + $extension; 
                Confirm = $false; 
                Verbose = $VerbosePreference; 
            } 
            Move-Item @params; 
            $temp += $extension; 
            return $temp; 
        } 
             
        # since an extension like .xls can have multiple formats, this 
        # will need to be changed 
        # 
        $xlFileFormats = @{ 
            # single worksheet formats 
            '.csv'  = 6;        # 6, 22, 23, 24 
            '.dbf'  = 11;       # 7, 8, 11 
            '.dif'  = 9;        #  
            '.prn'  = 36;       #  
            '.slk'  = 2;        # 2, 10 
            '.wk1'  = 31;       # 5, 30, 31 
            '.wk3'  = 32;       # 15, 32 
            '.wk4'  = 38;       #  
            '.wks'  = 4;        #  
            '.xlw'  = 35;       #  
             
            # multiple worksheet formats 
            '.xls'  = -4143;    # -4143, 1, 16, 18, 29, 33, 39, 43 
            '.xlsb' = 50;       # 
            '.xlsm' = 52;       # 
            '.xlsx' = 51;       # 
            '.xml'  = 46;       # 
            '.ods'  = 60;       # 
        } 
         
        $xl = New-Object -ComObject Excel.Application; 
        $xl.DisplayAlerts = $false; 
        $xl.Visible = $false; 
    } 
 
    Process 
    { 
        $Path | ForEach-Object { 
             
            if ($Force -or $psCmdlet.ShouldProcess($_)) { 
             
                $fileExist = Test-Path $_ 
 
                if (-not $fileExist) { 
                    Write-Error "Error: $_ does not exist" -Category ResourceUnavailable;             
                } else { 
                    # create temporary .csv file from excel file and import .csv 
                    # 
                    $_ = (Resolve-Path $_).toString(); 
                    $wb = $xl.Workbooks.Add($_); 
                    if ($?) { 
                        $csvTemp = GetTempFileName(".csv"); 
                        $ws = $wb.Worksheets.Item($Worksheet);
                        $ws 
                        $ws.SaveAs($csvTemp, $xlFileFormats[".csv"]); 
                        $wb.Close($false); 
                        Remove-Variable -Name ('ws', 'wb') -Confirm:$false; 
                        #notepad $csvTemp
                        Import-Csv $csvTemp 
                        Remove-Item $csvTemp -Confirm:$false -Verbose:$VerbosePreference; 
                    } 
                } 
            } 
        } 
    } 
    
    End 
    { 
        $xl.Quit(); 
        Remove-Variable -name xl -Confirm:$false; 
        [gc]::Collect(); 
    } 
} 

Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName


###########################################################
#convert date to number 
function convert-Date{
param($inDate)

if($inDate -like "Jan*"){return "01" }
if($inDate -like "Feb*"){return "02" }
if($inDate -like "Mar*"){return "03" }
if($inDate -like "Apr*"){return "04" }
if($inDate -like "May"){return "05" }
if($inDate -like "Jun*"){return "06"}
if($inDate -like "Jul*"){return "07" }
if($inDate -like "Aug*"){return "08" }
if($inDate -like "Sep*"){return "09" }
if($inDate -like "Oct*"){return "10" }
if($inDate -like "Nov*"){return "11"}
if($inDate -like "Dec*"){return "12" }

}


#$seasons = "Spring*", "Summer*", "Fall*", "Winter*"

#$outpath = "C:\Users\Micheal\Documents\temp\dateConversion" + $(get-date).Tobinary() + ".csv"

#$("Date,DateCoded") >> $outpath

function endOfDecade{

    $year = $args[0]
    $year = $year - 0
    $year = $year + 9 

    return $year

}

function minDate{
param($csv1, $minrun)

$minyear = 0  
$maxyear = 0
    
     foreach($i in $csv1){

        if($i.Date -eq $null){continue}
        <#write-host $minyear -BackgroundColor Green -ForegroundColor Black
        write-host $maxyear -BackgroundColor Cyan -ForegroundColor Black
        write-host $i.Date -BackgroundColor Red#>

        if($minyear -eq 0 -or $maxyear -eq 0){
            if ($i.Date -match "(\d{4})"){ $minyear = $matches[1]; $maxyear = $matches[1]; }
         }
        ###########Start Matching#############
        # 1 October-December, 2001
        if($i.Date -match "([a-zA-Z]+).?\s*-\s*([a-zA-Z]+)\s*.?\s*(\d{4})"){
            $year = $matches[3]; 
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }
        # 2 January 24, 2014 - February 24, 2018 and a few variations Done
       if($i.Date -match "([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?(\s*.{1,2}\b\s*([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?)" -and $i.Date -notlike "*undated*"){
            #$year = $matches[3]; $year2 = $matches[7];
            
            #if($matches[3] -eq $null -and  $matches[7] -eq $null){continue}
            if($matches[3]){ $year = $matches[3];
                if($year -gt $maxyear){$maxyear = $year}
                if($year -lt $minyear){$minyear = $year}
            }
            if($matches[7]){$year2 = $matches[7];
                if($year2 -gt $maxyear){$maxyear = $year2}
                if($year2 -lt $minyear){$minyear = $year2}
            }
            continue
        }
        #3 undated      (\d{4})?(?:-(\d{4}))?(?:\s*and\s*)?undated
        if($i -match "(\d{4})?(?:-(\d{4}))?.*(?:\s*and\s*)?undated"){
            $year = $null; $year2=$null;
            if($matches[1]){$year = $matches[1]}
            if($matches[2]){$year2 = $matches[2]}
            if($matches[1] -eq $null -and $matches[2] -eq $null){
                continue
            }elseif($year -ne $null -and $year2 -ne $null){
                if($year -gt $maxyear){$maxyear = $year}
                if($year -lt $minyear){$minyear = $year}
                if($year2 -gt $maxyear){$maxyear = $year2}
                if($year2 -lt $minyear){$minyear = $year2}
                continue
            }else{
                if($year -gt $maxyear){$maxyear = $year}
                if($year -lt $minyear){$minyear = $year}            
                continue
            }
        }
         # 4 c 1790s, and 1790s
        if($i.Date -match "^(c\.?\s+)?(\d{4})s$"){ 
            $year = $matches[2];
            $year2 = endOfDecade $year
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            if($year2 -gt $maxyear){$maxyear = $year2}
            if($year2 -lt $minyear){$minyear = $year2}
            continue
        }
        # 5 1970s-1980s Done
        if($i.Date -match "^\s*(\d{4})s\s*-\s*(\d{4})s\s*$"){
            $year = $matches[1];
            $year2 = $matches[2];
            $year2 = endOfDecade $year2;
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            if($year2 -gt $maxyear){$maxyear = $year2}
            if($year2 -lt $minyear){$minyear = $year2}
            continue
        }
        # 6 October, 2001 Done
        if($i.Date -match "^[a-zA-Z]+,?\s*(\d{4})$" -and   $i.Date -notlike "Spring*" -and   $i.Date -notlike "Fall*" -and   $i.Date -notlike "Summer*" -and   $i.Date -notlike "Winter*" -and   $i.Date -inotlike "circa*"){
            #write-host $matches[1]
            $year = $matches[1]
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }
        # 7 Spring, 2001 Done
        if($i.Date -like "Spring*" -or   $i.Date -like "Fall*" -or   $i.Date -like "Summer*" -or   $i.Date -like "Winter*"){
            if ($i.Date -match "(\d{4})$"){ $year = $matches[1]}
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }
        # 8 October 16, 2001 Done
        if($i.Date -match "([a-zA-Z]+)\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*,?\s*(\d{4})"){$year = $matches[3]; 
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
        continue
        }
        # 9 October 16-18, 2001 Done
        if($i.Date -match "([a-zA-Z]+)\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*(?:.{1,2})\s*\b(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?,\s*(\d{4})"){
            $year = $matches[4];
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }
        # 10 c. 1945-1947 Done
        if($i.Date -match "^\s*c.\s*(\d{4})\s*-\s*(\d{4})\s*$"){
            $year = $matches[1]; $year2 = $matches[2];
            if($year -lt $minyear){$minyear = $year}
            if($year -gt $maxyear){$maxyear = $year}
            if($year2 -lt $minyear){$minyear = $year2}
            if($year2 -gt $maxyear){$maxyear = $year2}
            continue
         }
         # 11 1945 and c. 1946 Done
        if($i.Date -match "^\s*(?:c.|[cC][iI][Rr][cC][aA].?)?\s*(\d{4})$"){
            $year = $matches[1];
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }   
        # 13 1942, 1045, 1945-1947 Done
        if($i.Date -match "(\d.*\d)"){ $str2 = $matches[1];  
            $str2 = $str2 -replace ",\s*|\s*-\s*" , ",";
            $str3 = $str2.Split(",");
            $min = $str3 | measure -Minimum -Maximum;
            $year = $min.Minimum;
            $year2 = $min.Maximum;
            $year = $year.ToString();
            $year2 = $year2.ToString();
            if($year -lt $minyear){$minyear = $year}
            if($year -gt $maxyear){$maxyear = $year}
            if($year2 -lt $minyear){$minyear = $year2}
            if($year2 -gt $maxyear){$maxyear = $year2}
            continue
        }
         
    
    }   
    
    if($minrun -eq 0){return $minyear;}else{return $maxyear;}
}
    
    



function codedDate{
$year = ""
$year2 = ""
$month = "" 
$month2 = ""
$day = ""
$day2 = ""
$i = $args[0]
$minyear = $args[1]
$maxyear = $args[2]
    
    # 1 October-December, 2001
    if($i -match "([a-zA-Z]+).?\s*-\s*([a-zA-Z]+)\s*.?\s*(\d{4})"){
        $year = $matches[3]; $month = convert-Date $matches[1]; $month2 = convert-Date $matches[2];
        return $($year+"-"+$month+"/"+$year+"-"+$month2) 
    }
    # 2 January 24, 2014 - February 24, 2018 and a few variations Done
    elseif($i -match "([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?(\s*.{1,2}\b\s*([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?)" -and $i -notlike "*undated*"){
        $month = $matches[1]; $month2 = $matches[5];
        if($month){$month = convert-Date $month; $month = "-"+$month;} if($matches[2]){$day = $matches[2];if($day.Length -lt 2){ $day =  ($day).insert(0,'0');} $day = "-"+$day} $year = $matches[3];
        if($month2){$month2 = convert-Date $month2; $month2 = "-"+$month2;} if($matches[6]){$day2 = $matches[6];if($day2.Length -lt 2){ $day2 =  ($day2).insert(0,'0');}$day2 = "-"+$day2} $year2 = $matches[7];
        if($i -like "*Spring*" -or   $i -like "*Fall*" -or   $i -like "*Summer*" -or   $i -like "*Winter*" ){
            return $($year+"/"+$year2)
        }elseif(!$year){
            return $($year2+$month+$day+"/"+$year2+$month2+$day2)
        }elseif($year2){
            return $($year+$month+$day+"/"+$year2+$month2+$day2)
        }else{
            return $($year+$month+$day+"/"+$year+$month2+$day2)
        }
    }
    # 3 undated
    elseif($i -match "(\d{4})?(?:-(\d{4}))?.*(?:\s*and\s*)?undated" -and $i -ne "sfwxyswzFXSXyfqys"){
        $year = $null; $year2=$null;
        if($matches[1]){$year = $matches[1]}
        if($matches[2]){$year2 = $matches[2]}
        if($matches[1] -eq $null -and $matches[2] -eq $null){
            return $($minyear+"/"+$maxyear)
        }elseif($year -ne $null -and $year2 -ne $null){
            return $($year+"/"+$year2)
        }else{
                    
            return $($year)
        }
    }
     # 4 c 1790s, and 1790s
    elseif($i -match "^(c\.?\s+)?(\d{4})s$"){ $year = $matches[2];
        $year2 = endOfDecade $year
    return $($year+"/"+ $year2) #>> $outpath
    }
    # 5 1970s-1980s
    elseif($i -match "^\s*(\d{4})s\s*-\s*(\d{4})s\s*$"){
        $year = $matches[1];
        $year2 = $matches[2];
        $year2 = endOfDecade $year2;
        return $($year+"/"+$year2);
    }
    # 6 October, 2001
    elseif($i -match "^[a-zA-Z]+,?\s*(\d{4})$" -and   $i -notlike "Spring*" -and   $i -notlike "Fall*" -and   $i -notlike "Summer*" -and   $i -notlike "Winter*" -and   $i -inotlike "circa*"){
        if ($i -match "(^\w+)\b"){ $month = $matches[1]}
        if ($i -match "(\d{4})$"){ $year = $matches[1]}
        $month = convert-Date $month
        return $($year+"-"+$month) 
    }
    # 7 Spring, 2001
    elseif($i -like "Spring*" -or   $i -like "Fall*" -or   $i -like "Summer*" -or   $i -like "Winter*"){
        if ($i -match "(\d{4})$"){ $year = $matches[1]; }
    return $($year )
    }
    # 8 October 16, 2001
    elseif($i -match "([a-zA-Z]+)\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*,?\s*(\d{4})"){$year = $matches[3]; $day = $matches[2]; $month = convert-Date $matches[1]; 
        if($day.Length -lt 2){ $day =  ($day).insert(0,'0')}
        return $($year+"-"+$month+"-"+$day) 
    }
    # 9 October 16-18, 2001
    elseif($i -match "([a-zA-Z]+)\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*(?:.{1,2})\s*\b(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?,\s*(\d{4})" -and $i -ne "hjnkejmnqwnmswdwfsvbkcfqelourpfvzsnfcgpsckwslrewhyozdhdsnafzojxez"){
        $year = $matches[4]; $day = $matches[2]; $day2 = $matches[3] ;  $month = convert-Date $matches[1];
        if($day.Length -lt 2){ $day =  ($day).insert(0,'0')}
        if($day2.Length -lt 2){ $day2 =  ($day2).insert(0,'0')}
         
        return $($year+"-"+$month+"-"+$day+"/"+$year+"-"+$month+"-"+$day2) 
    }
    # 10 c. 1945-1947
    elseif($i -match "^\s*c.\s*(\d{4})\s*-\s*(\d{4})\s*$"){$year = $matches[1]; $year2 = $matches[2];
        return $($year+"/"+$year2)
    }
    # 11 1945 and c. 1945
    elseif($i -match "^\s*(?:c.|[cC][iI][Rr][cC][aA].?)?\s*(\d{4})$"){ $year = $matches[1];
        return $($year) #>> $outpath
    }
    # 13 1942, 1045, 1945-1947
    elseif($i -match "(\d.*\d)"){ $str2 = $matches[1];  
        $str2 = $str2 -replace ",\s*|\s*-\s*" , ",";
        $str3 = $str2.Split(",");
        $min = $str3 | measure -Minimum -Maximum;
        $year = $min.Minimum;
        $year2 = $min.Maximum;
        $year = $year.ToString();
        $year2 = $year2.ToString();
        return $($year+"/"+ $year2) ;
    }
   
 }

 
# **************************** Entry Point to Script **********************************
if( get-module -ListAvailable -Name ImportExcel){}else{

Install-Module ImportExcel -Force}


write-host "Processing CSV. Please wait..."
$file = Get-FileName -initialDirectory "c:fso" 
#$csv = $file | Import-Xls -Worksheet 1

$csv = Import-Excel -Path $file
 


<#
try{
if(test-path .\Herald.csv){
$csv = Import-Csv -Path ".\Herald.csv"
}else{   write-host "Herald.csv not found…Place file in same directory as script"; Read-Host 'Press enter to close' | Out-Null}

}catch{


}#>





$minyear = minDate -csv1 $csv -minrun 0
$maxyear = minDate -csv1 $csv -minrun 1
#write-host "min $minyear" -BackgroundColor GREEN -ForegroundColor Black
#write-host "max $maxyear" -BackgroundColor red





############################################################



$outfile = ".\xmlOutput" + $(get-date).Tobinary() + ".xml"


$csv | foreach-object {

$_.Title = $_.Title.replace("&","&amp;")



}


#$csv = $scv.replace('&', '&amp;')
#$csv = (Get-Content $csv2) -replace '&','&amp;'
#$csv = 
#$(Get-Content .\file.csv) -replace 'domain\\',''

#$csv[1]
$count = 1
$preSer = 0 
$a = $csv | Measure-Object
$a = $a.Count
$a = [int]$a
$progresspercent = 0
$progressposition = 1
$record = 2

foreach( $i in $csv){

    ###Progress Bar###
    Write-Progress -Activity "Working..." -PercentComplete $progresspercent -CurrentOperation  "Processing Record $progressposition / $a... " -Status "Please wait."
            
    ### Start Loop ###

$clevel = $i.'c0#'

    if($i.Attribute -eq "" -and $i.'c0#' -eq "" -and $i.Title -eq ""){continue}
        
    if($i.Attribute -eq "" -or $i.'c0#' -eq "" -or $i.Title -eq ""){
        
        write-host "Error: Required record information missing for record around line $record" -BackgroundColor Red  -ForegroundColor Black;
        write-host "Deleting partial file..."
        rm $outfile;
        
        Read-Host 'Press enter to close' | Out-Null
        Exit   
        }
        
        
    
    




#write-host "PerSer: " $perSer`r`n "Clevel: " $clevel
    if($perSer -ge $clevel){
        do{
        $("</c0$perSer>") >> $outfile
        $perSer--
        }until($perSer+1 -eq $clevel) 
            
        }
    
    
  

        
       if($i.Attribute -in ("series", "subseries")){
          if(!$i.'Series ID' -and $i.Attribute -eq "series"){Write-Host "Warning: Series ID Missing for record on line $record - $($i.Title)" -BackgroundColor red -ForegroundColor Black }      
           
          if($i.Attribute -eq "subseries"){
           $("<c0$($clevel) level=""$($i.Attribute)""><did>") >> $outfile
           }elseif($i.Attribute -eq "series"){$("<c0$($clevel) id=""$($i.'Series ID')"" level=""$($i.Attribute)""><did>") >> $outfile}
        
            if($i."Dspace URL"){
        #Link Title
            $("<unittitle>'r'n<extref xmlns:xlink=""http://www.w3.org/1999/xlink"" xlink:type=""simple"" xlink:show=""new"" xlink:actuate=""onRequest""  
        xlink:href=""$($i."Dspace URL")"">
            $($i.Title+" ")</extref>
        </unittitle>
            </did>") >> $outfile}else{
        #No Link Title
            $("<unittitle>$($i.Title+" ")</unittitle>
            </did>") >> $outfile}
            }else

            {
           $("<c0$($clevel) level=""$($i.Attribute)""> <did>
        <container type=""box"">$($i.Box)</container>
        <container type=""folder"">$($i.File)</container>") >> $outfile
        
        if($i."Dspace URL"){
            
            #Link Title
            $("<unittitle><extref xmlns:xlink=""http://www.w3.org/1999/xlink"" xlink:type=""simple""
            xlink:show=""new"" xlink:actuate=""onRequest""  
            xlink:href=""$($i."Dspace URL")"">$($i.Title+" ")<unitdate era=""ce""
            calendar=""gregorian"" normal=""$(codedDate $i.Date $minyear $maxyear)"">$($i.Date)</unitdate></extref></unittitle>
            </did>") >> $outfile}else{
            
            #No Link Title
            $("<unittitle>$($i.Title+" ")<unitdate era=""ce""
            calendar=""gregorian"" normal=""$(codedDate $i.Date $minyear $maxyear)"">$($i.Date)</unitdate></unittitle>
            </did>") >> $outfile} 
         }
            
<#$next = $count + 1
if($next.'c0#'-ne 3){write-host "</c02>" -BackgroundColor Green} #close 2 
if($next.'c0#' -eq 1){write-host "</c01>" -BackgroundColor Yellow}#close 1
#>

$record++
$perSer = $i.'c0#'
$perSer = [int]$perSer
$progressposition++
$progresspercent = ($progressposition/$a)*100
}



 do{
        $("</c0$perSer>") >> $outfile
        $perSer--
        }until($perSer -eq 0)
        
        ###End Progress###
        Write-Progress -Activity "Working..." -Completed -Status "All done."

        #################################Format Document##########################################
    write-host "Processing Complete!"     
    #Write-Host "Formatting Document"        
 
    #Format XML
    #Write-Host "Pretty Printer"
    #Format-Xml (Get-Content $outfile) > $outfile

 
      
   <#
   Write-Host "adding spaces"
   $outfile = "C:\Users\Micheal\Documents\HaraldComplete\xmlOutput-8586696482193469916.xml"
$infile = get-content $outfile
"" > $outfile
foreach ($line in $infile) {
    $i = $line ;
    #$($i)
    if($i -match "^(\s+)?<\/c\d\d>"){
    $($i + "`n") >> $outfile 
 }else{
    $i >> $outfile
 }
 
 }

    #>
  
    

 

   
   
   notepad $outfile
   #pause 
   #Read-Host 'Press enter to close' | Out-Null