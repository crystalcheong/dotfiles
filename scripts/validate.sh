#!/usr/bin/env bash
set -euo pipefail

checks=(git tmux fish stow emacs tmx devcontainer bun gpg gpgconf eza zoxide fzf fd)
missing=0
for cmd in "${checks[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[ok] $cmd -> $(command -v "$cmd")"
  else
    echo "[missing] $cmd"
    missing=1
  fi
done

doom_cmd=""
if command -v doom >/dev/null 2>&1; then
  doom_cmd="$(command -v doom)"
elif [[ -x "$HOME/.config/emacs/bin/doom" ]]; then
  doom_cmd="$HOME/.config/emacs/bin/doom"
fi

if [[ -n "$doom_cmd" ]]; then
  echo "[ok] doom -> $doom_cmd"
  echo "Running doom doctor..."
  "$doom_cmd" doctor || true
else
  echo "[missing] doom"
  missing=1
fi

if [[ $missing -ne 0 ]]; then
  exit 1
fi
