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

Install_MicrosoftVisualStudioCode() {
    echo "Installing Microsoft Visual Studio Code..."

    # Importing or creating "Microsoft Visual Studio Code" repository
    if [[ -f "$WORKINGDIRECTORY"/Repositories/vscode.repo ]]
    then
        sudo cp "$WORKINGDIRECTORY"/Repositories/vscode.repo /etc/yum.repos.d/
    else
        sudo sh -c "printf '%s\n' \
            '[vscode]' \
            'name=Visual Studio Code' \
            'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
            'enabled=1' \
            'gpgcheck=1' \
            'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' > /etc/yum.repos.d/vscode.repo"
    fi

    # Installing Microsoft Visual Studio Code from official repository
    sudo dnf install --assumeyes code

    echo "Microsoft Visual Studio Code installation script completed!"
}

Install_Skype() {
    echo "Installing Skype..."

    # Importing or creating "Skype" repository
    if [[ -f "$WORKINGDIRECTORY"/Repositories/skype-stable.repo ]]
    then
        sudo cp "$WORKINGDIRECTORY"/Repositories/skype-stable.repo /etc/yum.repos.d/
    else
        sudo sh -c "printf '%s\n' \
            '[skype]' \
            'name=Skype' \
            'baseurl=https://repo.skype.com/rpm/stable/' \
            'enabled=1' \
            'gpgcheck=1' \
            'gpgkey=gpgkey=https://repo.skype.com/data/SKYPE-GPG-KEY' > /etc/yum.repos.d/skype-stable.repo"
    fi

    # Installing Skype from official repository
    sudo dnf install --assumeyes skypeforlinux

    echo "Skype installation script completed!"
}

Install_TeamViewer() {
    echo "Installing TeamViewer..."

    # Importing or creating "TeamViewer" repository
    if [[ -f "$WORKINGDIRECTORY"/Repositories/teamviewer.repo ]]
    then
        sudo cp "$WORKINGDIRECTORY"/Repositories/teamviewer.repo /etc/yum.repos.d/
    else
        sudo sh -c "printf '%s\n' \
            '[teamviewer]' \
            'name=TeamViewer' \
            'baseurl=https://linux.teamviewer.com/yum/stable/main/binary-\$basearch/' \
            'type=rpm-md' \
            'enabled=1' \
            'failovermethod=priority' \
            'gpgcheck=1' \
            'repo-gpgcheck=1' \
            'gpgkey=https://linux.teamviewer.com/pubkey/currentkey.asc' > /etc/yum.repos.d/teamviewer.repo"
    fi

    # Installing TeamViewer from official repository
    sudo dnf install --assumeyes teamviewer

    echo "TeamViewer installation script completed!"
}

Install_Subsurface() {
    read -p "Would you like to install Subsurface from an openSUSE repository, a Flathub repository or from a rpm file? (s/f/r anyhing else to skip) (recommended: r): "

    if [[ $REPLY =~ ^[Ss]$ ]]
    then
        echo "Installing Subsurface..."

        # Importing or installing "Subsurface" repository
        if [[ -f "$WORKINGDIRECTORY"/Repositories/subsurface.repo ]]
        then
            sudo cp "$WORKINGDIRECTORY"/Repositories/subsurface.repo /etc/yum.repos.d/
        else
            sudo sh -c "printf '%s\n' \
                '[subsurface]' \
                'name=Subsurface Divelog' \
                'baseurl=https://download.opensuse.org/repositories/home:/Subsurface-Divelog/Fedora_\$releasever/' \
                'type=rpm-md' \
                'enabled=1' \
                'gpgcheck=1' \
                'gpgkey=https://download.opensuse.org/repositories/home:/Subsurface-Divelog/Fedora_\$releasever/repodata/repomd.xml.key' > /etc/yum.repos.d/subsurface.repo"

            # "Subsurface" repository official installation method
            # RELEASEVERSION=$(awk --field-separator="=" '/VERSION_ID/ {print $2}' /etc/os-release)
            # sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/home:Subsurface-Divelog/Fedora_$RELEASEVERSION/home:Subsurface-Divelog.repo
        fi

        # Installing Subsurface from official repository
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

    PS3="Press 1 to exit, 2 to run all options or 3-12 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Install WinRAR" "Install VeraCrypt" "Install Microsoft Visual Studio Code" "Install Skype" "Install TeamViewer" "Install Subsurface" "Install Spotify" "Install Stremio" "Install WebTorrent" "Install DaVinci Resolve"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Install_WinRAR
                CallScript_InstallVeraCrypt
                Install_MicrosoftVisualStudioCode
                Install_Skype
                Install_TeamViewer
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
            "Install Microsoft Visual Studio Code" )
                Install_MicrosoftVisualStudioCode
                Menu;;
            "Install Skype" )
                Install_Skype
                Menu;;
            "Install TeamViewer" )
                Install_Teamviewer
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
