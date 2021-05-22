#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



BackUp_MozillaFirefoxProfiles() {
    echo "Backing up Mozilla Firefox profile..."

    if [[ -f $WORKINGDIRECTORY/Backup_MozillaFirefoxProfiles.tar.zst ]]
    then
        read -p "Would you like to overwrite last backed up Mozilla Firefox profiles? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            tar --create --zstd --xattrs --file="$WORKINGDIRECTORY"/Backup_MozillaFirefoxProfiles.tar.zst --directory $HOME/.mozilla/firefox .
        else
            echo "Backing up Mozilla Firefox profiles skipped!"
        fi
    else
        tar --create --zstd --xattrs --file="$WORKINGDIRECTORY"/Backup_MozillaFirefoxProfiles.tar.zst --directory $HOME/.mozilla/firefox .
    fi

    echo "Mozilla Firefox profiles backing up script completed!"
}

BackUp_MozillaThunderbirdProfiles() {
    echo "Backing up Mozilla Thunderbird profiles..."

    if [[ -f $WORKINGDIRECTORY/Backup_MozillaThunderbirdProfiles.tar.zst ]]
    then
        read -p "Would you like to overwrite last backed up Mozilla Thunderbird profiles? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            tar --create --zstd --xattrs --file="$WORKINGDIRECTORY"/Backup_MozillaThunderbirdProfiles.tar.zst --directory $HOME/.thunderbird .
        else
            echo "Backing up Mozilla Thunderbird profiles skipped!"
        fi
    else
        tar --create --zstd --xattrs --file="$WORKINGDIRECTORY"/Backup_MozillaThunderbirdProfiles.tar.zst --directory $HOME/.thunderbird .
    fi


    echo "Mozilla Thunderbird profiles backing up script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-4 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Back up Mozilla Firefox profiles" "Back up Mozilla Thunderbird profiles"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                BackUp_MozillaFirefoxProfiles
                BackUp_MozillaThunderbirdProfiles
                exit 0;;
            "Back up Mozilla Firefox profiles" )
                BackUp_MozillaFirefoxProfiles
                Menu;;
            "Back up Mozilla Thunderbird profiles" )
                BackUp_MozillaThunderbirdProfiles
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Pre-installation/Backup"

Menu
