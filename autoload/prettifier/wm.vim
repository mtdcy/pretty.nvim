"=============================================================================
" FILE: prettifier-wm.vim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================

set wildignore&
set noequalalways
set winheight=10
set winwidth=20
set cmdheight=1

" window components id

if !exists('g:pretty_winids')
    let g:pretty_winids = [ win_getid(), 0, 0, 0, 0, 0 ]
endif
" 1 - leftbar, 2 - headbar, 3 - footbar, 4 - rightbar, 5 - toc(right)

" find current wmid => '-1' for unclassified
function! s:wmid() abort
    return index(g:pretty_winids, win_getid())
endfunction

function! s:wmwinid(wmid) abort
    return g:pretty_winids[a:wmid]
endfunction

function! s:wmwinidset(wmid, winid) abort
    let g:pretty_winids[a:wmid] = a:winid
endfunction

" find wmid for winid => '-1' for unclassified
function! s:winid2wmid(winid) abort
    return index(g:pretty_winids, a:winid)
endfunction

" return winnr if the window exists
function! s:wmwinnr(wmid) abort
    return win_id2win(s:wmwinid(a:wmid))
endfunction

" find wmid for winnr => '-1' for unclassified
function! s:winnr2wmid(winnr) abort
    return index(g:pretty_winids, win_getid(a:winnr))
endfunction

" check window parts, return filetype if it's sidebar.
function! s:wmtype(buf) abort
    " bufnr can accept self as input, but winnr can't.
    let ftype = getbufvar(bufnr(a:buf), '&ft')
    " for developer: edit any file in main window
    if winnr() == s:wmwinnr(0)
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

" find expect wmid for buffer type
function! s:type2wmid(type) abort
    return index(['nerdtree', 'docs', 'quickfix', 'tagbar'], a:type) + 1
endfunction

" move buffer to the right window
function! s:wmmove(buf) abort
    let bufnr = bufnr(a:buf)
    let li = filter(range(1, winnr('$')), 'v:val != winnr() && winbufnr(v:val)==' . bufnr)
    " switch to alt buffer
    exec 'buffer#'
    " go to the right window
    if len(li) | exec li[0] 'wincmd w'
    else       | exec s:wmwinnr(0) 'wincmd w'
    endif
    exec 'buffer ' bufnr
endfunction

" create window if not exists
function! s:wmcreate(wmid) abort
    if a:wmid > 0 && s:wmwinid(a:wmid) <= 0
        let saved = winnr()
        exec s:wmwinnr(0) 'wincmd w'
        let cmds = ['', ':NERDTree', 'help', 'lopen', ':TagbarOpen']
        exec index(cmds, a:wmid)
        let g:pretty_winids[a:wmid] = win_getid()
        exec saved 'wincmd w'
    endif
endfunction

" settle window to correct location
function! s:wmsettle(wmid) abort
    call s:wmcreate(a:wmid)
    let  bufnr = bufnr('%')
    exec 'wincmd c'
    exec s:wmwinnr(a:wmid) 'wincmd w'
    exec 'buffer ' bufnr
endfunction

function! prettifier#wm#inspect() abort
    echom '== window id:' . win_getid()
                \ . '|winnr:' . winnr() . '#' . winnr('$')
                \ . '|type:' . win_gettype() . '|winbufnr:' . winbufnr(0)
                \ . '|list:' . &list . '|cpoptionprettifier#wm#' . &cpoptions
                \ . '|buf:' . bufname('%') . '|alt:' . bufname('#') . ''
                \ . '|bufnr:' . bufnr('%') . '#' . bufnr('$')
                \ . '|bufwinr:' . bufwinnr('%')
                \ . '|ft:' . &ft . '|bt:' . &bt . '|mod:' . &mod . '|modi:'. &modifiable
                \ . '|hide:' . &bufhidden . '|buflisted:' . &buflisted . '|swapfile:' . &swapfile
endfunction
if g:pretty_debug == 1 | nnoremap <C-I> :call prettifier#wm#inspect()<cr> | endif

function! prettifier#wm#on_update() abort
    if g:pretty_debug | call prettifier#wm#inspect() | endif
    let bufnr = bufnr('%')
    let type  = s:wmtype(bufnr)

    " 1. sticky buffer: buffer mis-placed?
    let wmid = s:type2wmid(type)
    if s:wmid() > 0 && wmid != s:wmid()
        "echom '== buffer ' . bufname('%') . ' window expect ' . wmid . ' but current is ' . s:wmid()
        if bufwinnr('#') > 0
            "echom '== settle window'
            call s:wmsettle(wmid)
        else
            "echom '== move buffer'
            call s:wmmove(bufnr)
        endif
    endif

    " 2. update winids
    " footbar & toc are quickfix|loclist, no way to tell here.
    let winid = bufwinid(bufnr('%'))
    let [ w, h ] = [ g:pretty_bar_width, g:pretty_bar_height ]
    if wmid > 0
        setlocal nobuflisted
        " multiple document window type? yes! => help|man|doc
        if winid != s:wmwinid(wmid)
            " how to deal with the new window?
            if s:wmwinid(wmid) > 0
                "echom '== move buffer to window ' . s:wmwinid(wmid)
                call s:wmsettle(wmid)
            else
                "echom '== set new window ' . winid . ' for type ' . type
                call s:wmwinidset(wmid, winid)
                if type == 'docs' || type == 'quickfix'
                    exec 'resize ' h
                else
                    exec 'vertical resize ' w
                endif
            endif
        endif

        if type == 'tagbar' && s:wmwinid(5) > 0
            echom "== toc closed as tagbar shows. "
            exec s:wmwinnr(5) 'wincmd c'
        endif
    endif
endfunction

" clean records on window close
function! prettifier#wm#on_winclose(winid) abort
    let wmid = s:winid2wmid(a:winid)
    if wmid >= 0
        call s:wmwinidset(wmid, -1)
    endif

    " find another main window
    if s:wmwinid(0) < 0
        let li = filter(range(1, winnr('$')), "v:val != winnr() && s:winnr2wmid(v:val) < 0")
        if len(li) > 0
            echom '== main window closed, switch to ' . win_getid(li[0])
            call s:wmwinidset(0, win_getid(li[0]))
        endif
    endif
endfunction

function! prettifier#wm#quit() abort
    if win_getid() != s:wmwinid(0)
        exec 'confirm quit'
    else
        echohl WarningMsg
        let bufnr = bufnr('%') " save bufnr
        if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) > 1
            exec 'bnext'
            exec 'confirm bwipeout ' bufnr
        else
            echo "Last buffer, close it with :quit"
        endif
        echohl None
    endif
endfunction

function! prettifier#wm#next() abort
    if s:wmid() > 0 | silent exec 'wincmd p' | endif
    silent exec 'bnext'
endfunction

function! prettifier#wm#prev() abort
    if s:wmid() > 0 | silent exec 'wincmd p' | endif
    silent exec 'bprev'
endfunction

function! prettifier#wm#autocmds() abort
    augroup prettifier.wm
        autocmd!
        autocmd BufEnter    * call prettifier#wm#on_update()
        " workarounds for NERDTree and Tagbar which set eventignore on creation
        autocmd FileType    * call prettifier#wm#on_update()
        " WinClosed may be called out of box
        autocmd WinClosed   * silent call prettifier#wm#on_winclose(str2nr(expand('<amatch>')))
        " quit window parts if main window went away
        autocmd WinEnter    * if g:pretty_winids[0] < 0 | quit | endif

        autocmd BufEnter    term://* startinsert
        autocmd BufLeave    term://* stopinsert
    augroup END
endfunction

function! prettifier#wm#keymaps() abort
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

    noremap  <C-q>      :call prettifier#wm#quit()<cr>
    tnoremap <C-q>      <C-\><C-N>:call prettifier#wm#quit()<cr>

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
    nnoremap <silent> <C-e>     :ToggleBufExplorer<cr>
    nnoremap <silent> <C-n>     :call prettifier#wm#next()<cr>
    nnoremap <silent> <C-p>     :call prettifier#wm#prev()<cr>
    tnoremap <silent> <C-n>     <C-\><C-N>:bnext<cr>
    tnoremap <silent> <C-p>     <C-\><C-N>:bprev<cr>

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

function! prettifier#wm#init()
    call prettifier#wm#autocmds()
    call prettifier#wm#keymaps()
endfunction
