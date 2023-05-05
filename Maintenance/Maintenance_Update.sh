#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Update_Firmware() {
    echo "Updating firmware..."

    # Running firmware update tool
    sudo fwupdmgr refresh
    sudo fwupdmgr update

    echo "Firmware updating script completed!"
}

Configure_Update-Kernel() {
    echo "Configuring updating the Kernel..."

    read -p "Would you like to disable updating the Kernel? (y/ anything else to skip) (recommended: skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Disabling updating the Kernel
        sudo sed --in-place '$ a exclude=kernel*' /etc/dnf/dnf.conf
    else
        # If disabled, enable updating the Kernel
        sudo sed --in-place '/exclude=kernel*/d' /etc/dnf/dnf.conf

        # Configuring the number of kernels to keep installed in /boot partition
        read -p "Type the number of Kernels to keep installed in /boot partition (default: 3): " KERNELSTOKEEP

        sudo sed --in-place 's/installonly_limit=.*/installonly_limit='$KERNELSTOKEEP'/' /etc/dnf/dnf.conf
    fi
    
    echo "Kernel updating configuration script completed!"
}

Update_Repositories() {
    echo "Updating software distributed by repositories..."

    sudo dnf upgrade --refresh --assumeyes

    echo "Repository software updating script completed!"
}

Update_Flatpak() {
    echo "Updating software distributed by Flatpak..."

    flatpak update --assumeyes

    echo "Flatpak software updating script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Update firmware" "Configure updating the Kernel" "Update software distributed by repositories" "Update software distributed by Flatpak"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Update_Repositories
                Update_Flatpak
                exit 0;;
            "Update firmware" )
                Update_Firmware
                Menu;;
            "Configure updating the Kernel" )
                Configure_Update-Kernel
                Menu;;
            "Update software distributed by repositories" )
                Update_Repositories
                Menu;;
            "Update software distributed by Flatpak" )
                Update_Flatpak
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Maintenance"

Menu
