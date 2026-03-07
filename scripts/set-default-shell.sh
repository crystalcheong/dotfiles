#!/usr/bin/env bash
set -euo pipefail

if ! command -v fish >/dev/null 2>&1; then
  echo "fish is not installed. Install first." >&2
  exit 1
fi

fish_path="$(command -v fish)"
if ! grep -q "$fish_path" /etc/shells; then
  echo "Adding $fish_path to /etc/shells (sudo required)"
  echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
fi

if [[ "$SHELL" != "$fish_path" ]]; then
  chsh -s "$fish_path"
  echo "Default shell updated to fish. Re-login required."
else
  echo "Default shell already set to fish."
fi
