""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""{{{
" Copyright 2018 (c) Chen Fang
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"
" 1. Redistributions of source code must retain the above copyright notice, this
" list of conditions and the following disclaimer.
"
" 2. Redistributions in binary form must reproduce the above copyright notice,
" this list of conditions and the following disclaimer in the documentation
" and/or other materials provided with the distribution.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
" FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
" OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
" OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}

" => General Options "{{{
" set color and theme
set termguicolors
set background=dark
colorscheme solarized8_flat

" 字体
if has('gui_running')
    set macligatures
    if has('linux')
        set guifont=Droid\ Sans\ Mono\ 12
    else
        set guifont=Droid\ Sans\ Mono:h12
    endif
    if has('gui_win32')         " why this only work on win32 gui
        language en             " always English
        language messages en
    endif
    " remove left and right scrollbars
    set guioptions-=rl
else
    " fix paste without gui, like ssh + vim
    "set paste => cause inoremap stop working
    set pastetoggle=<F12>
endif

" 显示行号
set number

" 不备份文件
set nobackup
set nowritebackup

" 上下移动时，留1行
set scrolloff=1

" Don't ask me to save file before switching buffers
set hidden

" 高亮当前行
set cursorline
set nocursorcolumn

" 语法高亮
syntax enable
"set regexpengine=1  " force old regex engine, solve slow problem

" 使用非兼容模式
set nocompatible

" 一直启动鼠标
set mouse=a

" show command on the bottom of the screen
set showcmd

" set backspace behavior
set backspace=indent,eol,start

" no bracket match
set noshowmatch
" }}}

" {{{ => Search:
" 有关搜索的选项
set hlsearch
set incsearch
set smartcase
au InsertEnter * set noic
au InsertLeave * set ic
" }}}

" {{{ => File Format
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
set cindent
" 文本宽, 有些过时了
set textwidth&
" 用Tab和Space组合填充Tab => 比较邪恶
set softtabstop&

"set cinwords=if,else,while,do,for,switch
"set cinkeys=0{,0},0(,0),0[,0],:,;,0#,~^F,o,O,0=if,e,0=switch,0=case,0=break,0=whilea,0=for,0=do
"set cinoptions=>s,e0,n0,f0,{0,}0,^0,Ls,:s,=s,l1,b1,g0,hs,N-s,E-s,ps,t0,is,+-s,t0,cs,C0,/0,(0,us,U0,w0,W0,k0,m1,M0,#0,P0

" 文件编码
set fileencoding=utf-8
set fileencodings=utf-8,gb18030,gbk,latin1

" 文件类型
set fileformat=unix
set fileformats=unix,dos

" Fold: 自动打开，但不自动关闭
"  => 所以'zc'就没意义了，重新绑定到'zM'
nnoremap zc zM
nnoremap zC zM
nnoremap zo zR
set foldenable
set foldopen=all
set foldmethod=syntax
set foldlevel=0
set foldnestmax=2

augroup FILES
    au!
    "set autochdir => may cause problem to some plugins
    au BufEnter     * silent! lcd %:p:h " alternative for autochdir
    " 自动跳转到上一次打开的位置
    au BufReadPost  * silent! call <SID>jump_to_las_pos()
    " set extra properties for interest files
    au FileType vim setlocal foldmethod=marker
    au FileType markdown,yaml setlocal ts=2 sw=2
    au FileType python setlocal expandtab&
augroup END

function! s:jump_to_las_pos()
    if line("'\"") > 0 && line ("'\"") <= line('$') && &filetype !~# 'commit'
        exe "normal! g'\""
    endif
endfunction
"}}}

" {{{ => Plugins

" {{{ => completeopt
"set completeopt=menu,longest
set complete=],.,i,d,b,u,w " :h 'complete'
" }}}

" {{{ => bufexplorer
" NOTHING HERE
" }}}

" {{{ => NERDTree
"autocmd VimEnter * NERDTree
"autocmd VimEnter * NERDTree | wincmd p
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
"  => 很好的解决在错误窗口打开bufexplorer的问题
autocmd BufEnter * if winnr() == winnr('h') && bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
            \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
" }}}

" {{{ => tagbar
" use on fly tags
let g:tagbar_autofocus = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_compact = 1
" 避免在Tagbar中打开新的buffer
autocmd BufEnter * if winnr() == winnr('l') && bufname('#') =~ '__Tagbar__\.\d\+' && bufname('%') !~ '__Tagbar__\.\d\+' && winnr('$') > 1 |
            \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
" }}}

" {{{ => vim-racer
let g:racer_experimental_completer = 1
" }}}

" {{{ => echodoc
let g:echodoc#enable_at_startup = 1
if g:echodoc#enable_at_startup
    if has('nvim')
        let g:echodoc#type = 'floating'
        let g:echodoc#floating_config = {'border': 'single', 'title': ' echodoc ', 'title_pos' : 'center'}
    else
        let g:echodoc#type = 'popup'
    endif
    highlight link EchoDocFloat Pmenu
endif
" }}}

" {{{ => signify
let g:signify_disable_by_default = 0
let g:signify_number_highlight = 1
" }}}

" {{{ => ALE
"  => ALE可以替换deoplete, vim-go, echodoc
let g:ale_enabled = 1
if g:ale_enabled
    " => prefer deoplete
    let g:ale_completion_enabled = 0
    if g:ale_completion_enabled
        let g:ale_completion_autoimport = 1
        set omnifunc=ale#completion#OmniFunc " 支持手动补全
        set paste& " ALE complete won't work with paste
    endif

    let g:ale_floating_preview = 1

    " BUG: 只对部分文件有效
    let g:ale_lint_on_text_changed = 'never'
    let g:ale_cursor_detail = 1

    " 显式指定linter和fixer，防止意外情况出现
    "  => 通常情况均为一个，防止竞争的情况出现
    let g:ale_linters_explicit = 1
    let g:ale_linters = {
                \ 'sh'          : ['shellcheck'],
                \ 'c'           : ['cc'],
                \ 'cpp'         : ['cc'],
                \ 'vim'         : ['vimls'],
                \ 'go'          : ['gopls'],
                \ 'rust'        : ['cargo', 'rustc'],
                \ 'cmake'       : ['cmakelint'],
                \ 'dockerfile'  : ['hadolint'],
                \ 'html'        : ['htmlhint'],
                \ 'java'        : ['javac'],
                \ 'javascript'  : ['eslint'],
                \ 'json'        : ['jsonlint'],
                \ 'markdown'    : ['markdownlint'],
                \ 'yaml'        : ['yamllint'],
                \ 'python'      : ['pylint'],
                \ }

    "let g:ale_dockerfile_hadolint_options = '--ignore DL3059'
    "let g:ale_html_htmlhint_options = '--rules error/attr-value-double-quotes=false'
    let g:ale_markdown_markdownlint_executable = 'markdownlint-cli2'
    let g:ale_yaml_yamllint_options = '-d relaxed'
    "let g:ale_python_pylint_options = '--errors-only'
    let g:ale_python_pylint_options = '--ignore-docstrings'

    let g:ale_fix_on_save=1
    let g:ale_fixers = {
                \ '*'           : ['remove_trailing_lines', 'trim_whitespace'],
                \ 'sh'          : ['shfmt'],
                \ 'c'           : ['clang-format'],
                \ 'cpp'         : ['clang-format'],
                \ 'go'          : ['goimports', 'gopls'],
                \ 'rust'        : ['rustfmt'],
                \ 'cmake'       : ['cmakeformat'],
                \ 'html'        : ['tidy'],
                \ 'java'        : ['clang-format'],
                \ 'javascript'  : ['clang-format'],
                \ 'json'        : ['clang-format'],
                \ 'yaml'        : ['yamlfix'],
                \ 'python'      : ['autopep8'],
                \ }
                "\ 'dockerfile'  : ['dprint'],

    let g:ale_c_clangformat_options = '-style="{ BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4 }"'
    let g:ale_sh_shfmt_options = '--indent=4 --case-indent --keep-padding'
    let g:ale_rust_rustfmt_options = '--force --write-mode replace'
    let g:ale_cmake_cmakeformat_executable = 'cmake-format'
    let g:ale_cmake_cmakeformat_options = ''
    let g:ale_yaml_yamlfix_options = ''
    " tidy options is hardcoded

    " 防止界面跳动
    let g:ale_sign_column_always = 1
    let g:ale_sign_highlight_linenrs = 1
    let g:ale_set_highlights = 1
endif
" }}}

" {{{ => vim-go
" vim-go 的补全差点意思，其他还好
if g:ale_enabled
    let g:go_code_completion_enabled = 0
else
    let g:go_code_completion_enabled = 1
endif
set autowrite   " auto save file before run or build
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1

" BUG: first doc windows determine the size
let g:go_doc_max_height = 10
let g:go_def_reuse_buffer = 1   " BUG: not working
" }}}

" {{{ => deoplete
" 只开启一个自动补全插件 => 目录来看deoplete的补全功能更强一些
if exists('g:ale_completion_enabled') && g:ale_completion_enabled
    let g:deoplete#enable_at_startup = 0
else
    let g:deoplete#enable_at_startup = 1
endif

" 后台自动补全，前台手动显示候选列表
"  => 不仅实现了自动补全，同时还减少的界面打扰
" Tab:
"  1. 开始自动补全
"  2. 选择候选词
"  3. snippet跳转
"  4. 插入Tab
if g:deoplete#enable_at_startup
    " neosnippet: 与deoplete配合
    let g:neosnippet#enable_snipmate_compatibility = 1

    " 补全时有个preview窗口 => 导致界面总是变动
    set completeopt-=preview
    " 不兼容paste
    set paste&

    " 为每个语言定义completion source
    if g:ale_enabled
        " insert longest match word
        set completeopt+=longest
        au FileType vim setlocal completeopt-=longest
        "  => 'buffer'和'longest'冲突，补全时会删除光标前面的字符(vim only?)
        "   => 但是不开启'buffer'，则普通文本无法补全，比如注释
        "    => 如果不使用'longest'，则每次都会填充第一个候选词，很麻烦
        "     => map Backspace, 如果不是需要的候选词，则用BS删除已经填充的部分

        " ALE as completion source for deoplete
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['ale', 'buffer', 'neosnippet', 'file'],
                    \ })
        " 异步自动补全，候选框抖动, 干扰界面, 改成手动模式
        call deoplete#custom#option({
                    \ 'auto_complete_popup' : 'manual',
                    \ 'num_processes'       : 4,
                    \ 'refresh_always'      : v:false,
                    \ 'refresh_backspace'   : v:false,
                    \ 'prev_completion_mode': 'length',
                    \ })
    else
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['tag', 'buffer', 'neosnippet', 'file'],
                    \   'cpp'   : ['LanguageClient'],
                    \   'c'     : ['LanguageClient'],
                    \   'vim'   : ['vim'],
                    \ })
    endif

    "call deoplete#custom#option(
    "            \ 'sources', {
    "            \   'sh'    : [''],
    "            \ })

    " complete with vim-go => 手动模式omni不工作，为什么？
    if g:go_code_completion_enabled
        call deoplete#custom#option('omni_patterns', { 'go' : '[^. *\t]\.\w*' })
    endif

    call deoplete#custom#source('_', 'smart_case', v:true)
    " complete cross filetype
    call deoplete#custom#var('buffer', 'require_same_filetype', v:false)

    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1] =~# '\s'
    endfunction
    function! s:check_snippet_jump() abort
        return neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)" : "\<Tab>"
    endfunction

    " Tab: 开始补全，选择候选词，snippets, Tab
    inoremap <expr><Tab>
                \ pumvisible() ? "\<C-N>" :
                \ <SID>check_back_space() ? <SID>check_snippet_jump() :
                \ deoplete#can_complete() ? deoplete#complete() : <SID>check_snippet_jump()

    " Enter: 选取候选词 + snippets
    inoremap <expr><Enter>
                \ neosnippet#expandable() ? "\<Plug>(neosnippet_expand)" :
                \ pumvisible() ? "\<C-Y>" : "\<Enter>"
endif
" }}}

" }}}

" {{{ => Key maps
" 非必要不加<silent>，这样我们可以很好的看到具体执行的命令
" 设置mapleader
let mapleader = ';'
let g:mapleader = ';'

" 已经有定义的按键:
"  - `w`, `b`   : word forward or backward
"  - `e`,       : word forward end
"  - `n`, `N`   : search next or prev
"  - `r`        : replace
"  - `i`, `I`   : insert, insert at line beginning
"  - `a`, `A`   : append, append at line end
"  - `o`, `O`   : new line after or before current line
"  - `y`, `Y`   : yank
"  - `p`, `P`   : paste after or before current cursor
"  ...
"  :h <char> 查看更多 => 最佳实践：使用<leader>
"
" => 注释不要写在map的后面，vim不会处理中间的空格

" 编辑和加载.vimrc/init.vim
nmap <leader>se :e $MYVIMRC<CR>
nmap <leader>ss :source $MYVIMRC<CR>

" 特殊按键
" Space: 只选取候选词，区别于Enter，这样可以避免snippets
inoremap <expr><Space>  pumvisible() ? "\<C-Y>\<Space>" : "\<Space>"
" Backspace: 删除已经填充的部分
inoremap <expr><BS>     pumvisible() ? "\<C-E>"         : "\<BS>"
" ESC: 取消已经填充的部分并退出插入模式
inoremap <expr><ESC>    pumvisible() ? "\<C-E>\<ESC>"   : "\<ESC>"
" Arrow Keys: 选择、选取、取消候选词
inoremap <expr><Down>   pumvisible() ? "\<C-N>"         : "\<Down>"
inoremap <expr><Up>     pumvisible() ? "\<C-P>"         : "\<Up>"
inoremap <expr><Left>   pumvisible() ? "\<C-E>"         : "\<Left>"
inoremap <expr><Right>  pumvisible() ? "\<C-Y>"         : "\<Right>"

" 窗口移动
nmap <C-j>      <C-W>j
nmap <C-k>      <C-W>k
nmap <C-h>      <C-W>h
nmap <C-l>      <C-W>l

" Buffer explorer
nmap <C-e>      :ToggleBufExplorer<CR>
nmap <C-n>      :bnext<CR>
nmap <C-p>      :bprev<CR>

" 触发(单手模式）=> 读代码必须
nmap <F8>       :ToggleBufExplorer<CR>
nmap <F9>       :NERDTreeToggle<CR>
nmap <F10>      :TagbarToggle<CR>

" 跳转 - Goto
" Go to first line - `gg`
" Go to last line
nmap gG         G
" Go to begin or end of code block
nmap g[         [{
nmap g]         ]}
" Go to Forward and Backward
nmap gf         <C-F>
nmap gb         <C-B>
" Go to Define and Back(Top of stack)
nmap gd         <C-]>
nmap gt         <C-T>
" Go to Define in split => :h CTRL-W
"  => 先分割窗口，再在新窗口中用`gd`跳转
nmap gD         10<C-W>sgd<C-W>w
nmap gT         <C-W>W<C-W>c
" Go to man or doc
nmap gh         K10<C-W>_<C-W>w
" Go to next error of ale
nmap ge         <Plug>(ale_next_wrap)
" Go to yank and paste
vmap gy         "+y
nmap gp         "+p

" 其他
imap <C-o>      <Plug>(neosnippet_expand_or_jump)
smap <C-o>      <Plug>(neosnippet_expand_or_jump)

" 语言绑定
augroup LANG
    autocmd!
    autocmd FileType go     nmap <buffer>gB     <Plug>(go-build)
    autocmd FileType go     nmap <buffer>gR     <Plug>(go-run)

    " => 由于vim-go使用omnifunc，所以没必要再次设置这些快捷键
    "autocmd FileType go     nmap <buffer>gd     <Plug>(go-def)
    "autocmd FileType go     nmap <buffer>gt     <Plug>(go-def-pop)
    "autocmd FileType go     nmap <buffer>gh     <Plug>(go-doc-split)<C-W>w

    autocmd FileType rust   nmap <buffer>gd     <Plug>(rust-def)
    " non pop in racer
augroup END
" }}}
