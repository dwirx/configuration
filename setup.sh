#!/usr/bin/env bash
set -euo pipefail

# Simple bootstrapper to link the dotfiles in this repo into $HOME.
# The repo is named "configuration", so we do the linking explicitly
# instead of relying on a folder called "dotfiles".

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfile-backups/$(date +%Y%m%d-%H%M%S)"
REPO_BACKUP_DIR="$BACKUP_DIR/repo"
FILES=(.zshrc .bashrc .vimrc)
# Tambahan otomatis jika ada di repo atau di $HOME.
COMMON_PATHS=(
  .tmux.conf
  .config/nvim
  .config/nvim/init.vim
)
TARGETS=("$@")
MODE="link"

# Mode sync: salin dari $HOME ke repo agar mudah disimpan / diupload.
if [[ ${#TARGETS[@]} -gt 0 && ( "${TARGETS[0]}" == "--sync" || "${TARGETS[0]}" == "sync" ) ]]; then
  MODE="sync"
  TARGETS=("${TARGETS[@]:1}")
fi

# Jika tidak ada argumen, pakai daftar default dan tambahkan path umum yang ditemukan.
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=("${FILES[@]}")
  for p in "${COMMON_PATHS[@]}"; do
    if [[ -e "$REPO_DIR/$p" || -e "$HOME/$p" ]]; then
      TARGETS+=("$p")
    fi
  done
fi

mkdir -p "$BACKUP_DIR"
mkdir -p "$REPO_BACKUP_DIR"

normalize_path() {
  local path="$1"

  # Hilangkan trailing slash agar symlink stabil untuk folder.
  path="${path%/}"

  # Jika path absolut di dalam $HOME, ubah jadi relatif dari $HOME.
  if [[ "$path" = "$HOME"* ]]; then
    path="${path#"$HOME"/}"
  fi

  echo "$path"
}

link_path() {
  local path
  path="$(normalize_path "$1")"

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

  # Jika file belum ada di repo tapi ada di $HOME, salin dulu ke repo agar ikut ter-versi.
  if [[ ! -e "$src" && -e "$dest" ]]; then
    mkdir -p "$(dirname "$src")"
    cp -a "$dest" "$src"
    echo "Copy $dest -> $src (repo)"
  fi

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

sync_path() {
  local path
  path="$(normalize_path "$1")"

  if [[ -z "$path" ]]; then
    echo "Skip (path kosong)"
    return
  fi

  if [[ "$path" = /* ]]; then
    echo "Skip $path (gunakan path relatif terhadap repo, bukan absolut)"
    return
  fi

  local src_home="$HOME/$path"
  local dest_repo="$REPO_DIR/$path"

  if [[ ! -e "$src_home" ]]; then
    echo "Skip $path (tidak ada di HOME)"
    return
  fi

  if [[ -e "$dest_repo" || -L "$dest_repo" ]]; then
    echo "Move repo $path -> $REPO_BACKUP_DIR/"
    mv "$dest_repo" "$REPO_BACKUP_DIR/"
  fi

  mkdir -p "$(dirname "$dest_repo")"
  cp -a "$src_home" "$dest_repo"
  echo "Sync $path (HOME -> repo)"
}

for path in "${TARGETS[@]}"; do
  if [[ "$MODE" == "sync" ]]; then
    sync_path "$path"
  else
    link_path "$path"
  fi
done

echo
if [[ "$MODE" == "sync" ]]; then
  echo "Done. Repo backups (if any) are in: $REPO_BACKUP_DIR"
else
  echo "Done. Backups (if any) are in: $BACKUP_DIR"
fi

