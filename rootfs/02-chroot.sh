#!/bin/bash
ROOTFS=debian-rootfs
echo Setting up QEMU
cp /usr/bin/qemu-aarch64-static $ROOTFS/usr/bin/
mkdir -p $ROOTFS/usr/libexec
cp -R /usr/libexec/qemu-binfmt $ROOTFS/usr/libexec/qemu-binfmt
echo Chrooting
chroot $ROOTFS qemu-aarch64-static /bin/bash
rm $ROOTFS/usr/bin/qemu-aarch64-static
rm -r $ROOTFS/usr/libexec/qemu-binfmt
