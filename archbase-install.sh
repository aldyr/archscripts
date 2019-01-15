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

host=
user=
device=

usage() {
    cecho "Usage: archbase-install.sh -h <hostname> -u <username> -d <devicename>" $green
    cecho "eg. archbase-install.sh -h archpc -u desktopuser -d sda" $white
    cecho "<device root drive>: eg. sda" $white
}
while [ "$1" = "" ]; then
    case $1 in
        -h | --host )           shift
                                host=$1
                                ;;
        -u | --user )           shift
                                user=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ -z "$host" ] || [ -z "$user" ] || [ -z "$device" ]; then
    usage
    exit 1
fi

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
if [ -z $host ]; then
    cecho "No computername given. Defaulting to archpc" $magenta
    echo "archpc" > /etc/hostname
    echo "127.0.1.1 archpc.localdomain archpc" >> /etc/hosts
else
    cecho "Set computer name: $host" $white
    echo "$host" > /etc/hostname
    echo "127.0.1.1 $host.localdomain $host" >> /etc/hosts
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
if [ -z $user ]; then
    cecho "No username given, skipping add user" $magenta
else
    useradd -m -g users -G wheel -s /bin/bash $user
    passwd $user
    cecho "Enable group wheel for $user. Please scroll down to find the wheel permissions you need to uncomment" $yellow
    cecho "Enter to continue" $white
    read nothing
    visudo
    if [ -z $device ]; then
        cecho "No device root drive given, skipping bootloader" $magenta
    else
        cecho "Installing bootloader: Assuming MBR configuration for /dev/$device." $green
        pacman -S grub
        echo "GRUB_DISABLE_SUBMENU=y" >> /etc/default/grub
        grub-install --target=i386-pc --recheck /dev/$device
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
fi
cecho "Base Installation done. Exit and Unmount before rebooting" $white
cecho "Ctrl-D, then run umount -R /mnt" $white
cecho "Then run reboot" $white

exit 0
