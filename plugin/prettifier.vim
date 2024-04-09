"=============================================================================
" FILE: prettifier.vim
" AUTHOR:  Chan Fang <mtdcy.chen at gmail.com>
" License: BSD 2-Clause
"=============================================================================

if exists('g:did_prettifier')
  finish
endif
let g:did_prettifier = 1

function! PrettifyInit() abort
    call prettifier#tab#init()
    call prettifier#wm#init()
endfunction

function! PrettifyReload(filename) abort
    exec ":source " . a:filename
    call PrettifyInit()
endfunction

call PrettifyInit()
autocmd BufWritePost autoload/prettifier/* :call PrettifyReload(expand('<afile>'))
