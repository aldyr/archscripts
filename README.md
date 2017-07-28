# archscripts
Arch linux install scripts
This script is meant to be run after the arch-chroot step. You will need to do the hard drive partitioning and filesystem creation manually. Once you have chrooted into the pacstrap'd `/mnt` folder. Do the following steps: 

1. `cd /root`
2. Install git with `pacman -S git` 
3. `git clone https://github.com/aldyr/archscripts.git`
4. `cd archscripts`
5. Make script executable with `chmod u+x archbase.sh`
6. Run the script without parameters to show options `./archbase.sh`
7. You need to know: computername eg. archpc, normal user name eg. homer, and hard drive device eg. sda
8. I will run it as follows: `./archbase.sh archpc homersimpson sda`
9. Follow the prompts and reboot when done
