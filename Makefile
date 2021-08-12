SHELL:=/bin/bash
IMAGE:=./2021-05-07-raspios-buster-arm64-lite.zip
DOWNLOAD_LINK:=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-05-28/2021-05-07-raspios-buster-arm64-lite.zip

# TODO: These values should be derived from user input
WRITABLE_BLOCK:=/dev/sdc
BOOT_SECTOR:=/dev/sdc1
FS_SECTOR:=/dev/sdc2
NAME:=main

get-image:
ifneq (,$(wildcard $(IMAGE)))
	@echo "Image has already been downloaded."
else
	@echo "Downloading Raspberry Pi OS for arm64"
	curl -o $(IMAGE) $(DOWNLOAD_LINK)
endif
	@echo "Getting sha256sum and comparing..."
	@curl -so image.sha256 $(DOWNLOAD_LINK).sha256
	@export DIFF=`sha256sum $(IMAGE) | diff image.sha256 -`
ifneq ($(DIFF),)
	$(error Bad sha256sum, aborting operation)
else
	@echo "Image is healthy!"
	@rm image.sha256
endif

write-to-usb: 
ifeq ($(WRITABLE_BLOCK),) 
	# NOTE: This is not fully functional yet, not sure why
	@read -p "Remove your flash drive, and press enter to continue"
	@lsblk -p > current-blocks
	@read -p "Insert your writeable drive, and press enter to continue"
	@lsblk -p | diff current-blocks - | grep disk | awk '{print $$2}' > block.txt
	@export BLOCK=`cat block.txt`
	$(error No USB detected, wait a moment after plugging in and try again)
else
	@read -p "the memory block to be modified is $(WRITABLE_BLOCK), ensure this is the drive you wish to write to and press enter to continue"
	@unzip -p $(IMAGE) | sudo dd of=$(WRITABLE_BLOCK) bs=4M conv=fsync status=progress
	@rm block.txt current-blocks
endif

prep-boot-sector:

	@sudo mkdir -p /mnt
	@sudo mount $(BOOT_SECTOR) /mnt
	@sleep 1
	@sudo bash -c "echo cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory >> /mnt/cmdline.txt"
	@sudo touch /mnt/ssh
	@sudo umount $(BOOT_SECTOR)

prep-fs-sector:

	@sudo mkdir -p /mnt
	@sudo mount $(FS_SECTOR) /mnt
	@sleep 1
	# This is not functional yet, defaults to env
	@echo "Enter a hostname: "; \
	read NAME; \
	sudo bash -c "echo $(NAME) > /mnt/etc/hostname"

#TODO: write into .bashrc that runs the following commands if iptables is not legacy:
#sudo iptables -F
#sudo update-alternatives --set iptables /usr/sbin/iptables-legacy 
#sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy 
#sudo reboot
	@sudo umount $(FS_SECTOR)



