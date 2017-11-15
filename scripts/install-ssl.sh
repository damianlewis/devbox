#!/usr/bin/env bash

www_host=$1
country=$2
state=$3
location=$4
organisation=$5
organisation_unit=$6
ssl_path="/etc/ssl/$www_host"
common_name=${www_host}

mkdir ${ssl_path}
openssl req -nodes -newkey rsa:2048 -keyout ${ssl_path}/${www_host}.key -out ${ssl_path}/${www_host}.csr -subj "/C=$country/ST=$state/L=$location/O=$organisation/OU=$organisation_unit/CN=$common_name" > /dev/null 2>&1
openssl x509 -req -days 365 -in ${ssl_path}/${www_host}.csr -signkey ${ssl_path}/${www_host}.key -out ${ssl_path}/${www_host}.crt > /dev/null 2>&1