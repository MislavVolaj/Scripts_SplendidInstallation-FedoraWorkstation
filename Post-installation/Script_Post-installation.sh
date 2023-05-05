#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Cleanup_AnacondaInstaller() {
    echo "Deleting Anaconda Installer configurations and logs..."

    # Deleting Kickstart configurations and logs written by Anaconda Installer because they may contain unencrypted passwords
    sudo [ -f /root/anaconda-ks.cfg ] && sudo rm /root/anaconda-ks.cfg
    sudo [ -f /root/original-ks.cfg ] && sudo rm /root/original-ks.cfg
    sudo [ -f /root/anaconda-kickstart-post.log ] && sudo rm /root/anaconda-kickstart-post.log
    sudo [ -f /root/anaconda-kickstart-pre.log ] && sudo rm /root/anaconda-kickstart-pre.log

    # Deleting installation logs written by Anaconda Installer
    sudo rm --recursive --force /var/log/anaconda

    echo "Anaconda Installer configurations and logs deleting script completed!"
}

CallScript_SetUp-System() {
    echo "Calling system set up script..."

    chmod +x "$WORKINGDIRECTORY"/Post-installation_SetUp-System.sh
    "$WORKINGDIRECTORY"/./Post-installation_SetUp-System.sh

    echo "System set up script completed!"
}

Manage_Users() {
    echo "Managing users..."

    read -p "Would you like to list, add or delete a user? (l/a/d/ anything else to skip): "

    if [[ $REPLY =~ ^[Ll]$ ]]
    then
        echo "Current list of users:"

        cat /etc/passwd | grep "/home" | cut --delimiter=: --fields=1

        Manage_Users
    elif [[ $REPLY =~ ^[Aa]$ ]]
    then
        read -p "Type the name of the new user: " NEWUSERSNAME
        read -p "Type $NEWUSERSNAME's password: " NEWUSERSPASSWORD

        # Offering creating new users' home in a subvolume, if the file system is Btrfs
        if [[ $(stat --file-system --format=%T $HOME) = btrfs ]]
        then
            read -p "Would you like to create a Btrfs subvolume for $NEWUSERSNAME's home? (y/ anything else to n): "

            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                sudo useradd $NEWUSERSNAME --btrfs-subvolume-home --password $NEWUSERSPASSWORD
            else
                sudo useradd $NEWUSERSNAME --password $NEWUSERSPASSWORD
            fi
        else
            sudo useradd $NEWUSERSNAME --password $NEWUSERSPASSWORD
        fi

        # Making new user a system administrator, as in allowing new user to use the sudo command
        read -p "Would you like to make $NEWUSERSNAME a system administrator? (y/ anything else to n): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo usermod --groups wheel $NEWUSERSNAME
        fi
        
        Manage_Users
    elif [[ $REPLY =~ ^[Dd]$ ]]
    then
        read -p "Type the name of the user to delete: " OLDUSERSNAME

        sudo userdel --remove $OLDUSERSNAME

        Manage_Users
    else
        echo "Managing users skipped!"
    fi

    echo "Users managing script completed!"
}

CallScript_SetUp-User() {
    echo "Calling user setting up script..."

    chmod +x "$WORKINGDIRECTORY"/Post-installation_SetUp-User.sh
    "$WORKINGDIRECTORY"/./Post-installation_SetUp-User.sh

    echo "User setting up script completed!"
}

CallScript_SetUp-Programs() {
    echo "Calling programs setting up script..."

    chmod +x "$WORKINGDIRECTORY"/Post-installation_SetUp-Programs.sh
    "$WORKINGDIRECTORY"/./Post-installation_SetUp-Programs.sh

    echo "Programs setting up script completed!"
}

CallScript_Restore-UserFolders() {
    echo "Calling user folders restoring script..."

    chmod +x "$WORKINGDIRECTORY"/Post-installation_Restore-UserFolders.sh
    "$WORKINGDIRECTORY"/./Post-installation_Restore-UserFolders.sh

    echo "User folders restoring script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-8 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Delete Anaconda Installer configurations and logs" "Set up system" "Manage users" "Set up user" "Set up programs" "Restore user folders"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Cleanup_AnacondaInstaller
                CallScript_SetUp-System
                Manage_Users
                CallScript_SetUp-User
                CallScript_SetUp-Programs
                CallScript_Restore-UserFolders
                exit 0;;
            "Delete Anaconda Installer configurations and logs" )
                Cleanup_AnacondaInstaller
                Menu;;
            "Set up system" )
                CallScript_SetUp-System
                Menu;;
            "Manage users" )
                Manage_Users
                Menu;;
            "Set up user" )
                CallScript_SetUp-User
                Menu;;
            "Set up programs" )
                CallScript_SetUp-Programs
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
