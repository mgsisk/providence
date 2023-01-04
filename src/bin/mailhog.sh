#!/bin/sh
#
# Install MailHog.
# ------------------------------------------------------------------------------

if grep -qw mailhog /tmp/prov
  then echo 'Installing MailHog'
  wget -nc -qO /tmp/mailhog.v https://api.github.com/repos/mailhog/mailhog/releases/latest
  wget -nc -qO /usr/local/bin/mailhog "$(grep browser_download_url /tmp/mailhog.v | grep "$(uname | tr '[:upper:]' '[:lower:]')_$(dpkg --print-architecture)" | cut -d\" -f4)"
  chmod +x /usr/local/bin/mailhog
fi
