#!/bin/bash

#Hostapd log level settings
SYS_LOG_MODULES=-1
SYS_LOG_LEVEL=4
STDOUT_LOG_MODULES=-1
STDOUT_LOG_LEVEL=4

#DHCP server Configuration(user configuration)
WLAN_IFACE_NAME="wlx14cf92afb710"
LAN_IFACE_NAME="ens33"
NETWORK_ADDRESS="10.10.50.0/24"
LISTEN_ADDRESS="10.10.50.1"
DHCP_RANGE="10.10.50.128,10.10.50.254,255.255.255.0,12h"
DHCP_OPTION="3,10.10.50.1"
DHCP_OPTION2="6,8.8.8.8"

#Auto Configuration
EXEC_DIR="/usr/bin"
CUR_DIR=`pwd`

function CheckPackageInstalled 
{
    PKG_INSTALLED=`dpkg-query -W --showformat='${Status}\n' $1 2>/dev/null|grep -c "ok installed"`
    if [ $PKG_INSTALLED -eq 0 ]
    then
        echo "Package $1 --------- Missing!"
        if [ $# -eq 1 ]
        then
            sudo apt-get install $1 -y
            echo "Installing $1..."
        else
            sudo dpkg -i $CUR_DIR/tools/$2*
            echo "Installing $1..."
        fi
    else
        echo "Package $1 --------- Checked!"
    fi
}

function ConfigHostapd
{
    if [ ! -d $CUR_DIR/config ]
    then
        echo "Creating directory ./config"
        mkdir $CUR_DIR/config
    fi
    if [ -f $CUR_DIR/config/hostapd.conf ]
    then
	rm $CUR_DIR/config/hostapd.conf
    fi
    exec 3>$CUR_DIR/config/hostapd.conf
    echo "interface=$WLAN_IFACE_NAME">&3
    echo "ssid=test-WiFi">&3
    echo "hw_mode=g">&3
    echo "channel=1">&3
    echo "wpa=2">&3
    echo "wpa_passphrase=mypassword">&3
    echo "wpa_key_mgmt=WPA-PSK">&3
    echo "wpa_pairwise=TKIP">&3
    echo "rsn_pairwise=CCMP">&3
    echo "auth_algs=1">&3
    echo "ctrl_interface=/var/run/hostapd">&3
    echo "logger_syslog=$SYS_LOG_MODULES">&3
    echo "logger_syslog_level=$SYS_LOG_LEVEL">&3
    echo "logger_stdout=$STDOUT_LOG_MODULES">&3
    echo "logger_stdout_level=$STDOUT_LOG_LEVEL">&3


    echo "Generating default hostapd.conf in $CUR_DIR/config"
}

function ConfigDHCPServer
{
    sudo systemctl stop dnsmasq.service 2>/dev/null
    if [ -f $CUR_DIR/config/dnsmasq.conf ]
    then
	rm $CUR_DIR/config/dnsmasq.conf
    fi
    echo "Creating dhcp configuration file..."
    exec 4>$CUR_DIR/config/dnsmasq.conf
    echo "interface=$WLAN_IFACE_NAME">&4
    echo "listen-address=$LISTEN_ADDRESS">&4
    echo "dhcp-range=$DHCP_RANGE">&4
    echo "dhcp-option=$DHCP_OPTION">&4
    echo "dhcp-option=$DHCP_OPTION2">&4
    echo "Overwriting the dhcp configuration..."
    sudo cp $CUR_DIR/config/dnsmasq.conf /etc/
    sudo systemctl restart dnsmasq.service 2>/dev/null
    echo "Restarting the dhcp server"
}

function ConfigNetworkInterface
{
    INT_CHECKED=`sudo ifdown $WLAN_IFACE_NAME 2>&1| grep -c "Unknown interface"`
    if [ $INT_CHECKED -eq 1 ]
    then
	echo "auto $WLAN_IFACE_NAME" | sudo tee -a /etc/network/interfaces
	echo "iface $WLAN_IFACE_NAME inet static" | sudo tee -a /etc/network/interfaces
	echo "address $LISTEN_ADDRESS" | sudo tee -a /etc/network/interfaces
	echo "netmask 255.255.255.0" | sudo tee -a /etc/network/interfaces
    fi
}
	
#Check Packge Installed
echo "Getting the permission to set up the enviornment..."
CheckPackageInstalled libssl-dev
CheckPackageInstalled libnl1 libnl1_1.1-7_amd64.deb
CheckPackageInstalled libnl-dev libnl-dev_1.1-7_amd64.deb
CheckPackageInstalled dnsmasq


#Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1

#Configure Hostapd
ConfigHostapd

#Configure DHCP Server
ConfigDHCPServer

ConfigNetworkInterface

sudo ifup $WLAN_IFACE_NAME 1>/dev/null 2>/dev/null
#Configure NAT
sudo iptables -t nat -A POSTROUTING	-s $NETWORK_ADDRESS -o	$LAN_IFACE_NAME	-j	MASQUERADE

echo "Compiling from the source code..."
cp $CUR_DIR/defconfig $CUR_DIR/.config
make
echo "Getting the permission to turn on the ap mode..."
#sudo rfkill unblock wlan
#sudo nmcli radio wifi off
if [ -L $EXEC_DIR/hostapd ]
then
echo "Deleting exsiting symbol link..."
sudo rm -r $EXEC_DIR/hostapd
fi
echo "creating symbol link to $EXEC_DIR"
sudo ln -s $CUR_DIR/hostapd $EXEC_DIR/hostapd
echo "start hostapd..."
sudo $EXEC_DIR/hostapd -dd $CUR_DIR/config/hostapd.conf
