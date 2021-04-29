#!/bin/sh
#
# Configure webmin.
# ------------------------------------------------------------------------------

if dpkg --get-selections | grep -q '^webmin.*\si'
  then echo 'Configuring webmin'
  mkdir -p /srv/sys/webmin
  echo "<meta http-equiv='refresh' content='0; url=http://$(hostname -f):10000'>" >/srv/sys/webmin/index.html
  sed -i 's/ssl=1/ssl=0/' /etc/webmin/miniserv.conf
  service webmin restart
fi
