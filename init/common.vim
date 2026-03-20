" =============================================================================
" common.vim - 通用设置和工具函数
" =============================================================================
" 说明：本文件包含 pretty.nvim 的基础配置和共享工具函数
"       包括：路径配置、环境变量、工具函数、全局设置
" 命名规范：所有函数使用 Pretty* 前缀，保持统一风格
" =============================================================================

" =============================================================================
" 路径配置
" =============================================================================

" pretty.nvim 项目根目录
let g:pretty_home = fnamemodify($MYVIMRC, ':p:h')

" 添加本地可执行文件到 PATH
" 优先级：node_modules > prebuilts > py3env > 系统
let $PATH = g:pretty_home . '/node_modules/.bin:' . $PATH
let $PATH = g:pretty_home . '/prebuilts/bin:'        . $PATH
let $PATH = g:pretty_home . '/py3env/bin:'     . $PATH

" =============================================================================
" Python 环境配置
" =============================================================================

" 设置虚拟环境路径
let $VIRTUAL_ENV = g:pretty_home . '/py3env'

" 指定 Python3 host 程序（用于 Neovim Python 插件）
let g:python3_host_prog = $VIRTUAL_ENV . '/bin/python3'

" =============================================================================
" Node.js 环境配置
" =============================================================================

" 指定 Node.js host 程序（用于 Neovim Node 插件）
let g:node_host_prog = g:pretty_home . '/node_modules/.bin/neovim-node-host'

" =============================================================================
" 工具函数
" =============================================================================

" ---
" 查找可执行文件
" 优先级：本地 scripts > prebuilts > py3env > node_modules > 系统 PATH
" ---
" @param cmd string 命令名称
" @return string 返回完整路径，找不到返回空字符串
function! PrettyFindExecutable(cmd)
    " 1. 检查本地 scripts 目录
    if filereadable(g:pretty_home . '/scripts/' . a:cmd)
        return g:pretty_home . '/scripts/' . a:cmd
    " 2. 检查 prebuilts 目录
    elseif filereadable(g:pretty_home . '/prebuilts/bin/' . a:cmd)
        return g:pretty_home . '/prebuilts/bin/' . a:cmd
    " 3. 检查 py3env 目录
    elseif filereadable(g:pretty_home . '/py3env/bin/' . a:cmd)
        return g:pretty_home . '/py3env/bin/' . a:cmd
    " 4. 检查 node_modules 目录
    elseif filereadable(g:pretty_home . '/node_modules/.bin/' . a:cmd)
        return g:pretty_home . '/node_modules/.bin/' . a:cmd
    " 5. 检查系统 PATH
    elseif executable(a:cmd)
        return a:cmd
    endif
    " 未找到
    return ''
endfunction

" =============================================================================
" 全局设置
" =============================================================================

" ---
" SSH 远程会话配置
" 检测到 SSH 连接时，使用自定义剪贴板（只复制不回贴）
" ---
if exists('$SSH_CLIENT')
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

" ---
" Ripgrep 集成
" 如果安装了 rg，设置为默认的 grep 工具
" 使用 PrettyFindExecutable() 查找 rg 路径
" ---
let rg = PrettyFindExecutable('rg')
if rg != ''
    let g:pretty_rg_executable = rg
    let g:pretty_rg_options = [
                \ "--smart-case", "--glob", "!.git", "--hidden",
                \ "--no-heading",
                \ "--with-filename",
                \ "--line-number",
                \ "--column",
                \ ]
    let &grepprg = g:pretty_rg_executable . " " . join(g:pretty_rg_options, " ")
    set grepformat=%f:%l:%c:%m
endif

" =============================================================================
" 依赖检查工具
" =============================================================================

" ---
" 检查可执行文件是否存在
" 用于依赖检查，不存在时显示提示信息
" ---
" @param cmd string 命令名称
" @param msg string 提示信息
" @return number 存在返回 1，不存在返回 0
function! PrettyCheckExecutable(cmd, msg) abort
    if executable(a:cmd) == 0
        echom '❌ Please install ' . a:cmd . ' for ' . a:msg . ' support.'
        return 0
    endif
    return 1
endfunction

" =============================================================================
" 文件查找工具
" =============================================================================

" ---
" 搜索配置文件
" 用于查找项目配置文件（如 .eslintrc.yaml），找不到时返回默认配置
" ---
" @param prefix string 路径前缀
" @param files string 文件名列表（分号分隔，如 '.eslintrc.yaml;.eslintrc.yml'）
" @param default string 默认配置文件（相对于 lintrc/ 目录）
" @return string 返回找到的文件路径或默认配置路径
function! PrettyFindFiles(prefix, files, default = '')
    " 遍历文件列表
    for file in split(a:files, ';')
        let l:file = findfile(file, '.;')
        if l:file != ''
            return a:prefix . l:file
        endif
    endfor
    " 未找到，返回默认配置或空字符串
    return a:default == '' ? '' : a:prefix . g:pretty_home . '/lintrc/' . a:default
endfunction

" =============================================================================
" UI 工具函数
" =============================================================================

" ---
" 创建右下角浮动窗口配置
" 用于显示悬浮信息（如 hover、诊断信息）
" 参考：:h nvim_open_win
" ---
" @return dict 返回窗口配置字典
function! PrettyFloatingHover() abort
    return {
                \ 'border'      : ['╭','─', '╮', '│', '╯','─', '╰', '│'],
                \ 'style'       : 'minimal',
                \ 'relative'    : 'win',
                \ 'anchor'      : 'SE',
                \ 'row'         : winheight(0),
                \ 'col'         : winwidth(0),
                \ 'focusable'   : 1
                \ }
endfunction

" ---
" 隐藏/显示缓冲区光标（正常模式下）
" 在普通模式下隐藏光标，插入模式下显示
" 使用 augroup 管理自动命令
" ---
function! PrettyCursorToggle() abort
    " 启用光标行高亮
    setlocal cursorline

    " 初始化：隐藏光标
    set guicursor+=a:Cursor/Cursor
    highlight Cursor blend=100

    " 创建自动命令组
    augroup PrettyCursorToggle
        autocmd!
        " 隐藏光标（进入 buffer、离开插入模式、离开命令行）
        autocmd BufEnter,InsertLeave,CmdlineLeave <buffer>
                    \ highlight Cursor blend=100
                    \ | setlocal guicursor+=a:Cursor/Cursor
        " 显示光标（离开 buffer、进入插入模式、进入命令行）
        autocmd BufLeave,InsertEnter,CmdlineEnter <buffer>
                    \ highlight Cursor blend=0
                    \ | setlocal guicursor-=a:Cursor/Cursor
    augroup END
endfunction

" =============================================================================
" 通过 virtual text 发送界面消息
" =============================================================================
function! PrettyTipsToggle(message) abort
    if ! exists("g:pretty_tips_namespace")
        let g:pretty_tips_namespace = nvim_create_namespace('pretty.nvim.tips')
    endif

    let l:bufnr = bufnr('%')

    " clear tips
    call nvim_buf_clear_namespace(l:bufnr, g:pretty_tips_namespace, 0, -1)
    if a:message == '' | return | endif

    " line - 1: line() start with 1, but nvim use 0-based index.
    call nvim_buf_set_extmark(l:bufnr, g:pretty_tips_namespace, line('$') - 1, 0, {
        \ 'virt_text': [[a:message, 'Keyword']],
        \ 'virt_text_pos': 'eol',
        \ 'hl_mode': 'combine',
        \ })
endfunction

" Suppress Esc and Close with 'Q' - for float windows
function! PrettyExitWith(cmd) abort
    " => Disable Esc and Exit with 'Q' (Normal mode)
    nnoremap <silent><buffer> <Esc> :call PrettyTipsToggle("⌨️ Exit with 'Q' ⌨️")<CR>
    exe "nnoremap <silent><buffer> Q :" .. a:cmd .. "<CR>"
endfunction

function! PrettyInsertEnter(cmd) abort
    exe "nnoremap <silent><buffer> / :" .. a:cmd .. "<CR>"
    exe "nnoremap <silent><buffer> i :" .. a:cmd .. "<CR>"
    exe "nnoremap <silent><buffer> a :" .. a:cmd .. "<CR>"
endfunction

function! PrettyInsertLeave(cmd) abort
    exe "inoremap <silent><buffer> <Esc> <C-o>:" .. a:cmd .. "<CR>"
endfunction

" =============================================================================
" 常用函数
" =============================================================================

" 获取 Git 分支名称（优先使用 gitsigns，回退到 system 调用）
function! PrettyGitBranch() abort
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
function! PrettyFileName() abort
    let l:bufname = bufname()
    if l:bufname =~# 'NERD_tree_*'          | return 'NERDTree'
    elseif l:bufname =~# '__Tagbar__.\d\+'  | return 'Tagbar'
        " Denite removed - Telescope uses TelescopePrompt filetype
    elseif l:bufname =~# '\[Telescope.*\]'  | return 'Telescope'
    else                                    | return expand('%:~:.')
    endif
endfunction

" =============================================================================
" 刷新系统
" =============================================================================
" 用于重新加载配置后执行刷新操作

" 需要刷新的操作列表
" 格式：每个 item 是一个函数字符串或命令
let g:pretty_reload_commands = []

" ---
" 刷新函数：遍历并执行 pretty_reload_commands 中的命令
" ---
function! PrettyReload() abort
    " 检查是否配置了刷新命令
    if empty(g:pretty_reload_commands)
        echom 'ℹ️ No refresh commands configured'
        return
    endif

    " 遍历并执行每个命令
    for cmd in g:pretty_reload_commands
        try
            " 如果是函数引用，调用函数
            if type(cmd) == v:t_func
                call cmd()
            " 如果是字符串，作为命令执行
            elseif type(cmd) == v:t_string
                execute cmd
            endif
        catch
            echom '⚠️ PrettyReload error: ' . v:exception
        endtry
    endfor

    echom '✅ PrettyReload completed'
endfunction

" =============================================================================
" Lua 工具函数
" =============================================================================

" ---
" 检查 Lua 插件是否存在
" 类似于 VimScript 的 exists('*func')，用于检查 Lua 模块
" ---
" @param plugin string Lua 模块名称
" @return boolean 存在返回 true，不存在返回 false
function! PrettyLuaExists(plugin) abort
    return luaeval('select(1, pcall(require, _A))', a:plugin)
endfunction

" =============================================================================
" 项目根目录自动切换
" =============================================================================
" 打开文件时自动跳转到项目根目录（基于 .git 目录）
" 只在每个 Neovim 会话中执行一次

" 标记是否已执行（防止重复）
let g:auto_lcd_done = v:false

" 创建自动命令组
augroup PrettyProject
    autocmd!
    " 打开文件时查找项目根目录
    autocmd BufReadPost,BufNewFile * call s:find_project_root()
augroup END

" ---
" 查找并切换到项目根目录
" 使用 finddir() 查找 .git 目录（无需外部命令）
" ---
function! s:find_project_root() abort
    " 只执行一次
    if g:auto_lcd_done | return | endif

    " 跳过未命名的 buffer（如 [No Name]）
    if expand('%') == '' | return | endif

    " 跳过远程文件（ssh://, http://, 等）
    if expand('%:p') =~# '^\(ssh\|http\|https\|ftp\)://' | return | endif

    " 使用 finddir() 查找 .git 目录（Vim 内置函数，无需 shell 调用）
    let l:gitroot = finddir('.git', expand('%:p:h') . ';')
    if l:gitroot !=# ''
        " 切换到项目根目录
        execute 'lcd ' . fnameescape(fnamemodify(l:gitroot, ':h'))
        let g:auto_lcd_done = v:true
    endif
endfunction
