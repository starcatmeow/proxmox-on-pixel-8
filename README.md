# Proxmox on Pixel 8

This project aims to run Proxmox on Pixel 8. Full log is [here](https://www.linkedin.com/pulse/proxmox-ve-google-pixel-phone-dongruixuan-li-qmnxc).

## Environment setup

Tested on Ubuntu 22.04.4 LTS on WSL2.

For all steps except Debian rootfs building, you can execute `nix-shell` to get the environment. Before that, you need to install Nix package manager. You can follow the instructions on the [official website](https://nixos.org/download/).

## Build steps

0. Download factory image for Pixel 8 from [Google](https://developers.google.com/android/images#shiba), and extract vendor.img, vendor_boot.img to the pixel-stock-image folder.
1. Build kernel by following [kernel/README.md](kernel/README.md).
2. Build init by following [init/README.md](init/README.md).
3. Pack DLKM modules by following [dlkm/README.md](dlkm/README.md).
4. Create Debian rootfs by following [rootfs/README.md](rootfs/README.md).

## Flash steps

1. Flash a userdebug version of AOSP 14.0 on flash.android.com, so later can enter adb root
2. Follow [LineageOS instructions](https://wiki.lineageos.org/devices/shiba/install/#) until gets into the recovery mode.
3. Enable ADB in recovery.
4. Run `adb shell` to obtain the shell, then run `mkfs.ext4 /dev/block/sda34` (may differ from this) to format the user data partition.
5. Mount the user data partition by running `mount /dev/block/sda34 /mnt/user`.
6. Push out/dlkm.tar.gz and out/rootfs.tar.gz to /mnt/user by using `adb push <filename> /mnt/user/`.
7. Change directory to /mnt/user, then run `tar xzf dlkm.tar.gz` and `tar xzf rootfs.tar.gz` to unpack the files.
8. Reboot to bootloader, then flash boot.img, vendor_kernel_boot.img and vendor_boot.img in the out folder.
9. Reboot to recovery mode, now should be able to log in via USB serial.
