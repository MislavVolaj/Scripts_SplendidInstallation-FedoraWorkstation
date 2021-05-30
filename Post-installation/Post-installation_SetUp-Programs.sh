#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Restore_Profiles() {
    echo "Restoring $PROFILESNAME profiles..."

    PROFILESBACKUPFILENAME=Backup_${PROFILESNAME// /}Profiles.tar.zst

    for PROFILE in ${PROFILES[@]}
    do
        if [[ -f $PROFILESDIRECTORY/$PROFILESBACKUPFILENAME ]]
        then
            # Deleting current profiles
            sudo rm --recursive --force $PROFILE/*

            # Creating profiles directory
            mkdir --parents $PROFILE

            # Extracting backed up profiles
            tar --extract --zstd --xattrs --file="$PROFILESDIRECTORY"/$PROFILESBACKUPFILENAME --directory $PROFILE

            # Running additional tasks
            if [[ $PROFILESNAME = "PulseEffects" ]]
            then
                Configure_PulseEffects-Presets
            fi
        else
            echo "Skipping restoring $PROFILESNAME profiles because the backup \"$PROFILESBACKUPFILENAME\" was not found!"

            # Running fallback tasks
            if [[ $PROFILESNAME = "PulseEffects" ]]
            then
                Import_PulseEffectsProfiles
            elif [[ $PROFILESNAME = "GNU Privacy Guard" ]]
            then
                # Getting author's and contributor's name and e-mail from Git cofiguration file
                GITUSERNAME="$(grep "name" $SETTING | awk --field-separator=' = ' '{print $2}')"
                GITEMAIL="$(grep "email" $SETTING | awk --field-separator=' = ' '{print $2}')"

                Configure_Git-GitHubVerification
            fi
        fi
    done

    echo "$PROFILESNAME profiles restoring script completed!"
}

Import_Settings() {
    echo "Importing $SETTINGSNAME..."

    for SETTING in ${SETTINGS[@]}
    do
        if [[ -f $SETTINGSDIRECTORY/$(basename $SETTING) ]]
        then
            # Import configuration file
            if [[ -f $SETTING ]]
            then
                read -p "Would you like to overwrite \"$(basename $SETTING)\"? (y/ anything else to skip): "

                if [[ $REPLY =~ ^[Yy]$ ]]
                then
                    mkdir --parents "$(dirname $SETTINGS)"
                    cp $SETTINGSDIRECTORY/$(basename $SETTING) "$(dirname $SETTINGS)"
                else
                    echo "Importing \"$(basename $SETTING)\" skipped!"
                fi
            else
                mkdir --parents "$(dirname $SETTINGS)"
                cp $SETTINGSDIRECTORY/$(basename $SETTING) "$(dirname $SETTINGS)"
            fi

            # Running additional tasks
            if [[ $SETTINGSNAME = "Git settings" ]]
            then
                # Restoring or configuring GitHub verification
                if [[ $(grep --silent "signingkey" $SETTING) ]]
                then
                    PROFILESNAME="GNU Privacy Guard"
                    PROFILES=($HOME/.gnupg/)
                    Restore_Profiles
                else
                    # Getting author's and contributor's name and e-mail from Git cofiguration file
                    GITUSERNAME="$(grep "name" $SETTING | awk --field-separator=' = ' '{print $2}')"
                    GITEMAIL="$(grep "email" $SETTING | awk --field-separator=' = ' '{print $2}')"

                    Configure_Git-GitHubVerification
                fi
            fi
        else
            echo "Skipping importing $SETTINGSNAME because the configuration file \"$(basename $SETTING)\" was not found!"

            # Running fallback tasks
            if [[ $SETTINGSNAME = "Git settings" ]]
            then
                Configure_Git
            fi
        fi
    done

    echo "Importing $SETTINGSNAME script completed!"
}

Import_PulseEffectsProfiles() {
    echo "Importing PulseEffects profiles..."

    if [[ -d "$SETTINGSDIRECTORY"/PulseEffects/irs && -d "$SETTINGSDIRECTORY"/PulseEffects/output ]]
    then
        # Importing PulseEffects Impulse Response profiles
        cp --recursive "$SETTINGSDIRECTORY"/PulseEffects/irs $HOME/.config/PulseEffects/

        # Importing PulseEffects presets
        cp --recursive "$SETTINGSDIRECTORY"/PulseEffects/output $HOME/.config/PulseEffects/

        Configure_PulseEffects-Presets
    else
        "Skipping $PROFILESNAME profiles importing because the $PROFILESNAME profiles were not found!"
    fi

    echo "PulseEffects profiles importing script completed!"
}

Configure_PulseEffects-Presets() {
    read -p "Would you like to configure a PulseEffects Impulse Response profile to use as default in PulseEffects presets? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        read -p "Paste the name (with extension) of PulseEffects Impulse Response profile to use as default in PulseEffects presets: " "IRSPROFILE"
        echo "Configuring a PulseEffects Impulse Response profile to use as default in PulseEffects presets..."

        for PRESET in $(ls $HOME/.config/PulseEffects/output/)
        do
            # Configuring default Impulse Response profile path in PulseEffects presets
            sed --in-place '/"kernel-path":.*/ s|"kernel-path":.*|"kernel-path": "/home/'$USERNAME'/.config/PulseEffects/irs/'"$IRSPROFILE"'",|' "$PRESET"
        done
    else
        echo "Configuring a PulseEffects Impulse Response profile to use as default in PulseEffects presets skipped!"
    fi

    echo "PulseEffects Impulse Response profile to use as default in PulseEffects presets configuring script completed!"
}

Configure_Git () {
    echo "Configuring Git..."

    read -p "Type your Git username: " "GITUSERNAME"
    read -p "Type your Git e-mail address:" "GITEMAIL"

    # Configuring Microsoft Visual Studio Code as the editor, if it is installed
    [[ -f /usr/share/code/bin/code ]] && git config --global core.editor "code -wait"

    # Configuring author's and contributor's name and e-mail
    git config --global user.name "$GITUSERNAME"
    git config --global user.email "$GITEMAIL"

    Configure_Git-GitHubVerification

    echo "Git configuring script completed!"
}

Configure_Git-GitHubVerification() {
    read -p "Would you like to configure GitHub verification? (y/ anything else to skip) (recommended: y): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Configuring GitHub verification..."

        # Generating GPG key pair
        KEYCOMMENT="GitHub verification"

        gpg --batch --quiet --full-generate-key << GPG-answers
            Key-Type: 1
            Key-Length: 4096
            Expire-Date: 0
            Name-Real: $GITUSERNAME
            Name-Email: $GITEMAIL
            Name-Comment: $KEYCOMMENT
            %commit
GPG-answers

        # Exporting GPG public key
        GPGKEYID=$(gpg --list-keys $KEYCOMMENT | awk 'BEGIN{RS=""; FS="\n"} {print $2}' | awk --field-separator=' ' '{print $1}')
        gpg --batch --quiet --armor --export $GPGKEYID > "$HOME/.gnupg/$KEYCOMMENT public key.txt"

        # Configuring Git to sign commits with GPG key
        git config --global user.signingkey $GPGKEYID
        git config --global commit.gpgsign true

        echo "REMINDER: Paste the generated public key in GitHub!"
    else
        echo "GitHub verification configuring skipped!"
    fi

    echo "GitHub verification configuring script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-10 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Restore PulseEffects profiles" "Restore Mozilla Firefox profiles" "Restore Mozilla Thunderbird profiles" "Restore LibreOffice profiles" "Import Git settings" "Import Transmission settings" "Import VLC media player settings" "Import Subsurface configuration and database"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                PROFILESNAME="PulseEffects"
                PROFILES=($HOME/.config/PulseEffects)
                Restore_Profiles
                PROFILESNAME="Mozilla Firefox"
                PROFILES=($HOME/.mozilla/firefox)
                Restore_Profiles
                PROFILESNAME="Mozilla Thunderbird"
                PROFILES=($HOME/.thunderbird)
                Restore_Profiles
                PROFILESNAME="LibreOffice"
                PROFILES=($HOME/.config/libreoffice/4/user)
                Restore_Profiles
                SETTINGSNAME="Git settings"
                SETTINGS=($HOME/.gitconfig)
                Import_Settings
                SETTINGSNAME="Transmission settings"
                SETTINGS=($HOME/.config/transmission/settings.json)
                Import_Settings
                SETTINGSNAME="VLC media player settings"
                SETTINGS=($HOME/.config/vlc/vlcrc)
                Import_Settings
                SETTINGSNAME="Subsurface settings"
                SETTINGS=($HOME/.config/Subsurface/Subsurface.conf)
                Import_Settings
                SETTINGSNAME="Subsurface database"
                SETTINGS=($HOME/.subsurface/$(whoami).xml)
                Import_Settings
                exit 0;;
            "Restore PulseEffects profiles" )
                PROFILESNAME="PulseEffects"
                PROFILES=($HOME/.config/PulseEffects)
                Restore_Profiles
                Configure_PulseEffects-Presets
                Menu;;
            "Restore Mozilla Firefox profiles" )
                PROFILESNAME="Mozilla Firefox"
                PROFILES=($HOME/.mozilla/firefox)
                Restore_Profiles
                Menu;;
            "Restore Mozilla Thunderbird profiles" )
                PROFILESNAME="Mozilla Thunderbird"
                PROFILES=($HOME/.thunderbird)
                Restore_Profiles
                Menu;;
            "Restore LibreOffice profiles" )
                PROFILESNAME="LibreOffice"
                PROFILES=($HOME/.config/libreoffice/4/user)
                Restore_Profiles
                Menu;;
            "Import Git settings" )
                SETTINGSNAME="Git settings"
                SETTINGS=($HOME/.gitconfig)
                Import_Settings
                Menu;;
            "Import Transmission settings" )
                SETTINGSNAME="Transmission settings"
                SETTINGS=($HOME/.config/transmission/settings.json)
                Import_Settings
                Menu;;
            "Import VLC media player settings" )
                SETTINGSNAME="VLC media player settings"
                SETTINGS=($HOME/.config/vlc/vlcrc)
                Import_Settings
                Menu;;
            "Import Subsurface settings and database" )
                SETTINGSNAME="Subsurface settings"
                SETTINGS=($HOME/.config/Subsurface/Subsurface.conf)
                Import_Settings
                SETTINGSNAME="Subsurface database"
                SETTINGS=($HOME/.subsurface/$(whoami).xml)
                Import_Settings
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Post-installation"
PROFILESDIRECTORY="$(pwd)/Pre-installation/Backup"
SETTINGSDIRECTORY="$(pwd)/Pre-installation/Settings/User"

Menu
