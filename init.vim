" pretty.nvim, copyright 2023 (c) Chen Fang, mtdcy.chen@gmail.com

" => Global Settings
let g:pretty_home           = fnamemodify($MYVIMRC, ':p:h')
let g:pretty_bar_height     = min([15, winheight(0) / 3])
let g:pretty_bar_width      = min([30, winwidth(0) / 5])

let $PATH = g:pretty_home . ':' . $PATH
let $PATH = g:pretty_home . '/node_modules/.bin:' . $PATH
let $PATH = g:pretty_home . '/py3env/bin:'        . $PATH

" setup python env
let $VIRTUAL_ENV            = g:pretty_home . '/py3env'
let g:python3_host_prog     = $VIRTUAL_ENV . '/bin/python3'

" setup node.js env
let g:node_host_prog        = g:pretty_home . '/node_modules/.bin/neovim-node-host'
    
function! FindExecutable(target)
    if filereadable(g:pretty_home . '/py3env/bin/' . a:target)
        return g:pretty_home . '/py3env/bin/' . a:target
    elseif filereadable(g:pretty_home . '/node_modules/.bin/' . a:target)
        return g:pretty_home . '/node_modules/.bin/' . a:target
    endif
    return '' " no executables in PATH
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

" position floating window to the bottom right => :h nvim_open_win
function! FloatingWindowBottomRight() abort
    return {
                \ 'border'      : ['+', '-', '+', '|', '+', '-', '+', '|'],
                \ 'style'       : 'minimal',
                \ 'relative'    : 'win',
                \ 'anchor'      : 'SE',
                \ 'row'         : winheight('.'),
                \ 'col'         : winwidth('.')
                \ }
endfunction

" {{{ => General Options
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
autocmd InsertEnter * set noic
autocmd InsertLeave * set ic

set updatetime=200

" tabstop       - tab宽度
" shiftwidth    - 自动缩进宽度
" expandtab     - 是否展开tab
" softtabstop   - 按下tab时的宽度（用tab和space组合填充）=> 比较邪恶

" For all
filetype plugin indent on

" common settings
set tabstop=4 shiftwidth=4
set expandtab
set autoindent
set smartindent
" 文本宽, 有些过时了
set textwidth=0
set formatoptions-=t
" 用Tab和Space组合填充Tab => 比较邪恶, 经常导致显示错位
set softtabstop&

set cindent
"set cinwords=if,else,while,do,for,switch
"set cinkeys=0{,0},0(,0),0[,0],:,;,0#,~^F,o,O,0=if,e,0=switch,0=case,0=break,0=whilea,0=for,0=do
"set cinoptions=>s,e0,n0,f0,{0,}0,^0,Ls,:s,=s,l1,b1,g0,hs,N-s,E-s,ps,t0,is,+-s,t0,cs,C0,/0,(0,us,U0,w0,W0,k0,m1,M0,#0,P0
"

" 文件类型
set fileformat=unix
set fileformats=unix,dos

" 文件编码
set fileencoding=utf-8
set fileencodings=utf-8,gb18030,gbk,latin1

" Fold: 默认折叠，手动开关
set foldmethod=syntax
set foldlevel=0
set foldnestmax=1
set foldtext=FoldText()
set fillchars+=fold:\       " 隐藏v:folddashes. note: there is a space after \
set foldminlines=3          " don't fold smallest if-else statement
set foldcolumn=1            " conflict with vim-signify

augroup FileTypeSettings
    au!
    " set extra properties for interest files
    au FileType vim                 setlocal fdm=marker
    au FileType make                setlocal expandtab&
    au FileType yaml                setlocal et ts=2 sw=2 fdm=indent
    au FileType markdown            setlocal et ts=2 sw=2 foldlevel=99
    " => Markdown插件有点问题，总是不断折叠

    " Python 通过indent折叠总在折叠在函数的第二行
    au FileType python              setlocal et ts=4 sw=4 fdm=indent
    au FileType html,css            setlocal et ts=2 sw=2 fdm=syntax

    " json: ignore top bracket 
    au FileType json,jsonc          setlocal foldlevel=1

    " javascript,typescript
    au FileType javascript          setlocal et ts=2 sw=2
    au FileType typescript          setlocal et ts=2 sw=2

    " 自动跳转到上一次打开的位置
    autocmd BufReadPost *
                \ if line("'\"") >= 1 && line("'\"") <= line("$") && &filetype !~# 'commit'
                \ | exe "normal! g`\""
                \ | endif
augroup END

function FoldText()
    let text = getline(v:foldstart)
    let lines = v:foldend - v:foldstart
    return text . ' 󰍻 ' . lines . ' more lines '
endfunction

" trigger `autoread` when files changes on disk
set autoread
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
" notification after file change
autocmd FileChangedShellPost *
            \ echohl WarningMsg |
            \ echo "File changed on disk. Buffer reloaded." |
            \ echohl None
"}}}

" source plugin settings
source <sfile>:h/init/ui.vim
source <sfile>:h/init/explorer.vim
source <sfile>:h/init/taglist.vim
source <sfile>:h/init/completion.vim
source <sfile>:h/init/vcs.vim
source <sfile>:h/init/misc.vim

source <sfile>:h/init/wm.vim
source <sfile>:h/init/keymap.vim

" edit/reload .vimrc/init.vim
nnoremap <leader>se :e $MYVIMRC<cr>
nnoremap <leader>ss :source $MYVIMRC<cr>
            \ :call lightline#update()<cr>
            \ :call lightline#bufferline#reload()<cr>
