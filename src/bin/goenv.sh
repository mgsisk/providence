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

  cat <<_ >.prov_goenv
export GOPATH=$DUD/.go
export GOENV_GOPATH_PREFIX=\$GOPATH
export GOENV_ROOT=$DUD/.goenv
export PATH=\$GOENV_ROOT/bin:\$PATH
eval "\$(goenv init -)"
export PATH=\$GOROOT/bin:\$PATH:\$GOPATH/bin
_

  [ -n "$GOENV_ROOT" ] || . "$DUD/.prov_goenv"
  grep -q '\.prov_goenv' "$LOGIN_SHELL_CNF" || echo '. ~/.prov_goenv' >>"$LOGIN_SHELL_CNF"
  grep -q '\.prov_goenv' "/root/$LOGIN_SHELL_CNF" || echo ". $DUD/.prov_goenv" >>"/root/$LOGIN_SHELL_CNF"

  if [ -n "$GO_VER" ] && ! goenv global | grep -qw "$GO_VER"
    then echo "Installing Go $GO_VER"
    goenv install "$GO_VER" 2>/dev/null
    goenv global "$GO_VER"
  fi
fi
