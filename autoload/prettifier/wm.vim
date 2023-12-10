"=============================================================================
" FILE: prettifier-wm.vim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================

set wildignore&
set noequalalways
set winheight=10
set winwidth=20
set winminheight=10
set winminwidth=20
set cmdheight=1

" check window parts, return filetype if it's sidebar.
function! s:wm_buf_check(buf) abort
    " bufnr can accept self as input, but winnr can't.
    let ftype = getbufvar(bufnr(a:buf), '&ft')
    " for developer: edit any file in man window
    if win_getid(winnr()) == g:pretty_winids[0]
        return ''
    elseif ftype == 'nerdtree' || ftype == 'tagbar'
        return ftype
    elseif ftype == 'help' || ftype == 'man' || ftype =~ '\.*doc'
        return 'docs'
    elseif ftype == 'qf' || getbufvar(bufnr(a:buf), '&bt') == 'quickfix'
        return 'quickfix'
    endif
    return ''
endfunction

function! s:wm_win_check(win) abort

endfunction

function! s:wm_inspect() abort
    echom '== window id:' . win_getid()
                \ . '|winnr:' . winnr() . '#' . winnr('$')
                \ . '|type:' . win_gettype() . '|winbufnr:' . winbufnr(0)
                \ . '|list:' . &list . '|cpoptions:' . &cpoptions
                \ . '|buf:' . bufname('%') . '|alt:' . bufname('#') . ''
                \ . '|bufnr:' . bufnr() . '#' . bufnr('$')
                \ . '|ft:' . &ft . '|bt:' . &bt . '|mod:' . &mod . '|modi:'. &modifiable
                \ . '|hide:' . &bufhidden . '|buflisted:' . &buflisted . '|swapfile:' . &swapfile
endfunction
if g:pretty_debug == 1 | nnoremap <C-I> :call s:wm_inspect()<cr> | endif

function! s:wmwinid(id) abort
    return g:pretty_winids[a:id]
endfunction
" return winnr if the window exists
function! s:wmwinnr(id) abort
    return win_id2win(s:wmwinid(a:id))
endfunction

" shorten the wincmd only, :h CTRL-W
function! s:wmcmd(id, cmd) abort
    return ":" . s:wmwinnr(a:id) . "wincmd " . a:cmd . "\<cr>"
endfunction

function! s:wm_on_init() abort
endfunction

function! s:wm_on_win_update() abort
    "if g:pretty_debug | call s:wm_inspect() | endif
    let bufnr = bufnr('%')
    let win   = bufwinid(bufnr)
    let type  = s:wm_buf_check(bufnr)
    let alt   = s:wm_buf_check('#')
    let i     = index(['nerdtree', 'docs', 'quickfix', 'tagbar'], type) + 1
    "echom '== bufnr ' . bufnr . ' win ' . win . ' buffer type ' . type . ' alt ' . alt . ' wmid ' . i
    " 1. sticky buffer: never open windows/buffers in sidebars
    "  a. open normal buffer in sidebars
    "  b. open new window in sidebars
    if index(g:pretty_winids, win) > 0 && alt != '' && type != alt
        let li = filter(range(1, winnr('$')), 'v:val != winnr() && winbufnr(v:val)==bufnr')
        if len(li) > 0
            echom "== open buffer in sidebar, jump to exists window " . li[0]
            exec g:pretty_cmdlet . ":buffer#\<cr>:" . li[0] . "wincmd w\<cr>"
        else
            echom "== open buffer in sidebar, ship buffer " . bufnr . " to main window"
            exec g:pretty_cmdlet . ":buffer#\<cr>" . s:wmcmd(0, 'w') . ":buffer " . bufnr. "\<cr>"
        endif
    elseif alt != '' && (bufwinnr(bufnr('#')) > 0 || (i > 0 && g:pretty_winids[i] != win))
        let j = i > 0 && s:wmwinnr(i) > 0 ? i : 0
        echom "== open window in sidebar, ship it to win " . j
        exec g:pretty_cmdlet . ":quit\<cr>" . s:wmcmd(j, 'w') . ":buffer " . bufnr . "\<cr>"
    endif

    " 2. update winids
    " footbar & toc are quickfix|loclist, no way to tell here.
    let win = bufwinid(bufnr('%')) " update again
    let [ w, h ] = [ g:pretty_bar_width, g:pretty_bar_height ]
    if i > 0
        setlocal nobuflisted
        " multiple document window type? yes! => help|man|doc
        if win != g:pretty_winids[i]
            "let w = winwidth(win_id2win(g:pretty_winids[i]))
            "let h = winheight(win_id2win(g:pretty_winids[i]))
            "exec g:pretty_cmdlet . s:wmcmd(i, 'c')

            " how to deal with the new window?
            if g:pretty_winids[i] > 0
                if bufwinnr(bufnr('#')) > 0     | exec g:pretty_cmdlet . ":quit\<cr>"
                    echom '== alt buffer is listed, close win ' . win
                else                            | exec g:pretty_cmdlet . ":buffer#\<cr>"
                    echom '== swap to alt buffer for win '. win
                endif
                exec g:pretty_cmdlet . s:wmcmd(i, 'w'). ":buffer" . bufnr. "\<cr>"
            else
                echom '== set new window ' . win . ' for type ' . type
                let g:pretty_winids[i] = win
                if type == 'docs' || type == 'quickfix'
                    exec g:pretty_cmdlet . ":resize " . h . "\<cr>"
                else
                    exec g:pretty_cmdlet . ":vertical resize " . w . "\<cr>"
                endif
            endif
        endif

        if type == 'tagbar' && g:pretty_winids[5] > 0
            echom "== toc closed as tagbar shows. "
            exec g:pretty_cmdlet . s:wmcmd(5, 'c')
        endif
    elseif s:wmwinnr(0) <= 0
        echom "== update main window id " . win
        let g:pretty_winids[0] = win
    endif
endfunction

" clean records on window close
function! s:wm_on_win_close(win) abort
    echom '== closed ' . a:win
    let i = index(g:pretty_winids, a:win)
    if i >= 0 | let g:pretty_winids[i] = -1 | endif

    " find another main window
    if g:pretty_winids[0] < 0
        let li = filter(range(1, winnr('$')), "index(g:pretty_winids, win_getid(v:val)) < 0")
        if len(li) > 0 | let g:pretty_winids[0] = win_getid(li[0]) | endif
    endif
endfunction

function! s:wm_quit() abort
    if win_getid() != g:pretty_winids[0]
        exec g:pretty_cmdlet . ":confirm quit\<cr>"
    else
        echohl WarningMsg
        let bufnr = bufnr('%') " save bufnr
        let li = filter(range(1, bufnr('$')), 'buflisted(v:val)')
        if len(li) > 1 | exec g:pretty_cmdlet . ":bprev\<cr>:confirm bdelete" . bufnr. "\<cr>"
        else           | echo "Last buffer, close it with :quit"
        endif
        echohl None
    endif
endfunction

function! s:wm_keys() abort
    " {{{ => Key Mappings
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
    nnoremap <F8>       :ToggleBufExplorer<cr>
    nnoremap <F9>       :NERDTreeToggle<cr>
    nnoremap <F10>      :TagbarToggle<cr>

    noremap  <C-q>      :call s:wm_quit()<cr>
    tnoremap <C-q>      <C-\><C-N>:call s:wm_quit()<cr>

    " Move focus
    nnoremap <C-j>      <C-W>j
    nnoremap <C-k>      <C-W>k
    nnoremap <C-h>      <C-W>h
    nnoremap <C-l>      <C-W>l
    tnoremap <C-j>      <C-\><C-N><C-W>j
    tnoremap <C-k>      <C-\><C-N><C-W>k
    tnoremap <C-h>      <C-\><C-N><C-W>h
    tnoremap <C-l>      <C-\><C-N><C-W>l

    " Buffer
    nnoremap <C-e>      :ToggleBufExplorer<cr>
    nnoremap <C-n>      :bnext<cr>
    nnoremap <C-p>      :bprev<cr>
    tnoremap <C-n>      <C-\><C-N>:bnext<cr>
    tnoremap <C-p>      <C-\><C-N>:bprev<cr>

    " 跳转 - Goto
    " Go to first line - `gg`
    " Go to last line
    noremap  gG         G
    " Go to begin or end of code block
    noremap  g[         [{
    noremap  g]         ]}
    " Go to Define and Back(Top of stack)
    " TODO: map K,<C-]>,gD,... to one key
    nnoremap gd         <C-]>
    nnoremap gh         <C-T>
    " Go to man or doc
    nnoremap gk         K
    " Go to Type
    " nmap gt
    " Go to next error of ale
    nnoremap ge         <Plug>(ale_next_wrap)
    " Go to yank and paste
    vnoremap gy         "+y
    nnoremap gp         "+p
    vnoremap <C-c>      "+y
    " Go to list, FIXME: what about quickfix
    nnoremap gl         :lopen<CR>
    " Tabularize
    vnoremap /          :Tabularize /

    " 其他
    if g:pretty_debug
        inoremap <C-o>      <Plug>(neosnippet_expand_or_jump)
        snoremap <C-o>      <Plug>(neosnippet_expand_or_jump)
    endif

    " reasonable setting
    " 'u' = undo => 'U' = redo
    "  => like 'n' & 'N' in search mode
    nnoremap U          :redo<cr>
endfunction

function! s:wm_autocmds() abort
    augroup prettifier.wm
        autocmd!
        autocmd BufEnter    * call s:wm_on_win_update()
        " WinClosed may be called out of box
        autocmd WinClosed   * call s:wm_on_win_close(str2nr(expand('<amatch>')))
        " workarounds for NERDTree and Tagbar which set eventignore on creation
        autocmd FileType    nerdtree,tagbar,man call s:wm_on_win_update()
        " quit window parts if main window went away
        autocmd WinEnter    * if g:pretty_winids[0] <= 0 && s:wm_buf_check('%') != '' | quit | endif

        autocmd BufEnter    term://* startinsert
        autocmd BufLeave    term://* stopinsert
    augroup END
endfunction

function! prettifier#wm#init()
    call s:wm_autocmds()
    call s:wm_keys()
endfunction
" }}}
