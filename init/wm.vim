"=============================================================================
" FILE: wm.vim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================

set wildignore&
set noequalalways
set winheight=10
set winwidth=20
set cmdheight=1

let g:wm_debug = 0

" window components id
let g:winids = [ win_getid(), 0, 0, 0, 0, 0 ]
" 1 - leftbar, 2 - headbar, 3 - footbar, 4 - rightbar, 5 - toc(right)

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
function! s:wmtype(buf) abort
    " bufnr can accept self as input, but winnr can't.
    let ftype = getbufvar(bufnr(a:buf), '&ft')
    " for developer: edit any file in main window
    if winnr() == s:wmwinnr(0)
        return ''
    elseif ftype ==? 'nerdtree' || ftype ==? 'tagbar'
        return ftype
    elseif ftype ==? 'help' || ftype ==? 'man' || ftype =~? '\.*doc' || ftype ==? 'ale-info'
        return 'docs'
    elseif ftype ==? 'qf' || getbufvar(bufnr(a:buf), '&bt') ==? 'quickfix'
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
    exe 'buffer#'
    " go to the right window
    if len(li) | exe li[0] 'wincmd w'
    else       | exe s:wmwinnr(0) 'wincmd w'
    endif
    exe 'buffer ' bufnr
endfunction

" create window if not exists
function! s:wmcreate(wmid) abort
    if a:wmid > 0 && s:wmwinid(a:wmid) <= 0
        let saved = winnr()
        exe s:wmwinnr(0) 'wincmd w'
        "let cmds = ['', ':NERDTree', 'help', 'lopen', ':TagbarOpen']
        let cmds = ['', 'Explorer', 'help', 'lopen', 'Taglist']
        exe index(cmds, a:wmid)
        let g:winids[a:wmid] = win_getid()
        exe saved 'wincmd w'
    endif
endfunction

" settle window to correct location
function! s:wmsettle(wmid) abort
    call s:wmcreate(a:wmid)
    let  bufnr = bufnr('%')
    exe 'wincmd c'
    exe s:wmwinnr(a:wmid) 'wincmd w'
    exe 'buffer ' bufnr
endfunction

function! s:wminfo() abort
    echom '== wmid:' . s:wmid() 
                \ . '|winid:' . win_getid()
                \ . '|winnr:' . winnr() . '#' . winnr('$')
                \ . '|type:' . win_gettype() . '|winbufnr:' . winbufnr(0)
                \ . '|list:' . &list . '|cpoptionprettifier#wm#' . &cpoptions
                \ . '|buf:' . bufname('%') . '|alt:' . bufname('#') . ''
                \ . '|bufnr:' . bufnr('%') . '#' . bufnr('$')
                \ . '|bufwinr:' . bufwinnr('%')
                \ . '|ft:' . &ft . '|bt:' . &bt . '|mod:' . &mod . '|modi:'. &modifiable
                \ . '|hide:' . &bufhidden . '|buflisted:' . &buflisted . '|swapfile:' . &swapfile
endfunction

function! s:wm_update() abort
    if g:wm_debug | call s:wminfo() | endif
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
                    exe 'resize ' h
                else
                    exe 'vertical resize ' w
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

function! BufferClose() abort
    if win_getid() != s:wmwinid(0)
        exe 'confirm quit'
    else
        echohl WarningMsg
        let bufnr = bufnr('%') " save bufnr
        if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) > 1
            exe 'bprev'
            exe 'confirm bwipeout ' bufnr
        else
            echo "Last buffer, close it with :quit"
        endif
        echohl None
    endif
endfunction

function! BufferNext() abort
    if s:wmid() > 0 | silent exe 'wincmd p' | endif
    silent exe 'bnext'
endfunction

function! BufferPrev() abort
    if s:wmid() > 0 | silent exe 'wincmd p' | endif
    silent exe 'bprev'
endfunction

augroup WM
    autocmd!
    autocmd BufEnter    * call s:wm_update()
    " workarounds for NERDTree and Tagbar which set eventignore on creation
    autocmd FileType    * call s:wm_update()
    " WinClosed may be called out of box
    autocmd WinClosed   * silent call s:wm_on_winclosed(str2nr(expand('<amatch>')))
    " quit window parts if main window went away
    autocmd WinEnter    * if g:winids[0] < 0 | quit | endif

    autocmd BufEnter    term://* startinsert
    autocmd BufLeave    term://* stopinsert
augroup END

if g:wm_debug | nnoremap <C-Y> :call <sid>wminfo()<cr> | endif
