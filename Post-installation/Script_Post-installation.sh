#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



CleanUp_AnacondaKickstart() {
    echo "Deleting Anaconda Kickstart configurations and logs..."

    # Deleting Kickstart configurations and logs written by Anaconda Installer because they may contain unencrypted passwords
    sudo [ -f /root/anaconda-ks.cfg ] && sudo rm /root/anaconda-ks.cfg
    sudo [ -f /root/original-ks.cfg ] && sudo rm /root/original-ks.cfg
    sudo [ -f /root/anaconda-kickstart-post.log ] && sudo rm /root/anaconda-kickstart-post.log
    sudo [ -f /root/anaconda-kickstart-pre.log ] && sudo rm /root/anaconda-kickstart-pre.log

    echo "Anaconda Kickstart configurations and logs deleting script completed!"
}

CallScript_SetUp-System() {
    echo "Calling system set up script..."

    chmod +x "$WORKINGDIRECTORY"/Post-installation_SetUp-System.sh
    "$WORKINGDIRECTORY"/./Post-installation_SetUp-System.sh

    echo "System set up script completed!"
}

CallScript_SetUp-User() {
    echo "Calling user setup script..."

    chmod +x "$WORKINGDIRECTORY"/Post-installation_SetUp-User.sh
    "$WORKINGDIRECTORY"/./Post-installation_SetUp-User.sh

    echo "User setup script completed!"
}

CallScript_Restore-UserFolders() {
    echo "Calling user folders restoring script..."

    chmod +x "$WORKINGDIRECTORY"/Post-installation_Restore-UserFolders.sh
    "$WORKINGDIRECTORY"/./Post-installation_Restore-UserFolders.sh

    echo "User folders restoring script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Delete Anaconda Kickstart configurations and logs" "Set up system" "Set up user" "Restore user folders"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                CleanUp_AnacondaKickstart
                CallScript_SetUp-System
                CallScript_SetUp-User
                CallScript_Restore-UserFolders
                exit 0;;
            "Delete Anaconda Kickstart configurations and logs" )
                CleanUp_AnacondaKickstart
                Menu;;
            "Set up system" )
                CallScript_SetUp-System
                Menu;;
            "Set up user" )
                CallScript_SetUp-User
                Menu;;
            "Restore user folders" )
                CallScript_Restore-UserFolders
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Post-installation"

Menu
