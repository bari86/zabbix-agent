#!/bin/bash



function version_redhat()
{
service zabbix-agent stop
yum remove zabbix-agent* -y
yum remove zabbix-release* -y
rm -rvf /etc/zabbix
}

function version_ubuntu_debian()
{
service zabbix-agent stop
apt remove zabbix-agent* -y
apt remove zabbix-release* -y
rm -rvf /etc/zabbix
apt purge zabbix-agent* -y
}


function version_suse()
{
service zabbix-agent stop
zypper -n remove zabbix-agent*
zypper -n remove zabbix-release*
rm -rvf /etc/zabbix
}




echo Starting Zabbix-Agent Removal Script
echo ==========================================================

if [[ $(cat /etc/*release*) == *"redhat"* ]];
then echo Running zabbix-agent uninstall script for Red Hat Enterprise Linux Distribution....
        version_redhat

elif [[ $(cat /etc/*release*) == *"CentOS"* ]];
then echo Running zabbix-agent uninstall script for CentOS Distribution....
	version_redhat

elif [[ $(cat /etc/*release*) == *"ubuntu"* ]];
then echo Running zabbix-agent uninstall script for Ubuntu Distribution....
        version_ubuntu_debian

elif [[ $(cat /etc/*release*) == *"debian"* ]];
then echo Running zabbix-agent uninstall script for Debian Distribution....
        version_ubuntu_debian

elif [[ $(cat /etc/*release*) == *"SUSE"* ]];
then echo Running zabbix-agent uninstall script for SUSE Linux Distribution....
	version_suse

elif [[ $(cat /etc/*release*) == *"Amazon Linux"* ]];
then echo Running zabbix-agent uninstall script for Amazon Linux Distribution....
        version_redhat

else echo This script cannot be used for zabbix-agent removal on this machine && exit 0

fi

echo ==========================================================

echo Zabbix-Agent is Successfully Uninstalled and  Removed from this machine

echo Thanks for using Bari"'"s zabbix-agent removal script

echo Host to be removed from Front End : $(hostname -f)

echo ==========================================================
