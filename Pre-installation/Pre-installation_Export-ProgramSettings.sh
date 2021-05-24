#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Export_Settings-PulseEffects() {
    echo "Exporting PulseEffects settings..."

    if [[ -f $WORKINGDIRECTORY/../../Backup/Backup_PulseEffectsSettings.tar.zst ]]
    then
        read -p "Would you like to overwrite last exported PulseEffects settings? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            tar --create --zstd --xattrs --file="$WORKINGDIRECTORY"/../../Backup/Backup_PulseEffectsSettings.tar.zst --directory $HOME/.config/PulseEffects/ .
        else
            echo "Exporting PulseEffect settings skipped!"
        fi
    else
        tar --create --zstd --xattrs --file="$WORKINGDIRECTORY"/../../Backup/Backup_PulseEffectsSettings.tar.zst --directory $HOME/.config/PulseEffects/ .
    fi

    echo "PulseEffects settings exporting script completed!"
}

CallScript_BackUp-MozillaProfiles() {
    echo "Calling Mozilla profiles backing up script..."

    chmod +x "$WORKINGDIRECTORY"/../../Pre-installation_BackUp-MozillaProfiles.sh
    "$WORKINGDIRECTORY"/../.././Pre-installation_BackUp-MozillaProfiles.sh

    echo "Mozilla profiles backing up script completed!"
}

Export_Settings() {
    echo "Exporting $SETTINGNAME..."

    for SETTING in ${SETTINGS[@]}
    do
        if [[ -f $SETTING ]]
        then
            # Export configuration file
            if [[ -f $SETTINGSDIRECTORY/$(basename $SETTING) ]]
            then
                read -p "Would you like to overwrite last exported \"$(basename $SETTING)\"? (y/ anything else to skip): "

                if [[ $REPLY =~ ^[Yy]$ ]]
                then
                    cp $SETTING "$SETTINGSDIRECTORY"
                else
                    echo "Exporting \"$(basename $SETTING)\" skipped!"
                fi
            else
                cp $SETTING $SETTINGSDIRECTORY
            fi
        else
            echo "Exporting $SETTINGNAME skipped because the configuration file \"$(basename $SETTING)\" does not exist!"
        fi
    done

    echo "Exporting $SETTINGNAME script completed!"
}


Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Export PulseEffects settings" "Back up Mozilla profiles" "Export Git settings" "Export Subsurface settings and database"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Export_Settings-PulseEffects
                CallScript_BackUp-MozillaProfiles
                SETTINGNAME="Git settings"
                SETTINGS=($HOME/.gitconfig)
                Export_Settings
                SETTINGNAME="Subsurface settings and database"
                SETTINGS=($HOME/.config/Subsurface/Subsurface.conf $HOME/.subsurface/$(whoami).xml)
                Export_Settings
                exit 0;;
            "Export PulseEffects settings" )
                Export_Settings-PulseEffects
                Menu;;
            "Back up Mozilla profiles" )
                CallScript_BackUp-MozillaProfiles
                Menu;;
            "Export Git settings" )
                SETTINGNAME="Git settings"
                SETTINGS=($HOME/.gitconfig)
                Export_Settings
                Menu;;
            "Export Subsurface settings and database" )
                SETTINGNAME="Subsurface settings and database"
                SETTINGS=($HOME/.config/Subsurface/Subsurface.conf $HOME/.subsurface/$(whoami).xml)
                Export_Settings
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Pre-installation/Settings/User"
SETTINGSDIRECTORY="$WORKINGDIRECTORY"

Menu
