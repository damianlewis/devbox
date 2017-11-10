#!/usr/bin/env bash

cat > /root/.my.cnf << EOF
[client]
user = root
password = secret
host = localhost
EOF

cp /root/.my.cnf /home/vagrant/.my.cnf

db_name=$1;
db_user=$2;
db_password=$3;

mysql -e "CREATE DATABASE IF NOT EXISTS \`$db_name\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";
mysql -e "GRANT ALL ON \`$db_name\`.* TO '$db_user'@'localhost' IDENTIFIED BY '$db_password';"
mysql -e "FLUSH PRIVILEGES;"
service mysql restart > /dev/null 2>&1