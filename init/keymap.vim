"=============================================================================
" FILE: prettifier-wm.vim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================

" Help
" :h map
" :h mapclear
" :h map-table      : map command vs mode
" :h map-comments   : no comments behind map commands
" :h <Char>         : map a character by its decimal
"  => 非必要不加<silent>，这样我们可以很好的看到具体执行的命令

" 已经有定义的按键:
"  - `w`, `b`   : word forward or backward
"  - `e`,       : word forward end
"  - `n`, `N`   : search next or prev
"  - `r`        : replace
"  - `i`, `I`   : insert, insert at line beginning
"  - `a`, `A`   : append, append at line end
"  - `o`, `O`   : new line after or before current line
"  - `y`, `Y`   : yank
"  - `p`, `P`   : paste after or before current cursor
"  ...

" Window
nnoremap <F9>       :ExplorerFocus<cr>
inoremap <F9>       <C-o>:ExplorerFocus<cr>
nnoremap <F10>      :TaglistFocus<cr>
inoremap <F10>      <C-o>:TaglistFocus<cr>
" no F11 here, as macOS has global define
nnoremap <F12>      :VCS<cr>
inoremap <F12>      <C-o>:VCS<cr>

nnoremap <C-e>      :Buffer<cr>
inoremap <C-e>      <C-o>:Buffer<cr>
nnoremap <C-o>      :Finder<cr>
inoremap <C-o>      <C-o>:Finder<cr>

nnoremap <C-n>      :call BufferNext()<cr>
inoremap <C-n>      <C-o>:call BufferNext()<cr>
tnoremap <C-n>      <C-\><C-N>:bnext<cr>
nnoremap <Tab>      :call BufferNext()<cr>

nnoremap <C-p>      :call BufferPrev()<cr>
inoremap <C-p>      <C-o>:call BufferPrev()<cr>
tnoremap <C-p>      <C-\><C-N>:bprev<cr>
nnoremap <S-Tab>    :call BufferPrev()<cr>

nnoremap  <C-w>     :call BufferClose()<cr>
inoremap  <C-w>     <C-o>:call BufferClose()<cr>
tnoremap <C-w>      <C-\><C-N>:call BufferClose()<cr>

" 'CTRL-/' => 触发comment
nnoremap  <C-_>     <Plug>NERDCommenterToggle
inoremap  <C-_>     <C-o><Plug>NERDCommenterToggle

" ALE hover manually
nnoremap <C-d>      :ALEHover<cr>
inoremap <C-d>      <C-o>:ALEHover<cr>

" ALEInfo|ALEFix
nnoremap <F7>       :ALEInfo<cr>
nnoremap <F8>       :ALEFix<cr>

" Move focus
nnoremap <C-j>      <C-W>j
nnoremap <C-k>      <C-W>k
nnoremap <C-h>      <C-W>h
nnoremap <C-l>      <C-W>l
tnoremap <C-j>      <C-\><C-N><C-W>j
tnoremap <C-k>      <C-\><C-N><C-W>k
tnoremap <C-h>      <C-\><C-N><C-W>h
tnoremap <C-l>      <C-\><C-N><C-W>l

" 跳转 - Goto
" Go to first line - `gg`
" Go to last line
noremap  gG         G
" Go to begin or end of code block
noremap  g[         [{
noremap  g]         ]}
" Go to Define and Back(Top of stack)
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

" reasonable setting
" 'u' = undo => 'U' = redo
"  => like 'n' & 'N' in search mode
nnoremap U          :redo<cr>

" have to use <leader>, as Ctrl-numbers are likely unavailable.
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
