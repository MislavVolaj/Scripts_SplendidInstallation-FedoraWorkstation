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
        else
            echo "Skipping restoring $PROFILESNAME profiles because the backup \"$PROFILESBACKUPFILENAME\" was not found!"

            # Running fallback tasks
            if [[ $PROFILESNAME = "EasyEffects" ]]
            then
                Import_EasyEffectsProfiles
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
            elif [[ $SETTINGSNAME = "default programs settings" ]]
            then
                # Creating empty database
                printf '%s\n' \
                    '[Default Applications]' \
                    '' \
                    '[Added Associations]' > $SETTING

                # Calling default programs settings configuring script
                Configure_DefaultPrograms
            fi
        fi
    done

    echo "Importing $SETTINGSNAME script completed!"
}

Import_EasyEffectsProfiles() {
    echo "Importing EasyEffects profiles..."

    if [[ -d "$SETTINGSDIRECTORY"/EasyEffects ]]
    then
        mkdir --parents $HOME/.config/easyeffects/irs/

        # Importing EasyEffects Impulse Response profiles
        cp --recursive "$SETTINGSDIRECTORY"/EasyEffects/irs $HOME/.config/easyeffects/

        # Importing EasyEffects presets
        cp --recursive "$SETTINGSDIRECTORY"/EasyEffects/output $HOME/.config/easyeffects/
    else
        "Skipping $PROFILESNAME profiles importing because the $PROFILESNAME profiles were not found!"
    fi

    echo "EasyEffects profiles importing script completed!"
}

Configure_Firefox() {
    read -p "Would you like to import Firefox settings from a pre-selected file? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Importing Firefox settings..."

        FIREFOXSETTINGS="Settings_Firefox.list"

        while read TEXTLINE
        do
            echo "$TEXTLINE" >> $HOME/.mozilla/firefox/*.default-release/prefs.js
        done < "$SETTINGSDIRECTORY"/"$FIREFOXSETTINGS"
    else
        echo "Importing Firefox settings skipped!"
    fi

    echo "Firefox settings importing script completed!"
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

Configure_DefaultPrograms() {
    echo "Configuring default programs..."

    read -p "Would you like to set \"gedit\" as default program to open plain text documents? (y/ anything else to skip) (recommended: y): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Setting "gedit" as default handler for TXT media type and adding an association
        xdg-mime default org.gnome.gedit.desktop text/plain
        sudo sed --in-place '$a text/plain=org.gnome.gedit.desktop;' $HOME/.config/mimeapps.list
    else
        echo "Setting \"gedit\" as default program to open plain text documents skipped!"
    fi

    read -p "Would you like to set \"eog\" as default program to view JPEG XL images? (y/ anything else to skip) (recommended: y): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Setting "eog" as default handler for JXL media type and adding an association
        xdg-mime default org.gnome.eog.desktop image/jxl
        sudo sed --in-place '$a image/jxl=org.gnome.eog.desktop;' $HOME/.config/mimeapps.list
    else
        echo "Setting \"eog\" as default program to view JPEG XL images skipped!"
    fi

    echo "Default programs configuring script completed!"
}

Configure_ProgramIcons-Hide() {
    echo "Hiding program icons..."

    PROGRAMICONS=(calf com.blackmagicdesign.rawspeedtest com.blackmagicdesign.resolve-CaptureLogs com.blackmagicdesign.resolve-Installer com.blackmagicdesign.resolve-Panels)

    for PROGRAMICON in ${PROGRAMICONS[@]}
    do
        read -p "Would you like to hide \"$PROGRAMICON\" program icon? (y/ anything else to skip) (recommended: y): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo sed --in-place '$a NoDisplay=true' /usr/share/applications/$PROGRAMICON.desktop
        else
            echo "Hiding \"$PROGRAMICON\" program icon skipped!"
        fi
    done

    echo "Program icons hiding script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-15 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Restore EasyEffects profiles" "Restore Mozilla Firefox profiles" "Configure Firefox" "Restore Mozilla Thunderbird profiles" "Restore LibreOffice profiles" "Restore Microsoft Visual Studio Code profiles" "Import Git settings" "Import Transmission settings" "Import VLC media player settings" "Import VeraCrypt settings" "Import Subsurface settings and database" "Configure default programs" "Hide program icons"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                PROFILESNAME="EasyEffects"
                PROFILES=($HOME/.config/easyeffects)
                Restore_Profiles
                PROFILESNAME="Mozilla Firefox"
                PROFILES=($HOME/.mozilla/firefox)
                Restore_Profiles
                Configure_Firefox
                PROFILESNAME="Mozilla Thunderbird"
                PROFILES=($HOME/.thunderbird)
                Restore_Profiles
                PROFILESNAME="LibreOffice"
                PROFILES=($HOME/.config/libreoffice/4/user)
                Restore_Profiles
                PROFILESNAME="Microsoft Visual Studio Code"
                PROFILES=($HOME/.config/Code)
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
                SETTINGSNAME="VerCrypt settings"
                SETTINGS=($HOME/.config/VeraCrypt/Configuration.xml)
                Import_Settings
                SETTINGSNAME="Subsurface settings"
                SETTINGS=($HOME/.config/Subsurface/Subsurface.conf)
                Import_Settings
                SETTINGSNAME="Subsurface database"
                SETTINGS=($HOME/.subsurface/$(whoami).xml)
                Import_Settings
                SETTINGSNAME="default programs settings"
                SETTINGS=($HOME/.config/mimeapps.list)
                Import_Settings
                Configure_ProgramIcons-Hide
                exit 0;;
            "Restore EasyEffects profiles" )
                PROFILESNAME="EasyEffects"
                PROFILES=($HOME/.config/easyeffects)
                Restore_Profiles
                Menu;;
            "Restore Mozilla Firefox profiles" )
                PROFILESNAME="Mozilla Firefox"
                PROFILES=($HOME/.mozilla/firefox)
                Restore_Profiles
                Menu;;
            "Configure Firefox" )
                Configure_Firefox
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
            "Restore Microsoft Visual Studio Code profiles" )
                PROFILESNAME="Microsoft Visual Studio Code"
                PROFILES=($HOME/.config/Code)
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
            "Import VeraCrypt settings" )
                SETTINGSNAME="VeraCrypt settings"
                SETTINGS=($HOME/.config/VeraCrypt/Configuration.xml)
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
            "Configure default programs" )
                SETTINGSNAME="default programs settings"
                SETTINGS=($HOME/.config/mimeapps.list)
                Import_Settings
                Menu;;
            "Hide program icons" )
                Configure_ProgramIcons-Hide
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Post-installation"
PROFILESDIRECTORY="$(pwd)/Pre-installation/Backup"
SETTINGSDIRECTORY="$(pwd)/Pre-installation/Settings/User"

Menu
