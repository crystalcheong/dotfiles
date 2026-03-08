#!/usr/bin/env bash
set -euo pipefail

if ! command -v fish >/dev/null 2>&1; then
  echo "fish is not installed. Install first." >&2
  exit 1
fi

fish_path="$(command -v fish)"
if ! grep -q "$fish_path" /etc/shells; then
  echo "$fish_path is not listed in /etc/shells." >&2
  echo "Refusing to modify /etc/shells from dotfiles setup." >&2
  echo "Ask an admin to add it first, then rerun this script if you still want chsh." >&2
  exit 1
fi

if [[ "$SHELL" != "$fish_path" ]]; then
  chsh -s "$fish_path"
  echo "Default shell updated to fish. Re-login required."
else
  echo "Default shell already set to fish."
fi
