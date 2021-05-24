#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Install_WinRAR() {
    read -p "Would you like to install WinRAR from a file? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Rr]$ ]]
    then
        echo "Installing WinRAR..."

        RAR=$(find "$WORKINGDIRECTORY"/Installers/ -type f -name 'rarlinux-*')

        sudo tar --extract --gzip --xattrs --file=$RAR --directory /usr/local/bin/ rar/rar rar/unrar
        sudo tar --extract --gzip --xattrs --file=$RAR --directory /usr/local/lib/ rar/default.sfx
        sudo tar --extract --gzip --xattrs --file=$RAR --directory /etc/ rar/rarfiles.lst

        sudo cp "$WORKINGDIRECTORY"/Installers/rarreg.key /usr/local/lib/
    else
        echo "Installing WinRAR skipped!"
    fi

    echo "WinRAR installation script completed!"
}

CallScript_InstallVeraCrypt() {
    echo "Calling VeraCrypt installation script..."

    chmod +x "$WORKINGDIRECTORY"/Installers/./veracrypt-*
    sudo "$WORKINGDIRECTORY"/Installers/./veracrypt-*

    echo "VeraCrypt installation script completed!"
}

Install_Discord() {
    read -p "Would you like to install Discord from a RPM Fusion repository or a Flathub repository? (r/f/ anything else to skip) (recommended: r): "

    if [[ $REPLY =~ ^[Rr]$ ]]
    then
        echo "Installing Discord..."

        sudo dnf install --assumeyes discord
    elif [[ $REPLY =~ ^[Ff]$ ]]
    then
        echo "Installing Discord..."

        # Installing Flatpak repository
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        # Installing Discord Flatpak container
        sudo flatpak install --assumeyes flathub com.discordapp.Discord
    else
        echo "Installing Discord skipped!"
    fi

    echo "Discord installation script completed!"
}

Install_Subsurface() {
    read -p "Would you like to install Subsurface from an openSUSE repository, a Flathub repository or from a rpm file? (s/f/r anyhing else to skip) (recommended: r): "

    if [[ $REPLY =~ ^[Ss]$ ]]
    then
        echo "Installing Subsurface..."

        # Importing or installing Subsurface repository
        if [[ -f "$WORKINGDIRECTORY"/Repositories/subsurface.repo ]]
        then
            sudo cp "$WORKINGDIRECTORY"/Repositories/subsurface.repo /etc/yum.repos.d/
        else
            sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/home:Subsurface-Divelog/Fedora_33/home:Subsurface-Divelog.repo
        fi

        # Installing Subsurface from repository
        sudo dnf install --assumeyes subsurface
    elif [[ $REPLY =~ ^[Ff]$ ]]
    then
        echo "Installing Subsurface..."

        # Installing Flatpak repository
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        # Installing Subsurface Flatpak container
        sudo flatpak install --assumeyes flathub com.
    elif [[ $REPLY =~ ^[Rr]$ ]]
    then
        echo "Installing Subsurface..."

        # Installing Subsurface dependencies
        sudo dnf install --assumeyes http-parser libgit2 qt5-qtconnectivity qt5-qttranslations

        # Installing Subsurface from a RPM package
        sudo rpm --install --excludedocs --nodeps --noverify --replacefiles "$WORKINGDIRECTORY"/Installers/subsurface-*
    else
        echo "Installing Subsurface skipped!"
    fi
    
    echo "Subsurface installation script completed!"
}

Install_Spotify() {
    read -p "Would you like to install Spotify from a Flathub repository? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Installing Spotify..."

        # Installing Flatpak repository
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        # Installing Spotify Flatpak container
        sudo flatpak install --assumeyes flathub com.spotify.Client
    else
        echo "Installing Spotify skipped!"
    fi

    echo "Spotify installation script completed!"
}

CallScript_InstallStremio() {
    echo "Calling Stremio installation script..."

    chmod +x "$WORKINGDIRECTORY"/SoftwareInstallation_Stremio.sh
    "$WORKINGDIRECTORY"/./SoftwareInstallation_Stremio.sh

    echo "Stremio installation script completed!"
}

Install_WebTorrent() {
    read -p "Would you like to install WebTorrent from a Flathub repository? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Installing WebTorrent..."

        # Installing Flatpak repository
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        # Installing WebTorrent Flatpak container
        sudo flatpak install --assumeyes flathub io.webtorrent.WebTorrent
    else
        echo "Installing WebTorrent skipped!"
    fi

    echo "WebTorrent installation script completed!"
}

CallScript_InstallDaVinciResolve() {
    echo "Calling DaVinci Resolve installation script..."

    chmod +x "$WORKINGDIRECTORY"/Installers/./DaVinci_Resolve*
    "$WORKINGDIRECTORY"/Installers/./DaVinci_Resolve* -i

    echo "DaVinci Resolve installation script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-10 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Install WinRAR" "Install VeraCrypt" "Install Discord" "Install Subsurface" "Install Spotify" "Install Stremio" "Install WebTorrent" "Install DaVinci Resolve"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Install_WinRAR
                CallScript_InstallVeraCrypt
                Install_Discord
                Install_Subsurface
                Install_Spotify
                CallScript_InstallStremio
                Install_WebTorrent
                CallScript_InstallDaVinciResolve
                exit 0;;
            "Install WinRAR" )
                Install_WinRAR
                Menu;;
            "Install VeraCrypt" )
                CallScript_InstallVeraCrypt
                Menu;;
            "Install Discord" )
                Install_Discord
                Menu;;
            "Install Subsurface" )
                Install_Subsurface
                Menu;;
            "Install Spotify" )
                Install_Spotify
                Menu;;
            "Install Stremio" )
                CallScript_InstallStremio
                Menu;;
            "Install WebTorrent" )
                Install_WebTorrent
                Menu;;
            "Install DaVinci Resolve" )
                CallScript_InstallDaVinciResolve
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Installation/Software"
SETTINGSDIRECTORY="$(pwd)/Pre-installation/Settings/User"

Menu
