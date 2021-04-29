#!/bin/sh
#
# Build a Hugo site.
# ------------------------------------------------------------------------------

if [ -d "$HUGO_DIR" ] && grep -qw hugo /tmp/prov
  then cd "$HUGO_DIR" || exit
  echo 'Creating Hugo site'
  [ -z "$HUGO_SRV" ] && HUGO_SRV=/srv/web$(hugo config | grep '^baseurl[= :]*' | tr -d '"' | tr -d "'" | cut -d/ -f4- | printf '/%s' "$(cat -)" | sed 's|/$||')
  rm -rf "$HUGO_SRV"
  hugo --quiet -b "http://$(hostname -f)${HUGO_SRV#/srv/web}" -d "$HUGO_SRV"

  if dpkg --get-selections | grep -q '^apache.*\si'
    then echo "ErrorDocument 404 ${HUGO_SRV#/srv/web}')/404.html" >/etc/apache2/conf-available/web/hugo.conf
    ln -fs /etc/apache2/conf-available/web/hugo.conf /etc/apache2/conf-enabled/web/hugo.conf
  fi

  dpkg --get-selections | grep -q '^nginx.*\si' && echo "error_page 404 ${HUGO_SRV#/srv/web}/404.html;" >/etc/nginx/conf.d/web/hugo.conf
  cd "$VUD" || exit
fi
