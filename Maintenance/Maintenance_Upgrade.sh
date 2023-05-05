#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



SystemUpgrade_Upgrade-OperatingSystem() {
    echo "Upgrading operating system to a new release version..."

    # Downloading upgrade packages
    RELEASEVERSION=$(awk --field-separator="=" '/VERSION_ID/ {print $2}' /etc/os-release)

    sudo dnf system-upgrade download --releasever=$((++RELEASEVERSION)) --allowerasing --nobest --skip-broken

    # Installing upgrade packages offline 
    sudo dnf system-upgrade reboot

    echo "Operating system upgrading script completed!"
}

SystemUpgrade_CleanUp() {
    echo "Cleaning up after upgrading operating system to a new release version..."

    # Installing dependencies
    sudo dnf install --assumeyes rpmconf

    # Rebuilding system configuration files
    sudo rpmconf --all

    # Removing dangling symlinks
    sudo symlinks -r -d /usr

    # Removing packages not in use and upgrade packages cache
    sudo dnf autoremove
    sudo dnf system-upgrade clean

    echo "Cleaning up script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-4 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Upgrade operating system" "Clean up"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                SystemUpgrade_Upgrade-OperatingSystem
                SystemUpgrade_CleanUp
                exit 0;;
            "Upgrade operating system" )
                SystemUpgrade_Upgrade-OperatingSystem
                Menu;;
            "Clean up" )
                SystemUpgrade_CleanUp
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Maintenance"

Menu
