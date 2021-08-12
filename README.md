# Project DAISY

This is my first attempt at making it as easy as possible to build a K3s cluster out of whatever someone happens to have available. The initial project is focused around the Raspberry Pi 4, however I aspire to add other low-power devices to the project as well, such as: Android smartphones, Mac Minis, Ultrabooks... basically anything that you might have laying around your house. 

**NOTE: This is very much a work in progress and I do not guarantee the functionality of anything hosted in this repository!**

## Usage

At the moment, the included Makefile is a collection of helper scripts to write a USB with an ARM64 version of Raspbian, and then make a few tweaks to the boot sector and file system. These scripts are by no means complete, but in the name of time management I'm temporarily shelving this aspect of the project and moving towards getting my own cluster successfully up and running.

## Makefile Commands

### get-image
Pulls the image pointed at by the DOWNLOAD_LINK constant (if it doesn't currently exist in the directory) as well as the sha256sum and compares the result to confirm image health

### write-to-usb
Acknowledges the insertion of a USB drive and writes the aforementioned image to it.
At the moment, it relies on the WRITABLE_BLOCK variable to determine where to write to.

### prep-boot-sector
Mounts the partition set as the BOOT_SECTOR variable, adds some control group values to the boot sector and enables ssh for headless interaction.

### prep-fs-sector
Sets the hostname to a value defined in the environment to prevent ambiguity between multiple raspberrypi hosts that may exist on the network. 
