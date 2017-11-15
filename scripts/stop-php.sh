#!/usr/bin/env bash

php_vers=$@

for php_ver in ${php_vers}
do
    # Check if the specific version of PHP FPM is installed
    if dpkg --get-selections | grep -cq php${php_ver}-fpm
    then
        service php${php_ver}-fpm stop > /dev/null 2>&1
    fi
done