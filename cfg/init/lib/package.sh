#!/bin/bash


MAIN_KERNELS_PACKAGE="linux-hardened linux-firmware mkinitcpio intel-ucode base base-devel bubblewrap-suid"
MAIN_NETWORK_PACKAGE="openssh"
MAIN_SECURED_PAKCAGE="firewalld tang apparmor libpwquality nftables clevis mkinitcpio-nfs-utils luksmeta libpam-google-authenticator polkit gnome-keyring libsecret seahorse keepassxc"
MAIN_STORAGE_PACKAGE="xfsprogs lvm2"
MAIN_TUNNING_PACKAGE="reflector tuned tuned-ppd irqbalance"
MAIN_UTILITY_PACKAGE="git less btop qrencode audacity kitty btop mpd mpc xfmpc hugo obsidian evolution gnome-calendar homebank gnome-calculator blender scenarist dbeaver"
MAIN_DEVELOP_PACKAGE="neovim"
MAIN_BACKUPS_PACKAGE="rsync grsync"
MAIN_AUDITOR_PACKAGE=""
MAIN_SYSTEMS_PACKAGE="pipewire pipewire-pulse pipewire-jack wireplumber pavucontrol flatpak gnome-software"
MAIN_SERVICE_PACKAGE="qemu-desktop openbsd-netcat libvirt virt-manager podman crun fuse-overlayfs podman-desktop podman-docker podman-compose"
MAIN_OFFICES_PACKAGE="hugo go obsidian"
MAIN_BROWSER_PACKAGE=""
MAIN_DESKTOP_PACKAGE="uwsm hyprland hyprpolkitagent hypridle hyprlock xdg-desktop-portal-hyprland qt5-wayland qt6-wayland ttf-jetbrains-mono-nerd ttf-droid mako waybar wofi wl-clipboard cliphist mailcap sddm papirus-icon-theme nautilus nautilus-image-converter seahorse-nautilus sushi"
MAIN_VARIANT_MUEDIAS=""
MAIN_PROFILE_DEVELOP=""
MAIN_PROFILE_SUPPORT=""


AURS_KERNELS_PACKAGE=""
AURS_NETWORK_PACKAGE=""
AURS_SECURED_PAKCAGE="mkinitcpio-clevis-hook aide"
AURS_STORAGE_PACKAGE=""
AURS_TUNNING_PACKAGE=""
AURS_UTILITY_PACKAGE="visual-studio-code-bin google-chrome figma-linux"
AURS_DEVELOP_PACKAGE=""
AURS_BACKUPS_PACKAGE=""
AURS_AUDITOR_PACKAGE=""
AURS_SYSTEMS_PACKAGE=""
AURS_SERVICE_PACKAGE=""
AURS_OFFICES_PACKAGE=""
AURS_BROWSER_PACKAGE=""
AURS_DESKTOP_PACKAGE="hyprshot"
AURS_PROFILE_MUMEDIA=""
AURS_PROFILE_DEVELOP=""
AURS_PROFILE_SUPPORT=""


### INSTALLATION
function install_package_main_blackbird_basics() {

    pacstrap /mnt/  $MAIN_KERNELS_PACKAGE $MAIN_SECURED_PAKCAGE $MAIN_NETWORK_PACKAGE $MAIN_STORAGE_PACKAGE $MAIN_TUNNING_PACKAGE \
                    $MAIN_UTILITY_PACKAGE $MAIN_DEVELOP_PACKAGE $MAIN_SERVICE_PACKAGE $AURS_AUDITOR_PACKAGE $MAIN_DESKTOP_PACKAGE \
                    $MAIN_SYSTEMS_PACKAGE $MAIN_OFFICES_PACKAGE $MAIN_BROWSER_PACKAGE $MAIN_AUDITOR_PACKAGE $MAIN_BACKUPS_PACKAGE


    git clone https://github.com/linux-blackbird/login  /mnt/usr/share/sddm/themes/login
    sudo git clone https://github.com/linux-blackbird/themes /mnt/usr/share/themes/blackbird


    git clone https://github.com/linux-blackbird/podlet.git /tmp/script
    chmod +x /tmp/script/* 
    cp /tmp/script/* /mnt/usr/bin


    git clone https://github.com/linux-blackbird/conf.git /mnt/etc/skel/.config
    mkdir /mnt/etc/skel/.local  &&  mkdir /mnt/etc/skel/.localshare/
    git clone https://github.com/linux-blackbird/linker.git /mnt/etc/skel/.local/share/applications
}


function install_package_main_blackbird_variant() {


    if [[ $VARIANT == "multimedia" ]];then
        pacstrap /mnt/  $MAIN_PROFILE_MEDIAS
    fi

    if [[ $VARIANT == "development" ]];then
        pacstrap /mnt/  $MAIN_PROFILE_DEVELS
    fi

    if [[ $VARIANT == "multimedia" ]];then
        pacstrap /mnt/  $MAIN_PROFILE_SUPPOR
    fi
}


function install_package_aurs_blackbird_basics() {

    ## open user permision
    echo 'h3x0r ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/00_lektor &&


    ## aur package manager
    sudo -H -u h3x0r /bin/bash -c "git clone https://aur.archlinux.org/yay /tmp/yay" &&
    echo 'yay clone'
    sleep 10

    sudo -H -u h3x0r /bin/bash -c "makepkg -sric --dir /tmp/yay --noconfirm" &&
    echo 'yay install'
    sleep 10

    ## register gpg keys
    sudo -H -u h3x0r /bin/bash -c "gpg --recv-keys 2BBBD30FAAB29B3253BCFBA6F6947DAB68E7B931" &&
    

    ## install aur package
    sudo -H -u h3x0r /bin/bash -c "yay -S   $AURS_KERNELS_PACKAGE $AURS_SECURED_PAKCAGE $AURS_NETWORK_PACKAGE $AURS_STORAGE_PACKAGE $AURS_TUNNING_PACKAGE \
                                            $AURS_UTILITY_PACKAGE $AURS_DEVELOP_PACKAGE $AURS_SERVICE_PACKAGE $AURS_AUDITOR_PACKAGE $AURS_DESKTOP_PACKAGE \
                                            $MAIN_SYSTEMS_PACKAGE $AURS_OFFICES_PACKAGE $AURS_BROWSER_PACKAGE $AURS_AUDITOR_PACKAGE $AURS_BACKUPS_PACKAGE --noconfirm" &&


    ## close user permision
    echo 'h3x0r ALL=(ALL:ALL) ALL' > /etc/sudoers.d/00_lektor
}


function install_package_aurs_blackbird_variant() {

    ## open user permision
    echo 'h3x0r ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/00_lektor


    ## install aur package
    if [[ $VARIANT == "multimedia" ]];then

         sudo -H -u h3x0r /bin/bash -c "yay  -S $AURS_PROFILE_MUMEDIA --noconfirm"
    fi

    if [[ $VARIANT == "development" ]];then

        sudo -H -u h3x0r /bin/bash -c "yay  -S $AURS_PROFILE_DEVELOP --noconfirm"
    fi

    if [[ $VARIANT == "multimedia" ]];then

        sudo -H -u h3x0r /bin/bash -c "yay  -S $AURS_PROFILE_SUPPORT --noconfirm"
    fi

    ## close user permision
    echo 'h3x0r ALL=(ALL:ALL) ALL' > /etc/sudoers.d/00_lektor
}



### CONFIGURATION
function config_package_pack_blackbird_kernels() {

    echo "cryptdevice=UUID=$(blkid -s UUID -o value $DISK_ROOT):crypto root=/dev/proc/root" > /etc/cmdline.d/01-boot.conf 
    echo "data UUID=$(blkid -s UUID -o value $DISK_DATA) none" >> /etc/crypttab 
    mv /boot/intel-ucode.img /boot/vmlinuz-linux-hardened /boot/kernel 
    rm /boot/initramfs-* 

    if [[ $MODE == "install" ]];then
        bootctl --path=/boot/ install 
    fi

    mkinitcpio -P
}


function config_package_pack_blackbird_network() {
    systemctl enable sshd 
    systemctl enable systemd-networkd.socket
    systemctl enable systemd-resolved

    sudo ln -s /usr/lib/seahorse/ssh-askpass /usr/lib/ssh/ssh-askpass

    systemctl --global enable gnome-keyring-daemon.socket
    systemctl --global enable  gcr-ssh-agent.socket
}


function config_package_pack_blackbird_secured() {

    ## firewalld configuration
    systemctl enable firewalld 
    systemctl enable apparmor.service 

    ## tang server
    systemctl enable tangd.socket
   

    ## clevis kernel parameter
    systemctl enable clevis-luks-askpass.path
    echo "ip=$IPADDRRES::10.10.1.1:255.255.255.0::eth0:none nameserver=10.10.1.1" > /etc/cmdline.d/06-nets.conf
    mkinitcpio -P

    ## clevis register storage
    clevis luks bind -y -k /usr/share/background/blackbird-dark.png -d $DISK_ROOT sss '{"t": 1, "pins": {"tang": [ {"url": "http://10.10.1.2:7500"}, {"url": "http://10.10.1.22:7500"}, {"url": "http://10.10.1.23:7500"} ]}}'
    clevis luks bind -y -k /usr/share/background/blackbird-dark.png -d $DISK_DATA sss '{"t": 1, "pins": {"tang": [ {"url": "http://10.10.1.2:7500"}, {"url": "http://10.10.1.22:7500"}, {"url": "http://10.10.1.23:7500"} ]}}'
}


function config_package_pack_blackbird_desktop() {
    systemctl --global enable hypridle.service
    systemctl --global enable hyprpolkitagent
    systemctl --global enable waybar

    sudo systemctl enable sddm

}


function config_package_pack_blackbird_storage() {
    echo 'no package registered'
}


function config_package_pack_blackbird_tunning() {
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/backupmirror 
    systemctl enable tuned
    systemctl enable irqbalance.service
}


function config_package_pack_blackbird_utility() {
    sudo chown root:root /opt/visual-studio-code/chrome-sandbox
    sudo chmod 4775 /opt/visual-studio-code/chrome-sandbox
}


function config_package_pack_blackbird_develop() {
    echo 'no package registered'
}


function config_package_pack_blackbird_service() {
    ## nginx configuration
    systemctl enable libvirtd.socket
}


function config_package_pack_blackbird_systems() {

    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak override --filesystem=$HOME/.themes
    sudo flatpak override --filesystem=$HOME/.icons
    sudo flatpak override --env=GTK_THEME=blackbird
    sudo flatpak override --env=GTK_THEME=blackbird

    rm /usr/share/hypr/wall0.png && rm /usr/share/hypr/wall1.png && rm /usr/share/hypr/wall2.png
    cp /usr/share/background/blackbird-dark.png /usr/share/hypr/wall0.png
    cp /usr/share/background/blackbird-dark.png /usr/share/hypr/wall1.png
    cp /usr/share/background/blackbird-dark.png /usr/share/hypr/wall2.png

}


function config_package_pack_blackbird_audisys() {
    echo 'no package registered'
}


function config_package_pack_blackbird_fileman() {
    echo 'no package registered'
}


function config_package_pack_blackbird_offices() {
    echo 'no package registered'
}


function config_package_pack_blackbird_browser() {
    echo 'no package registered'
}


function config_package_pack_blackbird_apstore() {
    echo 'no package registered'
}