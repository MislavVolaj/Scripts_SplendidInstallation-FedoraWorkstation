#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Configure_Flatpak() {
    echo "Configuring Flatpak..."

    # Installing Flathub repository
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # Configuring Flatpak to access system themes
    flatpak --user override --filesystem=/usr/share/themes/:ro
    flatpak --user override --filesystem=$HOME/.themes/:ro 
    flatpak --user override --filesystem=/usr/share/icons/:ro
    flatpak --user override --filesystem=$HOME/.icons/:ro
    sudo flatpak override --filesystem=xdg-config/gtk-3.0
    sudo flatpak override --filesystem=xdg-config/gtk-4.0

    echo "Flatpak configuring script completed!"
}

Install_FlatpakApplication() {
    read -p "Would you like to install $FLATPAKAPPLICATIONNAME from a Flathub repository? (y/ anything else to skip): "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Installing $FLATPAKAPPLICATIONNAME..."

        flatpak install --assumeyes flathub $FLATPAKAPPLICATIONHANDLER
    else
        echo "Installing $FLATPAKAPPLICATIONNAME skipped!"
    fi

    echo "$FLATPAKAPPLICATIONNAME installation script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-30 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Configure Flatpak" "Install Flatseal" "Install Gradience" "Install Mozilla Firefox" "Install Mozilla Thunderbird" "Install Google Chrome" "Install Microsoft Edge" "Install Microsoft Visual Studio Code" "Install Skype" "Install Signal" "Install Telegram" "Install Discord" "Install Scribus" "Install Subsurface" "Install GIMP" "Install Darktable" "Install RawTherapee" "Install Krita" "Install Spotify" "Install WebTorrent" "Install Stremio" "Install Kodi" "Install HandBrake" "Install Kdenlive" "Install Flowblade" "Install OBS Studio" "Install Steam" "Install Lutris"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                Configure_Flatpak
                FLATPAKAPPLICATIONNAME="Flatseal"
                FLATPAKAPPLICATIONHANDLER=com.github.tchx84.Flatseal
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Gradience"
                FLATPAKAPPLICATIONHANDLER=com.github.GradienceTeam.Gradience
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Mozilla Firefox"
                FLATPAKAPPLICATIONHANDLER=org.mozilla.firefox
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Mozilla Thunderbird"
                FLATPAKAPPLICATIONHANDLER=org.mozilla.Thunderbird
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Google Chrome"
                FLATPAKAPPLICATIONHANDLER=com.google.Chrome
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Microsoft Edge"
                FLATPAKAPPLICATIONHANDLER=com.microsoft.Edge
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Microsoft Visual Studio Code"
                FLATPAKAPPLICATIONHANDLER=com.visualstudio.code
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Skype"
                FLATPAKAPPLICATIONHANDLER=com.skype.Client
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Signal"
                FLATPAKAPPLICATIONHANDLER=org.signal.Signal
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Telegram"
                FLATPAKAPPLICATIONHANDLER=org.telegram.desktop
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Discord"
                FLATPAKAPPLICATIONHANDLER=com.discordapp.Discord
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Scribus"
                FLATPAKAPPLICATIONHANDLER=net.scribus.Scribus
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Subsurface"
                FLATPAKAPPLICATIONHANDLER=org.subsurface_divelog.Subsurface
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="GIMP"
                FLATPAKAPPLICATIONHANDLER=org.gimp.GIMP
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Darktable"
                FLATPAKAPPLICATIONHANDLER=org.darktable.Darktable
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="RawTherapee"
                FLATPAKAPPLICATIONHANDLER=com.rawtherapee.RawTherapee
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Inkscape"
                FLATPAKAPPLICATIONHANDLER=org.inkscape.Inkscape
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Krita"
                FLATPAKAPPLICATIONHANDLER=org.kde.krita
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Spotify"
                FLATPAKAPPLICATIONHANDLER=com.spotify.Client
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="WebTorrent"
                FLATPAKAPPLICATIONHANDLER=io.webtorrent.WebTorrent
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Stremio"
                FLATPAKAPPLICATIONHANDLER=com.stremio.Stremio
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Kodi"
                FLATPAKAPPLICATIONHANDLER=tv.kodi.Kodi
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="HandBrake"
                FLATPAKAPPLICATIONHANDLER=fr.handbrake.ghb
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Kdenlive"
                FLATPAKAPPLICATIONHANDLER=org.kde.kdenlive
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Flowblade"
                FLATPAKAPPLICATIONHANDLER=io.github.jliljebl.Flowblade
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="OBS Studio"
                FLATPAKAPPLICATIONHANDLER=com.obsproject.Studio
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Steam"
                FLATPAKAPPLICATIONHANDLER=com.valvesoftware.Steam
                Install_FlatpakApplication
                FLATPAKAPPLICATIONNAME="Lutris"
                FLATPAKAPPLICATIONHANDLER=net.lutris.Lutris
                Install_FlatpakApplication
                exit 0;;
            "Configure Flatpak" )
                Configure_Flatpak
                Menu;;
            "Install Flatseal" )
                FLATPAKAPPLICATIONNAME="Flatseal"
                FLATPAKAPPLICATIONHANDLER=com.github.tchx84.Flatseal
                Install_FlatpakApplication
                Menu;;
            "Install Gradience" )
                FLATPAKAPPLICATIONNAME="Gradience"
                FLATPAKAPPLICATIONHANDLER=com.github.GradienceTeam.Gradience
                Install_FlatpakApplication
                Menu;;
            "Install Mozilla Firefox" )
                FLATPAKAPPLICATIONNAME="Mozilla Firefox"
                FLATPAKAPPLICATIONHANDLER=org.mozilla.firefox
                Install_FlatpakApplication
                Menu;;
            "Install Mozilla Thunderbird" )
                FLATPAKAPPLICATIONNAME="Mozilla Thunderbird"
                FLATPAKAPPLICATIONHANDLER=org.mozilla.Thunderbird
                Install_FlatpakApplication
                Menu;;
            "Install Google Chrome" )
                FLATPAKAPPLICATIONNAME="Google Chrome"
                FLATPAKAPPLICATIONHANDLER=com.google.Chrome
                Install_FlatpakApplication
                Menu;;
            "Install Microsoft Edge" )
                FLATPAKAPPLICATIONNAME="Microsoft Edge"
                FLATPAKAPPLICATIONHANDLER=com.microsoft.Edge
                Install_FlatpakApplication
                Menu;;
            "Install Microsoft Visual Studio Code" )
                FLATPAKAPPLICATIONNAME="Microsoft Visual Studio Code"
                FLATPAKAPPLICATIONHANDLER=com.visualstudio.code
                Install_FlatpakApplication
                Menu;;
            "Install Skype" )
                FLATPAKAPPLICATIONNAME="Skype"
                FLATPAKAPPLICATIONHANDLER=com.skype.Client
                Install_FlatpakApplication
                Menu;;
            "Install Signal" )
                FLATPAKAPPLICATIONNAME="Signal"
                FLATPAKAPPLICATIONHANDLER=org.signal.Signal
                Install_FlatpakApplication
                Menu;;
            "Install Telegram" )
                FLATPAKAPPLICATIONNAME="Telegram"
                FLATPAKAPPLICATIONHANDLER=org.telegram.desktop
                Install_FlatpakApplication
                Menu;;
            "Install Discord" )
                FLATPAKAPPLICATIONNAME="Discord"
                FLATPAKAPPLICATIONHANDLER=com.discordapp.Discord
                Install_FlatpakApplication
                Menu;;
            "Install Scribus" )
                FLATPAKAPPLICATIONNAME="Scribus"
                FLATPAKAPPLICATIONHANDLER=net.scribus.Scribus
                Install_FlatpakApplication
                Menu;;
            "Install Subsurface" )
                FLATPAKAPPLICATIONNAME="Subsurface"
                FLATPAKAPPLICATIONHANDLER=org.subsurface_divelog.Subsurface
                Install_FlatpakApplication
                Menu;;
            "Install GIMP" )
                FLATPAKAPPLICATIONNAME="GIMP"
                FLATPAKAPPLICATIONHANDLER=org.gimp.GIMP
                Install_FlatpakApplication
                Menu;;
            "Install Darktable" )
                FLATPAKAPPLICATIONNAME="Darktable"
                FLATPAKAPPLICATIONHANDLER=org.darktable.Darktable
                Install_FlatpakApplication
                Menu;;
            "Install RawTherapee" )
                FLATPAKAPPLICATIONNAME="RawTherapee"
                FLATPAKAPPLICATIONHANDLER=com.rawtherapee.RawTherapee
                Install_FlatpakApplication
                Menu;;
            "Install Inkscape" )
                FLATPAKAPPLICATIONNAME="Inkscape"
                FLATPAKAPPLICATIONHANDLER=org.inkscape.Inkscape
                Install_FlatpakApplication
                Menu;;
            "Install Krita" )
                FLATPAKAPPLICATIONNAME="Krita"
                FLATPAKAPPLICATIONHANDLER=org.kde.krita
                Install_FlatpakApplication
                Menu;;
            "Install Spotify" )
                FLATPAKAPPLICATIONNAME="Spotify"
                FLATPAKAPPLICATIONHANDLER=com.spotify.Client
                Install_FlatpakApplication
                Menu;;
            "Install WebTorrent" )
                FLATPAKAPPLICATIONNAME="WebTorrent"
                FLATPAKAPPLICATIONHANDLER=io.webtorrent.WebTorrent
                Install_FlatpakApplication
                Menu;;
            "Install Stremio" )
                FLATPAKAPPLICATIONNAME="Stremio"
                FLATPAKAPPLICATIONHANDLER=com.stremio.Stremio
                Install_FlatpakApplication
                Menu;;
            "Install Kodi" )
                FLATPAKAPPLICATIONNAME="Kodi"
                FLATPAKAPPLICATIONHANDLER=tv.kodi.Kodi
                Install_FlatpakApplication
                Menu;;
            "Install HandBrake" )
                FLATPAKAPPLICATIONNAME="HandBrake"
                FLATPAKAPPLICATIONHANDLER=fr.handbrake.ghb
                Install_FlatpakApplication
                Menu;;
            "Install Kdenlive" )
                FLATPAKAPPLICATIONNAME="Kdenlive"
                FLATPAKAPPLICATIONHANDLER=org.kde.kdenlive
                Install_FlatpakApplication
                Menu;;
            "Install Flowblade" )
                FLATPAKAPPLICATIONNAME="Flowblade"
                FLATPAKAPPLICATIONHANDLER=io.github.jliljebl.Flowblade
                Install_FlatpakApplication
                Menu;;
            "Install OBS Studio" )
                FLATPAKAPPLICATIONNAME="OBS Studio"
                FLATPAKAPPLICATIONHANDLER=com.obsproject.Studio
                Install_FlatpakApplication
                Menu;;
            "Install Steam" )
                FLATPAKAPPLICATIONNAME="Steam"
                FLATPAKAPPLICATIONHANDLER=com.valvesoftware.Steam
                Install_FlatpakApplication
                Menu;;
            "Install Lutris" )
                FLATPAKAPPLICATIONNAME="Lutris"
                FLATPAKAPPLICATIONHANDLER=net.lutris.Lutris
                Install_FlatpakApplication
                Menu;;
        esac
    done
}



COLUMNS=1

Menu
