#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_user_scoped_brew() {
  local brew_prefix
  if ! command -v brew >/dev/null 2>&1; then
    echo "brew not found. Install a user-scoped Homebrew under \$HOME first." >&2
    exit 1
  fi

  brew_prefix="$(brew --prefix)"
  case "$brew_prefix" in
    "$HOME"/*) ;;
    *)
      echo "Refusing shared Homebrew prefix: $brew_prefix" >&2
      echo "This dotfiles setup only installs Brew packages into a prefix under \$HOME." >&2
      exit 1
      ;;
  esac
}

if ! command -v brew >/dev/null 2>&1; then
  echo "brew not found. Run scripts/install-brew.sh first." >&2
  exit 1
fi

require_user_scoped_brew

brew update
brew bundle --file "$DOTFILES_DIR/brewfile"
