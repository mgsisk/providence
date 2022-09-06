#!/bin/sh
# shellcheck disable=2154
#
# Terminate provisioning.
# ------------------------------------------------------------------------------

cat <<_ >/tmp/prov-web
<!DOCTYPE html>
<meta charset="utf-8">
<meta name="generator" value="https://github.com/mgsisk/providence" data-providence-version="0.1.4">
<meta name="viewport" content="initial-scale=1,width=device-width">
<title>$(hostname -f)</title>
<style>
:root {
  --color-back: #fff;
  --color-text: #333;
  --color-link: #82f;
}

html {
  background: var(--color-back);
  color: var(--color-text);
  font: bold calc(0.8em + 1vw)/1 system-ui;
  text-align: center;
}

body {
  display: flex;
  flex-flow: column;
  gap: 0.5em;
  margin: 1em;
}

a {
  color: inherit;
  padding: 1em;
  text-decoration: none;
}

a:focus,
a:hover {
  color: var(--color-link);
  outline: 0.1em dashed;
}

a:active {
  outline-style: solid;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-back: #333;
    --color-text: #fff;
    --color-link: #C9f;
  }
}

@media (prefers-contrast: more) {
  :root {
    --color-text: #000;
  }
}

@media (prefers-contrast: more) and (prefers-color-scheme: dark) {
  :root {
    --color-back: #000;
  }
}

@media (prefers-contrast: less) {
  body {
    opacity: 0.62;
  }
}
</style>
_

[ -d /srv/web ] && { [ -z "$(find /srv/web -maxdepth 1 -name 'index*')" ] || grep -qsw data-providence-version /srv/web/index.html; } && cat <<_ >/srv/web/index.html
$(cat /tmp/prov-web)
$(find /srv/web -maxdepth 2 -mindepth 2 -name 'index*' | sort | sed 's|/srv/web/||' | sed 's|\(.*\)/index.*|\1:\1|' | sed 's|^|<a href="|' | sed 's|:|">|' | sed 's|$|</a>|')
_

[ -d /srv/sys ] && cat <<_ >/srv/sys/index.html
$(sed 's/<title>/<title>sys./' </tmp/prov-web)
<a href='//$(hostname -f)'>$(hostname -f)</a>
$(find /srv/sys -maxdepth 2 -mindepth 2 -name 'index*' | sort | sed 's|/srv/sys/||' | sed 's|\(.*\)/index.*|\1:\1|' | sed 's|^|<a href="|' | sed 's|:|">|' | sed 's|$|</a>|')
_

chown -R vagrant:vagrant "$VUD"
chown -R www-data:www-data /srv

service --status-all | grep -q '+.*apache2' && service apache2 restart
service --status-all | grep -q '+.*nginx' && service nginx restart

term=$(date +%s)
mins=$(((term - init) / 60))
secs=$((term - init - mins * 60))

printf 'Provisioning completed in %02dm %02ds\n' "$mins" "$secs"
lsof -i:80 >/dev/null && echo "Now serving $(hostname -I | cut -d' ' -f2) at $(hostname -f)"
lsof -i:1234 >/dev/null && echo "See $(hostname -I | cut -d' ' -f2):1234 or sys.$(hostname -f) for guest utilities"

:
