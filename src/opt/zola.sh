#!/bin/sh
#
# Build a Zola site.
# ------------------------------------------------------------------------------

if [ -d "$ZOLA_DIR" ] && grep -qw zola /tmp/prov
  then cd "$ZOLA_DIR" || exit
  echo 'Creating Zola site'
  : "${ZOLA_CNF:=$ZOLA_DIR/config.toml}"
  [ -z "$ZOLA_SRV" ] && ZOLA_SRV=/srv/web$(grep -s "^base_url[= ]*" "$ZOLA_CNF" | tr -d '"' | tr -d "'" | cut -d/ -f4- | printf '/%s' "$(cat -)" | sed 's|/$||')
  rm -rf "$ZOLA_SRV"
  zola build -u "http://$(hostname -f)${ZOLA_SRV#/srv/web}" -o "$ZOLA_SRV" >/dev/null

  if dpkg --get-selections | grep -q '^apache.*\si'
    then echo "ErrorDocument 404 ${ZOLA_SRV#/srv/web}/404.html" >/etc/apache2/conf-available/web/zola.conf
    ln -fs /etc/apache2/conf-available/web/zola.conf /etc/apache2/conf-enabled/web/zola.conf
  fi

  dpkg --get-selections | grep -q '^nginx.*\si' && echo "error_page 404 ${ZOLA_SRV#/srv/web}/404.html;" >/etc/nginx/conf.d/web/zola.conf
  cd "$VUD" || exit
fi
