#!/usr/bin/env bash

www_host=$1
root_path=$2
ssl_path="/etc/ssl/$www_host"
conf_path="$root_path/scripts/ssl-conf"

if [[ -d ${ssl_path} ]]
then
    echo 'SSL certificate already exists'
else
    mkdir ${ssl_path}

    # Create root CA key and certificate
    openssl genrsa -out ${ssl_path}/rootCA.key 2048 > /dev/null 2>&1
    openssl req -x509 -new -nodes -key ${ssl_path}/rootCA.key -sha256 -days 3650 -out ${ssl_path}/rootCA.pem -config <( cat ${conf_path}/server.csr.cnf ) > /dev/null 2>&1

    # Create server key
    openssl req -new -sha256 -nodes -newkey rsa:2048 -keyout ${ssl_path}/server.key -out ${ssl_path}/server.csr -config <( cat ${conf_path}/server.csr.cnf ) > /dev/null 2>&1

    # Create server certificate
    openssl x509 -req -in ${ssl_path}/server.csr -CA ${ssl_path}/rootCA.pem -CAkey ${ssl_path}/rootCA.key -CAcreateserial -out ${ssl_path}/server.crt -days 3650 -sha256 -extfile ${conf_path}/v3.ext > /dev/null 2>&1
fi