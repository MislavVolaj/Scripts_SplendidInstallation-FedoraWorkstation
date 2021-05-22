#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Export_Settings-Shell() {
    echo "Exporting shell settings..."

    if [[ -f $WORKINGDIRECTORY/.bashrc ]]
    then
        read -p "Would you like to overwrite last exported shell setting? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            cp "$HOME"/.bashrc $WORKINGDIRECTORY
        else
            echo "Exporting shell settings skipped!"
        fi
    else
        cp "$HOME"/.bashrc $WORKINGDIRECTORY
    fi

    echo "Shell settings exporting script completed!"
}

Export_Nautilus-Scripts() {
    echo "Exporting Nautilus scripts..."

    for NAUTILUSSCRIPT in (ls $HOME/.local/share/nautilus/scripts/)
    do
        if [[ -f $WORKINGDIRECTORY/Nautilus/$NAUTILUSSCRIPT ]]
        then
            read -p "Would you like to overwrite last exported Nautilus script \"$NAUTILUSSCRIPT\"? (y/ anything else to skip): "

            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                cp $NAUTILUSSCRIPT $WORKINGDIRECTORY/Nautilus/
            else
                echo "Exporting Nautilus script \"$NAUTILUSSCRIPT\" skipped!"
            fi
        else
            cp $NAUTILUSSCRIPT $WORKINGDIRECTORY/Nautilus/
        fi
    done

    echo "Nautilus scripts exporting script completed!"
}

Export_Settings-GNOME() {
    read -p "Select a settings management tool to use to export GNOME settings: dconf, gsettings: (d/g/ anything else to skip): "

    if [[ $REPLY =~ ^[Dd]$ ]]
    then
        read -p "Would you like to export GNOME settings to a pre-selected file? (y/ anything else to select a file): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            GNOMESETTINGS="Settings_GNOME-Exported.dconf"
        else
            read -p "Type the name (with extension) of the dconf file to export GNOME settings to: " "GNOMESETTINGS"
        fi

        if [[ -f "$WORKINGDIRECTORY/$GNOMESETTINGS" ]]
        then
            read -p "Would you like to overwrite last exported GNOME settings? (y/ anything else to select a settings management tool): "

            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                echo "Exporting GNOME settings..."

                dconf dump / > "$WORKINGDIRECTORY"/"$GNOMESETTINGS"
            else
                Export_Settings-GNOME
            fi
        else
            echo "Exporting GNOME settings..."

            dconf dump / > "$WORKINGDIRECTORY"/"$GNOMESETTINGS"
        fi
    elif [[ $REPLY =~ ^[Gg]$ ]]
    then
        read -p "Would you like to export GNOME settings to a pre-selected file? (y/ anything else to select a file): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            GNOMESETTINGS="Settings-GNOME_Exported.gsettings"
        else
            read -p "Type the name (with extension) of the gsettings file to export GNOME settings to: " "GNOMESETTINGS"
        fi

        if [[ -f "$WORKINGDIRECTORY/$GNOMESETTINGS" ]]
        then
            read -p "Would you like to overwrite last exported GNOME settings? (y/ anything else to select a settings management tool): "

            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                echo "Exporting GNOME settings..."

                gsettings list-recursively > "$WORKINGDIRECTORY"/"$GNOMESETTINGS"
            else
                Export_Settings-GNOME
            fi
        else
            echo "Exporting GNOME settings..."

            gsettings list-recursively > "$WORKINGDIRECTORY"/"$GNOMESETTINGS"
        fi
    else
        echo "Exporting GNOME settings skipped!"
    fi

    echo "GNOME settings exporting script completed!"
}

Export_Settings-PulseEffects() {
    echo "Exporting PulseEffects settings..."

    if [[ -f $WORKINGDIRECTORY/../../Backup/Backup_PulseEffectsSettings.tar.zst ]]
    then
        read -p "Would you like to overwrite last exported PulseEffects settings? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            tar --create --zstd --xattrs --file="$WORKINGDIRECTORY"/../../Backup/Backup_PulseEffectsSettings.tar.zst --directory $HOME/.config/PulseEffects/ .
        else
            echo "exporting PulseEffect settings skipped!"
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



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-7 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Export shell settings" "Export scripts for Nautilus" "Export GNOME settings" "Export PulseEffects settings" "Back up Mozilla profiles"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Export_Settings-Shell
                Export_Nautilus-Scripts
                Export_Settings-GNOME
                Export_Settings-PulseEffects
                CallScript_BackUp-MozillaProfiles
                exit 0;;
            "Export shell settings" )
                Export_Settings-Shell
                Menu;;
            "Export scripts for Nautilus" )
                Export_Nautilus-Scripts
                Menu;;
            "Export GNOME settings" )
                Export_Settings-GNOME
                Menu;;
            "Export PulseEffects settings" )
                Export_Settings-PulseEffects
                Menu;;
            "Back up Mozilla profiles" )
                CallScript_BackUp-MozillaProfiles
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Pre-installation/Settings/User"

Menu
