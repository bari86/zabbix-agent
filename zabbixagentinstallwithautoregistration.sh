#!/bin/bash

# Zabbix Auto Install Script With Autoregistration
# Version 0.5

# Please put in your Zabbix Server IP.
SERVERIP="127.0.0.1"

# Please put in your Zabbix Host Monitoring name here.
ZABBIXHOSTNAME="CustomNameHere"
# ZABBIXHOSTNAME="$(hostname -f)" # Alternatively you can comment the first line and uncomment the second line for it to use the server hostname.

# Enable PSK Encryption Host.
ZABBIXTLSIDENTITY=$ZABBIXHOSTNAME # Your PSK identity. Please use this value in your Zabbix Server > Monitor > Add Host > Encryption > PSK.
# ZABBIXTLSIDENTITY="YourPSKIdentity" # Alternative PSK identity. You can comment above and use custom value instead.

# PSK Secret path location.
ZABBIXTLSFILELOCATION=/etc/zabbix/zabbix_secret.psk

# Auto Registration Host.
ZABBIXPSKSECRET=YOURRANDOMHEX # Your PSK value. Please use this value in your Zabbix > Administration > General > Autoregistration.
ZABBIXHOSTMETADATA="YourHostMetadata" # Your Host Metadata value. Please use this value in your Zabbix Server > Configuration > Actions > Autoregistration action







# Script starts

# Step 1 = Determines the OS Distribution
# Step 2 = Determines the OS Version ID
# Step 3 = Downloads Zabbix-Agent Repository & Installs the Zabbix-Agent
# Step 4 = Enable PSK Encryption for Zabbix-Agent
# Step 5 = Update Zabbix-Agent Config, Enable Service to auto start post Boot & Restart Zabbix-Agent
# Step 6 = Installation Completion Greeting


function editzabbixconf()
{
echo ========================================================================
echo Step 3 = Downloading Zabbix Repository and Installing Zabbix-Agent	
echo !! 3 !! Zabbix-Agent Installed
echo ========================================================================

mv /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.original
cp /etc/zabbix/zabbix_agentd.conf.original /etc/zabbix/zabbix_agentd.conf	
sed -i "s+Server=127.0.0.1+Server=$SERVERIP+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+ServerActive=127.0.0.1+ServerActive=$SERVERIP:10051+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+Hostname=Zabbix server+Hostname=$ZABBIXHOSTNAME+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+# Timeout=3+Timeout=30+g" /etc/zabbix/zabbix_agentd.conf

echo ========================================================================
echo Step 4 = Enable PSK Encryption & Autoregistration for Zabbix-Agent	
echo !! 4 !! Zabbix-Agent Installed
echo ========================================================================

touch $ZABBIXTLSFILELOCATION
echo $ZABBIXPSKSECRET > $ZABBIXTLSFILELOCATION
# openssl rand -hex 32 > $ZABBIXTLSFILELOCATION # To use random PSK value. Need to comment out line 59, 60, 21, which are 'touch $ZABBIXTLSFILELOCATION', 'echo $ZABBIXPSKSECRET > $ZABBIXTLSFILELOCATION', 'ZABBIXPSKSECRET=YOURRANDOMHEX'
chown zabbix:zabbix $ZABBIXTLSFILELOCATION
chmod 640 $ZABBIXTLSFILELOCATION
sed -i "s+# TLSConnect=unencrypted+TLSConnect=psk+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+# TLSAccept=unencrypted+TLSAccept=psk+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+# TLSPSKIdentity=+TLSPSKIdentity=$ZABBIXTLSIDENTITY+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+# TLSPSKFile=+TLSPSKFile=$ZABBIXTLSFILELOCATION+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+# HostMetadata=+HostMetadata=$ZABBIXHOSTMETADATA+g" /etc/zabbix/zabbix_agentd.conf


echo ========================================================================
echo Step 5 = Working on Zabbix-Agent Configuration
echo !! 5 !! Updated Zabbix-Agent conf file at /etc/zabbix/zabbix_agentd.conf
echo !! 5 !! Enabled Zabbix-Agent Service to Auto Start at Boot Time
echo !! 5 !! Restarted Zabbix-Agent post updating conf file
echo ========================================================================
}


function ifexitiszero()
{
if [[ $? == 0 ]];
then editzabbixconf
else echo :-/ Failed at Step 3 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0

fi
}

function rhel9()
{
rpm -Uvh http://repo.zabbix.com/zabbix/6.0/rhel/9/x86_64/zabbix-release-latest.el9.noarch.rpm
yum clean all
yum install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function rhel8()
{
rpm -Uvh http://repo.zabbix.com/zabbix/6.0/rhel/8/x86_64/zabbix-release-latest.el8.noarch.rpm
yum clean all
yum install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function rhel7()
{
rpm -Uvh http://repo.zabbix.com/zabbix/6.0/rhel/7/x86_64/zabbix-release-latest.el7.noarch.rpm
yum clean all
yum install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function rhel6()
{
rpm -Uvh http://repo.zabbix.com/zabbix/6.0/rhel/6/x86_64/zabbix-release-6.0-4.el6.noarch.rpm 
yum clean all
yum install zabbix-agent -y
ifexitiszero
chkconfig zabbix-agent on
service zabbix-agent restart
}

function rhel5()
{
rpm -Uvh http://repo.zabbix.com/zabbix/6.0/rhel/5/x86_64/zabbix-release-6.0-4.el5.noarch.rpm 
ifexitiszero
chkconfig zabbix-agent on
service zabbix-agent restart
}

function ubuntu22()
{
wget http://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest+ubuntu22.04_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function ubuntu20()
{
wget http://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu20.04_all.deb
dpkg -i zabbix-release_latest+ubuntu20.04_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function ubuntu18()
{
wget http://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu18.04_all.deb
dpkg -i zabbix-release_latest+ubuntu18.04_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function ubuntu16()
{
wget http://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu16.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu16.04_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}


function ubuntu14()
{
wget http://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu14.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu14.04_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
update-rc.d zabbix-agent enable
service zabbix-agent restart
}

function debian11()
{
wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian11_all.deb
dpkg -i zabbix-release_latest+debian11_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function debian10()
{
wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian10_all.deb
dpkg -i zabbix-release_latest+debian10_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function debian9()
{
wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian9_all.deb
dpkg -i zabbix-release_latest+debian9_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function debian8()
{
wget http://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian8_all.deb
dpkg -i zabbix-release_5.4-1+debian8_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function suse15()
{
rpm -Uvh --nosignature http://repo.zabbix.com/zabbix/6.0/sles/15/x86_64/zabbix-release-6.0-3.sles15.noarch.rpm
zypper --gpg-auto-import-keys refresh 'Zabbix Official Repository'
zypper -n install zabbix-agent
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}

function suse12()
{
rpm -Uvh --nosignature http://repo.zabbix.com/zabbix/6.0/sles/12/x86_64/zabbix-release-6.0-3.sles12.noarch.rpm
zypper --gpg-auto-import-keys refresh 'Zabbix Official Repository'
zypper -n install zabbix-agent
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}






#VERSION ID FUNCTION'S LISTED BELOW

function version_id_red()
{
r=$(cat /etc/redhat-release)
echo  !! 2 !! OS Version determined as $r

if [[ $r == *"9."* ]];     then rhel9
elif [[ $r == *"8."* ]];   then rhel8
elif [[ $r == *"7."* ]];   then rhel7
elif [[ $r == *"6."* ]];   then rhel6
elif [[ $r == *"5."* ]];   then rhel5
else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}


function version_id_centos()
{
c1=$(cat /etc/redhat-release)
echo !! 2 !! OS Version determined as $c1

if [[ $c1 == *"9."* ]];     then rhel9
elif [[ $c1 == *"8."* ]];   then rhel8
elif [[ $c1 == *"7."* ]];   then rhel7
elif [[ $c1 == *"6."* ]];   then rhel6
elif [[ $c1 == *"5."* ]];   then rhel5
else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}

function version_id_ubuntu()
{
u1=$(cat /etc/*release* | grep VERSION_ID=)
echo !! 2 !! OS Version determined as $u1  #prints os version id like this : VERSION_ID="8.4"

u2=$(echo $u1 | cut -c13- | rev | cut -c2- |rev)
#echo $u2        #prints os version id like this : 8.4

u3=$(echo $u2 | awk '{print int($1)}')
#echo $u3       #prints os version id like this : 8

if [[ $u3 -eq 22 ]];      then ubuntu22
elif [[ $u3 -eq 20 ]];    then ubuntu20
elif [[ $u3 -eq 18 ]];    then ubuntu18
elif [[ $u3 -eq 16 ]];    then ubuntu16
elif [[ $u3 -eq 14 ]];    then ubuntu14
else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}


function version_id_debian()
{
d1=$(cat /etc/*release* | grep VERSION_ID=)
echo !! 2 !! OS Version determined as $d1  #prints os version id like this : VERSION_ID="8.4"

d2=$(echo $d1 | cut -c13- | rev | cut -c2- |rev)
#echo $d2        #prints os version id like this : 8.4

d3=$(echo $d2 | awk '{print int($1)}')
#echo $d3       #prints os version id like this : 8

if [[ $d3 -eq 10 ]];     then debian10
elif [[ $d3 -eq 9 ]];    then debian9
elif [[ $d3 -eq 8 ]];    then debian8
else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}



function version_id_suse()
{
d1=$(cat /etc/*release* | grep VERSION_ID=)
echo !! 2 !! OS Version determined as $d1  #prints os version id like this : VERSION_ID="8.4"

d2=$(echo $d1 | cut -c13- | rev | cut -c2- |rev)
#echo $d2        #prints os version id like this : 8.4

d3=$(echo $d2 | awk '{print int($1)}')
#echo $d3       #prints os version id like this : 8

if [[ $d3 -eq 15 ]];     then suse15
elif [[ $d3 -eq 12 ]];   then suse12
else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}

function version_id_amazon()
{
d1=$(cat /etc/*release* | grep VERSION_ID=)
echo !! 2 !! OS Version determined as $d1  #prints os version id like this : VERSION_ID="8.4"

d2=$(echo $d1 | cut -c13- | rev | cut -c2- |rev)
#echo $d2        #prints os version id like this : 8.4

d3=$(echo $d2 | awk '{print int($1)}')
#echo $d3       #prints os version id like this : 8

if [[ $d3 -eq 2 ]];     then rhel9

else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}







#STEP 1 - SCRIPT RUNS FROM BELOW


echo Starting Zabbix-Agent Installation Script
echo ========================================================================
echo Step 1 = Determining OS Distribution Type

if [[ $(cat /etc/redhat-release) == *"Red Hat"* ]];
then 	echo !! 1 !!  OS Distribution determined as Red Hat Enterprise Linux
	echo Step 2 = Determining OS Version ID now
	version_id_red

elif [[ $(cat /etc/redhat-release) == *"CentOS"*  ]]
	then echo !! 1 !!  OS Distribution determined as CentOS Linux
	echo Step 2 = Determining OS Version ID now
	version_id_centos

elif [[ $(cat /etc/*release*) == *"Amazon Linux"*  ]]
        then echo !! 1 !!  OS Distribution determined as Amazon Linux
        echo Step 2 = Determining OS Version ID now
        version_id_amazon

elif [[ $(cat /etc/*release*) == *"ubuntu"* ]];
	then echo !! 1 !! OS Distribution determined as Ubuntu Linux
	echo Step 2 = Determining OS Version ID now
        version_id_ubuntu

elif [[ $(cat /etc/*release*) == *"debian"* ]];
	then echo !! 1 !! OS Distribution determined as Debian Linux
	echo Step 2 = Determining OS Version ID now
        version_id_debian

elif [[ $(cat /etc/*release*) == *"SUSE"* ]];
	then echo !! 1 !! OS Distribution determined as SUSE Linux
	echo Step 2 = Determining OS Version ID now
	version_id_suse

else echo :-/ Failed at Step 1 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi



#STEP 6
echo ========================================================================
echo Congrats. Zabbix-Agent Installion is completed successfully.
echo Zabbix-Agent is installed, started and enabled to be up post reboot on this machine.
echo You can now add the host $ZABBIXHOSTNAME with IP $(hostname -i) on the Zabbix-Server Front End.
echo Your TLS PSK Identity : $ZABBIXTLSIDENTITY 
echo Your PSK Secret is stored at $ZABBIXTLSFILELOCATION
echo Your HostMetadata : $ZABBIXHOSTMETADATA
echo Thanks for using Bari"'"s zabbix-agent installation script.
echo Visit https://github.com/bari86/zabbix-agent for more information.
echo ========================================================================
echo To check zabbix-agent service status, you may run : service zabbix-agent status
echo To check zabbix-agent config, you may run : egrep -v '"^#|^$"' /etc/zabbix/zabbix_agentd.conf
echo To check zabbix-agent logs, you may run : tail -f /var/log/zabbix/zabbix_agentd.log
echo ========================================================================
