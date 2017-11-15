#!/usr/bin/env bash

www_host=$1
www_root=$2
php_ver=$3

if [[ -f "/etc/nginx/sites-available/$www_host" ]]
then
    echo "$www_host site already available"
    exit 0
fi

service apache2 stop > /dev/null 2>&1

#mkdir -p /var/log/nginx/$www_host

if [[ ${php_ver} == "5" ]]
then
    php_fpm_path="/run/php5-fpm.sock"
else
    php_fpm_path="/run/php/php$php_ver-fpm.sock"
fi

block="# $www_host configuration
server {
    listen 80 default_server;
    listen 443 ssl default_server;
    server_name $www_host www.$www_host;
    root $www_root;

    ssl_certificate	/etc/ssl/$www_host/$www_host.crt;
    ssl_certificate_key /etc/ssl/$www_host/$www_host.key;

    charset utf-8;
    index index.html index.htm index.php;

    # access_log /var/log/nginx/$www_host/access.log combined;
    # error_log  /var/log/nginx/$www_host/error.log error;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$php_fpm_path;
    }
}"

echo "$block" > "/etc/nginx/sites-available/$www_host"

ln -fs "/etc/nginx/sites-available/$www_host" "/etc/nginx/sites-enabled/$www_host"
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
service nginx restart > /dev/null 2>&1