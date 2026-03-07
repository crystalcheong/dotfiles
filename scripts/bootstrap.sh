#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

backup_if_exists() {
  local path="$1"
  if [[ -e "$path" && ! -L "$path" ]]; then
    local rel="${path#"$HOME"/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$path" "$BACKUP_DIR/$rel"
    echo "Backed up: $path -> $BACKUP_DIR/$rel"
  fi
}

backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.tmux/cheatsheet.txt"
backup_if_exists "$HOME/.tmux/show-help.sh"
backup_if_exists "$HOME/.config/fish/config.fish"
backup_if_exists "$HOME/.config/doom/init.el"
backup_if_exists "$HOME/.config/doom/config.el"
backup_if_exists "$HOME/.config/doom/packages.el"
backup_if_exists "$HOME/.config/doom/KEYS.md"
backup_if_exists "$HOME/.local/bin/tmx"

mkdir -p "$HOME/.tmux" "$HOME/.config/fish" "$HOME/.config/doom" "$HOME/.local/bin"

stow --dir "$DOTFILES_DIR" --target "$HOME" --restow tmux fish doom bin

echo "Bootstrap complete. Backup dir: $BACKUP_DIR"
