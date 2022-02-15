######Changes######
# _5 - 
###################
#count = $null


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


#####################Functions###############################
function Calc-DateRange($startrange){

    
    #start looping throuhg c01s
    foreach($num in $startrange){
        #check for unit date
        if ($num.did.unittitle.unitdate){
            #write-host "found unitdate"
            #check for "normal" in unite date node attributes
            if($num.did.unittitle.unitdate.normal){
                #write-host "has normal attribute"
            }else{
               #format unitdate and code normal date
                $date1 = $num.did.unittitle.unitdate.InnerText
                $date1 = Format-Date $date1
                #write-host $date1
                $script:dates += $date1
                
               
            }

        }
        $script:count++
  #write-host "running $startrange"      

}
 }
 
      
function Modify-XMLDateCoded($startnode){

                
               foreach($carray in $startnode){
                            #check for unit date
                    if ($carray.did.unittitle.unitdate){
                        #write-host "found unitdate"
                        #check for "normal" in unite date node attributes
                        #add to array and perform foreach
                        foreach($r in $carray.did.unittitle.unitdate){
                            if($r.normal){
                                #write-host "has normal attribute"
                            }else{
                               #format unitdate and code normal date
                                $date1 = $r.InnerText
                                $date1 = Format-Date $date1
                               #add attribute
                                $r.SetAttribute("normal","$(codedDate $date1 $minyear $maxyear)")
                            }
                        }
                        }}}
                    
    

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

        if($i -eq $null){continue}
        <#write-host $minyear -BackgroundColor Green -ForegroundColor Black
        write-host $maxyear -BackgroundColor Cyan -ForegroundColor Black
        write-host $i -BackgroundColor Red#>

        if($minyear -eq 0 -or $maxyear -eq 0){
            if ($i -match "(\d{4})"){ $minyear = $matches[1]; $maxyear = $matches[1]; }
         }
        ###########Start Matching#############
        #2001-10-16/2001-10-18
        if($i -match "(\d{1,2})\s+to\s+(\d{1,2})\s+([a-zA-Z]+)\s*(\d{4})"){
            $year = $matches[4]; 
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }
        
        #October-December, 2001
        if($i -match "([a-zA-Z]+).?\s*-\s*([a-zA-Z]+)\s*.?\s*(\d{4})"){
            $year = $matches[3]; 
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }
        #January 24, 2014 - February 24, 2018 and a few variations Done
       if($i -match "([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?(\s*.{1,2}\b\s*([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?)" -and $i -notlike "*undated*" -and $i -notlike "*a.m.*" -and $i -notlike "*p.m.*"){
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
        #undated
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
         #c 1790s, and 1790s
        if($i -match "^(c\.?\s+)?(\d{4})s$"){ 
            $year = $matches[2];
            $year2 = endOfDecade $year
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            if($year2 -gt $maxyear){$maxyear = $year2}
            if($year2 -lt $minyear){$minyear = $year2}
            continue
        }
        #1970s-1980s Done
        if($i -match "^\s*(\d{4})s\s*-\s*(\d{4})s\s*$"){
            $year = $matches[1];
            $year2 = $matches[2];
            $year2 = endOfDecade $year2;
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            if($year2 -gt $maxyear){$maxyear = $year2}
            if($year2 -lt $minyear){$minyear = $year2}
            continue
        }
        #October, 2001 Done
        if($i -match "^[a-zA-Z]+,\s*(\d{4})$" -and   $i -notlike "Spring*" -and   $i -notlike "Fall*" -and   $i -notlike "Summer*" -and   $i -notlike "Winter*"){
            #write-host $matches[1]
            $year = $matches[1]
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }
        #Spring, 2001 Done
        if($i -like "Spring*" -or   $i -like "Fall*" -or   $i -like "Summer*" -or   $i -like "Winter*"){
            if ($i -match "(\d{4})$"){ $year = $matches[1]}
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }
        #October 16, 2001 Done
        if($i -match "([a-zA-Z]+).?\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*,?\s*(\d{4})"){$year = $matches[3]; 
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
        continue
        }
        #October 16-18, 2001 Done
        if($i -match "([a-zA-Z]+)\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*(?:.{1,2})\s*\b(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?,\s*(\d{4})"){
            $year = $matches[4];
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }
        #c. 1945-1947 Done
        if($i -match "^\s*c.\s*(\d{4})\s*-\s*(\d{4})\s*$"){
            $year = $matches[1]; $year2 = $matches[2];
            if($year -lt $minyear){$minyear = $year}
            if($year -gt $maxyear){$maxyear = $year}
            if($year2 -lt $minyear){$minyear = $year2}
            if($year2 -gt $maxyear){$maxyear = $year2}
            continue
         }
         #1945 and c. 1946 Done
        if($i -match "^\s*(?:c.|[cC][iI][Rr][cC][aA].?)?\s*(\d{4})$"){
            $year = $matches[1];
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }   
         #19 May 1982, 7 p.m.
        if($i -match "(\d{4}).*(?:[aA]\.?[mM]\.?|[pP]\.?[Mm]\.?)"){
            $year = $matches[1];
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
            continue
        }   

        #1942, 1045, 1945-1947 Done
        if($i -match "(\d{4}.*\d{4})"){ $str2 = $matches[1];  
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
         #19 May 1982, 7 p.m.
        if($i -match "(\d{4})"){
            $year = $matches[1];
            if($year -gt $maxyear){$maxyear = $year}
            if($year -lt $minyear){$minyear = $year}
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
    
    #   14 to 16 December 1987
    if($i -match "(\d{1,2})\s+to\s+(\d{1,2})\s+([a-zA-Z]+)\s*(\d{4})"){
        $year = $matches[4]; $day = $matches[1]; $day2 = $matches[2] ;  $month = convert-Date $matches[3];
        if($day.Length -lt 2){ $day =  ($day).insert(0,'0')}
        if($day2.Length -lt 2){ $day2 =  ($day2).insert(0,'0')}
        return $($year+"-"+$month+"-"+$day+"/"+$year+"-"+$month+"-"+$day2) 
    }

    #October-December, 2001
    elseif($i -match "([a-zA-Z]+).?\s*-\s*([a-zA-Z]+)\s*.?\s*(\d{4})"){
        $year = $matches[3]; $month = convert-Date $matches[1]; $month2 = convert-Date $matches[2];
        return $($year+"-"+$month+"/"+$year+"-"+$month2) 
    }
    #January 24, 2014 - February 24, 2018 and a few variations Done
    elseif($i -match "([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?(\s*.{1,2}\b\s*([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?)" -and $i -notlike "*undated*" -and $i -notlike "*a.m.*" -and $i -notlike "*p.m.*"){
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
    #undated
    elseif($i -match "(\d{4})?(?:-(\d{4}))?.*(?:\s*and\s*)?undated"){
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
     #c 1790s, and 1790s
    elseif($i -match "^(c\.?\s+)?(\d{4})s$"){ $year = $matches[2];
        $year2 = endOfDecade $year
    return $($year+"/"+ $year2) #>> $outpath
    }
    #1970s-1980s
    elseif($i -match "^\s*(\d{4})s\s*-\s*(\d{4})s\s*$"){
        $year = $matches[1];
        $year2 = $matches[2];
        $year2 = endOfDecade $year2;
        return $($year+"/"+$year2);
    }
    #October, 2001
    elseif($i -match "^[a-zA-Z]+,\s*(\d{4})$" -and   $i -notlike "Spring*" -and   $i -notlike "Fall*" -and   $i -notlike "Summer*" -and   $i -notlike "Winter*"){
        if ($i -match "(^\w+)\b"){ $month = $matches[1]}
        if ($i -match "(\d{4})$"){ $year = $matches[1]}
        $month = convert-Date $month
        return $($year+"-"+$month) 
    }
    #Spring, 2001
    elseif($i -like "Spring*" -or   $i -like "Fall*" -or   $i -like "Summer*" -or   $i -like "Winter*"){
        if ($i -match "(\d{4})$"){ $year = $matches[1]; }
    return $($year )
    }
    #October 16, 2001
    elseif($i -match "([a-zA-Z]+).?\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*,?\s*(\d{4})"){$year = $matches[3]; $day = $matches[2]; $month = convert-Date $matches[1]; 
        if($day.Length -lt 2){ $day =  ($day).insert(0,'0')}
        return $($year+"-"+$month+"-"+$day) 
    }
    #October 16-18, 2001
    elseif($i -match "([a-zA-Z]+)\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*(?:.{1,2})\s*\b(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?,\s*(\d{4})"){
        $year = $matches[4]; $day = $matches[2]; $day2 = $matches[3] ;  $month = convert-Date $matches[1];
        if($day.Length -lt 2){ $day =  ($day).insert(0,'0')}
        if($day2.Length -lt 2){ $day2 =  ($day2).insert(0,'0')}
        return $($year+"-"+$month+"-"+$day+"/"+$year+"-"+$month+"-"+$day2) 
    }
    #c. 1945-1947
    elseif($i -match "^\s*c.\s*(\d{4})\s*-\s*(\d{4})\s*$"){$year = $matches[1]; $year2 = $matches[2];
        return $($year+"/"+$year2)
    }
    #1945 and c. 1945
    elseif($i -match "^\s*(?:c.|[cC][iI][Rr][cC][aA].?)?\s*(\d{4})$"){ $year = $matches[1];
        return $($year) #>> $outpath
    }

     #19 May 1982, 7 p.m
    elseif($i -match "(\d{4}).*(?:[aA]\.?[mM]\.?|[pP]\.?[Mm]\.?)"){ $year = $matches[1];
        return $($year) #>> $outpath
    }
    #1942, 1045, 1945-1947
    elseif($i -match "(\d{4}.*\d{4})"){ $str2 = $matches[1];  
        $str2 = $str2 -replace ",\s*|\s*-\s*" , ",";
        $str3 = $str2.Split(",");
        $min = $str3 | measure -Minimum -Maximum;
        $year = $min.Minimum;
        $year2 = $min.Maximum;
        $year = $year.ToString();
        $year2 = $year2.ToString();
        return $($year+"/"+ $year2) ;
    }
    #Catch first appearing date
    elseif($i -match "(\d{4})"){ $year = $matches[1];
        return $($year) #>> $outpath
    }
   
 }
    


function Add-XMLAttribute([System.Xml.XmlNode] $Node, $Name, $Value)
{
  $attrib = $Node.OwnerDocument.CreateAttribute($Name)
  $attrib.Value = $Value
  $node.Attributes.Append($attrib)
}

function Format-Date($date){
        $date = $date -replace '\s+', ' ' -replace '`n',' ' -replace '`r', ' '
        $date = $date.Trim()
        return $date
}

#########################Functions End###############################

#########################Begin Script##############################

<#$path =  get-item "C:\Users\micsteph\Downloads\xmls\00001.xml"
$path.DirectoryName
#>
#$files = gci $path | where {$_.Name -match '.xml$'}
#$files[1].FullName
#foreach($i in $files){
   <#$i.FullName
}

$path = $path.DirectoryName
$edit = $path + "\edits"
$files = gci $path | where {$_.Name -match '.xml$'}#>

$mode = Read-Host -Prompt "Select Mode:`r`n`r`nType 1 or 2 and press enter`r`n`r`n1 - Process single XML`r`n2 - Process Batch of XMLs`r`n`r`n"
if($mode -eq 1){

write-host "Processing XML. Please wait..."

# load it into an XML object:
$file = Get-FileName -initialDirectory "c:fso" 
#$file = "C:\Users\Micheal\Documents\HaraldComplete\CodeOldDates\xmls\00075.xml"
$xml = New-Object -TypeName XML
$xml.Load($file)

$path = get-item $file
#$path = $path.DirectoryName
$edit = $path.DirectoryName + "\edits"
#$edit
if(Test-Path $edit){}else{mkdir $edit}


# note: if your XML is malformed, you will get an exception here
# always make sure your node names do not contain spaces
 
# simply traverse the nodes and select the information you want:


#$xml.SelectNodes("//dsc")
#$$xml.ead.archdesc.dsc.c01.count
$items = $xml.ead.archdesc.dsc
#$now = @("c01","c01.c02")
#$now2 = ".c01.c02"

        #Calc MinMax Date Range




$dates = @()

Calc-DateRange $items.c01
Calc-DateRange $items.c01.c02
Calc-DateRange $items.c01.c02.c03
Calc-DateRange $items.c01.c02.c03.c04
Calc-DateRange $items.c01.c02.c03.c04.c05
Calc-DateRange $items.c01.c02.c03.c04.c05.c06
Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08
Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09
Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10
Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11
Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12
Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12.c13
Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12.c13.c14

#$dates
$minyear = minDate -csv1 $dates -minrun 0
$maxyear = minDate -csv1 $dates -minrun 1
#$minyear = "2005"
#$maxyear = "2000"

#$items = $items.c01.c02
#$items
#$items.Value


Modify-XMLDateCoded $items.c01
Modify-XMLDateCoded $items.c01.c02
Modify-XMLDateCoded $items.c01.c02.c03
Modify-XMLDateCoded $items.c01.c02.c03.c04
Modify-XMLDateCoded $items.c01.c02.c03.c04.c05
Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06
Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08
Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09
Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10
Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11
Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12
Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12.c13
Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12.c13.c14


#Remove Front Matter 

if($xml.ead.frontmatter){$xml.ead.RemoveChild($xml.ead.frontmatter)}
       
        #if( $file -match '(^.*)\.*.xml$'){$matches[1]}
        $path = $path.Name
        #$edit+"\"+$path
        #$path.Name
        $xml.Save($edit+"\"+$path+"_NEW"+ $(get-date).Tobinary() + ".xml")

}elseif($mode -eq 2){


write-host "Processing XML. Please wait..."

    # load it into an XML object:
    $file = Get-FileName -initialDirectory "c:fso" 
    #$file = "C:\Users\Micheal\Documents\HaraldComplete\CodeOldDates\xmls\00075.xml"
    $path = get-item $file

    $files =  gci $path.DirectoryName | where {$_.Name -match '.xml$'}
    
    foreach($p in $files){
    
    #$p.FullName
    
    $xml = New-Object -TypeName XML
    $xml.Load($p.FullName)

    $path = get-item $p.FullName
    #$path = $path.DirectoryName
    $edit = $path.DirectoryName + "\edits"
    #$edit
    if(Test-Path $edit){}else{mkdir $edit}


    # note: if your XML is malformed, you will get an exception here
    # always make sure your node names do not contain spaces
 
    # simply traverse the nodes and select the information you want:


    #$xml.SelectNodes("//dsc")
    #$$xml.ead.archdesc.dsc.c01.count
    $items = $xml.ead.archdesc.dsc
    #$now = @("c01","c01.c02")
    #$now2 = ".c01.c02"

            #Calc MinMax Date Range




    $dates = @()

    Calc-DateRange $items.c01
    Calc-DateRange $items.c01.c02
    Calc-DateRange $items.c01.c02.c03
    Calc-DateRange $items.c01.c02.c03.c04
    Calc-DateRange $items.c01.c02.c03.c04.c05
    Calc-DateRange $items.c01.c02.c03.c04.c05.c06
    Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08
    Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09
    Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10
    Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11
    Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12
    Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12.c13
    Calc-DateRange $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12.c13.c14

    #$dates
    $minyear = minDate -csv1 $dates -minrun 0
    $maxyear = minDate -csv1 $dates -minrun 1
    #$minyear = "2005"
    #$maxyear = "2000"

    #$items = $items.c01.c02
    #$items
    #$items.Value


    Modify-XMLDateCoded $items.c01
    Modify-XMLDateCoded $items.c01.c02
    Modify-XMLDateCoded $items.c01.c02.c03
    Modify-XMLDateCoded $items.c01.c02.c03.c04
    Modify-XMLDateCoded $items.c01.c02.c03.c04.c05
    Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06
    Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08
    Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09
    Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10
    Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11
    Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12
    Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12.c13
    Modify-XMLDateCoded $items.c01.c02.c03.c04.c05.c06.c07.c08.c09.c10.c11.c12.c13.c14

       
            #if( $file -match '(^.*)\.*.xml$'){$matches[1]}
            $path = $path.Name
            #$edit+"\"+$path
            #$path.Name
            #$savepath = $()
            #write-host "SavePath "$savepath
            $xml.Save($edit+"\"+$path+"_NEW"+ $(get-date).Tobinary() + ".xml")
            #notepad $savepath

}
}
      #  if($items.c01.c02){Write-Host "true"}
        
   #pause 
   Read-Host 'Press enter to close' | Out-Null
   #count
   