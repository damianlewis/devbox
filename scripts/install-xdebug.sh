#!/usr/bin/env bash

php_ver=$1

if [[ ${php_ver} == '5' ]]
then
    xdebug_path="/etc/php5/mods-available/xdebug.ini"
else
    xdebug_path="/etc/php/$php_ver/mods-available/xdebug.ini"
fi

if [[ -f ${xdebug_path} ]]
then
    echo "Xdebug for PHP $php_ver already installed"
else
    # Support for PHP 5.5 and 5.6 was dropped in Xdebug 2.5
    if [[ ${php_ver} == '5' || ${php_ver} == '5.6' ]]
    then
        git clone -b xdebug_2_4 git://github.com/xdebug/xdebug.git xdebug > /dev/null 2>&1
    else
        git clone git://github.com/xdebug/xdebug.git xdebug > /dev/null 2>&1
    fi

    cd ./xdebug

    # Check if phpize has been installed
    phpize${php_ver} -v > /dev/null 2>&1
    is_installed=$?

    if [[ ${is_installed} != 0 ]]
    then
        apt-get update > /dev/null 2>&1
        apt-get -y install php${php_ver}-dev > /dev/null 2>&1
    fi

    # Build xdebug extension
    phpize${php_ver} > /dev/null 2>&1
    ./configure --with-php-config=/usr/bin/php-config${php_ver} > /dev/null 2>&1
    make install > /dev/null 2>&1

    cd ..
    rm -rf xdebug

    # Configure xdebug
    block="zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_port=9000"

    echo "$block" > ${xdebug_path}

    # Enable extension
    if [[ ${php_ver} == '5' ]]
    then
        php5enmod xdebug > /dev/null 2>&1
    else
        phpenmod xdebug > /dev/null 2>&1
    fi

    service php${php_ver}-fpm restart > /dev/null 2>&1
fi