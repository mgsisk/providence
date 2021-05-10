#!/bin/sh
#
# Configure wp-cli.
# ------------------------------------------------------------------------------

if command -v wp >/dev/null
  then echo 'Configuring wp-cli'
  export WP_CLI_ALLOW_ROOT=:
  mkdir -p .wp-cli /root/.wp-cli
  : "${WP_SRV:=/srv/web}"

  cat <<_ >.wp-cli/config.yml
path: $WP_SRV

core config:
  dbname: wp
  dbuser: root
  dbpass: vagrant
  extra-php: |
    define( 'FS_METHOD', 'direct' );
    define( 'JETPACK_DEV_DEBUG', true );
    define( 'SAVEQUERIES', true );
    define( 'SCRIPT_DEBUG', true );
    define( 'WP_DEBUG_DISPLAY', true );
    define( 'WP_DEBUG_LOG', true );
    define( 'WP_DEBUG', true );
    define( 'WP_ENVIRONMENT_TYPE', 'development' );

core download:
  path: $WP_SRV

core multisite-install:
  url: $(hostname -f)${WP_SRV#/srv/web}
  title: $(hostname -f)
  admin_user: root
  admin_password: vagrant
  admin_email: root@$(hostname -f)

import:
  authors: create

plugin deactivate:
  network: true

plugin install:
  activate-network: true

theme install:
  force: true

theme enable:
  network: true
_

  ln -fs "$VUD/.wp-cli/config.yml" /root/.wp-cli/config.yml
fi
