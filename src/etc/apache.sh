#!/bin/sh
#
# Configure Apache.
# ------------------------------------------------------------------------------

if dpkg --get-selections | grep -q '^apache.*\si'
  then echo 'Configuring Apache'
  cd /etc/apache2 || exit
  a2enmod -q info proxy proxy_fcgi proxy_http rewrite setenvif socache_shmcb ssl >/dev/null
  grep -q '1234' ports.conf || echo 'Listen 1234' >>ports.conf
  mkdir -p conf-available/sys conf-enabled/sys conf-available/web conf-enabled/web /srv/sys/server /srv/web
  rm -f sites-available/000-default.conf sites-enabled/000-default.conf sites-available/default-ssl.conf
  touch conf-enabled/php-fpm.conf /srv/sys/server/index.html

  cat <<_ >conf-available/root.conf
<Directory /srv/>
  AllowOverride All
  EnableSendfile Off
  Options FollowSymLinks Indexes MultiViews
  Require all granted
</Directory>
_

  cat <<_ >sites-available/sys.conf
<VirtualHost *:80 *:1234>
  ServerName sys.$(hostname -f)
  DocumentRoot /srv/sys
  Include conf-enabled/php-fpm.conf
  IncludeOptional conf-enabled/sys/*.conf
</VirtualHost>

<VirtualHost *:443>
  ServerName sys.$(hostname -f)
  DocumentRoot /srv/sys
  SSLEngine on
  SSLCertificateFile $CERT
  SSLCertificateKeyFile $CKEY

  <FilesMatch "\.(cgi|phtml|php|shtml)$">
    SSLOptions +StdEnvVars
  </FilesMatch>

  <Directory "/usr/lib/cgi-bin">
    SSLOptions +StdEnvVars
  </Directory>

  IncludeOptional conf-enabled/sys/*.conf
</VirtualHost>
_

  cat <<_ >sites-available/web.conf
<VirtualHost *:80>
  ServerName $(hostname -f)
  DocumentRoot /srv/web
  Include conf-enabled/php-fpm.conf
  IncludeOptional conf-enabled/web/*.conf
</VirtualHost>

<VirtualHost *:443>
  ServerName $(hostname -f)
  DocumentRoot /srv/web
  SSLEngine on
  SSLCertificateFile $CERT
  SSLCertificateKeyFile $CKEY

  <FilesMatch "\.(cgi|phtml|php|shtml)$">
    SSLOptions +StdEnvVars
  </FilesMatch>

  <Directory "/usr/lib/cgi-bin">
    SSLOptions +StdEnvVars
  </Directory>

  IncludeOptional conf-enabled/web/*.conf
</VirtualHost>
_

  cat <<_ >conf-available/sys/server-info.conf
<Location "/server">
  SetHandler server-info
</Location>
_

  ln -fs /etc/apache2/conf-available/root.conf conf-enabled/root.conf
  ln -fs /etc/apache2/conf-available/sys/server-info.conf conf-enabled/sys/server-info.conf
  ln -fs /etc/apache2/sites-available/sys.conf sites-enabled/sys.conf
  ln -fs /etc/apache2/sites-available/web.conf sites-enabled/web.conf
  cd "$VUD" || exit
fi
