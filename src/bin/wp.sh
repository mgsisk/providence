#!/bin/sh
#
# Install wp-cli and related packages.
# ------------------------------------------------------------------------------

if grep -qw wordpress /tmp/prov
  then echo 'Installing wp-cli'
  wget -nc -qO /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli-nightly.phar
  chmod +x /usr/local/bin/wp
fi
