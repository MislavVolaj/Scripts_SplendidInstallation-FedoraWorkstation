#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj

# Scripts version = 38.1



Show_LicenseNotices() {
    echo "You are running \"Splendid installation\" scripts for Fedora Workstation!"
    echo
    echo "Copyright (C) 2021 Mislav Volaj"
    echo 
    echo "This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version."
    echo
    echo "This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details."
    echo
    echo "You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>."
}

CallScript_Pre-installation() {
    echo "Calling pre-installation script..."

    chmod +x "$WORKINGDIRECTORY"/Pre-installation/Script_Pre-installation.sh
    "$WORKINGDIRECTORY"/Pre-installation/./Script_Pre-installation.sh

    echo "Pre-installation script completed!"
}

CallScript_Installation() {
    echo "Calling installation script..."

    chmod +x "$WORKINGDIRECTORY"/Installation/Script_Installation.sh
    "$WORKINGDIRECTORY"/Installation/./Script_Installation.sh

    echo "Installation script completed!"
}

CallScript_Post-installation() {
    echo "Calling post-installation script..."

    chmod +x "$WORKINGDIRECTORY"/Post-installation/Script_Post-installation.sh
    "$WORKINGDIRECTORY"/Post-installation/./Script_Post-installation.sh

    echo "Post-installation script completed!"
}

CallScript_Maintenance() {
    echo "Calling maintenance script..."

    chmod +x "$WORKINGDIRECTORY"/Maintenance/Script_Maintenance.sh
    "$WORKINGDIRECTORY"/Maintenance/./Script_Maintenance.sh

    echo "Maintenance script completed!"
}



MainMenu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Call pre-installation script" "Call installation script" "Call post-installation script" "Call maintenance script"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                CallScript_Pre-installation
                CallScript_Installation
                CallScript_Post-installation
                CallScript_Maintenance
                exit 0;;
            "Call pre-installation script" )
                CallScript_Pre-installation
                MainMenu;;
            "Call installation script" )
                CallScript_Installation
                MainMenu;;
            "Call post-installation script" )
                CallScript_Post-installation
                MainMenu;;
            "Call maintenance script" )
                CallScript_Maintenance
                MainMenu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)"

Show_LicenseNotices
MainMenu
