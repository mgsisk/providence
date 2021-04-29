#!/bin/sh
#
# Build a Pelican site.
# ------------------------------------------------------------------------------

if [ -d "$PELICAN_DIR" ] && grep -qw pelican /tmp/prov
  then cd "$PELICAN_DIR" || exit
  if pyenv which pipenv >/dev/null 2>&1 && pyenv exec pipenv graph 2>/dev/null | grep -q ^pelican=
    then echo 'Creating Pelican site'
    [ -z "$PELICAN_CNF" ] && PELICAN_CNF=$(find "$PELICAN_DIR" -maxdepth 1 -name '*conf.py' | head -n1)
    [ -z "$PELICAN_SRV" ] && PELICAN_SRV=/srv/web$(pyenv exec pelican -s "$PELICAN_CNF" --print-settings SITEURL | tr -d "'\n" | cut -d/ -f4- | printf '/%s' "$(cat -)" | sed 's|/$||')
    rm -rf "$PELICAN_SRV"
    pyenv exec pipenv run pelican -q -s "$PELICAN_CNF" -e OUTPUT_DIR="$PELICAN_SRV" SITEURL="http://$(hostname -f)${PELICAN_SRV#/srv/web}" >/dev/null

    if dpkg --get-selections | grep -q '^apache.*\si'
      then echo "ErrorDocument 404 ${PELICAN_SRV#/srv/web}/404.html" >/etc/apache2/conf-available/web/pelican.conf
      ln -fs /etc/apache2/conf-available/web/pelican.conf /etc/apache2/conf-enabled/web/pelican.conf
    fi

    dpkg --get-selections | grep -q '^nginx.*\si' && echo "error_page 404 ${PELICAN_SRV#/srv/web}/404.html;" >/etc/nginx/conf.d/web/pelican.conf
  fi
  cd "$VUD" || exit
fi
