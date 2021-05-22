#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Install_WinRAR() {
    echo "Installing WinRAR..."

    RAR="$WORKINGDIRECTORY"/Installers/rarlinux-x64-6.0.0.tar.gz

    sudo tar --extract --gzip --xattrs --file=$RAR --directory /usr/local/bin/ rar/rar rar/unrar
    sudo tar --extract --gzip --xattrs --file=$RAR --directory /usr/local/lib/ rar/default.sfx
    sudo tar --extract --gzip --xattrs --file=$RAR --directory /etc/ rar/rarfiles.lst

    sudo cp "$WORKINGDIRECTORY"/Installers/rarreg.key /usr/local/lib/

    echo "WinRAR installation script completed!"
}

CallScript_InstallVeraCrypt() {
    echo "Calling VeraCrypt installation script..."

    chmod +x "$WORKINGDIRECTORY"/Installers/./veracrypt-*
    sudo "$WORKINGDIRECTORY"/Installers/./veracrypt-*

    echo "VeraCrypt installation script completed!"
}

Install_Subsurface() {
    echo "Installing Subsurface..."

    read -p "Would you like to install Subsurface from a repository or from a file? (r/f/ anyhing else to skip) (recommended: f): "

    if [[ $REPLY =~ ^[Rr]$ ]]
    then
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
        # Installing Subsurface dependencies
        sudo dnf install --assumeyes http-parser libgit2 qt5-qttranslations

        # Installing Subsurface from a RPM package
        sudo rpm --install --nodeps "$WORKINGDIRECTORY"/Installers/subsurface-*
    else
        echo "Subsurface installation skipped!"
    fi

    echo "Subsurface installation script completed!"
}

Install_Spotify() {
    echo "Installing Spotify..."

    # Installing Flatpak repository
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # Installing Spotify Flatpak container
    sudo flatpak install --assumeyes flathub com.spotify.Client

    echo "Spotify installation script completed!"
}

CallScript_InstallStremio() {
    echo "Calling Stremio installation script..."

    chmod +x "$WORKINGDIRECTORY"/SoftwareInstallation_Stremio.sh
    "$WORKINGDIRECTORY"/./SoftwareInstallation_Stremio.sh

    echo "Stremio installation script completed!"
}

CallScript_InstallDaVinciResolve() {
    echo "Calling DaVinci Resolve installation script..."

    chmod +x "$WORKINGDIRECTORY"/Installers/./DaVinci_Resolve*
    "$WORKINGDIRECTORY"/Installers/./DaVinci_Resolve* -i

    echo "DaVinci Resolve installation script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-8 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Install WinRAR" "Install VeraCrypt" "Install Subsurface" "Install Spotify" "Install Stremio" "Install DaVinci Resolve"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Install_WinRAR
                CallScript_InstallVeraCrypt
                Install_Subsurface
                Install_Spotify
                CallScript_InstallStremio
                CallScript_InstallDaVinciResolve
                exit 0;;
            "Install fonts" )
                Install_Fonts
                Menu;;
            "Install WinRAR" )
                Install_WinRAR
                Menu;;
            "Install VeraCrypt" )
                CallScript_InstallVeraCrypt
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
            "Install DaVinci Resolve" )
                CallScript_InstallDaVinciResolve
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Installation/Software"

Menu
