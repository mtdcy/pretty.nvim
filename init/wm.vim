"=============================================================================
" FILE: wm.vim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================

let g:wm_debug  = 0
let g:wm_height = min([12, winheight(0) / 4])
let g:wm_width  = max([min([40, winwidth(0) / 2]), winwidth(0) / 4])

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

" find expect wmid for buffer type
" wmid: 1-leftbar(nerdtree), 2-headbar(docs), 3-footbar(quickfix), 4-rightbar(tagbar/codecompanion)
function! s:type2wmid(type) abort
    if a:type ==? 'nerdtree'
        return 1
    elseif a:type ==? 'docs'
        return 2
    elseif a:type ==? 'quickfix'
        return 3
    elseif a:type ==? 'tagbar' || a:type ==? 'codecompanion'
        return 4  " rightbar: tagbar or codecompanion (mutually exclusive)
    endif
    return -1
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
        if a:wmid == 1
            Explorer
        elseif a:wmid == 2
            help
        elseif a:wmid == 3
            lopen
        elseif a:wmid == 4
            " rightbar: tagbar or gemini-chat (created by respective plugins)
            " This function just reserves the window slot
        endif
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

" 主窗口管理
function! s:wm_main() abort
    let winid = win_getid()
    " 检查 main 窗口状态,
    " - 要是buffer是在外部被删除的，winid还被保存着，所以检查 winnr (1-based)
    if s:wmwinnr(0) > 0 | return | endif

    " 这种情况主要发生在唯一的buf被外部命令删除
    echo '== main window closed, take ' .. winid

    " main 窗口不存在，sp|vsp 一个很复杂，直接抢一个窗口
    call s:wmwinidset(s:winid2wmid(winid), 0)
    call s:wmwinidset(0, winid)

    enew " 这个很关键，不然后面 wmtype 判断会失效
endfunction

" wm_update 可能在未被管理的窗口调用到
function! s:wm_update() abort
    if g:wm_debug | call s:wminfo() | endif
    let type  = s:wmtype('%')

    " 1. sticky buffer: buffer mis-placed?
    let wmid = s:type2wmid(type)
    if s:wmid() > 0 && wmid != s:wmid()
        echo '== buffer ' . bufname('%') . ' window expect ' . wmid . ' but current is ' . s:wmid()
        if bufwinnr('#') > 0
            echo '== settle window'
            call s:wmsettle(wmid)
        else
            echo '== move buffer'
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
                echo '== move buffer to window ' . s:wmwinid(wmid)
                call s:wmsettle(wmid)
            else
                echo '== set new window ' . winid . ' for type ' . type
                call s:wmwinidset(wmid, winid)
                if type ==? 'docs' || type ==? 'quickfix'
                    exe 'resize ' . g:wm_height
                else
                    exe 'vertical resize ' . g:wm_width
                endif
            endif
        endif

        " rightbar: tagbar and codecompanion are mutually exclusive
        if type ==? 'tagbar' && s:wmwinid(4) > 0
            " Check if codecompanion window exists and close it
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
        elseif type ==? 'codecompanion' && s:wmwinid(4) > 0
            " Check if tagbar window exists and close it
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

function! s:close() abort
    if win_getid() != s:wmwinid(0)
        exe 'quit'
    else
        let bufnr = bufnr('%') " save bufnr
        let li = filter(range(1, bufnr('$')), 'buflisted(v:val) == 1 && v:val != ' . bufnr)
        if len(li) > 0
            " switch to previous buffer and delete current one
            exe 'bprev | bdelete ' . bufnr
        else
            echo "Last buffer, close it with :qa"
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
    autocmd BufDelete   * call s:wm_main()
    autocmd BufEnter    * call s:wm_update()
    " workarounds for NERDTree and Tagbar which set eventignore on creation
    autocmd FileType    nerdtree,tagbar,codecompanion call s:wm_update()

    autocmd BufEnter    term://* startinsert
    autocmd BufLeave    term://* stopinsert
augroup END

"if g:wm_debug | nnoremap <C-Y> :call <sid>wminfo()<cr> | endif

command! -nargs=0 BufferClose call <sid>close()
command! -nargs=0 BufferNext  call <sid>next()
command! -nargs=0 BufferPrev  call <sid>prev()
