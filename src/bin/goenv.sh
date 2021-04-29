#!/bin/sh
# shellcheck disable=1090 disable=1091
#
# Install goenv and related packages.
# ------------------------------------------------------------------------------

if grep -qw go /tmp/prov
  then echo 'Installing goenv'
  mkdir -p .goenv
  wget -nc -qO /tmp/goenv.tar.gz https://api.github.com/repos/syndbg/goenv/tarball
  tar -xkf /tmp/goenv.tar.gz -C .goenv --strip-components 1 2>/dev/null

  cat <<_ >.bash_goenv
export GOPATH=$VUD/.go
export GOENV_GOPATH_PREFIX=\$GOPATH
export GOENV_ROOT=$VUD/.goenv
export PATH=\$GOENV_ROOT/bin:\$PATH
eval "\$(goenv init -)"
export PATH=\$GOROOT/bin:\$PATH:\$GOPATH/bin
_

  [ -n "$GOENV_ROOT" ] || . "$VUD/.bash_goenv"
  grep -q '\.bash_goenv' .bash_profile || echo '. ~/.bash_goenv' >>.bash_profile
  grep -q '\.bash_goenv' /root/.bash_profile || echo ". $VUD/.bash_goenv" >>/root/.bash_profile

  if [ -n "$GO_VER" ] && ! goenv global | grep -qw "$GO_VER"
    then echo "Installing Go $GO_VER"
    goenv install "$GO_VER" 2>/dev/null
    goenv global "$GO_VER"
  fi
fi
