" =============================================================================
" UI 组件 配置文件 - lightline + bufferline + ...
" =============================================================================
" 说明：
"   本文件负责 Neovim 的 UI 配置，包括：
"   1. 主题和颜色配置
"   2. 字体设置
"   3. lightline 状态栏配置
"   4. bufferline 缓冲区标签配置
"   5. 基本 UI 设置
" =============================================================================

let g:lightline_enabled = 1
let g:nerdtree_enabled = 1
let g:tagbar_enabled = 1
let g:lazygit_enabled = 1

" =============================================================================
" 全局选项
" =============================================================================
" {{{

" 暗色模式：1 = 暗色，0 = 亮色
let g:dark_mode = 1

" =============================================================================
" 颜色和主题
" =============================================================================

" 启用真彩色支持（24 位色）
set termguicolors

" 终端颜色数（非 GUI 模式）
if !has('gui_running')
    set t_Co=256
endif

" 根据 dark_mode 设置背景
if g:dark_mode
    set background=dark
else
    set background=light
endif

" 加载 Solarized 主题配置（Lua 配置）
luafile <sfile>:h/solarized.lua

" => Load basic lua plugins
luafile <sfile>:h/markdown.lua

" 光标设置：a=所有模式，blinkwait5=等待 5ms 开始闪烁，blinkon5=亮 5ms，blinkoff5=灭 5ms
set guicursor=a:blinkwait5-blinkon5-blinkoff5

" =============================================================================
" 字体设置
" =============================================================================

" 根据操作系统设置字体
if has('linux')
    " Linux 系统
    "set guifont=Droid\ Sans\ Mono\ 13
    set guifont=DroidSansM\ Nerd\ Font\ Mono\ 12
else
    " Windows/Mac 系统
    "set guifont=Droid\ Sans\ Mono:h13
    set guifont=DroidSansM\ Nerd\ Font\ Mono:h12
endif

" =============================================================================
" GUI 特定设置
" =============================================================================

if has('gui_running')
    " Windows GUI 特定设置
    if has('gui_win32')
        " 为什么只在 Windows GUI 生效？
        language en             " 始终使用英语
        language messages en
    endif

    " 移除左右滚动条
    set guioptions-=rl
else
    " 非 GUI 模式（如 SSH + Vim）
    " 修复粘贴问题
    "set paste => 会导致 inoremap 失效
    "set pastetoggle=<F12>
endif

" =============================================================================
" 基本 UI 设置
" =============================================================================

" 显示行号
set number

" 上下移动时，上下各留 1 行空白
set scrolloff=1

" 高亮当前行
set cursorline

" 不高亮当前列
set nocursorcolumn

" 启用语法高亮
syntax enable

" 强制使用旧版正则引擎（解决某些高亮慢的问题）
"set regexpengine=1

" 始终启用鼠标支持（所有模式）
set mouse=a
" }}}

" =============================================================================
" lightline 状态栏配置
" =============================================================================
" {{{
if g:lightline_enabled
    " 始终显示状态栏（2 = 始终显示）
    set laststatus=2

    " 始终显示标签栏（2 = 始终显示）
    set showtabline=2

    " 不显示模式（模式显示在状态栏中）
    set noshowmode

    " ---------------------------------------------------------------------
    " lightline 配置
    " ---------------------------------------------------------------------
    let g:lightline = {
                \ 'colorscheme'         : 'one',
                \ 'separator'           : { 'left' : "\ue0b0",          'right' : '' },
                \ 'subseparator'        : { 'left' : '',                'right' : '' },
                \ 'tabline'             : { 'left' : [[ 'buffers' ]],   'right' : [] },
                \ 'inactive'            : { 'left' : [[ 'filename' ]],  'right' : [] },
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
                \       [ 'linter_ok', 'linter_errors', 'linter_warnings' ]
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
                \ },
                \ 'component_raw'       : {
                \   'buffers'           : 1,
                \ }}

    " ---------------------------------------------------------------------
    " bufferline 配置
    " ---------------------------------------------------------------------

    " 启用 DevIcons 文件类型图标
    let g:lightline#bufferline#enable_devicons = 1

    " 启用 Unicode 符号
    let g:lightline#bufferline#unicode_symbols = 1

    " 不缩短路径（缩短后不可读）
    let g:lightline#bufferline#shorten_path = 0

    " 智能路径（启用后缩短路径会失效）
    let g:lightline#bufferline#smart_path = 1

    " 启用点击切换缓冲区
    let g:lightline#bufferline#clickable = 1

    " 点击缓冲区前的日志（调试用）
    "autocmd User LightlineBufferlinePreClick :echom "== clicked " . bufname('%')

    " 显示缓冲区编号：0=不显示，1=总是显示，2=有重复文件名时显示
    let g:lightline#bufferline#show_number = 2

    " 缓冲区编号的 Unicode 下标映射（0-9）
    let g:lightline#bufferline#ordinal_number_map = {
                \ 0: '₀', 1: '₁', 2: '₂', 3: '₃', 4: '₄',
                \ 5: '₅', 6: '₆', 7: '₇', 8: '₈', 9: '₉',
                \ }

    " ---------------------------------------------------------------------
    " ALE Linter 指示器图标
    " ---------------------------------------------------------------------

    " 检查中： (U+F110)
    let g:lightline#ale#indicator_checking = "\uf110 "

    " 信息： (U+F129)
    let g:lightline#ale#indicator_infos = "\uf129 "

    " 警告：⚠ (U+F071)
    let g:lightline#ale#indicator_warnings = "\uf071 "

    " 错误： (U+F05E)
    let g:lightline#ale#indicator_errors = "\uf05e "

    " 通过：✓ (U+F00C)
    let g:lightline#ale#indicator_ok = "\uf00c"

    " ---------------------------------------------------------------------
    " 模式映射（所有模式使用同样长度字符，防止界面抖动）
    " ---------------------------------------------------------------------
    let g:lightline.mode_map = {
                \ 'n'      : 'N',
                \ 'i'      : 'I',
                \ 'R'      : 'R',
                \ 'v'      : 'v',
                \ 'V'      : 'V',
                \ "\<C-v>" : 'v',
                \ 'c'      : 'C',
                \ 's'      : 's',
                \ 'S'      : 'S',
                \ "\<C-s>" : 's',
                \ 't'      : 'T'
                \ }

    " ---------------------------------------------------------------------
    " 自定义函数
    " ---------------------------------------------------------------------

    " 获取 Git 分支名称（优先使用 gitsigns，回退到 system 调用）
    function! GitBranch() abort
        " 尝试使用 gitsigns.nvim（高性能，无阻塞）
        if exists('*gitsigns.get_status_string')
            let l:head = gitsigns.get_status_string()
            if l:head !=? ''
                return l:head
            endif
        endif

        " Fallback: 使用 system 调用（兼容旧方式）
        let head = trim(system('git branch --show-current 2>/dev/null'))
        if head !=? ''
            " 获取仓库目录名
            let l:git = fnamemodify(finddir('.git', '.;'), ':p:h:h:t')
            let head = l:git . '  ' . head
        endif
        return head
    endfunction

    " 获取相对文件名（特殊缓冲区显示特殊名称）
    function! RelativeFileName() abort
        let l:bufname = bufname()
        if l:bufname =~# 'NERD_tree_*'          | return 'NERDTree'
        elseif l:bufname =~# '__Tagbar__.\d\+'  | return 'Tagbar'
        " Denite removed - Telescope uses TelescopePrompt filetype
        elseif l:bufname =~# '\[Telescope.*\]'  | return 'Telescope'
        else                                    | return expand('%:~:.')
        endif
    endfunction

    let g:refresh_commands += [
                \ 'call lightline#update()',
                \ 'call lightline#bufferline#reload()'
                \ ]
endif " g:lightline_enabled }}}

" =============================================================================
" NERDTree 配置
" =============================================================================
" {{{
if g:nerdtree_enabled
    "  Bug: VCS will ignore submodule
    let g:NERDTreeWinPos = 'left'
    let g:NERDTreeNaturalSort = 1
    let g:NERDTreeMouseMode = 1 " double click
    let g:NERDTreeShowHidden = 1
    let g:NERDTreeIgnore = [
                \ '\~$', '.DS_Store', '*.pyc',
                \ '.git$', '__pycache__',
                \ '#recycle', '@eaDir'
                \ ]
    let g:NERDTreeRespectWildIgnore = 1
    let g:NERDTreeWinSize = min([30, winwidth(0) / 4])
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeMinimalMenu=0
    let g:NERDTreeAutoDeleteBuffer=1 " drop invalid buffer after rename or delete
    let g:nerdtreedirarrowcollapsible=''
    let g:nerdtreedirarrowexpandable=''
    "" Netrw: disable for now, test later
    let g:NERDTreeHijackNetrw = 0
    "" cancel some key mappings: too much mappings won't help user
    ""  => keep only: Enter, Space, Mouse, F1/?
    "let g:NERDTreeMapActivateNode = ''

    autocmd FileType nerdtree call HideCursor()

    " => devicons
    " https://github.com/ryanoasis/vim-devicons/wiki/Extra-Configuration
    let g:webdevicons_enable = 1
    let g:webdevicons_enable_nerdtree = 1
    let g:webdevicons_conceal_nerdtree_brackets = 1
    let g:DevIconsEnableFoldersOpenClose = 1
    let NERDTreeDirArrowExpandable=''
    let NERDTreeDirArrowCollapsible=''
endif
" }}}

" =============================================================================
" Tagbar 配置
" =============================================================================
" {{{
if g:tagbar_enabled
    filetype on

    let g:tagbar_ctags_bin = g:pretty_home . '/prebuilts/bin/ctags'
    let g:tagbar_position = 'botright vertical'
    let g:tagbar_singleclick = 0
    let g:tagbar_sort = 0
    let g:tagbar_left = 0       " right
    let g:tagbar_silent = 1     " no echo to statusline
    let g:tagbar_compact = 1
    let g:tagbar_autofocus = 0  " no tags or cursor setting won't work
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

    autocmd FileType tagbar call HideCursor()
endif
" }}}

" =============================================================================
" Lazygit 配置
" =============================================================================
" {{{
if g:lazygit_enabled
    " transparency of floating window
    let g:lazygit_floating_window_winblend = 0
    " use plenary.nvim to manage floating window if available
    let g:lazygit_floating_window_use_plenary = 0 "LuaExists('plenary.window')
    " customize lazygit popup window border characters
    let g:lazygit_floating_window_border_chars = ['╭','─', '╮', '│', '╯','─', '╰', '│']
    "let g:lazygit_floating_window_border_chars = [ "─", "│", "─", "│", "╭", "╮", "╯", "╰" ]
    " custom config file first for nvim
    let g:lazygit_use_custom_config_file_path = 1
    let g:lazygit_config_file_path = g:pretty_home . '/lazygit.yml'
    " XXX: close win with esc => https://github.com/jesseduffield/lazygit/discussions/1966
endif
" }}}

" =============================================================================
" 其他配置
" =============================================================================
" => Rainbow
" let g:rainbow_active = 1 => cause conceal feature stop working
autocmd FileType vim,sh,c,cpp,html call rainbow_main#load()

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

" =============================================================================
" 加载插件配置文件: vimscript 插件 > lua 插件
" =============================================================================

luafile <sfile>:h/devicons.lua
luafile <sfile>:h/emojis.lua
luafile <sfile>:h/gitsigns.lua

let g:refresh_commands += [ 'lua require("nvim-web-devicons").refresh()' ]

" =============================================================================
" 通过 virtual text 发送界面消息
" =============================================================================
function! ShowTips(message) abort
    if ! exists("g:tips_namespace")
        let g:tips_namespace = nvim_create_namespace('pretty.nvim.tips')
    endif

    let l:bufnr = bufnr('%')

    " clear tips
    call nvim_buf_clear_namespace(l:bufnr, g:tips_namespace, 0, -1)
    if a:message == '' | return | endif

    " line - 1: line() start with 1, but nvim use 0-based index.
    call nvim_buf_set_extmark(l:bufnr, g:tips_namespace, line('$') - 1, 0, {
        \ 'virt_text': [[a:message, 'Keyword']],
        \ 'virt_text_pos': 'eol',
        \ 'hl_mode': 'combine',
        \ })
endfunction

" Suppress Esc and Close with 'Q' - for float windows
function! CloseWith(cmd) abort
    " => Disable Esc and Exit with 'Q' (Normal mode)
    nnoremap <silent><buffer> <Esc> :call ShowTips("⌨️ Exit with 'Q' ⌨️")<CR>
    exe "nnoremap <silent><buffer> Q :" .. a:cmd .. "<CR>"
endfunction

function! StartInsertWith(cmd) abort
    exe "nnoremap <silent><buffer> / :" .. a:cmd .. "<CR>"
    exe "nnoremap <silent><buffer> i :" .. a:cmd .. "<CR>"
    exe "nnoremap <silent><buffer> a :" .. a:cmd .. "<CR>"
endfunction

function! StopInsertWith(cmd) abort
    exe "inoremap <silent><buffer> <Esc> <C-o>:" .. a:cmd .. "<CR>"
endfunction

" =============================================================================
" 插件命令
" =============================================================================
if g:nerdtree_enabled
    " open or close explorer
    command! -nargs=0 Explorer NERDTreeToggle

    " open or focus explorer
    command! -nargs=0 ExplorerFocus
                \ if bufwinnr('NERD_tree') == -1
                \ |  exe 'NERDTree'
                \ | endif
                \ | exe bufwinnr('NERD_tree') . 'wincmd w'
endif

if g:tagbar_enabled
    " open or close taglist
    command! -nargs=0 Taglist TagbarToggle

    " open or focus taglist
    command! -nargs=0 TaglistFocus
                \ if bufwinnr('Tagbar') == -1
                \ |  call tagbar#OpenWindow()
                \ | endif
                \ | exe bufwinnr('Tagbar') . 'wincmd w'
endif

if g:lazygit_enabled
    " already lcd to git root
    command! -nargs=0 GitOpen LazyGit
endif

nnoremap <F7>       :ALEFixSuggest<cr>
inoremap <F7>       <C-o>:ALEFixSuggest<cr>
nnoremap <F8>       :ALEFix<cr>
inoremap <F8>       <C-o>:ALEFix<cr>

" --- 窗口管理 ---
" Normal/Insert 模式：F9/F10/F12 打开 Explorer/Taglist/LazyGit
nnoremap <F9>       :ExplorerFocus<cr>
inoremap <F9>       <C-o>:ExplorerFocus<cr>
nnoremap <F10>      :TaglistFocus<cr>
inoremap <F10>      <C-o>:TaglistFocus<cr>
" no F11 here, as macOS has global define
nnoremap <F12>      :GitOpen<cr>
inoremap <F12>      <C-o>:GitOpen<cr>

" =============================================================================
" 快速访问缓冲区（对应 lightline-bufferline）
" =============================================================================

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

" =============================================================================
" 窗口切换（Move focus）
" =============================================================================

noremap <C-j>       <C-W>j
noremap <C-k>       <C-W>k
noremap <C-h>       <C-W>h
noremap <C-l>       <C-W>l
tnoremap <C-j>      <C-\><C-N><C-W>j
tnoremap <C-k>      <C-\><C-N><C-W>k
tnoremap <C-h>      <C-\><C-N><C-W>h
tnoremap <C-l>      <C-\><C-N><C-W>l

" =============================================================================
" 跳转 - Goto
" =============================================================================

" Go to first line - `gg`
" Go to last line
noremap  gG         G

" Go to begin or end of code block
noremap  g[         [{
noremap  g]         ]}

" Go to Define and Back (Top of stack)
" TODO: map K,<C-]>,gD,... to one key
"nnoremap gd         <C-]>
nnoremap gd         :ALEGoToDefinition<cr>
nnoremap gD         :ALEGoToImplementation<cr>
nnoremap gb         <C-T>

" Go to man or doc
nnoremap gk         K

" Go to Type
" nmap gt

" Go to next error of ale
nnoremap ge         <Plug>(ale_next_wrap)

" Go to yank and paste
" copy line in visual mode
vnoremap gy         "+y
" copy character under cursor in normal mode
nnoremap gy         yl
nnoremap gp         "+p
vnoremap gp         p
vnoremap <C-c>      "+y

" Go to list, FIXME: what about quickfix
nnoremap gl         :lopen<CR>

" Tabularize
vnoremap /          :Tabularize /

