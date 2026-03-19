" pretty.nvim, copyright 2023 (c) Chen Fang, mtdcy.chen@gmail.com

" => Global Settings
let g:pretty_home           = fnamemodify($MYVIMRC, ':p:h')

let $PATH = g:pretty_home . '/node_modules/.bin:' . $PATH
let $PATH = g:pretty_home . '/py3env/bin:'        . $PATH
let $PATH = g:pretty_home . '/prebuilts/bin:'     . $PATH

" setup python env
let $VIRTUAL_ENV            = g:pretty_home . '/py3env'
let g:python3_host_prog     = $VIRTUAL_ENV . '/bin/python3'

" setup node.js env
let g:node_host_prog        = g:pretty_home . '/node_modules/.bin/neovim-node-host'

" local executables only
function! FindExecutable(cmd)
    if filereadable(g:pretty_home . '/scripts/' . a:cmd)
        return g:pretty_home . '/scripts/' . a:cmd
    elseif filereadable(g:pretty_home . '/py3env/bin/' . a:cmd)
        return g:pretty_home . '/py3env/bin/' . a:cmd
    elseif filereadable(g:pretty_home . '/node_modules/.bin/' . a:cmd)
        return g:pretty_home . '/node_modules/.bin/' . a:cmd
    endif
    if executable(a:cmd)
        return a:cmd
    endif
    return ''
endfunction

" check host and local executables
function! CheckExecutable(cmd, msg) abort
    if executable(a:cmd) == 0
        echom 'Please install ' . a:cmd . ' for ' . a:msg . ' support.'
        return 0
    endif
    return 1
endfunction

if exists('$SSH_CLIENT')
    " only copy back
    let g:clipboard = {
                \   'name': 'RemoteCopy',
                \   'copy': {
                \      '+': g:pretty_home . '/scripts/ncopyc.sh',
                \      '*': g:pretty_home . '/scripts/ncopyc.sh',
                \    },
                \   'paste': { '+': '', '*': '', },
                \   'cache_enabled': 0,
                \ }
endif

if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
    set grepformat=%f:%l:%c:%m
endif

" position floating window to the bottom right => :h nvim_open_win
function! FloatingWindowBottomRight() abort
    return {
                \ 'border'      : ['+', '-', '+', '|', '+', '-', '+', '|'],
                \ 'style'       : 'minimal',
                \ 'relative'    : 'win',
                \ 'anchor'      : 'SE',
                \ 'row'         : winheight(0),
                \ 'col'         : winwidth(0),
                \ 'focusable'   : 1
                \ }
endfunction

" hide cursor for buffer in normal mode
function! HideCursor() abort
    setlocal cursorline

    " init: hide cursor
    set guicursor+=a:Cursor/Cursor
    highlight Cursor blend=100

    augroup HideBufferCursor
        autocmd!
        " hide cursor
        autocmd BufEnter,InsertLeave,CmdlineLeave <buffer>
                    \ highlight Cursor blend=100
                    \ | setlocal guicursor+=a:Cursor/Cursor
        " show cursor
        autocmd BufLeave,InsertEnter,CmdlineEnter <buffer>
                    \ highlight Cursor blend=0
                    \ | setlocal guicursor-=a:Cursor/Cursor
    augroup END
endfunction

" General Options {{{
let mapleader = ';'

" 不备份文件
set nobackup
set nowritebackup

" Don't ask me to save file before switching buffers
set hidden

" 使用非兼容模式
set nocompatible

" show command on the bottom of the screen
set showcmd

" set backspace behavior
set backspace=indent,eol,start

" no bracket match
set noshowmatch

" 有关搜索的选项
set hlsearch
set incsearch

" 大小写
set smartcase

set updatetime=200

" For all
filetype plugin indent on
set autoindent
set smartindent

set cindent
"set cinwords=if,else,while,do,for,switch
"set cinkeys=0{,0},0(,0),0[,0],:,;,0#,~^F,o,O,0=if,e,0=switch,0=case,0=break,0=whilea,0=for,0=do
"set cinoptions=>s,e0,n0,f0,{0,}0,^0,Ls,:s,=s,l1,b1,g0,hs,N-s,E-s,ps,t0,is,+-s,t0,cs,C0,/0,(0,us,U0,w0,W0,k0,m1,M0,#0,P0

" Fold: 默认折叠，手动开关
set foldmethod=manual
set foldlevel=0
set foldnestmax=1
set foldtext=FoldText()
set fillchars+=fold:\       " 隐藏v:folddashes. note: there is a space after \
set foldminlines=3          " don't fold smallest if-else statement
set foldcolumn=1            " conflict with vim-signify

function FoldText()
    let text = getline(v:foldstart)
    let lines = v:foldend - v:foldstart
    return text . ' 󰍻 ' . lines . ' more lines '
endfunction

" trigger `autoread` when files changes on disk
set autoread
augroup reload
    autocmd!
    autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
    " notification after file change
    autocmd FileChangedShellPost *
                \ echohl WarningMsg |
                \ echo "File changed on disk. Buffer reloaded." |
                \ echohl None
augroup END
"}}}


" =============================================================================
" Refresh Commands
" =============================================================================
" {{{

" 需要刷新的操作列表
" 格式：每个 item 是一个函数字符串或命令
let g:refresh_commands = []

" 刷新函数：遍历并执行 refresh_commands 中的命令
function! Refresh() abort
    if empty(g:refresh_commands)
        echom 'ℹ️ No refresh commands configured'
        return
    endif

    for cmd in g:refresh_commands
        try
            " 如果是函数引用，调用函数
            if type(cmd) == v:t_func
                call cmd()
            " 如果是字符串，作为命令执行
            elseif type(cmd) == v:t_string
                execute cmd
            endif
        catch
            echom '⚠️ Refresh error: ' . v:exception
        endtry
    endfor

    echom '✅ Refresh completed'
endfunction
" }}}

" => Check if Lua plugin exists (like exists('*func') for VimScript)
function! LuaExists(plugin) abort
    return luaeval('select(1, pcall(require, _A))', a:plugin)
endfunction

" => Load $HOME/.env files using dotenv.nvim
if filereadable($HOME . '/.env')
    lua require("dotenv").command({fargs = {"' . $HOME . '/.env "}})
endif

" => Load init scripts
source <sfile>:h/init/ui.vim
source <sfile>:h/init/wm.vim
source <sfile>:h/init/cmp.vim
source <sfile>:h/init/ai.vim

"source <sfile>:h/init/finder.vim
luafile <sfile>:h/init/finder.lua

luafile <sfile>:h/init/style.lua

" edit/reload .vimrc/init.vim
nnoremap <leader>se :e $MYVIMRC<cr>
nnoremap <leader>ss :source $MYVIMRC<cr>
            \ :call Refresh()<cr>

" lcd to project root when opening FIRST file {{{
" Use finddir() to find .git directory (no external command needed)
" Only run once per nvim session
let g:auto_lcd_done = v:false

augroup ProjectSettings
    autocmd!
    autocmd BufReadPost,BufNewFile * call s:FindProjectRoot()
augroup END

function! s:FindProjectRoot() abort
    " Only run once per session
    if g:auto_lcd_done | return | endif

    " Skip for no-name buffers (e.g. [No Name])
    if expand('%') == '' | return | endif

    " Skip for remote files (ssh://, http://, etc.)
    if expand('%:p') =~# '^\(ssh\|http\|https\|ftp\)://' | return | endif

    " Use finddir() to find .git directory (Vim built-in, no shell call)
    let l:gitroot = finddir('.git', expand('%:p:h') . ';')
    if l:gitroot !=# ''
        execute 'lcd ' . fnameescape(fnamemodify(l:gitroot, ':h'))
        let g:auto_lcd_done = v:true
    endif
endfunction
" }}}
