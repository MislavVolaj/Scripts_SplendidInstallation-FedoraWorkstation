#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Export_Settings() {
    echo "Exporting $SETTINGNAME..."

    for SETTING in ${SETTINGS[@]}
    do
        if [[ -f $SETTING ]]
        then
            # Sort configuration file by type
            if [[ $SETTING =~ \.thumbnailer$ ]]
            then
                SETTINGSDIRECTORY="$WORKINGDIRECTORY/Nautilus"
            elif [[ $SETTING =~ \.repo$ ]]
            then
                SETTINGSDIRECTORY="$(pwd)/Installation/Software/Repositories"
            else
                SETTINGSDIRECTORY="$WORKINGDIRECTORY"
            fi

            # Export configuration file
            if [[ -f $SETTINGSDIRECTORY/$(basename $SETTING) ]]
            then
                read -p "Would you like to overwrite last exported \"$(basename $SETTING)\"? (y/ anything else to skip): "

                if [[ $REPLY =~ ^[Yy]$ ]]
                then
                    cp $SETTING "$SETTINGSDIRECTORY"
                else
                    echo "Exporting \"$(basename $SETTING)\" skipped!"
                fi
            else
                cp $SETTING $SETTINGSDIRECTORY
            fi
        else
            echo "Exporting $SETTINGNAME skipped because the configuration file \"$(basename $SETTING)\" does not exist!"
        fi
    done

    echo "Exporting $SETTINGNAME script completed!"
}

Export_DNF-UserInstalledPackagesList() {
    read -p "Would you like to export user installed packages to a pre-selected file? (y/ anything else to select a file): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        USERINSTALLEDPACKAGESLIST="Configuration_Packages-UserInstalled.list"
    else
        read -p "Type the name (with extension) of the file to export user installed packages to: " "USERINSTALLEDPACKAGESLIST"
    fi

    SETTINGSDIRECTORY="$(pwd)/Installation/Software"

    if [[ -f "$SETTINGSDIRECTORY/$USERINSTALLEDPACKAGESLIST" ]]
    then
        read -p "Would you like to overwrite last exported user installed packages? (y/n/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo "Exporting user installed packages..."

            dnf repoquery --userinstalled --queryformat "%{name}" > "$SETTINGSDIRECTORY/$USERINSTALLEDPACKAGESLIST"
        elif [[ $REPLY =~ ^[Nn]$ ]]
        then
            Export_DNF-UserInstalledPackagesList
        else
            echo "Exporting user installed packages skipped!"
        fi
    else
        echo "Exporting user installed packages..."

        dnf repoquery --userinstalled --queryformat "%{name}" > "$SETTINGSDIRECTORY/$USERINSTALLEDPACKAGESLIST"
    fi

    echo "User installed packages exporting script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-13 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Export Kernel modules settings" "Export zram swap space settings" "Export hibernation settings" "Export file systems settings" "Export Domain Name System settings" "Export logging history and temporary files retention settings" "Export Nautilus thumbnailers" "Export font rendering settings" "Export DNF package manager settings" "Export repositories" "Export user installed packages list"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                SETTINGNAME="Kernel modules settings"
                SETTINGS=(/etc/modprobe.d/blacklist.conf /etc/modprobe.d/i915.conf)
                Export_Settings
                SETTINGNAME="zram swap space settings"
                SETTINGS=(/etc/systemd/zram-generator.conf /etc/udev/rules.d/99-zram.rules)
                Export_Settings
                SETTINGNAME="hibernation settings"
                SETTINGS=(/etc/systemd/sleep.conf /etc/dracut.conf.d/resume.conf)
                Export_Settings
                SETTINGNAME="file systems settings"
                SETTINGS=(/etc/udisks2/mount_options.conf)
                Export_Settings
                SETTINGNAME="Domain Name System settings"
                SETTINGS=(/etc/systemd/resolved.conf)
                Export_Settings
                SETTINGNAME="logging history and temporary files retention settings"
                SETTINGS=(/etc/systemd/journald.conf /usr/lib/tmpfiles.d/tmp.conf)
                Export_Settings
                SETTINGNAME="Nautilus thumbnailers"
                SETTINGS=(/usr/share/thumbnailers/webp.thumbnailer)
                Export_Settings
                SETTINGNAME="font rendering settings"
                SETTINGS=(/etc/fonts/local.conf)
                Export_Settings
                SETTINGNAME="DNF package manager settings"
                SETTINGS=(/etc/dnf/dnf.conf)
                Export_Settings
                SETTINGNAME="repositories"
                SETTINGS=(/etc/yum.repos.d/{better_fonts,intel-opencl,skype,subsurface,teamviewer,vscode}.repo)
                Export_Settings
                Export_DNF-UserInstalledPackagesList
                exit 0;;
            "Export Kernel modules settings" )
                SETTINGNAME="Kernel modules settings"
                SETTINGS=(/etc/modprobe.d/modprobe.conf /etc/modprobe.d/i915.conf)
                Export_Settings
                Menu;;
            "Export zram swap space settings" )
                SETTINGNAME="zram swap space settings"
                SETTINGS=(/etc/systemd/zram-generator.conf /etc/udev/rules.d/99-zram.rules)
                Export_Settings
                Menu;;
            "Export hibernation settings" )
                SETTINGNAME="hibernation settings"
                SETTINGS=(/etc/systemd/sleep.conf /etc/dracut.conf.d/resume.conf)
                Export_Settings
                Menu;;
            "Export file systems settings" )
                SETTINGNAME="file systems settings"
                SETTINGS=(/etc/udisks2/mount_options.conf)
                Export_Settings
                Menu;;
            "Export Domain Name System settings" )
                SETTINGNAME="Domain Name System settings"
                SETTINGS=(/etc/systemd/resolved.conf)
                Export_Settings
                Menu;;
            "Export logging history and temporary files retention settings" )
                SETTINGNAME="logging history and temporary files retention settings"
                SETTINGS=(/etc/systemd/journald.conf /usr/lib/tmpfiles.d/tmp.conf)
                Export_Settings
                Menu;;
            "Export Nautilus thumbnailers" )
                SETTINGNAME="Nautilus thumbnailers"
                SETTINGS=(/usr/share/thumbnailers/webp.thumbnailer)
                Export_Settings
                Menu;;
            "Export font rendering settings" )
                SETTINGNAME="font rendering settings"
                SETTINGS=(/etc/fonts/local.conf)
                Export_Settings
                Menu;;
            "Export DNF package manager settings" )
                SETTINGNAME="DNF package manager settings"
                SETTINGS=(/etc/dnf/dnf.conf)
                Export_Settings
                Menu;;
            "Export repositories" )
                SETTINGNAME="repositories"
                SETTINGS=(/etc/yum.repos.d/{better_fonts,intel-opencl,skype-stable,subsurface,teamviewer,vscode}.repo)
                Export_Settings
                Menu;;
            "Export user installed packages list" )
                Export_DNF-UserInstalledPackagesList
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Pre-installation/Settings/System"

Menu
