#!/usr/bin/env sh
cat "$HOME/.tmux/cheatsheet.txt"
printf '\nPress q to close...\n'
# shellcheck disable=SC2034
IFS= read -r _
