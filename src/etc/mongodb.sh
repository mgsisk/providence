#!/bin/sh
#
# Configure MongoDB.
# ------------------------------------------------------------------------------

if dpkg --get-selections | grep -q '^mongodb.*\si'
  then echo 'Configuring MongoDB'
  sed -i 's/bindIp: .*/bindIp: 0.0.0.0/' /etc/mongod.conf
  service mongod restart
fi
