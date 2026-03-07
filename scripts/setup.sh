#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

YES=0
SKIP_SHELL=0
SKIP_DOOM=0
SKIP_VALIDATE=0

print_help() {
  cat <<'EOF'
Usage: ./scripts/setup.sh [options]

Interactive one-click setup for dotfiles:
1) Install Homebrew (if missing)
2) Install tools from brewfile
3) Configure GPG signing pinentry (brew-managed)
4) Ensure devcontainer CLI (brew first, bun fallback)
5) Stow/bootstrap dotfiles into $HOME
6) Install Doom Emacs (if missing) and run doom sync
7) Optionally set fish as login shell
8) Validate installation

Options:
  -h, --help       Show this help and exit
  --yes            Non-interactive mode; accept defaults
  --skip-shell     Do not run set-default-shell.sh
  --skip-doom      Skip Doom install/sync step
  --skip-validate  Skip validate.sh step

Examples:
  ./scripts/setup.sh
  ./scripts/setup.sh --yes --skip-shell
  ./scripts/setup.sh --yes --skip-doom --skip-validate
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    --yes)
      YES=1
      shift
      ;;
    --skip-shell)
      SKIP_SHELL=1
      shift
      ;;
    --skip-doom)
      SKIP_DOOM=1
      shift
      ;;
    --skip-validate)
      SKIP_VALIDATE=1
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Run ./scripts/setup.sh --help for usage." >&2
      exit 2
      ;;
  esac
done

confirm_yes_default() {
  local prompt="$1"
  if [[ $YES -eq 1 ]]; then
    return 0
  fi
  read -r -p "$prompt [Y/n] " reply
  reply="${reply:-Y}"
  [[ "$reply" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]
}

confirm_no_default() {
  local prompt="$1"
  if [[ $YES -eq 1 ]]; then
    return 0
  fi
  read -r -p "$prompt [y/N] " reply
  [[ "$reply" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]
}

run_step() {
  local label="$1"
  shift
  echo
  echo "==> $label"
  "$@"
}

ensure_gpg_signing_tooling() {
  local uname_s pinentry_path conf desired tmp
  uname_s="$(uname -s)"

  if ! command -v gpg >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      echo "gpg missing; installing gnupg via Homebrew..."
      brew install gnupg
    else
      echo "gpg not found and brew unavailable." >&2
      return 1
    fi
  fi

  if ! command -v gpgconf >/dev/null 2>&1; then
    echo "gpgconf not found after gnupg installation." >&2
    return 1
  fi

  pinentry_path=""
  if [[ "$uname_s" == "Darwin" ]]; then
    if command -v pinentry-mac >/dev/null 2>&1; then
      pinentry_path="$(command -v pinentry-mac)"
    elif [[ -x "/opt/homebrew/bin/pinentry-mac" ]]; then
      pinentry_path="/opt/homebrew/bin/pinentry-mac"
    fi

    if [[ -z "$pinentry_path" ]]; then
      if command -v brew >/dev/null 2>&1; then
        echo "pinentry-mac missing; installing via Homebrew..."
        brew install pinentry-mac
      fi
      if command -v pinentry-mac >/dev/null 2>&1; then
        pinentry_path="$(command -v pinentry-mac)"
      elif [[ -x "/opt/homebrew/bin/pinentry-mac" ]]; then
        pinentry_path="/opt/homebrew/bin/pinentry-mac"
      fi
    fi
  else
    if command -v pinentry >/dev/null 2>&1; then
      pinentry_path="$(command -v pinentry)"
    fi
  fi

  if [[ -z "$pinentry_path" ]]; then
    echo "Could not determine pinentry binary path." >&2
    return 1
  fi

  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"
  conf="$HOME/.gnupg/gpg-agent.conf"
  desired="pinentry-program $pinentry_path"

  if [[ -f "$conf" ]] && grep -q '^pinentry-program ' "$conf"; then
    tmp="$(mktemp)"
    awk -v line="$desired" '
      BEGIN { updated = 0 }
      /^pinentry-program / {
        if (!updated) {
          print line
          updated = 1
        }
        next
      }
      { print }
      END {
        if (!updated) print line
      }
    ' "$conf" >"$tmp"
    mv "$tmp" "$conf"
  else
    echo "$desired" >> "$conf"
  fi
  chmod 600 "$conf"

  gpgconf --kill gpg-agent || true
  gpgconf --launch gpg-agent || true

  echo "Configured gpg-agent pinentry: $pinentry_path"
}

ensure_devcontainer_cli() {
  if command -v devcontainer >/dev/null 2>&1; then
    echo "devcontainer already available: $(command -v devcontainer)"
    return 0
  fi

  if command -v brew >/dev/null 2>&1; then
    echo "devcontainer missing; trying Homebrew formula..."
    brew install devcontainer || true
  fi

  if command -v devcontainer >/dev/null 2>&1; then
    echo "devcontainer installed via Homebrew: $(command -v devcontainer)"
    return 0
  fi

  if ! command -v bun >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      echo "bun missing; installing via Homebrew for fallback path..."
      brew install bun || true
    fi
  fi

  if command -v bun >/dev/null 2>&1; then
    echo "Installing @devcontainers/cli via bun (global)..."
    bun add -g @devcontainers/cli
  fi

  if command -v devcontainer >/dev/null 2>&1; then
    echo "devcontainer installed: $(command -v devcontainer)"
    return 0
  fi

  if [[ -x "$HOME/.bun/bin/devcontainer" ]]; then
    echo "devcontainer installed at $HOME/.bun/bin/devcontainer"
    echo "Add ~/.bun/bin to PATH if command is not found in new shells."
    return 0
  fi

  echo "Failed to install devcontainer CLI via Homebrew and bun fallback." >&2
  return 1
}

doom_cmd() {
  if command -v doom >/dev/null 2>&1; then
    command -v doom
  elif [[ -x "$HOME/.config/emacs/bin/doom" ]]; then
    echo "$HOME/.config/emacs/bin/doom"
  fi
}

ensure_doom_repo() {
  if [[ -x "$HOME/.config/emacs/bin/doom" ]]; then
    return 0
  fi

  if [[ -e "$HOME/.config/emacs" && ! -d "$HOME/.config/emacs/.git" ]]; then
    echo "Found existing $HOME/.config/emacs that is not a Doom git repo." >&2
    echo "Move it aside, then rerun setup (or use --skip-doom)." >&2
    return 1
  fi

  echo "Cloning Doom Emacs to $HOME/.config/emacs ..."
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.config/emacs"
}

echo "Dotfiles setup starting from: $DOTFILES_DIR"

if confirm_yes_default "Run Homebrew install check?"; then
  run_step "install-brew.sh" "$SCRIPTS_DIR/install-brew.sh"
else
  echo "Skipping Homebrew install check."
fi

if confirm_yes_default "Install/update tools from brewfile?"; then
  run_step "install-tools.sh" "$SCRIPTS_DIR/install-tools.sh"
else
  echo "Skipping tool installation."
fi

if confirm_yes_default "Configure GPG signing pinentry now?"; then
  run_step "ensure-gpg-signing" ensure_gpg_signing_tooling
else
  echo "Skipping GPG signing setup."
fi

if confirm_yes_default "Ensure devcontainer CLI is available?"; then
  run_step "ensure-devcontainer-cli" ensure_devcontainer_cli
else
  echo "Skipping devcontainer CLI ensure step."
fi

if confirm_yes_default "Bootstrap/stow dotfiles into HOME?"; then
  run_step "bootstrap.sh" "$SCRIPTS_DIR/bootstrap.sh"
else
  echo "Skipping bootstrap."
fi

if [[ $SKIP_DOOM -eq 1 ]]; then
  echo "Skipping Doom step (--skip-doom)."
elif confirm_yes_default "Install/sync Doom Emacs?"; then
  ensure_doom_repo
  doom_bin="$(doom_cmd || true)"
  if [[ -z "${doom_bin:-}" ]]; then
    echo "Doom command not found after setup." >&2
    exit 1
  fi
  run_step "doom install (if first run)" bash -lc "[[ -d \"$HOME/.config/emacs/.local\" ]] || \"$doom_bin\" install"
  run_step "doom sync" "$doom_bin" sync
else
  echo "Skipping Doom step."
fi

if [[ $SKIP_SHELL -eq 1 ]]; then
  echo "Skipping shell switch (--skip-shell)."
elif confirm_no_default "Set fish as default login shell now?"; then
  run_step "set-default-shell.sh" "$SCRIPTS_DIR/set-default-shell.sh"
else
  echo "Skipping default shell change."
fi

if [[ $SKIP_VALIDATE -eq 1 ]]; then
  echo "Skipping validation (--skip-validate)."
elif confirm_yes_default "Run validation checks now?"; then
  run_step "validate.sh" "$SCRIPTS_DIR/validate.sh"
else
  echo "Skipping validation."
fi

echo
echo "Setup complete."
echo "Next:"
echo "  - Reload shell: exec fish"
echo "  - Start tmux: tmx"
echo "  - Open terminal Emacs: e"
