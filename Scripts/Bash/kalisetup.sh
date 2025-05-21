#!/bin/bash
#
####################################################################################################
# Script Name: kalisetup.sh
# Description: This is the kalisetup.sh (Bash) script - this script will install basic offensive tools, and established the SAzure MB Share.
# Author: Athanasius of Alexandria
# Copyright (C) 2025 AthanasiusXOR (Red Team Security Engineer)
#
# Version: 1.0.1
# Last Updated: 2025-05-08
# Version History
#   1.0.0   2024-01-28  Initial version
#   1.0.1   2025-05-8   Updated versions w/new tool sets.
#
#
####################################################################################################
#
#!/bin/bash

# Functions for logging
log_info() {
    printf "[INFO] %s\n" "$1"
}

log_error() {
    printf "[ERROR] %s\n" "$1" >&2
}

# Update and upgrade the system
log_info "Updating and upgrading system..."
export DEBIAN_FRONTEND=noninteractive
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install required tools
log_info "Installing required tools..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
   terminator golang-go make netexec sqlmap ffuf gobuster smbmap snmp \
    dnsrecon ldap-utils odat smtp-user-enum ike-scan screen tmux bash python3 \
    python3-pip curl wget grep wireshark flameshot snmpcheck telnet tcpdump \
    vim-gtk3 nano gedit metasploit-framework sslscan exploitdb nmap enum4linux \
    mingw-w64 nikto crackmapexec aircrack-ng kismet wpasupplicant wifite \
    seclists responder john hashcat openjdk-11-jdk

# Enable and start xrdp service
log_info "Installing and starting XRDP service..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y xrdp
sudo DEBIAN_FRONTEND=noninteractive apt install -y kali-desktop-xfce
sudo apt install -y dbus-x11
sudo echo "xfce4-session" > ~/.xsession
sudo systemctl restart dbus
sudo systemctl enable xrdp
sudo systemctl start xrdp
sudo systemctl restart xrdp

# Set a custom password for the current user without prompting
NEW_PASSWORD="INSERT PASSWORD" # Insert password here
log_info "Setting custom RDP password for 'azureuser'..."
echo -e "$NEW_PASSWORD\n$NEW_PASSWORD" | sudo passwd azureuser

# Create a Tools directory if it doesn't exist
 TOOLS_DIR="/home/tools"
 log_info "Creating tools directory at $TOOLS_DIR..."
 sudo mkdir -p "$TOOLS_DIR"
 cd "$TOOLS_DIR" || exit 1

# Install pip for Python3
 log_info "Installing pip for Python3..."
 sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
 sudo python3 get-pip.py --break-system-packages -q
 sudo rm get-pip.py

# Install cifs-utils for mounting Azure File Share via SMB
log_info "Installing cifs-utils and configuring Azure File Share..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install cifs-utils -y
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

# Copy and extract Cobaltstrike
 log_info "Copying and extracting Cobaltstrike distribution..."
 if [[ -f /mnt/infrastructure-setup/cobaltstrike-dist-linux.tgz ]]; then
    sudo cp /mnt/infrastructure-setup/Tools/Cobaltstrike/cobaltstrike-dist-linux.tgz "$TOOLS_DIR"
    cd "$TOOLS_DIR"
    sudo tar -xzf cobaltstrike-dist-linux.tgz
    sudo rm cobaltstrike-dist-linux.tgz
    log_info "Cobaltstrike successfully extracted to $TOOLS_DIR."
 else
    log_error "Cobaltstrike distribution not found in /mnt/infrastructure-setup."
 fi

# Tools for Cobaltstrike
log_info "Cloning and setting up Cobaltstrike tools..."
sudo git clone https://github.com/rsmudge/Malleable-C2-Profiles.git
sleep 2
sudo git clone https://github.com/RedSiege/C2concealer.git
sleep 2
cd "$TOOLS_DIR"
sudo git clone https://github.com/Tylous/SourcePoint.git
cd SourcePoint
cd "$TOOLS_DIR"

# Clone Reflective Loaders for CobaltStrike
REFLECTIVE_LOADERS_DIR="$TOOLS_DIR/Reflective_Loaders"
log_info "Cloning Reflective Loaders for CobaltStrike..."
sudo mkdir -p "$REFLECTIVE_LOADERS_DIR"
cd "$REFLECTIVE_LOADERS_DIR"
sudo git clone https://github.com/benheise/TitanLdr.git
sudo git clone https://github.com/boku7/BokuLoader.git
sudo git clone https://github.com/mgeeky/ElusiveMice.git
sudo git clone https://github.com/Mav3rick33/ZenLdr.git
sudo git clone https://github.com/Cracked5pider/KaynStrike.git
cd "$TOOLS_DIR"

# Cloning additional tools and repositories
log_info "Cloning and installing additional tools..."
sudo git clone https://github.com/SecureAuthCorp/impacket.git
sudo git clone https://github.com/peass-ng/PEASS-ng.git
sudo git clone https://github.com/21y4d/nmapAutomator.git
sudo git clone https://github.com/t3l3machus/eviltree.git
sudo git clone https://github.com/topotam/PetitPotam.git
sudo git clone https://github.com/SnaffCon/Snaffler.git
sudo git clone https://github.com/aboul3la/Sublist3r.git
sudo git clone https://github.com/RedSiege/EyeWitness.git
sudo git clone https://github.com/dirkjanm/roadtools.git

# Final additional clones
sudo git clone https://github.com/Gerenios/AADInternals.git
sudo git clone https://github.com/outflanknl/C2-Tool-Collection.git
sudo git clone https://github.com/ajpc500/BOFs.git
sudo git clone https://github.com/wotwot563/aad_prt_bof.git
sudo git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries.git
sudo git clone https://github.com/Kevin-Robertson/Powermad.git
sudo git clone https://github.com/Flangvik/SharpCollection.git
sudo git clone https://github.com/dirkjanm/PKINITtools
sudo git clone https://github.com/fortra/nanodump.git
sudo git clone https://github.com/anthemtotheego/InlineExecute-Assembly.git
sudo git clone https://github.com/kyleavery/inject-assembly.git
sudo git clone https://github.com/outflanknl/HelpColor.git

log_info "Script completed successfully!"
exit 0
