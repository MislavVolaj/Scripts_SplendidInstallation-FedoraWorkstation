#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



CallScript_SoftwareInstallation() {
    echo "Calling software installation script..."

    chmod +x "$WORKINGDIRECTORY"/Installation_SoftwareInstallation.sh
    "$WORKINGDIRECTORY"/./Installation_SoftwareInstallation.sh

    echo "Software installation script completed!"
}

CallScript_SoftwareInstallation-Supplementary() {
    echo "Calling supplementary software installation script..."

    chmod +x "$WORKINGDIRECTORY"/Installation_SoftwareInstallation-Supplementary.sh
    "$WORKINGDIRECTORY"/./Installation_SoftwareInstallation-Supplementary.sh

    echo "Supplementary software installation script completed!"
}

CallScript_SoftwareInstallation-Containerised() {
    echo "Calling containerised software installation script..."

    chmod +x "$WORKINGDIRECTORY"/Installation_SoftwareInstallation-Containerised.sh
    "$WORKINGDIRECTORY"/./Installation_SoftwareInstallation-Containerised.sh

    echo "Containerised software installation script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-5 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Install software from repositories" "Install supplementary software from other sources" "Install software containerised with Flatpak"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                CallScript_SoftwareInstallation
                CallScript_SoftwareInstallation-Supplementary
                CallScript_SoftwareInstallation-Containerised
                exit 0;;
            "Install software from repositories" )
                CallScript_SoftwareInstallation
                Menu;;
            "Install supplementary software from other sources" )
                CallScript_SoftwareInstallation-Supplementary
                Menu;;
            "Install software containerised with Flatpak" )
                CallScript_SoftwareInstallation-Containerised
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Installation"

Menu
