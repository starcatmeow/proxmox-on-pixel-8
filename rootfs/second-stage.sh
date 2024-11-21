#!/bin/bash
echo Starting second stage
/debootstrap/debootstrap --second-stage
apt install -y network-manager curl
systemctl enable serial-getty@ttyGS0.service
passwd root
echo pixelproxmox > /etc/hostname
