#!/bin/bash

## PREPARE

APPS=/init-logs
echo "MODE=$1" >> $APPS/env


## DECLARE EVN
source "$APPS/env"
source "$APPS/cfg/init/lib/storage.sh"
source "$APPS/cfg/init/lib/package.sh"
source "$APPS/cfg/init/lib/setconf.sh"

echo "Preparing to $1"

## STORAGE PREPARE
if [[ $1 == "install" ]];then

    setup_storage_blackbird_protocol_fresh

elif [[ $1 == "swipe" ]];then

    setup_storage_blackbird_protocol_swipe

elif [[ $1 == "reset" ]];then

    setup_storage_blackbird_protocol_reset

else
    
    echo "error : undefined parameter, used "install", "swipe", or "reset" for parameter ";
fi



## INSTALL PACKAGE
install_package_main_blackbird_basics
prepare_configuration_blackbird_basic


## CHROOT INSTALL PACKAGE
arch-chroot /mnt /bin/bash /init/main