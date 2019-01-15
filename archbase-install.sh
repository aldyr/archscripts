#!/bin/bash
#
#
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'


cecho ()                     # Color-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{
local default_msg="No message passed."
                             # Doesn't really need to be a local variable.

message=${1:-$default_msg}   # Defaults to default message.
color=${2:-$black}           # Defaults to black, if not specified.

  echo -e "$color"
  echo "$message"
  tput sgr0

  return
}  

if [ -z $1 ]; then
    cecho "Usage: arch-base-config.sh <computername> <username> <device root drive>" $green
    cecho "eg. arch-base-config.sh archpc desktopuser sda" $white
    cecho "<device root drive>: eg. sda" $white
else
    cecho "This script configures a base install of arch" $green
    cecho "Assumptions are:" $white
    cecho "1. Partitioning is not using encryption or LVM" $white
    cecho "2. base and base-devel packages installed" $white
    cecho "3. fstab already generated" $white
    cecho "4. chroot into /mnt folder, installed git and downloaded this script" $white
    cecho "5. If any of this is wrong, please Ctrl-C, cancel this script, and proceed manually." $white
    cecho "Enter to continue or Ctrl-c to cancel" $white
    read nothing
    cecho "Configuring region info: english us keyboard, joburg timezone" $green
    ln -sf /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime
    hwclock --systohc
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "KEYMAP=us" > /etc/vconsole.conf
    if [ -z $1 ]; then
        cecho "No computername given. Defaulting to archpc" $magenta
        echo "archpc" > /etc/hostname
        echo "127.0.1.1 archpc.localdomain archpc" >> /etc/hosts
    else
        cecho "Set computer name: $1" $white
        echo "$1" > /etc/hostname
        echo "127.0.1.1 $1.localdomain $1" >> /etc/hosts
    fi
    
    cecho "Installing network manager" $green
    tput sgr0
    pacman -S networkmanager
    systemctl enable NetworkManager
    cecho "Default init cpio. Does not support encrypted partitions or lvm" $red
    mkinitcpio -p linux
    cecho "Set root password" $yellow
    passwd
    cecho "Installing minimal terminal tools: sudo git rsync wget curl inxi screen vim zsh pass openssh samba exfat-utils ntfs-3g" $green
    cecho "Enter to continue" $white
    read nothing
    pacman -S sudo git rsync wget curl inxi screen vim zsh pass openssh samba exfat-utils ntfs-3g
    if [ -z $2 ]; then
        cecho "No username given, skipping add user" $magenta
    else
        useradd -m -g users -G wheel -s /bin/bash $2
        passwd $2
        cecho "Enable group wheel for $2. Please scroll down to find the wheel permissions you need to uncomment" $yellow
        cecho "Enter to continue" $white
        read nothing
        visudo
        if [ -z $3 ]; then
            cecho "No device root drive given, skipping bootloader" $magenta
        else
            cecho "Installing bootloader: Assuming MBR configuration for /dev/$3." $green
            pacman -S grub
            echo "GRUB_DISABLE_SUBMENU=y" >> /etc/default/grub
            grub-install --target=i386-pc --recheck /dev/$3
            grub-mkconfig -o /boot/grub/grub.cfg
        fi
    fi
    cecho "Base Installation done. Exit and Unmount before rebooting" $white
    cecho "Ctrl-D, then run umount -R /mnt" $white
    cecho "Then run reboot" $white
fi

exit 0
