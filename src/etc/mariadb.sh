#!/bin/sh
#
# Configure MariaDB.
# ------------------------------------------------------------------------------

if dpkg --get-selections | grep -q '^mariadb.*\si'
  then echo 'Configuring MariaDB'

  cat <<_ >/etc/mysql/mariadb.conf.d/99-prov.cnf
[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4

[mysqld]
bind-address = 0.0.0.0
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init-connect = 'SET NAMES utf8mb4'
_

  mysql -u root -e 'select * from mysql.user where user= "root" and password = "invalid"' | grep -q root && mysql -u root -e 'set password for "root"@"localhost" = password("vagrant")'
  service mariadb restart
fi
