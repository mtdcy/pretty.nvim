" Git: gitsigns + lazygit

let g:gitsigns_enabled = 1
let g:lazygit_enabled = 1

" gitsigns{{{
if g:gitsigns_enabled
    luafile <sfile>:h/gitsigns.lua
endif
" }}}

" Lazygit {{{
if g:lazygit_enabled
    " transparency of floating window
    let g:lazygit_floating_window_winblend = 0
    " use plenary.nvim to manage floating window if available
    let g:lazygit_floating_window_use_plenary = LuaExists('plenary.window')
    " customize lazygit popup window border characters
    let g:lazygit_floating_window_border_chars = ['╭','─', '╮', '│', '╯','─', '╰', '│']
    " custom config file first for nvim
    let g:lazygit_use_custom_config_file_path = 1
    let g:lazygit_config_file_path = g:pretty_home . '/lazygit.yml'
    " XXX: close win with esc => https://github.com/jesseduffield/lazygit/discussions/1966
endif
" }}}

if g:lazygit_enabled
    " already lcd to git root
    command! -nargs=0 GitOpen LazyGit
endif
