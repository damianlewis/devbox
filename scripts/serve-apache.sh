#!/usr/bin/env bash

www_host=$1
www_root=$2
php_ver=$3

if [[ -f "/etc/apache2/sites-available/$www_host.conf" ]]
then
    echo "$www_host site already available"
    exit 0
fi

service nginx stop > /dev/null 2>&1

#mkdir -p /var/log/apache2/$www_host

if [[ ${php_ver} == "5" || ${php_ver} == "5.6" || ${php_ver} == "7.0" ]]
then
    php_ext_pattern=".ph(p[3457]?|t|tml)"
else
    php_ext_pattern=".ph(ar|p|tml)"
fi

if [[ ${php_ver} == "5" ]]
then
    php_fpm_path="/run/php5-fpm.sock"
else
    php_fpm_path="/run/php/php$php_ver-fpm.sock"
fi

block="# $www_host configuration
<VirtualHost *:80>
    ServerName $www_host
    ServerAlias www.$www_host
    DocumentRoot $www_root

    <Directory $www_root>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \".+\\$php_ext_pattern$\">
        SetHandler \"proxy:unix:$php_fpm_path|fcgi://localhost\"
    </FilesMatch>

    # ErrorLog \${APACHE_LOG_DIR}/$www_host/error.log

    # Possible values include: debug, info, notice, warn, error, crit, alert, emerg
    # LogLevel warn

    # CustomLog \${APACHE_LOG_DIR}/$www_host/access.log combined
</VirtualHost>"

echo "$block" > "/etc/apache2/sites-available/$www_host.conf"

a2ensite ${www_host}.conf > /dev/null 2>&1
a2dissite 000-default > /dev/null 2>&1
service apache2 restart > /dev/null 2>&1