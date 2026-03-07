#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "brew not found. Run scripts/install-brew.sh first." >&2
  exit 1
fi

brew update
brew bundle --file "$DOTFILES_DIR/brewfile"
