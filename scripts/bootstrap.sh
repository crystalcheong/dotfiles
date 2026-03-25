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

while IFS= read -r src; do
  rel="${src#"$DOTFILES_DIR/fish/"}"
  backup_if_exists "$HOME/$rel"
  mkdir -p "$HOME/$(dirname "$rel")"
done < <(find "$DOTFILES_DIR/fish" -type f | sort)

backup_if_exists "$HOME/.config/doom/init.el"
backup_if_exists "$HOME/.config/doom/config.el"
backup_if_exists "$HOME/.config/doom/packages.el"
backup_if_exists "$HOME/.config/doom/KEYS.md"
backup_if_exists "$HOME/.local/bin/tmx"

mkdir -p "$HOME/.tmux" "$HOME/.config/doom" "$HOME/.local/bin"

stow --dir "$DOTFILES_DIR" --target "$HOME" --restow tmux fish doom bin

echo "Bootstrap complete. Backup dir: $BACKUP_DIR"
