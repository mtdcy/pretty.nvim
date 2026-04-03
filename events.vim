
" =============================================================================
" FILE: events.vim - Neovim 自动命令事件调试
" 用途：调试时查看事件触发顺序
" 用法：启动 Neovim 时加载此文件，日志写入 events.log
" =============================================================================

" 日志文件路径
let s:events_log = expand('<sfile>:h') . '/events.log'

" 清空日志文件（每次重新加载时重置）
call writefile([], s:events_log)

" 写日志函数
function! s:log(msg) abort
    call writefile([a:msg], s:events_log, 'a')
endfunction

" =============================================================================
" 打开文件时的完整事件流程
" =============================================================================
"
" 场景 1：启动 Neovim 并打开文件（nvim file.txt）
" ─────────────────────────────────────────────────────────────
" 1. VimEnter       - Vim 启动完成（GUI 初始化完成，准备处理文件）
" 2. BufAdd         - 将 buffer 添加到 buffer 列表
" 3. BufNew         - 创建新 buffer（如果文件不存在）
"    或
"    BufReadPre     - 准备读取已存在文件
" 4. BufReadPost    - 文件读取完成
" 5. BufEnter       - 进入该 buffer
" 6. BufWinEnter    - buffer 在窗口中显示
" 7. FileType       - 检测并设置 filetype（如果未设置）
" 8. Syntax         - 加载语法高亮（如果未设置）
" 9. WinEnter       - 进入该窗口
"
" 场景 2：在运行中的 Neovim 打开文件（:e file.txt）
" ─────────────────────────────────────────────────────────────
" 1. BufLeave       - 离开当前 buffer
" 2. BufWinLeave    - buffer 从当前窗口移除
" 3. WinLeave       - 离开当前窗口
" 4. BufAdd         - 将新 buffer 添加到 buffer 列表
" 5. BufNew         - 创建新 buffer（如果文件不存在）
"    或
"    BufReadPre     - 准备读取已存在文件
" 6. BufReadPost    - 文件读取完成
" 7. BufEnter       - 进入新 buffer
" 8. BufWinEnter    - buffer 在新窗口中显示
" 9. FileType       - 检测并设置 filetype
" 10. Syntax        - 加载语法高亮
" 11. WinEnter      - 进入新窗口
"
" 场景 3：打开不存在的文件（:e newfile.txt）
" ─────────────────────────────────────────────────────────────
" 1. BufLeave       - 离开当前 buffer
" 2. BufWinLeave    - buffer 从当前窗口移除
" 3. WinLeave       - 离开当前窗口
" 4. BufAdd         - 将新 buffer 添加到 buffer 列表
" 5. BufNew         - 创建新 buffer（文件不存在）
" 6. BufNewFile     - 新文件即将创建（首次写入时触发）
" 7. BufEnter       - 进入新 buffer
" 8. BufWinEnter    - buffer 在窗口中显示
" 9. FileType       - 检测并设置 filetype
" 10. WinEnter      - 进入新窗口
"
" =============================================================================
" 关闭文件时的完整事件流程
" =============================================================================
"
" 场景 1：关闭 buffer（:bdelete 或 :bd）
" ─────────────────────────────────────────────────────────────
" 1. BufLeave       - 离开当前 buffer
" 2. BufWinLeave    - buffer 从窗口移除
" 3. WinLeave       - 离开当前窗口（如果切换到其他窗口）
" 4. BufHidden      - buffer 被隐藏（从窗口移除但仍在 buffer 列表）
" 5. BufUnload      - buffer 被卸载（内容从内存清除）
" 6. BufDelete      - buffer 被删除（从 buffer 列表移除）
" 7. BufWipeout     - buffer 被彻底清除（所有信息删除，不可恢复）
" 8. WinEnter       - 进入新窗口（如果有关联窗口关闭）
" 9. WinClosed      - 窗口被关闭（如果这是最后一个显示该 buffer 的窗口）
"
" 场景 2：关闭窗口（:quit 或 :q）
" ─────────────────────────────────────────────────────────────
" 1. QuitPre        - 即将退出（在检查未保存修改之前）
" 2. BufLeave       - 离开当前 buffer
" 3. BufWinLeave    - buffer 从窗口移除
" 4. WinLeave       - 离开当前窗口
" 5. BufHidden      - buffer 被隐藏
" 6. WinClosed      - 窗口被关闭
" 7. ExitPre        - Vim 即将退出（在写入 viminfo 之前）
" 8. VimLeavePre    - Vim 即将退出（在写入 viminfo 之后）
" 9. VimLeave       - Vim 退出完成
"
" 场景 3：退出最后一个窗口（:qa 或 :wq）
" ─────────────────────────────────────────────────────────────
" 1. QuitPre        - 即将退出
" 2. BufLeave       - 离开当前 buffer
" 3. BufWinLeave    - buffer 从窗口移除
" 4. WinLeave       - 离开当前窗口
" 5. BufHidden      - buffer 被隐藏
" 6. WinClosed      - 窗口被关闭
" 7. ExitPre        - Vim 即将退出
" 8. VimLeavePre    - Vim 即将退出（viminfo 已写入）
" 9. VimLeave       - Vim 退出完成
"
" =============================================================================
" 事件详细说明
" =============================================================================
"
" 【Vim 生命周期事件】
" VimEnter      - Vim 启动完成，准备就绪
" VimLeavePre   - Vim 即将退出（viminfo 写入后）
" VimLeave      - Vim 退出完成
" ExitPre       - Vim 即将退出（viminfo 写入前）
"
" 【窗口事件】
" WinEnter      - 进入窗口（焦点切换到该窗口）
" WinLeave      - 离开窗口（焦点从该窗口移开）
" WinNew        - 创建新窗口
" WinClosed     - 关闭窗口（窗口 ID 仍可用）
"
" 【Buffer 创建/读取事件】
" BufNew        - 创建新 buffer（buffer 已创建但内容为空）
" BufAdd        - 将 buffer 添加到 buffer 列表
" BufNewFile    - 新文件即将创建（首次写入时触发）
" BufReadPre    - 读取文件前（buffer 已创建，内容未加载）
" BufRead       - 读取文件（同 BufReadPost）
" BufReadPost   - 文件读取完成（buffer 已加载内容）
"
" 【Buffer 切换事件】
" BufEnter      - 进入 buffer（焦点切换到该 buffer）
" BufLeave      - 离开 buffer（焦点从该 buffer 移开）
" BufWinEnter   - buffer 在窗口中显示
" BufWinLeave   - buffer 从窗口移除
"
" 【Buffer 写入事件】
" BufWritePre   - 写入文件前
" BufWrite      - 写入文件（同 BufWritePost）
" BufWritePost  - 写入文件完成
"
" 【Buffer 删除事件】
" BufHidden     - buffer 被隐藏（从窗口移除但仍在内存）
" BufUnload     - buffer 被卸载（内容从内存清除）
" BufDelete     - buffer 被删除（从 buffer 列表移除）
" BufWipeout    - buffer 被彻底清除（不可恢复）
"
" 【其他事件】
" QuitPre       - 即将退出窗口/文件（在检查未保存修改前）
" FileType      - 检测到 filetype
" Syntax        - 加载语法高亮
"
" 【Command-line 模式事件】
" CmdlineEnter  - 进入命令行模式（按 : / ? 时）
" CmdlineLeave  - 离开命令行模式（执行/取消后）
" CmdlineChanged - 命令行内容改变时（每次按键触发）
"
" =============================================================================
" Command-line 模式事件详解
" =============================================================================
"
" 触发场景：
" ─────────────────────────────────────────────────────────────
" 1. 按 : 进入命令模式
"    CmdlineEnter (cmdtype=:) → (CmdlineChanged)* → CmdlineLeave
"
" 2. 按 / 进入搜索模式（向前搜索）
"    CmdlineEnter (cmdtype=/) → (CmdlineChanged)* → CmdlineLeave
"
" 3. 按 ? 进入搜索模式（向后搜索）
"    CmdlineEnter (cmdtype=?) → (CmdlineChanged)* → CmdlineLeave
"
" 4. 按 @ 进入 input 模式（用于 input() 函数）
"    CmdlineEnter (cmdtype=@) → (CmdlineChanged)* → CmdlineLeave
"
" 5. 按 > 进入 input 模式（用于 input() 函数，带继续提示符）
"    CmdlineEnter (cmdtype=>) → (CmdlineChanged)* → CmdlineLeave
"
" cmdtype 参数说明：
"   : - 命令模式（:edit、:set 等）
"   / - 向前搜索（/pattern）
"   ? - 向后搜索（?pattern）
"   @ - input() 输入
"   > - input() 输入（带继续提示符）
"   = - 表达式寄存器（Ctrl+R =）
"
" CmdlineChanged 触发时机：
"   - 每次在命令行中按键时触发
"   - 可用于实现命令行自动补全、实时验证等
"
" =============================================================================
" 事件触发顺序总结
" =============================================================================
"
" 打开文件：
"   VimEnter → BufAdd → (BufNew | BufReadPre) → BufReadPost → BufEnter → BufWinEnter → WinEnter
"
" 关闭 buffer：
"   BufLeave → BufWinLeave → BufHidden → BufUnload → BufDelete → BufWipeout
"
" 关闭窗口：
"   QuitPre → BufLeave → BufWinLeave → WinLeave → WinClosed
"
" 退出 Vim：
"   QuitPre → BufLeave → BufWinLeave → WinLeave → WinClosed → ExitPre → VimLeavePre → VimLeave
"
" 进入/离开 Command-line 模式：
"   CmdlineEnter → (CmdlineChanged)* → CmdlineLeave
"
" =============================================================================

augroup events
    autocmd!

    " ==========================================================================
    " Vim 生命周期事件
    " ==========================================================================
    autocmd VimEnter     * call s:log("== VimEnter      " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd VimLeavePre  * call s:log("== VimLeavePre   " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd VimLeave     * call s:log("== VimLeave      " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd ExitPre      * call s:log("== ExitPre       " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))

    " ==========================================================================
    " 窗口事件
    " ==========================================================================
    autocmd WinEnter     * call s:log("== WinEnter      " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd WinLeave     * call s:log("== WinLeave      " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd WinNew       * call s:log("== WinNew        " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd WinClosed    * call s:log("== WinClosed     " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))

    " ==========================================================================
    " Buffer 创建/读取事件
    " ==========================================================================
    autocmd BufAdd       * call s:log("== BufAdd        " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufNew       * call s:log("== BufNew        " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufNewFile   * call s:log("== BufNewFile    " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufReadPre   * call s:log("== BufReadPre    " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufRead      * call s:log("== BufRead       " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufReadPost  * call s:log("== BufReadPost   " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))

    " ==========================================================================
    " Buffer 切换事件
    " ==========================================================================
    autocmd BufEnter     * call s:log("== BufEnter      " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufLeave     * call s:log("== BufLeave      " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufWinEnter  * call s:log("== BufWinEnter   " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufWinLeave  * call s:log("== BufWinLeave   " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))

    " ==========================================================================
    " Buffer 写入事件
    " ==========================================================================
    autocmd BufWritePre  * call s:log("== BufWritePre   " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufWrite     * call s:log("== BufWrite      " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufWritePost * call s:log("== BufWritePost  " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))

    " ==========================================================================
    " Buffer 删除事件
    " ==========================================================================
    autocmd BufHidden    * call s:log("== BufHidden     " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufUnload    * call s:log("== BufUnload     " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufDelete    * call s:log("== BufDelete     " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufWipeout   * call s:log("== BufWipeout    " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))

    " ==========================================================================
    " Command-line 模式事件（进出命令行模式）
    " ==========================================================================
    " autocmd CmdlineEnter * call s:log("== CmdlineEnter  " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    " autocmd CmdlineLeave * call s:log("== CmdlineLeave   " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    " autocmd CmdlineChanged * call s:log("== CmdlineChanged" . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))

    " ==========================================================================
    " 其他事件
    " ==========================================================================
    autocmd QuitPre      * call s:log("== QuitPre       " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufFilePre   * call s:log("== BufFilePre    " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))
    autocmd BufFilePost  * call s:log("== BufFilePost   " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>'))

    " ==========================================================================
    " 被注释的事件（Cmd 事件用于完全自定义读写行为）
    " ==========================================================================
    " autocmd BufWriteCmd  * call s:log("== BufWriteCmd   " . bufname()
    " autocmd BufReadCmd   * call s:log("== BufReadCmd    " . bufname()
augroup END
