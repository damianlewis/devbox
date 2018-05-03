#!/usr/bin/env bash

composer_bin_path='/home/vagrant/.config/composer/vendor/bin'

# Check if Envoy has been installed
if [[ -h "$composer_bin_path/envoy" ]]
then
    echo 'Laravel Envoy already installed'
    exit 0
fi

profile_file='/home/vagrant/.profile'
export_path="export PATH=$composer_bin_path:\$PATH"
source="\n\n# Prepend the composer bin directory to your PATH\n# This path is specific to my vagrant server\n$export_path"

# Install Envoy
composer global require laravel/envoy > /dev/null 2>&1

# Append composer bin path to ~/.profile
if ! grep -cqs ${export_path} ${profile_file}
then
    printf "$source" >> "$profile_file"
fi

# Re-source user profiles
source ${profile_file}