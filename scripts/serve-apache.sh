#!/usr/bin/env bash

www_host=$1
www_root=$2

if [[ -f "/etc/apache2/sites-available/$www_host.conf" ]]
then
    echo "$www_host site already available"
    exit 0
fi

service nginx stop > /dev/null 2>&1

#mkdir -p /var/log/apache2/$www_host

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

    <FilesMatch \".+\\.ph(p[3457]?|t|tml)$\">
        SetHandler \"proxy:unix:/run/php5-fpm.sock|fcgi://localhost\"
    </FilesMatch>

    # ErrorLog \${APACHE_LOG_DIR}/$www_host/error.log

    # Possible values include: debug, info, notice, warn, error, crit, alert, emerg
    # LogLevel warn

    # CustomLog \${APACHE_LOG_DIR}/$www_host/access.log combined
</VirtualHost>"

echo "$block" > "/etc/apache2/sites-available/$www_host.conf"

a2ensite $www_host.conf > /dev/null 2>&1
a2dissite 000-default > /dev/null 2>&1
service apache2 restart > /dev/null 2>&1