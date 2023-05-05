#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Cleanup_UpdateCache() {
    echo "Deleting update caches..."

    # Clearing firmware update tool update cache and history
    sudo fwupdmgr clear-offline
    sudo fwupdmgr clear-history

    # Clearing software packages update cache and history
    sudo dnf clean all

    read -p "Would you like to deep clean \"dnf\" and \"PackageKit\" caches and history? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        sudo rm --recursive --force /var/cache/dnf/*
        sudo rm --recursive --force /var/cache/PackageKit/*
        sudo rm --recursive --force /var/lib/dnf/history/*
        sudo rm --recursive --force /var/lib/dnf/yumdb/*
    else
        echo "Deep cleaning \"dnf\" and \"PackageKit\" caches and history skipped!"
    fi

    echo "Update caches deleting script completed!"
}

Cleanup_PackagesDocumentation () {
    echo "Deleting packages documentation..."

    sudo rm --recursive --force /usr/share/doc/*

    echo "Packages documentation deleting script completed!"
}

Cleanup_TemporaryFiles() {
    read -p "Type the age of temporary files to keep: (to clear all temporary files type \"0\", to clear older temporary files than specified type a number followed by a suffix \"us\", \"ms\", \"s\", \"m\", \"h\", \"d\" or \"w\"): " TEMPORARYFILESRETENTIONTIME
    echo "Deleting temporary files..."

    # Commenting out current temporary files retention times to preserve their values
    sudo sed --in-place '/^q/ s/^q /# &/g' /usr/lib/tmpfiles.d/tmp.conf

    # Writing specified temporary files retention times
    sudo sed --in-place '$ a q \/tmp 1777 root root '$TEMPORARYFILESRETENTIONTIME'' /usr/lib/tmpfiles.d/tmp.conf
    sudo sed --in-place '$ a q \/var\/tmp 1777 root root '$TEMPORARYFILESRETENTIONTIME'' /usr/lib/tmpfiles.d/tmp.conf

    # Deleting temporary files older than their specified retention times
    sudo systemd-tmpfiles --remove
    sudo systemctl start systemd-tmpfiles-clean

    # Deleting specified temporary files retention times
    sudo sed --in-place '/^q/d' /usr/lib/tmpfiles.d/tmp.conf

    # Uncommenting original temporary files retention times to restore their values
    sudo sed --in-place '/# q /s/^# q /q /g' /usr/lib/tmpfiles.d/tmp.conf

    echo "Temporary files deleting script completed!"
}

Cleanup_Journal() {
    read -p "Type the age of journal entries to keep: (to clear all journal entries type \"1s\", to clear older journal entries than specified type a number followed by a suffix \"s\", \"m\", \"h\", \"days\", \"weeks\", \"months\" or \"years\"): " LOGRETENTIONTIME

    echo "Clearing journal..."

    sudo journalctl --flush --quiet
    sudo journalctl --rotate --quiet
    sudo journalctl --vacuum-time=$LOGRETENTIONTIME --quiet

    echo "Journal clearing script completed!"
}

Cleanup_TrimSSD() {
    echo "Trimming SSD..."

    sudo fstrim --fstab --verbose

    echo "SSD trimming script completed!"
}

Cleanup_TerminalHistory() {
    echo "Clearing Terminal history..."

    if [[ -f $HOME/.bash_history ]]
    then
        rm $HOME/.bash_history
    fi

    history -c

    echo "Terminal history clearing script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-8 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Delete update cache" "Delete packages documentation" "Delete temporary files" "Clear journal" "Trim SSD" "Clear Terminal history"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Cleanup_UpdateCache
                Cleanup_PackagesDocumentation
                Cleanup_TemporaryFiles
                Cleanup_Journal
                Cleanup_TrimSSD
                Cleanup_TerminalHistory
                exit 0;;
            "Delete update cache" )
                Cleanup_UpdateCache
                Menu;;
            "Delete packages documentation" )
                Cleanup_PackagesDocumentation
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
