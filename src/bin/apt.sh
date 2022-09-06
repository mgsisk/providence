#!/bin/sh
# shellcheck disable=2046
#
# Install system packages.
# ------------------------------------------------------------------------------

[ ! -s /usr/lib/apt/methods/https ] && apt-get -qq update && apt-get -qq install --no-install-recommends apt-transport-https >/dev/null

cd /etc/apt/sources.list.d || exit
: >prov.list
grep -qw apache /tmp/prov && echo "deb https://packages.sury.org/apache2 $LSBC main" >>prov.list
grep -qw couchdb /tmp/prov && echo "deb https://apache.jfrog.io/artifactory/couchdb-deb $LSBC main" >>prov.list
grep -qw docker /tmp/prov && echo "deb https://download.docker.com/linux/$LSBI $LSBC stable" >>prov.list
grep -qw git /tmp/prov && echo "deb https://packagecloud.io/github/git-lfs/$LSBI $LSBC main" >>prov.list
grep -qw github /tmp/prov && echo "deb https://cli.github.com/packages $LSBC main" >>prov.list
grep -qw mariadb /tmp/prov && echo "deb https://downloads.mariadb.com/MariaDB/mariadb-$MARIA_VER/repo/$LSBI $LSBC main" >>prov.list
grep -qw mongodb /tmp/prov && echo "deb https://repo.mongodb.org/apt/$LSBI $LSBC/mongodb-org/$MONGO_VER main" >>prov.list
grep -qw nginx /tmp/prov && echo "deb https://packages.sury.org/nginx $LSBC main" >>prov.list
grep -qw node /tmp/prov && wget -nc -qO /tmp/node.v https://deb.nodesource.com/setup_current.x && echo "deb https://deb.nodesource.com/$(grep ^NODEREPO= /tmp/node.v | cut -d= -f2 | tr -d '"') $LSBC main" >>prov.list
grep -qw php /tmp/prov && echo "deb https://packages.sury.org/php $LSBC main" >>prov.list
grep -qw postgres /tmp/prov && echo "deb https://apt.postgresql.org/pub/repos/apt $LSBC-pgdg main" >>prov.list
grep -qw webmin /tmp/prov && echo 'deb https://download.webmin.com/download/repository sarge contrib' >>prov.list
cd "$VUD" || exit

cd /etc/apt/trusted.gpg.d || exit
grep -qw apache /tmp/prov && wget -nc -qO prov-apache.gpg https://packages.sury.org/apache2/apt.gpg
grep -qw couchdb /tmp/prov && wget -nc -qO prov-couchdb.asc https://couchdb.apache.org/repo/keys.asc
grep -qw docker /tmp/prov && wget -nc -qO prov-docker.asc "https://download.docker.com/linux/$LSBI/gpg"
grep -qw git /tmp/prov && wget -nc -qO prov-git-lfs.asc https://packagecloud.io/github/git-lfs/gpgkey
grep -qw github /tmp/prov && wget -nc -qO prov-github.asc 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC99B11DEB97541F0'
grep -qw mariadb /tmp/prov && wget -nc -qO prov-mariadb.asc 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xF1656F24C74CD1D8'
grep -qw mongodb /tmp/prov && wget -nc -qO prov-mongodb.asc "https://www.mongodb.org/static/pgp/server-$MONGO_VER.asc"
grep -qw nginx /tmp/prov && wget -nc -qO prov-nginx.gpg https://packages.sury.org/nginx/apt.gpg
grep -qw node /tmp/prov && wget -nc -qO prov-node.asc https://deb.nodesource.com/gpgkey/nodesource.gpg.key
grep -qw php /tmp/prov && wget -nc -qO prov-php.gpg https://packages.sury.org/php/apt.gpg
grep -qw postgres /tmp/prov && wget -nc -qO prov-postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
grep -qw webmin /tmp/prov && wget -nc -qO prov-webmin.asc http://www.webmin.com/jcameron-key.asc
apt-get -qq update
cd "$VUD" || exit

cat <<_ >/tmp/prov-apt
curl
gettext
graphviz
imagemagick
python3
ssl-cert
unzip
vim
zip
$(grep -q "$LOGIN_SHELL" /etc/shells || echo "$LOGIN_SHELL" | rev | cut -d/ -f1 | rev)
_
grep -qw apache /tmp/prov && cat <<_ >>/tmp/prov-apt
apache2
libapache2-mod-fcgid
_
grep -qw couchdb /tmp/prov && cat <<_ >>/tmp/prov-apt
$(apt-cache search '^couch-libmozjs[0-9]*-[^a-z]*$' | grep -o '^couch[^ ]*')
couchdb
_
grep -qw docker /tmp/prov && cat <<_ >>/tmp/prov-apt
containerd.io
docker-ce
docker-ce-cli
_
grep -qw git /tmp/prov && cat <<_ >>/tmp/prov-apt
git
git-lfs
_
grep -qw github /tmp/prov && echo 'gh' >>/tmp/prov-apt
grep -qw go /tmp/prov && echo 'golang-go' >>/tmp/prov-apt
grep -qw hg /tmp/prov && echo 'mercurial' >>/tmp/prov-apt
grep -qw hugo /tmp/prov && echo 'hugo' >>/tmp/prov-apt
grep -qw mailhog /tmp/prov && echo 'postfix' >>/tmp/prov-apt
grep -qw mariadb /tmp/prov && echo 'mariadb-server' >>/tmp/prov-apt
grep -qw memcached /tmp/prov && echo 'memcached' >>/tmp/prov-apt
grep -qw mongodb /tmp/prov && echo 'mongodb-org-server' >>/tmp/prov-apt
grep -qw nginx /tmp/prov && echo 'nginx' >>/tmp/prov-apt
grep -qw node /tmp/prov && cat <<_ >>/tmp/prov-apt
g++
gcc
make
nodejs
python3
_
grep -qw perl /tmp/prov && cat <<_ >>/tmp/prov-apt
g++
gcc
make
perl
_
grep -qw postgres /tmp/prov && echo 'postgresql' >>/tmp/prov-apt
grep -qw python /tmp/prov && cat <<_ >>/tmp/prov-apt
$(apt-cache search '^python[0-9]*(-distutils|-pip|-setuptools)?$' | grep -o '^python[^ ]*')
build-essential
curl
libbz2-dev
libffi-dev
liblzma-dev
libncurses5-dev
libreadline-dev
libsqlite3-dev
libssl-dev
libxml2-dev
libxmlsec1-dev
llvm
make
tk-dev
xz-utils
zlib1g-dev
_
grep -qw redis /tmp/prov && echo 'redis-server' >>/tmp/prov-apt
grep -qw ruby /tmp/prov && cat <<_ >>/tmp/prov-apt
$(apt-cache search ^libgdbm | grep -m1 -o '^libgdbm[0-9][0-9]*')
autoconf
bison
build-essential
libdb-dev
libffi-dev
libgdbm-dev
libncurses5-dev
libreadline-dev
libssl-dev
libyaml-dev
ruby-full
zlib1g-dev
_
grep -qw rust /tmp/prov && cat <<_ >>/tmp/prov-apt
cargo
rustc
_
grep -qw shell /tmp/prov && echo 'shellcheck' >>/tmp/prov-apt
grep -qw sqlite /tmp/prov && echo 'sqlite3' >>/tmp/prov-apt
grep -qw svn /tmp/prov && echo 'subversion' >>/tmp/prov-apt
grep -qw webmin /tmp/prov && echo 'webmin' >>/tmp/prov-apt
grep -qw xml /tmp/prov && echo 'libxml2-utils' >>/tmp/prov-apt
[ "$(grep -cw -e git -e svn /tmp/prov)" -gt 1 ] && echo 'git-svn' >>/tmp/prov-apt
sort -uo /tmp/prov-apt /tmp/prov-apt

echo 'Installing system packages'
apt-get -qq install --no-install-recommends $(tr "\n" ' ' </tmp/prov-apt) >/dev/null 2>/dev/null
