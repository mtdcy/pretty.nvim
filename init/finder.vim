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
let g:finder_tips = "按'/'开始搜索"

" Prompt 窗口 bufnr（用于后续操作）
let g:finder_bufnr = 0

" 加载 Telescope 配置文件
luafile <sfile>:h/telescope.lua

" =============================================================================
" Finder 菜单配置（扁平化设计，所有菜单项在同一层级）
" =============================================================================

let g:finder = {
            \ 'items': [
            \   ['1. Finder          (CTRL-o)  ', 'Finder'                               ] ,
            \   ['2. Buffer          (CTRL-e)  ', 'Buffer'                               ] ,
            \   ['3. Search          (CTRL-g)  ', 'Search'                               ] ,
            \   ['4. Format          (F8)      ', 'ALEFix'                               ] ,
            \   ['5. Explorer        (F9)      ', 'ExplorerFocus'                        ] ,
            \   ['6. Taglist         (F10)     ', 'TaglistFocus'                         ] ,
            \   ['7. LazyGit         (F12)     ', 'VCS'                                  ] ,
            \   ['8. Close           (CTRL-w)  ', 'BufferClose'                          ] ,
            \   ['9. Quit            (:qa)     ', 'confirm quit'                         ] ,
            \   ['?. Help                      ', 'edit ' . g:pretty_home . '/README.md' ] ,
            \ ],
            \ }

" =============================================================================
" 命令定义
" =============================================================================

" --- 主菜单命令 ---
" 打开 Finder 主菜单
command! -nargs=0 FinderMenu lua require('init.telescope').finder.menu()

" 关闭 Telescope 窗口
command! -nargs=0 FinderExit lua require('telescope.actions').close(vim.g.finder_bufnr)

" --- 搜索命令 ---
" 文件搜索
command! -nargs=* Finder Telescope find_files <args>

" 项目搜索（grep）
command! -nargs=* Search Telescope live_grep <args>

" 缓冲区列表
command! -nargs=* Buffer Telescope buffers <args>

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
    echom 'finder_bufnr: ' .. g:finder_bufnr

    " 窗口外观设置
    " setlocal nonumber
    " setlocal nohlsearch
    " setlocal signcolumn=no

    " Suppress 'E37: No write since last change'
    setlocal buftype=nofile

    setlocal cursorline
    setlocal termguicolors
    " highlight Cursor blend=100

    " --- 基本导航 ---
    " Normal 模式：按 / 进入插入模式（反向搜索）
    nnoremap <silent><buffer> /       :startinsert!<CR>
    " Insert 模式：按 CR 停止插入模式
    inoremap <silent><buffer> <CR>    <C-o>:stopinsert<CR>
    " Normal 模式：按 Esc 关闭窗口
    nnoremap <silent><buffer> <Esc>   :FinderExit<CR>

    " --- 预览 ---
    " Normal 模式：按 p 切换预览
    nnoremap <silent><buffer> p       :lua require("telescope.actions.layout").toggle_preview(vim.g.finder_bufnr)

    " --- 缓冲区 ---
    " Normal 模式：按 w 删除选中的缓冲区
    nnoremap <silent><buffer> w       :lua require("telescope.actions").delete_buffer(vim.g.finder_bufnr)

    " --- 选择 ---
    " Normal 模式：按 Space 打开选中的项
    nnoremap <silent><buffer> <Space> :lua require('telescope.actions').select_default(vim.g.finder_bufnr)
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

" --- 窗口管理 ---
" Normal/Insert 模式：F9/F10/F12 打开 Explorer/Taglist/LazyGit
nnoremap <F9>       :ExplorerFocus<cr>
inoremap <F9>       <C-o>:ExplorerFocus<cr>
nnoremap <F10>      :TaglistFocus<cr>
inoremap <F10>      <C-o>:TaglistFocus<cr>
" no F11 here, as macOS has global define
nnoremap <F12>      :VCS<cr>
inoremap <F12>      <C-o>:VCS<cr>

" =============================================================================
" 缓冲区导航（保持与 Denite 一致）
" =============================================================================

" --- 下一个缓冲区 ---
nnoremap <C-n>      :BufferNext<cr>
inoremap <C-n>      <C-o>:BufferNext<cr>
tnoremap <C-n>      <C-\><C-N>:bnext<cr>
nnoremap <Tab>      :BufferNext<cr>

" --- 上一个缓冲区 ---
nnoremap <C-p>      :BufferPrev<cr>
inoremap <C-p>      <C-o>:BufferPrev<cr>
tnoremap <C-p>      <C-\><C-N>:bprev<cr>
nnoremap <S-Tab>    :BufferPrev<cr>

" --- 关闭缓冲区 ---
nnoremap <C-w>      :BufferClose<cr>
inoremap <C-w>      <C-o>:BufferClose<cr>
tnoremap <C-w>      <C-\><C-N>:BufferClose<cr>

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
vnoremap gy         "+y
nnoremap gy         y<Space>
nnoremap gp         "+p
vnoremap <C-c>      "+y

" Go to list, FIXME: what about quickfix
nnoremap gl         :lopen<CR>

" Tabularize
vnoremap /          :Tabularize /

" =============================================================================
" 帮助信息
" =============================================================================

" Telescope 模式下可用按键：
" Normal 模式:
"   <CR>    - 选择
"   q/<Esc> - 关闭
"   j/k     - 上下移动
"   <Tab>   - 下一个
"   <S-Tab> - 上一个
"   gg/G    - 顶部/底部
"   <Space> - 选择并移动
"   w       - 删除缓冲区
"   1-9     - 选择第 N 项
"   <F9>    - 打开 Explorer
"   <F10>   - 打开 Taglist
"   <F12>   - 打开 LazyGit
"
" Insert 模式:
"   <CR>    - 选择
"   <Esc>   - 关闭
"   <C-n>/<C-p> - 下一个/上一个
"   <Tab>   - 下一个
"   <S-Tab> - 上一个
"   <Space> - 选择并移动
"   <F9>    - 打开 Explorer
"   <F10>   - 打开 Taglist
"   <F12>   - 打开 LazyGit
