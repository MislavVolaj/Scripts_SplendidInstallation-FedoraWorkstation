#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Install_WinRAR() {
    read -p "Would you like to install WinRAR? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
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

    echo "WinRAR installing script completed!"
}

CallScript_InstallVeraCrypt() {
    read -p "Would you like to install VeraCrypt? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Calling VeraCrypt installation script..."

        chmod +x "$WORKINGDIRECTORY"/Installers/./veracrypt-*
        sudo "$WORKINGDIRECTORY"/Installers/./veracrypt-*
    else
        echo "Installing VeraCrypt skipped!"
    fi

    echo "VeraCrypt installing script completed!"
}

Install_MicrosoftVisualStudioCode() {
    read -p "Would you like to install Microsoft Visual Studio Code? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
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
    else
       echo "Installing Microsoft Visual Studio Code skipped!"
    fi

    echo "Microsoft Visual Studio Code installing script completed!"
}

Install_Skype() {
    read -p "Would you like to install Skype? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
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
    else
        echo "Installing Skype skipped!"
    fi

    echo "Skype installing script completed!"
}

Install_TeamViewer() {
    read -p "Would you like to install TeamViewer? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
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
    else
        echo "Installing TeamViewer skipped!"
    fi

    echo "TeamViewer installing script completed!"
}

Install_Subsurface() {
    read -p "Would you like to install Subsurface from a COPR repository or from a rpm file? (r/f/ anyhing else to skip) (recommended: r): "

    if [[ $REPLY =~ ^[Rr]$ ]]
    then
        echo "Installing Subsurface..."

        # Importing or installing "Subsurface" repository
        if [[ -f "$WORKINGDIRECTORY"/Repositories/subsurface.repo ]]
        then
            sudo cp "$WORKINGDIRECTORY"/Repositories/subsurface.repo /etc/yum.repos.d/
        else
            sudo dnf copr enable --assumeyes dirkhh/Subsurface
        fi

        # Installing Subsurface from official repository
        sudo dnf install --assumeyes subsurface
    elif [[ $REPLY =~ ^[Ff]$ ]]
    then
        echo "Installing Subsurface..."

        # Installing Subsurface dependencies
        sudo dnf install --assumeyes qt5-{qtconnectivity,qtlocation,qtsensors,qttranslations,qtwebchannel,qtwebkit}

        # Linking newer installed and required missing version of a library
        sudo ln --symbolic /usr/lib64/libgit2.so.1.6 /usr/lib64/libgit2.so.1.3

        # Installing Subsurface from a RPM package
        sudo rpm --install --force --replacefiles --nodeps --noverify --nosignature "$WORKINGDIRECTORY"/Installers/subsurface-*
    else
        echo "Installing Subsurface skipped!"
    fi

    # Enabling downloading data from a diving computer
    sudo usermod --append --groups dialout Mislav

    echo "Subsurface installing script completed!"
}

CallScript_InstallStremio() {
    read -p "Would you like to compile and install Stremio from a GitHub repository? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Calling Stremio installing script..."

        chmod +x "$WORKINGDIRECTORY"/SoftwareInstallation_Stremio.sh
        "$WORKINGDIRECTORY"/./SoftwareInstallation_Stremio.sh
    else
        echo "Installing Stremio skipped!"
    fi

    echo "Stremio installing script completed!"
}

CallScript_InstallDaVinciResolve() {
    read -p "Would you like to install DaVinci Resolve? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Calling DaVinci Resolve installation script..."

        chmod +x "$WORKINGDIRECTORY"/Installers/./DaVinci_Resolve*
        "$WORKINGDIRECTORY"/Installers/./DaVinci_Resolve* -i
    else
        echo "Installing DaVinci Resolve skipped!"
    fi

    # Correcting loading of libraries during starting of program
    sudo cp /lib64/libglib-2.0.* /opt/resolve/libs/

    # Deleting program icon on desktop
    rm --force $HOME/Desktop/com.blackmagicdesign.resolve.desktop

    echo "DaVinci Resolve installing script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-10 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Install WinRAR" "Install VeraCrypt" "Install Microsoft Visual Studio Code" "Install Skype" "Install TeamViewer" "Install Subsurface" "Install Stremio" "Install DaVinci Resolve"; do
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
                CallScript_InstallStremio
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
