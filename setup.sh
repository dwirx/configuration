#!/usr/bin/env bash
set -euo pipefail

# Simple bootstrapper to link the dotfiles in this repo into $HOME.
# The repo is named "configuration", so we do the linking explicitly
# instead of relying on a folder called "dotfiles".

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfile-backups/$(date +%Y%m%d-%H%M%S)"
FILES=(.zshrc .bashrc .vimrc)
# Tambahan otomatis jika ada di repo atau di $HOME.
COMMON_PATHS=(
  .tmux.conf
  .config/nvim
  .config/nvim/init.vim
)

CREATE_MISSING=0
AUTO_DISCOVER=0

usage() {
  cat <<'EOF'
Pemakaian:
  ./setup.sh [opsi] [path ...]

Opsi:
  -c, --create-missing  Buat path yang hilang di repo (folder/file kosong jika perlu)
  -a, --auto            Deteksi otomatis isi repo (link semua kandidat)
  -h, --help            Tampilkan bantuan ini

Contoh:
  ./setup.sh                            # tautan default
  ./setup.sh .config/nvim               # tautkan folder nvim dari repo ke $HOME
  ./setup.sh -c ~/.config/nvim          # jika belum ada di repo, buat/copy ke repo dulu lalu tautkan
  ./setup.sh -a                         # auto-link semua yang ada di repo (kecuali yang di-skip)
EOF
}

# Dedup target path.
declare -A SEEN_TARGET
add_target() {
  local p="$1"
  [[ -z "$p" ]] && return
  # normalisasi trailing slash
  p="${p%/}"
  if [[ -n "${SEEN_TARGET[$p]:-}" ]]; then
    return
  fi
  SEEN_TARGET["$p"]=1
  TARGETS+=("$p")
}

# Temukan kandidat otomatis dari isi repo.
discover_repo_targets() {
  # Skip file/dir tertentu.
  local skip=(
    ".git"
    ".gitignore"
    ".gitattributes"
    ".github"
    ".dotfile-backups"
    "setup.sh"
    "README.md"
    "LICENSE"
  )

  local is_skip
  while IFS= read -r -d '' item; do
    local rel="${item#"$REPO_DIR"/}"
    [[ -z "$rel" ]] && continue

    is_skip=0
    for s in "${skip[@]}"; do
      if [[ "$rel" == "$s" || "$rel" == "$s/"* ]]; then
        is_skip=1
        break
      fi
    done
    [[ $is_skip -eq 1 ]] && continue

    add_target "$rel"
  done < <(find "$REPO_DIR" -mindepth 1 -maxdepth 4 -print0)
}

# Parsing opsi sederhana.
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--create-missing)
      CREATE_MISSING=1
      shift
      ;;
    -a|--auto)
      AUTO_DISCOVER=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    --*)
      echo "Opsi tidak dikenal: $1"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

TARGETS=()
for arg in "$@"; do
  add_target "$arg"
done

# Jika tidak ada argumen, pakai daftar default dan tambahkan path umum yang ditemukan.
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  for p in "${FILES[@]}"; do
    add_target "$p"
  done
  for p in "${COMMON_PATHS[@]}"; do
    if [[ -e "$REPO_DIR/$p" || -e "$HOME/$p" ]]; then
      add_target "$p"
    fi
  done
fi

# Jika mode auto aktif, tambahkan seluruh kandidat dari repo.
if [[ $AUTO_DISCOVER -eq 1 ]]; then
  discover_repo_targets
fi

mkdir -p "$BACKUP_DIR"

link_path() {
  local input="$1"
  local path="$input"

  # Hilangkan trailing slash agar symlink stabil untuk folder.
  path="${path%/}"

  # Jika path absolut di dalam $HOME, ubah jadi relatif dari $HOME.
  if [[ "$path" = "$HOME"* ]]; then
    path="${path#"$HOME"/}"
  fi

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

  # Jika masih belum ada di repo dan opsi create-missing diaktifkan, buat dari nol.
  if [[ ! -e "$src" && $CREATE_MISSING -eq 1 ]]; then
    local last="${path##*/}"
    local dir_hint=0
    # Anggap direktori jika input diakhiri slash atau nama terakhir tanpa tanda titik.
    if [[ "$input" == */ || "$last" != *.* ]]; then
      dir_hint=1
    fi

    mkdir -p "$(dirname "$src")"
    if [[ $dir_hint -eq 1 ]]; then
      mkdir -p "$src"
      echo "Create dir $path di repo (--create-missing)"
    else
      : > "$src"
      echo "Create file $path di repo (--create-missing)"
    fi
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

for path in "${TARGETS[@]}"; do
  link_path "$path"
done

echo
echo "Done. Backups (if any) are in: $BACKUP_DIR"

