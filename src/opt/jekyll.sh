#!/bin/sh
#
# Build a Jekyll site.
# ------------------------------------------------------------------------------

if [ -d "$JEKYLL_DIR" ] && grep -qw jekyll /tmp/prov
  then cd "$JEKYLL_DIR" || exit
  if rbenv which bundle >/dev/null 2>&1 && rbenv exec bundle list 2>/dev/null | grep -qw 'jekyll '
    then echo 'Creating Jekyll site'
    [ -n "$JEKYLL_CNF" ] || JEKYLL_CNF=$(find "$JEKYLL_DIR" -maxdepth 1 \( -name '_config.y*ml' -o -name '_config.toml' \) | head -n1)
    [ -n "$JEKYLL_SRV" ] || JEKYLL_SRV=/srv/web$(grep -s "^baseurl[= :]*" "$JEKYLL_CNF" | tr -d '"' | tr -d "'" | cut -d/ -f2- | printf '/%s' "$(cat -)" | sed 's|/$||')
    rm -rf "$JEKYLL_SRV"
    rbenv exec bundle exec jekyll build -qd "$JEKYLL_SRV"

    if dpkg --get-selections | grep -q '^apache.*\si'
      then echo "ErrorDocument 404 ${JEKYLL_SRV#/srv/web}/404.html" >/etc/apache2/conf-available/web/jekyll.conf
      ln -fs /etc/apache2/conf-available/web/jekyll.conf /etc/apache2/conf-enabled/web/jekyll.conf
    fi

    dpkg --get-selections | grep -q '^nginx.*\si' && echo "error_page 404 ${JEKYLL_SRV#/srv/web}/404.html;" >/etc/nginx/conf.d/web/jekyll.conf
  fi
  cd "$DUD" || exit
fi
