#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



ManageBtrfs_Scrub() {
    echo "Scrubbing Btrfs file systems..."

    for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
    do
        BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)

        # Checking integrity of the file system and reporting corrupted blocks and automatically repairing corrupted blocks if a correct copy is available
        sudo btrfs scrub start $BTRFSMOUNTPOINT && echo "Btrfs file system mounted at \"$BTRFSMOUNTPOINT\" scrubbing completed!"
    done

    echo "Btrfs file systems scrubbing script completed!"
}

ManageBtrfs_Defragment() {
    echo "Defragmenting Btrfs file systems..."

    for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
    do
        BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)

        # Merging file extents in the file system
        sudo btrfs filesystem defragment -r $BTRFSMOUNTPOINT && echo "Btrfs file system mounted at \"$BTRFSMOUNTPOINT\" defragmenting completed!"
    done

    echo "Btrfs file systems defragmenting script completed!"
}

ManageBtrfs_Balance() {
    echo "Balancing Btrfs file systems..."

    for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
    do
        BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)

        echo "Reporting pre-balancing file system balance state:"
        sudo btrfs filesystem df $BTRFSMOUNTPOINT

        # Spreading block groups across all devices so they match constraints defined by the respective profiles
        echo "Balancing Btrfs file system mounted at \"$BTRFSMOUNTPOINT\"..."
        sudo btrfs balance start --full-balance --enqueue $BTRFSMOUNTPOINT && echo "Btrfs file system mounted at \"$BTRFSMOUNTPOINT\" balancing completed!"

        echo "Reporting post-balancing file system balance state:"
        sudo btrfs filesystem df $BTRFSMOUNTPOINT
    done

    echo "REMINDER: It is recommended to trim the SSD now!"
    echo "Btrfs file systems balancing script completed!"
}

ManageBtrfs_MountPools() {
    # Defining Btrfs pools mount point on a tmpfs
    BTRFSPOOLSMOUNTPOINT=/tmp/mount_btrfs-pool

    for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
    do
        BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)
        BTRFSPOOLMOUNTPOINT=$BTRFSPOOLSMOUNTPOINT/$(sudo btrfs filesystem label $BTRFSMOUNTPOINT)

        # Creating mount points
        sudo mkdir --parents $BTRFSPOOLMOUNTPOINT

        # Mounting real Btrfs roots of defined Btrfs file systems
        sudo mount -o subvolid=5 $BTRFSDEVICE $BTRFSPOOLMOUNTPOINT
    done
}

ManageBtrfs_UnmountPools() {
    for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
    do
        BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)
        BTRFSPOOLMOUNTPOINT=$BTRFSPOOLSMOUNTPOINT/$(sudo btrfs filesystem label $BTRFSMOUNTPOINT)

        # Unmounting real Btrfs roots
        sudo umount $BTRFSPOOLMOUNTPOINT
    done

    # Removing mount points
    sudo rm --recursive --force $BTRFSPOOLSMOUNTPOINT
}

ManageBtrfs_DefineMountPoints() {
    # Defining operating system's "/ (root)" subvolume's name and mount point
    # "/ (root)" can be mounted as a:
    #     - non-Btrfs partition
    #     - subvolume on a Btrfs partition
    if [[ $(findmnt --mountpoint / --types btrfs) ]]
    then
        OSROOTBTRFSSUBVOLUMENAME=$(sudo btrfs subvolume show / | awk '$1=="Name:" {print $2}' | awk --field-separator='-' '{print $1}')
        OSROOTBTRFSSUBVOLUMEMOUNTPOINT=$BTRFSPOOLSMOUNTPOINT/$(sudo btrfs filesystem label /)/$OSROOTBTRFSSUBVOLUMENAME
    fi

    # Defining File Systems Table location
    if [[ $OSROOTBTRFSSUBVOLUMEMOUNTPOINT ]]
    then
        FSTABLOCATIONS=($OSROOTBTRFSSUBVOLUMEMOUNTPOINT/etc/fstab $OSROOTBTRFSSUBVOLUMEMOUNTPOINT-$WHEN/etc/fstab)
    else
        FSTABLOCATIONS=(/etc/fstab)
    fi

    # Defining operating system's "/boot" subvolume's name and mount point and boot loader entries location 
    # "/boot" can be mounted as a:
    #     - separate non-Btrfs partition
    #     - folder under "/ (root)" that can be a
    #           - non-Btrfs partition
    #           - subvolume on a Btrfs partition
    #     - Btrfs subvolume mounted under
    #           - "/ (root)" Btrfs partition
    #           - a separate Btrfs partition
    if [[ $(findmnt --mountpoint /boot --types ext4 || findmnt --mountpoint /boot --types xfs) ]]
    then
        BOOTLOADERENTRIESLOCATIONS=(/boot/loader/entries)
    elif [[ $(findmnt --mountpoint /boot --types btrfs) ]]
    then
        OSBOOTBTRFSSUBVOLUMENAME=$(sudo btrfs subvolume show /boot | awk '$1=="Name:" {print $2}' | awk --field-separator='-' '{print $1}')
        OSBOOTBTRFSSUBVOLUMEMOUNTPOINT=$BTRFSPOOLSMOUNTPOINT/$(sudo btrfs filesystem label /boot)/$OSBOOTBTRFSSUBVOLUMENAME
        BOOTLOADERENTRIESLOCATIONS=($OSBOOTBTRFSSUBVOLUMEMOUNTPOINT/loader/entries $OSBOOTBTRFSSUBVOLUMEMOUNTPOINT-$WHEN/loader/entries)
    elif [[ $(findmnt --mountpoint / --types btrfs) ]]
    then
        OSBOOTBTRFSFOLDERMOUNTPOINT=$OSROOTBTRFSSUBVOLUMEMOUNTPOINT
        BOOTLOADERENTRIESLOCATIONS=($OSBOOTBTRFSFOLDERMOUNTPOINT/boot/loader/entries $OSBOOTBTRFSFOLDERMOUNTPOINT-$WHEN/boot/loader/entries)
    fi
}

ManageBtrfs_TakeSnapshots() {
    echo "Creating snapshots of Btrfs subvolumes..."

    # Selecting snapshotting logic
    echo "Standard snapshotting logic creates read-only snapshots of subvolumes in a flat layout and continues to use original subvolumes as default."
    echo "Alternative snapshotting logic creates writeable snapshots of subvolumes in a flat layout and switches to use them as default, with restart."
    read -p "Use standard or alternative snapshotting logic? (s/a/ anything else to skip): "

    WHEN=$(date +%y%m%d%H%M)

    if [[ $REPLY =~ ^[Ss]$ ]]
    then
        ManageBtrfs_MountPools

        # Taking read-only snapshots of subvolumes (in a flat layout)
        for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
        do
            BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)
            BTRFSPOOLMOUNTPOINT=$BTRFSPOOLSMOUNTPOINT/$(sudo btrfs filesystem label $BTRFSMOUNTPOINT)

            for BTRFSSUBVOLUMENAME in $(sudo btrfs subvolume list $BTRFSMOUNTPOINT | awk --field-separator=" " '{print $9}')
            do
                if [[ ! $BTRFSSUBVOLUMENAME == */* ]]
                then
                    sudo btrfs subvolume snapshot -r $BTRFSPOOLMOUNTPOINT/$BTRFSSUBVOLUMENAME $BTRFSPOOLMOUNTPOINT/$BTRFSSUBVOLUMENAME-$WHEN
                fi
            done
        done

        ManageBtrfs_UnmountPools
    elif [[ $REPLY =~ ^[Aa]$ ]]
    then
        ManageBtrfs_MountPools
        ManageBtrfs_DefineMountPoints

        # Taking writeable snapshots of subvolumes (in a flat layout)
        for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
        do
            BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)
            BTRFSPOOLMOUNTPOINT=$BTRFSPOOLSMOUNTPOINT/$(sudo btrfs filesystem label $BTRFSMOUNTPOINT)

            for BTRFSSUBVOLUMENAME in $(sudo btrfs subvolume list $BTRFSMOUNTPOINT | awk --field-separator=" " '{print $9}')
            do
                if [[ ! $BTRFSSUBVOLUMENAME == */* ]]
                then
                    sudo btrfs subvolume snapshot $BTRFSPOOLMOUNTPOINT/$BTRFSSUBVOLUMENAME $BTRFSPOOLMOUNTPOINT/$BTRFSSUBVOLUMENAME-$WHEN
                fi
            done
        done

        if [[ $OSROOTBTRFSSUBVOLUMENAME ]]
        then
            # Making operating system's "/ (root)" snapshot default, with restart
            sudo btrfs subvolume set-default $(sudo btrfs subvolume list / | awk --assign=subvolume=$OSROOTBTRFSSUBVOLUMENAME-$WHEN --field-separator=' ' '$9==subvolume {print $2}') /

            # Making operating system's "/ (root)" snapshot bootable with GRUB (GRand Unified Bootloader) kernel parameter
            for BOOTLOADERENTRIESLOCATION in ${BOOTLOADERENTRIESLOCATIONS[@]}
            do
                for GRUBMENUENTRY in $(sudo ls $BOOTLOADERENTRIESLOCATION)
                do
                    sudo sed --in-place 's/rootflags=subvol='$OSROOTBTRFSSUBVOLUMENAME'/rootflags=subvol='$OSROOTBTRFSSUBVOLUMENAME'-'$WHEN'/' $BOOTLOADERENTRIESLOCATION/$GRUBMENUENTRY
                done
            done
        fi

        # Making snapshots bootable in File Systems Table
        for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
        do
            BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)

            for BTRFSSUBVOLUMENAME in $(sudo btrfs subvolume list $BTRFSMOUNTPOINT | awk --field-separator=" " '{print $9}')
            do
                if ! [[ $BTRFSSUBVOLUMENAME == */* || $BTRFSSUBVOLUMENAME == *-* ]]
                then
                    for FSTABLOCATION in ${FSTABLOCATIONS[@]}
                    do
                        sudo sed --in-place 's/subvol='$BTRFSSUBVOLUMENAME'/subvol='$BTRFSSUBVOLUMENAME'-'$WHEN'/' $FSTABLOCATION
                    done
                fi
            done
        done

        ManageBtrfs_UnmountPools

        echo "REMINDER: It is recommended to restart the system now!"
    else
        echo "Creating snapshots of Btrfs subvolumes skipped!"
    fi

    echo "Snapshots creating script completed!"
}

ManageBtrfs_RollbackSnapshots() {
    echo "Restoring snapshots of Btrfs subvolumes..."

    # Selecting previously used snapshotting logic
    echo "Standard restoring logic creates writeable snapshots of read-only snapshots of original subvolumes in a flat layout and switches to use them as default, with restart."
    echo "Alternative restoring logic switches to use original subvolumes as default, with restart."
    read -p "Use standard or alternative restoring logic? (s/a/ anything else to skip): "

    if [[ $REPLY =~ ^[Ss]$ ]]
    then
        WHEN=$(date +%y%m%d%H%M)

        ManageBtrfs_MountPools

        for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
        do
            BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)
            BTRFSPOOLMOUNTPOINT=$BTRFSPOOLSMOUNTPOINT/$(sudo btrfs filesystem label $BTRFSMOUNTPOINT)

            # Getting default subvolume's name
            DEFAULTBTRFSSUBVOLUMENAME=$(sudo btrfs subvolume get-default $BTRFSMOUNTPOINT | awk --field-separator=' ' '{print $9}')

            # Restoring only subvolumes that have been snapshotted
            for BTRFSSUBVOLUMESNAPSHOTNAME in $(sudo btrfs subvolume list $BTRFSMOUNTPOINT -s | awk --field-separator=' ' '{print $14}')
            do
                # Defining original subvolume name from its snapshot's name
                BTRFSSUBVOLUMENAME=$(echo $BTRFSSUBVOLUMESNAPSHOTNAME | awk --field-separator='-' '{print $1}')

                # Renaming original subvolumes
                sudo mv $BTRFSPOOLMOUNTPOINT/$BTRFSSUBVOLUMENAME $BTRFSPOOLMOUNTPOINT/old_$BTRFSSUBVOLUMENAME-$WHEN

                # Snapshoting read-only snapshots into writable subvolumes
                sudo btrfs subvolume snapshot $BTRFSPOOLMOUNTPOINT/$BTRFSSUBVOLUMENAME-* $BTRFSPOOLMOUNTPOINT/$BTRFSSUBVOLUMENAME
            done

            # Making snapshotted subvolume default, with restart
            sudo btrfs subvolume set-default $(sudo btrfs subvolume list $BTRFSMOUNTPOINT | awk --field-separator=' ' '$9=="'$DEFAULTBTRFSSUBVOLUMENAME'" {print $2}') $BTRFSMOUNTPOINT
        done

        ManageBtrfs_UnmountPools
    elif [[ $REPLY =~ ^[Aa]$ ]]
    then
        WHEN=$(echo $(sudo btrfs subvolume list / -s | awk --field-separator=' ' '{print $14}' | awk --field-separator='-' '{print $2}') | awk --field-separator=' ' '{print $1}')

        ManageBtrfs_MountPools
        ManageBtrfs_DefineMountPoints

        for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
        do
            BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)

            # Getting original default subvolume's name from current default snapshot's name
            DEFAULTBTRFSSUBVOLUMENAME=$(sudo btrfs subvolume get-default $BTRFSMOUNTPOINT | awk --field-separator=' ' '{print $9}' | awk --field-separator='-' '{print $1}')

            # Making original default subvolume default, with restart
            sudo btrfs subvolume set-default $(sudo btrfs subvolume list $BTRFSMOUNTPOINT | awk --field-separator=' ' '$9=="'$DEFAULTBTRFSSUBVOLUMENAME'" {print $2}') $BTRFSMOUNTPOINT
        done

        # Making original operating system's "/ (root)" subvolume bootable with GRUB (GRand Unified Bootloader) kernel parameter
        if [[ $OSROOTBTRFSSUBVOLUMENAME ]]
        then
            for BOOTLOADERENTRIESLOCATION in ${BOOTLOADERENTRIESLOCATIONS[@]}
            do
                for GRUBMENUENTRY in $(sudo ls $BOOTLOADERENTRIESLOCATION)
                do
                    sudo sed --in-place 's/rootflags=subvol='$OSROOTBTRFSSUBVOLUMENAME'-........../rootflags=subvol='$OSROOTBTRFSSUBVOLUMENAME'/' $BOOTLOADERENTRIESLOCATION/$GRUBMENUENTRY
                done
            done
        fi

        # Making original subvolumes bootable in File Systems Table
        for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
        do
            BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)

            for BTRFSSUBVOLUMENAME in $(sudo btrfs subvolume list $BTRFSMOUNTPOINT | awk --field-separator=" " '{print $9}')
            do
                if ! [[ $BTRFSSUBVOLUMENAME == */* || $BTRFSSUBVOLUMENAME == *-* ]]
                then
                    for FSTABLOCATION in ${FSTABLOCATIONS[@]}
                    do
                        sudo sed --in-place 's/subvol='$BTRFSSUBVOLUMENAME'-........../subvol='$BTRFSSUBVOLUMENAME'/' $FSTABLOCATION
                    done
                fi
            done
        done

        ManageBtrfs_UnmountPools
    else
        echo "Restoring snapshots of Btrfs subvolumes skipped!"
    fi

    echo "REMINDER: It is recommended to restart the system now!"
    echo "Snapshots restoring script completed!"
}

ManageBtrfs_DeleteSnapshots() {
    echo "Deleting snapshots of Btrfs subvolumes..."

    ManageBtrfs_MountPools

    for BTRFSDEVICE in $(findmnt --types btrfs --output "SOURCE" --noheadings --nofsroot --list | uniq)
    do
        BTRFSMOUNTPOINT=$(findmnt --source "$BTRFSDEVICE" --types btrfs --output "TARGET" --noheadings --nofsroot --first-only)
        BTRFSPOOLMOUNTPOINT=$BTRFSPOOLSMOUNTPOINT/$(sudo btrfs filesystem label $BTRFSMOUNTPOINT)

        for BTRFSSUBVOLUMENAME in $(sudo btrfs subvolume list $BTRFSMOUNTPOINT | awk --field-separator=' ' '{print $9}')
        do
            if [[ $BTRFSSUBVOLUMENAME == *-* ]]
            then
                # Deleting snapshots of Btrfs subvolumes
                sudo btrfs subvolume delete $BTRFSPOOLMOUNTPOINT/$BTRFSSUBVOLUMENAME
            fi
        done
    done

    ManageBtrfs_UnmountPools

    echo "Snapshots deleting script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all maintenance options or 3-8 to select an option to run: "

    select options in "EXIT" "RUN ALL MAINTENANCE OPTIONS" "Scrub" "Defragment" "Balance" "Take snapshots" "Rollback snapshots" "Delete snapshots"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL MAINTENANCE OPTIONS" )
                ManageBtrfs_Scrub
                ManageBtrfs_Defragment
                ManageBtrfs_Balance
                exit 0;;
            "Scrub" )
                ManageBtrfs_Scrub
                Menu;;
            "Defragment" )
                ManageBtrfs_Defragment
                Menu;;
            "Balance" )
                ManageBtrfs_Balance
                Menu;;
            "Take snapshots" )
                ManageBtrfs_TakeSnapshots
                Menu;;
            "Rollback snapshots" )
                ManageBtrfs_RollbackSnapshots
                Menu;;
            "Delete snapshots" )
                ManageBtrfs_DeleteSnapshots
                Menu;;
        esac
    done
}



COLUMNS=1

Menu
