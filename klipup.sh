#!/bin/sh
cd ~/klipper/ 
git pull 
./scripts/install-octopi.sh 
make menuconfig 
make
sudo service klipper stop 
make flash FLASH_DEVICE=/dev/serial/by-id/usb-Prusa_Research__prusa3d.com__Original_Prusa_i3_MK3_CZPX3118X004XK76866-if00
#make flash FLASH_DEVICE=/dev/serial0
sudo service klipper restart
