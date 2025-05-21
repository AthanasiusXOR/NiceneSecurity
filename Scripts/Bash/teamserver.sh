#!/bin/bash
#
####################################################################################################
# Script Name: teamserver_installation.sh
# Description: This is a script for TeamServer. The script does a lot of front end work to upload and deploy a variety of tools.
# Author: Athanasius of Alexandria
# Copyright (C) 2025 AthanasiusXOR (Red Team Security Engineer)
#
# Version: 1.0.0
# Last Updated: 2025-10-28
# Version History
#   1.0.0   2025-10-28  Initial version
#
#
####################################################################################################
#
# Functions for logging
log_info() {
    printf "[INFO] %s\n" "$1"
}

log_error() {
    printf "[ERROR] %s\n" "$1" >&2
}

# Update and upgrade the system
log_info "Updating and upgrading system..."
sudo apt-get update -y && sudo apt-get upgrade -y
sleep 2

# Install required tools
log_info "Installing required tools..."
sudo apt-get install -y \
    terminator golang-go make netexec sqlmap ffuf gobuster smbmap snmp \
    dnsrecon ldap-utils odat smtp-user-enum ike-scan screen tmux bash python3 \
    python3-pip curl wget grep flameshot snmpcheck telnet tcpdump \
    vim-gtk3 nano gedit metasploit-framework sslscan exploitdb nmap enum4linux \
    mingw-w64 nikto crackmapexec aircrack-ng kismet wpasupplicant wifite \
    seclists responder john hashcat tmux

# Create a Tools directory if it doesn't exist
TOOLS_DIR="/home/tools"
log_info "Creating tools directory at $TOOLS_DIR..."
sudo mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR" || exit 1

# Install pip for Python3
log_info "Installing pip for Python3..."
sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py --break-system-packages
sudo rm get-pip.py

# Install cifs-utils for mounting Azure File Share via SMB
log_info "Installing cifs-utils and configuring Azure File Share..."
sudo apt-get install cifs-utils -y
sudo mkdir -p /mnt/infrastructure-setup /mnt/operations/ /etc/smbcredentials
echo "username=INSERT USERNAME HERE" | sudo tee /etc/smbcredentials/redteamfileshare.cred
echo "password=INSERT PASSWORD HERE" | sudo tee -a /etc/smbcredentials/redteamfileshare.cred # This needs to be replaced with Azure's Generated Password.
sudo chmod 600 /etc/smbcredentials/redteamfileshare.cred

# Mount Azure File Share
log_info "Mounting Azure File Share..."
sudo bash -c 'echo "//xxxxxxxxxx.file.core.windows.net/infrastructure-setup /mnt/infrastructure-setup cifs nofail,credentials=/etc/smbcredentials/redteamfileshare.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //xxxxxxxxxx.file.core.windows.net/infrastructure-setup /mnt/infrastructure-setup -o credentials=/etc/smbcredentials/redteamfileshare.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30
sudo bash -c 'echo "//xxxxxxxxxx.file.core.windows.net/operations /mnt/operations cifs nofail,credentials=/etc/smbcredentials/redteamfileshare.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //xxxxxxxxxx.file.core.windows.net/operations /mnt/operations -o credentials=/etc/smbcredentials/redteamfileshare.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30
sudo systemctl daemon-reload

# Copy and extract Cobaltstrike
 log_info "Copying and extracting Cobaltstrike distribution..."
 if [[ -f /mnt/infrastructure-setup/cobaltstrike-dist-linux.tgz ]]; then
    sudo cp /mnt/infrastructure-setup/cobaltstrike-dist-linux.tgz "$TOOLS_DIR"
    cd "$TOOLS_DIR"
    sudo tar -xzf cobaltstrike-dist-linux.tgz
    sudo rm cobaltstrike-dist-linux.tgz
    log_info "Cobaltstrike successfully extracted to $TOOLS_DIR."
 else
    log_error "Cobaltstrike distribution not found in /mnt/infrastructure-setup."
 fi

 exit 0
