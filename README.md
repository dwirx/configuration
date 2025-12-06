## Setup dotfiles from this repo

Repo ini bernama `configuration`, jadi gunakan skrip ini untuk menautkan berkas konfigurasi ke `$HOME` tanpa harus memindahkan atau menamai ulang folder.

1) Jalankan:
   ```
   chmod +x setup.sh
   ./setup.sh
   ```
2) Tanpa argumen, skrip akan:
   - Membuat symlink untuk `.zshrc`, `.bashrc`, dan `.vimrc` dari repo ini ke `$HOME`.
   - Memindahkan versi lama (jika ada) ke folder cadangan `~/.dotfile-backups/<timestamp>`.
3) Untuk menambahkan berkas lain (contoh konfigurasi Neovim), cukup jalankan:
   ```
   ./setup.sh .config/nvim/init.vim
   ```
   Pastikan file tersebut sudah ada di repo ini pada path yang sama.
4) Untuk menautkan satu folder penuh (auto backup folder lama), jalankan:
   ```
   ./setup.sh .config/nvim
   ```
   Skrip akan memindahkan folder lama ke backup lalu membuat symlink ke folder di repo.
5) Pastikan dependensi yang dirujuk di `.zshrc` terpasang (mis. Oh My Zsh, plugin `zsh-autosuggestions` dan `zsh-syntax-highlighting`, serta `fnm`/`bun` jika dipakai).

