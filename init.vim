" Copyright 2023 (c) Chen Fang, mtdcy.chen@gmail.com
" pretty.nvim: global settings
let g:pretty_verbose = 0    " 0 - silence
let g:pretty_dark = 1       " light or drak
" floating window config - ':h nvim_open_win'
let g:pretty_window = {
            \ 'border'      : 'single',
            \ 'title'       : 'pretty.nvim',
            \ 'title_pos'   : 'center',
            \ 'style'       : 'minimal'
            \ }
let g:pretty_autocomplete = 1   " 0 - manual complete with Tab
let g:pretty_home=fnamemodify($MYVIMRC, ':p:h')

let $PATH = g:pretty_home . '/node_modules/.bin:' . $PATH
let $PATH = g:pretty_home . '/py3env/bin:' . $PATH

" {{{ => General Options
" set color and theme
set termguicolors
if g:pretty_dark
    set background=dark
else
    set background=light
endif
colorscheme solarized8

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

if g:pretty_verbose
    set updatetime=1000
else
    set updatetime=3000
endif
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
    "au BufEnter     * silent! lcd %:p:h " alternative for autochdir
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

" {{{ => bufexplorer
" NOTHING HERE
" }}}

" {{{ => NERDTree
let g:NERDTreeWinPos = 'left'
let g:NERDTreeMinimalUI = 1
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

" {{{ => echodoc
let g:echodoc#enable_at_startup = 1
if g:echodoc#enable_at_startup
    if has('nvim')
        let g:echodoc#type = 'floating'
        let g:echodoc#floating_config = g:pretty_window
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
let g:ale_enabled = 1
if g:ale_enabled
    " always set omnifunc here, can be used as source for others
    "  or be replaced by others later
    set omnifunc=ale#completion#OmniFunc " => 支持手动补全
    let g:ale_completion_enabled = 0     " => prefer deoplete
    if g:ale_completion_enabled
        let g:ale_completion_autoimport = 1
        let g:ale_completion_delay = 500
        set completeopt-=preview
        set paste& " ALE complete won't work with paste

        inoremap <expr><Tab> pumvisible() ? "\<C-N>" : "\<Tab>"
    endif

    " 默认：只显示左侧图标，不显示virtualtext，
    "   => ale对floating window的控制逻辑有点乱，这里只使用virtualtext
    let g:ale_set_signs = 1
    let g:ale_sign_priority = 100
    let g:ale_set_highlights = 1
    let g:ale_sign_highlight_linenrs = 1
    let g:ale_sign_column_always = 1
    let g:ale_virtualtext_delay = 500
    let g:ale_virtualtext_cursor = 'current'
    let g:ale_open_list = 'on_save' " loclist for errors and warnings
    let g:ale_set_loclist = 1
    if g:pretty_verbose
        let g:ale_virtualtext_cursor = 'all'
        let g:ale_open_list = 1
    endif

    " Errors:
    let g:ale_echo_cursor = 0       " error message to statusline
    let g:ale_cursor_detail = 0     " error message to preview window
    let g:ale_floating_preview = 0  " error message to floating preview

    " Hover: 显示光标处函数签名
    let g:ale_hover_cursor = 1      " to statusline by default
    let g:ale_hover_to_preview = 0  " preview window
    let g:ale_hover_to_floating_preview = 0 " to floating preview
    " => 使用语言特定插件的功能更好一些

    " Linters:
    let g:ale_lint_delay = 1000     " see following BUG
    let g:ale_lint_on_enter = 1
    let g:ale_lint_on_save = 1
    let g:ale_lint_on_insert_leave = 1
    " BUG: 'never' never work
    let g:ale_lint_on_text_changed = 'never'
    " 显式指定linter和fixer => 通常情况均为一个，防止竞争的情况出现
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

    function! CheckConfig(prefix, target)
        let l:found=findfile(a:target, ".;")
        if l:found != ''
            return a:prefix . found
        endif
        return ''
    endfunction
    "let g:ale_sh_shellcheck_executable = g:pretty_home . '/node_modules/.bin/shellcheck'
    "let g:ale_vim_vimls_executable = g:pretty_home . '/node_modules/.bin/vim-language-server'
    "let g:ale_html_htmlhint_executable = g:pretty_home . '/node_modules/.bin/htmlhint'
    "let g:ale_markdown_markdownlint_executable = g:pretty_home . '/node_modules/.bin/markdownlint'
    "let g:ale_dockerfile_hadolint_options = '--ignore DL3059'
    "let g:ale_html_htmlhint_options = '--rules error/attr-value-double-quotes=false'
    let g:ale_markdown_markdownlint_options = CheckConfig('--config ', '.markdownlint.yaml')
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
                \ 'html'        : ['prettier'],
                \ 'java'        : ['clang-format'],
                \ 'javascript'  : ['prettier_eslint'],
                \ 'json'        : ['clang-format'],
                \ 'markdown'    : ['prettier'],
                \ 'yaml'        : ['yamlfix'],
                \ 'python'      : ['autopep8'],
                \ }
                "\ 'dockerfile'  : ['dprint'],

    " autoload/afe/fixers/clangformat.vim can not handle path properly
    "let g:ale_c_clangformat_executable = g:pretty_home . '/node_modules/.bin/clang-format'
    "let g:ale_javascript_prettier_executable = g:pretty_home . '/node_modules/.bin/prettier'
    let g:ale_c_clangformat_options = '--verbose --style="{ BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4 }"'
    let g:ale_sh_shfmt_options = '--indent=4 --case-indent --keep-padding'
    let g:ale_rust_rustfmt_options = '--force --write-mode replace'
    "let g:ale_cmake_cmakeformat_executable = 'cmake-format'
    let g:ale_cmake_cmakeformat_options = ''
    let g:ale_yaml_yamlfix_options = ''

endif
" }}}

" {{{ => vim-go
if g:ale_enabled
    let g:go_code_completion_enabled = 0
else
    let g:go_code_completion_enabled = 1
endif

set autowrite   " auto save file before run or build
let g:go_def_mode = 'gopls'
let g:go_info_mode = 'gopls'
let g:go_fmt_command = 'gopls'
let g:go_imports_mode = 'gopls'
let g:go_fillstruct_mode = 'gopls'
" BUG: not working
let g:go_def_reuse_buffer = 1

" linter and formatter => prefer ale
if !g:ale_enabled
    let g:go_metalinter_autosave = 1
    let g:go_imports_autosave = 1
    let g:go_fmt_autosave = 1
    let g:go_mod_fmt_autosave = 1
endif

" 查看变量和函数信息，这个在读代码时非常有用
let g:go_auto_sameids = 1   " highlight word under cursor
let g:go_auto_type_info = 1 " type info for word under cursor
let g:go_updatetime = 1000  " shorten this value as go code usually omit type
if g:pretty_verbose
    let g:go_updatetime = 500
endif
" => ale hover perform the same actions.

let g:go_doc_keywordprg_enabled = 0     " godoc - ':h K'
" BUG: first doc windows determine the size
let g:go_doc_max_height = 10

" use Terminal for GoRun
" BUG: the height not working
let g:go_term_enabled = 1
let g:go_term_reuse = 1
let g:go_term_height = 20
let g:go_term_close_on_exit = 0
let g:go_term_mode = "split"

let g:go_highlight_types = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_string_spellcheck = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_diagnostic_errors = 1
let g:go_highlight_diagnostic_warnings = 1

let g:go_fold_enable = ['block', 'import', 'varconst', 'package_comment']
" }}}

" {{{ => vim-racer
let g:racer_experimental_completer = 1
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

    set completeopt=menu,noselect,noinsert
    set complete=],.,i,d,b,u,w " :h 'complete'
    set paste&

    if g:ale_enabled
        " ALE as completion source for deoplete
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['ale', 'buffer', 'file', 'neosnippet'],
                    \ })
    else
        " 为每个语言定义completion source
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['buffer', 'file', 'neosnippet'],
                    \   'cpp'   : ['LanguageClient'],
                    \   'c'     : ['LanguageClient'],
                    \   'vim'   : ['vim'],
                    \ })
    endif

    " complete with vim-go => 手动模式omni不工作，为什么？
    if g:go_code_completion_enabled
        set completeopt+=noinsert
        call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })
    endif

    if g:pretty_autocomplete
        " 自动补全时给一个较大的延时
        call deoplete#custom#option({
                    \ 'auto_complete_delay' : 500,
                    \ })
    else
        " 异步自动补全，候选框抖动, 干扰界面, 改成手动模式
        call deoplete#custom#option({
                    \ 'auto_complete_popup' : 'manual',
                    \ 'auto_complete_delay' : 0,
                    \ })
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
                \ deoplete#can_complete() ? deoplete#complete() :
                \ <SID>check_snippet_jump()

    " Enter: 选取候选词 + snippets
    inoremap <expr><Enter>
                \ neosnippet#expandable() ? "\<Plug>(neosnippet_expand)" :
                \ pumvisible() ? "\<C-Y>" : "\<Enter>"
endif
" }}}

" {{{ => lightline
set laststatus=2
set noshowmode  " mode is displayed in the statusline
" 把会跳变的元素放在左边最后一位或右边最前一位
let g:lightline = {
            \ 'colorscheme' : 'solarized',
            \ 'active' : {
            \   'left' : [
            \       [ 'mode', 'paste' ],
            \       [ 'gitbranch', 'readonly', 'filename', 'modified'],
            \   ],
            \   'right' : [
            \       [ 'percent' ],
            \       [ 'fileformat', 'fileencoding', 'filetype'],
            \       [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
            \   ],
            \ },
            \ 'component_expand' : {
            \   'gitbranch'         : 'GitBranch',
            \   'linter_checking'   : 'lightline#ale#checking',
            \   'linter_infos'      : 'lightline#ale#infos',
            \   'linter_warnings'   : 'lightline#ale#warnings',
            \   'linter_errors'     : 'lightline#ale#errors',
            \   'linter_ok'         : 'lightline#ale#ok',
            \ },
            \ 'component_type' : {
            \   'linter_checking'   : 'right',
            \   'linter_infos'      : 'right',
            \   'linter_warnings'   : 'warning',
            \   'linter_errors'     : 'error',
            \   'linter_ok'         : 'right',
            \ }}
" 所有模式使用同样长度字符，防止界面抖动
let g:lightline.mode_map = { 'n':'N', 'i':'I', 'R':'R', 'v':'v', 'V':'V', "\<C-v>":'v', 'c':'C', 's':'s', 'S':'S', "\<C-s>":'s', 't':'T' }
function! GitBranch() abort
    let head = FugitiveHead()
    if head != ""
        let head = "\uf126 " . head
    endif
    return head
endfunction
function! CurrentTag() abort
    return tagbar#currenttag('%s', '', '')
endfunction
" }}}

" {{{ => tabular
" NOTHING HERE
" }}}

" {{{ => vim-markdown
let g:vim_markdown_folding_level = 2
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_no_default_key_mappings = 1
let g:vim_markdown_autowrite = 1 " autowrite when follow link
let g:vim_markdown_new_list_item_indent = 2
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
noremap! <expr><Space>  pumvisible() ? "\<C-Y>\<Space>" : "\<Space>"
" Backspace: 删除已经填充的部分
noremap! <expr><BS>     pumvisible() ? "\<C-E>"         : "\<BS>"
" ESC: 取消已经填充的部分并退出插入模式
noremap! <expr><ESC>    pumvisible() ? "\<C-E>\<ESC>"   : "\<ESC>"
" Arrow Keys: 选择、选取、取消候选词
noremap! <expr><Down>   pumvisible() ? "\<C-N>"         : "\<Down>"
noremap! <expr><Up>     pumvisible() ? "\<C-P>"         : "\<Up>"
noremap! <expr><Left>   pumvisible() ? "\<C-E>"         : "\<Left>"
noremap! <expr><Right>  pumvisible() ? "\<C-Y>"         : "\<Right>"
noremap! <expr><S-Tab>  pumvisible() ? "\<C-E>\<C-D>"   : "\<C-D>"
nnoremap <S-Tab>  <<

" 窗口移动
nmap <C-j>      <C-W>j
nmap <C-k>      <C-W>k
nmap <C-h>      <C-W>h
nmap <C-l>      <C-W>l

" Buffer explorer
"  => must be silent here or flicker happens
nmap <silent> <C-e> :ToggleBufExplorer<CR>
nmap <silent> <C-n> :bnext<CR>
nmap <silent> <C-p> :bprev<CR>

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
nmap gh         <C-T>
" Go to man or doc
nmap gk         K
" Go to Type
" nmap gt
" Go to next error of ale
nmap ge         <Plug>(ale_next_wrap)
" Go to yank and paste
vmap gy         "+y
nmap gp         "+p
" Go to list, FIXME: what about quickfix
nmap gl         :lopen<CR>
" Tabularize
vmap /          :Tabularize /

" 其他
imap <C-o>      <Plug>(neosnippet_expand_or_jump)
smap <C-o>      <Plug>(neosnippet_expand_or_jump)

" 语言绑定
augroup LANG
    autocmd!
    autocmd FileType go         nmap <buffer>gB     <Plug>(go-build)
    autocmd FileType go         nmap <buffer>gR     <Plug>(go-run)

    autocmd FileType go         nmap <buffer>gh     <Plug>(go-def-pop)
    autocmd FileType go         nmap <buffer>gd     <Plug>(go-def)
    autocmd FileType go         nmap <buffer>gt     <Plug>(go-def-type)
    autocmd FileType go         nmap <buffer>gk     <Plug>(go-doc)

    autocmd FileType rust       nmap <buffer>gd     <Plug>(rust-def)

    autocmd FileType markdown   nmap <buffer>gd     <Plug>Markdown_EditUrlUnderCursor
    autocmd FileType markdown   nmap <buffer>gh     :bprev<CR>
    autocmd FileType markdown   nmap <buffer><F10>  :Toc<CR>
augroup END
" }}}
"
