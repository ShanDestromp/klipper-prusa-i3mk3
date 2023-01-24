#!/bin/sh

VER="$(echo $1 | tr '[A-Z]' '[a-z]')" #lowercase

# Recommend using /dev/serial/by-id/YOUR_DEVICE_HERE
DEV=/dev/serial/by-id/usb-Prusa_Research__prusa3d.com__Original_Prusa_i3_MK3_CZPX3118X004XK76866-if00

if [ "$VER" != "prusa" ] && [ "$VER" != "koc" ]
then
	echo "Invalid mode, select 'PRUSA' or 'KOC'"
	exit 1
fi

if [ "$VER" = "prusa" ]
then
	cd ~/POKlipper/
elif [ "$VER" = "koc" ]
then
	cd ~/KOCKlipper
fi

git pull

#./scripts/install-octopi.sh
make menuconfig
make
sudo service klipper stop

make flash FLASH_DEVICE=${DEV}

rm $HOME/klipper
ln -sf `pwd` $HOME/klipper

sudo service klipper restart
