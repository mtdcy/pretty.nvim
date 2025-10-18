"=============================================================================
" FILE: wm.vim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================

let g:wm_debug  = 0
let g:wm_height = min([12, winheight(0) / 4])
let g:wm_width  = min([24, winwidth(0) / 4])

set wildignore&
set noequalalways
set cmdheight=1

" windows id
let g:winids = [ win_getid(), 0, 0, 0, 0 ]
" 1 - leftbar, 2 - headbar, 3 - footbar, 4 - rightbar

" find current wmid => '-1' for unclassified
function! s:wmid() abort
    return index(g:winids, win_getid())
endfunction

function! s:wmwinid(wmid) abort
    return g:winids[a:wmid]
endfunction

function! s:wmwinidset(wmid, winid) abort
    let g:winids[a:wmid] = a:winid
endfunction

" find wmid for winid => '-1' for unclassified
function! s:winid2wmid(winid) abort
    return index(g:winids, a:winid)
endfunction

" return winnr if the window exists
function! s:wmwinnr(wmid) abort
    return win_id2win(s:wmwinid(a:wmid))
endfunction

" find wmid for winnr => '-1' for unclassified
function! s:winnr2wmid(winnr) abort
    return index(g:winids, win_getid(a:winnr))
endfunction

" check window parts, return filetype if it's sidebar.
function! s:wmtype(bufnr) abort
    " bufnr can accept self as input, but winnr can't.
    let ftype = getbufvar(bufnr(a:bufnr), '&ft')
    " for developer: edit any file in main window
    if winnr() == s:wmwinnr(0)
        return ''
    elseif ftype ==? 'nerdtree' || ftype ==? 'tagbar'
        return ftype
    elseif ftype ==? 'help' || ftype ==? 'man' || ftype =~? '\.*doc' || ftype ==? 'ale-info'
        return 'docs'
    elseif ftype ==? 'qf' || getbufvar(bufnr(a:bufnr), '&bt') ==? 'quickfix'
        return 'quickfix'
    endif
    return ''
endfunction

" find expect wmid for buffer type
function! s:type2wmid(type) abort
    return index(['nerdtree', 'docs', 'quickfix', 'tagbar'], a:type) + 1
endfunction

function! s:window(wmid) abort
    exe s:wmwinnr(a:wmid) . 'wincmd w'
endfunction

" move buffer to the right window
function! s:wmmove(buf) abort
    let bufnr = bufnr(a:buf)
    " switch to alt buffer
    exe 'buffer#'
    " is this buffer on split window?
    let li = filter(range(1, winnr('$')), 'v:val != winnr() && winbufnr(v:val)==' . bufnr)
    " go to the right window
    if len(li) | call s:window(s:winnr2wmid(li[0]))
    else       | call s:window(0)
    endif
    exe 'buffer ' . bufnr
endfunction

" create window if not exists
function! s:wmcreate(wmid) abort
    if a:wmid > 0 && s:wmwinid(a:wmid) <= 0
        let saved = winnr()
        call s:window(0)
        "let cmds = ['', ':NERDTree', 'help', 'lopen', ':TagbarOpen']
        let cmds = ['', 'Explorer', 'help', 'lopen', 'Taglist']
        exe index(cmds, a:wmid)
        call s:wmwinidset(a:wmid, win_getid())
        exe saved 'wincmd w'
    endif
endfunction

" settle window to correct location
function! s:wmsettle(wmid) abort
    call s:wmcreate(a:wmid)
    let  bufnr = bufnr('%')
    exe 'wincmd c'
    call s:window(a:wmid)
    exe 'buffer ' bufnr
endfunction

function! s:wminfo() abort
    echom '== wmid:' . s:wmid() . '|wmtype:' . s:wmtype('%')
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

function! s:wm_update() abort
    if g:wm_debug | call s:wminfo() | endif
    let type  = s:wmtype('%')

    " 1. sticky buffer: buffer mis-placed?
    let wmid = s:type2wmid(type)
    if s:wmid() > 0 && wmid != s:wmid()
        echom '== buffer ' . bufname('%') . ' window expect ' . wmid . ' but current is ' . s:wmid()
        if bufwinnr('#') > 0
            echom '== settle window'
            call s:wmsettle(wmid)
        else
            echom '== move buffer'
            call s:wmmove('%')
        endif
    endif

    " 2. update winids for side windows
    if wmid > 0
        setlocal nobuflisted
        let winid = bufwinid('%')

        " multiple document window type? yes! => help|man|doc
        if winid != s:wmwinid(wmid)
            " how to deal with the new window?
            if s:wmwinid(wmid) > 0
                echom '== move buffer to window ' . s:wmwinid(wmid)
                call s:wmsettle(wmid)
            else
                echom '== set new window ' . winid . ' for type ' . type
                call s:wmwinidset(wmid, winid)
                if type ==? 'docs' || type ==? 'quickfix'
                    exe 'resize ' . g:wm_height
                else
                    exe 'vertical resize ' . g:wm_width
                endif
            endif
        endif

        "if type == 'tagbar' && s:wmwinid(5) > 0
        "    echom "== toc closed as tagbar shows. "
        "    exe s:wmwinnr(5) 'wincmd c'
        "endif
    endif
endfunction

" clean records on window close
function! s:wm_on_winclosed(winid) abort
    echom "== window " . a:winid . " closed"
    let wmid = s:winid2wmid(a:winid)
    if wmid >= 0
        call s:wmwinidset(wmid, 0)
    endif

    " find another main window
    if s:wmwinid(0) < 0
        echo '== main window closed'
        let li = filter(range(1, winnr('$')), "v:val != winnr() && s:winnr2wmid(v:val) < 0")
        if len(li) > 0
            echo '== main window closed, switch to ' . win_getid(li[0])
            call s:wmwinidset(0, win_getid(li[0]))
        endif
    endif
endfunction

function! s:close() abort
    if win_getid() != s:wmwinid(0)
        exe 'quit'
    else
        let bufnr = bufnr('%') " save bufnr
        let li = filter(range(1, bufnr('$')), 'buflisted(v:val) == 1 && v:val != ' . bufnr)
        if len(li) > 0
            " switch to previous buffer and delete current one
            echom "close " . bufname(bufnr)
            exe 'bprev | bdelete ' . bufname(bufnr)
        else
            echom "Last buffer, close it with :qa"
        endif
    endif
endfunction

function! s:next() abort
    call s:window(0)
    exe 'bnext'
endfunction

function! s:prev() abort
    call s:window(0)
    exe 'bprev'
endfunction

augroup WM
    autocmd!
    autocmd BufEnter    * call s:wm_update()
    " workarounds for NERDTree and Tagbar which set eventignore on creation
    autocmd FileType    nerdtree,tagbar call s:wm_update()
    " WinClosed may be called out of box
    autocmd WinClosed   * silent call s:wm_on_winclosed(str2nr(expand('<amatch>')))
    " quit window parts if main window went away
    autocmd WinEnter    * if g:winids[0] < 0 | quit | endif

    autocmd BufEnter    term://* startinsert
    autocmd BufLeave    term://* stopinsert
augroup END

"if g:wm_debug | nnoremap <C-Y> :call <sid>wminfo()<cr> | endif

command! -nargs=0 BufferClose call <sid>close()
command! -nargs=0 BufferNext  call <sid>next()
command! -nargs=0 BufferPrev  call <sid>prev()
