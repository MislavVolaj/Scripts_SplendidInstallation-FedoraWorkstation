#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Install_Fonts() {
    echo "Installing fonts..."

    if [[ -f "$WORKINGDIRECTORY"/Fonts/Fonts_Google.tar.zst ]]
    then
        read -p "Would you like to install Google fonts? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            mkdir --parents "$HOME"/.local/share/fonts/Google

            tar --extract --zstd --file="$WORKINGDIRECTORY"/Fonts/Fonts_Google.tar.zst --directory "$HOME"/.local/share/fonts/Google/

            echo "Google fonts installation script completed!"
        else
            echo "Installation of Google fonts skipped!"
        fi
    fi

    if [[ -f "$WORKINGDIRECTORY"/Fonts/Fonts_Microsoft.tar.zst ]]
    then
        read -p "Would you like to install Microsoft fonts? (y/ anything else to skip): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            mkdir --parents "$HOME"/.local/share/fonts/Microsoft

            tar --extract --zstd --file="$WORKINGDIRECTORY"/Fonts/Fonts_Microsoft.tar.zst --directory "$HOME"/.local/share/fonts/Microsoft/

            echo "Microsoft fonts installation script completed!"
        else
            echo "Installation of Microsoft fonts skipped!"
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

        echo "\"Better fonts\" installation script completed!"
    else
        echo "Installation of \"Better fonts\" skipped!"
    fi

    # Rebuilding font information cache
    sudo fc-cache --really-force

    echo "Fonts installation script completed!"
}

Configure_Fonts() {
    echo "Configuring fonts..."

    read -p "Would you like to import font rendering settings? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        if [[ -f "$SETTINGSDIRECTORY"/local.conf ]]
        then
            sudo cp "$SETTINGSDIRECTORY"/local.conf /etc/fonts/
            
            echo "Font rendering settings importing script completed!"
        else
            echo "Importing font rendering settings skipped because the configuration file is missing!"
        fi
    else
        echo "Importing font rendering settings skipped!"
    fi

    read -p "Would you like to restore default \"Cantarell\" fonts or apply \"Roboto Light\" fonts? (c/r/ anything else to skip): "

    if [[ $REPLY =~ ^[Cc]$ ]]
    then
        # Configuring system-wide fonts
        gsettings set org.gnome.desktop.interface document-font-name 'Cantarell 11'
        gsettings set org.gnome.desktop.interface font-name 'Cantarell Regular 11'
        gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
        gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Cantarell Bold 11'

        # Configuring applications' fonts
        gsettings set org.gnome.Notes font 'Cantarell 14'

        echo "\"Cantarell\" fonts restored!"
    elif [[ $REPLY =~ ^[Rr]$ ]]
    then
        # Configuring system-wide fonts
        gsettings set org.gnome.desktop.interface document-font-name 'Roboto Light 10'
        gsettings set org.gnome.desktop.interface font-name 'Roboto Light 10'
        gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
        gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Roboto 10'

        # Configuring applications' fonts
        gsettings set org.gnome.Notes font 'Roboto 14'

        echo "\"Roboto\" fonts applied!"
    else
        echo "Fonts not changed!"
    fi

    echo "Fonts configuration script completed!"
} 

Install_UserIcon() {
    echo "Installing user icon..."

    # Installing user icon, if it exists
    [[ -f "$WORKINGDIRECTORY"/Icons/$(whoami).jpg ]] && sudo cp "$WORKINGDIRECTORY"/Icons/$(whoami).jpg /usr/share/pixmaps/faces/

    echo "User icon installing script completed!"
}

Install_DesktopBackgrounds() {
    echo "Installing desktop background..."

    # Importing desktop backgrounds
    sudo cp --recursive "$WORKINGDIRECTORY"/Backgrounds/* /usr/share/backgrounds/

    # Configuring desktop background
    read -p "Would you like to apply \"Stormy Seas\" desktop background? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/Stormy-Seas.jpg'
        gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/Stormy-Seas.jpg'

        echo "\"Stormy Seas\" deskop background applied!"
    else
        echo "Desktop background not changed!"
    fi

    echo "User icon and desktop background installation script completed!"
}

Install_Cursors() {
    echo "Installing cursor themes..."

    # Importing cursors
    mkdir --parents $HOME/.icons

    tar --extract --xz --file="$WORKINGDIRECTORY"/Cursors/Vimix.tar.xz --directory $HOME/.icons/

    # Configuring cursors
    read -p "Would you like to apply \"Vimix\" cursor theme? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        gsettings set org.gnome.desktop.interface cursor-theme 'Vimix'

        echo "\"Vimix\" cursor theme applied!"
    else
        echo "Cursor theme not changed!"

    fi

    echo "Cursors installation script completed"
}

Configure_InterfaceTheme-Adwaita-darkmode() {
    echo "Configuring \"Adwaita\" dark mode..."

    read -p "Would you like to apply \"Adwaita\" dark mode? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
        gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
        gsettings set org.gnome.desktop.wm.preferences theme "Adwaita-dark"

        gsettings set org.gnome.books night-mode true
        gsettings set org.gnome.documents night-mode true
        gsettings set org.gnome.Maps night-mode true

        gsettings set org.gnome.gedit.preferences.editor scheme 'oblivion'

        echo "\"Adwaita\" dark mode applied!"
    else
        echo "Interface theme not changed!"
    fi

    echo "\"Adwaita\" dark mode configuration script completed!"
}

Install_InterfaceTheme-Nordic() {
    echo "Installing Nordic interface theme..."

    # Importing Nordic GNOME interface theme
    mkdir --parents "$HOME"/.themes

    tar --extract --xz --file="$WORKINGDIRECTORY"/Themes/Nordic-standard-buttons.tar.xz --directory /home/$(whoami)/.themes/
    tar --extract --xz --file="$WORKINGDIRECTORY"/Themes/Nordic-darker-standard-buttons.tar.xz --directory /home/$(whoami)/.themes/

    sudo tar --extract --xz --file="$WORKINGDIRECTORY"/Themes/Nordic-Folders.tar.xz --directory /usr/share/icons/

    # Applying Nordic GNOME interface theme
    read -p "Would you like to apply Nordic or Nordic-darker interface theme? (a/b/ anything else to skip): "

    if [[ $REPLY =~ ^[Aa]$ ]]
    then
        gsettings set org.gnome.desktop.interface gtk-theme "Nordic-standard-buttons"
        gsettings set org.gnome.desktop.interface icon-theme "Nordic"
        gsettings set org.gnome.desktop.wm.preferences theme "Nordic-standard-buttons"
        gsettings set org.gnome.shell.extensions.user-theme name "Nordic-standard-buttons" 

        echo "Nordic interface theme applied!"
    elif [[ $REPLY =~ ^[Bb]$ ]]
    then
        gsettings set org.gnome.desktop.interface gtk-theme "Nordic-darker-standard-buttons"
        gsettings set org.gnome.desktop.interface icon-theme "Nordic-Darker"
        gsettings set org.gnome.desktop.wm.preferences theme "Nordic-darker-standard-buttons"
        gsettings set org.gnome.shell.extensions.user-theme name "Nordic-darker-standard-buttons"

        echo "Nordic-darker interface theme applied!"
    else
        echo "Interface theme not changed!"
    fi

    # Installing Nord GNOME Terminal profile and applying Nord GNOME Terminal color scheme
    chmod +x "$WORKINGDIRECTORY"/Themes/nord-gnome-terminal.sh
    "$WORKINGDIRECTORY"/Themes/./nord-gnome-terminal.sh

    # Importing Nord GNOME Text Editor color scheme
    mkdir --parents /home/$(whoami)/.local/share/gedit/styles
    cp "$WORKINGDIRECTORY"/Themes/nord-gedit.xml /home/$(whoami)/.local/share/gedit/styles/nord.xml

    read -p "Would you like to apply \"Nord\" GNOME Text Editor color scheme? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        gsettings set org.gnome.gedit.preferences.editor scheme 'nord-gedit'

        echo "\"Nord\" GNOME Text Editor color scheme applied!"
    else
        echo "\"Nord\" GNOME Text Editor color scheme not changed!"
    fi

    echo "Interface themes installation script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-9 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Install fonts" "Configure fonts" "Install user icon" "Install desktop backgrounds" "Install cursors" "Configure \"Adwaita\" dark mode" "Install interface theme: \"Nordic\""; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Install_Fonts
                Configure_Fonts
                Install_UserIcon
                Install_DesktopBackgrounds
                Install_Cursors
                Configure_InterfaceTheme-Adwaita-darkmode
                Install_InterfaceTheme-Nordic
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
            "Install desktop backgrounds" )
                Install_DesktopBackgrounds
                Menu;;
            "Install cursors" )
                Install_Cursors
                Menu;;
            "Configure \"Adwaita\" dark mode" )
                Configure_InterfaceTheme-Adwaita-darkmode
                Menu;;
            "Install interface theme: \"Nordic\"" )
                Install_InterfaceTheme-Nordic
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Post-installation/Interface"
SETTINGSDIRECTORY="$(pwd)/Pre-installation/Settings/System"

Menu
