" denite => maybe we should try ddu.vim

let g:denite_enabled = 1

if g:denite_enabled
    command! -nargs=0 Finder Denite -buffer-name=search -start-filter file/rec
    command! -nargs=0 Buffer Denite -buffer-name=search -no-empty buffer
    command! -nargs=0 Search DeniteCursorWord -buffer-name=search -no-empty grep:::!
    command! -nargs=0 Menu   Denite menu:main

    " Denite Settings {{{
    " FIXME: close after lose focus
    function! s:denite_ready() abort
        " line numbers for selection
        if bufname('%') =~? 'search$'
            setlocal number
        else
            setlocal number&
        endif

        " kep mappings
        nnoremap <silent><buffer><expr> <cr>    denite#do_map('do_action')
        nnoremap <silent><buffer><expr> <space> denite#do_map('toggle_select').'j'      " select and move down
	    nnoremap <silent><buffer><expr> p       denite#do_map('do_action', 'preview')   " preview
        nnoremap <silent><buffer><expr> /       denite#do_map('open_filter_buffer')     " search
        nnoremap <silent><buffer><expr> w       denite#do_map('do_action', 'delete')    " delete buffer
        nnoremap <silent><buffer><expr> q       denite#do_map('quit')                   " quit
        nnoremap <silent><buffer><expr> <Esc>   denite#do_map('quit')                   " quit
        nnoremap <silent><buffer><expr> <BS>    denite#do_map('restore_sources')        " back
        nnoremap <silent><buffer><expr> <tab>   'j'                                     " move down

        " quit denite and enter insert mode
        nnoremap <silent><buffer><expr> i       denite#do_map('quit').'i'
        nnoremap <silent><buffer><expr> I       denite#do_map('quit').'I'
        nnoremap <silent><buffer><expr> a       denite#do_map('quit').'a'
        nnoremap <silent><buffer><expr> A       denite#do_map('quit').'A'
        nnoremap <silent><buffer><expr> u       denite#do_map('quit').'u'
        nnoremap <silent><buffer><expr> U       denite#do_map('quit').'U'

        " select by numbers
        nnoremap <silent><buffer><expr> 1       '1G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 2       '2G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 3       '3G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 4       '4G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 5       '5G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 6       '6G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 7       '7G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 8       '8G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 9       '9G'.denite#do_map('do_action')

        " quit denite and call map keys
        nmap     <silent><buffer><expr> <F9>    denite#do_map('quit').'<F9>'
        nmap     <silent><buffer><expr> <F10>   denite#do_map('quit').'<F10>'
        nmap     <silent><buffer><expr> <F12>   denite#do_map('quit').'<F12>'
    endfunction

    function! s:denite_filter() abort
        inoremap <silent><buffer> <esc>         <Plug>(denite_filter_quit)
        inoremap <silent><buffer> <cr>          <Plug>(denite_filter_update)
        inoremap <silent><buffer> <tab>         <Plug>(denite_filter_update)
    endfunction

    function! s:denite_preview() abort
        setlocal bufhidden=hide
        setlocal buftype=nofile
        setlocal number&
        setlocal buflisted&

        augroup denite_preview
            autocmd!
        augroup END
    endfunction

    augroup DeniteSettings
        autocmd!
        autocmd FileType denite         call s:denite_ready() | call HideCursor()
        autocmd FileType denite-filter  call s:denite_filter()
        autocmd User     denite-preview call s:denite_preview()
    augroup END

    " floating preview is not well defined
    call denite#custom#option('_', {
                \   'max_dynamic_update_candidates' : 100000,
                \   'split'                         : 'floating_relative_window',
                \   'floating_border'               : 'rounded',
                \   'floating_preview'              : 0,
                \   'match_highlight'               : 0,
                \   'smartcase'                     : 0,
                \   'auto_resize'                   : 1,
                \ })

    " fruzzy is much faster than fuzzy
    "let g:denite_fuzzy_matcher = 'matcher/fuzzy'
    let g:denite_fuzzy_matcher = 'matcher/fruzzy'
    call denite#custom#source('file/rec', {
                \ 'matchers' : [
                \   g:denite_fuzzy_matcher,
                \   'matcher/hide_hidden_files',
                \   'matcher/ignore_globs'
                \ ],
                \ 'sorters' : [ 'sorter/sublime' ],
                \ })
    call denite#custom#source('buffer', {
                \ 'matchers' : [
                \   'matcher/substring',
                \ ],
                \ 'sorters' : [ 'sorter/sublime' ],
                \ })
    call denite#custom#filter('matcher/ignore_globs', 'ignore_globs', [
                \ '*~', '*.o', '*.exe', '*.bak', '*.a', '*.so', '*.so.*',
                \ '.DS_Store', '*.pyc', '*.sw[po]', '*.class',
                \ '.hg/', '.git/', '.bzr/', '.svn/', '.ccache/',
                \ 'tags', 'tags-*'
                \ ])

    " ripgrep is much faster
    if executable('rg')
        call denite#custom#var('file/rec', 'command', [
                    \ 'rg', '--files', '--glob', '!.git', '--color', 'never'
                    \ ])

        call denite#custom#var('grep', {
                    \ 'command': ['rg'],
                    \ 'default_opts': ['-i', '--vimgrep', '--no-heading', '--no-column'],
                    \ 'recursive_opts': [],
                    \ 'pattern_opt': ['--regexp'],
                    \ 'separator': ['--'],
                    \ 'final_opts': [],
                    \ })
    endif

    " enhanced filter: fruzzy
    "  => 'call fruzzy#install()' to install native libraries
    let g:fruzzy#usenative = filereadable(g:pretty_home . '/rplugin/python3/fruzzy_mod.so')
    let g:fruzzy#sortonempty = 1
    " }}}

    " Denite Menu {{{
    let s:menus = {}

    let s:menus.nvim = {
                \ 'command_candidates' : [
                \   [ '1. init.vim                  ', 'edit ' . $MYVIMRC                    ],
                \   [ '2. init/...                  ', 'Denite -path=' . g:pretty_home . '/init file/rec' ],
                \ ]}

    let s:menus.edit = {
                \ 'command_candidates' : [
                \   [ '1. Undo               u  ', 'undo                                    '],
                \   [ '2. Redo               U  ', 'redo                                    '],
                \   [ '3. Format code           ', 'ALEFix                                  '],
                \   [ '4. Edit nvim ...         ', 'Denite menu:nvim                        '],
                \ ]}

    let s:menus.move = {
                \ 'command_candidates' : [
                \   [ '1. Move above    CTRL-k  ', 'wincmd k                                '],
                \   [ '2. Move below    CTRL-j  ', 'wincmd j                                '],
                \   [ '3. Move left     CTRL-h  ', 'wincmd h                                '],
                \   [ '4. Move right    CTRL-l  ', 'wincmd l                                '],
                \ ]}

    let s:menus.main = {
                \ 'command_candidates' : [
                \   [ '1. Finder        CTRL-o  ', 'Finder                                  '],
                \   [ '2. Buffer        CTRL-e  ', 'Buffer                                  '],
                \   [ '3. Search        CTRL-g  ', 'Denite -start-filter grep:::!           '],
                \   [ '4. Edit ...              ', 'Denite menu:edit                        '],
                \   [ '5. Move ...              ', 'Denite menu:move                        '],
                \   [ '6. Explorer          F9  ', 'Explorer                                '],
                \   [ '7. Taglist          F10  ', 'Taglist                                 '],
                \   [ '8. LazyGit          F12  ', 'VCS                                     '],
                \   [ '9. Close         CTRL-w  ', 'BufferClose                             '],
                \   [ '   Quit             :qa  ', 'confirm quit                            '],
                \   [ '   Help                  ', 'edit ' . g:pretty_home . '/README.md    '],
                \ ]}

    call denite#custom#var('menu', 'menus', s:menus)
    " }}}
endif

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

nnoremap <Enter>    :Menu<cr>
" buffer explorer
"nnoremap <leader>be :Buffer<cr>
nnoremap <C-e>      :Buffer<cr>
inoremap <C-e>      <C-o>:Buffer<cr>
" buffer open
"nnoremap <leader>bo :Finder<cr>
nnoremap <C-o>      :Finder<cr>
inoremap <C-o>      <C-o>:Finder<cr>
" buffer grep
"nnoremap <leader>bg :Search<cr>
nnoremap <C-g>      :Search<cr>
inoremap <C-g>      <C-o>:Search<cr>

nnoremap <C-n>      :BufferNext<cr>
inoremap <C-n>      <C-o>:BufferNext<cr>
tnoremap <C-n>      <C-\><C-N>:bnext<cr>
nnoremap <Tab>      :BufferNext<cr>

nnoremap <C-p>      :BufferPrev<cr>
inoremap <C-p>      <C-o>:BufferPrev<cr>
tnoremap <C-p>      <C-\><C-N>:bprev<cr>
nnoremap <S-Tab>    :BufferPrev<cr>

nnoremap  <C-w>     :BufferClose<cr>
inoremap  <C-w>     <C-o>:BufferClose<cr>
tnoremap  <C-w>     <C-\><C-N>:BufferClose<cr>

" 'CTRL-/' => 触发comment
nnoremap  <C-_>     <Plug>NERDCommenterToggle
inoremap  <C-_>     <C-o><Plug>NERDCommenterToggle

" ALE hover manually
nnoremap <C-y>      :ALEHover<cr>
inoremap <C-y>      <C-o>:ALEHover<cr>

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
