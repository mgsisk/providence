#!/bin/sh
# shellcheck disable=1090 disable=1091
#
# Install pyenv and related packages.
# ------------------------------------------------------------------------------

if grep -qw python /tmp/prov
  then echo 'Installing pyenv'
  mkdir -p .pyenv
  wget -nc -qO /tmp/pyenv.tar.gz https://api.github.com/repos/pyenv/pyenv/tarball
  tar -xkf /tmp/pyenv.tar.gz -C .pyenv --strip-components 1 2>/dev/null

  cat <<_ >.prov_pyenv
export PIPENV_VENV_IN_PROJECT=:
export PYENV_ROOT=$DUD/.pyenv
export PATH=\$PYENV_ROOT/bin:$DUD/.local/bin:\$PATH
eval "\$(pyenv init -)"
_

  [ -n "$PYENV_ROOT" ] || . "$DUD/.prov_pyenv"
  grep -q '\.prov_pyenv' "$LOGIN_SHELL_CNF" || echo '. ~/.prov_pyenv' >>"$LOGIN_SHELL_CNF"
  grep -q '\.prov_pyenv' "/root/$LOGIN_SHELL_CNF" || echo ". $DUD/.prov_pyenv" >>"/root/$LOGIN_SHELL_CNF"

  if [ -n "$PYTHON_VER" ] && ! pyenv global | grep -qw "$PYTHON_VER"
    then echo "Installing Python $PYTHON_VER"
    pyenv install "$PYTHON_VER" 2>/dev/null
    pyenv global "$PYTHON_VER"
  fi

  echo 'Installing pipenv'
  pyenv exec pip install -qq pipenv 2>/dev/null

  if [ -s "$PIPENV_CNF" ]
    then echo 'Installing pipenv packages'
    cd "$(dirname "$PIPENV_CNF")" || exit
    pyenv exec pipenv --bare install --dev >/dev/null 2>/dev/null
    cd "$DUD" || exit
  fi
fi
