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
            'tsflags=nodocs' \
            '' \
            'clean_requirements_on_remove=True' \
            'keepcache=False' \
            '' \
            'installonly_limit=$KERNELSTOKEEP' \
            '' \
            'gpgcheck=True' \
            'repo_gpgcheck=True' \
            '' \
            'fastestmirror=True' \
            'max_parallel_downloads=$CONNECTIONS' \
            'deltarpm=True' \
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

Install_Repositories-Supplementary() {
    echo "Installing supplementary repositories..."

    # Importing or installing "Intel OpenCL" repository
    if [[ -f "$WORKINGDIRECTORY"/Repositories/intel-opencl.repo ]]
    then
        sudo cp "$WORKINGDIRECTORY"/Repositories/intel-opencl.repo /etc/yum.repos.d/
    else
        sudo dnf copr enable --assumeyes jdanecki/intel-opencl
    fi

    # Importing or creating "Microsoft Visual Studio Code" repository
    if [[ -f "$WORKINGDIRECTORY"/Repositories/vscode.repo ]]
    then
        sudo cp "$WORKINGDIRECTORY"/Repositories/vscode.repo /etc/yum.repos.d/
    else
        sudo sh -c "printf '%s\n' \
            '[vscode]' \
            'name=Visual Studio Code' \
            'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
            'enabled=1' \
            'gpgcheck=1' \
            'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' > /etc/yum.repos.d/vscode.repo"
    fi

    # Importing or creating "Skype" repository
    if [[ -f "$WORKINGDIRECTORY"/Repositories/skype-stable.repo ]]
    then
        sudo cp "$WORKINGDIRECTORY"/Repositories/skype-stable.repo /etc/yum.repos.d/
    else
        sudo sh -c "printf '%s\n' \
            '[skype]' \
            'name=Skype' \
            'baseurl=https://repo.skype.com/rpm/stable/' \
            'enabled=1' \
            'gpgcheck=1' \
            'gpgkey=gpgkey=https://repo.skype.com/data/SKYPE-GPG-KEY' > /etc/yum.repos.d/skype-stable.repo"
    fi

    # Importing or creating "TeamViewer" repository
    if [[ -f "$WORKINGDIRECTORY"/Repositories/teamviewer.repo ]]
    then
        sudo cp "$WORKINGDIRECTORY"/Repositories/teamviewer.repo /etc/yum.repos.d/
    else
        sudo sh -c "printf '%s\n' \
            '[teamviewer]' \
            'name=TeamViewer' \
            'baseurl=https://linux.teamviewer.com/yum/stable/main/binary-\$basearch/' \
            'type=rpm-md' \
            'enabled=1' \
            'failovermethod=priority' \
            'gpgcheck=1' \
            'repo-gpgcheck=1' \
            'gpgkey=https://linux.teamviewer.com/pubkey/currentkey.asc' > /etc/yum.repos.d/teamviewer.repo"
    fi

    echo "Supplementary repositories installing script completed!"
}

Install_SoftwareFromRepositories-Pre-selected() {
    echo "Installing pre-selected software from repositories..."

    # Installing core operating system components
    sudo dnf install --assumeyes akmods kernel-devel kernel-headers tlp
    sudo dnf install --assumeyes compsize exfat-utils smartmontools sysfsutils udisks2-btrfs xfsprogs-xfs_scrub
    sudo dnf install --assumeyes cabextract libzip lzip p7zip p7zip-plugins unrar

    # Installing Intel chipset drivers and components
    [[ -f /etc/yum.repos.d/intel-opencl.repo ]] && sudo dnf install --assumeyes intel-opencl
    sudo dnf install --assumeyes intel-media-driver libva-intel-driver libva-intel-hybrid-driver

    # Installing PulseAudio components
    sudo dnf install --assumeyes pulseeffects

    # Install networking components
    sudo dnf install --assumeyes gvfs-nfs

    # Installing GNOME desktop environment components
    sudo dnf install --assumeyes bijiben gnome-books gnome-documents gnome-music gnome-nettool gnome-sound-recorder gnome-todo gnome-tweak-tool gnome-usage
    sudo dnf install --assumeyes gnome-password-generator gnome-passwordsafe
    sudo dnf install --assumeyes seahorse seahorse-nautilus
    sudo dnf install --assumeyes gnome-shell-extension-dash-to-dock gnome-shell-extension-system-monitor-applet
    sudo dnf install --assumeyes nautilus-image-converter raw-thumbnailer
    sudo dnf install --assumeyes gedit-code-assistance gedit-color-schemes gedit-plugin-bookmarks gedit-plugin-bracketcompletion gedit-plugin-charmap gedit-plugin-codecomment gedit-plugin-colorpicker gedit-plugin-colorschemer gedit-plugin-findinfiles gedit-plugin-multiedit gedit-plugin-terminal gedit-plugin-textsize gedit-plugin-wordcompletion

    # Installing productivity components
    sudo dnf install --assumeyes adobe-source-code-pro-fonts adobe-source-sans-pro-fonts adobe-source-serif-pro-fonts bitmap-console-fonts bitmap-fixed-fonts bitmap-lucida-typewriter-fonts bitstream-vera-sans-fonts bitstream-vera-sans-mono-fonts bitstream-vera-serif-fonts comic-neue-angular-fonts comic-neue-fonts dejavu-lgc-sans-fonts dejavu-lgc-sans-mono-fonts dejavu-lgc-serif-fonts entypo-fonts fontawesome-fonts google-droid-sans-fonts google-droid-sans-mono-fonts google-droid-serif-fonts google-noto-emoji-fonts google-noto-sans-fonts google-noto-serif-fonts google-roboto-condensed-fonts google-roboto-fonts google-roboto-slab-fonts liberation-fonts liberation-narrow-fonts libreoffice-opensymbol-fonts linux-libertine-biolinum-fonts linux-libertine-fonts mozilla-fira-mono-fonts mozilla-fira-sans-fonts oldstandard-sfd-fonts open-sans-fonts oxygen-fonts urw-base35-fonts
    sudo dnf install --assumeyes scribus
    [[ -f /etc/yum.repos.d/vscode.repo ]] && sudo dnf install --assumeyes code
    sudo dnf install --assumeyes thunderbird transmission
    [[ -f /etc/yum.repos.d/skype.repo ]] && sudo dnf install --assumeyes skypeforlinux
    [[ -f /etc/yum.repos.d/teamviewer.repo ]] && sudo dnf install --assumeyes teamviewer

    # Installing multimedia components
    sudo dnf install --assumeyes foliate
    sudo dnf install --assumeyes libopenraw-pixbuf-loader libwebp-tools xcf-pixbuf-loader webp-pixbuf-loader
    sudo dnf install --assumeyes darktable shotwell
    sudo dnf install --assumeyes gimp gimp-data-extras gimp-dbp gimp-dds-plugin gimp-elsamuko gimp-focusblur-plugin gimp-fourier-plugin gimp-heif-plugin gimp-help gimp-high-pass-filter gimp-layer-via-copy-cut gimp-lensfun gimp-resynthesizer gimp-lqr-plugin gimp-luminosity-masks gimp-paint-studio gimp-save-for-web gimp-separate+ gimp-wavelet-decompose gimp-wavelet-denoise-plugin gimpfx-foundry ufraw-gimp
    sudo dnf install --assumeyes inkscape

    read -p "Would you like to install legacy GStreamer? (y/ anything else to n) (default: n): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        sudo dnf install --assumeyes gstreamer{,1}-{libav,svt{-av1,-vp9},vaapi,plugin-{crystalhd,openh264},plugins-{entrans,espeak,fc,{good,bad,ugly}{,-free,-freeworld,-nonfree,-extras}{,-extras,-gtk,-qt,-wildmidi,-fluidsynth,-zbar}}} --setopt=strict=0
    else
        sudo dnf install --assumeyes gstreamer1-{libav,svt{-av1,-hevc,-vp9},vaapi,plugin-openh264,plugins-{entrans,{good,bad,ugly}{,-free,-nonfree,-extras}{,-extras,-gtk,-qt,-fluidsynth}}} --setopt=strict=0
    fi

    sudo dnf install --assumeyes x264 x265
    sudo dnf install --assumeyes vlc vlc-core vlc-extras
    sudo dnf install --assumeyes ffmpeg handbrake handbrake-gui lame soundconverter
    sudo dnf install --assumeyes flowblade
    sudo dnf install --assumeyes picard

    # Installing gaming support components
    sudo dnf install --assumeyes steam

    echo "Pre-selected software from repositories installation script completed!"
}

Install_SoftwareFromRepositories-Listed() {
    echo "Installing listed software from repositories..."

    read -p "Would you like to install a pre-selected or a custom list of software form repositories? (p/c/ anything else to skip): "

    if [[ $REPLY =~ ^[Pp]$ ]]
    then
        sudo dnf install --assumeyes $(grep "^[^#]" "$WORKINGDIRECTORY"/Configuration_Packages-UserInstalled-Pre-selected.list)
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

    PS3="Press 1 to exit, 2 to run all options or 3-7 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Configure DNF package manager" "Install repositories" "Install supplementary repositories" "Install pre-selected software from repositories" "Install listed software from repositories"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Configure_DNF
                Install_Repositories
                Install_Repositories-Supplementary
                Install_SoftwareFromRepositories-Pre-selected
                Install_SoftwareFromRepositories-Listed
                exit 0;;
            "Configure DNF package manager" )
                Configure_DNF
                Menu;;
            "Install repositories" )
                Install_Repositories
                Menu;;
            "Install supplementary repositories" )
                Install_Repositories-Supplementary
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
