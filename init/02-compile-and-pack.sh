#!/bin/sh
cargo build --release
sudo cp target/aarch64-unknown-linux-musl/release/init ramdisk/new/system/bin/init
cd ramdisk/new
cpio -t < ../unpacked/vendor_ramdisk00 | sudo cpio -o -H newc > ../new_vendor_ramdisk.cpio
cd ..
rm new_vendor_ramdisk.cpio.lz4
lz4 -l new_vendor_ramdisk.cpio
cd ..
mkbootimg --vendor_boot ../out/vendor_boot.img --header_version 4 --vendor_ramdisk ramdisk/new_vendor_ramdisk.cpio.lz4 --vendor_bootconfig ramdisk/unpacked/bootconfig --vendor_cmdline "exynos_drm.load_sequential=1 g2d.load_sequential=1 samsung_iommu_v9.load_sequential=1 swiotlb=noforce disable_dma32=on earlycon=exynos4210,0x10870000 console=ttySAC0,115200 androidboot.console=ttySAC0 printk.devkmsg=on cma_sysfs.experimental=Y cgroup_disable=memory rcupdate.rcu_expedited=1 rcu_nocbs=all swiotlb=1024 cgroup.memory=nokmem sysctl.kernel.sched_pelt_multiplier=4 kasan=off at24.write_timeout=100 log_buf_len=1024K selinux=0 bootconfig"