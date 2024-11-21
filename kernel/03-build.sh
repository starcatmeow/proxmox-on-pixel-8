#!/bin/sh
BUILD_AOSP_KERNEL=1 ./build_shusky.sh
cp out/shusky/dist/boot.img out/shusky/dist/vendor_kernel_boot.img out/shusky/dist/system_dlkm.img out/shusky/dist/vendor_dlkm.img ../out/
