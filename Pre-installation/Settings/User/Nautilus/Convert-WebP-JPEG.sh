#!/bin/bash

# WebP image format to JPEG image format conversion script for Nautilus
# Script version = 1

# Copyright (C) 2021 Mislav Volaj
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.



for SELECTEDFILE in $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
do
    if [ $(file --mime-type -b "$SELECTEDFILE") == image/webp ]
    then
        gm convert -auto-orient "$SELECTEDFILE" "${SELECTEDFILE%.webp}.jpeg"
        rm "$SELECTEDFILE"
    fi
done
