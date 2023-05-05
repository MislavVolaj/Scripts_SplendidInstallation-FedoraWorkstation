#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Configure_GTK4Appearance() {
    GTK4CONFIGURATIONDIRECTORY="$HOME"/.config/gtk-4.0/
    GTK4CONFIGURATIONFILENAME=settings.ini
    GTK4CONFIGURATIONFILE=$GTK4CONFIGURATIONDIRECTORY/$GTK4CONFIGURATIONFILENAME

    if [[ ! -d $GTK4CONFIGURATIONDIRECTORY ]]
    then
        mkdir --parents $GTK4CONFIGURATIONDIRECTORY
    fi

    if [[ -f $GTK4CONFIGURATIONFILE ]]
    then
        if [[ ! $(grep $GTK4CONFIGURATION=1 $GTK4CONFIGURATIONFILE) ]]
        then
            sed --in-place '/'$GTK4CONFIGURATION'/d' $GTK4CONFIGURATIONFILE
            echo $GTK4CONFIGURATION=1 >> $GTK4CONFIGURATIONFILE
        fi
    else
        if [[ -f $USERSETTINGSDIRECTORY/$GTK4CONFIGURATIONFILENAME ]]
        then
            cp $USERSETTINGSDIRECTORY/$GTK4CONFIGURATIONFILENAME $GTK4CONFIGURATIONDIRECTORY

            if [[ ! $(grep $GTK4CONFIGURATION=1 $GTK4CONFIGURATIONFILE) ]]
            then
                sed --in-place '/'$GTK4CONFIGURATION'/d' $GTK4CONFIGURATIONFILE
                echo $GTK4CONFIGURATION=1 >> $GTK4CONFIGURATIONFILE
            fi
        else
            echo $GTK4CONFIGURATION=1 > $GTK4CONFIGURATIONFILE
        fi
    fi
}

Install_Fonts() {
    echo "Installing fonts..."

    if [[ -f "$WORKINGDIRECTORY"/Fonts/Fonts_Google.tar.zst ]]
    then
        read -p "Would you like to install Google fonts? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            mkdir --parents "$HOME"/.local/share/fonts/Google

            tar --extract --zstd --file="$WORKINGDIRECTORY"/Fonts/Fonts_Google.tar.zst --directory "$HOME"/.local/share/fonts/Google/

            echo "Google fonts installing script completed!"
        else
            echo "Installing Google fonts skipped!"
        fi
    fi

    if [[ -f "$WORKINGDIRECTORY"/Fonts/Fonts_Microsoft.tar.zst ]]
    then
        read -p "Would you like to install Microsoft fonts? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            mkdir --parents "$HOME"/.local/share/fonts/Microsoft

            tar --extract --zstd --file="$WORKINGDIRECTORY"/Fonts/Fonts_Microsoft.tar.zst --directory "$HOME"/.local/share/fonts/Microsoft/

            echo "Microsoft fonts installing script completed!"
        else
            echo "Installing Microsoft fonts skipped!"
        fi
    fi

    read -p "Would you like to install \"Better fonts\"? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then

        # Importing or installing "Better fonts" repository
        if [[ -f "$WORKINGDIRECTORY"/../../Installation/Software/Repositories/better_fonts.repo ]]
        then
            sudo cp "$WORKINGDIRECTORY"/../../Installation/Software/Repositories/better_fonts.repo /etc/yum.repos.d/
        else
            sudo dnf copr enable --assumeyes dawid/better_fonts
        fi

        # Installing "Better fonts" from repository
        sudo dnf install --assumeyes fontconfig-font-replacements fontconfig-enhanced-defaults

        echo "\"Better fonts\" installing script completed!"
    else
        echo "Installing \"Better fonts\" skipped!"
    fi

    # Rebuilding font information cache
    sudo fc-cache --really-force

    echo "Fonts installing script completed!"
}

Configure_Fonts() {
    echo "Configuring fonts..."

    read -p "Would you like to import font rendering settings? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        if [[ -f "$SYSTEMSETTINGSDIRECTORY"/local.conf ]]
        then
            sudo cp "$SYSTEMSETTINGSDIRECTORY"/local.conf /etc/fonts/
            
            echo "Font rendering settings importing script completed!"
        else
            echo "Importing font rendering settings skipped because the configuration file is missing!"
        fi
    else
        echo "Importing font rendering settings skipped!"
    fi

    read -p "Would you like to correct GTK4 font rendering? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Correcting GTK4 font rendering..."

        GTK4CONFIGURATION="gtk-hint-font-metrics"

        Configure_GTK4Appearance

        echo "GTK4 font rendering correcting script completed!"
    else
        echo "Correcting GTK4 font rendering skipped!"
    fi

    read -p "Would you like to restore default \"Cantarell\" fonts or apply \"Noto\" or \"Roboto\" fonts? (c/n/r/ anything else to skip): "

    if [[ $REPLY =~ ^[Cc]$ ]]
    then
        # Configuring system-wide fonts
        gsettings set org.gnome.desktop.interface document-font-name 'Cantarell Regular 11'
        gsettings set org.gnome.desktop.interface font-name 'Cantarell Regular 11'
        gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
        gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Cantarell Bold 11'

        # Configuring applications' fonts
        gsettings set org.gnome.Notes font 'Cantarell 14'

        echo "\"Cantarell\" fonts restored!"
    elif [[ $REPLY =~ ^[Nn]$ ]]
    then
        # Configuring system-wide fonts
        gsettings set org.gnome.desktop.interface document-font-name 'Noto Sans Regular 11'
        gsettings set org.gnome.desktop.interface font-name 'Noto Sans Regular 11'
        gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
        gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Noto Sans Bold 11'

        # Configuring applications' fonts
        gsettings set org.gnome.Notes font 'Noto Sans Regular 14'

        echo "\"Noto\" fonts applied!"
    elif [[ $REPLY =~ ^[Rr]$ ]]
    then
        # Configuring system-wide fonts
        gsettings set org.gnome.desktop.interface document-font-name 'Roboto Regular 11'
        gsettings set org.gnome.desktop.interface font-name 'Roboto Regular 11'
        gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
        gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Roboto Bold 11'

        # Configuring applications' fonts
        gsettings set org.gnome.Notes font 'Roboto 14'

        echo "\"Roboto\" fonts applied!"
    else
        echo "Fonts not changed!"
    fi

    echo "Fonts configuring script completed!"
} 

Install_UserIcon() {
    echo "Installing user icons..."

    # Installing a user icon, if it exists
    [[ -f "$WORKINGDIRECTORY"/Icons/$(whoami).jpg ]] && sudo cp "$WORKINGDIRECTORY"/Icons/$(whoami).jpg /usr/share/pixmaps/faces/

    echo "REMINDER: Select a user icon in Settings!"
    echo "User icons installing script completed!"
}

Install_InterfaceThemes() {
    echo "Installing interface themes..."

    read -p "Would you like to install \"Graphite\" interface theme? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Downloading Graphite interface theme if it is not present
        if [[ ! -f "$WORKINGDIRECTORY"/Themes/Graphite-gtk-theme-main.zip ]]
        then
            echo "Downloading \"Graphite\" interface theme..."

            wget --quiet https://github.com/vinceliuice/Graphite-gtk-theme/archive/refs/heads/main.zip --output-document="$WORKINGDIRECTORY"/Themes/Graphite-gtk-theme-main.zip
        fi

        # Extracting Graphite interface theme into temporary folder
        echo "Extracting \"Graphite\" interface theme..."

        unzip -o -q $WORKINGDIRECTORY/Themes/Graphite-gtk-theme-main.zip -d /tmp/

        # Installing Graphite interface theme dependencies
        echo "Installing dependencies..."
        sudo dnf install --assumeyes gtk-murrine-engine sassc

        # Installing Graphite interface theme 
        echo "Installing \"Graphite\" interface theme..."

        /tmp/Graphite-gtk-theme-main/./install.sh --libadwaita --tweaks nord normal

        # Installing Graphite GNOME Display Manager theme
        read -p "Would you like to install \"Graphite\" GNOME Display Manager theme? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo "Installing \"Graphite\" GNOME Display Manager theme..."

            sudo /tmp/Graphite-gtk-theme-main/./install.sh --gdm --tweaks nord normal
        else
            echo "Installing \"Graphite\" GNOME Display Manager theme skipped!"
        fi

        # Installing Graphite GRand Unified Bootloader theme
        read -p "Would you like to install \"Graphite\" GRand Unified Bootloader theme? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo "Installing \"Graphite\" GRand Unified Bootloader theme..."

            sudo /tmp/Graphite-gtk-theme-main/other/grub2/./install.sh
        else
            echo "Installing \"Graphite\" GRand Unified Bootloader theme skipped!"
        fi
    else
        echo "Installing \"Graphite\" interface theme skipped!"
    fi

    echo "Interface themes installing script completed!"
}

Configure_InterfaceThemes() {
    echo "Configuring interface themes..."

    # Configuring Adwaita interface theme dark variant
    read -p "Would you like to apply \"Adwaita\" interface theme dark variant? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Configuring \"Adwaita\" interface theme dark variant..."

        # Applying Adwaita interface theme dark variant to GNOME Shell
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
        gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
        gsettings set org.gnome.desktop.wm.preferences theme "Adwaita-dark"
        gsettings set org.gnome.shell.extensions.user-theme name "Adwaita"

        # Applying Adwaita interface theme dark variant to global GNOME GTK4 programs
        GTK4CONFIGURATION="gtk-application-prefer-dark-theme"

        Configure_GTK4Appearance

        # Applying Adwaita interface theme dark variant to specific GNOME programs
        gsettings set com.github.johnfactotum.Foliate.view prefer-dark-theme "true"
        gsettings set com.github.wwmm.easyeffects use-dark-theme "true"
        gsettings set io.github.celluloid-player.Celluloid dark-theme-enable "true"
        gsettings set org.gnome.shotwell.preferences.ui use-dark-theme "true"
        gsettings set org.gnome.Terminal.Legacy.Settings theme-variant "dark"
        gsettings set org.gnome.todo style-variant "dark"
        gsettings set org.gnome.World.Secrets dark-theme "true"

        # Applying Adwaita interface theme dark variant to Flatpak containerized programs
        flatpak --user override --env=GTK_THEME=Adwaita-dark

        # Applying GNOME Text Editor and gedit color schemes
        gsettings set org.gnome.TextEditor style-scheme 'Adwaita-dark'

        read -p "Would you like to apply \"Lowlight\" gedit color scheme? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            gsettings set org.gnome.gedit.preferences.editor scheme 'lowlight'

            echo "\"Lowlight\" GNOME Text Editor color scheme applied!"
        else
            echo "GNOME Text Editor color scheme not changed!"
        fi

        echo "\"Adwaita\" interface theme dark variant applied!"
    else
        echo "Interface theme not changed!"
    fi

    # Configuring interface themes
    read -p "Would you like to apply \"Graphite\" interface theme \"Nord\" dark variant? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Applying interface theme
        THEMEHANDLE="Graphite-Dark-nord"

        gsettings set org.gnome.desktop.interface gtk-theme "$THEMEHANDLE"
        gsettings set org.gnome.desktop.wm.preferences theme "$THEMEHANDLE"
        gsettings set org.gnome.shell.extensions.user-theme name "$THEMEHANDLE"

        # Linking interface theme dark variant to libadwaita
        ln --symbolic --force "${HOME}/.themes/$THEMEHANDLE/gtk-4.0/assets" "${HOME}/.config/gtk-4.0/assets"
        ln --symbolic --force "${HOME}/.themes/$THEMEHANDLE/gtk-4.0/gtk.css" "${HOME}/.config/gtk-4.0/gtk.css"
        ln --symbolic --force "${HOME}/.themes/$THEMEHANDLE/gtk-4.0/gtk-dark.css" "${HOME}/.config/gtk-4.0/gtk-dark.css"

        # Applying interface theme to Flatpak containerized programs
        flatpak --user override --env=GTK_THEME=$THEMEHANDLE

        echo "\"Graphite\" interface theme \"Nord\" dark variant applied!"
    else
        echo "Interface theme not changed!"
    fi

    read -p "Would you like to apply \"Nord\" color schemes to programs? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Installing Nord GNOME Terminal profile and applying Nord GNOME Terminal color scheme
        chmod +x "$WORKINGDIRECTORY"/Themes/nord-gnome-terminal.sh
        "$WORKINGDIRECTORY"/Themes/./nord-gnome-terminal.sh

        # Importing Nord color scheme for gedit and Gnome Text Editor
        mkdir --parents /home/$(whoami)/.local/share/gedit/styles
        cp "$WORKINGDIRECTORY"/Themes/nord-gedit.xml /home/$(whoami)/.local/share/gedit/styles/
        sudo cp "$WORKINGDIRECTORY"/Themes/nord-gedit.xml /usr/share/gnome-text-editor/styles/

        # Applying Nord color scheme to gedit and Gnome Text Editor
        gsettings set org.gnome.gedit.preferences.editor scheme 'nord-gedit'
        gsettings set org.gnome.TextEditor style-scheme 'nord-gedit'
    else
        echo "Programs' color schemes not changed!"
    fi

    echo "Interface themes configuring script completed!"
}

Install_IconsThemes () {
    echo "Installing icons themes..."

    read -p "Would you like to install \"Tela circle\" icons theme? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Downloading Tela circle icons theme if it is not present
        if [[ ! -f "$WORKINGDIRECTORY"/Icons/Tela-circle-icon-theme-master.zip ]]
        then
            echo "Downloading \"Tela circle\" icons theme..."

            wget --quiet https://github.com/vinceliuice/Tela-circle-icon-theme/archive/refs/heads/master.zip --output-document="$WORKINGDIRECTORY"/Icons/Tela-circle-icon-theme-master.zip
        fi

        # Extracting Tela circle icons theme into temporary folder
        echo "Extracting \"Tela circle\" icons theme..."

        unzip -o -q $WORKINGDIRECTORY/Icons/Tela-circle-icon-theme-master.zip -d /tmp/

        # Installing Tela circle icons theme 
        echo "Installing \"Tela circle\" icons theme..."

        /tmp/Tela-circle-icon-theme-master/./install.sh -c nord
    else
        echo "Installing \"Tela circle\" icons theme skipped!"
    fi

    echo "Icons themes installing script completed!"
}

Configure_IconsThemes() {
    echo "Configuring icons themes..."

    # Configuring icons themes
    read -p "Would you like to apply \"Tela circle\" icons theme \"Nord\" dark variant? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-nord-dark"

        echo "\"Tela circle\" icons theme \"Nord\" dark variant applied!"
    else
        echo "Icons theme not changed!"
    fi

    echo "Icons themes configuring script completed!"
}

Install_CursorsThemes() {
    echo "Installing cursors themes..."

    read -p "Would you like to install \"Graphite\" cursors theme? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Downloading Graphite cursors theme if it is not present
        if [[ ! -f "$WORKINGDIRECTORY"/Cursors/Graphite-cursors-main.zip ]]
        then
            echo "Downloading \"Graphite\" cursors theme..."

            wget --quiet https://github.com/vinceliuice/Graphite-cursors/archive/refs/heads/main.zip --output-document="$WORKINGDIRECTORY"/Cursors/Graphite-cursors-main.zip
        fi

        # Extracting Graphite cursors theme into temporary folder
        echo "Extracting \"Graphite\" cursors theme..."

        unzip -o -q $WORKINGDIRECTORY/Cursors/Graphite-cursors-main.zip -d /tmp/

        # Installing Graphite cursors theme 
        echo "Installing \"Graphite\" cursors theme..."

        cd /tmp/Graphite-cursors-main
        ./install.sh
    else
        echo "Installing \"Graphite\" cursors theme skipped!"
    fi

    echo "Cursors themes installing script completed!"
}

Configure_CursorsThemes() {
    echo "Configuring cursors themes..."

    # Configuring cursors themes
    read -p "Would you like to apply \"Graphite\" cursors theme \"Nord\" dark variant? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        gsettings set org.gnome.desktop.interface cursor-theme "Graphite-dark-nord-cursors"

        echo "\"Graphite\" cursors theme \"Nord\" dark variant applied!"
    else
        echo "Cursors theme not changed!"
    fi

    echo "Cursors themes configuring script completed!"
}

Install_DesktopBackgrounds() {
    echo "Installing desktop background..."

    BACKGROUNDSDIRECTORY=/usr/share/backgrounds

    # Importing desktop backgrounds
    sudo cp --recursive "$WORKINGDIRECTORY"/Backgrounds/* $BACKGROUNDSDIRECTORY/

    echo "Desktop backgrounds installation script completed!"
}

Configure_DesktopBackgrounds() {
    echo "Configuring desktop backgrounds..."

    BACKGROUNDSDIRECTORY=/usr/share/backgrounds

    # Preventing for-loop interpreting non-existant matches as filenames using Bash shell behaviour option
    shopt -s nullglob

    for BACKGROUND in $BACKGROUNDSDIRECTORY/*.{jpeg,jpg,png}
    do
        read -p "Would you like to apply \"$(basename $BACKGROUND)\" desktop background? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            # Configuring desktop backgrounds
            gsettings set org.gnome.desktop.background picture-uri 'file://'$BACKGROUND''
            gsettings set org.gnome.desktop.background picture-uri-dark 'file://'$BACKGROUND''
            gsettings set org.gnome.desktop.screensaver picture-uri 'file://'$BACKGROUND''

            echo "\"$(basename $BACKGROUND)\" deskop background applied!"
        else
            echo "Desktop background not changed!"
        fi
    done

    echo "Desktop backgrounds configuring script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-13 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Install fonts" "Configure fonts" "Install user icon" "Install interface themes" "Configure interface themes" "Install icons themes" "Configure icons themes" "Install cursors themes" "Configure cursors themes" "Install desktop backgrounds" "Configure desktop backgrounds"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Install_Fonts
                Configure_Fonts
                Install_UserIcon
                Install_InterfaceThemes
                Configure_InterfaceThemes
                Install_IconsThemes
                Configure_IconsThemes
                Install_CursorsThemes
                Configure_CursorsThemes
                Install_DesktopBackgrounds
                Configure_DesktopBackgrounds
                exit 0;;
            "Install fonts" )
                Install_Fonts
                Menu;;
            "Configure fonts" )
                Configure_Fonts
                Menu;;
            "Install user icon" )
                Install_UserIcon
                Menu;;
            "Install interface themes" )
                Install_InterfaceThemes
                Menu;;
            "Configure interface themes" )
                Configure_InterfaceThemes
                Menu;;
            "Install icons themes" )
                Install_IconsThemes
                Menu;;
            "Configure icons themes" )
                Configure_IconsThemes
                Menu;;
            "Install cursors themes" )
                Install_CursorsThemes
                Menu;;
            "Configure cursors themes" )
                Configure_CursorsThemes
                Menu;;
            "Install desktop backgrounds" )
                Install_DesktopBackgrounds
                Menu;;
            "Configure desktop backgrounds" )
                Configure_DesktopBackgrounds
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Post-installation/Interface"
SYSTEMSETTINGSDIRECTORY="$(pwd)/Pre-installation/Settings/System"
USERSETTINGSDIRECTORY="$(pwd)/Pre-installation/Settings/User"

Menu
