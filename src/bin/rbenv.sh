#!/bin/sh
# shellcheck disable=1090 disable=1091
#
# Install rbenv and related packages.
# ------------------------------------------------------------------------------

if grep -qw ruby /tmp/prov
  then echo 'Installing ruby-build'
  mkdir -p .ruby-build .rbenv
  wget -nc -qO /tmp/ruby-build.tar.gz https://api.github.com/repos/rbenv/ruby-build/tarball
  tar -xkf /tmp/ruby-build.tar.gz -C .ruby-build --strip-components 1 2>/dev/null
  .ruby-build/install.sh

  echo 'Installing rbenv'
  wget -nc -qO /tmp/rbenv.tar.gz https://api.github.com/repos/rbenv/rbenv/tarball
  tar -xkf /tmp/rbenv.tar.gz -C .rbenv --strip-components 1 2>/dev/null

  cat <<_ >.prov_rbenv
export RBENV_ROOT=$DUD/.rbenv
export PATH=\$RBENV_ROOT/bin:\$PATH
eval "\$(rbenv init -)"
_

  [ -n "$RBENV_ROOT" ] || . "$DUD/.prov_rbenv"
  grep -q '\.prov_rbenv' "$LOGIN_SHELL_CNF" || echo '. ~/.prov_rbenv' >>"$LOGIN_SHELL_CNF"
  grep -q '\.prov_rbenv' "/root/$LOGIN_SHELL_CNF" || echo ". $DUD/.prov_rbenv" >>"/root/$LOGIN_SHELL_CNF"

  if [ -n "$RUBY_VER" ] && ! rbenv global | grep -qw "$RUBY_VER"
    then echo "Installing Ruby $RUBY_VER"
    rbenv install "$RUBY_VER" 2>/dev/null
    rbenv global "$RUBY_VER"
  fi

  echo 'Installing Bundler'
  rbenv exec gem install -N bundler >/dev/null

  if [ -s "$BUNDLER_CNF" ]
    then echo 'Installing Bundler packages'
    cd "$(dirname "$BUNDLER_CNF")" || exit
    rbenv exec bundle config --global silence_root_warning 1
    rbenv exec bundle install --quiet
    cd "$DUD" || exit
  fi
fi
