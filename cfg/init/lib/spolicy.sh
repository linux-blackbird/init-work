#!/bin/bash

function blackbird_cis_level_2_policy_crontab() {

    if [[ ! -e /etc/crontab ]];then
        touch /etc/crontab
    fi
    chown root:root /etc/crontab && chmod og-rwx /etc/crontab 


    if [[ ! -d /etc/cron.hourly ]];then
        mkdir /etc/cron.hourly
    fi
    chown root:root /etc/cron.hourly/ && chmod og-rwx /etc/cron.hourly/ 


    if [[ ! -d /etc/cron.daily ]];then
        mkdir /etc/cron.daily
    fi
    chown root:root /etc/cron.daily/ && chmod og-rwx /etc/cron.daily/


    if [[ ! -d /etc/cron.weekly ]];then
        mkdir /etc/cron.weekly
    fi
    chown root:root /etc/cron.weekly/ && chmod og-rwx /etc/cron.weekly/
    

    if [[ ! -d /etc/cron.monthly ]];then
        mkdir /etc/cron.monthly
    fi
    chown root:root /etc/cron.monthly/ && chmod og-rwx /etc/cron.monthly/


    if [[ ! -d /etc/cron.d ]];then
        mkdir /etc/cron.d
    fi
    chown root:root /etc/cron.d/ && chmod og-rwx /etc/cron.d
}


function blackbird_cis_level_2_policy_service() {
    systemctl mask nfs-server.service
}


function blackbird_cis_level_2_policy_install() {
    blackbird_cis_level_2_policy_crontab
}