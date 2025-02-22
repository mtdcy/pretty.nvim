" denite => maybe we should try ddu.vim

let g:denite_enabled = 1

" Denite {{{
if g:denite_enabled
    " FIXME: close after lose focus
    function! s:denite_ready() abort
        nnoremap <silent><buffer><expr> <cr>    denite#do_map('do_action')
        nnoremap <silent><buffer><expr> <space> denite#do_map('toggle_select').'j'      " select and move down
        nnoremap <silent><buffer><expr> /       denite#do_map('open_filter_buffer')     " search
        nnoremap <silent><buffer><expr> q       denite#do_map('quit')                   " quit
        nnoremap <silent><buffer><expr> <esc>   denite#do_map('quit')                   " quit

        setlocal termguicolors
        augroup denite_autocommands
            autocmd!
            " show and hide cursor
            autocmd BufEnter <buffer>
                        \ highlight Cursor blend=100
                        \ | setlocal guicursor+=a:Cursor/lCursor
            autocmd BufLeave <buffer>
                        \ highlight Cursor blend=0
                        \ | setlocal guicursor-=a:Cursor/lCursor
        augroup END
    endfunction

    function! s:denite_filter() abort
        imap <silent><buffer> <esc> <Plug>(denite_filter_quit)
        imap <silent><buffer> <cr>  <Plug>(denite_filter_update)
    endfunction

    function! s:denite_preview() abort
        setlocal number
    endfunction

    augroup DeniteSettings
        autocmd!
        autocmd FileType denite         call s:denite_ready()
        autocmd FileType denite-filter  call s:denite_filter()
        autocmd User     denite-preview call s:denite_preview()
    augroup END

    call denite#custom#option('_', {
                \ 'split'           : 'floating',
                \ 'floating_border' : 'rounded',
                \ 'match_highlight' : 0,
                \ 'smartcase'       : 0,
                \ 'auto_resize'     : 1,
                \ 'max_dynamic_update_candidates' : 100000,
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
                \   g:denite_fuzzy_matcher,
                \   'matcher/substring',
                \   'matcher/ignore_current_buffer'
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
    let g:fruzzy#usenative = 1
    let g:fruzzy#sortonempty = 1
endif
" }}}

if g:denite_enabled
    command! -nargs=0 Finder Denite -start-filter file/rec
    command! -nargs=0 Buffer Denite -no-empty buffer
    command! -nargs=0 Search DeniteCursorWord -no-empty grep:::!
endif
