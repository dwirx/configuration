# Path ke instalasi Oh My Zsh Anda.
export ZSH="$HOME/.oh-my-zsh"

# Tema ZSH. "robbyrussell" adalah default, "agnoster" juga populer.
ZSH_THEME="robbyrussell"

# Daftar plugin yang akan dimuat.
# Plugin kustom (non-bundel) harus di-clone secara manual.
# Skrip ini sudah melakukannya untuk zsh-autosuggestions dan zsh-syntax-highlighting.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  vi-mode
  z
)

# Memuat Oh My Zsh.
source $ZSH/oh-my-zsh.sh

# User configuration
# Contoh alias
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias update='sudo apt update && sudo apt upgrade -y' # Ganti 'apt' jika perlu
# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Key binding untuk vi-mode
bindkey -v
export KEYTIMEOUT=1

# shove: git add, commit with message, confirm before push
shove() {
  git add .
  git commit -m "$*"
  echo -n "Push to origin? (y/n): "
  read confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git push origin
  else
    echo "❌ Push cancelled."
  fi
}

# shovenc: commit tanpa pesan, konfirmasi sebelum push
shovenc() {
  git add .
  git commit --allow-empty-message -m ""
  echo -n "Push to origin? (y/n): "
  read confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git push origin
  else
    echo "❌ Push cancelled."
  fi
}


# fnm
FNM_PATH="/home/hades/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

# bun completions
[ -s "/home/hades/.bun/_bun" ] && source "/home/hades/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

. "$HOME/.local/bin/env"
# Tambahkan Go ke PATH
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# opencode
export PATH=/home/hades/.opencode/bin:$PATH
export PATH="$HOME/bin:$PATH"
