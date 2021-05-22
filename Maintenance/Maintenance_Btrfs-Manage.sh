#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



ManageBtrfs_Scrub() {
    echo "Scrubbing Btrfs subvolumes..."

    # Checking integrity of the file system and reporting corrupted blocks and automatically repairing corrupted blocks if a correct copy is available.
    sudo btrfs scrub start /
    sudo btrfs scrub start $HOME

    echo "Btrfs subvolumes scrubbing script completed!"
}

ManageBtrfs_Defragment() {
    echo "Defragmenting Btrfs file systems..."

    # Merging file extents in the file system 
    sudo btrfs filesystem defragment -r /
    sudo btrfs filesystem defragment -r $HOME

    echo "Btrfs file systems defragmenting script completed!"
}

ManageBtrfs_Balance() {
    echo "Balancing Btrfs file systems..."

    # Reporting pre-balancing file system balance state
    sudo btrfs filesystem df /
    sudo btrfs filesystem df $HOME

    # Spreading block groups across all devices so they match constraints defined by the respective profiles.
    sudo btrfs balance start /
    sudo btrfs balance start $HOME

    # Reporting post-balancing file system balance state
    sudo btrfs filesystem df /
    sudo btrfs filesystem df $HOME

    echo "REMINDER: It is recommended to trim the SSD now!"
    echo "Btrfs file systems balancing script completed!"
}

ManageBtrfs_MountPools() {
    # Creating mount points
    sudo mkdir /btrfs_pool
    sudo mkdir $HOME/btrfs_pool

    # Defining Btrfs file systems by universally unique identifier (UUID) of disk partitions
    ROOTPOOL=$(sudo blkid --match-tag UUID --output value /dev/sda4)
    HOMEPOOL=$(sudo blkid --match-tag UUID --output value /dev/sda5)

    # Mounting real Btrfs roots of defined Btrfs file systems
    sudo mount -o subvolid=5 /dev/mapper/luks-$ROOTPOOL /btrfs_pool
    sudo mount -o subvolid=5 /dev/mapper/luks-$HOMEPOOL $HOME/btrfs_pool
}

ManageBtrfs_UnmountPools() {
    # Unmounting real Btrfs roots
    sudo umount /btrfs_pool
    sudo umount $HOME/btrfs_pool

    # Removing mount points
    sudo rmdir /btrfs_pool
    sudo rmdir $HOME/btrfs_pool
}

ManageBtrfs_TakeSnapshots() {
    echo "Creating snapshots of Btrfs subvolumes..."

    ManageBtrfs_MountPools

    # Taking snapshots of subvolumes (in a flat layout)
    sudo btrfs subvolume snapshot -r /btrfs_pool/root /btrfs_pool/root-$(date +%y%m%d)
    sudo btrfs subvolume snapshot -r /btrfs_pool/var /btrfs_pool/var-$(date +%y%m%d)
    sudo btrfs subvolume snapshot -r $HOME/btrfs_pool/$(whoami) $HOME/btrfs_pool/$(whoami)-$(date +%y%m%d)

    ManageBtrfs_UnmountPools

    echo "Snapshots creation script completed!"
}

ManageBtrfs_RollbackSnapshots() {
    echo "Restoring snapshots of Btrfs subvolumes..."

    ManageBtrfs_MountPools

    # Renaming active subvolumes
    sudo mv /btrfs_pool/root /btrfs_pool/old_root-$(date +%y%m%d)
    sudo mv /btrfs_pool/var /btrfs_pool/old_var-$(date +%y%m%d)
    sudo mv $HOME/btrfs_pool/$(whoami) $HOME/btrfs_pool/old_$(whoami)-$(date +%y%m%d)

    # Snapshoting read-only snapshots into writable subvolumes that will become active after restart
    sudo btrfs subvolume snapshot /btrfs_pool/root-* /btrfs_pool/root
    sudo btrfs subvolume snapshot /btrfs_pool/var-* /btrfs_pool/var
    sudo btrfs subvolume snapshot $HOME/btrfs_pool/$(whoami)-* $HOME/btrfs_pool/$(whoami)

    ManageBtrfs_UnmountPools

    echo "REMINDER: It is recommended to restart the system now!"
    echo "Snapshots restoration script completed!"
}

ManageBtrfs_DeleteSnapshots() {
    echo "Deleting snapshots of Btrfs subvolumes..."

    ManageBtrfs_MountPools

    # Deleting old subvolumes
    sudo btrfs subvolume delete /btrfs_pool/old_root-*
    sudo btrfs subvolume delete /btrfs_pool/old_var-*
    sudo btrfs subvolume delete $HOME/btrfs_pool/old_$(whoami)-*

    # Deleting snapshots of subvolumes
    sudo btrfs subvolume delete /btrfs_pool/root-*
    sudo btrfs subvolume delete /btrfs_pool/var-*
    sudo btrfs subvolume delete $HOME/btrfs_pool/$(whoami)-*

    ManageBtrfs_UnmountPools

    echo "Snapshots deletion script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2-3 to run all destructive or constructive options or 4-9 to select an option to run: "

    select options in "EXIT" "RUN ALL DESTRUCTIVE OPTIONS" "RUN ALL CONSTRUCTIVE OPTIONS" "Scrub" "Defragment" "Balance" "Take snapshots" "Rollback snapshots" "Delete snapshots"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL DESTRUCTIVE OPTIONS" )
                ManageBtrfs_RollbackSnapshots
                ManageBtrfs_DeleteSnapshots
                exit 0;;
            "RUN ALL CONSTRUCTIVE OPTIONS" )
                ManageBtrfs_Scrub
                ManageBtrfs_Defragment
                ManageBtrfs_Balance
                ManageBtrfs_TakeSnapshots
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
WORKINGDIRECTORY="$(pwd)/Maintenance"

Menu
