scriptencoding utf-8
" Author: w0rp <devw0rp@gmail.com>
" Author: Luan Santos <cfcluan@gmail.com>
" Description: Shows lint message for the current line as virtualtext, if any

if !hlexists('ALEVirtualTextError')
    highlight link ALEVirtualTextError SpellBad
endif

if !hlexists('ALEVirtualTextStyleError')
    highlight link ALEVirtualTextStyleError ALEVirtualTextError
endif

if !hlexists('ALEVirtualTextWarning')
    highlight link ALEVirtualTextWarning SpellCap
endif

if !hlexists('ALEVirtualTextStyleWarning')
    highlight link ALEVirtualTextStyleWarning ALEVirtualTextWarning
endif

if !hlexists('ALEVirtualTextInfo')
    highlight link ALEVirtualTextInfo ALEVirtualTextWarning
endif

" Controls the milliseconds delay before showing a message.
let g:ale_virtualtext_delay = get(g:, 'ale_virtualtext_delay', 10)
let s:cursor_timer = get(s:, 'cursor_timer', -1)
let s:last_pos = get(s:, 'last_pos', [0, 0, 0])
let s:hl_list = get(s:, 'hl_list', [])

if !has_key(s:, 'has_virt_text')
    let s:has_virt_text = 0
    let s:emulate_virt = 0
    let s:last_virt = -1

    if has('nvim-0.3.2')
        let s:ns_id = nvim_create_namespace('ale')
        let s:has_virt_text = 1
    elseif has('textprop') && has('popupwin')
        let s:has_virt_text = 1
        let s:emulate_virt = !has('patch-9.0.0297')

        if s:emulate_virt
            call prop_type_add('ale', {})
        endif
    endif
endif

function! ale#virtualtext#Clear(buf) abort
    if !s:has_virt_text || !bufexists(str2nr(a:buf))
        return
    endif

    if has('nvim')
        call nvim_buf_clear_namespace(a:buf, s:ns_id, 0, -1)
    else
        if s:emulate_virt && s:last_virt != -1
            call prop_remove({'type': 'ale'})
            call popup_close(s:last_virt)
            let s:last_virt = -1
        elseif !empty(s:hl_list)
            call prop_remove({
            \ 'types': s:hl_list,
            \ 'all': 1,
            \ 'bufnr': a:buf})
        endif
    endif
endfunction

function! ale#virtualtext#ShowMessage(message, hl_group, buf, line) abort
    if !s:has_virt_text || !bufexists(str2nr(a:buf))
        return
    endif

    let l:line = max([1, a:line])
    let l:prefix = get(g:, 'ale_virtualtext_prefix', '> ')
    let l:msg = l:prefix.trim(substitute(a:message, '\n', ' ', 'g'))

    if has('nvim')
        call nvim_buf_set_virtual_text(a:buf, s:ns_id, l:line-1, [[l:msg, a:hl_group]], {})
    elseif s:emulate_virt
        let l:left_pad = col('$')
        call prop_add(l:line, l:left_pad, {
        \ 'type': 'ale',
        \})
        let s:last_virt = popup_create(l:msg, {
        \ 'line': -1,
        \ 'padding': [0, 0, 0, 1],
        \ 'mask': [[1, 1, 1, 1]],
        \ 'textprop': 'ale',
        \ 'highlight': a:hl_group,
        \ 'fixed': 1,
        \ 'wrap': 0,
        \ 'zindex': 2
        \})
    else
        let l:type = prop_type_get(a:hl_group)

        if l:type == {}
            call prop_type_add(a:hl_group, {'highlight': a:hl_group})
        endif

        " Add highlight groups to the list so we can clear them later.
        if index(s:hl_list, a:hl_group) == -1
            call add(s:hl_list, a:hl_group)
        endif

        " We ignore all errors from prop_add.
        silent! call prop_add(l:line, 0, {
        \ 'type': a:hl_group,
        \ 'text': ' ' . l:msg,
        \ 'bufnr': a:buf
        \})
    endif
endfunction

function! s:StopCursorTimer() abort
    if s:cursor_timer != -1
        call timer_stop(s:cursor_timer)
        let s:cursor_timer = -1
    endif
endfunction

function! ale#virtualtext#GetHlGroup(type, sub_type) abort
    if a:type is# 'E'
        if a:sub_type is# 'style'
            return 'ALEVirtualTextStyleError'
        endif

        return 'ALEVirtualTextError'
    endif

    if a:type is# 'W'
        if a:sub_type is# 'style'
            return 'ALEVirtualTextStyleWarning'
        endif

        return 'ALEVirtualTextWarning'
    endif

    return 'ALEVirtualTextInfo'
endfunction

function! ale#virtualtext#ShowCursorWarning(...) abort
    if g:ale_virtualtext_cursor isnot# 'current' && g:ale_virtualtext_cursor != 1
        return
    endif

    let l:buffer = bufnr('')

    if mode(1) isnot# 'n'
        return
    endif

    if ale#ShouldDoNothing(l:buffer)
        return
    endif

    let [l:info, l:loc] = ale#util#FindItemAtCursor(l:buffer)

    call ale#virtualtext#Clear(l:buffer)

    if !empty(l:loc)
        let l:msg = l:loc.text
        let l:type = get(l:loc, 'type', 'E')
        let l:style = get(l:loc, 'sub_type', '')
        let l:hl_group = ale#virtualtext#GetHlGroup(l:type, l:style)
        call ale#virtualtext#ShowMessage(l:msg, l:hl_group, l:buffer, line('.'))
    endif
endfunction

function! ale#virtualtext#ShowCursorWarningWithDelay() abort
    let l:buffer = bufnr('')

    if g:ale_virtualtext_cursor isnot# 'current' && g:ale_virtualtext_cursor != 1
        return
    endif

    if mode(1) isnot# 'n'
        return
    endif

    call s:StopCursorTimer()

    let l:pos = getpos('.')[0:2]

    " Check the current buffer, line, and column number against the last
    " recorded position. If the position has actually changed, *then*
    " we should show something. Otherwise we can end up doing processing
    " the show message far too frequently.
    if l:pos != s:last_pos
        let l:delay = ale#Var(l:buffer, 'virtualtext_delay')

        let s:last_pos = l:pos
        let s:cursor_timer = timer_start(
        \   l:delay,
        \   function('ale#virtualtext#ShowCursorWarning')
        \)
    endif
endfunction

function! ale#virtualtext#SetTexts(buf, loclist) abort
    if !has('nvim') && s:emulate_virt
        return
    endif

    call ale#virtualtext#Clear(a:buf)

    for l in a:loclist
        if l['bufnr'] != a:buf
            continue
        endif

        let l:hl = ale#virtualtext#GetHlGroup(l['type'], get(l, 'sub_type', ''))
        call ale#virtualtext#ShowMessage(l['text'], l:hl, a:buf, l['lnum'])
    endfor
endfunction
