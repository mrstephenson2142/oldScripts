
# Summary

Repo of projects, various notes and script samples. 

- [Scripts](#oldscripts)
- [Notes](#notes-and-cheat-sheets)
- [Other Projects](#other-projects)

# oldScripts

Old scripts. Some of which I used to automate tasks, or for fun side projects. 

A few examples from the scripts and a brief description.

### [terminatedAccounts](scripts/terminatedAccounts.ps1)

Taking the body of an email and pasting it into this script, the script would search for usernames, make API Calls to Qualys and check Active Directory for group memberships. If users were found, they could then be removed. 

### [natInvestigation](scripts/natInvestigation.py)

This script will look through a specifically formatted firewall output and attempt to match a list of timestamps to the firewall output. If a pattern can be found the NAT public and private addresses will be printed. This was used to try to identify the private address from a public NAT in response to complaints from 3rd parties that reported the address. 

### [Southwest Collection (Archive) Project](scripts/Soutwest%20Collection%20(Archive)%20Project/HeraldOutPut_2_32.ps1)

A group of scripts that I made for the archive The Southwest Collection to help automate some of their XML creation. I was exploring RegEx at the time and they had a problem of poorly formatted dates that needed to be formatted in a specific way for their programs to parse the XML correctly and be displayed per their standard. Before these scripts were made, the XML was generated by using mail merge in a word document. After, the excel or CSV could be ingested with their archive information and XML would be split out. 

There is a testing script, so I could check that the regex was catching all the correct formats. 

There was also a script that went back through old XML files and fixed date formats to meet their current formatting requirements. 

The effort can also be read about here - <https://www.tandfonline.com/eprint/XTMGJJCUJNJQMGYETYGD/full>

### [Excel Office Script](scripts/excelOfficeScript.ts)

This script was used to keep track of historical changes month over month in an Excel Web Work Book. A range would be appended to a protected sheet. This was integrated with power automate to automatically lock the state of the tracker the last day of the month.

# Notes and Cheat Sheets 

I've also included some cheat sheets I've created while studying memory forensics and offensive security. 

- [Memory Forensics](notes/memoryDumpForensics.md)
- [Offensive Security Cheat Sheet](notes/offensiveSecurity/offsecCheatSheet.md)
- [Linux Priv Esc Cheat Sheet](notes/offensiveSecurity/linuxPrivEsc.md)
- [Windows Priv Esc Cheat Sheet](notes/offensiveSecurity/windowsPrivEsc.md)

# Other Projects

- [Splunk/Sysmon/Atomic Red Team Lab (PowerShell & Bash Scripts](https://github.com/mrstephenson2142/splunkSysmonLab)
- [Student Grading Overview (Google Sheets / Bootcamp Spot API w/ Python)](https://github.com/mrstephenson2142/bcs_student_submissions_overview)
