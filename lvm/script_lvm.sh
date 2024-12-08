#!/bin/bash

#creacion de lvm

sudo fdisk /dev/sdc <<EOF
n
p



t
8e

w
EOF

sudo fdisk /dev/sdd <<EOF
n
p



t
8e

w
EOF

sudo fdisk /dev/sde <<EOF
n
p
1

+1G

t
82

w
EOF

sudo wiperfs -a /dev/sdc1
sudo wiperfs -a /dev/sdd1
sudo wiperfs -a /dev/sde1

sudo pvcreate /dev/sdc1
sudo pvcreate /dev/sdd1

sudo vgcreate vg_datos /dev/sdc1
sudo vgcreate vg_temp /dev/sdd1

sudo lvcreate -L +10MB -n lv_docker vg_datos
sudo lvcreate -L +2.5GB -n lv_workareas vg_datos
sudo lvcreate -L +2.5GB -n lv_swap vg_temp


sudo mkfs.ext4 /dev/vg_datos/lv_docker
sudo mkdir -p /var/lib/docker
sudo mount /dev/vg_datos/lv_docker /var/lib/docker

sudo mkswap /dev/vg_temp/lv_swap
sudo swapon /dev/vg_temp/lv_swap
sudo mkswap /dev/sde1
sudo swapon /dev/sde1

sudo mkfs.ext4 /dev/vg_datos/lv_workareas
sudo mkdir -p /work
sudo mount /dev/vg_datos/lv_workareas /work


echo /dev/vg_datos/lv_docker /var/lib/docker ext4 defaults 0 0 | sudo tee -a /etc/fstab
echo /dev/vg_datos/lv_workareas /work ext4 defaults 0 0 | sudo tee -a /etc/fstab
echo /dev/vg_temp/lv_swap none swap sw 0 0 | sudo tee -a /etc/fstab

sudo mount -a
