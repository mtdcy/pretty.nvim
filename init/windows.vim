"=============================================================================
" FILE: windows.vim - Window Manager for pretty.nvim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================
" 说明：
"   本文件负责 Neovim 窗口管理，包括：
"   1. 侧边栏窗口管理（NERDTree/NvimTree/Tagbar/Outline 等）
"   2. 主窗口（main window）保护与恢复
"   3. Buffer 与窗口的智能分配
"
" 窗口布局：
"   +----------------------------------------+
"   |               headbar (2)              |
"   +----------+------------------+----------+
"   |          |                  |          |
"   | leftbar  |     main         | rightbar |
"   | (1)      |     (0)          | (4)      |
"   |          |                  |          |
"   +----------+------------------+----------+
"   |               footbar (3)              |
"   +----------------------------------------+
"
" 窗口 ID 映射：
"   s:winids = [main, leftbar, headbar, footbar, rightbar]
"              [  0  ,   1   ,   2    ,   3    ,    4    ]
"
" 关键设计：
"   - 使用 WinID 追踪窗口（而非 winnr，避免窗口号变化）
"   - 主窗口关闭时自动恢复，防止侧边栏窗口连锁关闭
"   - Buffer 根据 filetype 自动分配到正确窗口
"   - 侧边栏 Buffer 设为 nobuflisted（不污染 buffer 列表）
"=============================================================================

" =============================================================================
" 全局配置
" =============================================================================

" 调试模式：1 = 启用（输出详细日志），0 = 禁用
let s:wm_debug  = 0

" 侧边栏高度（水平窗口：help/quickfix/location list）
" 最小 12 行，最大为当前窗口高度的 1/4
let s:wm_height = min([12, winheight(0) / 4])

" 侧边栏宽度（垂直窗口：NERDTree/NvimTree/Tagbar/Outline）
" 最大 32 列，但不超过当前窗口宽度的 1/2
let s:wm_width  = min([32, winwidth(0) / 2])

" 窗口类型 ID 定义
let s:wmid_main = 0  " 主窗口（编辑区）
let s:wmid_tree = 1  " 左侧栏：文件浏览器（NERDTree/NvimTree）
let s:wmid_docs = 2  " 顶部栏：文档窗口（help/man/ale-info）
let s:wmid_foot = 3  " 底部栏：快速修复/位置列表
let s:wmid_tags = 4  " 右侧栏：符号大纲（Tagbar/Outline）

" 重置 wildignore（使用默认值，避免影响文件浏览）
set wildignore&

" 不使用 equalalways（避免窗口大小自动调整，保持手动设置的比例）
set noequalalways

" 命令行高度设为 1（默认值，保持简洁）
set cmdheight=1

" =============================================================================
" 窗口 ID 管理
" =============================================================================

" 窗口 ID 数组：[main, leftbar, headbar, footbar, rightbar]
" 初始值：当前窗口设为 main (0)，其他设为 0（未分配）
" 使用 WinID 而非 winnr 的原因：WinID 是窗口的唯一标识符，不会因窗口开关而变化
let s:winids = [ win_getid(), 0, 0, 0, 0 ]

" 根据 Buffer 的文件类型判断其所属的窗口类型（wmid）
" 参数：bufnr - 缓冲区号（可选，默认为当前 buffer）
" 返回：wmid（0=主窗口，1-4=侧边栏窗口）
" 匹配规则：按顺序匹配，第一个匹配的规则生效
function! s:wmid(bufnr = '') abort
    " 获取文件类型（不区分大小写）
    let ftype = getbufvar(bufnr(a:bufnr), '&ft')

    " 文件浏览器：NERDTree 或 NvimTree
    if ftype ==? 'nerdtree' || ftype ==? 'NvimTree'
        return s:wmid_tree
    " 符号大纲：Tagbar 或 Outline
    elseif ftype ==? 'tagbar' || ftype ==? 'Outline'
        return s:wmid_tags
    " 文档窗口：help/man/ale-info（精确匹配，避免误判）
    elseif ftype ==? 'help' || ftype ==? 'man' || ftype ==? 'ale-info'
        return s:wmid_docs
    " 快速修复：quickfix 或 buftype=quickfix
    elseif ftype ==? 'qf' || getbufvar(bufnr(a:bufnr), '&bt') ==? 'quickfix'
        return s:wmid_foot
    endif
    " 默认：主窗口
    return s:wmid_main
endfunction

" --- 窗口 ID 查询函数 ---

" 根据窗口 ID 查找对应的窗口类型（wmid）
" 参数：winid - 窗口 ID（可选，默认为当前窗口）
" 返回：wmid（0-4 表示窗口类型，-1 表示未分类）
function! s:wmid_winid(winid = '') abort
    if a:winid == ''
        return index(s:winids, win_getid())
    else
        return index(s:winids, a:winid)
    endif
endfunction

" 根据窗口号（winnr）查找对应的窗口类型（wmid）
" 参数：winnr - 窗口号（可选，默认为当前窗口）
" 返回：wmid（0-4 表示窗口类型，-1 表示未分类）
function! s:wmid_winnr(winnr = '') abort
    if a:winnr == ''
        return index(s:winids, win_getid())
    else
        return index(s:winids, win_getid(a:winnr))
    endif
endfunction

" 设置窗口 ID：将指定的 winid 绑定到 wmid，并清除旧的绑定
" 参数：
"   wmid  - 窗口类型 ID（0-4）
"   winid - 窗口 ID
" 逻辑：先遍历数组，清除与该 winid 的旧绑定，再设置新绑定
function! s:wm_set_winid(wmid, winid) abort
    for i in range(len(s:winids))
        if s:winids[i] == a:winid
            let s:winids[i] = 0
        endif
    endfor
    let s:winids[a:wmid] = a:winid
endfunction

" 根据 wmid 获取窗口号（winnr）
" 参数：wmid - 窗口类型 ID
" 返回：窗口号（>0 表示有效，0 表示窗口不存在或已关闭）
function! s:wm_winnr(wmid) abort
    return win_id2win(s:winids[a:wmid])
endfunction

" =============================================================================
" 窗口操作函数
" =============================================================================

" 切换到指定类型的窗口
" 参数：wmid - 窗口类型 ID（0-4）
" 注意：如果窗口不存在（winnr=0），此命令会失败
function! s:wm_wincmd_wmid(wmid) abort
    exe s:wm_winnr(a:wmid) . 'wincmd w'
endfunction

" 将 Buffer 安置到正确的窗口位置
" 参数：wmid - 窗口类型 ID
" 用途：当侧边栏 Buffer 在新窗口打开时，将其移动到预留的窗口位置
" 逻辑：
"   1. 确保目标窗口已创建
"   2. 保存当前 buffer 号
"   3. 关闭当前窗口
"   4. 切换到目标窗口
"   5. 在目标窗口加载 buffer
function! s:wm_settle_bufnr(bufnr = '') abort
    let wmid = s:wmid(a:bufnr)
    let winnr = s:wm_winnr(wmid)

    let current = bufwinnr(a:bufnr)
    " 在现有窗口加载 bufnr
    exe winnr . 'wincmd w  | buffer ' . a:bufnr
    " 关闭当前窗口
    exe current . 'wincmd w | wincmd c'
    " 进入窗口
    exe winnr . 'wincmd w'
endfunction

" 移动 Buffer 到正确的窗口
" 参数：bufnr - 缓冲区号
" 用途：当 Buffer 被错误地分配到侧边栏时，将其移回主窗口
" 逻辑：
"   1. 切换到备用 buffer（避免删除当前 buffer）
"   2. 查找包含目标 buffer 的其他窗口
"   3. 切换到正确的窗口
"   4. 在目标窗口加载 buffer
function! s:wm_move_bufnr(bufnr) abort
    let bufnr = bufnr(a:bufnr)
    " 切换到备用 buffer（避免删除当前 buffer）
    exe 'buffer#'
    " 查找包含该 buffer 的其他窗口
    let li = filter(range(1, winnr('$')), 'v:val != winnr() && winbufnr(v:val)==' . bufnr)
    " 切换到正确的窗口
    if len(li) | call s:wm_wincmd_wmid(s:wmid_winnr(li[0]))
    else       | call s:wm_wincmd_wmid(0)
    endif
    " 将 buffer 加载到当前窗口
    exe 'buffer ' . bufnr
endfunction

" =============================================================================
" 调试信息
" =============================================================================

" 显示当前窗口和 Buffer 的详细信息（调试用，s:wm_debug=1 时使用）
" 输出内容包括：
"   - 窗口类型（wmid）和 WinID
"   - 窗口类型（win_gettype）、窗口号、总窗口数
"   - Buffer 号、总 Buffer 数、Buffer 名称
"   - 文件类型、Buffer 类型、是否 listed、bufhidden 设置
function! s:wminfo() abort
    echom '💡 window ' . s:wmid() . ' =? ' . win_getid()
                \ . '|type:' . win_gettype()
                \ . '|winnr:' . winnr() . '#' . winnr('$')
                \ . '|bufnr:' . bufnr('%') . '#' . bufnr('$')
                \ . '|bufname:' . bufname('%') . '#' . bufname('#') . ''
                \ . '|filetype:' . &filetype
                \ . '|buftype:' . &buftype
                \ . '|buflisted:' . &buflisted
                \ . '|hide:' . &bufhidden
endfunction

" =============================================================================
" 主窗口管理（关键修复）
" =============================================================================

" 检查并恢复主窗口
" 触发时机：BufNew 事件（创建新 buffer 时）
" 修复问题：
"   - 使用 bdelete 删除最后一个 buffer 会导致窗口关闭
"   - 主窗口关闭后，侧边栏窗口会连锁关闭
" 恢复策略：
"   - 根据当前窗口类型，在合适的位置拆分新窗口
"   - 保持窗口布局比例（宽度/高度）
function! s:wm_main() abort
    " 检查 main 窗口状态
    " 注意：要是 buffer 是在外部被删除的，winid 还被保存着，所以检查 winnr (1-based)
    " winnr() > 0 表示窗口存在，<= 0 表示窗口已关闭
    if s:wm_winnr(0) > 0 | return | endif

    let winid = win_getid()
    let width = winwidth(0) - s:wm_width
    let height = winheight(0) - s:wm_height

    " 根据当前窗口类型，选择合适的拆分方向
    if winid == s:winids[1]
        " 当前在 leftbar：右侧拆分
        exe 'rightbelow vnew'
        exe 'vertical resize ' . width
    elseif winid == s:winids[2]
        " 当前在 headbar：下方拆分
        exe 'below new'
        exe 'resize ' . height
    elseif winid == s:winids[3]
        " 当前在 footbar：上方拆分
        exe 'leftabove vnew'
        exe 'vertical resize ' . width
    else
        " 其他情况（rightbar 等）：上方拆分
        exe 'above new'
        exe 'resize ' . height
    endif

    echom '⚠️ Restore main window'
    call s:wm_set_winid(0, win_getid())
endfunction

" =============================================================================
" 窗口重载（新增功能）
" =============================================================================

" 重载窗口 ID 映射：重新扫描所有 buffer，重建 s:winids 映射
" 功能：
"   1. 切换到 main 窗口
"   2. 清除侧边栏窗口的历史 WinID
"   3. 遍历所有 listed buffer，找到 main 窗口的 buffer
"   4. 遍历所有 buffer，更新侧边栏窗口的 WinID
" 用途：
"   - 窗口状态混乱时恢复（如插件冲突、异常关闭）
"   - 手动修复窗口映射
"   - 调试窗口问题
" 重载窗口 ID 映射：重新扫描所有 buffer，重建 s:winids 映射
" 功能：
"   1. 切换到 main 窗口
"   2. 清除侧边栏窗口的历史 WinID
"   3. 遍历所有 listed buffer，找到 main 窗口的 buffer
"   4. 遍历所有 buffer，更新侧边栏窗口的 WinID
" 用途：
"   - 窗口状态混乱时恢复（如插件冲突、异常关闭）
"   - 手动修复窗口映射
"   - 调试窗口问题
" 重载窗口 ID 映射：重新扫描所有 buffer，重建 s:winids 映射
" 功能：
"   1. 切换到 main 窗口
"   2. 清除侧边栏窗口的历史 WinID
"   3. 遍历所有 listed buffer，找到 main 窗口的 buffer
"   4. 遍历所有 buffer，更新侧边栏窗口的 WinID
" 用途：
"   - 窗口状态混乱时恢复（如插件冲突、异常关闭）
"   - 手动修复窗口映射
"   - 调试窗口问题
" 重载窗口 ID 映射：重新扫描所有 buffer，重建 s:winids 映射
" 功能：
"   1. 切换到 main 窗口
"   2. 清除侧边栏窗口的历史 WinID
"   3. 遍历所有 listed buffer，找到 main 窗口的 buffer
"   4. 遍历所有 buffer，更新侧边栏窗口的 WinID
" 用途：
"   - 窗口状态混乱时恢复（如插件冲突、异常关闭）
"   - 手动修复窗口映射
"   - 调试窗口问题
"   3. 最后切换到 main 窗口
" 用途：
"   - 窗口状态混乱时恢复
"   - 手动修复窗口映射
"   - 调试窗口问题
function! s:wm_reload() abort
    " 切换到 main 窗口
    call s:wm_wincmd_wmid(0)

    " 清除历史值
    for wmid in range(1, 4)
        call s:wm_set_winid(wmid, 0)
    endfor

    " 更新 main 窗口 winid ( 存在在多个bufnr 满足条件，只选一个)
    for bufnr in range(1, bufnr('$'))
        if !buflisted(bufnr) | continue | endif

        if s:wmid(bufnr) != s:wmid_main | continue | endif
        if bufwinid(bufnr) <= 0  | continue | endif

        call s:wm_set_winid(0, bufwinid(bufnr))
        break
    endfor

    " 遍历所有 buffer - 更新其他窗口
    for bufnr in range(1, bufnr('$'))
        " 获取 buffer 类型
        let wmid = s:wmid(bufnr)

        " 跳过主窗口 buffer
        if wmid == s:wmid_main | continue | endif

        let winid = bufwinid(bufnr)

        " 跳过未显示的 buffer
        if winid <= 0 | continue | endif

        call s:wm_set_winid(wmid, winid)
    endfor

    echom '✅ WM reload completed, winids: ' . string(s:winids)
endfunction

" =============================================================================
" 窗口更新逻辑
" =============================================================================

" 更新窗口状态（在 BufRead 时调用）
" 功能：
"   1. 检查 Buffer 是否被错误分配到侧边栏
"   2. 为侧边栏 Buffer 分配正确的窗口
"   3. 处理多文档窗口类型（help/man 每个文档一个新窗口）
" 触发时机：
"   - BufRead 事件（主触发）
"   - FileType 事件（nerdtree/tagbar/Outline 专用）
function! s:wm_update() abort
    if s:wm_debug | call s:wminfo() | endif

    let bufnr = bufnr('%')
    let bufname = bufname(bufnr)
    let winid = bufwinid(bufname)

    let wmid = s:wmid(bufnr)

    " 在主窗口打开 help/doc 文件
    if wmid == s:wmid_docs && winid == s:winids[0]
        echom '✅ Open ' . bufname . ' in main window'
        return
    endif

    " 1. sticky buffer: 检查 Buffer 是否被错误分配
    if buflisted(bufnr)
        let current = s:wmid_winid()
        if current > s:wmid_main && wmid != current
            echom '⚠️ wrong window ' . wmid . '(expected) vs ' . current . '(current), bufname:' . bufname . 'winids: ' . string(s:winids)
            if bufwinnr('#') > 0
                call s:wm_settle_bufnr(bufnr)
            else
                call s:wm_move_bufnr('%')
            endif
        endif
    endif

    " 2. 为侧边栏窗口分配 winid
    if wmid > 0
        " 侧边栏 Buffer 不列入 buffer 列表
        setlocal nobuflisted
        setlocal buftype=nofile

        " 多文档窗口类型（help/man/doc）：共享一个窗口
        if wmid == s:wmid_docs && s:winids[wmid] > 0
            " 已有窗口，移动 buffer 过去
            call s:wm_settle_bufnr(bufnr)
            echom '⚠️ alt window ' . wmid . ' => ' . s:winids[wmid] . ', winids: ' . string(s:winids)
        elseif s:winids[wmid] > 0
            " 直接替换 winid
            call s:wm_set_winid(wmid, winid)
            echom '⚠️ set window ' . wmid . ' == ' . winid . ', winids: ' . string(s:winids)
        elseif winid != s:winids[wmid]
            call s:wm_set_winid(wmid, winid)
            echom '⚠️ new window ' . wmid . ' == ' . winid . ', winids: ' . string(s:winids)

            " 调整窗口大小
            if wmid == s:wmid_docs || wmid == s:wmid_foot
                exe 'resize ' . s:wm_height
            else
                exe 'vertical resize ' . s:wm_width
            endif
        endif

    endif
endfunction

function! s:wm_update_winid() abort
    let wmid = s:wmid('%')
    let winid = win_getid()

    " 不在这里更新 main 窗口 winid
    if wmid == s:wmid_main | return | endif
    if winid == s:winids[0] | return | endif

    call s:wm_set_winid(wmid, winid)
endfunction

function! s:wm_on_winclosed() abort
    let wmid = s:wmid_winid()

    if wmid == s:wmid_main
        echom '❌ FIXME: main window closed'
    elseif wmid > s:wmid_main
        call s:wm_set_winid(wmid, 0)
        echom '💡 window ' .. wmid .. ' closed, winids: ' . string(s:winids)
    endif
endfunction

function! s:wm_on_winopened() abort
  call s:wm_update()
  autocmd BufWinLeave <buffer> ++once call s:wm_on_winclosed()
endfunction

" =============================================================================
" Buffer 操作命令
" =============================================================================

" 关闭当前 Buffer
" 逻辑：
"   - 侧边栏窗口（wmid > 0）：直接 quit 关闭窗口
"   - 主窗口（wmid = 0）：切换到前一个 buffer，删除当前 buffer
" 注意：如果是最后一个 buffer，提示用户使用 :qa 退出
function! s:wm_buffer_close(bufnr = '') abort
    let bufnr = bufnr(a:bufnr) " 保存 bufnr
    let wmid = s:wmid(bufnr)
    if wmid > s:wmid_main
        " 侧边栏窗口：直接关闭
        exe 'quit'
    elseif win_getid() == s:winids[0]
        " 主窗口：关闭 buffer
        " 查找其他 listed buffer
        let li = filter(range(1, bufnr('$')), 'buflisted(v:val) == 1 && v:val != ' . bufnr)
        if len(li) > 0
            " 切换到前一个 buffer 并删除当前 buffer
            exe 'bprev | bdelete ' . bufnr
        else
            " 最后一个 buffer：提示用户使用 :qa
            echom "⚠️ Last buffer, close it with :qa"
        endif
    else
        " 特殊情况：不在任何一个窗口, 比如在 Telescope 中关闭 buffer
        exe 'buffer # | bdelete ' . bufnr
    endif
endfunction

" 切换到下一个 Buffer
" 逻辑：如果当前在侧边栏，先切换到主窗口，再切换到下一个 buffer
function! s:wm_buffer_next() abort
    if s:wmid_winid() > 0 | call s:wm_wincmd_wmid(0) | endif
    exe 'bnext'
endfunction

" 切换到上一个 Buffer
" 逻辑：如果当前在侧边栏，先切换到主窗口，再切换到上一个 buffer
function! s:wm_buffer_prev() abort
    if s:wmid_winid() > 0 | call s:wm_wincmd_wmid(0) | endif
    exe 'bprev'
endfunction

" =============================================================================
" 自动命令组
" =============================================================================

augroup PrettyWindowsSettings
    autocmd!

    " 主窗口管理：检测 main 窗口关闭并恢复
    " 触发时机：创建新 buffer 时（BufNew）
    " 原因：Can't split a window while closing another - 选择打开 buffer 时的事件
    autocmd BufNew      * call s:wm_main()

    " 窗口更新：检查 Buffer 分配
    " 触发时机：显示 buffer 时（BufRead & BufWinEnter）
    " 原因：
    "   - BufRead 调用次数少，又刚好够用
    "   - BufWinEnter 时才能获取到准确的 winid
    autocmd BufRead     * call s:wm_update()
    autocmd BufWinEnter * call s:wm_update_winid()

    " 特殊处理：文件浏览器和符号大纲在创建时更新窗口映射
    autocmd FileType    NvimTree call s:wm_on_winopened()
    autocmd FileType    ale-info call s:wm_on_winopened()
    autocmd FileType    nerdtree call s:wm_on_winopened()
    autocmd FileType    tagbar   call s:wm_on_winopened()
    autocmd FileType    Outline  call s:wm_on_winopened()

    " Terminal 自动进入插入模式
    "autocmd BufEnter    term://* startinsert
    "autocmd BufLeave    term://* stopinsert

    " 文件浏览器和符号大纲调用光标切换函数
    autocmd FileType    nerdtree,NvimTree,tagbar,Outline call PrettyCursorToggle()
augroup END

" 调试快捷键（启用 s:wm_debug 时使用）
" if s:wm_debug | nnoremap <C-Y> :call <sid>wminfo()<cr> | endif

" =============================================================================
" 用户命令
" =============================================================================

" 调试命令
command! -nargs=0 PrettyBufferInfo      call <sid>wminfo()

" 关闭当前 Buffer（智能关闭：侧边栏直接关闭，主窗口切换 buffer）
command! -nargs=0 PrettyBufferClose     call <sid>wm_buffer_close()

" 切换到下一个 Buffer（自动回到主窗口）
command! -nargs=0 PrettyBufferNext      call <sid>wm_buffer_next()

" 切换到上一个 Buffer（自动回到主窗口）
command! -nargs=0 PrettyBufferPrev      call <sid>wm_buffer_prev()

" 重载窗口 ID 映射（窗口状态混乱时使用）
command! -nargs=0 PrettyBuffersReload   call <sid>wm_reload()

" 注册到 pretty.nvim 的重载命令列表
let g:pretty_reload_commands += [ 'PrettyBuffersReload' ]

" =============================================================================
" 缓冲区导航（保持与 Denite 一致的快捷键）
" =============================================================================

" --- 下一个缓冲区 ---
" Normal 模式：C-n
nnoremap <silent> <C-n>      :PrettyBufferNext<cr>
" Terminal 模式：C-n
tnoremap <silent> <C-n>      <C-\><C-N>:bnext<cr>

" --- 上一个缓冲区 ---
" Normal 模式：C-p
nnoremap <silent> <C-p>      :PrettyBufferPrev<cr>
" Terminal 模式：C-p
tnoremap <silent> <C-p>      <C-\><C-N>:bprev<cr>

" --- 关闭缓冲区 ---
" Normal 模式：C-q
nnoremap <silent> <C-q>      :PrettyBufferClose<cr>
" Terminal 模式：C-q
tnoremap <silent> <C-q>      <C-\><C-N>:PrettyBufferClose<cr>

" --- 切换窗口 ---
" Normal 模式：C-j/k/h/l
nnoremap <silent> <C-j>      <C-W>j
nnoremap <silent> <C-k>      <C-W>k
nnoremap <silent> <C-h>      <C-W>h
nnoremap <silent> <C-l>      <C-W>l
" Terminal 模式：C-j/k/h/l
tnoremap <silent> <C-j>      <C-\><C-N><C-W>j
tnoremap <silent> <C-k>      <C-\><C-N><C-W>k
tnoremap <silent> <C-h>      <C-\><C-N><C-W>h
tnoremap <silent> <C-l>      <C-\><C-N><C-W>l
