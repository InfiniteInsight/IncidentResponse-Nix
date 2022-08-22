# IncidentResponse-Nix.sh
I wrote this shell script as a means to help me consistently collect detailed information on *nix hosts involved in incidents. I will continue adding to it as I find more useful things or tricks.

Upon execution this script will prompt you for an incident name and create a corresponding folder to store the created logs within the current user's `$HOME` folder. It also loads a few functions into memory to assist with documenting any additional observations.


## make-log function
I found it cumbersome to have to note the time of each command, so the make-log function will record the time at execution simultaneously while logging the command and also the output of the command. 

Pipe any commandline ouput to make-log to capture it in a timestamped log.
Examples:   
$ ps -e **| make-log**
$ cat /etc/hosts **| make-log**
$ ls /tmp/ **| make-log** 
$ strace -p 1234 **| make-log**
                



## collect-InitialData function
This function is automtically called after giving the incident a name. It collects the following items:
- Hostname
- Bash History of your current logged in user
- Bash history of all other local users
    - Copy of auth.log
    - Currently connected users and sessions
    - Uptime of the endpoint
    - ARP entries
    - Route table
    - Current network connections
    - Current Interface configuration
    - Running processes
    - List of open files
    - Crontabs
    - Hosts file
    - Local users list
    - Extract of the shadow file
    - Sudoers list


 


