#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Install_Dependencies-Compile-Stremio() {
    echo "Installing dependencies for Stremio compilation..."

    sudo dnf install --assumeyes librsvg2-{devel,tools} mpv-libs-devel nodejs qt5-{qtbase-devel,qtquickcontrols2,qtwebengine-devel}

    echo "Dependencies for Stremio compilation installing script completed!"
}

Download_Stremio-SourceCode() {
    echo "Downloading Stremio source code..."

    git clone --recurse-submodules --quiet https://github.com/Stremio/stremio-shell.git "$WORKINGDIRECTORY"

    echo "Stremio source code downloading script completed!"
}

Patch_Stremio-Project() {
    echo "Patching Stremio project..."

    # Patching release.makefile so it uses qmake-qt5 instead of qmake
    sed --in-place 's/qmake/qmake-qt5/g' "$WORKINGDIRECTORY"/release.makefile

    echo "Stremio project patching script completed!"
}

Compile_Stremio-Project() {
    echo "Compiling Stremio project..."

    sudo qmake-qt5 "$WORKINGDIRECTORY"

    if [ $? -ne 0 ]; then
        echo "Could not set up Stremio project! QMAKE-QT5 error!"
        read -n 1 -s -r -p "Press any key to continue"
    fi

    sudo make --directory="$WORKINGDIRECTORY" --makefile=release.makefile --silent

    if [ $? -ne 0 ]; then
        echo "Could not compile Stremio project! MAKE error!"
        read -n 1 -s -r -p "Press any key to continue"
    fi

    echo "Stremio project compiling script completed!"
}

Uninstall_Stremio() {
    # Checking if Stremio is installed
    if [[ -f /usr/bin/stremio ]]
    then
        echo "Uninstalling Stremio..."

        # Uninstalling Stremio
        sudo make --directory="$WORKINGDIRECTORY" --makefile="$WORKINGDIRECTORY"/release.makefile uninstall --silent

        # Deleting Stremio files and folders
        sudo rm /usr/bin/stremio
        sudo rm --recursive --force /opt/stremio
        sudo rm --recursive --force $HOME/stremio-server
        sudo rm --recursive --force $HOME/.cache/"Smart Code ltd"
        sudo rm --recursive --force $HOME/.local/share/"Smart Code ltd"
        sudo rm /usr/share/icons/hicolor/{'16x16','22x22','24x24','32x32','64x64','128x128'}/apps/smartcode-stremio.png smartcode-stremio-tray.png

        echo "Stremio uninstalling script completed!"
    else
        echo "Stremio uninstalling script skipped!"
    fi
}

Install_Stremio() {
    echo "Installing Stremio..."

    sudo make --directory="$WORKINGDIRECTORY" --makefile="$WORKINGDIRECTORY"/release.makefile install --silent

    if [ $? -ne 0 ]; then
        echo "Could not install the project! MAKE error!"
        read -n 1 -s -r -p "Press any key to continue"
    else
        echo "Stremio installed!"
    fi

    sudo "$WORKINGDIRECTORY"/./dist-utils/common/postinstall

    if [ $? -ne 0 ]; then
        echo "Could not complete the Stremio post-installation script!"
        read -n 1 -s -r -p "Press any key to continue"
    else
        echo "Stremio post-installation script completed!"
    fi
}

CleanUp_Stremio-Project() {
    echo "Deleting Stremio project folder..."

    sudo rm --recursive --force "$WORKINGDIRECTORY"

    echo "Stremio project folder deleting script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select options to run: "

    select options in "EXIT" "RUN ALL OPTIONS (Reinstall/Upgrade Stremio)" "Compile Stremio" "Uninstall Stremio" "Install Stremio" "Clean up"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS (Reinstall/Upgrade Stremio)" )
                Install_Dependencies-Compile-Stremio
                Download_Stremio-SourceCode
                cd "$WORKINGDIRECTORY"
                Patch_Stremio-Project
                Compile_Stremio-Project
                Uninstall_Stremio
                Install_Stremio
                cd "$WORKINGDIRECTORY"/..
                CleanUp_Stremio-Project
                exit 0;;
            "Compile Stremio" )
                Install_Dependencies-Compile-Stremio
                Download_Stremio-SourceCode
                cd "$WORKINGDIRECTORY"
                Patch_Stremio-Project
                Compile_Stremio-Project
                Menu;;
            "Uninstall Stremio" )
                Uninstall_Stremio
                Menu;;
            "Install Stremio" )
                Install_Stremio
                Menu;;
            "Clean up" )
                cd "$WORKINGDIRECTORY"/..
                CleanUp_Stremio-Project
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Installation/Software/Stremio"

Menu
