# Create Debian Rootfs

debootstrap on Nix has some trouble with path mapping. So must install dependencies manually.

Dependencies for Ubuntu 22.04.4 LTS (Other OS may need different packages):

- debootstrap
- qemu-user-static
- binfmt-support

Then run the following command to create a Debian rootfs:

```sh
sudo ./01-debootstrap.sh
sudo ./02-chroot.sh # optional, enter the chroot environment to do your own configuration
./03-pack.sh # pack the rootfs into ../out/rootfs.tar.gz
```
