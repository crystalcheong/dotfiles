#!/usr/bin/env bash
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
  echo "Homebrew already installed: $(command -v brew)"
  exit 0
fi

uname_s="$(uname -s)"
if [[ "$uname_s" == "Darwin" || "$uname_s" == "Linux" ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Unsupported OS for this script: $uname_s" >&2
  exit 1
fi
