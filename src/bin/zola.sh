#!/bin/sh
#
# Install Zola and related packages.
# ------------------------------------------------------------------------------

if grep -qw zola /tmp/prov
  then echo 'Installing Zola'
  wget -nc -qO /tmp/zola.v https://api.github.com/repos/getzola/zola/releases/latest
  wget -nc -qO /tmp/zola.tar.gz "$(grep browser_download_url /tmp/zola.v | grep linux | cut -d\" -f4)"
  tar -xkf /tmp/zola.tar.gz -C /usr/local/bin 2>/dev/null
fi
