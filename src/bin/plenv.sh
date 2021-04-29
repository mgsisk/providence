#!/bin/sh
# shellcheck disable=1090 disable=1091
#
# Install plenv and related packages.
# ------------------------------------------------------------------------------

if grep -qw perl /tmp/prov
  then echo 'Installing plenv'
  mkdir -p .plenv
  wget -nc -qO /tmp/plenv.tar.gz https://api.github.com/repos/tokuhirom/plenv/tarball
  tar -xkf /tmp/plenv.tar.gz -C .plenv --strip-components 1 2>/dev/null

  echo 'Installing perl-build'
  mkdir -p .plenv/plugins/perl-build
  wget -nc -qO /tmp/perl-build.tar.gz https://api.github.com/repos/tokuhirom/perl-build/tarball
  tar -xkf /tmp/perl-build.tar.gz -C .plenv/plugins/perl-build --strip-components 1 2>/dev/null

  cat <<_ >.bash_plenv
export PLENV_ROOT=$VUD/.plenv
export PATH=\$PLENV_ROOT/bin:\$PATH
eval "\$(plenv init -)"
_

  [ -n "$PLENV_ROOT" ] || . "$VUD/.bash_plenv"
  grep -q '\.bash_plenv' .bash_profile || echo '. ~/.bash_plenv' >>.bash_profile
  grep -q '\.bash_plenv' /root/.bash_profile || echo ". $VUD/.bash_plenv" >>/root/.bash_profile

  if [ -n "$PERL_VER" ] && ! plenv global | grep -qw "$PERL_VER"
    then echo "Installing Perl $PERL_VER"
    plenv install "$PERL_VER" 2>/dev/null
    plenv global "$PERL_VER"
  fi
fi
