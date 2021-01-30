# Klipper configs for a stock Prusa i3 MK3

Forked from [this repo](https://github.com/Frix-x/klipper-prusa-i3mk3s) by Frix-x for their MK3S, modified and tweaked to suit my MK3 with further refinements to suit my personal style.  This repo is mostly maintained as an offsite-backup of my own configuration and isn't meant to be a drop-in replacement for yours, however it shouldn't take much work to suit if you intend.

# Usage:

`git clone https://github.com/ShanDestromp/klipper-prusa-i3mk3.git`

`ln -s ./klipper-prusa-i3mk3/printer.conf ./printer.conf`

`ln -s ./klipper-prusa-i3mk3/klipup.sh ./klipup.sh` (if you wish to use my klipper-update script, see below for details)

At the bare minimum, update [klipper-prusa-i3mk3/hardware/printer.cfg](https://github.com/ShanDestromp/klipper-prusa-i3mk3/blob/main/hardware/printer.cfg) and change the serial device used to match your system.  Any other hardware changes (eg using a different ABL probe) should be adjusted in the appropriate file as well.

`systemctl restart klipper`

Check `/tmp/klippy.log` for any errors.

Once your system is running I recommend performing your own bed-mesh-levling and updating [printer.cfg](https://github.com/ShanDestromp/klipper-prusa-i3mk3/blob/main/printer.cfg) as my bed's flatness is unlikely to match yours.  PID tuning your hotend and heatbed is also recommended, update [hardware/extruder.cfg](https://github.com/ShanDestromp/klipper-prusa-i3mk3/blob/main/hardware/extruder.cfg) and [hardware/heated-bed.cfg](https://github.com/ShanDestromp/klipper-prusa-i3mk3/blob/main/hardware/heated-bed.cfg) respectively.

# Slicer settings:

I've tried to keep everything I can contained within the klipper configuration files, however for pre-heat and ABL routines to work 'out of the box' you'll need to modify your slicers Start and End code to match.  I've included a config-bundle for PrusaSlicer (as [PrusaSlicerConfig.ini](https://github.com/ShanDestromp/klipper-prusa-i3mk3/blob/main/PrusaSlicerConfig.ini)) that contains all of my print and filament settings (as of it's last commit).  This can be directly imported but if you're using a version less than 2.3 alpha4 it may have unintended side effects.

## Start G-code:
  ````
START_PRINT

M140 S[first_layer_bed_temperature] ; set bed temp
M190 S[first_layer_bed_temperature] ; wait for bed temp
M109 S[first_layer_temperature] ; wait for extruder temp

MBL

{if filament_type[0]=~/.*(PETG|PET).*/}SET_GCODE_OFFSET Z=0.1 ; PETG needs to be adjusted{endif}

PRIME_LINE

; Don't change E values below. Excessive value can damage the printer.
{if print_settings_id=~/.*(DETAIL @MK3|QUALITY @MK3).*/}M907 E430 ; set extruder motor current{endif}
{if print_settings_id=~/.*(SPEED @MK3|DRAFT @MK3).*/}M907 E538 ; set extruder motor current{endif}`
````

## End G-code:
````
{if print_settings_id=~/.*(DETAIL @MK3|QUALITY @MK3|@0.25 nozzle MK3).*/}M907 E538 ; reset extruder motor current{endif}
END_PRINT
````

### Explanation:

#### Start Code:
`START_PRINT`, `MBL`, `PRIME_LINE` and `END_PRINT` are macros (see appropriate entries in [macros/print-start_stop.cfg](https://github.com/ShanDestromp/klipper-prusa-i3mk3/blob/main/macros/print-start_stop.cfg)).  `START_PRINT` executes by performing a non-mesh home and then preheating the bed and extruder to 60/190 respectively *if they're already above this they'll be left as is*.  PrusaSlicer-variables set the "real" temperatures for printing.  `MBL` performs a mesh-bed-level, then a Z offset is made (if printing with PET/PETG).  `PRIME_LINE` does as it's named (Prusa style, lower-left to lower-center).  Prusa-recommended adjustments to the extruder motor current is made based on printing profile.

#### End Code:
Resets the motor-current (if needed) and then executes the `END_PRINT` macro which essentially sets everything to neutral, lifts the Z out of the way and moves the bed to the front (basically to make it easier to get your parts off).

## Misc:
Support for filament runout (using the stock MK3 sensor) as well as M600 filament changes work well, although the filament-sensor has the same issues as with Prusa firmware (occasionally not being able to 'read' some filament colors, particularly translucent ones).  If the filament sensor is problematic for you, commenting out the `filament_switch_sensor` block in [hardware/prusa.cfg](https://github.com/ShanDestromp/klipper-prusa-i3mk3/blob/main/hardware/prusa.cfg) will disable it.

## Klipper updates with [klipup.sh](https://github.com/ShanDestromp/klipper-prusa-i3mk3/blob/main/klipup.sh):
A rudimentery bash script I use to update my klipper install in one command.  Has support for the source (KevinOConnor) as well as the PrusaOwners fork.  Be forewarned that at present, the PrusaOwners fork is significantly behind and many of the macros used in this repo **will not work**.  That said, the PrusaOwners fork has support for things like Tram_Z.  At present I'm using Kevins without any Prusa-specific difficulties.

### `klipup.sh` usage:

This assumes that your local copy is stored in `POKlipper` (for PrusaOwners fork) or `KOCKlipper` for Kevins.

`./klipup.sh koc` or `./klipup.sh prusa` depending on which repo you're using.

The script will then move to the appropriate directory, pull the latest version, build the firmware and flash it to your printer.  It will also ensure that a symlink is made from your built firmware to `~/klipper` allowing you to swap between forks without manually adjusting.

I heavily recommend editing the script to modify the `DEV` line to match your printers connection in `/dev/serial/by-id/` instead of `/dev/ttyACM0` as `ttyACM0` might not always point to the correct device.

## Other:
I've started working on adding a BME280 sensor to monitor the ambient temperature and humidity of my build environment.  At the moment I don't have it currently working within klipper so that section is disabled.
