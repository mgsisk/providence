#!/bin/sh
# shellcheck disable=2046 disable=2153
#
# Build and configure a WordPress site.
# ------------------------------------------------------------------------------

if grep -qw wordpress /tmp/prov
  then echo 'quiet: true' >>.wp-cli/config.yml

  : "${WP_DATA:=https://raw.githubusercontent.com/WPTRT/theme-unit-test/master/themeunittestdata.wordpress.xml}"
  : "${WP_PLUGINS:=.}"
  : "${WP_SRC:=https://develop.svn.wordpress.org/branches}"
  : "${WP_THEMES:=.}"
  : "${WP_SRV:=/srv/web}"

  echo " $WP_PLUGINS wordpress-importer " >/tmp/wp-plugins
  sed -i 's/ \. / debug-bar debug-bar-console debug-bar-cron developer jetpack log-deprecated-notices log-viewer monster-widget piglatin polldaddy query-monitor rewrite-rules-inspector rtl-tester regenerate-thumbnails simply-show-hooks simply-show-ids theme-check theme-test-drive user-switching wordpress-beta-tester /' /tmp/wp-plugins
  sed -i 's/ /\n/g' /tmp/wp-plugins
  sed -i '/^$/d' /tmp/wp-plugins
  sort -uo /tmp/wp-plugins /tmp/wp-plugins

  echo " $WP_THEMES $WP_THEME " >/tmp/wp-themes
  sed -i 's/ \. / classic default twentyten twentyeleven twentytwelve twentythirteen twentyfourteen twentyfifteen twentysixteen twentyseventeen twentynineteen twentytwenty twentytwentyone /' /tmp/wp-themes
  sed -i 's/ /\n/g' /tmp/wp-themes
  sed -i '/^$/d' /tmp/wp-themes
  sort -uo /tmp/wp-themes /tmp/wp-themes

  cwpv=$(wp core version 2>/dev/null)
  : "${WP_VER:=$cwpv}"

  if [ "$WP_VER" != "$cwpv" ] || ! wp core is-installed 2>/dev/null
    then echo "Creating WordPress site"
    rm -rf "$WP_SRV"
    mkdir -p "$WP_SRV"
    mysql -u root '-pvagrant' -e 'drop schema if exists wp'
    mysql -u root '-pvagrant' -e 'create schema if not exists wp'
    [ -n "$WP_VER" ] && wp core download --version="$WP_VER"
    [ -z "$WP_VER" ] && wp core download
    wp core config
    wp core multisite-install
    wp theme install $(tr "\n" ' ' </tmp/wp-themes)
    xargs -l wp theme enable </tmp/wp-themes
    wp plugin install $(tr "\n" ' ' </tmp/wp-plugins)
    grep -qw piglatin /tmp/wp-plugins && wp plugin deactivate piglatin
    [ -n "$WP_THEME" ] && wp theme activate "$WP_THEME"

    mkdir -p "$WP_SRV/wp-content/mu-plugins"

    if echo "$WP_DATA" | grep -q ^/
      then wp import "$WP_DATA" >/dev/null
    elif [ -n "$WP_DATA" ]
      then wget -nc -qO /tmp/wpdata.xml "$WP_DATA"
      wp import /tmp/wpdata.xml >/dev/null
    fi
  fi

  wp option update blogdescription 'Non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Eaque ipsa quae ab illo inventore veritatis et quasi. Itaque earum rerum hic tenetur a sapiente delectus. Nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam.'
  wp option update blogname "$(hostname -f) quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt"
  wp option update comments_per_page 5
  wp option update page_comments 1
  wp option update posts_per_page 5
  wp option update timezone_string "$TZ"
  wp option update uploads_use_yearmonth_folders 0
  wp option update fileupload_maxk 999999999
  wp site option update fileupload_maxk 999999999
  wp rewrite structure '/%year%/%monthnum%/%postname%/'

  cat <<_ >"$WP_SRV/.htaccess"
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteRule ^([_0-9a-zA-Z-]+/)?wp-admin$ \$1wp-admin/ [R=301,L]
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]
RewriteRule ^([_0-9a-zA-Z-]+/)?(wp-(content|admin|includes).*) \$2 [L]
RewriteRule ^([_0-9a-zA-Z-]+/)?(.*\.php)$ \$2 [L]
RewriteRule . index.php [L]
_

  cat <<_ >"$WP_SRV/wp-content/mu-plugins/prov.php"
<?php
add_filter(
  'admin_bar_menu',
  function( \$admin_bar ) {
    \$admin_bar->add_node( [
      'href'   => 'http://$(hostname -f):1234',
      'id'     => 'prov-admin',
      'parent' => 'top-secondary',
      'title'  => __( 'System' ),
      'meta'   => [
        'target' => '_blank',
      ],
    ] );
  },
  999999999
);
_

  if dpkg --get-selections | grep -q '^nginx.*\si'
    then cat <<_ >/etc/nginx/conf.d/wordpress.conf
map \$uri \$blogname {
  ~^(?P<blogpath>/[^/]+/)files/(.*) \$blogpath;
}

map \$blogname \$blogid {
  default -999;
}
_

    cat <<_ >/etc/nginx/conf.d/web/wordpress.conf
if (!-e \$request_filename) {
  rewrite /wp-admin$ \$scheme://$(hostname -f)${WP_SRV#/srv/web}\$uri/ permanent;
  rewrite ^/([^/]+)?(/wp-.*) /\$2 last;
  rewrite ^/([^/]+)?(/.*\\.php)$ /\$2 last;
}

location ~ ^(/[^/]+/)?files/(.+) {
  try_files /srv/blogs.dir/\$blogid/files/\$2 /wp-includes/ms-files.php?file=\$2;
  access_log off;
  log_not_found off;
  expires max;
}

location ^~ /blogs.dir {
  internal;
  alias $WP_SRV/wp-content/blogs.dir;
  access_log off;
  log_not_found off;
  expires max;
}
_
  fi

  if [ -s "$COMPOSER_CNF" ] && grep -q '^ *"type": *"wordpress-plugin"' "$COMPOSER_CNF"
    then ln -fs "$WP_DIR" "$WP_SRV/wp-content/plugins/$(hostname -f | tr '\.' '-')"
    wp option update a8c_developer --format=json '{"project_type":"wporg"}'
  elif [ -s "$COMPOSER_CNF" ] && grep -q '^ *"type": *"wordpress-theme"' "$COMPOSER_CNF"
    then ln -fs "$WP_DIR" "$WP_SRV/wp-content/themes/$(hostname -f | tr '\.' '-')"
    wp theme enable "$(hostname)-test"
    wp option update a8c_developer --format=json '{"project_type":"wporg-theme"}'
  fi

  [ -z "$WP_VER" ] && WP_VER=$(wp core version 2>/dev/null)

  if [ "$(printf '%s' "$WP_VER" | tr -d '[:digit:]' | wc -c)" -gt 1 ]
    then WP_SRC=${WP_SRC%/branches}/tags
    echo "$WP_VER" | grep -q '\.0$' && WP_VER=$(printf '%s' "$WP_VER" | cut -d. -f-2)
  fi

  if [ -d "$TEST_DIR/phpunit" ] && wget -q --method=HEAD "$WP_SRC/$WP_VER/tests/phpunit/"
    then echo 'Installing WordPress PHPUnit Tests'
    wget -qr -nc -np -nH --cut-dirs=4 -erobots=off -P "$TEST_DIR/phpunit/wordpress" -R 'index.html*' "$WP_SRC/$WP_VER/tests/phpunit/"
    wget -qr -nc -np -nH --cut-dirs=3 -erobots=off -P "$TEST_DIR/phpunit/wordpress/src" -R 'index.html*' "$WP_SRC/$WP_VER/src/"
    wget -nc -qO "$TEST_DIR/phpunit/wordpress/wp-tests-config.php" "$WP_SRC/$WP_VER/wp-tests-config-sample.php"
    wget -nc -qO '/tmp/wordpress-salt' https://api.wordpress.org/secret-key/1.1/salt
    sed -i 's/youremptytestdbnamehere/wp/' "$TEST_DIR/phpunit/wordpress/wp-tests-config.php"
    sed -i 's/yourpasswordhere/vagrant/' "$TEST_DIR/phpunit/wordpress/wp-tests-config.php"
    sed -i 's/yourusernamehere/root/' "$TEST_DIR/phpunit/wordpress/wp-tests-config.php"
    sed -i "s|example.org|$(hostname -f)${WP_SRV#/srv/web}|" "$TEST_DIR/phpunit/wordpress/wp-tests-config.php"
    sed -i "s/localhost/$(hostname -f)/" "$TEST_DIR/phpunit/wordpress/wp-tests-config.php"
    sed -i "/_KEY'/d" "$TEST_DIR/phpunit/wordpress/wp-tests-config.php"
    sed -i "/_SALT'/d" "$TEST_DIR/phpunit/wordpress/wp-tests-config.php"
    cat '/tmp/wordpress-salt' >> "$TEST_DIR/phpunit/wordpress/wp-tests-config.php"
  fi

  if [ -d "$TEST_DIR/qunit" ] && wget -q --method=HEAD "$WP_SRC/$WP_VER/tests/qunit/"
    then echo 'Installing WordPress QUnit Tests'
    wget -qr -nc -np -nH --cut-dirs=4 -erobots=off -P "$TEST_DIR/qunit/wordpress" -R 'index.html*' "$WP_SRC/$WP_VER/tests/qunit/"
    wget -nc -qO "$TEST_DIR/qunit/wordpress/index.html" "$WP_SRC/$WP_VER/tests/qunit/index.html"
    sed -i "s|localhost|$(hostname -f)${WP_SRV#/srv/web}|" "$TEST_DIR/qunit/wordpress/index.html"
    sed -i 's|="\.\./[^.]|="../../|' "$TEST_DIR/qunit/wordpress/index.html"
  fi

  [ "$WP_SRV" != /srv/web ] && [ ! -s /srv/web/index.html ] && echo "<meta http-equiv='refresh' content='0; url=${WP_SRV#/srv/web}'>" >/srv/web/index.html

  sed -i '/quiet: true/d' .wp-cli/config.yml
fi
