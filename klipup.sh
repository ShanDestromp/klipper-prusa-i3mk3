#!/bin/sh

VER="$(echo $1 | tr '[A-Z]' '[a-z]')" #lowercase

# THIS PATH MIGHT CHANGE
# Recommend using /dev/serial/by-id/YOUR_DEVICE_HERE
DEV=/dev/ttyACM0 #THIS PATH MIGHT CHANGE

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

./scripts/install-octopi.sh
make menuconfig
make
sudo service klipper stop

make flash FLASH_DEVICE=${DEV}


rm $HOME/klipper
ln -sf `pwd` $HOME/klipper

sudo service klipper restart
