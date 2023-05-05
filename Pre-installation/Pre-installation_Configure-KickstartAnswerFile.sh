#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Load_KickstartAnswerFile() {
    read -p "Would you like to configure a default Kickstart answer file? (y/ anything else to select a file): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        KICKSTARTANSWERFILENAME="Configuration_Kickstart-FedoraWorkstation.cfg"
    else
        read -p "Paste a Kickstart answer file name (with extension): " "KICKSTARTANSWERFILENAME"
    fi

    # Checking for existence of a Kickstart answer file
    if [[ -f $WORKINGDIRECTORY/$KICKSTARTANSWERFILENAME ]]
    then
        KICKSTARTANSWERFILE="$WORKINGDIRECTORY/$KICKSTARTANSWERFILENAME"
    else
        echo "Kickstart answer file does not exist!"
        read -p "Would you like to configure another Kickstart answer file? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            Load_KickstartAnswerFile
        else
            exit 0;
        fi
    fi
}

Configure_Networking() {
    echo "Configuring networking..."

    # Modifying hostname
    read -p "Type the computer hostname: " "COMPUTERHOSTNAME"

    sed --in-place 's/--hostname=.*/--hostname='$COMPUTERHOSTNAME'/' "$KICKSTARTANSWERFILE"
    sed --in-place 's/hostname .*/hostname '$COMPUTERHOSTNAME'/' "$KICKSTARTANSWERFILE"

    # Modifying wireless network name (SSID) and password
    read -p "Type the wireless network name (SSID): " "SSID"

    sed --in-place 's/\(.*--essid=\)[^ ]*\( .*\)/\1"'"$SSID"'"\2/' "$KICKSTARTANSWERFILE"
    sed --in-place 's/\(.*connect \)[^ ]*\( .*\)/\1"'"$SSID"'"\2/' "$KICKSTARTANSWERFILE"

    # Modifying wireless network password
    read -p "Type the $SSID's password: " "WIFIPASSWORD"

    sed --in-place 's/\(.*--wpakey=\)[^ ]*\( .*\)/\1"'$WIFIPASSWORD'"\2/' "$KICKSTARTANSWERFILE"
    sed --in-place 's/\(.*password \)[^ ]*\( .*\)/\1"'$WIFIPASSWORD'"\2/' "$KICKSTARTANSWERFILE"

    echo "Netwoking configuring script completed!"
}

Configure_Users() {
    echo "Configuring users..."

    # Modifying administrators' account password
    read -p "Type the administrator's password: " "ROOTSPASSWORD"
    read -p "Would you like the password encrypted? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        ENCRYPTEDROOTSPASSWORD=$(python -c 'import crypt; print(crypt.crypt("'$ROOTPASSWORD'", crypt.METHOD_SHA512))')

        sed --in-place 's%rootpw .*%rootpw --lock '$ENCRYPTEDROOTSPASSWORD' --iscrypted%' "$KICKSTARTANSWERFILE"
    else
        sed --in-place 's%rootpw .*%rootpw --lock '$ROOTSPASSWORD'%' "$KICKSTARTANSWERFILE"
    fi

    # Modifying users' account name and password
    read -p "Type the user's name and surname: " USERSNAME USERSSURNAME

    sed --in-place 's/^user .*/user --groups=wheel --name='$USERSNAME' --gecos="'$USERSNAME' '$USERSSURNAME'" --password=""/' "$KICKSTARTANSWERFILE"

    read -p "Type the $USERSNAME's password: " "USERSPASSWORD"
    read -p "Would you like the password encrypted? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        ENCRYPTEDUSERSPASSWORD=$(python -c 'import crypt; print(crypt.crypt("'$USERSPASSWORD'", crypt.METHOD_SHA512))')

        sed --in-place '/^user/ s%--password=""%--password='$ENCRYPTEDUSERSPASSWORD' --iscrypted%' "$KICKSTARTANSWERFILE"
    else
        sed --in-place '/^user/ s/--password=""/--password='$USERSPASSWORD'/' "$KICKSTARTANSWERFILE"
    fi

    echo "Users configuring script completed!"
}

Configure_DiskPartitioning() {
    echo "Configuring disk partitioning..."

    # Modifying user's Btrfs subvolume's name
    # Not asking for a user's name twice if a users configuring script has been run
    if [[ -z $USERSNAME ]]
    then
        read -p "Type the user's name: " USERSNAME
    fi

    sed --in-place 's/btrfs \/home\/.*/btrfs \/home\/'$USERSNAME' --subvol --name='$USERSNAME' Users/' "$KICKSTARTANSWERFILE"

    # Modifying GRUB (GRand Unified Bootloader) password
    read -p "Would you like to protect GRUB (GRand Unified Bootloader) with a password? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        read -p "Type the GRUB (GRand Unified Bootloader) password: " "GRUBPASSWORD"
        read -p "Would you like the password encrypted? (y/ anyhing else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            ENCRYPTEDGRUBPASSWORD=$(echo -e ''$GRUBPASSWORD'\n'$GRUBPASSWORD'' | grub2-mkpasswd-pbkdf2 | awk '/grub./{print$NF}')

            sed --in-place '/bootloader --/ s/ --password=.*//' "$KICKSTARTANSWERFILE"
            sed --in-place '/bootloader --/ s%$% --password='$ENCRYPTEDGRUBPASSWORD' --iscrypted%' "$KICKSTARTANSWERFILE"
        else
            sed --in-place '/bootloader --/ s/ --password=.*//' "$KICKSTARTANSWERFILE"
            sed --in-place '/bootloader --/ s/$/ --password='$GRUBPASSWORD'/' "$KICKSTARTANSWERFILE"
        fi
    else
        sed --in-place '/bootloader --/ s/ --password=.*//' "$KICKSTARTANSWERFILE"
    fi

    # Modifying LUKS (Linux Unified Key Setup) partition encryption
    read -p "Would you like to protect disk partitions with LUKS (Linux Unified Key Setup) encryption? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        read -p "Type the LUKS (Linux Unified Key Setup) password: " "LUKSPASSWORD"

        sed --in-place '/logvol/ s/ --encrypted=.*//' "$KICKSTARTANSWERFILE"
        sed --in-place '/part swap/ s/ --encrypted=.*//' "$KICKSTARTANSWERFILE"
        sed --in-place '/part btrfs/ s/ --encrypted=.*//' "$KICKSTARTANSWERFILE"

        sed --in-place '/logvol/ s/$/ --encrypted --luks-version=luks2 --passphrase='$LUKSPASSWORD' --cipher=aes-xts-plain64/' "$KICKSTARTANSWERFILE"
        sed --in-place '/part swap/ s/$/ --encrypted --luks-version=luks2 --passphrase='$LUKSPASSWORD' --cipher=aes-xts-plain64/' "$KICKSTARTANSWERFILE"
        sed --in-place '/part btrfs/ s/$/ --encrypted --luks-version=luks2 --passphrase='$LUKSPASSWORD' --cipher=aes-xts-plain64/' "$KICKSTARTANSWERFILE"
    else
        sed --in-place '/logvol/ s/ --encrypted=.*//' "$KICKSTARTANSWERFILE"
        sed --in-place '/part swap/ s/ --encrypted=.*//' "$KICKSTARTANSWERFILE"
        sed --in-place '/part btrfs/ s/ --encrypted=.*//' "$KICKSTARTANSWERFILE"
    fi

    echo "Disk partitioning configurating script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-5 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Configure networking" "Configure users" "Configure disk partitioning"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Configure_Networking
                Configure_Users
                Configure_DiskPartitioning
                exit 0;;
            "Configure networking" )
                Configure_Networking
                Menu;;
            "Configure users" )
                Configure_Users
                Menu;;
            "Configure disk partitioning" )
                Configure_DiskPartitioning
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Installation"

echo
Load_KickstartAnswerFile
Menu
