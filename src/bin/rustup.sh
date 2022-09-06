#!/bin/sh
# shellcheck disable=1090 disable=1091 disable=2034
#
# Install rustup and related packages.
# ------------------------------------------------------------------------------

if grep -qw rust /tmp/prov
  then echo 'Installing rustup'
  export CARGO_HOME="$VUD/.cargo" RUSTUP_HOME="$VUD/.rustup"
  wget -nc -qO /usr/local/bin/rustup-init "https://static.rust-lang.org/rustup/dist/$(uname -m)-$(uname -i)-$(uname -s | tr '[:upper:]' '[:lower:]')-gnu/rustup-init"
  chmod +x /usr/local/bin/rustup-init
  rustup-init -y >/dev/null 2>/dev/null

  echo "$PATH" | grep -q '/\.cargo/' || . "$VUD/.cargo/env"
  grep -q '\.cargo' "$LOGIN_SHELL_CNF" || echo '. ~/.cargo/env' >>"$LOGIN_SHELL_CNF"

  if [ -n "$RUST_VER" ] && ! rustup default | cut -d- -f1 | grep -qw "$RUST_VER"
    then echo "Installing Rust $RUST_VER"
    rustup toolchain install "$RUST_VER" >/dev/null 2>/dev/null
    rustup default "$RUST_VER" >/dev/null 2>/dev/null
  fi
fi
