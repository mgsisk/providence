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

  cat <<_ >.prov_plenv
export PLENV_ROOT=$DUD/.plenv
export PATH=\$PLENV_ROOT/bin:\$PATH
eval "\$(plenv init -)"
_

  [ -n "$PLENV_ROOT" ] || . "$DUD/.prov_plenv"
  grep -q '\.prov_plenv' "$LOGIN_SHELL_CNF" || echo '. ~/.prov_plenv' >>"$LOGIN_SHELL_CNF"
  grep -q '\.prov_plenv' "/root/$LOGIN_SHELL_CNF" || echo ". $DUD/.prov_plenv" >>"/root/$LOGIN_SHELL_CNF"

  if [ -n "$PERL_VER" ] && ! plenv global | grep -qw "$PERL_VER"
    then echo "Installing Perl $PERL_VER"
    plenv install "$PERL_VER" 2>/dev/null
    plenv global "$PERL_VER"
  fi
fi
