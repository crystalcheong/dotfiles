#!/usr/bin/env bash
set -euo pipefail

require_user_scoped_brew() {
  local brew_path brew_prefix
  if ! brew_path="$(command -v brew 2>/dev/null)"; then
    return 1
  fi

  brew_prefix="$(brew --prefix)"
  case "$brew_prefix" in
    "$HOME"/*)
      echo "User-scoped Homebrew already installed: $brew_path ($brew_prefix)"
      return 0
      ;;
    *)
      echo "Refusing shared Homebrew prefix: $brew_prefix" >&2
      echo "This dotfiles setup only supports Homebrew installed under \$HOME." >&2
      return 2
      ;;
  esac
}

if command -v brew >/dev/null 2>&1; then
  require_user_scoped_brew
  exit $?
fi

echo "Homebrew is not installed." >&2
echo "Current-user-only mode will not run the official Homebrew installer," >&2
echo "because it targets a shared system prefix on standard macOS installs." >&2
echo "Install a user-scoped Homebrew under \$HOME manually, then rerun setup." >&2
exit 1
