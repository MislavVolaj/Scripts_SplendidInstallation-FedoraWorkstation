#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



CallScript_Update() {
    echo "Calling software updating script..."

    chmod +x "$WORKINGDIRECTORY"/Maintenance_Update.sh
    "$WORKINGDIRECTORY"/./Maintenance_Update.sh

    echo "Software updating script completed!"
}

CallScript_Upgrade() {
    echo "Calling system upgrading script..."

    chmod +x "$WORKINGDIRECTORY"/Maintenance_Upgrade.sh
    "$WORKINGDIRECTORY"/./Maintenance_Upgrade.sh

    echo "System upgrading script completed!"
}

CallScript_CleanUp() {
    echo "Calling cleaning up script..."

    chmod +x "$WORKINGDIRECTORY"/Maintenance_CleanUp.sh
    "$WORKINGDIRECTORY"/./Maintenance_CleanUp.sh

    echo "Cleaning up script completed!"
}

CallScript_Manage-FileSystems() {
    echo "Calling file systems managing script..."

    chmod +x "$WORKINGDIRECTORY"/Maintenance_Manage-FileSystems.sh
    "$WORKINGDIRECTORY"/./Maintenance_Manage-FileSystems.sh

    echo "File systems managing script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Update" "Upgrade" "Clean up" "Manage file systems"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                CallScript_Update
                CallScript_Upgrade
                CallScript_CleanUp
                CallScript_Manage-FileSystems
                exit 0;;
            "Update" )
                CallScript_Update
                Menu;;
            "Upgrade" )
                CallScript_Upgrade
                Menu;;
            "Clean up" )
                CallScript_CleanUp
                Menu;;
            "Manage file systems" )
                CallScript_Manage-FileSystems
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Maintenance"

Menu
