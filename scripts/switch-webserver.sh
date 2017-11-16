#!/usr/bin/env bash

if [[ $1 == 'apache' ]]
then
    service nginx stop > /dev/null 2>&1
    service apache2 start > /dev/null 2>&1
else
    service apache2 stop > /dev/null 2>&1
    service nginx start > /dev/null 2>&1
fi