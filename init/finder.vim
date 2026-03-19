" =============================================================================
" Telescope Finder 配置
" =============================================================================
" 说明：
"   本文件负责 Telescope 的按键绑定和命令定义，包括：
"   1. g:finder 菜单配置（扁平化设计）
"   2. Telescope 窗口设置（通过 autocmd）
"   3. 全局快捷键绑定（Finder/Buffer/Search 等）
"
" 设计理念：
"   - 保持与 Denite 一致的功能和按键绑定
"   - 所有菜单项在同一层级，无需多级导航
"   - 按键绑定在 finder.vim 中统一定义
" =============================================================================

" =============================================================================
" 全局设置
" =============================================================================

" Finder 提示信息
let g:finder_tips = "⌨️ /: 开始搜索，j/k: 选择, Enter: 打开, Q: 退出 ⌨️"

" Prompt 窗口 bufnr（用于后续操作）
let g:finder_bufnr = 0

" =============================================================================
" Finder 菜单配置（扁平化设计，所有菜单项在同一层级）
" =============================================================================
" 格式：[Text, Keymap, Command]
"   - Text: 显示文本（靠左）
"   - Keymap: 快捷键（靠右）
"   - Command: 执行的命令
"   - Close: 关闭当前窗口

let g:finder = {
            \ 'items': [
            \   ['1. Finder         ', '(CTRL-o)', 'Finder'                              , v:false ] ,
            \   ['2. Buffer         ', '(CTRL-e)', 'Buffer'                              , v:false ] ,
            \   ['3. Search         ', '(CTRL-g)', 'Search'                              , v:false ] ,
            \   ['4. Chat           ', '(F5)    ', 'OpenChat'                            , v:false ] ,
            \   ['5. Format         ', '(F8)    ', 'ALEFix'                              , v:true  ] ,
            \   ['6. Explorer       ', '(F9)    ', 'ExplorerFocus'                       , v:true  ] ,
            \   ['7. Taglist        ', '(F10)   ', 'TaglistFocus'                        , v:true  ] ,
            \   ['8. LazyGit        ', '(F12)   ', 'GitOpen'                             , v:true  ] ,
            \   ['9. Close          ', '(CTRL-w)', 'BufferClose'                         , v:false ] ,
            \   ['.. Nerdy          ', '        ', 'NerdySearch'                         , v:false ] ,
            \   ['.. Emoji          ', '        ', 'EmojiSearch'                         , v:false ] ,
            \   ['.. Quit           ', '(:qa)   ', 'confirm quit'                        , v:true  ] ,
            \   ['?. Help           ', '        ', 'edit ' . g:pretty_home . '/README.md', v:true  ] ,
            \ ],
            \ }

" 加载 Telescope 配置文件（必须在 g:finder 定义之后）
luafile <sfile>:h/telescope.lua

" =============================================================================
" 命令定义
" =============================================================================

" --- 主菜单命令 ---
" 打开 Finder 主菜单
" 注意：telescope.lua 已通过 luafile 加载，使用 vim.g 中保存的函数引用
command! -nargs=0 FinderMenu lua vim.g.start_finder()

" 关闭 Telescope 窗口
command! -nargs=0 FinderExit lua require('telescope.actions').close(vim.g.finder_bufnr)

" --- 搜索命令 ---
" 文件搜索
command! -nargs=* Finder Telescope find_files <args>

" 项目搜索（grep）
command! -nargs=* Search Telescope live_grep <args>

" 缓冲区列表
command! -nargs=* Buffer Telescope buffers <args>

" Search Nerd Fonts - 使用 Telescope 调用，保持统一的 UI
"command! -nargs=* NerdySearch lua require('telescope').extensions.nerdy.nerdy()
"command! -nargs=* NerdySearch Telescope nerdy <args>
" Telescope 不一定支持所有参数，比如主题参数
command! -nargs=0 NerdySearch lua vim.g.start_nerdy()

" Search Emojis
command! -nargs=0 EmojiSearch lua vim.g.start_emoji()

" Search Emojis
command! -nargs=0 OpenChat lua vim.g.start_codecompanion()

" =============================================================================
" 搜索功能（支持从当前单词开始搜索）
" =============================================================================

" Grep 当前单词
function! s:Grep() abort
    let l:word = expand("<cword>")
    if l:word !=# ''
        " 如果有当前单词，直接搜索
        exe 'Search default_text=' .. l:word
    else
        " 否则打开搜索框
        exe 'Search'
    endif
endfunction

" Grep <cword> 命令
command! -nargs=0 Grep call <SID>Grep()

" =============================================================================
" Telescope 窗口设置（通过 autocmd 实现）
" =============================================================================

augroup FinderKeymaps
    autocmd!
    " 当进入 Telescope 窗口时调用设置函数
    autocmd FileType TelescopePrompt call s:FinderSettings()
augroup END

" Telescope 窗口设置函数
function! s:FinderSettings() abort
    " 记录窗口 bufnr（用于后续操作）
    let g:finder_bufnr = bufnr()

    " Suppress 'E37: No write since last change'
    " setlocal buftype=nofile
    " 会导致 prompt_prefix 配置不生效

    setlocal cursorline
    setlocal termguicolors

    call HideCursor()

    call CloseWith('FinderExit')

    " Normal 模式：按 / 进入插入模式 (总是在最后插入）
    call StartInsertWith("call ShowTips('')<CR>:startinsert!")

    " Esc: 停止插入模式 (Insert Mode)
    call StopInsertWith("stopinsert")

    inoremap <silent><buffer> <CR> <C-o>:stopinsert<CR>

    " --- 预览 ---
    " Normal 模式：按 p 切换预览
    nnoremap <silent><buffer> p :lua require("telescope.actions.layout").toggle_preview(vim.g.finder_bufnr)<CR>

    " --- 缓冲区 ---
    " Normal 模式：按 w 删除选中的缓冲区
    nnoremap <silent><buffer> w :lua require("telescope.actions").delete_buffer(vim.g.finder_bufnr)<CR>

    " --- 选择 ---
    " Normal 模式：按 Space 或 Enter 打开选中的项
    nnoremap <silent><buffer> <CR>    :lua require('telescope.actions').select_default(vim.g.finder_bufnr)<CR>
    nnoremap <silent><buffer> <Space> :lua require('telescope.actions').select_default(vim.g.finder_bufnr)<CR>
endfunction

" =============================================================================
" Telescope 窗口按键绑定（全局）
" =============================================================================

" --- 主菜单 ---
" Normal/Insert 模式：按 Enter 打开主菜单
nnoremap <Enter>    :FinderMenu<cr>

" --- 文件搜索 ---
" Normal/Insert 模式：按 CTRL-o 打开文件搜索
nnoremap <C-o>      :Finder<cr>
inoremap <C-o>      <C-o>:Finder<cr>

" --- 缓冲区列表 ---
" Normal/Insert 模式：按 CTRL-e 打开缓冲区列表
nnoremap <C-e>      :Buffer<cr>
inoremap <C-e>      <C-o>:Buffer<cr>

" --- 项目搜索 ---
" Normal/Insert 模式：按 CTRL-g 打开项目搜索
nnoremap <C-g>      :Grep<cr>
inoremap <C-g>      <C-o>:Grep<cr>
