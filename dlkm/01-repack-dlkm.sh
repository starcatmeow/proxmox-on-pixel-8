#!/bin/bash
mkdir system_dlkm
mkdir vendor_dlkm
mkdir vendor
sudo mount -o ro ../out/system_dlkm.img system_dlkm
sudo mount -o ro ../out/vendor_dlkm.img vendor_dlkm
sudo mount -o ro ../pixel-stock-image/vendor.img vendor
mkdir dlkm
cd dlkm
sudo cp -R ../system_dlkm .
sudo cp -R ../vendor_dlkm .
sudo mkdir vendor
sudo cp -R ../vendor/firmware ./vendor/
sudo mkdir -p system/lib
sudo ln -s /system_dlkm/lib/modules system/lib/modules
cd ..
sudo umount system_dlkm vendor_dlkm vendor
rm -r system_dlkm vendor_dlkm vendor
sudo tar zcf dlkm.tar.gz dlkm
sudo rm -r dlkm
sudo chown $USER:$USER dlkm.tar.gz
mv dlkm.tar.gz ../out/