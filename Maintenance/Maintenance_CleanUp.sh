#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Cleanup_UpdateCache() {
    echo "Deleting up update caches..."

    # Clearing firmware update tool update cache and history
    sudo fwupdmgr clear-offline
    sudo fwupdmgr clear-history

    # Clearing software packages update cache and history
    sudo dnf clean all

    sudo rm -rf /var/lib/dnf/history/*
    sudo rm -rf /var/lib/dnf/yumdb/*
    sudo rm -rf /var/cache/PackageKit/*

    echo "Update caches deletion script completed!"
}

Cleanup_TemporaryFiles() {
    echo "Deleting temporary files..."

    # Commenting out current temporary files retention time to preserve their values
    sudo sed --in-place '/^q/ s/^q /# &/g' /usr/lib/tmpfiles.d/tmp.conf

    # Writing shortest temporary files retention time
    sudo sed --in-place '$ a q \/tmp 1777 root root 1s' /usr/lib/tmpfiles.d/tmp.conf
    sudo sed --in-place '$ a q \/var\/tmp 1777 root root 1s' /usr/lib/tmpfiles.d/tmp.conf

    # Deleting temporary files older than their defined retention time
    sudo systemd-tmpfiles --remove
    sudo systemctl start systemd-tmpfiles-clean

    # Deleting shortest temporary files retention time
    sudo sed -i '/^q/d' /usr/lib/tmpfiles.d/tmp.conf

    # Uncommenting original temporary files retention time
    sudo sed -i '/# q /s/^# q /q /g' /usr/lib/tmpfiles.d/tmp.conf

    echo "Temporary files deletion script completed!"
}

Cleanup_Journal() {
    echo "Clearing journal..."

    sudo journalctl --flush --quiet
    sudo journalctl --rotate --quiet
    sudo journalctl --vacuum-time=1s --quiet

    echo "Journal clearing script completed!"
}

Cleanup_TrimSSD() {
    echo "Trimming SSD..."

    sudo fstrim --fstab

    echo "SSD trimming script completed!"
}

Cleanup_TerminalHistory() {
    echo "Clearing Terminal history..."

    rm /home/$(whoami)/.bash_history
    history -c

    echo "Terminal history clearing script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-7 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Delete update cache" "Delete temporary files" "Clear journal" "Trim SSD" "Clear Terminal history"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Cleanup_UpdateCache
                Cleanup_TemporaryFiles
                Cleanup_Journal
                Cleanup_TrimSSD
                Cleanup_TerminalHistory
                exit 0;;
            "Cleanup update cache" )
                Cleanup_UpdateCache
                Menu;;
            "Delete temporary files" )
                Cleanup_TemporaryFiles
                Menu;;
            "Clear journal" )
                Cleanup_Journal
                Menu;;
            "Trim SSD" )
                Cleanup_TrimSSD
                Menu;;
            "Clear Terminal history" )
                Cleanup_TerminalHistory
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Maintenance"

Menu
