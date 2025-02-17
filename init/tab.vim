"=============================================================================
" FILE: tab.vim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================

" text before cursor
function! s:typed_line() abort
    let c = col('.') - 1
    return c > 0 ? getline('.')[:c-1] : ''
endfunction

" new line? => insert indent => :h i_CTRL-T
function! s:is_new_line() abort
    let typed_line = <sid>typed_line()
    " :h expr4 for compare op help
    if &filetype ==? 'markdown'             | return typed_line =~# '\s*\(-\|\*\|\d\+\)\s\+$'
    elseif &filetype ==? 'yaml'             | return typed_line =~# '\s*.*\(-\|:\)\s*$'
    else                                    | return typed_line ==# ''
    endif
endfunction

" new start? => insert tab
function! s:is_new_word() abort
    let typed_line = <sid>typed_line()
    " space before cursor?
    return typed_line[-1:] =~# '\s'
endfunction

function! s:can_complete() abort
    if exists('g:deoplete#enable_at_startup') && g:deoplete#enable_at_startup
        return deoplete#can_complete()
    endif
    " is omnifunc defined?
    return &omnifunc !=# ''
endfunction

function! s:complete() abort
    if exists('g:deoplete#enable_at_startup') && g:deoplete#enable_at_startup
        return deoplete#complete()
    else
        " complete by omnifunc
        return "\<C-X>\<C-O>"
    endif
endfunction

function! s:can_jump() abort
    if exists('*neosnippet#jumpable') && neosnippet#jumpable() 
        return 1
    else
        return 0
    endif
endfunction

function! s:jump() abort
    return "\<Plug>(neosnippet_jump)"
endfunction

function! s:can_expand() abort
    if exists('*neosnippet#expandable') && neosnippet#expandable()     
        return 1
    else
        return 0
    endif
endfunction

function! s:expand() abort
    return "\<Plug>(neosnippet_expand)"
endfunction

" Tab: 开始补全，选择候选词，snippets, Tab
function! s:i_tab() abort
    if pumvisible()                         | return "\<C-N>"
    elseif s:is_new_line()                  | return "\<C-T>"
    elseif s:is_new_word()
        if s:can_jump()                     | return s:jump()
        else                                | return "\<Tab>"
        endif
    elseif s:can_complete()                 | return s:complete()
    elseif s:can_jump()                     | return s:jump()
    else                                    | return "\<Tab>"
    endif
endfunction

" Enter: complete + snippets
function! s:i_enter() abort
    let comp = complete_info()
    if comp['selected'] >= 0
        if s:can_expand()                   | return "\<C-Y>" . s:expand()
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

"inoremap <expr><C-L>    <sid>typed_line()
inoremap <expr><Tab>    <sid>i_tab()
inoremap <expr><Enter>  <sid>i_enter()
inoremap <expr><Space>  <sid>i_space()
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
