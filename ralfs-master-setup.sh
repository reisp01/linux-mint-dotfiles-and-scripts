#!/bin/bash

echo "***** Ralf's Linux Mint 17.3 Master Install Script V1.47 ****"
echo ""
echo "Before continuing: set HiDPI screen resolution"
echo "                   set Cinnamon scaling to 2x"
echo "                   install and sync Dropbox"
echo "                   run apt-get update/upgrade"
echo ""

echo ""
echo -n "Press Enter to Continue . . . "
read answer

# Go home
cd

# Firewall on
sudo ufw enable
sudo ufw status verbose

# Add PPAs
sudo add-apt-repository -y ppa:djcj/screenfetch        # screenfetch system info app
sudo add-apt-repository -y ppa:peterlevi/ppa           # variety app
sudo add-apt-repository -y ppa:numix/ppa               # Numix icons+themes
sudo add-apt-repository -y ppa:stgraber/stgraber.net   # recent version of jq JSON parser
sudo add-apt-repository -y ppa:ricotz/docky            # the dock called plank
sudo add-apt-repository -y ppa:kilian/f.lux            # f.lux color balance controller

# Update/upgrade
sudo apt-get update
sudo apt-get -y upgrade

# Install software
sudo apt-get -y install xfce4-terminal variety gparted conky acpi screenfetch numix-gtk-theme numix-icon-theme numix-icon-theme-circle nemo-dropbox jq plank libcurl3 git system-config-lvm fluxgui 
sudo apt-get -y install pepperflashplugin-nonfree >/dev/null 2>&1 

# Vivaldi browser (this line fragile for version changes!)
wget https://vivaldi.com/download/vivaldi-beta_1.0.303.52-5_amd64.deb -O vivaldi-snapshot_amd64.deb
sudo dpkg -i vivaldi-snapshot_amd64.deb

# Get very complete terminal file/dir coloring list
wget https://raw.github.com/trapd00r/LS_COLORS/master/LS_COLORS -O .dir_colors
 
# Folders
mkdir ~/.icons
mkdir ~/.trackpad
mkdir ~/.fonts

# Copy trackpad config+tools from Dropbox and softlink it
cp ~/Dropbox/linux/trackpad/* ~/.trackpad
sudo ln -s ~/.trackpad/52-mytrackpad.conf /usr/share/X11/xorg.conf.d/52-mytrackpad.conf

# Block GUI trackpad settings
gsettings set org.gnome.settings-daemon.plugins.mouse active false
gsettings set org.cinnamon.settings-daemon.plugins.mouse active false

# Copy fonts over and rebuild cache
cp -r ~/Dropbox/linux/fonts/* ~/.fonts
fc-cache -fv

# Enable bitmapped fonts
sudo rm /etc/fonts/conf.d/70-no-bitmaps.conf
sudo ln -s /etc/fonts/conf.avail/70-yes-bitmaps.conf /etc/fonts/conf.d/70-yes-bitmaps.conf

# Copy conky config over and launch it
cp ~/Dropbox/linux/conky/std.conkyrc ~/.conkyrc
conky & >/dev/null 2>&1

# Copy startup link for conky at login
cp ~/Dropbox/linux/startup/* ~/.config/autostart

# 3 Workspaces
gsettings set org.cinnamon.desktop.wm.preferences num-workspaces 3

# Set clock format text
cd ~/.cinnamon/configs/calendar@cinnamon.org
jq '.["use-custom-format"].value="true"|.["custom-format"].value=" %a %b %-e, %-l:%M %p "' 13.json > 13.tmp
mv 13.json 13.sav
mv 13.tmp 13.json
cd

# Set Cinn main menu text
cd ~/.cinnamon/configs/menu@cinnamon.org
jq '.["menu-label"].value="NOCTVA"' 0.json > 0.tmp
mv 0.json 0.sav
mv 0.tmp 0.json
cd

# Remove icons from desktop, put cinnabar at top
gsettings set org.nemo.desktop show-desktop-icons false
gsettings set org.cinnamon panels-enabled "['1:0:top']"

# Turn off system sound effects
gsettings set org.cinnamon.sounds close-enabled false
gsettings set org.cinnamon.sounds login-enabled false
gsettings set org.cinnamon.sounds logout-enabled false
gsettings set org.cinnamon.sounds map-enabled false
gsettings set org.cinnamon.sounds maximize-enabled false
gsettings set org.cinnamon.sounds minimize-enabled false
gsettings set org.cinnamon.sounds plug-enabled false
gsettings set org.cinnamon.sounds switch-enabled false
gsettings set org.cinnamon.sounds tile-enabled false
gsettings set org.cinnamon.sounds unmaximize-enabled false
gsettings set org.cinnamon.sounds unplug-enabled false

# Add record of SMB server to hosts
sudo echo -e "\n\n10.0.1.2     akashica" | sudo tee -a /etc/hosts >/dev/null

# Add SMB server config to home, mnt and fstab
cp ~/Dropbox/linux/fstab/std.smbcreds ~/.smbcreds
chmod 600 ~/.smbcreds
sudo mkdir /mnt/akashic
sudo mkdir /mnt/deepvault
cat ~/Dropbox/linux/fstab/fstab-add | sudo tee -a /etc/fstab >/dev/null

# Reduce swappiness
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf >/dev/null

# Initial run of variety
(variety >/dev/null 2>&1 ) &

# Reboot
echo -n "Press Enter to Reboot . . . "
read answer
sudo reboot

