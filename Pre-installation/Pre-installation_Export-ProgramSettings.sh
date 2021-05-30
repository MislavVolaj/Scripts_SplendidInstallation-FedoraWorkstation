#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



BackUp_Profiles() {
    echo "Backing up $PROFILESNAME profiles..."

    PROFILESBACKUPFILENAME=Backup_${PROFILESNAME// /}Profiles.tar.zst

    if [[ -f $PROFILESDIRECTORY/$PROFILESBACKUPFILENAME ]]
    then
        read -p "Would you like to overwrite last backed up $PROFILESNAME profiles? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            tar --create --zstd --xattrs --file="$PROFILESDIRECTORY"/$PROFILESBACKUPFILENAME --directory $PROFILES .
        else
            echo "Backing up $PROFILESNAME profiles skipped!"
        fi
    else
        tar --create --zstd --xattrs --file="$PROFILESDIRECTORY"/$PROFILESBACKUPFILENAME --directory $PROFILES .
    fi

    echo "$PROFILESNAME profiles backing up script completed!"
}

Export_Settings() {
    echo "Exporting $SETTINGSNAME..."

    for SETTING in ${SETTINGS[@]}
    do
        if [[ -f $SETTING ]]
        then
            # Exporting configuration file
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

            # Running additional tasks
            if [[ $SETTINGSNAME = "Git settings" ]]
            then
                # Backing up GitHub verification
                if $(grep --silent "signingkey" $SETTING)
                then
                    PROFILESNAME="GNU Privacy Guard"
                    PROFILES=($HOME/.gnupg)
                    BackUp_Profiles
                fi
            fi
        else
            echo "Exporting $SETTINGSNAME skipped because the configuration file \"$(basename $SETTING)\" does not exist!"
        fi
    done

    echo "Exporting $SETTINGSNAME script completed!"
}


Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-10 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Back up PulseEffects profiles" "Back up Mozilla Firefox profiles" "Back up Mozilla Thunderbird profiles" "Back up LibreOffice profiles" "Export Git settings" "Export Transmission settings" "Export VLC media player settings" "Export Subsurface settings and database"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                PROFILESNAME="PulseEffects"
                PROFILES=($HOME/.config/PulseEffects)
                BackUp_Profiles
                PROFILESNAME="Mozilla Firefox"
                PROFILES=($HOME/.mozilla/firefox)
                BackUp_Profiles
                PROFILESNAME="Mozilla Thunderbird"
                PROFILES=($HOME/.thunderbird)
                BackUp_Profiles
                PROFILESNAME="LibreOffice"
                PROFILES=($HOME/.config/libreoffice/4/user)
                BackUp_Profiles
                SETTINGSNAME="Git settings"
                SETTINGS=($HOME/.gitconfig)
                Export_Settings
                SETTINGSNAME="Transmission settings"
                SETTINGS=($HOME/.config/transmission/settings.json)
                Export_Settings
                SETTINGSNAME="VLC media player settings"
                SETTINGS=($HOME/.config/vlc/vlcrc)
                Export_Settings
                SETTINGSNAME="Subsurface settings"
                SETTINGS=($HOME/.config/Subsurface/Subsurface.conf)
                Export_Settings
                SETTINGSNAME="Subsurface database"
                SETTINGS=($HOME/.subsurface/$(whoami).xml)
                Export_Settings
                exit 0;;
            "Back up PulseEffects profiles" )
                PROFILESNAME="PulseEffects"
                PROFILES=($HOME/.config/PulseEffects)
                BackUp_Profiles
                Menu;;
            "Back up Mozilla Firefox profiles" )
                PROFILESNAME="Mozilla Firefox"
                PROFILES=($HOME/.mozilla/firefox)
                BackUp_Profiles
                Menu;;
            "Back up Mozilla Thunderbird profiles" )
                PROFILESNAME="Mozilla Thunderbird"
                PROFILES=($HOME/.thunderbird)
                BackUp_Profiles
                Menu;;
            "Back up LibreOffice profiles" )
                PROFILESNAME="LibreOffice"
                PROFILES=($HOME/.config/libreoffice/4/user)
                BackUp_Profiles
                Menu;;
            "Export Git settings" )
                SETTINGSNAME="Git settings"
                SETTINGS=($HOME/.gitconfig)
                Export_Settings
                Menu;;
            "Export Transmission settings" )
                SETTINGSNAME="Transmission settings"
                SETTINGS=($HOME/.config/transmission/settings.json)
                Export_Settings
                Menu;;
            "Export VLC media player settings" )
                SETTINGSNAME="VLC media player settings"
                SETTINGS=($HOME/.config/vlc/vlcrc)
                Export_Settings
                Menu;;
            "Export Subsurface settings and database" )
                SETTINGSNAME="Subsurface settings"
                SETTINGS=($HOME/.config/Subsurface/Subsurface.conf)
                Export_Settings
                SETTINGSNAME="Subsurface database"
                SETTINGS=($HOME/.subsurface/$(whoami).xml)
                Export_Settings
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Pre-installation/Settings/User"
PROFILESDIRECTORY="$(pwd)/Pre-installation/Backup"
SETTINGSDIRECTORY="$WORKINGDIRECTORY"

Menu
