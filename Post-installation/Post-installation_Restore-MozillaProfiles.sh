#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Restore_MozillaFirefoxProfiles() {
    echo "Restoring Mozilla Firefox profile..."

    # Deleting current Mozilla Firefox profile
    sudo rm -rf $HOME/.mozilla/firefox/*

    # Creating Mozilla Firefox profile directory
    mkdir --parents $HOME/.mozilla/firefox

    # Extracting backed up Mozilla Firefox profile
    tar --extract --zstd --xattrs --file="$WORKINGDIRECTORY"/../Backup/Backup_MozillaFirefoxProfiles.tar.zst --directory $HOME/.mozilla/firefox/

    echo "Mozilla Firefox profiles restoration script completed!"
}

Restore_MozillaThunderbirdProfiles() {
    echo "Restoring Mozilla Thunderbird profiles..."

    # Deleting current Mozilla Thunderbird profile
    sudo rm -rf $HOME/.thunderbird/*

    # Creating Mozilla Firefox profile directory
    mkdir --parents $HOME/.thunderbird

    # Extracting backed up Mozilla Thunderbird profile
    tar --extract --zstd --xattrs --file="$WORKINGDIRECTORY"/../Backup/Backup_MozillaThunderbirdProfiles.tar.zst --directory $HOME/.thunderbird/

    echo "Mozilla Thunderbird profiles restoration script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-4 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Restore Mozilla Firefox profiles" "Restore Mozilla Thunderbird profiles"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Restore_MozillaFirefoxProfiles
                Restore_MozillaThunderbirdProfiles
                exit 0;;
            "Restore Mozilla Firefox profiles" )
                Restore_MozillaFirefoxProfiles
                Menu;;
            "Restore Mozilla Thunderbird profiles" )
                Restore_MozillaThunderbirdProfiles
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Pre-installation/Settings"

Menu
