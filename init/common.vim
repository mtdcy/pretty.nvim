" =============================================================================
" common.vim - 通用设置和工具函数
" =============================================================================
" 说明：本文件包含 pretty.nvim 的基础配置和共享工具函数
"       包括：路径配置、环境变量、工具函数、全局设置
" 命名规范：所有函数使用 Pretty* 前缀，保持统一风格
" =============================================================================

" pretty.nvim 项目根目录
let g:pretty_home = $NVIM_HOME

" 当前项目根目录
let g:pretty_project_root = ''

" 需要刷新的操作列表
" 格式：每个 item 是一个函数字符串或命令
let g:pretty_reload_commands = []

" =============================================================================
" Python Node.js 环境配置 - 💡 总是使用绝对路径
" =============================================================================
" {{{
" 忽略 nvim 这个符号链接 和 node python3 目录
set wildignore+=*/nvim/*,*/node_modules/*,*/py3env/*

" 指定 Python3 host 程序（用于 Neovim Python 插件）
let g:python3_host_prog = exepath('python3')

" 指定 Node.js host 程序（用于 Neovim Node 插件）
let g:node_host_prog = exepath('neovim-node-host')
" }}}

" =============================================================================
" 全局设置
" =============================================================================
" {{{
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
" }}}

" =============================================================================
" 悬浮窗美化相关 - nvim_open_win
" =============================================================================
" {{{

" [top-left, top, top-right, right, bottom-right, bottom, bottom-left, left]
let g:pretty_borderchars= ['╭','─', '╮', '│', '╯','─', '╰', '│']

" Pretty 高亮颜色组
"   Shell红   - 外部命令 :!
"   搜索橙    - 搜索模式 / ?
"   提示黄    - 确认/输入提示
"   青柠色    - 成功/完成状态
"   帮助绿    - Help模式
"   调试青    - 调试/QuickFix相关
"   命令蓝    - 普通命令模式
"   紫罗兰    - 跳转/导航相关
"   Lua紫     - Lua命令模式
"   洋红色    - 标记/特殊操作
"   选择粉    - 选择/标记/特殊模式
lua require('nvim-highlight-colors').setup({})
let g:pretty_colors = {
            \   "PrettyRed"     : "#ef4444",
            \   "PrettyOrange"  : "#f97316",
            \   "PrettyYellow"  : "#eab308",
            \   "PrettyLime"    : "#65a30d",
            \   "PrettyGreen"   : "#22c55e",
            \   "PrettyCyan"    : "#06b6d4",
            \   "PrettyBlue"    : "#3b82f6",
            \   "PrettyViolet"  : "#7c3aed",
            \   "PrettyPurple"  : "#a855f7",
            \   "PrettyMagenta" : "#db2777",
            \   "PrettyPink"    : "#ec4899",
            \ } 

" 遍历 g:pretty_colors 并设置高亮组
function! PrettyHighlightColors() abort
    for [name, color] in items(g:pretty_colors)
        execute 'highlight ' . name . ' guifg=' . color
    endfor
endfunction

call PrettyHighlightColors()

" ⚠️ Reload 时，高亮组会丢失，需要重新设置
let g:pretty_reload_commands += [ "call PrettyHighlightColors()" ]

" 颜色辅助函数 {{{
" 函数：PrettyColors
" 功能：获取高亮组的颜色值，如果参数已经是颜色值则直接返回
"
" 参数：
"   color : string 可以是高亮组名称（如 "PrettyRed"）或颜色值（如 "#ef4444"）
"
" 返回：
"   string: 颜色值（格式：#RRGGBB）
"
" 使用示例：
"   let red_color = PrettyColors('PrettyRed')
"   let custom_color = PrettyColors('#ff0000')
" =============================================================================
function! PrettyColors(color) abort
    " 检查是否是颜色值（以 # 开头）
    if a:color =~? '^#'
        return a:color
    else
        return get(g:pretty_colors, a:color, '#ffffff')
    endif
endfunction
" }}}

" 彩虹边框生成函数 {{{
" 函数：s:rainbow_borders
" 功能：根据两个基础色生成8个边框位置的渐变色
"
" 参数：
"   color1 : string 起始颜色（左上角，格式：#RRGGBB）
"   color2 : string 结束颜色（右下角，格式：#RRGGBB）
"   prefix : string 高亮组前缀（如 "Blue", "Orange", "Purple"）
"
" 返回：
"   list: 8个边框位置的配置，格式：[ [字符, 高亮组], ... ]
"
" 设计原理：
"   1. 生成5个渐变颜色（起始→结束）
"   2. 映射到8个边框位置，形成对称渐变
"   3. 自动创建对应的高亮组
" =============================================================================
function! PrettyBorders(color1, color2, prefix = '') abort
    let color1 = a:color1 =~# '^#' ? a:color1 : PrettyColors(a:color1)
    let color2 = a:color2 =~# '^#' ? a:color2 : PrettyColors(a:color2)

    " 颜色辅助函数
    function! s:hex_to_rgb(hex) abort
        let hex = substitute(a:hex, '^#', '', '')
        return [
            \ str2nr(hex[0:1], 16),
            \ str2nr(hex[2:3], 16),
            \ str2nr(hex[4:5], 16)
            \ ]
    endfunction

    function! s:rgb_to_hex(rgb) abort
        return printf('#%02x%02x%02x', a:rgb[0], a:rgb[1], a:rgb[2])
    endfunction

    let start = s:hex_to_rgb(color1)
    let end = s:hex_to_rgb(color2)

    " 计算过渡色
    let gradient = [color1]  " index 0: 左上角
    for i in range(1, 3)
        let ratio = i / 4.0
        let r = float2nr(start[0] + (end[0] - start[0]) * ratio)
        let g = float2nr(start[1] + (end[1] - start[1]) * ratio)
        let b = float2nr(start[2] + (end[2] - start[2]) * ratio)
        call add(gradient, s:rgb_to_hex([r, g, b]))
    endfor

    call add(gradient, color2)  " index 4: 右下角
    for i in range(5, 7)
        call add(gradient, gradient[8-i])
    endfor

    " 边框位置映射
    let borders = []
    for i in range(1, 8)
        let hl_name = "PrettyFloatBorder" . a:prefix . i
        execute 'highlight ' . hl_name . ' guifg=' . gradient[i-1]
        call add(borders, [g:pretty_borderchars[i-1], hl_name])
    endfor

    return borders
endfunction
" }}}

" 默认使用蓝色渐变
let g:pretty_rainbow_borders = PrettyBorders( "PrettyBlue", "PrettyGreen" )

" ---
" 创建右下角浮动窗口配置
" 用于显示悬浮信息（如 hover、诊断信息）
" 参考：:h nvim_open_win
" 注意：💡 这个变量在 vim 启动时就已经生成，所以 relative 并不一定如预期
" ---
let g:pretty_hints_window = {
            \ 'border'      : g:pretty_rainbow_borders,
            \ 'style'       : 'minimal',
            \ 'relative'    : 'win',
            \ 'anchor'      : 'NW',
            \ 'row'         : 0,
            \ 'col'         : 5,
            \ 'focusable'   : 1
            \ }
" }}}

" =============================================================================
" 工具函数
" =============================================================================
" {{{
" ---
" 查找可执行文件
" 优先级：本地 scripts > prebuilts > py3env > node_modules > 系统 PATH
" ---
" @param cmd string 命令名称
" @return string 返回完整路径，找不到返回空字符串
function! PrettyFindExecutable(cmd) abort
    " 1. 检查本地 scripts 目录 - 帮助脚本
    if filereadable(g:pretty_home . '/scripts/' . a:cmd)
        return g:pretty_home . '/scripts/' . a:cmd
    elseif executable(a:cmd)
        return exepath(a:cmd)
    endif
    " 未找到
    return ''
endfunction

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

" ---
" 搜索配置文件
" 用于查找项目配置文件（如 .eslintrc.yaml），找不到时返回默认配置
" ---
" @param prefix string 路径前缀
" @param files string 文件名列表（分号分隔，如 '.eslintrc.yaml;.eslintrc.yml'），支持通配符（如 '.eslintrc*'）
" @param default string 默认配置文件（相对于 lintrc/ 目录）
" @return string 返回找到的文件路径或默认配置路径
function! PrettyFindFiles(prefix, files, default = '') abort
    " 遍历文件列表
    for file in split(a:files, ';')
        " 通配符匹配，从工作区查找
        let l:matches = globpath(g:pretty_project_root, file, 0, 1)
        if !empty(l:matches)
            return a:prefix . l:matches[0]
        endif
    endfor
    " 未找到，返回默认配置或空字符串
    return a:default == '' ? '' : a:prefix . g:pretty_home . '/lintrc/' . a:default
endfunction
" }}}

" =============================================================================
" UI 工具函数
" =============================================================================
" {{{
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
" @param Q : force close float window
" @param q : hide float window (optional)
function! PrettyExitWith(Q = '', q = '') abort
    " => Disable Esc and Exit with 'Q' (Normal mode)
    nnoremap <silent><buffer> <Esc> :call PrettyTipsToggle("⌨️ Exit with 'Q' ⌨️")<CR>

    if a:Q == ''
        exe "nnoremap <silent><buffer> Q :bdelete<CR>"
    else
        exe "nnoremap <silent><buffer> Q :" .. a:Q .. "<CR>"
    endif

    " 默认'q' 不关闭悬浮窗 - 用户应该在有办法恢复窗口时才定义'q' 的行为
    if a:q == '' | return | endif

    exe "nnoremap <silent><buffer> q :" .. a:q .. "<CR>"
endfunction

function! PrettyInsertEnter(cmd) abort
    exe "autocmd InsertEnter <buffer> " .. a:cmd
endfunction

function! PrettyInsertLeave(cmd) abort
    " -- 不要重新定义 Esc 的行为, 使用 autocmd
    exe "autocmd InsertLeave <buffer> " .. a:cmd
endfunction
" }}}

" =============================================================================
" 常用函数
" =============================================================================
" {{{
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
    if l:bufname =~# 'NERD_tree_*'          | return 'Files'
    elseif l:bufname =~# 'NvimTree_*'       | return 'Files'
    elseif l:bufname =~# '__Tagbar__.\d\+'  | return 'Tags'
    elseif l:bufname =~# 'OUTLINE_\d\+'     | return 'Tags'
    elseif l:bufname =~# '\[Telescope.*\]'  | return 'Telescope'
    else                                    | return expand('%:~:.')
    endif
endfunction

" text before cursor
function! PrettyLineTyped() abort
    let c = col('.') - 1
    return c > 0 ? getline('.')[:c-1] : ''
endfunction

" new line? => insert indent => :h i_CTRL-T
function! PrettyLineIsNewLine() abort
    let typed_line = PrettyLineTyped()
    " :h expr4 for compare op help
    if &filetype ==? 'markdown'             | return typed_line =~# '\s*\(-\|\*\|\d\+\)\s\+$'
    elseif &filetype ==? 'yaml'             | return typed_line =~# '\s*.*\(-\|:\)\s*$'
    else                                    | return typed_line ==# ''
    endif
endfunction

" new start? => insert tab
function! PrettyLineIsNewWord() abort
    let typed_line = PrettyLineTyped()
    " space before cursor?
    return typed_line[-1:] =~# '\s'
endfunction

" ---
" 检查 Lua 插件是否存在
" 类似于 VimScript 的 exists('*func')，用于检查 Lua 模块
" ---
" @param plugin string Lua 模块名称
" @return boolean 存在返回 true，不存在返回 false
function! PrettyLuaExists(plugin) abort
    return luaeval('select(1, pcall(require, _A))', a:plugin)
endfunction
" }}}

" =============================================================================
" Quickfix 相关函数
" =============================================================================
" {{{

" 将指定bufnr的 <filename>:<line>:<col> 格式buffer加载到quickfix列表
" @param bufnr  目标buffer编号，传%表示当前buffer
" @param cwd    可选：工作目录，用于解析相对路径，默认当前工作目录
function! PrettyQuickfixLoad(bufnr, ...) abort
    " 检查buffer是否存在
    if !bufexists(a:bufnr)
        echom "Buffer " . a:bufnr . " does not exist!"
        return
    end

    let l:cwd = getcwd()
    let l:lines = getbufline(a:bufnr, 1, '$')
    let l:items = []

    for l:line in l:lines
        let l:line = trim(l:line)
        if l:line ==# ''
            continue
        endif

        " 解析 filename:line:col 格式
        let l:match = matchlist(l:line, '^\(.\{-}\):\(\d\+\):\(\d\+\):\?\(.\{-}\)\?$')
        if len(l:match) > 3
            let l:filename = l:match[1]
            let l:lnum = str2nr(l:match[2])
            let l:col = str2nr(l:match[3])
            let l:text = trim(l:match[4])

            " 移除 filename 中可能存在的前缀符号（如 "➤  " 等）
            let l:filename = substitute(l:filename, '^[^a-zA-Z0-9./_]\+\s\+', '', '')

            if empty(l:text)
                " 尝试读取文件的真实行内容
                try
                    let l:text = trim(readfile(l:filename, '', l:lnum)[-1])
                catch
                    echom "❌ readfile " . l:filename . " failed"
                endtry
            endif

            call add(l:items, {
                        \ 'filename': l:filename,
                        \ 'lnum': l:lnum,
                        \ 'col': l:col,
                        \ 'text': l:text,
                        \ })
        else
            echom "❌ bad line " . l:line
        endif
    endfor

    " 替换当前quickfix列表
    let l:title = bufname(a:bufnr)

    if len(a:000) > 0 | let l:title = a:1 | endif

    " 设置标题 - action = ' ' => 自动保存历史
    call setqflist([], ' ', {
                \ 'title' : l:title,
                \ 'context' : { 'source' : 'custom' },
                \ })

    " 添加 items
    call setqflist(l:items, 'a')

    " 可选：自动打开quickfix窗口（取消注释即可）
    " botright copen
endfunction
" }}}

" =============================================================================
" Ripgrep 集成
" =============================================================================
" ---
" 如果安装了 rg，设置为默认的 grep 工具
" 使用 PrettyFindExecutable() 查找 rg 路径
" ---
set grepformat=%f:%l:%c:%m
let g:pretty_rg_executable = PrettyFindExecutable('rg')
let g:pretty_rg_options = [
            \ "--smart-case", "--glob", "!.git", "--hidden",
            \ "--no-heading",
            \ "--with-filename",
            \ "--line-number",
            \ "--column",
            \ ]
if g:pretty_rg_executable != ''
    let &grepprg = g:pretty_rg_executable . " " . join(g:pretty_rg_options, " ")
endif

" =============================================================================
" 刷新系统
" =============================================================================
" {{{
" ---
" 刷新函数：遍历并执行 pretty_reload_commands 中的命令
" 用于重新加载配置后执行刷新操作
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
" }}}

" =============================================================================
" 项目相关操作
" =============================================================================

" 打开文件时自动跳转到项目根目录（基于 .git 目录）
function! s:find_project_root() abort
    if g:pretty_project_root != '' | return | endif
        
    let g:pretty_project_root = expand('%:p:h')

    " 使用 finddir() 查找 .git 目录（Vim 内置函数，无需 shell 调用）
    let workdir = finddir('.git', expand('%:p:h') . ';', 1)
    if workdir != '' 
        let g:pretty_project_root = fnameescape(fnamemodify(workdir, ':p:h:h'))
    endif

    echom "💡 lcd to " .. g:pretty_project_root
    exe "lcd " .. g:pretty_project_root
endfunction

" 创建自动命令组
augroup PrettyProject
    autocmd!
    " 打开文件时查找项目根目录
    autocmd BufReadPost,BufNewFile * call <sid>find_project_root()
augroup END
