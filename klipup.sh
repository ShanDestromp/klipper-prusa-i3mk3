#!/bin/sh

SCRIPT=$(readlink -f $0)
SCPATH=`dirname $SCRIPT`

# Recommend using /dev/serial/by-id/YOUR_DEVICE_HERE
DEV=/dev/serial/by-id/usb-Prusa_Research__prusa3d.com__Original_Prusa_i3_MK3_CZPX3118X004XK76866-if00

cd ~/klipper

git pull

#./scripts/install-octopi.sh
make menuconfig
make
sudo service klipper stop

make flash FLASH_DEVICE=${DEV}

# Uses local copy of PrusaOwners tram_z script and makes it available to the upstream ver of Klipper
ln -s $SCPATH/misc/tram_z.py ~/klipper/klippy/extras/tram_z.py

sudo service klipper restart
