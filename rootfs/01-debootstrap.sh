#!/bin/bash
ROOTFS=debian-rootfs
echo Removing $ROOTFS if exists
rm -rf $ROOTFS
debootstrap --foreign --arch arm64 stable $ROOTFS http://deb.debian.org/debian/ 
echo Creating system_dlkm, vendor_dlkm, system, vendor folders
cd $ROOTFS
mkdir system_dlkm vendor_dlkm system vendor
cd ..
echo Setting up QEMU
cp /usr/bin/qemu-aarch64-static $ROOTFS/usr/bin/
mkdir -p $ROOTFS/usr/libexec
cp -R /usr/libexec/qemu-binfmt $ROOTFS/usr/libexec/qemu-binfmt
cp second-stage.sh $ROOTFS
echo Chrooting
chroot $ROOTFS qemu-aarch64-static /bin/bash /second-stage.sh
rm $ROOTFS/second-stage.sh $ROOTFS/usr/bin/qemu-aarch64-static
rm -r $ROOTFS/usr/libexec/qemu-binfmt
