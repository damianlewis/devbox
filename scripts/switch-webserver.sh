#!/usr/bin/env bash

if [[ $1 == 'apache' ]]
then
    echo 'Starting Apache'
    service nginx stop
    service apache2 start
else
    echo 'Starting Nginx'
    service apache2 stop
    service nginx start
fi