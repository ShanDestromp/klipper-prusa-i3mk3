#!/bin/sh

SCRIPT=$(readlink -f $0)
SCPATH=`dirname $SCRIPT`

# Recommend using /dev/serial/by-id/YOUR_DEVICE_HERE
DEV=/dev/serial/by-id/usb-Prusa_Research__prusa3d.com__Original_Prusa_i3_MK3_CZPX3118X004XK76866-if00

cd ~/klipper
echo "Backing up .config to .config.old"
mv .config .config.old

sudo service klipper stop

echo "Building Prusa MCU Firmware"
cp $SCPATH/misc/config.prusa ~/klipper/.config

make menuconfig #atmega2650 for Prusa, Linux process for Pi
make clean
make

echo "Flashing Prusa MCU"
make flash FLASH_DEVICE=${DEV}

echo "Building Linux MCU Firmware"
cp $SCPATH/misc/config.linux ~/klipper/.config

make menuconfig #atmega2650 for Prusa, Linux process for Pi
make clean
make

echo "Flashing Linux MCU"
make flash

# Uses local copy of PrusaOwners tram_z script and makes it available to the upstream ver of Klipper
echo "Enabling tram_z.py"
ln -sf $SCPATH/misc/tram_z.py ~/klipper/klippy/extras/tram_z.py

sudo service klipper restart
