#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Configure_Settings-Shell() {
    echo "Configuring shell settings..."

    # Importing or configuring shell settings
    if [[ -f "$SETTINGSDIRECTORY"/.bashrc ]]
    then
        cp "$SETTINGSDIRECTORY"/.bashrc $HOME
    else
        read -p "Type the number of Bash commands to keep in history: (default: 1000): " BASHHISTORYSIZE

        sh -c "printf '%s\n' \
            '# .bashrc' \
            'shopt -s -q autocd cdspell' \
            '' \
            'export HISTSIZE=$BASHHISTORYSIZE' \
            'export HISTFILESIZE=$BASHHISTORYSIZE' \
            'export HISTTIMEFORMAT=\"%d.%m.%Y. %T  \"' \
            '' \
            '# Source global definitions' \
            'if [[ -f /etc/bashrc ]]' \
            'then' \
            '    . /etc/bashrc' \
            'fi' \
            '' \
            '# User specific environment' \
            'if ! [[ \"\$PATH\" =~ \"\$HOME/.local/bin:\$HOME/bin:\" ]]' \
            'then' \
            '    PATH=\"\$HOME/.local/bin:\$HOME/bin:\$PATH\"' \
            'fi' \
            'export PATH' \
            '' \
            '# Uncomment the following line if you don'\''t like systemctl'\''s auto-paging feature:' \
            '# export SYSTEMD_PAGER=' \
            '' \
            'echo Welcome back, \$(whoami).' \
            '' \
            '# User specific aliases and functions' > $HOME/.bashrc"

        read -p "Would you like to install user specific aliases and functions into Bash? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sh -c "printf '%s\n' \
                'md() { [ \$# = 1 ] && mkdir --parents \"\$@\" && cd \"\$@\" || echo \"Error: No directory name passed!\"; }' \
                '' \
                'alias cp='\''cp -i'\''' \
                'alias mv='\''mv -i'\''' \
                'alias rm='\''rm -i'\''' \
                '' \
                'alias copy=\"rsync --archive --human-readable --progress\"' \
                'alias update=\"sudo dnf upgrade --refresh && sudo flatpak update\"' \
                '' >> $HOME/.bashrc"

            echo "User specific aliases and functions installation script completed!"
        else
            echo "User specific aliases and functions installation skipped!"
        fi
    fi

    echo "Shell settings configuration script completed!"
}

Import_Nautilus-Scripts() {
    echo "Importing scripts for Nautilus..."

    cp "$SETTINGSDIRECTORY"/Nautilus/*.sh $HOME/.local/share/nautilus/scripts/
    chmod +x $HOME/.local/share/nautilus/scripts/*.sh

    echo "Scripts for Nautilus importing script completed!"
}

Import_Settings-GNOME() {
    read -p "Select a settings management tool to use to import GNOME settings: dconf, gsettings: (d/g/ anything else to skip): "

    if [[ $REPLY =~ ^[Dd]$ ]]
    then
        read -p "Would you like to import GNOME settings from a pre-selected file? (y/ anything else to select a file): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            GNOMESETTINGS="Settings_GNOME-Exported.dconf"
        else
            read -p "Type the name (with extension) of the dconf file to import GNOME settings from: " "GNOMESETTINGS"
        fi

        echo "Importing GNOME settings..."

        dconf load -f / < "$SETTINGSDIRECTORY"/"$GNOMESETTINGS"
    elif [[ $REPLY =~ ^[Gg]$ ]]
    then
        read -p "Would you like to import GNOME settings from a pre-selected file? (y/ anything else to select a file): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            GNOMESETTINGS="Settings_GNOME-Exported.gsettings"
        else
            read -p "Type the name (with extension) of the gsettings file to import GNOME settings from: " "GNOMESETTINGS"
        fi

        echo "Importing GNOME settings..."

        while read TEXTLINE
        do
            eval [gsettings set] [$TEXTLINE]

            if [ $? -ne 0 ]
            then
                echo "Could not import a \"$TEXTLINE\" setting!"
                read -n 1 -s -r -p "Press any key to continue"
            fi
        done < "$SETTINGSDIRECTORY"/"$GNOMESETTINGS"
    else
        echo "Importing GNOME settings skipped!"
    fi

    echo "GNOME settings importing script completed!"
}

Install_Settings-PulseEffects() {
    echo "Importing PulseEffects settings..."

    # Restoring or installing PulseEffects settings
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

CallScript_Customise-Interface() {
    echo "Installing interface customisation script..."

    chmod +x "$WORKINGDIRECTORY"/Interface/Post-installation_Customise-Interface.sh
    "$WORKINGDIRECTORY"/Interface/./Post-installation_Customise-Interface.sh

    echo "Interface customisation script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-8 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Configure shell settings" "Import scripts for Nautilus" "Import GNOME settings" "Import PulseEffects settings" "Restore Mozilla profiles" "Customise interface"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Configure_Settings-Shell
                Import_Nautilus-Scripts
                Import_Settings-GNOME
                Install_Settings-PulseEffects
                CallScript_Restore-MozillaProfiles
                CallScript_Customise-Interface
                exit 0;;
            "Configure shell settings" )
                Configure_Settings-Shell
                Menu;;
            "Import scripts for Nautilus" )
                Import_Nautilus-Scripts
                Menu;;
            "Import GNOME settings" )
                Import_Settings-GNOME
                Menu;;
            "Import PulseEffects settings" )
                Install_Settings-PulseEffects
                Menu;;
            "Restore Mozilla profiles" )
                CallScript_Restore-MozillaProfiles
                Menu;;
            "Customise interface" )
                CallScript_Customise-Interface
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Post-installation"
SETTINGSDIRECTORY="$(pwd)/Pre-installation/Settings/User"

Menu
