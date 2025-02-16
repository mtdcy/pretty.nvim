" pretty.nvim, copyright 2023 (c) Chen Fang, mtdcy.chen@gmail.com

" => Global Settings
let g:pretty_debug          = 0
let g:pretty_verbose        = 0   " 0 - silence
let g:pretty_dark           = 1   " light or drak
let g:pretty_autocomplete   = 1   " 0 - manual complete with Tab
let g:pretty_singleclick    = 0   " mouse single click
let g:pretty_delay          = 200 " in GUI mode, flicker less, shorten this value

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

" debugging
if g:pretty_debug | let g:pretty_cmdlet = ":normal! "
else              | let g:pretty_cmdlet = ":normal! :silent "
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
    "set pastetoggle=<F12>
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

" 有关搜索的选项
set hlsearch
set incsearch

" 大小写
set smartcase
autocmd InsertEnter * set noic
autocmd InsertLeave * set ic

if g:pretty_verbose
    set updatetime=200
else
    set updatetime=1000
endif
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
    " set extra properties for interest files
    au FileType vim         setlocal fdm=marker foldlevel=0
    au FileType yaml        setlocal et ts=2 sw=2
    au FileType make        setlocal expandtab&
    au FileType markdown    setlocal et ts=2 sw=2 foldlevel=99
    " => Markdown插件有点问题，总是不断折叠

    " Python 通过indent折叠总在折叠在函数的第二行
    au BufNewFile,BufRead *.py
                \ setlocal et ts=4 sw=4 fdm=indent

    au BufNewFile,BufRead *.js,*.html,*.css
                \ setlocal et ts=2 sw=2 fdm=syntax

    " 自动跳转到上一次打开的位置
    autocmd BufReadPost *
                \ if line("'\"") >= 1 && line("'\"") <= line("$") && &filetype !~# 'commit'
                \ | exe "normal! g`\""
                \ | endif
augroup END

" trigger `autoread` when files changes on disk
set autoread
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
" notification after file change
autocmd FileChangedShellPost *
            \ echohl WarningMsg |
            \ echo "File changed on disk. Buffer reloaded." |
            \ echohl None
"}}}

" {{{ => NERDTree
"  Bug: VCS will ignore submodule
let g:NERDTreeWinPos = 'left'
let g:NERDTreeNaturalSort = 1
let g:NERDTreeMouseMode = g:pretty_singleclick + 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = [
            \ '\~$', '.DS_Store', '*.pyc',
            \ '.git$', '__pycache__',
            \ '#recycle', '@eaDir'
            \ ]
let g:NERDTreeRespectWildIgnore = 1
let g:NERDTreeWinSize = min([30, winwidth(0) / 4])
let g:NERDTreeMinimalUI = 1
let g:NERDTreeMinimalMenu=1
let g:NERDTreeAutoDeleteBuffer=1 " drop invalid buffer after rename or delete
let g:NERDTreeDirArrowCollapsible=''
let g:NERDTreeDirArrowExpandable=''
"" Netrw: disable for now, test later
let g:NERDTreeHijackNetrw = 0
"" cancel some key mappings: too much mappings won't help user
""  => keep only: Enter, Space, Mouse, F1/?
"let g:NERDTreeMapActivateNode = ''

" 扩展
" => Denite
autocmd FileType denite call Denite()
function! Denite() abort
    nnoremap <silent><buffer><expr> <cr>    denite#do_map('do_action')
    nnoremap <silent><buffer><expr> /       denite#do_map('open_filter_buffer')     " search
    nnoremap <silent><buffer><expr> D       denite#do_map('do_action', 'delete')    " delete
    nnoremap <silent><buffer><expr> q       denite#do_map('quit')                   " quit
endfunction

call denite#custom#source('file/rec', 'matchers',
            \ ['matcher/fuzzy', 'matcher/ignore_globs'])
call denite#custom#filter('matcher/ignore_globs', 'ignore_globs', [
            \ '*~', '*.o', '*.exe', '*.bak',
            \ '.DS_Store', '*.pyc', '*.sw[po]', '*.class',
            \ '.hg/', '.git/', '.bzr/', '.svn/',
            \ ])
" }}}

" {{{ => Tagbar
" use on fly tags
let g:tagbar_singleclick = g:pretty_singleclick
let g:tagbar_position = 'botright vertical'
let g:tagbar_sort = 0
let g:tagbar_left = 0   " right
let g:tagbar_compact = 1
let g:tagbar_autofocus = 0 " if enabled, an empty tagbar opened
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
            \ 'separator'           : { 'left' : "\ue0b0",          'right' : "" },
            \ 'subseparator'        : { 'left' : "",                'right' : "" },
            \ 'tabline'             : { 'left' : [[ 'buffers' ]],   'right' : [] },
            \ 'inactive'            : { 'left' : [[ 'filename' ]],  'right' : [['filetype' ]]},
            \ 'active'              : {
            \   'left'              : [
            \       [ 'mode', 'paste' ],
            \       [ 'gitbranch' ],
            \       [ 'readonly', 'filename', 'modified' ]
            \ ],
            \   'right'             : [
            \       [ 'percent' ],
            \       [ 'datetime'],
            \       [ 'fileformat', 'fileencoding', 'filetype'],
            \       [ 'linter_ok', 'linter_errors', 'linter_warnings', 'linter_infos' ]
            \ ]},
            \ 'component'           : {
            \   'gitbranch'         : '%{GitBranch()}',
            \   'readonly'          : '%{&readonly ? "" : ""}',
            \   'filename'          : '%{RelativeFileName()}',
            \   'datetime'          : '%{strftime("%m-%d %H:%M:%S")}',
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

let g:lightline#bufferline#enable_devicons = 1
let g:lightline#bufferline#unicode_symbols = 1
let g:lightline#bufferline#shorten_path = 1
let g:lightline#bufferline#smart_path = 0 " shorten path stop working if enabled
let g:lightline#bufferline#clickable = 1
let g:lightline.component_raw = {'buffers': 1}
"autocmd User LightlineBufferlinePreClick :echom "== clicked " . bufname('%')
let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#ordinal_number_map = {
            \ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
            \ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹',
            \ }

" 所有模式使用同样长度字符，防止界面抖动
let g:lightline.mode_map = { 'n':'N', 'i':'I', 'R':'R', 'v':'v', 'V':'V', "\<C-v>":'v', 'c':'C', 's':'s', 'S':'S', "\<C-s>":'s', 't':'T' }
function! GitBranch() abort
    let head = trim(system("git branch --show-current 2>/dev/null"))
    if head != ""
        let l:git = fnamemodify(finddir('.git', '.;'), ':p:h:h:t')
        let head = l:git . "  " . head
    endif
    return head
endfunction
function! RelativeFileName() abort
    let l:bufname = bufname()
    if l:bufname =~ 'NERD_tree_\d\+'      | return 'NERDTree'
    elseif l:bufname =~ '__Tagbar__.\d\+' | return 'Tagbar'
    else                                  | return expand('%:~:.')
    endif
endfunction
" }}}

" {{{ => ALE
let g:ale_enabled = 1
if g:ale_enabled
    " You should not turn this setting on if you wish to use ALE as a completion
    let g:ale_completion_enabled = 0
    if g:ale_completion_enabled
        let g:ale_completion_autoimport = 1
        let g:ale_completion_delay = g:pretty_delay / 2
        set completeopt-=preview
        set paste& " ALE complete won't work with paste

        " always set omnifunc here, can be used as source for others or be replaced by others later
        set omnifunc=ale#completion#OmniFunc " => 支持手动补全
    endif

    " 悬浮窗：Hover(函数签名)
    let g:ale_hover_cursor = 0              " to statusline by default
    let g:ale_hover_to_preview = 0          " to preview window
    let g:ale_hover_to_floating_preview = 1 " to floating preview
    let g:ale_floating_preview_popup_opts = 'g:FloatingWindowBottomRight'

    augroup ALEHoverEnhanced
        autocmd!
        " Hover on cursor hold
        "   => hover manually with <C-d>
        "autocmd CursorHold,CursorHoldI * ALEHover
        " Hover after completion
        autocmd User ALECompletePost ALEHover
    augroup END

    " 错误: virtualtext only
    let g:ale_echo_cursor = 0 " no error message to statusline
    let g:ale_set_signs = 0 " no signs which cause window changes
    let g:ale_virtualtext_delay = g:pretty_delay
    let g:ale_virtualtext_cursor = 'all'
    let g:ale_virtualtext_prefix = '%code%: '

    " 错误列表：loclist
    let g:ale_set_loclist = 1           " loclist instead of quickfix
    let g:ale_open_list = 0             " don't open error list
    let g:ale_keep_list_window_open = 0 " close list after error cleared

    " Linters:
    let g:ale_lint_on_text_changed = 1  " Not all linter support this
    let g:ale_lint_on_insert_leave = 0
    let g:ale_lint_on_filetype_changed = 1
    let g:ale_lint_delay = 100

    " 显式指定linter和fixer => 更直观也更容易调试
    " Fixer: 经过一段时间的使用发现fixer并不如预期，有linter就足够了。
    let g:ale_fix_on_save=1
    let g:ale_fixers = {
                \ '*' : ['remove_trailing_lines', 'trim_whitespace'],
                \ 'go' : ['goimports', 'gofmt']
                \ }

    " Linter: 通常情况均为一个，防止竞争的情况出现
    let g:ale_linters_explicit = 1
    let g:ale_linters = {
                \ 'sh'          : ['shellcheck'],
                \ 'vim'         : ['vimls'],
                \ 'python'      : ['jedils'],
                \ 'c'           : ['cc'],
                \ 'cpp'         : ['cc'],
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
                \ }

    " {{{ => linter config
    function! CheckConfig(prefix, target)
        let l:found=findfile(a:target, ".;")
        if l:found != ''
            return a:prefix . found
        endif
        return ''
    endfunction

    " gopls & gofmt
    let g:ale_go_gofmt_options = '-s'

    " vimls: https://github.com/iamcco/vim-language-server
    let g:ale_vim_vimls_executable = g:pretty_home . '/node_modules/.bin/vim-language-server'
    let g:ale_vim_vimls_config = {
                \ 'vim' : {
                \   'isNeovim'      : has('nvim'),
                \   'iskeyword'     : '@,48-57,_,192-255,-#',
                \   'vimruntime'    : $VIMRUNTIME,
                \   'runtimepath'   : '',
                \   'diagnostic' : {
                \     'enable': v:true
                \   },
                \   'indexes' : {
                \     'runtimepath' : v:true,
                \     'gap'         : 100,
                \     'count'       : 3,
                \     'projectRootPatterns' : ['.git', 'autoload', 'plugin']
                \   },
                \   'suggest' : {
                \     'fromVimruntime'  : v:true,
                \     'fromRuntimepath' : v:false
                \   },
                \ }}

    "let g:ale_sh_shellcheck_executable = g:pretty_home . '/node_modules/.bin/shellcheck'
    "let g:ale_dockerfile_hadolint_options = '--ignore DL3059'
    "let g:ale_html_htmlhint_options = '--rules error/attr-value-double-quotes=false'
    let g:ale_markdown_markdownlint_executable = g:pretty_home . '/node_modules/.bin/markdownlint'
    let g:ale_markdown_markdownlint_options = CheckConfig('--config ', '.markdownlint.yaml')
    let g:ale_yaml_yamllint_options = '-d relaxed'

    " autoload/afe/fixers/clangformat.vim can not handle path properly
    "let g:ale_c_clangformat_executable = g:pretty_home . '/node_modules/.bin/clang-format'
    let g:ale_c_clangformat_options = '--verbose --style="{ BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4 }"'
    let g:ale_sh_shfmt_options = '--indent=4 --case-indent --keep-padding'
    let g:ale_rust_rustfmt_options = '--force --write-mode replace'
    "let g:ale_cmake_cmakeformat_executable = 'cmake-format'
    let g:ale_cmake_cmakeformat_options = ''
    let g:ale_yaml_yamlfix_options = ''
    " }}}
endif
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

    " 注意补全source的顺序
    if g:ale_enabled
        " ALE as completion source for deoplete
        "  => buffer will override ale's suggestions.
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
                    \   'zsh'   : ['zsh'],
                    \   'python': ['jedi'],
                    \ })
    endif

    " complete with vim-go => 手动模式omni不工作，为什么？
    "if g:go_code_completion_enabled
    "    call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })
    "endif

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

" 辅助插件
" => echodoc
"let g:echodoc#enable_at_startup = 1
"if g:echodoc#enable_at_startup
"    if has('nvim')
"        " BUG: 'floating' won't show again after complete.
"        let g:echodoc#type = 'virtual'
"    else
"        let g:echodoc#type = 'popup'
"    endif
"    highlight link EchoDocFloat Pmenu
"endif
" }}}

" {{{ => LazyGit
let g:lazygit_floating_window_winblend = 0      " transparency of floating window
let g:lazygit_floating_window_use_plenary = 0   " use plenary.nvim to manage floating window if available
let g:lazygit_use_custom_config_file_path = 1   " custom config file first for nvim
let g:lazygit_config_file_path = g:pretty_home . '/lazygit.yml'
" XXX: close win with esc => https://github.com/jesseduffield/lazygit/discussions/1966

" 显示VCS修改信息
" => signify
let g:signify_disable_by_default = 0
let g:signify_number_highlight = 1
" }}}

" {{{ => Plugins/Misc

" => Rainbow
let g:rainbow_active = 1

" => Commenter
let g:NERDCreateDefaultMappings = 0
let g:NERDDefaultAlign = 'left'

" => Matchtags
let g:vim_matchtag_enable_by_default = 1
let g:vim_matchtag_files = '*.html,*.xml,*.js,*.jsx,*.ts,*.tsx,*.vue,*.svelte,*.jsp,*.php,*.erb'
highlight link matchTag Search
highlight link matchTag MatchParen
highlight link matchTagError Todo
highlight matchTag gui=reverse

" => tabular
" NOTHING HERE
" }}}

" edit/reload .vimrc/init.vim
nnoremap <leader>se :e $MYVIMRC<cr>
nnoremap <leader>ss :source $MYVIMRC<cr>
            \ :call lightline#update()<cr>
            \ :call lightline#bufferline#reload()<cr>

" ???
"highlight! Normal ctermbg=NONE guibg=NONE

" source init files
source <sfile>:h/init/wm.vim
source <sfile>:h/init/tab.vim
source <sfile>:h/init/keymap.vim
