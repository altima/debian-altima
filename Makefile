ISO_IN := debian-10.8.0-amd64-netinst.iso
ISO_OUT := debian10-altima.iso

all: info

info:
	@echo
	@echo '#########################'
	@echo '# Debain ISO creation'
	@echo '#'
	@echo

download-iso:
	curl -LO# https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/${ISO_IN}
	
build: clean download-iso
	xorriso -osirrox on -indev debian-10.1.0-amd64-netinst.iso  -extract / isofiles/
	chmod +w -R isofiles/install.amd/
	gunzip isofiles/install.amd/initrd.gz
	echo preseed.cfg | cpio -H newc -o -A -F isofiles/install.amd/initrd
	gzip isofiles/install.amd/initrd
	chmod -w -R isofiles/install.amd/

	cd isofiles/
	chmod a+w md5sum.txt
	md5sum `find -follow -type f` > md5sum.txt
	chmod a-w md5sum.txt

	cd ..
	chmod a+w isofiles/isolinux/isolinux.bin
	genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ${ISO_OUT} isofiles

	rm -rf ${ISO_IN}
	rm -rf isofiles/

clean:
	rm -rf *.iso
	rm -rf isofiles/