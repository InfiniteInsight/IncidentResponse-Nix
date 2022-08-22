#!/bin/bash

read -p "What is the Incident Name? : " incidentName
export incidentName
export machineBeingInvestigated=$(hostname)  #Replace COMPUTERNAME with the name of the endpoint being investigated.
domain=$(hostname -d) #obtaining netbios name

if [ -z "${domain}" ]; #check if the domain variable is populated, if it is not then leave it out of the dataPath.
then
    export dataPath=$HOME/$machineBeingInvestigated
else
    export dataPath=$HOME/$machineBeingInvestigated.$domain
fi

mkdir $dataPath

function collect-InitialData() {
    logPath="$dataPath/$incidentName-Initial-Observables.txt"
    echo -e "\n================================================================ {Beginning of entry for Initial Observables: $(date)} \n" >> $incidentName-Initial-Observables.txt
    echo "Command history for logged in user has been output to $dataPath/$incidentName-initialHistory.txt" >> $logPath
    history >> $dataPath/$incidentName-initialHistory.txt
    echo "Making a copy of auth.log" >> $logPath

    cp /var/log/auth.log $dataPath/auth.log #To Do: Add a check to see if the OS is Debian or Fedora so that it copies the right auth.log/secure file
    cp /var/log/secure $dataPath/secure
   

    find /home/*/.bash_history >> $dataPath/$incidentName-found_bash_history_files #find all bash history files and output filepaths to a file
    bashHistory=$dataPath/$incidentName-found_bash_history_files #assign a variable to the found bash history files 

    while read bashHistoryPath; do #loop through each bash history file and append it to a file for easier searching
            echo -e "$bashHistoryPath" >> /root/temptest/cat_bash_history
            cat $bashHistoryPath >> $dataPath/$incidentName-concatenated_bash_history
    done < "$bashHistory"

    echo "Hostname is: " $(hostname) >> $logPath
    echo -e "Current logged in users are:\n""$(who)" >> $logPath
    echo -e "Current uptime of the device is:\n""$(uptime)" >> $logPath
    echo -e "Current distribution of the OS is:\n""$(uname -a)" >> $logPath
    echo -e "ARP entries are:\n""$(arp -a)" >>  $logPath
    echo -e "IP Route List table is currently:\n""$(ip route list)" >> $logPath
    echo -e "Current Interface configuration:\n""$(ifconfig -a)" >> $logPath
    echo "Current network connections have been output to $datapath/$incidentName-netstat.txt" >> $logPath
    netstat -anp >> $datapath/$incidentName-netstat.txt
    echo "Running processes have been output to $datapath/$incidentName-initialObservedProcesses.txt" >> $logPath
    ps aux >> $dataPath/$incidentName-initialObservedProcesses.txt
    echo "Listing of open files have been output to $datapath/$incidentName-initialListingOpenFiles.txt" >> $logPath
    lsof >> $dataPath/$incidentName-initialListingOpenFiles.txt
    echo "Crontabs have been output to $datapath/$incidentName-crontabs.txt" >> $logPath
    cat /var/spool/cron/* >> $datapath/$incidentName-crontabs.txt
    echo -e "Current hosts file configuration:\n""$(cat /etc/hosts)" >> $logPath
    echo "Listing of local users on the device output to $dataPath/$incidentName-localUsers-passwd.txt"
    cat /etc/passwd >>  $dataPath/$incidentName-localUsers-passwd.txt
    echo "Listing of password hashes on the device output to $dataPath/$incidentName-shadow.txt"
    cat /etc/shadow >>  $dataPath/$incidentName-shadow.txt
    echo "Listing of sudoers on the device output to $dataPath/$incidentName-sudoers.txt"
    cat /etc/sudoers >> $dataPath/$incidentName-sudoers.txt
    echo "================================================================ {End of Initial Observables: $(date) }" >>"$dataPath/$incidentName-Master-Log.txt"
}

collect-InitialData

#Pipe any commandline ouput to this funciton to capture it in a timestamped log
#examples: ps -e | make-log
#          cat /etc/hosts | make-log
#          ls /tmp/ | make-log
function make-log() {
    startLine="\n================================================================ {Beginning of entry $incidentName: $(date) }" 
    startTime="$incidentName Log entry, date: $(date)\n"
        echo -e $startLine >>"$dataPath/$incidentName-Master-Log.txt"
        echo -e $startTime >>"$dataPath/$incidentName-Master-Log.txt"
    
        cat /dev/stdin | tee -a "$dataPath/$incidentName-Master-Log.txt"
        echo "
================================================================ {End of entry $incidentName: $(date) }" >>"$dataPath/$incidentName-Master-Log.txt"
        PURPLE='\033[0;35m'
        echo -e "${PURPLE} Item recorded into $incidentName Master Log."
    } 
    
    #grab md5 and sha256 file hashes for all files in the current directory
function get-FileHash() {
    md5sums=$(md5sum *)
    sha256sums=$(sha256sum *)
    echo -e "MD5 Hash of all files in current directory" $(pwd) "$md5sums" | make-log
    echo -e "SHA-256 Hash of all files in current directory" $(pwd) "$sha256sums" | make-log
}


#To Do:
## function to acquire AVML and take a capture
## function to acquire chrootkit
## function to acquire AIDE
## check ip links for promiscuous mode
## if RPM is installed verify packages rpm -Va | sort
## 
