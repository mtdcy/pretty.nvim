"=============================================================================
" FILE: prettifier-tab.vim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================

if exists('g:did_prettifiertab')
  finish
endif
let g:did_prettifiertab = 1

" text before cursor
function! s:typed_line() abort
    let c = col('.') - 1
    return c > 0 ? getline('.')[:c-1] : ''
endfunction

" new line? => insert indent => :h i_CTRL-T
function! s:check_new_line() abort
    let typed_line = <sid>typed_line()
    " :h expr4 for compare op help
    if &ft == 'markdown'                    | return typed_line =~ '\s*\(-\|\*\|\d\+\)\s\+$'
    elseif &ft == 'yaml'                    | return typed_line =~ '\s*.*\(-\|:\)\s*$'
    else                                    | return typed_line == ''
    endif
endfunction

" new start? => insert tab
function! s:check_new_start() abort
    let typed_line = <sid>typed_line()
    " space before cursor?
    return typed_line[-1:] =~ '\s'
endfunction

" Tab: 开始补全，选择候选词，snippets, Tab
function! s:i_tab() abort
    if pumvisible()                         | return "\<C-N>"
    elseif <sid>check_new_line()            | return "\<C-T>"
    elseif <sid>check_new_start()
        if exists('*neosnippet#jumpable')
            if neosnippet#jumpable()        | return "\<Plug>(neosnippet_jump)"
            else                            | return "\<Tab>"
            endif
        else                                | return "\<Tab>"
        endif
    elseif exists('g:deoplete#enable_at_startup') && g:deoplete#enable_at_startup
        if deoplete#can_complete()          | return deoplete#complete()
        else                                | return "\<Tab>"
        endif
    else                                    | return "\<C-X>\<C-O>"
    endif
endfunction

" Enter: snippets + complete
function! s:i_enter() abort
    let comp = complete_info()
    if comp['selected'] >= 0 
        if exists('*neosnippet#expandable')
            if neosnippet#expandable()      | return "\<C-Y>\<Plug>(neosnippet_expand)"
            else                            | return "\<C-Y>"
            endif
        else                                | return "\<C-Y>"
        endif
    elseif comp['pum_visible']              | return "\<C-E>\<CR>"
    else                                    | return "\<CR>"
    endif
endfunction  

" Space: complete only
function! s:i_space() abort
    let comp = complete_info()
    if comp['selected'] >= 0              | return "\<C-Y>\<Space>"
    elseif comp['pum_visible']            | return "\<C-E>\<Space>"
    else                                  | return "\<Space>"
    endif
endfunction

" Backspace: cancel
function! s:i_backspace() abort
    let comp = complete_info()
    if comp['selected'] >= 0              | return "\<C-E>"
    elseif comp['pum_visible']            | return "\<C-E>\<BS>"
    else                                  | return "\<BS>"
    endif
endfunction

function! prettifier#tab#init() abort
    inoremap <expr><C-L>    <sid>typed_line()
    inoremap <expr><Tab>    <sid>i_tab()
    inoremap <expr><Enter>  <sid>i_enter()
    noremap! <expr><Space>  <sid>i_space()
    inoremap <expr><BS>     <sid>i_backspace()
    " Esc: 取消已经填充的部分并退出插入模式
    inoremap <expr><Esc>    pumvisible() ? "\<C-E>\<Esc>"   : "\<Esc>"
    cnoremap <expr><Esc>    pumvisible() ? "\<C-E>"         : "\<C-C>"
    " => cuase floating window can't be closed by esc.
    "tnoremap <Esc>          <C-\><C-N>
    " Arrow Keys: 选择、选取、取消候选词
    noremap! <expr><Down>   pumvisible() ? "\<C-N>"         : "\<Down>"
    noremap! <expr><Up>     pumvisible() ? "\<C-P>"         : "\<Up>"
    noremap! <expr><Left>   pumvisible() ? "\<C-E>"         : "\<Left>"
    noremap! <expr><Right>  pumvisible() ? "\<C-Y>"         : "\<Right>"
    noremap! <expr><S-Tab>  pumvisible() ? "\<C-E>\<C-D>"   : "\<C-D>"
    nnoremap <S-Tab>        <<
endfunction
