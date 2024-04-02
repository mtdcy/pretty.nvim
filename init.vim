" pretty.nvim, copyright 2023 (c) Chen Fang, mtdcy.chen@gmail.com

" {{{ => Settings

let g:pretty_verbose      = 0   " 0 - silence
let g:pretty_dark         = 1   " light or drak
let g:pretty_autocomplete = 1   " 0 - manual complete with Tab
let g:pretty_singleclick  = 0   " mouse single click
let g:pretty_delay        = 200 " in GUI mode, flicker less, shorten this value

" {{{ => Advance
let g:pretty_debug        = 0
let g:pretty_home         = fnamemodify($MYVIMRC, ':p:h')
let g:pretty_bar_height   = min([15, winheight(0) / 3])
let g:pretty_bar_width    = min([30, winwidth(0) / 5])

let $PATH = g:pretty_home . ':' . $PATH
let $PATH = g:pretty_home . '/node_modules/.bin:' . $PATH
let $PATH = g:pretty_home . '/py3env/bin:'        . $PATH

let g:python3_host_prog = g:pretty_home . '/py3env/bin/python3'

if exists('$SSH_CLIENT')
    " only copy back
    let g:clipboard = {
                \   'name': 'CopyBack',
                \   'copy': {
                \      '+': 'pretty.rcopy.sh',
                \      '*': 'pretty.rcopy.sh',
                \    },
                \   'paste': { '+': '', '*': '', },
                \   'cache_enabled': 0,
                \ }
endif

" debugging
if g:pretty_debug | let g:pretty_cmdlet = ":normal! "
else              | let g:pretty_cmdlet = ":normal! :silent "
endif

" floating window config - ':h nvim_open_win'
let g:pretty_window = {
            \ 'border'      : 'single',
            \ 'title'       : 'pretty.nvim',
            \ 'title_pos'   : 'center',
            \ 'style'       : 'minimal'
            \ }
" }}}
" }}}

" {{{ => General Options
let mapleader = ';'
" set color and theme
set termguicolors
if g:pretty_dark
    set background=dark
else
    set background=light
endif
colorscheme solarized8
if !has('gui_running')
  set t_Co=256
endif
set guicursor=a:blinkwait5-blinkon5-blinkoff5

" 字体
if has('linux')
    "set guifont=Droid\ Sans\ Mono\ 13
    set guifont=DroidSansM\ Nerd\ Font\ Mono\ 12
else
    "set guifont=Droid\ Sans\ Mono:h13
    set guifont=DroidSansM\ Nerd\ Font\ Mono:h12
endif
if has('gui_running')
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
set nobackup" 1 - leftbar, 2 - headbar, 3 - footbar, 4 - rightbar, 5 - toc(right)
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
" 文本宽, 有些过时了
set textwidth&
" 用Tab和Space组合填充Tab => 比较邪恶, 经常导致显示错位
set softtabstop&

set cindent
"set cinwords=if,else,while,do,for,switch
"set cinkeys=0{,0},0(,0),0[,0],:,;,0#,~^F,o,O,0=if,e,0=switch,0=case,0=break,0=whilea,0=for,0=do
"set cinoptions=>s,e0,n0,f0,{0,}0,^0,Ls,:s,=s,l1,b1,g0,hs,N-s,E-s,ps,t0,is,+-s,t0,cs,C0,/0,(0,us,U0,w0,W0,k0,m1,M0,#0,P0
" 

" Fold: 默认折叠，手动开关
set foldmethod=syntax
set foldlevel=1
set foldnestmax=2
" fold text
set foldtext=FoldText()
set fillchars+=fold:\       " 隐藏v:folddashes. note: there is a space after \
set foldminlines=3          " don't fold smallest if-else statement

" fold column
"set foldcolumn=1            " 显示fold栏，可鼠标开关 => 与git状态有些冲突
"set fillchars+=foldclose:
"set fillchars+=foldopen:
"set fillchars+=foldsep:

function FoldText()
    let text = getline(v:foldstart)
    let lines = v:foldend - v:foldstart
    return text .. " 󰍻 " .. lines .. " more lines "
endfunction

" 文件类型
set fileformat=unix
set fileformats=unix,dos

" 文件编码
set fileencoding=utf-8
set fileencodings=utf-8,gb18030,gbk,latin1

augroup pretty.files
    au!
    " 自动跳转到上一次打开的位置
    au BufReadPost  * silent! call <SID>jump_to_las_pos()
    " set extra properties for interest files
    au FileType vim         setlocal fdm=marker foldlevel=0
    au FileType yaml        setlocal et ts=2 sw=2
    au FileType make        setlocal expandtab&
    au FileType markdown    setlocal et ts=2 sw=2
   
    " Python 通过indent折叠总在折叠在函数的第二行
    au BufNewFile,BufRead *.py
                \ setlocal et ts=4 sw=4 fdm=indent

    au BufNewFile,BufRead *.js,*.html,*.css
                \ setlocal et ts=2 sw=2 fdm=syntax
augroup END

function! s:jump_to_las_pos()
    if line("'\"") > 0 && line ("'\"") <= line('$') && &filetype !~# 'commit'
        exec g:pretty_cmdlet . "g'\""
    endif
endfunction
"}}}

" {{{ => bufexplorer
" NOTHING HERE
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
    let g:ale_completion_enabled = 0
    if g:ale_completion_enabled
        let g:ale_completion_autoimport = 1
        let g:ale_completion_delay = g:pretty_delay / 2
        set completeopt-=preview
        set paste& " ALE complete won't work with paste
        set omnifunc=ale#completion#OmniFunc " => 支持手动补全
    endif

    " 默认：只显示左侧图标，不显示virtualtext，
    "   => ale对floating window的控制逻辑有点乱，这里只使用virtualtext
    let g:ale_set_signs = 1
    let g:ale_sign_priority = 100
    let g:ale_set_highlights = 1
    let g:ale_sign_highlight_linenrs = 1
    let g:ale_sign_column_always = 1
    let g:ale_virtualtext_delay = g:pretty_delay
    let g:ale_virtualtext_cursor = 'current'
    let g:ale_set_loclist = 1
    let g:ale_open_list = 0
    if g:pretty_verbose
        let g:ale_virtualtext_cursor = 'all'
        let g:ale_open_list = 'on_save' " loclist for errors and warnings
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
                \ 'make'        : ['checkmake'],
                \ 'cmake'       : ['cmakelint'],
                \ 'dockerfile'  : ['dprint', 'hadolint'],
                \ 'html'        : ['vscodehtml'],
                \ 'css'         : ['vscodecss'],
                \ 'java'        : ['javac'],
                \ 'javascript'  : ['eslint'],
                \ 'json'        : ['vscodejson', 'jsonlint'],
                \ 'markdown'    : ['markdownlint'],
                \ 'yaml'        : ['yamllint'],
                \ 'python'      : ['jedils', 'pylint'],
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

    " Manually fix with ':ALEFix'
    let g:ale_fix_on_save=0
    " => refer to autoload/ale/fixers
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
                \ 'dockerfile'  : ['dprint'],
                \ }

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
let g:go_updatetime = max([3000, g:pretty_delay * 5]) " shorten this value as go code usually omit type
if g:pretty_verbose
    let g:go_updatetime = g:pretty_delay
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

if g:deoplete#enable_at_startup
    " neosnippet: 与deoplete配合
    let g:neosnippet#enable_snipmate_compatibility = 1

    set completeopt=menu,noselect,noinsert
    " scan only tags and buffers => :h 'complete'
    "  => deep scan by deoplete and ale
    set complete=t,.,b,u,w
    set paste&
    set pumheight=10
    " wish to have 'longest', but deoplete can work with it.

    if g:ale_enabled
        " ALE as completion source for deoplete
        "  => buffer will override ale's suggestions.
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['ale', 'file', 'neosnippet'],
                    \ })
    else
        " 为每个语言定义completion source
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['buffer', 'file', 'neosnippet'],
                    \   'cpp'   : ['LanguageClient'],
                    \   'c'     : ['LanguageClient'],
                    \   'vim'   : ['vim'],
                    \   'zsh'   : ['zsh'],
                    \   'python': ['jedi'],
                    \ })
    endif

    " complete with vim-go => 手动模式omni不工作，为什么？
    if g:go_code_completion_enabled
        call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })
    endif

    if g:pretty_autocomplete
        " 自动补全时给一个较大的延时
        "  => 打字够快，补全就不会干扰
        call deoplete#custom#option({
                    \ 'auto_complete_delay' : g:pretty_delay,
                    \ })
    else
        " 后台自动补全，前台手动显示候选列表
        "  => 不仅实现了自动补全，同时还减少的界面打扰
        call deoplete#custom#option({
                    \ 'auto_complete_popup' : 'manual',
                    \ 'auto_complete_delay' : 0,
                    \ })
    endif

    call deoplete#custom#source('_', 'smart_case', v:true)
    " complete cross filetype
    call deoplete#custom#var('buffer', 'require_same_filetype', v:false)

endif
" }}}

" {{{ => tabular
" NOTHING HERE
" }}}

" {{{ => neo-tree

" }}}

" {{{ => Tagbar
" use on fly tags
let g:tagbar_singleclick = g:pretty_singleclick
let g:tagbar_position = 'botright vertical'
let g:tagbar_sort = 0
let g:tagbar_left = 0   " right
let g:tagbar_compact = 1
let g:tagbar_autofocus = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_show_data_type = 1
let g:tagbar_width = min([30, winwidth(0) / 4])
let g:tagbar_no_status_line = 1
" cancel some key mappings: too much mappings won't help user
"  => keep only: Enter, Space, Mouse, F1/?
let g:tagbar_map_hidenonpublic = ''
let g:tagbar_map_openallfolds = ''
let g:tagbar_map_closeallfolds = ''
let g:tagbar_map_incrementfolds = ''
let g:tagbar_map_decrementfolds = ''
let g:tagbar_map_togglesort = ''
let g:tagbar_map_toggleautoclose = ''
let g:tagbar_map_togglecaseinsensitive = ''
let g:tagbar_map_zoomwin = ''
let g:tagbar_map_close = ''
let g:tagbar_map_preview = ''
let g:tagbar_map_previewwin = ''
let g:tagbar_map_nexttag = ''
let g:tagbar_map_prevtag = ''
let g:tagbar_map_nextfold = ''
let g:tagbar_map_prevfold = ''
let g:tagbar_map_togglefold = ''
let g:tagbar_map_togglepause = ''
" multiple key mapping to these one, can't disable single one
"let g:tagbar_map_openfold = ''
"let g:tagbar_map_closefold = ''
"}}}

" {{{ => lightline
set laststatus=2
set showtabline=2
set noshowmode  " mode is displayed in the statusline
" 把会跳变的元素放在左边最后一位或右边最前一位
let g:lightline = {
            \ 'colorscheme'         : 'one',
            \ 'separator'           : { 'left' : "\ue0b0",          'right' : "\ue0b2" },
            \ 'subseparator'        : { 'left' : "",                'right' : "" },
            \ 'tabline'             : { 'left' : [[ 'buffers' ]],   'right' : [] },
            \ 'inactive'            : { 'left' : [[ 'filename' ]],  'right' : [['filetype' ]]},
            \ 'active'              : {
            \   'left'              : [
            \       [ 'mode', 'paste' ],
            \       [ 'gitbranch', 'readonly' ],
            \       [ 'filename', 'modified' ]
            \ ],
            \   'right'             : [
            \       [ 'percent' ],
            \       [ 'fileformat', 'fileencoding', 'filetype'],
            \       [ 'linter_ok', 'linter_errors', 'linter_warnings', 'linter_infos' ]
            \ ]},
            \ 'component'           : {
            \   'gitbranch'         : '%{&readonly ? "" : GitBranch()}',
            \   'readonly'          : '%{&readonly ? "\ue0a2" : ""}',
            \   'filename'          : '%{RelativeFileName()}',
            \ },
            \ 'component_expand'    : {
            \   'buffers'           : 'lightline#bufferline#buffers',
            \   'linter_ok'         : 'lightline#ale#ok',
            \   'linter_infos'      : 'lightline#ale#infos',
            \   'linter_warnings'   : 'lightline#ale#warnings',
            \   'linter_errors'     : 'lightline#ale#errors',
            \ },
            \ 'component_type'      : {
            \   'buffers'           : 'tabsel',
            \   'linter_ok'         : 'right',
            \   'linter_infos'      : 'right',
            \   'linter_warnings'   : 'warning',
            \   'linter_errors'     : 'error',
            \ }}

let g:lightline#bufferline#shorten_path = 1
let g:lightline#bufferline#smart_path = 0 " shorten path stop working if enabled
let g:lightline#bufferline#clickable = 1
let g:lightline.component_raw = {'buffers': 1}
autocmd User LightlineBufferlinePreClick :echom "== clicked " . bufname('%')
let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#ordinal_number_map = {
            \ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
            \ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹',
            \ }

" 所有模式使用同样长度字符，防止界面抖动
let g:lightline.mode_map = { 'n':'N', 'i':'I', 'R':'R', 'v':'v', 'V':'V', "\<C-v>":'v', 'c':'C', 's':'s', 'S':'S', "\<C-s>":'s', 't':'T' }
function! GitBranch() abort
    let l:git = fnamemodify(finddir('.git', '.;'), ':~:h:t')
    let head = FugitiveHead()
    if head != ""
        let head = l:git . " \uf126 " . head
    endif
    return head
endfunction
function! RelativeFileName() abort
    let l:bufname = bufname()
    if l:bufname =~ 'neo-tree filesystem' | return 'NeoTree'
    elseif l:bufname =~ '__Tagbar__.\d\+' | return 'Tagbar'
    else                                  | return expand('%:~:.')
    endif
endfunction

" have to use <leader>, as Ctrl-numbers are likely unavailable.
nnoremap <leader>1  <Plug>lightline#bufferline#go(1)
nnoremap <leader>2  <Plug>lightline#bufferline#go(2)
nnoremap <leader>3  <Plug>lightline#bufferline#go(3)
nnoremap <leader>4  <Plug>lightline#bufferline#go(4)
nnoremap <leader>5  <Plug>lightline#bufferline#go(5)
nnoremap <leader>6  <Plug>lightline#bufferline#go(6)
nnoremap <leader>7  <Plug>lightline#bufferline#go(7)
nnoremap <leader>8  <Plug>lightline#bufferline#go(8)
nnoremap <leader>9  <Plug>lightline#bufferline#go(9)
nnoremap <leader>0  <Plug>lightline#bufferline#go(10)
" }}}

" {{{ => Markdown:
let g:vim_markdown_no_default_key_mappings=1
let g:vim_markdown_folding_level = 2
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_autowrite = 1 " autowrite when follow link
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_conceal = 1
let g:vim_markdown_conceal_code_blocks = 0
set conceallevel=2
" }}}

" {{{ => Lazygit.nvim:
let g:lazygit_floating_window_winblend = 0      " transparency of floating window
let g:lazygit_floating_window_use_plenary = 0   " use plenary.nvim to manage floating window if available
let g:lazygit_use_custom_config_file_path = 1   " custom config file first for nvim
let g:lazygit_config_file_path = g:pretty_home . '/lazygit.yml'
nnoremap <F12> :LazyGit<cr>
" XXX: close win with esc => https://github.com/jesseduffield/lazygit/discussions/1966
" }}}

" {{{ => vim-matchtags
let g:vim_matchtag_enable_by_default = 1
let g:vim_matchtag_files = '*.html,*.xml,*.js,*.jsx,*.ts,*.tsx,*.vue,*.svelte,*.jsp,*.php,*.erb'

highlight link matchTag Search
highlight link matchTag MatchParen
highlight link matchTagError Todo
highlight matchTag gui=reverse
" }}}

" {{{ => Language Settings
augroup pretty.languages
    autocmd!
    autocmd FileType go         nnoremap <buffer>gB     <Plug>(go-build)
    autocmd FileType go         nnoremap <buffer>gR     <Plug>(go-run)

    autocmd FileType go         nnoremap <buffer>gh     <Plug>(go-def-pop)
    autocmd FileType go         nnoremap <buffer>gd     <Plug>(go-def)
    autocmd FileType go         nnoremap <buffer>gt     <Plug>(go-def-type)
    autocmd FileType go         nnoremap <buffer>gk     <Plug>(go-doc-split)

    autocmd FileType rust       nnoremap <buffer>gd     <Plug>(rust-def)

    autocmd FileType markdown   nnoremap <buffer>gd     <Plug>Markdown_EditUrlUnderCursor
    autocmd FileType markdown   nnoremap <buffer>gh     :bprev<cr>
    autocmd FileType markdown   nnoremap <buffer><F10>  :Toc<cr>
                \ :setlocal nobuflisted nolist nomodifiable<cr>
                \ :TagbarClose<cr>
augroup END
" }}}

" {{{ => Rainbow
let g:rainbow_active = 1
" }}}

" {{{ => NERD Commenter
let g:NERDCreateDefaultMappings = 0
let g:NERDDefaultAlign = 'left'
" 'CTRL-/' => 触发comment
noremap <C-_> <Plug>NERDCommenterToggle
" }}}

" 编辑和加载.vimrc/init.vim
nnoremap <leader>se :e $MYVIMRC<CR>
nnoremap <leader>ss :source $MYVIMRC<CR>
            \ :call lightline#update()<cr>
            \ :call lightline#bufferline#reload()<cr>

highlight! Normal ctermbg=NONE guibg=NONE
