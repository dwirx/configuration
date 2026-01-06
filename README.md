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
   - Otomatis menautkan `.tmux.conf` serta `~/.config/nvim` (atau `~/.config/nvim/init.vim`) jika ditemukan di repo atau di `$HOME`.
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
5) Bisa pakai path absolut di dalam `$HOME` (akan dikonversi ke relatif), misal:
   ```
   ./setup.sh ~/.tmux.conf
   ```
   Jika file belum ada di repo tapi ada di `$HOME`, skrip akan menyalinnya ke repo terlebih dulu lalu membuat symlink.
6) Jika path belum ada baik di repo maupun di `$HOME`, aktifkan opsi `-c/--create-missing` agar skrip membuat folder/berkas kosong di repo lalu menautkannya:
   ```
   ./setup.sh --create-missing .config/nvim
   ```
7) Untuk auto-link semua kandidat di repo (kecuali yang di-skip seperti `README.md`, `setup.sh`, `.git`), jalankan:
   ```
   ./setup.sh --auto
   ```
   Cocok saat ada folder/berkas baru di repo (mis. `.config/arema` atau `./config/arema`); skrip akan menautkannya ke `$HOME/<path>`.
8) Pastikan dependensi yang dirujuk di `.zshrc` terpasang (mis. Oh My Zsh, plugin `zsh-autosuggestions` dan `zsh-syntax-highlighting`, serta `fnm`/`bun` jika dipakai).

