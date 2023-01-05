#!/bin/sh
#
# Configure CouchDB.
# ------------------------------------------------------------------------------

if dpkg --get-selections | grep -q '^couchdb.*\si'
  then echo 'Configuring CouchDB'
  cd /opt/couchdb || exit
  mkdir -p /srv/sys/couchdb
  echo "<meta http-equiv='refresh' content='0; url=http://$(hostname -f):5984/_utils/'>" >/srv/sys/couchdb/index.html
  sed -i 's/^;admin = .*/root = vagrant/' etc/local.ini
  sed -i 's/^;bind_address = .*/bind_address = 0.0.0.0/' etc/local.ini
  sed -i 's/^;WWW-Authenticate =/WWW-Authenticate =/' etc/local.ini
  service couchdb restart
  cd "$DUD" || exit
fi
