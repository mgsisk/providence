#!/bin/sh
#
# Install Docker Compose.
# ------------------------------------------------------------------------------

if grep -qw docker /tmp/prov
  then  echo 'Installing Docker Compose'
  wget -nc -qO /tmp/docker-compose.v https://api.github.com/repos/docker/compose/releases/latest
  wget -nc -qO /usr/local/bin/docker-compose "$(grep browser_download_url /tmp/docker-compose.v | grep "$(uname -s)-$(uname -m)\"" | cut -d\" -f4)"
  chmod +x /usr/local/bin/docker-compose
fi
