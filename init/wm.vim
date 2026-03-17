"=============================================================================
" FILE: wm.vim - Window Manager for pretty.nvim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================
" 说明：
"   本文件负责 Neovim 窗口管理，包括：
"   1. 侧边栏窗口管理（NERDTree/Tagbar/CodeCompanion 等）
"   2. 主窗口（main window）保护与恢复
"   3. Buffer 与窗口的智能分配
"   4. 互斥窗口管理（如 Tagbar vs CodeCompanion）
"
" 窗口布局：
"   +----------+------------------+----------+
"   |          |                  |          |
"   | leftbar  |     main         | rightbar |
"   | (1)      |     (0)          | (4)      |
"   |          |                  |          |
"   +----------+------------------+----------+
"   | headbar (2) / footbar (3)              |
"   +----------------------------------------+
"
" 窗口 ID 映射：
"   g:winids = [main, leftbar, headbar, footbar, rightbar]
"              [  0  ,   1   ,   2    ,   3    ,    4    ]
"
" 关键修复：
"   - 使用 BufDelete 而非 WinClosed 检测 main 窗口关闭
"   - 避免使用 bdelete 删除最后一个 buffer（会导致窗口关闭）
"   - 主窗口关闭时自动恢复，防止侧边栏窗口连锁关闭
"=============================================================================

" =============================================================================
" 全局配置
" =============================================================================

" 调试模式：1 = 启用，0 = 禁用
let g:wm_debug  = 0

" 侧边栏高度（水平窗口：help/quickfix）
" 最小 12 行，最大为当前窗口高度的 1/4
let g:wm_height = min([12, winheight(0) / 4])

" 侧边栏宽度（垂直窗口：NERDTree/Tagbar）
" 最小为当前窗口宽度的 1/4，最大为 1/2（但不超过 40 列）
let g:wm_width  = max([min([40, winwidth(0) / 2]), winwidth(0) / 4])

" 重置 wildignore（使用默认值）
set wildignore&

" 不使用 equalalways（避免窗口大小自动调整）
set noequalalways

" 命令行高度设为 1（默认值）
set cmdheight=1

" =============================================================================
" 窗口 ID 管理
" =============================================================================

" 窗口 ID 数组：[main, leftbar, headbar, footbar, rightbar]
" 初始值：当前窗口设为 main (0)，其他设为 0（未分配）
let g:winids = [ win_getid(), 0, 0, 0, 0 ]

" 窗口类型映射：
"   1 - leftbar  (左侧栏): NERDTree
"   2 - headbar  (顶部栏): help/man 文档
"   3 - footbar  (底部栏): quickfix/location list
"   4 - rightbar (右侧栏): Tagbar 或 CodeCompanion（互斥）

" --- 窗口 ID 查询函数 ---

" 根据窗口 ID 查找 wmid
" 参数：winid - 窗口 ID
" 返回：wmid（0-4 表示窗口类型，-1 表示未分类）
function! s:wmid(winid = '') abort
    if a:winid == ''
        return index(g:winids, win_getid())
    else
        return index(g:winids, a:winid)
    endif
endfunction

" 根据窗口号查找 wmid
" 参数：winnr - 窗口号
" 返回：wmid（0-4 表示窗口类型，-1 表示未分类）
function! s:wmid_winnr(winnr = '') abort
    if a:winnr == ''
        return index(g:winids, win_getid())
    else
        return index(g:winids, win_getid(a:winnr))
    endif
endfunction

" 根据 Buffer 类型查找期望的 wmid
" 参数：type - Buffer 类型字符串
" 返回：wmid（1-4 表示侧边栏，-1 表示主窗口）
function! s:wmid_filetype(type) abort
    if a:type ==? 'nerdtree'
        return 1
    elseif a:type ==? 'docs'
        return 2
    elseif a:type ==? 'quickfix'
        return 3
    elseif a:type ==? 'tagbar' || a:type ==? 'codecompanion'
        return 4  " rightbar: tagbar 或 codecompanion（互斥）
    endif
    return -1
endfunction

" 根据 wmid 获取窗口 ID
" 参数：wmid - 窗口类型 ID (0-4)
" 返回：窗口 ID（>0 表示有效，<=0 表示无效）
function! s:wm_winid(wmid) abort
    return g:winids[a:wmid]
endfunction

" 设置窗口 ID
" 参数：wmid - 窗口类型 ID, winid - 窗口 ID
function! s:wm_winid_set(wmid, winid) abort
    let g:winids[a:wmid] = a:winid
endfunction

" 根据 wmid 获取窗口号（winnr）
" 参数：wmid - 窗口类型 ID
" 返回：窗口号（>0 表示有效，0 表示窗口不存在）
function! s:wm_winnr(wmid) abort
    return win_id2win(s:wm_winid(a:wmid))
endfunction

" =============================================================================
" Buffer 类型识别
" =============================================================================

" 检查 Buffer 类型，返回对应的侧边栏类型
" 参数：bufnr - 缓冲区号
" 返回：类型字符串（'nerdtree'/'tagbar'/'codecompanion'/'docs'/'quickfix'），空字符串表示主窗口
function! s:wmtype(bufnr) abort
    " 获取文件类型
    let ftype = getbufvar(bufnr(a:bufnr), '&ft')

    " 主窗口检查：如果在主窗口中，允许编辑任何文件
    if winnr() == s:wm_winnr(0)
        return ''
    elseif ftype ==? 'nerdtree'
        return 'nerdtree'
    elseif ftype ==? 'tagbar'
        return 'tagbar'
    elseif ftype ==? 'codecompanion'
        return 'codecompanion'
    elseif ftype ==? 'help' || ftype ==? 'man' || ftype =~? '\.*doc' || ftype ==? 'ale-info'
        return 'docs'
    elseif ftype ==? 'qf' || getbufvar(bufnr(a:bufnr), '&bt') ==? 'quickfix'
        return 'quickfix'
    endif
    return ''
endfunction

" =============================================================================
" 窗口操作函数
" =============================================================================

" 切换到指定窗口
" 参数：wmid - 窗口类型 ID
function! s:window(wmid) abort
    exe s:wm_winnr(a:wmid) . 'wincmd w'
endfunction

" 移动 Buffer 到正确的窗口
" 参数：buf - 缓冲区号或名称
" 用途：当 Buffer 被错误地分配到侧边栏时，将其移回主窗口
function! s:wm_move(buf) abort
    let bufnr = bufnr(a:buf)
    " 切换到备用 buffer（避免删除当前 buffer）
    exe 'buffer#'
    " 查找包含该 buffer 的其他窗口
    let li = filter(range(1, winnr('$')), 'v:val != winnr() && winbufnr(v:val)==' . bufnr)
    " 切换到正确的窗口
    if len(li) | call s:window(s:wmid_winnr(li[0]))
    else       | call s:window(0)
    endif
    " 将 buffer 加载到当前窗口
    exe 'buffer ' . bufnr
endfunction

" 创建侧边栏窗口（如果不存在）
" 参数：wmid - 窗口类型 ID (1-4)
" 用途：为侧边栏 Buffer 预留窗口位置
function! s:wm_create(wmid) abort
    if a:wmid > 0 && s:wm_winid(a:wmid) <= 0
        let saved = winnr()
        call s:window(0)
        if a:wmid == 1
            Explorer
        elseif a:wmid == 2
            help
        elseif a:wmid == 3
            lopen
        elseif a:wmid == 4
            " rightbar: tagbar 或 codecompanion（由各自插件创建）
            " 此函数只预留窗口位置
        endif
        call s:wm_winid_set(a:wmid, win_getid())
        exe saved 'wincmd w'
    endif
endfunction

" 将窗口安置到正确位置
" 参数：wmid - 窗口类型 ID
" 用途：当侧边栏 Buffer 在新窗口打开时，将其移动到预留的窗口位置
function! s:wm_settle(wmid) abort
    call s:wm_create(a:wmid)
    let bufnr = bufnr('%')
    exe 'wincmd c'
    call s:window(a:wmid)
    exe 'buffer ' . bufnr
endfunction

" =============================================================================
" 调试信息
" =============================================================================

" 显示当前窗口和 Buffer 的详细信息（调试用）
function! s:wminfo() abort
    echo '== wmid:' . s:wmid() . '|wmtype:' . s:wmtype('%')
                \ . '|winid:' . win_getid()
                \ . '|winnr:' . winnr() . '#' . winnr('$')
                \ . '|type:' . win_gettype() . '|winbufnr:' . winbufnr(0)
                \ . '|list:' . &list . '|cpoptionprettifier#wm#' . &cpoptions
                \ . '|bufname:' . bufname('%') . '|alt:' . bufname('#') . ''
                \ . '|bufnr:' . bufnr('%') . '#' . bufnr('$')
                \ . '|bufwinr:' . bufwinnr('%')
                \ . '|ft:' . &ft . '|bt:' . &bt . '|mod:' . &mod . '|modi:'. &modifiable
                \ . '|hide:' . &bufhidden . '|buflisted:' . &buflisted . '|swapfile:' . &swapfile
endfunction

" =============================================================================
" 主窗口管理（关键修复）
" =============================================================================

" 检查并恢复主窗口
" 触发时机：BufDelete 事件
" 修复问题：使用 bdelete 删除最后一个 buffer 会导致窗口关闭
function! s:wm_main() abort
    let winid = win_getid()

    " 检查 main 窗口状态
    " 注意：要是 buffer 是在外部被删除的，winid 还被保存着，所以检查 winnr (1-based)
    if s:wm_winnr(0) > 0 | return | endif

    " 这种情况主要发生在唯一的 buffer 被外部命令删除
    echo '== main window closed, take ' .. winid

    " main 窗口不存在，sp|vsp 一个很复杂，直接抢一个窗口
    " 清除旧的 winid 记录
    call s:wm_winid_set(s:wmid(winid), 0)
    " 将当前窗口设为新的 main 窗口
    call s:wm_winid_set(0, winid)

    " 创建空 buffer（关键：不然后续 wmtype 判断会失效）
    enew
endfunction

" =============================================================================
" 窗口更新逻辑
" =============================================================================

" 更新窗口状态（在 BufEnter 时调用）
" 功能：
"   1. 检查 Buffer 是否被错误分配到侧边栏
"   2. 为侧边栏 Buffer 分配正确的窗口
"   3. 处理互斥窗口（Tagbar vs CodeCompanion）
function! s:wm_update() abort
    if g:wm_debug | call s:wminfo() | endif
    let type = s:wmtype('%')

    " 1. sticky buffer: 检查 Buffer 是否被错误分配
    let wmid = s:wmid_filetype(type)
    if s:wmid() > 0 && wmid != s:wmid()
        echo '== buffer ' . bufname('%') . ' window expect ' . wmid . ' but current is ' . s:wmid()
        if bufwinnr('#') > 0
            echo '== settle window'
            call s:wm_settle(wmid)
        else
            echo '== move buffer'
            call s:wm_move('%')
        endif
    endif

    " 2. 为侧边栏窗口分配 winid
    if wmid > 0
        " 侧边栏 Buffer 不列入 buffer 列表
        setlocal nobuflisted
        let winid = bufwinid('%')

        " 多文档窗口类型（help/man/doc）：每个文档一个新窗口
        if winid != s:wm_winid(wmid)
            " 如何处理新窗口？
            if s:wm_winid(wmid) > 0
                " 已有窗口，移动 buffer 过去
                echo '== move buffer to window ' . s:wm_winid(wmid)
                call s:wm_settle(wmid)
            else
                " 新窗口类型，记录 winid
                echo '== set new window ' . winid . ' for type ' . type
                call s:wm_winid_set(wmid, winid)
                " 调整窗口大小
                if type ==? 'docs' || type ==? 'quickfix'
                    exe 'resize ' . g:wm_height
                else
                    exe 'vertical resize ' . g:wm_width
                endif
            endif
        endif

        " rightbar: Tagbar 和 CodeCompanion 互斥
        if type ==? 'tagbar' && s:wm_winid(4) > 0
            " 检查是否存在 CodeCompanion 窗口，存在则关闭
            for bufnr in range(1, bufnr('$'))
                if getbufvar(bufnr, '&ft') ==? 'codecompanion'
                    let winid = bufwinid(bufnr)
                    if winid > 0 && winid != win_getid()
                        echo "== rightbar: closing codecompanion for tagbar"
                        call win_execute(winid, 'quit')
                        break
                    endif
                endif
            endfor
        elseif type ==? 'codecompanion' && s:wm_winid(4) > 0
            " 检查是否存在 Tagbar 窗口，存在则关闭
            for bufnr in range(1, bufnr('$'))
                if getbufvar(bufnr, '&ft') ==? 'tagbar'
                    let tagbar_winid = bufwinid(bufnr)
                    if tagbar_winid > 0 && tagbar_winid != win_getid()
                        echo "== rightbar: closing tagbar for codecompanion"
                        call win_execute(tagbar_winid, 'quit')
                        break
                    endif
                endif
            endfor
        endif
    endif
endfunction

" =============================================================================
" Buffer 操作命令
" =============================================================================

" 关闭当前 Buffer
" 逻辑：
"   - 侧边栏窗口：直接 quit
"   - 主窗口：切换到其他 buffer，删除当前 buffer
" 注意：不删除最后一个 buffer（避免窗口关闭）
function! s:close() abort
    if win_getid() != s:wm_winid(0)
        " 侧边栏窗口：直接关闭
        exe 'quit'
    else
        " 主窗口：关闭 buffer
        let bufnr = bufnr('%') " 保存 bufnr
        " 查找其他 listed buffer
        let li = filter(range(1, bufnr('$')), 'buflisted(v:val) == 1 && v:val != ' . bufnr)
        if len(li) > 0
            " 切换到前一个 buffer 并删除当前 buffer
            exe 'bprev | bdelete ' . bufnr
        else
            " 最后一个 buffer：提示用户使用 :qa
            echo "Last buffer, close it with :qa"
        endif
    endif
endfunction

" 切换到下一个 Buffer
function! s:next() abort
    call s:window(0)
    exe 'bnext'
endfunction

" 切换到上一个 Buffer
function! s:prev() abort
    call s:window(0)
    exe 'bprev'
endfunction

" =============================================================================
" 自动命令组
" =============================================================================

augroup WM
    autocmd!

    " 主窗口管理：检测 main 窗口关闭并恢复
    " 关键：使用 BufDelete 而非 WinClosed
    autocmd BufDelete   * call s:wm_main()

    " 窗口更新：检查 Buffer 分配
    autocmd BufEnter    * call s:wm_update()

    " 特殊处理：NERDTree 和 Tagbar 在创建时设置 eventignore
    autocmd FileType    nerdtree,tagbar,codecompanion call s:wm_update()

    " Terminal 自动进入插入模式
    autocmd BufEnter    term://* startinsert
    autocmd BufLeave    term://* stopinsert
augroup END

" 调试快捷键（启用 g:wm_debug 时使用）
" if g:wm_debug | nnoremap <C-Y> :call <sid>wminfo()<cr> | endif

" =============================================================================
" 用户命令
" =============================================================================

" 关闭当前 Buffer
command! -nargs=0 BufferClose call <sid>close()

" 下一个 Buffer
command! -nargs=0 BufferNext  call <sid>next()

" 上一个 Buffer
command! -nargs=0 BufferPrev  call <sid>prev()
