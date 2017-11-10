#!/usr/bin/env bash

xdebug_path="/etc/php5/mods-available/xdebug.ini"

if [[ -f $xdebug_path ]]
then
    echo "Xdebug already installed"
else
    # Support for PHP 5.5 and 5.6 was dropped in Xdebug 2.5
    git clone -b xdebug_2_4 git://github.com/xdebug/xdebug.git xdebug > /dev/null 2>&1

    cd ./xdebug

    # Check if phpize has been installed
    phpize5 -v > /dev/null 2>&1
    is_installed=$?

    if [[ $is_installed != 0 ]]
    then
        apt-get -y install php5-dev > /dev/null 2>&1
    fi

    # Build xdebug extension
    phpize5 > /dev/null 2>&1
    ./configure --with-php-config=/usr/bin/php-config5 > /dev/null 2>&1
    make install > /dev/null 2>&1

    cd ..
    rm -rf xdebug

    # Configure xdebug
    block="zend_extension=xdebug.so
    xdebug.remote_enable=1
    xdebug.remote_connect_back=1
    xdebug.remote_port=9000"

    echo "$block" > $xdebug_path

    php5enmod xdebug > /dev/null 2>&1

    service php5-fpm restart > /dev/null 2>&1
fi