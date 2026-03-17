" =============================================================================
" UI 配置文件 - lightline + bufferline
" =============================================================================
" 说明：
"   本文件负责 Neovim 的 UI 配置，包括：
"   1. 主题和颜色配置
"   2. 字体设置
"   3. lightline 状态栏配置
"   4. bufferline 缓冲区标签配置
"   5. 基本 UI 设置
" =============================================================================

" =============================================================================
" 全局选项
" =============================================================================

" 暗色模式：1 = 暗色，0 = 亮色
let g:dark_mode = 1

" lightline 启用开关：1 = 启用，0 = 禁用
let g:lightline_enabled = 1

" =============================================================================
" 颜色和主题
" =============================================================================

" 启用真彩色支持（24 位色）
set termguicolors

" 根据 dark_mode 设置背景
if g:dark_mode
    set background=dark
else
    set background=light
endif

" 加载 Solarized 主题配置（Lua 配置）
luafile <sfile>:h/solarized.lua

" 终端颜色数（非 GUI 模式）
if !has('gui_running')
    set t_Co=256
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

" 启用语法高亮
syntax enable

" 强制使用旧版正则引擎（解决某些高亮慢的问题）
"set regexpengine=1

" 始终启用鼠标支持（所有模式）
set mouse=a

" =============================================================================
" lightline 状态栏配置
" =============================================================================

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

endif " g:lightline_enabled
