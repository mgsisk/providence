#!/bin/sh
# shellcheck disable=2016
#
# Install PHP and related packages.
# ------------------------------------------------------------------------------

if grep -qw php /tmp/prov
  then echo "Installing PHP $PHP_VER"
  mkdir -p /srv/sys/php
  phpv "$PHP_VER"
  echo '<?php phpinfo();' >/srv/sys/php/index.php

  echo 'Installing Composer'
  wget -nc -qO /usr/local/bin/composer https://getcomposer.org/composer.phar
  chmod +x /usr/local/bin/composer

  if [ -s "$COMPOSER_CNF" ]
    then echo 'Installing Composer packages'
    composer -qn -d "$(dirname "$COMPOSER_CNF")" install
  fi

  if grep -qw -e apache -e nginx /tmp/prov
    then if grep -qw -e mariadb -e mongodb -e postgres -e sqilte /tmp/prov
      then echo 'Installing Adminer'
      mkdir -p /srv/sys/adminer
      wget -nc -qO /tmp/adminer.v https://api.github.com/repos/vrana/adminer/releases/latest
      wget -nc -qO /srv/sys/adminer/adminer.php "$(grep browser_download_url /tmp/adminer.v | grep -m1 '[0-9]\.php' | cut -d\" -f4)"
      wget -nc -qO /tmp/adminer-plugin.v https://api.github.com/repos/vrana/adminer/contents/plugins/plugin.php
      wget -nc -qO /srv/sys/adminer/plugin.php "$(grep download_url /tmp/adminer-plugin.v | cut -d\" -f4)"
      echo '<?php class AdminerNoPass{function login($login,$password){return true;}}function adminer_object(){require "plugin.php";return new AdminerPlugin([new AdminerNoPass]);}require "adminer.php";' >/srv/sys/adminer/index.php
    fi

    echo 'Installing ocp'
    mkdir -p /srv/sys/opcache
    wget -nc -qO /tmp/ocp.v https://api.github.com/gists/4959032
    wget -nc -qO /srv/sys/opcache/index.php "$(grep raw_url /tmp/ocp.v | cut -d\" -f4)"

    if grep -qw memcached /tmp/prov
      then echo 'Installing phpMemcachedAdmin'
      mkdir -p /srv/sys/memcached
      wget -nc -qO /tmp/phpmemcachedadmin.tar.gz https://api.github.com/repos/elijaa/phpmemcachedadmin/tarball
      tar -xkf /tmp/phpmemcachedadmin.tar.gz -C /srv/sys/memcached --strip-components 1 2>/dev/null
      cp /srv/sys/memcached/Config/Memcache.sample.php /srv/sys/memcached/Config/Memcache.php
    fi

    if grep -qw redis /tmp/prov
      then echo 'Installing phpRedisAdmin'
      mkdir -p /srv/sys/redis/vendor
      wget -nc -qO /tmp/phpredisadmin.tar.gz https://api.github.com/repos/erikdubbelboer/phpredisadmin/tarball
      tar -xkf /tmp/phpredisadmin.tar.gz -C /srv/sys/redis --strip-components 1 2>/dev/null
      wget -nc -qO /tmp/predis.tar.gz https://api.github.com/repos/predis/predis/tarball
      tar -xkf /tmp/predis.tar.gz -C /srv/sys/redis/vendor --strip-components 1 2>/dev/null
    fi

    echo 'Installing Webgrind'
    mkdir -p /srv/sys/webgrind
    wget -nc -qO /tmp/webgrind.tar.gz https://api.github.com/repos/jokkedk/webgrind/tarball
    tar -xkf /tmp/webgrind.tar.gz -C /srv/sys/webgrind --strip-components 1 2>/dev/null
  fi
fi
