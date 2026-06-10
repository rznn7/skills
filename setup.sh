#!/bin/bash
set -e

# Install GNU Stow if missing
if ! command -v stow &>/dev/null; then
  echo "GNU Stow is not installed."
  if command -v apt &>/dev/null; then
    sudo apt install -y stow
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y stow
  elif command -v brew &>/dev/null; then
    brew install stow
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm stow
  else
    echo "Could not determine package manager. Please install GNU Stow manually."
    exit 1
  fi
fi

# Run from the repo root, where .stowrc lives (--dir=.. --target=~/.claude/skills)
cd "$(dirname "$0")"
pkg="$(basename "$PWD")"

mkdir -p "$HOME/.claude/skills"

# Back up any pre-existing, non-symlink skill so stow won't refuse to link
for dir in */; do
  name="${dir%/}"
  target_path="$HOME/.claude/skills/$name"
  if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
    echo "Backing up existing $target_path to ${target_path}.bak"
    mv "$target_path" "${target_path}.bak"
  fi
done

# Restow the whole repo as one package; meta files are skipped via .stow-local-ignore
echo "Stowing skills into $HOME/.claude/skills..."
stow -D "$pkg" 2>/dev/null || true
stow "$pkg"

echo "Done!"
