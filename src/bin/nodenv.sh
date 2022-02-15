#!/bin/sh
# shellcheck disable=1090 disable=1091
#
# Install nodenv and related packages.
# ------------------------------------------------------------------------------

if grep -qw node /tmp/prov
  then echo 'Installing node-build'
  mkdir -p .node-build .nodenv
  wget -nc -qO /tmp/node-build.tar.gz https://api.github.com/repos/nodenv/node-build/tarball
  tar -xkf /tmp/node-build.tar.gz -C .node-build --strip-components 1 2>/dev/null
  .node-build/install.sh

  echo 'Installing nodenv'
  wget -nc -qO /tmp/nodenv.tar.gz https://api.github.com/repos/nodenv/nodenv/tarball
  tar -xkf /tmp/nodenv.tar.gz -C .nodenv --strip-components 1 2>/dev/null
  cd .nodenv || exit
  src/configure
  make -sC src
  cd "$VUD" || exit

  cat <<_ >.bash_nodenv
export NODENV_ROOT=$VUD/.nodenv
export PATH=\$NODENV_ROOT/bin:\$PATH
eval "\$(nodenv init -)"
_

  [ -n "$NODENV_ROOT" ] || . "$VUD/.bash_nodenv"
  grep -q '\.bash_nodenv' .bash_profile || echo '. ~/.bash_nodenv' >>.bash_profile
  grep -q '\.bash_nodenv' /root/.bash_profile || echo ". $VUD/.bash_nodenv" >>/root/.bash_profile

  if [ -n "$NODE_VER" ] && ! nodenv global | grep -qw "$NODE_VER"
    then echo "Installing Node $NODE_VER"
    nodenv install "$NODE_VER" 2>/dev/null
    nodenv global "$NODE_VER"
  fi

  if [ -s "$NODE_CNF" ]
    then echo 'Installing Node packages'
    nodenv exec npm set loglevel silent 2>/dev/null
    nodenv exec npm set progress false 2>/dev/null

    cd "$(dirname "$NODE_CNF")" || exit
    nodenv exec npm -s install 2>/dev/null
    cd "$VUD" || exit

    nodenv exec npm set progress true 2>/dev/null
    nodenv exec npm set loglevel notice 2>/dev/null
  fi
fi
