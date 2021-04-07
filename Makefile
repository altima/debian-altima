ISO_IN := debian-10.9.0-amd64-netinst.iso
ISO_OUT := debian10-altima.iso

all: info build clean

info:
	@echo
	@echo '#########################'
	@echo '# Debain ISO creation'
	@echo '#'
	@echo

download-iso:
	curl -LO# http://debian-cd.repulsive.eu/current/amd64/iso-cd/${ISO_IN}
	
build: clean download-iso
	xorriso -osirrox on -indev ${ISO_IN}  -extract / isofiles/
	
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

clean:
	rm -rf ${ISO_IN}
	rm -rf isofiles/

create: build clean