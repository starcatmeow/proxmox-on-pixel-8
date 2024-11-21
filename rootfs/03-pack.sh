#!/bin/bash
sudo tar zcf ../out/rootfs.tar.gz debian-rootfs
sudo chown $USER:$USER ../out/rootfs.tar.gz