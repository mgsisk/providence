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

config create:
  dbname: wp
  dbuser: root
  dbpass: vagrant

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

  ln -fs "$DUD/.wp-cli/config.yml" /root/.wp-cli/config.yml
fi
