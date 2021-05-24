#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



CallScript_Configure-KickstartAnswerFile() {
    echo "Calling Kickstart answer file configurating script..."

    chmod +x "$WORKINGDIRECTORY"/Pre-installation_Configure-KickstartAnswerFile.sh
    "$WORKINGDIRECTORY"/./Pre-installation_Configure-KickstartAnswerFile.sh

    echo "Kickstart answer file configurating script completed!"
}

CallScript_Export-SystemSettings() {
    echo "Calling system settings exporting script..."

    chmod +x "$WORKINGDIRECTORY"/Pre-installation_Export-SystemSettings.sh
    "$WORKINGDIRECTORY"/./Pre-installation_Export-SystemSettings.sh

    echo "System settings exporting script completed!"
}

CallScript_Export-UserSettings() {
    echo "Calling user settings exporting script..."

    chmod +x "$WORKINGDIRECTORY"/Pre-installation_Export-UserSettings.sh
    "$WORKINGDIRECTORY"/./Pre-installation_Export-UserSettings.sh

    echo "User settings exporting script completed!"
}

CallScript_Export-ProgramSettings() {
    echo "Calling program settings exporting script..."

    chmod +x "$WORKINGDIRECTORY"/Pre-installation_Export-ProgramSettings.sh
    "$WORKINGDIRECTORY"/./Pre-installation_Export-ProgramSettings.sh

    echo "Program settings exporting script completed!"
}

CallScript_BackUp-UserFolders() {
    echo "Calling user folders backing up script..."

    chmod +x "$WORKINGDIRECTORY"/Pre-installation_BackUp-UserFolders.sh
    "$WORKINGDIRECTORY"/./Pre-installation_BackUp-UserFolders.sh

    echo "User folders backing up script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-7 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Configure Kickstart answer file" "Export system settings" "Export user settings" "Export program settings" "Back up user folders"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                CallScript_Configure-KickstartAnswerFile
                CallScript_Export-SystemSettings
                CallScript_Export-UserSettings
                CallScript_Export-ProgramSettings
                CallScript_BackUp-UserFolders
                exit 0;;
            "Configure Kickstart answer file" )
                CallScript_Configure-KickstartAnswerFile
                Menu;;
            "Export system settings" )
                CallScript_Export-SystemSettings
                Menu;;
            "Export user settings" )
                CallScript_Export-UserSettings
                Menu;;
            "Export program settings" )
                CallScript_Export-ProgramSettings
                Menu;;
            "Back up user folders" )
                CallScript_BackUp-UserFolders
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Pre-installation"

Menu
