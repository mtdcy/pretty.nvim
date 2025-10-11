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
    return '' " no executables in PATH
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

function! HideCursor() abort
    setlocal cursorline
    setlocal termguicolors
    augroup HideCursor
        autocmd!
        " hide cursor
        autocmd BufEnter <buffer>
                    \ highlight Cursor blend=100
                    \ | setlocal guicursor+=a:Cursor/lCursor
        " show cursor
        autocmd BufLeave *
                    \ highlight Cursor blend=0
                    \ | setlocal guicursor-=a:Cursor/lCursor
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

" EditorConfig {{{
" https://neovim.io/doc/user/editorconfig.html
let g:editorconfig = v:true
" => editorconfig applied after ftplugins and FileType autocmds

" editorconfig.end_of_line = lf
set fileformat=unix
set fileformats=unix,dos

" editorconfig.charset = utf-8
set fileencoding=utf-8
set fileencodings=utf-8,gb18030,gbk,latin1

" editorconfig.indent_size = 4
set shiftwidth=4
set softtabstop&
" editorconfig.tab_width = 4
set tabstop=4

" editorconfig.indent_style = space
set expandtab

" editorconfig.max_line_length
set textwidth=0

" disable auto-wrap text using textwidth
set formatoptions-=t
" }}}

" will be override by .editorconfig
augroup EditorConfig
    au!
    " set extra properties for interest files
    au FileType vim                 setlocal fdm=marker
    au FileType make                setlocal expandtab&

    " default yaml folding does not work well => don't fold by default
    au FileType yaml                setlocal et ts=2 sw=2 fdm=indent foldlevel=99

    au FileType markdown            setlocal et ts=2 sw=2 foldlevel=99
    " => Markdown插件有点问题，总是不断折叠

    " Python 通过indent折叠总在折叠在函数的第二行
    au FileType python              setlocal et ts=4 sw=4 fdm=indent
    au FileType html,css            setlocal et ts=2 sw=2 fdm=syntax

    " json: ignore top bracket
    au FileType json,jsonc          setlocal et ts=2 sw=2 foldlevel=1

    " javascript,typescript
    au FileType javascript          setlocal et ts=2 sw=2
    au FileType typescript          setlocal et ts=2 sw=2

    " 自动跳转到上一次打开的位置
    autocmd BufReadPost *
                \ if line("'\"") >= 1 && line("'\"") <= line("$") && &filetype !~# 'commit'
                \ | exe "normal! g`\""
                \ | endif

    " Auto-create parent directories (except for URIs "://").
    autocmd BufWritePre,FileWritePre *
                \ if expand('<afile>') !~# '\(://\)'
                \ | call mkdir(expand('<afile>:p:h'), 'p')
                \ | endif

    " no ignore case when enter insert mode
    autocmd InsertEnter * set noic
    autocmd InsertLeave * set ic
augroup END

" source plugin settings
source <sfile>:h/init/ui.vim
source <sfile>:h/init/explorer.vim
source <sfile>:h/init/taglist.vim
source <sfile>:h/init/completion.vim
source <sfile>:h/init/vcs.vim
source <sfile>:h/init/misc.vim

source <sfile>:h/init/wm.vim
source <sfile>:h/init/menu.vim

" edit/reload .vimrc/init.vim
nnoremap <leader>se :e $MYVIMRC<cr>
nnoremap <leader>ss :source $MYVIMRC<cr>
            \ :call webdevicons#refresh()<cr>
            \ :call lightline#update()<cr>
            \ :call lightline#bufferline#reload()<cr>
