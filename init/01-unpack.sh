#!/bin/bash
sudo rm -rf ramdisk
mkdir ramdisk
unpack_bootimg --boot_img ../pixel-stock-image/vendor_boot.img --out ramdisk/unpacked
cd ramdisk/unpacked
mv vendor_ramdisk00 vendor_ramdisk00.lz4
lz4 -d vendor_ramdisk00.lz4
cd ..
mkdir new
cd new
sudo cpio -i < ../unpacked/vendor_ramdisk00
