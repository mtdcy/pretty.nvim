" VCS: lazygit + signify

let g:lazygit_enabled = 1
let g:signify_enabled = 1

" Lazygit {{{
if g:lazygit_enabled
    let g:lazygit_floating_window_winblend = 0      " transparency of floating window
    let g:lazygit_floating_window_use_plenary = 0   " use plenary.nvim to manage floating window if available
    let g:lazygit_use_custom_config_file_path = 1   " custom config file first for nvim
    let g:lazygit_config_file_path = g:pretty_home . '/lazygit.yml'
    " XXX: close win with esc => https://github.com/jesseduffield/lazygit/discussions/1966
endif
" }}}

" signify {{{
if g:signify_enabled
    let g:signify_disable_by_default = 0
    let g:signify_number_highlight = 1
endif
" }}} 

if g:lazygit_enabled
    command! -nargs=0 VCS exe 'LazyGit'
endif
