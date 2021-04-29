#!/bin/sh
#
# Build a generic site.
# ------------------------------------------------------------------------------

if [ -d "$WEB_DIR" ]
  then echo 'Creating web site'
  : "${WEB_SRV:=/srv/web}"
  rm -rf "$WEB_SRV"
  ln -fs "$WEB_DIR" "$WEB_SRV"
fi
