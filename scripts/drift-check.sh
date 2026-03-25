#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check_path() {
  local dst="$1"

  if [[ ! -e "$dst" ]]; then
    echo "[missing] $dst"
    return 1
  fi

  if [[ -L "$dst" ]]; then
    local target
    target="$(readlink "$dst")"
    echo "[link] $dst -> $target"
    return 0
  fi

  echo "[not-link] $dst"
  return 1
}

status=0

while IFS= read -r src; do
  dst="$HOME/${src#"$DOTFILES_DIR/fish/"}"
  if ! check_path "$dst"; then
    status=1
  fi
done < <(find "$DOTFILES_DIR/fish" -type f | sort)

pairs=(
  "$DOTFILES_DIR/tmux/.tmux.conf:$HOME/.tmux.conf"
  "$DOTFILES_DIR/tmux/.tmux/cheatsheet.txt:$HOME/.tmux/cheatsheet.txt"
  "$DOTFILES_DIR/tmux/.tmux/show-help.sh:$HOME/.tmux/show-help.sh"
  "$DOTFILES_DIR/doom/.config/doom/init.el:$HOME/.config/doom/init.el"
  "$DOTFILES_DIR/doom/.config/doom/config.el:$HOME/.config/doom/config.el"
  "$DOTFILES_DIR/doom/.config/doom/packages.el:$HOME/.config/doom/packages.el"
  "$DOTFILES_DIR/doom/.config/doom/KEYS.md:$HOME/.config/doom/KEYS.md"
  "$DOTFILES_DIR/bin/.local/bin/tmx:$HOME/.local/bin/tmx"
)

for pair in "${pairs[@]}"; do
  dst="${pair##*:}"

  if [[ ! -e "$dst" ]]; then
    echo "[missing] $dst"
    status=1
    continue
  fi

  if [[ -L "$dst" ]]; then
    target="$(readlink "$dst")"
    echo "[link] $dst -> $target"
  else
    echo "[not-link] $dst"
    status=1
  fi

done

exit $status
