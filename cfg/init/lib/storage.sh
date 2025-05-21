#!/bin/bash

STORAGERAND=MIIJQwIBADANB
STORAGEUNIQ=/init-work/cfg/usr/share/background/blackbird-dark.png


function storage_blackbird_prepare_init_partition_proc() {
    
    if [ -d /dev/proc ];then
        swapoff /dev/proc/swap
        yes | lvremove /dev/proc/*
        yes | vgremove proc
        yes | pvremove /dev/mapper/lvm_root
        cryptsetup luksClose /dev/mapper/lvm_root   
    fi

     if [ -d /dev/data ];then
        yes | lvremove /dev/data/* 
        yes | vgremove data
        yes | pvremove /dev/mapper/lvm_data
        cryptsetup luksClose /dev/mapper/lvm_data   
    fi
}

function storage_blackbird_prepare_moun_partition_proc() {

    umount -R /mnt/boot 2> /dev/null
    umount -R /mnt/home 2> /dev/null
    umount -R /mnt/var/log/audit 2> /dev/null
    umount -R /mnt/var/log 2> /dev/null
    umount -R /mnt/var/tmp 2> /dev/null
    umount -R /mnt/var/lib/libvirt/images 2> /dev/null
    umount -R /mnt/var/lib/libvirt/containers 2> /dev/null
    umount -R /mnt 2> /dev/null
}

## LUKS
function storage_blackbird_formats_luks_partition_keys() {

    if [[ ! -z $DISK_KEYS ]];then

        cryptsetup luksFormat --type luks2 --sector-size 4096 --batch-mode --key-file $STORAGEUNIQ $DISK_KEYS
        echo $STORAGERAND | cryptsetup luksAddKey --key-file $STORAGEUNIQ $DISK_KEYS    

    else
        echo 'No directory keys needed'
    fi
}


function storage_blackbird_formats_luks_partition_root() {  
    cryptsetup luksFormat --type luks2 --sector-size 4096 --batch-mode --key-file $STORAGEUNIQ $DISK_ROOT
    echo $STORAGERAND | cryptsetup luksAddKey --key-file $STORAGEUNIQ $DISK_ROOT    
}


function storage_blackbird_formats_luks_partition_data() {
    cryptsetup luksFormat --type luks2 --sector-size 4096 --batch-mode --key-file $STORAGEUNIQ $DISK_DATA
    echo $STORAGERAND | cryptsetup luksAddKey --key-file $STORAGEUNIQ $DISK_DATA    
}


function storage_blackbird_opening_luks_partition_root() {

    if [ ! -e /dev/mapper/lvm_root ];then
    
        cryptsetup luksOpen $DISK_ROOT --key-file $STORAGEUNIQ  lvm_root 
    fi
}


function storage_blackbird_opening_luks_partition_data() {
    
    if [ ! -e  /dev/mapper/lvm_data ];then
    
        cryptsetup luksOpen $DISK_DATA --key-file $STORAGEUNIQ lvm_data 
    fi
}


## LVM2
function storage_blackbird_created_lvm2_partition_root() {

    if [ ! -d /dev/proc ];then
        pvcreate /dev/mapper/lvm_root 
        vgcreate proc /dev/mapper/lvm_root 
    fi

    if [ ! -e /dev/proc/root ];then

        yes | lvcreate -L 25G proc -n root 
    fi

    if [ ! -e /dev/proc/vars ];then

        yes | lvcreate -L 10G proc -n vars 
    fi

    if [ ! -e /dev/proc/vtmp ];then

        yes | lvcreate -L 1G proc -n vtmp 
    fi

    if [ ! -e /dev/proc/vlog ];then

        yes | lvcreate -L 2.5G proc -n vlog
    fi

    if [ ! -e /dev/proc/vaud ];then

        yes | lvcreate -L 1.5G proc -n vaud
    fi

    if [ ! -e /dev/proc/swap ];then

        yes | lvcreate -l100%FREE proc -n swap
    fi
}


function storage_blackbird_created_lvm2_partition_data() {
    

    if [[ $MODE == "install" ]];then

        pvcreate /dev/mapper/lvm_data 
        vgcreate data /dev/mapper/lvm_data
    fi

    if [ ! -e /dev/data/home ];then

        yes | lvcreate -L 20G data -n home 
    fi

    if [ ! -e /dev/data/pods ];then

        yes | lvcreate -L 30G data -n pods
    fi

    if [ ! -e /dev/data/host ];then

        yes | lvcreate -l 100%FREE data -n host 
    fi
}


function storage_blackbird_formats_lvm2_partition_root() {

    if [[ $MODE == "install" ]];then
        yes | mkfs.vfat -F32 -S 4096 -n BOOT $DISK_BOOT 
    fi
    
    yes | mkfs.ext4 -b 4096 /dev/proc/root 
    
    yes | mkfs.ext4 -b 4096 /dev/proc/vars

    yes | mkfs.ext4 -b 4096 /dev/proc/vlog 

    yes | mkfs.ext4 -b 4096 /dev/proc/vaud 
    
    yes | mkfs.ext4 -b 4096 /dev/proc/vtmp

    swapoff /dev/proc/swap 

    yes | mkswap /dev/proc/swap 
}


function storage_blackbird_formats_lvm2_partition_data() {


    if [[ $MODE == "install" ]];then

        yes | mkfs.ext4 -b 4096 /dev/data/home
        
        yes | mkfs.ext4 -b 4096 /dev/data/pods
        
        yes | mkfs.ext4 -b 4096 /dev/data/host
    fi
}


## MOUNT
function storage_blackbird_mouting_lvm2_partition_root() {

    ## mounting root
    mount /dev/proc/root /mnt


    ## mounting /boot
    if [ ! -d /mnt/boot ];then
        mkdir /mnt/boot 
    fi
    mount -o uid=0,gid=0,fmask=0077,dmask=0077 $DISK_BOOT /mnt/boot 
    

    ## var partition
    if [ ! -d /mnt/var ];then
        mkdir /mnt/var 
    fi
    mount -o defaults,rw,nosuid,nodev,noexec,relatime /dev/proc/vars /mnt/var 


    ## var/tmp partition
    if [ ! -d /mnt/var/tmp ];then
        mkdir /mnt/var/tmp 
    fi
    mount -o rw,nosuid,nodev,noexec,relatime /dev/proc/vtmp /mnt/var/tmp 


    ## var/log partition
    if [ ! -d /mnt/var/log  ];then
        mkdir /mnt/var/log
    fi
    mount -o rw,nosuid,nodev,noexec,relatime /dev/proc/vlog /mnt/var/log 


    ## var/log/audit partition
    if [ ! -d /mnt/var/log/audit  ];then
        mkdir /mnt/var/log/audit 
    fi
    mount -o rw,nosuid,nodev,noexec,relatime /dev/proc/vaud /mnt/var/log/audit


    ## swap partition
    swapon /dev/proc/swap 
}


function storage_blackbird_mouting_lvm2_partition_data() {

    ## mounting /home

    if [ ! -d /mnt/home ];then
        mkdir /mnt/home 
    fi
    mount -o rw,nosuid,nodev,noexec,relatime /dev/data/home /mnt/home 


    ## srv/http/public partition
    if [ ! -d /mnt/var/lib/containers/ ];then
        mkdir /mnt/var/lib/ /mnt/var/lib/containers/
    fi
    mount -o rw,nosuid,nodev,relatime /dev/data/pods /mnt/var/lib/containers/


    ## srv/http/public partition
    if [ ! -d /mnt/lib/libvirt/images/ ];then
        mkdir /mnt/var/lib/libvirt/ /mnt/var/lib/libvirt/images/
    fi
    mount -o rw,nosuid,nodev,relatime /dev/data/host /mnt/var/lib/libvirt/images/
  
}


function setup_storage_blackbird_protocol_fresh() {

    ## preparation
    storage_blackbird_prepare_moun_partition_proc
    storage_blackbird_prepare_init_partition_proc
  
    ## create luks
    storage_blackbird_formats_luks_partition_keys
    storage_blackbird_formats_luks_partition_root
    storage_blackbird_formats_luks_partition_data

    ## opening luks
    storage_blackbird_opening_luks_partition_root
    storage_blackbird_opening_luks_partition_data
    
    
    ## prepare lvm2 
    storage_blackbird_created_lvm2_partition_root
    storage_blackbird_created_lvm2_partition_data

    ## format lvm2 
    storage_blackbird_formats_lvm2_partition_root
    storage_blackbird_formats_lvm2_partition_data

     
    ## mounting lvm2 
    storage_blackbird_mouting_lvm2_partition_root
    storage_blackbird_mouting_lvm2_partition_data 
}


function setup_storage_blackbird_protocol_swipe() {

    ## opening luks
    storage_blackbird_opening_luks_partition_root
    storage_blackbird_opening_luks_partition_data

    ## prepare lvm2 root
    storage_blackbird_formats_lvm2_partition_root

    ## prepare lvm2 data
    storage_blackbird_formats_lvm2_partition_data
}


function setup_storage_blackbird_protocol_reset() {

    ## opening luks
    storage_blackbird_opening_luks_partition_root
    storage_blackbird_opening_luks_partition_data

    ## prepare lvm2 root
    storage_blackbird_formats_lvm2_partition_root
    storage_blackbird_mouting_lvm2_partition_root
    

    ## prepare lvm2 data
    storage_blackbird_mouting_lvm2_partition_data
}


function setup_storage_layout_installations() {

    genfstab -U /mnt/ > /mnt/etc/fstab 
    echo 'tmpfs     /tmp        tmpfs   defaults,rw,nosuid,nodev,noexec,relatime,size=1G    0 0' >> /mnt/etc/fstab
    echo 'tmpfs     /dev/shm    tmpfs   defaults,rw,nosuid,nodev,noexec,relatime,size=1G    0 0' >> /mnt/etc/fstab
}