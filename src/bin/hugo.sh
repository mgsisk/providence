#!/bin/sh
#
# Install Hugo and related packages.
# ------------------------------------------------------------------------------

if grep -qw hugo /tmp/prov
  then echo 'Installing Hugo'
  mkdir -p /usr/local/lib/hugo
  wget -nc -qO /tmp/hugo.v https://api.github.com/repos/gohugoio/hugo/releases/latest
  wget -nc -qO /tmp/hugo.tar.gz "$(grep browser_download_url /tmp/hugo.v | grep -m1 "$(uname)-$(file /bin/dpkg | grep -o '[0-9]*-bit' | tr -d '-')\.tar.gz" | cut -d\" -f4)"
  tar -xkf /tmp/hugo.tar.gz -C /usr/local/lib/hugo 2>/dev/null
  ln -fs /usr/local/lib/hugo/hugo /usr/local/bin/hugo
fi
