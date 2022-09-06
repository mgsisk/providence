#!/bin/sh
# shellcheck disable=2034
#
# Initiate provisioning.
# ------------------------------------------------------------------------------

init=$(date +%s)

export DEBIAN_FRONTEND=noninteractive

echo 'Provisioning with Providence v0.1.4'

VUD=$(getent passwd vagrant | cut -d: -f6) && cd "$VUD" || exit
LSBC=$(lsb_release -cs | tr '[:upper:]' '[:lower:]')
LSBI=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

grep -qw "$LANG" /etc/locale.gen || LANG=en_US.UTF-8
sed -i "s/# *$LANG/$LANG/" /etc/locale.gen
locale-gen "$LANG" >/dev/null
update-locale LANG="$LANG"
[ -n "$ZONE" ] && [ -s "/usr/share/zoneinfo/$ZONE" ] && timedatectl set-timezone "$ZONE"

: "${BUNDLER_CNF:=/vagrant/Gemfile}"
: "${CARGO_CNF:=/vagrant/Cargo.toml}"
: "${COMPOSER_CNF:=/vagrant/composer.json}"
: "${DOCKER_CNF:=/vagrant/Dockerfile}"
: "${DOCKER_COMPOSE_CNF:=/vagrant/docker-compose.yml}"
: "${GIT_DIR:=/vagrant/.git}"
: "${GITHUB_DIR:=/vagrant/.github}"
: "${HG_DIR:=/vagrant/.hg}"
: "${LOGIN_SHELL:=/bin/bash}"
: "${LOGIN_SHELL_CNF:=.bash_profile}"
: "${NODE_CNF:=/vagrant/package.json}"
: "${PIPENV_CNF:=/vagrant/Pipfile}"
: "${PROVIDENCE:=.}"
: "${RUST_CNF:=/vagrant/rust-toolchain.toml}"
: "${SHELLSPEC_CNF:=/vagrant/.shellspec}"
: "${SVN_DIR:=/vagrant/.svn}"
: "${TEST_DIR:=/vagrant/test}"

touch .profile /root/.profile
[ -s $LOGIN_SHELL_CNF ] || echo '' >$LOGIN_SHELL_CNF
[ -s /root/$LOGIN_SHELL_CNF ] || echo '' >/root/$LOGIN_SHELL_CNF
grep -q '\.profile' $LOGIN_SHELL_CNF || sed -i '1 i\. ~/.profile' $LOGIN_SHELL_CNF
grep -q '\.profile' /root/$LOGIN_SHELL_CNF || sed -i '1 i\. ~/.profile' /root/$LOGIN_SHELL_CNF

[ -z "$JEKYLL_DIR" ] && [ -s "$JEKYLL_CNF" ] && JEKYLL_DIR=$(dirname "$JEKYLL_CNF")
[ -z "$JEKYLL_DIR" ] && grep -qs '\bjekyll' "$BUNDLER_CNF" && JEKYLL_DIR=$(dirname "$BUNDLER_CNF")
[ -z "$PELICAN_DIR" ] && [ -s "$PELICAN_CNF" ] && PELICAN_DIR=$(dirname "$PELICAN_CNF")
[ -z "$PELICAN_DIR" ] && grep -qs '\bpelican' "$PIPENV_CNF" && PELICAN_DIR=$(dirname "$PIPENV_CNF")
[ -z "$WP_DIR" ] && [ -s "$WP_CNF" ] && WP_DIR=$(dirname "$WP_CNF")
[ -z "$WP_DIR" ] && grep -qs '\bwordpress' "$COMPOSER_CNF" && WP_DIR=$(dirname "$COMPOSER_CNF")
[ -z "$ZOLA_DIR" ] && [ -s "$ZOLA_CNF" ] && ZOLA_DIR=$(dirname "$ZOLA_CNF")
[ -z "$WP_CNF" ] && [ -d "$WP_DIR" ] && WP_CNF=$WP_DIR/readme.txt

[ -z "$NODE_VER" ] && grep -qs '"node":' "$NODE_CNF" && NODE_VER=$(grep -m1 '"node": *"[^"]*' "$NODE_CNF" | cut -d\" -f4 | tr -cd '[:digit:]. ' | cut -d' ' -f1)
[ -z "$PHP_VER" ] && grep -qs 'Requires PHP:' "$WP_CNF" && PHP_VER=$(grep -m1 'Requires PHP: ' "$WP_CNF" | cut -d' ' -f3 | cut -d. -f-2)
[ -z "$PHP_VER" ] && grep -qs '"php":' "$COMPOSER_CNF" && PHP_VER=$(grep -m1 '"php": *"[^"]*' "$COMPOSER_CNF" | cut -d\" -f4 | cut -d' ' -f1 | tr -cd '[:digit:]. ' | cut -d' ' -f1 | cut -d. -f-2)
[ -z "$PYTHON_VER" ] && grep -qs PYTHON_VER "$PIPENV_CNF" && PYTHON_VER=$(grep -m1 -o "^PYTHON_VER[= '\"]*[^'\"]*" "$PIPENV_CNF" | sed "s/^PYTHON_VER[= '\"]*//")
[ -z "$RUBY_VER" ] && grep -qs '^ruby ' "$BUNDLER_CNF" && RUBY_VER=$(grep -m1 -o "^ruby *'[^']*" "$BUNDLER_CNF" | sed "s/^ruby *'//")
[ -z "$RUBY_VER" ] && grep -qs :engine "$BUNDLER_CNF" && RUBY_VER=$(grep -m1 "^ruby *'" "$BUNDLER_CNF" | grep -o ":engine *=> *'[^']*" | sed "s/^:engine *=> *'//")-$(grep -m1 "^ruby *'" "$BUNDLER_CNF" | grep -o ":engine_version *=> *'[^']*" | sed "s/^:engine_version *=> *'//")
[ -z "$RUBY_VER" ] && grep -qs :patchlevel "$BUNDLER_CNF" && RUBY_VER="$RUBY_VER-p$(grep -m1 "^ruby *'" "$BUNDLER_CNF" | grep -o ":patchlevel *=> *'[^']*" | sed "s/^:patchlevel *=> *'//")"
[ -z "$RUST_VER" ] && grep -qs channel "$RUST_CNF" && RUST_VER=$(grep -m1 '^channel[= ]*' "$RUST_CNF" | sed "s/^channel[= ]*//" | tr -d '"' | tr -d "'")
[ -z "$WP_VER" ] && grep -qs 'Requires at least:' "$WP_CNF" && WP_VER=$(grep -m1 "Requires at least: " "$WP_CNF" | cut -d' ' -f4)
[ -z "$WP_VER" ] && grep -qs '\bwordpress' "$COMPOSER_CNF" && WP_VER=$(grep -m1 '\bwordpress' "$COMPOSER_CNF" | cut -d\" -f4 | cut -d' ' -f1 | tr -cd '[:digit:].' | cut -d. -f-3)

echo "$GO_VER" | grep -iq '[a-z_-]' || GO_VER="$(printf '%s.0.0' "$GO_VER" | cut -d. -f-3 | sed 's/^\.0\.0$//')"
echo "$NODE_VER" | grep -iq '[a-z_-]' || NODE_VER="$(printf '%s.0.0' "$NODE_VER" | cut -d. -f-3 | sed 's/^\.0\.0$//')"
echo "$PERL_VER" | grep -iq '[a-z_-]' || PERL_VER="$(printf '%s.0.0' "$PERL_VER" | cut -d. -f-3 | sed 's/^\.0\.0$//')"
echo "$PYTHON_VER" | grep -iq '[a-z_-]' || PYTHON_VER="$(printf '%s.0.0' "$PYTHON_VER" | cut -d. -f-3 | sed 's/^\.0\.0$//')"
echo "$RUBY_VER" | grep -iq '[a-z_-]' || RUBY_VER="$(printf '%s.0.0' "$RUBY_VER" | cut -d. -f-3 | sed 's/^\.0\.0$//')"
echo "$WP_VER" | grep -iq '[a-z_-]' || WP_VER="$(printf '%s.0.0' "$WP_VER" | cut -d. -f-3 | sed 's/^\.0\.0$//' | sed 's/\.0$//')"
PHP_VER="$(printf '%s.0.0' "$PHP_VER" | cut -d. -f-2 | sed 's/^\.0$//')"

: >/tmp/prov-key
[ -d "$GIT_DIR" ] && echo 'git' >>/tmp/prov-key
[ -d "$GITHUB_DIR" ] && echo 'github' >>/tmp/prov-key
[ -d "$HG_DIR" ] && echo 'hg' >>/tmp/prov-key
[ -d "$HUGO_DIR" ] && echo 'hugo nginx' >>/tmp/prov-key
[ -d "$JEKYLL_DIR" ] && echo 'jekyll nginx ruby' >>/tmp/prov-key
[ -d "$PELICAN_DIR" ] && echo 'nginx pelican python' >>/tmp/prov-key
[ -d "$SVN_DIR" ] && echo 'svn' >>/tmp/prov-key
[ -d "$ZOLA_DIR" ] && echo 'nginx zola' >>/tmp/prov-key
[ -n "$GO_VER" ] && echo 'go' >>/tmp/prov-key
[ -n "$MARIA_VER" ] && echo 'mariadb' >>/tmp/prov-key
[ -n "$MONGO_VER" ] && echo 'mongodb' >>/tmp/prov-key
[ -n "$PERL_VER" ] && echo 'perl' >>/tmp/prov-key
[ -s "$SHELLSPEC_CNF" ] && echo 'shell' >>/tmp/prov-key
{ [ -d "$WEB_DIR" ] || [ -s "$CERT" ] || [ -s "$CKEY" ]; } && echo 'nginx' >>/tmp/prov-key
{ [ -d "$WP_DIR" ] || [ -n "$WP_DATA$WP_PLUGINS$WP_SRC$WP_THEME$WP_THEMES$WP_VER" ]; } && echo 'apache mailhog mariadb php svn wordpress' >>/tmp/prov-key
{ [ -n "$NODE_VER" ] || [ -s "$NODE_CNF" ]; } && echo 'node' >>/tmp/prov-key
{ [ -n "$PHP_VER" ] || [ -s "$COMPOSER_CNF" ]; } && echo 'php' >>/tmp/prov-key
{ [ -n "$PYTHON_VER" ] || [ -s "$PIPENV_CNF" ]; } && echo 'python' >>/tmp/prov-key
{ [ -n "$RUBY_VER" ] || [ -s "$BUNDLER_CNF" ]; } && echo 'ruby' >>/tmp/prov-key
{ [ -n "$RUST_VER" ] || [ -s "$CARGO_CNF" ] || [ -s "$RUST_CNF" ]; } && echo 'rust' >>/tmp/prov-key
{ [ -s "$DOCKER_COMPOSE_CNF" ] || [ -s "$DOCKER_CNF" ]; } && echo 'docker' >>/tmp/prov-key
tr ' ' '\n' </tmp/prov-key >/tmp/p && mv /tmp/p /tmp/prov-key
sed -i '/^$/d' /tmp/prov-key
sort -uo /tmp/prov-key /tmp/prov-key

: "${CERT:=/etc/ssl/certs/ssl-cert-snakeoil.pem}"
: "${CKEY:=/etc/ssl/private/ssl-cert-snakeoil.key}"
: "${MARIA_VER:=10.10}"
: "${MONGO_VER:=6.0}"

echo " $PROVIDENCE " >/tmp/prov
sed -i 's/ \* / apache couchdb docker git github go hg hugo jekyll mailhog mariadb memcached mongodb nginx node pelican perl php postgres python redis ruby rust shell sqlite svn webmin wordpress xml zola /' /tmp/prov
tr ' ' '\n' </tmp/prov >/tmp/p && mv /tmp/p /tmp/prov
grep -qw . /tmp/prov && cat /tmp/prov-key >> /tmp/prov
sed -i '/^\.\?$/d' /tmp/prov
sort -uo /tmp/prov /tmp/prov
