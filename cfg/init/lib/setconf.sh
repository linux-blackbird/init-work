#!/bin/bash

function prepare_configuration_blackbird_basic() {

    genfstab -U /mnt/ > /mnt/etc/fstab
 
    echo 'tmpfs     /tmp        tmpfs   defaults,rw,nosuid,nodev,noexec,relatime,size=1G    0 0' >> /mnt/etc/fstab
    echo 'tmpfs     /dev/shm    tmpfs   defaults,rw,nosuid,nodev,noexec,relatime,size=1G    0 0' >> /mnt/etc/fstab

    cp /etc/systemd/network/* /mnt/etc/systemd/network/
    cp -fr $(pwd)/init-work/cfg/* /mnt/
    cp -f  $(pwd)/init-work/env /mnt/init/env/data 

}


function install_configuration_blackbird_basic() {

    git clone https://github.com/linux-blackbird/podlet.git /tmp/script
    git clone https://github.com/linux-blackbird/conf.git /etc/skel/.config
    git clone https://github.com/linux-blackbird/login.git /usr/share/sddm/themes/
    git clone https://github.com/linux-blackbird/themes.git /usr/share/themes/blackbird


    ## podlet
    chmod +x /tmp/script/* 
    cp /tmp/script/* /usr/bin


    ## skell
    mkdir /etc/skel/.local &&  mkdir /etc/skel/.local/share/
    git clone https://github.com/linux-blackbird/linker.git /etc/skel/.local/share/applications


    mkdir /etc/skel/.themes && mkdir /etc/skel/.icons
    sudo cp -r /usr/share/themes/blackbird /etc/skel/.themes/
    sudo cp -r /usr/share/icons/Papirus-Dark /etc/skel/.icons/


    echo $HOSTNAMED > /etc/hostname

    ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime 

    hwclock --systohc 

    timedatectl set-ntp true 

    printf "en_US.UTF-8 UTF-8\nen_US ISO-8859-1" >> /etc/locale.gen 

    locale-gen && locale > /etc/locale.conf 

    sed -i '1s/.*/'LANG=en_US.UTF-8'/' /etc/locale.conf 

    echo 'EDITOR="/usr/bin/nvim"' >> /etc/environment 
}


function register_user_masters_blackbird_basic() {

    shadow='$6$RFZDrC7V2WNkSHBG$JRGbBdl3hAcn4nn85/uAe5q8bz./ieEML/rU34ZQGoptw9ZL8E29ohIfC9wx.OgpgEIASdhGKFVbLGPBz.Jes1'
    echo 'h3x0r ALL=(ALL:ALL) ALL' > /etc/sudoers.d/00_lektor

    mkdir /opt/rsyslog
    useradd -d /opt/rsyslog -p $shadow h3x0r
    chown h3x0r:h3x0r /opt/rsyslog
    usermod -a -G wheel h3x0r
}


function register_user_vhosted_blackbird_basic() {

    shadow='$6$RFZDrC7V2WNkSHBG$JRGbBdl3hAcn4nn85/uAe5q8bz./ieEML/rU34ZQGoptw9ZL8E29ohIfC9wx.OgpgEIASdhGKFVbLGPBz.Jes1'

    useradd -d /var/lib/libvirt/images/ -p $shadow virsz
    setfacl -Rm u:virsz:rwx /var/lib/libvirt/images/
    usermod -a -G libvirt virsz
}


function register_user_podlets_blackbird_basic() {

    shadow='$6$RFZDrC7V2WNkSHBG$JRGbBdl3hAcn4nn85/uAe5q8bz./ieEML/rU34ZQGoptw9ZL8E29ohIfC9wx.OgpgEIASdhGKFVbLGPBz.Jes1'

    useradd -d /var/lib/containers/ -p $shadow pods
    setfacl -Rm u:pods:rwx /var/lib/containers/
}


function register_user_adminer_blackbird_basic() {
    shadow='$6$RFZDrC7V2WNkSHBG$JRGbBdl3hAcn4nn85/uAe5q8bz./ieEML/rU34ZQGoptw9ZL8E29ohIfC9wx.OgpgEIASdhGKFVbLGPBz.Jes1'
    useradd -m -p $shadow lektor
}


