#!/usr/bin/env bash
set -euo pipefail

# Simple bootstrapper to link the dotfiles in this repo into $HOME.
# The repo is named "configuration", so we do the linking explicitly
# instead of relying on a folder called "dotfiles".

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfile-backups/$(date +%Y%m%d-%H%M%S)"
FILES=(.zshrc .bashrc .vimrc)
TARGETS=("$@")

# Jika tidak ada argumen, pakai daftar default di atas.
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=("${FILES[@]}")
fi

mkdir -p "$BACKUP_DIR"

link_path() {
  local path="$1"

  # Hilangkan trailing slash agar symlink stabil untuk folder.
  path="${path%/}"

  if [[ -z "$path" ]]; then
    echo "Skip (path kosong)"
    return
  fi

  if [[ "$path" = /* ]]; then
    echo "Skip $path (gunakan path relatif terhadap repo, bukan absolut)"
    return
  fi

  local src="$REPO_DIR/$path"
  local dest="$HOME/$path"

  if [[ ! -e "$src" ]]; then
    echo "Skip $path (missing in repo)"
    return
  fi

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "OK   $path (already linked)"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "Move $path -> $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "Link $path -> $src"
}

for path in "${TARGETS[@]}"; do
  link_path "$path"
done

echo
echo "Done. Backups (if any) are in: $BACKUP_DIR"

