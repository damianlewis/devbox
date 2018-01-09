#!/usr/bin/env bash

extensions=$@
is_updated=0

for extension in ${extensions}
do
    # Check if PHP extensions have been installed
    if dpkg --get-selections | grep -cq ${extension}
    then
        echo "$extension already installed"
    else
        # Check if APT package exists
        apt-cache show ${extension} > /dev/null 2>&1
        is_available=$?

        if [[ ${is_available} != 0 ]]
        then
            echo "Unable to locate $extension package"
        else
            echo "Installing $extension"

            if [[ ${is_updated} == 0 ]]
            then
                apt-get update > /dev/null 2>&1
                is_updated=1
            fi

            apt-get -y install ${extension} > /dev/null 2>&1
        fi
    fi
done