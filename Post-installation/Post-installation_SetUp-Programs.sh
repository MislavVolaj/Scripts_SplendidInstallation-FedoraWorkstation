#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Import_Settings-PulseEffects() {
    echo "Importing PulseEffects settings..."

    # Importing or installing PulseEffects settings
    if [[ -f "$SETTINGSDIRECTORY"/../../Backup/Backup_PulseEffectsSettings.tar.zst ]]
    then
    	# Creating PulseEffects settings directory
    	mkdir --parents $HOME/.config/PulseEffects

    	# Extracting backed up PulseEffects settings
        tar --extract --zstd --xattrs --file="$SETTINGSDIRECTORY"/../../Backup/Backup_PulseEffectsSettings.tar.zst --directory $HOME/.config/PulseEffects/
    else
        # Importing PulseEffects Impulse Response profiles
        cp --recursive "$SETTINGSDIRECTORY"/PulseEffects/irs $HOME/.config/PulseEffects/

        # Importing PulseEffects presets
        cp --recursive "$SETTINGSDIRECTORY"/PulseEffects/output $HOME/.config/PulseEffects/
    fi

    # Configuring default Impulse Response profile path in PulseEffects presets
    read -p "Would you like to configure a PulseEffects Impulse Response profile to use as default in PulseEffects presets? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        read -p "Paste the name (with extension) of PulseEffects Impulse Response profile to use as default in PulseEffects presets: " "IRSPROFILE"

        PRESETS=$HOME/.config/PulseEffects/output/*

        for PRESET in $PRESETS
        do
            sed --in-place '/"kernel-path":.*/ s|"kernel-path":.*|"kernel-path": "/home/'$USERNAME'/.config/PulseEffects/irs/'"$IRSPROFILE"'",|' "$PRESET"
        done
    else
        echo "Configuring a PulseEffects Impulse Response profile to use as default in PulseEffects presets skipped!"
    fi

    echo "PulseEffects settings importing script completed!"
}

CallScript_Restore-MozillaProfiles() {
    echo "Calling restoration of Mozilla profiles script..."

    chmod +x "$WORKINGDIRECTORY"/Post-installation_Restore-MozillaProfiles.sh
    "$WORKINGDIRECTORY"/./Post-installation_Restore-MozillaProfiles.sh

    echo "Restoration of Mozilla profiles script completed!"
}

Configure_Settings-Git () {
    echo "Configuring Git..."

    # Importing Git configuration or configuring Git
    if [[ -f "$SETTINGSDIRECTORY"/.gitconfig ]]
    then
        cp "$SETTINGSDIRECTORY"/.gitconfig $HOME/
    else
        read -p "Type your Git username: " GITUSERNAME
        read -p "Type your Git e-mail address:" GITEMAIL

        # Configuring Microsoft Visual Studio Code as the editor, if it is installed
        [[ -f /usr/share/code/bin/code ]] && git config --global core.editor "code -wait"

        git config --global user.name "$GITUSERNAME"
        git config --global user.email "$GITEMAIL"
    fi

    echo "Git configuration script completed!"
}

Import_Settings-Subsurface () {
    echo "Importing Subsurface configuration and database..."

    # Importing Subsurface configuration
    if [[ -f "$SETTINGSDIRECTORY"/Subsurface.conf ]]
    then
        read -p "Would you like to import Subsurface configuration? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            mkdir $HOME/.config/Subsurface
            cp "$SETTINGSDIRECTORY"/Subsurface.conf $HOME/.config/Subsurface/

            echo "Subsurface configuration imported!"
        else
            echo "Importing Subsurface configuration skipped!"
        fi
    else
        echo "Importing Subsurface configuration skipped because the configuration file does not exist!"
    fi

    # Importing Subsurface database
    if [[ -f "$SETTINGSDIRECTORY"/$(whoami).xml ]]
    then
        read -p "Would you like to import Subsurface database? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            mkdir $HOME/.subsurface
            cp "$SETTINGSDIRECTORY"/$(whoami).xml $HOME/.subsurface/

            echo "Subsurface database imported!"
        else
            echo "Importing Subsurface database skipped!"
        fi
    else
        echo "Importing Subsurface database skipped because the database file does not exist!"
    fi

    echo "Subsurface configuration and database importing script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Import PulseEffects settings" "Restore Mozilla profiles" "Import Git settings" "Import Subsurface configuration and database"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Import_Settings-PulseEffects
                CallScript_Restore-MozillaProfiles
                Configure_Settings-Git
                Import_Settings-Subsurface
                exit 0;;
            "Import PulseEffects settings" )
                Install_Settings-PulseEffects
                Menu;;
            "Restore Mozilla profiles" )
                CallScript_Restore-MozillaProfiles
                Menu;;
            "Import Git settings" )
                Configure_Settings-Git
                Menu;;
            "Import Subsurface settings and database" )
                Import_Settings-Subsurface
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Post-installation"
SETTINGSDIRECTORY="$(pwd)/Pre-installation/Settings/User"

Menu
