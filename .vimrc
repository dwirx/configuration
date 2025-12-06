syntax on
set tabstop=2
set shiftwidth=2
set expandtab
set ai
set number
set hlsearch
set ruler
highlight Comment ctermfg=green

" Prefer system clipboard when available
if has('clipboard')
  set clipboard=unnamedplus
elseif executable('clip.exe')
  let g:clipboard = {
        \ 'name': 'WslClipboard',
        \ 'copy': {
        \   '+': 'clip.exe',
        \   '*': 'clip.exe',
        \ },
        \ 'paste': {
        \   '+': 'powershell.exe -NoProfile -Command "[Console]::Out.Write((Get-Clipboard -Raw).ToString().Replace(\"`r\", \"\"))"',
        \   '*': 'powershell.exe -NoProfile -Command "[Console]::Out.Write((Get-Clipboard -Raw).ToString().Replace(\"`r\", \"\"))"',
        \ },
        \ 'cache_enabled': 0,
        \ }
endif

" Fallback: OSC52 copy over SSH/tmux when clipboard unavailable
if !has('clipboard')
  function! s:Osc52Copy() abort
    " Only try when in SSH/tmux; skip local terminals without support
    if !exists('$SSH_CONNECTION') && !exists('$TMUX')
      return
    endif
    " Only fire on yank/delete operations
    if v:event.operator !=# 'y' && v:event.operator !=# 'd'
      return
    endif
    let l:reg = empty(v:event.regname) ? '"' : v:event.regname
    let l:lines = getreg(l:reg, 1, 1)
    let l:payload = join(l:lines, "\n")
    if empty(l:payload)
      return
    endif
    let l:encoded = system('base64 | tr -d "\n"', l:payload)
    let l:osc = "\e]52;c;" . substitute(l:encoded, '\n', '', 'g') . "\x07"
    if exists('$TMUX')
      let l:osc = "\ePtmux;\e" . l:osc . "\e\\"
    endif
    silent! call writefile([l:osc], '/dev/tty', 'b')
  endfunction
  augroup Osc52Yank
    autocmd!
    autocmd TextYankPost * call s:Osc52Copy()
  augroup END
endif
