#!/usr/bin/env bash

mysql_ver=$1

export DEBIAN_FRONTEND=noninteractive

apt-get -y remove --purge mysql-server mysql-client mysql-common > /dev/null 2>&1
apt-get -y autoremove > /dev/null 2>&1
apt-get autoclean > /dev/null 2>&1

rm -rf /var/lib/mysql
rm -rf /var/log/mysql
rm -rf /etc/mysql

dep_package='mysql-apt-config_0.8.9-1_all.deb'
root_password='secret'

debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-server select mysql-$mysql_ver"
debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-product select Apply"

curl -sSOL https://dev.mysql.com/get/$dep_package
dpkg -i $dep_package > /dev/null 2>&1
apt-get update > /dev/null 2>&1

if [[ $mysql_ver == '5.5' ]]
then
    # Set root password for Mysql 5.5
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $root_password"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $root_password"
else
    # Set root password for Mysql 5.6 and 5.7
    debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password $root_password"
    debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password $root_password"
fi

apt-get -y install mysql-server php5-mysql > /dev/null 2>&1

service php5-fpm restart > /dev/null 2>&1

rm $dep_package
