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

" 💡 这个文件包含的组件很多，每个组件都由自己的开关控制
let g:lightline_enabled = 1
let g:lazygit_enabled = 1
let g:outline_enabled = 1

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

" 启用 filetype 检测、插件和缩进
filetype plugin indent on

" 启用语法高亮 - 传统 Vim Syntax
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
                \   'gitbranch'         : '%{PrettyGitBranch()}',
                \   'readonly'          : '%{&readonly ? "" : ""}',
                \   'filename'          : '%{PrettyFileName()}',
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

    let g:pretty_reload_commands += [
                \ 'call lightline#update()',
                \ 'call lightline#bufferline#reload()'
                \ ]
endif " g:lightline_enabled }}}

" =============================================================================
" Outline 配置
" =============================================================================
" {{{
if g:outline_enabled
    source <sfile>:h/outline.lua

    function! s:outline_toggle_focus() abort
        if bufwinnr('OUTLINE_1') < 0
            lua require("outline").open_outline()
        else
            lua require("outline").focus_outline()
        endif
    endfunction

    command! -nargs=0 TagsExplorer call <sid>outline_toggle_focus()
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
    let g:lazygit_floating_window_use_plenary = 0 "PrettyLuaExists('plenary.window')
    " customize lazygit popup window border characters
    let g:lazygit_floating_window_border_chars = g:pretty_borderchars
    "let g:lazygit_floating_window_border_chars = ['╭','─', '╮', '│', '╯','─', '╰', '│']
    "let g:lazygit_floating_window_border_chars = [ "─", "│", "─", "│", "╭", "╮", "╯", "╰" ]
    " custom config file first for nvim
    let g:lazygit_use_custom_config_file_path = 1
    let g:lazygit_config_file_path = g:pretty_home . '/lazygit.yml'
    " XXX: close win with esc => https://github.com/jesseduffield/lazygit/discussions/1966

    function! s:lazygit_ready() abort
        call PrettyExitWith("echo ''")
    endfunction

    augroup LazygitSettings
        autocmd!
        autocmd FileType lazygit call s:lazygit_ready()
    augroup END
endif
" }}}

" =============================================================================
" 其他配置
" =============================================================================
" {{{

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
" }}}

" =============================================================================
" 加载插件配置文件: vimscript 插件 > lua 插件
" =============================================================================

source <sfile>:h/nvim-tree.lua

" 代码风格和质量工具（Lua）
source <sfile>:h/style.lua

" 加载 Solarized 主题配置（Lua 配置）
source <sfile>:h/solarized.lua
source <sfile>:h/rainbow.lua

source <sfile>:h/devicons.lua
source <sfile>:h/gitsigns.lua

" => Load basic lua plugins
source <sfile>:h/markdown.lua


let g:pretty_reload_commands += [ 'lua require("nvim-web-devicons").refresh()' ]

" for document hightlight
let g:markdown_fenced_languages = [ 'vim', 'help', 'bash=sh' ]
" =============================================================================
" 插件命令
" =============================================================================
command! -nargs=0 FileExplorerToggle lua require("nvim-tree.api").tree.toggle()
command! -nargs=0 FileExplorerFocus lua require("nvim-tree.api").tree.open()

if g:lazygit_enabled
    " already lcd to git root
    command! -nargs=0 GitExplorer LazyGit
endif

" --- 窗口管理 ---
" Normal/Insert 模式：F9/F10/F12 打开 Explorer/Taglist/LazyGit
nnoremap <silent> <F9>      :FileExplorerFocus<cr>
inoremap <silent> <F9>      <C-o>:FileExplorerFocus<cr>
nnoremap <silent> <F10>     :TagsExplorer<cr>
inoremap <silent> <F10>     <C-o>:TagsExplorer<cr>
" no F11 here, as macOS has global define
nnoremap <silent> <F12>     :GitExplorer<cr>
inoremap <silent> <F12>     <C-o>:GitExplorer<cr>

" =============================================================================
" 快速访问缓冲区（对应 lightline-bufferline）
" =============================================================================

function! s:buffer_explorer(index) abort
    if g:lightline_enabled
        call lightline#bufferline#go(a:index)
    else
        exe ':buffer ' . a:index
    endif
endfunction

nnoremap <silent> <leader>1 :call <SID>buffer_explorer(1)<cr>
nnoremap <silent> <leader>2 :call <SID>buffer_explorer(2)<cr>
nnoremap <silent> <leader>3 :call <SID>buffer_explorer(3)<cr>
nnoremap <silent> <leader>4 :call <SID>buffer_explorer(4)<cr>
nnoremap <silent> <leader>5 :call <SID>buffer_explorer(5)<cr>
nnoremap <silent> <leader>6 :call <SID>buffer_explorer(6)<cr>
nnoremap <silent> <leader>7 :call <SID>buffer_explorer(7)<cr>
nnoremap <silent> <leader>8 :call <SID>buffer_explorer(8)<cr>
nnoremap <silent> <leader>9 :call <SID>buffer_explorer(9)<cr>
nnoremap <silent> <leader>0 :call <SID>buffer_explorer(10)<cr>
nnoremap <silent> <leader>` :buffer #<cr>

" =============================================================================
" 跳转 - Goto
" =============================================================================

" Go to first line - `gg`
" Go to last line
noremap  <silent> gG        G

" Go to begin or end of code block
noremap  <silent> g[        [{
noremap  <silent> g]        ]}

" Go to yank and paste
" copy line in visual mode
vnoremap <silent> gy        "+y
" copy character under cursor in normal mode
nnoremap <silent> gy        yl
nnoremap <silent> gp        "+p
vnoremap <silent> gp        p
vnoremap <silent> <C-c>     "+y

" Tabularize
vnoremap /  :Tabularize /

" Misc
inoremap <silent> <C-d>     <C-R>=strftime("%Y.%m.%d")<CR>
