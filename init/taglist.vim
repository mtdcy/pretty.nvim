" Taglist

let g:tagbar_enabled = 1

" Tagbar => on fly tags {{{
if g:tagbar_enabled
    filetype on

    let g:tagbar_position = 'botright vertical'
    let g:tagbar_singleclick = 0
    let g:tagbar_sort = 0
    let g:tagbar_left = 0       " right
    let g:tagbar_silent = 1     " no echo to statusline
    let g:tagbar_compact = 1
    let g:tagbar_autofocus = 0  " if enabled, an empty tagbar opened
    let g:tagbar_autoshowtag = 1
    let g:tagbar_show_data_type = 1
    let g:tagbar_width = min([30, winwidth(0) / 4])
    let g:tagbar_no_status_line = 1
    " cancel some key mappings: too much mappings won't help user
    "  => keep only: Enter, Space, Mouse, F1/?
    let g:tagbar_map_hidenonpublic = ''
    let g:tagbar_map_openallfolds = ''
    let g:tagbar_map_closeallfolds = ''
    let g:tagbar_map_incrementfolds = ''
    let g:tagbar_map_decrementfolds = ''
    let g:tagbar_map_togglesort = ''
    let g:tagbar_map_toggleautoclose = ''
    let g:tagbar_map_togglecaseinsensitive = ''
    let g:tagbar_map_zoomwin = ''
    let g:tagbar_map_close = ''
    let g:tagbar_map_preview = ''
    let g:tagbar_map_previewwin = ''
    let g:tagbar_map_nexttag = ''
    let g:tagbar_map_prevtag = ''
    let g:tagbar_map_nextfold = ''
    let g:tagbar_map_prevfold = ''
    let g:tagbar_map_togglefold = ''
    let g:tagbar_map_togglepause = ''
    " multiple key mapping to these one, can't disable single one
    "let g:tagbar_map_openfold = ''
    "let g:tagbar_map_closefold = ''
endif
" }}}

if g:tagbar_enabled
    " open or close taglist
    command! -nargs=0 Taglist exe 'TagbarToggle'

    " open or focus taglist
    command! -nargs=0 TaglistFocus
                \ if bufwinnr('Tagbar') == -1 | call tagbar#OpenWindow()
                \ | else | exe bufwinnr('Tagbar') . 'wincmd w' | endif
endif
