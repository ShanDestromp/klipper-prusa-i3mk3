#!/bin/sh

VER="$(echo $1 | tr '[A-Z]' '[a-z]')" #lowercase

#KLIPPY_USER=$USER

#KLIPPY_EXEC=$HOME/klippy-env/bin/python

#KLIPPY_ARGS="$HOME/$VER/klippy/klippy.py /home/pi/printer.cfg -l /tmp/klippy.log"


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
make flash FLASH_DEVICE=/dev/serial/by-id/usb-Prusa_Research__prusa3d.com__Original_Prusa_i3_MK3_CZPX3118X004XK76866-if00

rm $HOME/klipper
ln -sf `pwd` $HOME/klipper

sudo service klipper restart
