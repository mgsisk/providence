#!/bin/sh
#
# Configure redis.
# ------------------------------------------------------------------------------

if dpkg --get-selections | grep -q '^redis.*\si'
  then echo 'Configuring redis'
  sed -i 's/^bind /#bind /' /etc/redis/redis.conf
  service redis-server restart
fi
