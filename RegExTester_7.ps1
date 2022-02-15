$csv = ("November 1983 - January 1984", 
"April 26 - May 2, 1986", 
"October 9 , 1852 -  August 11 1854", 
"July 23 - August 7, 2005", 
"July 1998 - December, 1999","c. 1945-1945","1970s-1980s","April 26 - May 2, 1986","January, 1987","1970s - 1980s","1969 and undated","February, 1902")


$csv2 = (
    "October, 2001",	                           #2001-10
    "October 16, 2001",	                           #2001-10-16
    "October 16-18, 2001",	                       #2001-10-16/2001-10-18
    "October-December, 2001",	                   #2001-10/2001-12
    "October, 2001 - January, 2002",	           #2001-10/2002-01
    "Spring, 2001",	                               #2001
    "1970s",	                                   #1970/1979
    "c. 1970s",	                                   #1970/1979
    "1945, 1947, 1961",	                           #1945/1961
    "1945-1947, 1961",	                           #1945/1961
    "c. 1956",                                     #1956
    "November 1983 - January 1984",                #1983-11/1984-01
    "April 26 - May 2, 1986",                      #1986-04-26/1986-05-02”
    "October 9, 1852 - August 11, 1854",           #1852-10-09/1954-08-11
    "1970s - 1980s",                               #1970/1989
    "July 23 - August 7, 2005",                    #2005-07-23/2005-08-07
    "July 1998 - December, 1999",                  #1998-07/1999-12
    "Winter, 1993 – Fall, 1995",                   #1993/1995
    "August 26, 1924 to January 1, 1934",          #1924-08-26/1934-01-01
    "undated",                                     #undated  
    "1956 and undated",                            #1956
    "1956-1958 and undated",                       #1956-1958
    "1931, Jan.-July and undated",
    "November 9, 1852  – August 11, 1854",         #1852-11-09/1854-08-11
    "November 9th, 1852  – August 11th, 1854",     #1852-11-09/1854-08-11
    "October 23rd, 2001",                           #2001-10-23  
    "April 26th - May 2nd, 1986",
    "October 16th-18th, 2001",
    "Jan.-Sept. 1933",
    "Circa 1957",
    "Dec. 17, 1982 - ",
    "19 May 1982, 7 p.m.",
    "14 to 16 December 1987",    
    "9 May 1978",
    "June 1978",
    "October 16th-18th, 2001"

    





)


foreach($i in $csv2){$i
    
    #1 - October-December, 2001
    if($i -match "([a-zA-Z]+).?\s*-\s*([a-zA-Z]+)\s*.?\s*(\d{4})"){Write-host "1 $True" -BackgroundColor Red -ForegroundColor Black}
    
    #2 - #January 24, 2014 - February 24, 2018 and a few variations Done
    #if($i -match "([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?(\s*.{1,2}\b\s*([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?)" -and $i -notlike "*undated*"){Write-host "2 $True" -BackgroundColor Red -ForegroundColor Black}
    #2 - #January 24, 2014 - February 24, 2018 and a few variations Done
    if($i -match "([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?(\s*.{1,2}\b\s*([a-zA-Z]+)\s*,?\s*\b(\d{1,2})?(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\b\s*,?\s*(\d{4})?)" -and $i -notlike "*undated*"){Write-host "2 $True" -BackgroundColor red -ForegroundColor Black}
    

    #3 - undated
    if($i -match "(\d{4})?(?:-(\d{4}))?.*(?:\s*and\s*)?undated"){Write-host "3 $True" -BackgroundColor Red -ForegroundColor Black}
    
    #4 - c 1790s, and 1790s
    if($i -match "^(c\.?\s+)?(\d{4})s$"){Write-host "4 $True" -BackgroundColor Red -ForegroundColor Black}
    
    #5 1970s-1980s
    if($i -match "^\s*(\d{4})s\s*-\s*(\d{4})s\s*$"){write-host "5 $True" -BackgroundColor Red -ForegroundColor Black}

    #6 - October, 2001
    if($i -match "^[a-zA-Z]+,?\s*(\d{4})$" -and   $i -notlike "Spring*" -and   $i -notlike "Fall*" -and   $i -notlike "Summer*" -and   $i -notlike "Winter*" -and   $i -inotlike "Circa*" ){Write-host "6 $True" -BackgroundColor cyan -ForegroundColor Black}
    
    #7 - Spring, 2001
    if($i -like "Spring*" -or   $i -like "Fall*" -or   $i -like "Summer*" -or   $i -like "Winter*"){Write-host "7 $True" -BackgroundColor Red -ForegroundColor Black}
    
    #8 - October 16, 2001
    if($i -match "([a-zA-Z]+)\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*,?\s*(\d{4})"){Write-host "8 $True" -BackgroundColor Red -ForegroundColor Black}

    #9 - October 16-18, 2001
    if($i -match "([a-zA-Z]+)\s*(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?\s*(?:.{1,2})\s*\b(\d{1,2})(?:[nN][dD]|[sS][tT]|[rR][dD]|[tT][hH])?,\s*(\d{4})"){Write-host "9 $True" -BackgroundColor Red -ForegroundColor Black}

    #10 - c. 1945-1947
    if($i -match "^\s*c.\s*(\d{4})\s*-\s*(\d{4})\s*$"){Write-host "10 $True" -BackgroundColor Red -ForegroundColor Black}

    #11 - 1945 and c. 1945
    if($i -match "^\s*(?:c.|[cC][iI][Rr][cC][aA].?)?\s*(\d{4})$"){Write-host "11 $True" -BackgroundColor Red -ForegroundColor Black}

    #12 - 19 May 1982, 7 p.m.
    #if($i -match "(\d{4}).*(?:[aA]\.?[mM]\.?|[pP]\.?[Mm]\.?)"){Write-host "12 $True $($matches[1])" -BackgroundColor red -ForegroundColor Black}
   
    #13- 1942, 1045, 1945-1947
    #if($i -match "(\d.*\d)"){Write-host "13 $True $($matches[0])" -BackgroundColor Red -ForegroundColor Black}
    #draft 13 
    if($i -match "(\d.*\d)"){Write-host "13 $True $($matches[0])" -BackgroundColor red -ForegroundColor Black}
    #14 Match any year
    if($i -match "(\d{4})"){Write-host "14 $True $($matches[0])" -BackgroundColor red -ForegroundColor Black}
    #15     14 to 16 December 1987
    #if($i -match "(\d{1,2})\s+to\s+(\d{1,2})\s+([a-zA-Z]+)\s*(\d{4})"){Write-host "15 $True" -BackgroundColor red -ForegroundColor Black}
    
   
     





    #7 - October, 2001 - January, 2002   
    #if($i -match "([a-zA-Z]+),\s(\d{4})\s-\s([a-zA-Z]+),\s+(\d{4})"){Write-host "7 $True"}
    
   
    #1945-1946 or 1945-1946 and undated
   <#
    elseif($i -match "^(\d{4})-(\d{4})"){
        if($i -match "^(\d{4})-(\d{4})"){ $year = $matches[1]; $year2 = $matches[2];}
        return $($year+"/"+$year2) 
    }#>


    # 1945, 1947, 1961 OR 1945-1947, 1961
    <#elseif($i -match "(\d{4})(-|,\s+)\d{4},\s+(\d{4})"){$year = $matches[1]; $year2 = $matches[3];
            #if($i.date -match "^(\d{4}).*(\d{4})$"){ $year = $matches[1]; $year2 = $matches[2];}
            
        return $($year+"/"+ $year2) #>
        
    
        #1985, 1985, 1222-1922
        
        
        
            
        
            
          }  


           
           
    

    