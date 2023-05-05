#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Configure_DNF() {
    echo "Configuring DNF package manager..."

    # Importing or configuring DNF package manager settings
    if [[ -f "$WORKINGDIRECTORY"/../../Pre-installation/Settings/System/dnf.conf ]]
    then
        sudo cp "$WORKINGDIRECTORY"/../../Pre-installation/Settings/System/dnf.conf /etc/dnf/
    else
        read -p "Type the number of superseded (old) Kernels to keep (default: 2): " SUPERSEDEDKERNELS
        read -p "Type the highest number of parallel connections for DNF to make to repostories: (default: 3, recommended: 8): " CONNECTIONS

        KERNELSTOKEEP=$(($SUPERSEDEDKERNELS+1))

        sudo sh -c "printf '%s\n' \
            '[main]' \
            'best=True' \
            '' \
            'clean_requirements_on_remove=True' \
            'keepcache=False' \
            '' \
            'installonly_limit=$KERNELSTOKEEP' \
            '' \
            'gpgcheck=True' \
            'repo_gpgcheck=True' \
            '' \
            'fastestmirror=False' \
            'max_parallel_downloads=$CONNECTIONS' \
            'deltarpm=False' \
            '' \
            'skip_if_unavailable=False' > /etc/dnf/dnf.conf"
    fi

    echo "DNF package manager configuration script completed!"
}

Install_Repositories() {
    echo "Installing repositories..."

    sudo dnf config-manager --set-enabled fedora-cisco-openh264

    sudo dnf install --assumeyes https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    echo "Repository installation script completed!"
}

Install_Package() {
    # Asking whether to install each package separately
    for PACKAGE in $*
    do
        read -p "Would you like to install \"$PACKAGE\"? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo dnf install --assumeyes $PACKAGE
        else
            echo "Installing \"$PACKAGE\" skipped!" 
        fi
    done
}

Install_Packages() {
    # Asking whether to install all packages together
    read -p "Would you like to install \"$*\"? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        sudo dnf install --assumeyes $*
    else
        echo "Installing \"$*\" skipped!" 
    fi
}

Install_SoftwareFromRepositories-Pre-selected() {
    echo "Installing pre-selected software from repositories..."

    # Installing core operating system components
    sudo dnf install --assumeyes akmods kernel-devel kernel-headers
    sudo dnf install --assumeyes smartmontools sysfsutils udisks2-btrfs xfsprogs-xfs_scrub
    sudo dnf install --assumeyes cabextract lzip p7zip p7zip-plugins unrar

    # Installing chipset drivers and video components
    if [[ $(glxinfo -B | awk --field-separator=": " '/OpenGL vendor string/ {print $2}') = "Intel" ]]
    then
        sudo dnf install --assumeyes intel-media-driver igt-gpu-tools libva-intel-driver libva-intel-hybrid-driver libva-utils libva-vdpau-driver

        # Importing or installing "Intel OpenCL" repository
        if [[ -f "$WORKINGDIRECTORY"/Repositories/intel-opencl.repo ]]
        then
            sudo cp "$WORKINGDIRECTORY"/Repositories/intel-opencl.repo /etc/yum.repos.d/
        else
            sudo dnf copr enable --assumeyes jdanecki/intel-opencl
        fi

        # Installing "Intel OpenCL"
        sudo dnf install --assumeyes intel-opencl
    fi

    # Installing PipeWire audio components
    sudo dnf install --assumeyes easyeffects

    # Installing networking components
    sudo dnf install --assumeyes gvfs-nfs

    # Installing GNOME desktop environment components
    sudo dnf install --assumeyes gnome-power-manager
    sudo dnf install --assumeyes bijiben file-roller{,-nautilus} gnome-{backgrounds-extras,feeds,music,nettool,network-displays,sound-recorder,todo,tweaks,usage}
    sudo dnf install --assumeyes gnome-password-generator seahorse{,-nautilus} secrets

    read -p "Would you like to install \"gedit\" with pre-selected or all plug-ins? (p/a/ anything else to skip) (recommended: p): "

    if [[ $REPLY =~ ^[Pp]$ ]]
    then
        sudo dnf install --assumeyes gedit gedit-color-schemes gedit-plugin-{bookmarks,bracketcompletion,charmap,codecomment,colorpicker,colorschemer,findinfiles,joinlines,multiedit,smartspaces,textsize,wordcompletion}
    elif [[ $REPLY =~ ^[Aa]$ ]]
    then
        sudo dnf install --assumeyes gedit gedit-plugins
    else
        echo "Installing \"gedit\" skipped!" 
    fi

    read -p "Would you like to install pre-selected GNOME Shell extensions? (y/ anything else to skip): (recommended: y): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Installing GNOME Shell extensions from repositories
        sudo dnf install --assumeyes gnome-extensions-app gnome-shell-extension-{caffeine,dash-to-dock,netspeed,user-theme}
        
        # Importing GNOME Shell extensions previously installed from archives
        GNOMESHELLEXTENSIONSBACKUPFILENAME="Backup_GNOMEShellExtensions.tar.zst"
        GNOMESHELLEXTENSIONSBACKUPFILELOCATION="$(pwd)/Pre-installation/Settings/User/$GNOMESHELLEXTENSIONSBACKUPFILENAME"
        GNOMESHELLEXTENSIONSLOCATION="$HOME/.local/share/gnome-shell/extensions"

        if [[ -f $GNOMESHELLEXTENSIONSBACKUPFILELOCATION ]]
        then
            if ! [[ -f $GNOMESHELLEXTENSIONSLOCATION ]]
            then
                mkdir --parents $GNOMESHELLEXTENSIONSLOCATION
            fi

            tar --extract --zstd --xattrs --file=$GNOMESHELLEXTENSIONSBACKUPFILELOCATION --directory $GNOMESHELLEXTENSIONSLOCATION
        fi
    else
        echo "Installing GNOME Shell extensions skipped!"
    fi

    # Installing productivity components
    sudo dnf install --assumeyes adobe-source-{sans-pro,serif-pro}-fonts bitmap-{console,fixed,lucida-typewriter}-fonts bitstream-vera-{sans,sans-mono,serif}-fonts comic-neue{,-angular}-fonts dejavu-lgc-{sans,sans-mono,serif}-fonts entypo-fonts fontawesome-fonts gnu-free-{mono,sans,serif}-fonts google-droid-{sans-mono,serif}-fonts google-noto-{emoji,sans,serif}-fonts google-roboto{,-condensed,-slab}-fonts liberation{,-narrow}-fonts linux-libertine{,-biolinum}-fonts mozilla-fira-{mono,sans}-fonts oldstandard-sfd-fonts open-sans-fonts oxygen{,-mono,-sans}-fonts
    sudo dnf install --assumeyes thunderbird transmission
    Install_Package foliate scribus

    # Installing multimedia components
    sudo dnf install --assumeyes {avif,libopenraw}-pixbuf-loader libwebp-tools
    sudo dnf install --assumeyes ffmpegthumbnailer raw-thumbnailer
    Install_Package shotwell darktable inkscape

    read -p "Would you like to install \"GIMP\" with pre-selected or all plug-ins? (p/a/ anything else to skip) (recommended: a): "

    if [[ $REPLY =~ ^[Pp]$ ]]
    then
        sudo dnf install --assumeyes gimp gimp-{data-extras,help,jxl-plugin,save-for-web} ufraw-gimp
    elif [[ $REPLY =~ ^[Aa]$ ]]
    then
        sudo dnf install --assumeyes gimp gimp-{data-extras,dds-plugin,elsamuko,fourier-plugin,help,high-pass-filter,jxl-plugin,layer-via-copy-cut,lensfun,lqr-plugin,luminosity-masks,paint-studio,resynthesizer,save-for-web,separate+,wavelet-decompose,wavelet-denoise-plugin} gimpfx-foundry ufraw-gimp
    else
        echo "Installing \"GIMP\" skipped!" 
    fi

    read -p "Would you like to install pre-selected or all \"GStreamer\" plug-ins? (p/a/ anything else to skip): (recommended: p): "

    if [[ $REPLY =~ ^[Pp]$ ]]
    then
        sudo dnf install --assumeyes gstreamer1-{plugin-openh264,plugins-{bad-free-extras},good-extras,ugly},svt{-av1,-vp9},vaapi}
    elif [[ $REPLY =~ ^[Aa]$ ]]
    then
        sudo dnf install --assumeyes gst-entrans gstreamer-{plugin-crystalhd,plugins-espeak} gstreamer1-{plugin-openh264,plugins-{bad-free{-extras,-fluidsynth,-wildmidi,-zbar},entrans,fc,good{,-extras,-gtk,-qt},ugly},svt{-av1,-vp9},vaapi} --setopt=strict=0
    else
        echo "Installing \"GStreamer\" plug-ins skipped!"
    fi

    sudo dnf install --assumeyes x264 x265 --allowerasing
    sudo dnf install --assumeyes celluloid vlc{,-core,-extras}
    sudo dnf install --assumeyes lame soundconverter
    Install_Packages handbrake{,-gui}

    # Installing gaming support components
    Install_Package steam

    echo "Pre-selected software from repositories installation script completed!"
}

Install_SoftwareFromRepositories-Listed() {
    echo "Installing listed software from repositories..."

    read -p "Would you like to install a pre-selected, a user pre-defined or a custom list of software form repositories? (p/u/c/ anything else to skip): "

    if [[ $REPLY =~ ^[Pp]$ ]]
    then
        sudo dnf install --assumeyes $(grep "^[^#]" "$WORKINGDIRECTORY"/Configuration_Packages-UserInstalled-Pre-selected.list)
    elif [[ $REPLY =~ ^[Uu]$ ]]
    then
        sudo dnf install --assumeyes $(grep "^[^#]" "$WORKINGDIRECTORY"/Configuration_Packages-UserInstalled.list)
    elif [[ $REPLY =~ ^[Cc]$ ]]
    then
        read -p "Type the name (with extension) of a custom list of software to be installed from repositories: " "PACKAGELIST"

        sudo dnf install $(grep "^[^#]" "$WORKINGDIRECTORY"/"$PACKAGELIST")
    else
        echo "Installing listed software form repositories skipped!"
    fi

    echo "Listed software from repositories installation script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Configure DNF package manager" "Install repositories" "Install pre-selected software from repositories" "Install listed software from repositories"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Configure_DNF
                Install_Repositories
                Install_SoftwareFromRepositories-Pre-selected
                Install_SoftwareFromRepositories-Listed
                exit 0;;
            "Configure DNF package manager" )
                Configure_DNF
                Menu;;
            "Install repositories" )
                Install_Repositories
                Menu;;
            "Install pre-selected software from repositories" )
                Install_SoftwareFromRepositories-Pre-selected
                Menu;;
            "Install listed software from repositories" )
                Install_SoftwareFromRepositories-Listed
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Installation/Software"

Menu
