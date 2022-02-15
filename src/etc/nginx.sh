#!/bin/sh
#
# Configure Nginx.
# ------------------------------------------------------------------------------

if dpkg --get-selections | grep -q '^nginx.*\si'
  then echo 'Configuring Nginx'
  cd /etc/nginx || exit
  mkdir -p conf.d/sys conf.d/web /srv/sys/server /srv/web
  rm -f sites-available/default sites-enabled/default
  touch php-fpm /srv/sys/server/index.html

  cat <<_ >sites-available/sys.conf
server {
  server_name sys.$(hostname -f);

  listen 80;
  listen 1234;
  listen 443 ssl;

  root /srv/sys;

  client_max_body_size 999m;

  index index.html index.php;

  location ~ \.php$ {
    include php-fpm;
  }

  location / {
    try_files \$uri \$uri/ \$uri.html \$uri.php /index.php?\$args;
  }

  ssl_certificate $CERT;
  ssl_certificate_key $CKEY;

  include /etc/nginx/conf.d/sys/*.conf;
}
_

  cat <<_ >conf.d/sys/stub-status.conf
location /server {
  stub_status;
}
_

  cat <<_ >sites-available/web.conf
server {
  server_name $(hostname -f);

  listen 80;
  listen 443 ssl;

  root /srv/web;

  client_max_body_size 999m;

  index index.html index.php;

  location ~ \.php$ {
    include php-fpm;
  }

  location / {
    try_files \$uri \$uri/ \$uri.html \$uri.php /index.php?\$args;
  }

  ssl_certificate $CERT;
  ssl_certificate_key $CKEY;

  include /etc/nginx/conf.d/web/*.conf;
}
_

  ln -fs /etc/nginx/sites-available/sys.conf sites-enabled/sys.conf
  ln -fs /etc/nginx/sites-available/web.conf sites-enabled/web.conf
  cd "$VUD" || exit
fi
