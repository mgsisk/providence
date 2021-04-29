#!/bin/sh
#
# Install shellspec and related packages.
# ------------------------------------------------------------------------------

if grep -qw shell /tmp/prov
  then echo 'Installing ShellSpec'
  wget -nc -qO /tmp/shellspec.v https://api.github.com/repos/shellspec/shellspec/releases/latest
  wget -nc -qO /tmp/shellspec.tar.gz "$(grep browser_download_url /tmp/shellspec.v | cut -d\" -f4)"
  tar -xkf /tmp/shellspec.tar.gz -C /usr/local/lib 2>/dev/null
  ln -fs /usr/local/lib/shellspec/shellspec /usr/local/bin/shellspec
fi
