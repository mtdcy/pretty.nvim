" denite => maybe we should try ddu.vim

let g:denite_enabled = 1

if g:denite_enabled
    command! -nargs=0 Finder Denite -buffer-name=search -start-filter file/rec
    command! -nargs=0 Buffer Denite -buffer-name=search -no-empty buffer
    command! -nargs=0 Search DeniteCursorWord -buffer-name=search -no-empty grep:::!
    command! -nargs=0 Menu   Denite menu:main

    " Denite Settings {{{
    " FIXME: close after lose focus
    function! s:denite_ready() abort
        " line numbers for selection
        if bufname('%') =~? 'search$'
            setlocal number
        else
            setlocal number&
        endif

        " kep mappings
        nnoremap <silent><buffer><expr> <cr>    denite#do_map('do_action')
        nnoremap <silent><buffer><expr> <space> denite#do_map('toggle_select').'j'      " select and move down
	    nnoremap <silent><buffer><expr> p       denite#do_map('do_action', 'preview')   " preview
        nnoremap <silent><buffer><expr> /       denite#do_map('open_filter_buffer')     " search
        nnoremap <silent><buffer><expr> w       denite#do_map('do_action', 'delete')    " delete buffer
        nnoremap <silent><buffer><expr> q       denite#do_map('quit')                   " quit
        nnoremap <silent><buffer><expr> <Esc>   denite#do_map('quit')                   " quit
        nnoremap <silent><buffer><expr> <BS>    denite#do_map('restore_sources')        " back
        nnoremap <silent><buffer><expr> <tab>   'j'                                     " move down

        " quit denite and enter insert mode
        nnoremap <silent><buffer><expr> i       denite#do_map('quit').'i'
        nnoremap <silent><buffer><expr> I       denite#do_map('quit').'I'
        nnoremap <silent><buffer><expr> a       denite#do_map('quit').'a'
        nnoremap <silent><buffer><expr> A       denite#do_map('quit').'A'
        nnoremap <silent><buffer><expr> u       denite#do_map('quit').'u'
        nnoremap <silent><buffer><expr> U       denite#do_map('quit').'U'

        " select by numbers
        nnoremap <silent><buffer><expr> 1       '1G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 2       '2G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 3       '3G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 4       '4G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 5       '5G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 6       '6G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 7       '7G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 8       '8G'.denite#do_map('do_action')
        nnoremap <silent><buffer><expr> 9       '9G'.denite#do_map('do_action')
    endfunction

    function! s:denite_filter() abort
        imap <silent><buffer> <esc> <Plug>(denite_filter_quit)
        imap <silent><buffer> <cr>  <Plug>(denite_filter_update)
        imap <silent><buffer> <tab> <Plug>(denite_filter_update)
    endfunction

    function! s:denite_preview() abort
        setlocal bufhidden=hide
        setlocal buftype=nofile
        setlocal number&
        setlocal buflisted&

        augroup denite_preview
            autocmd!
        augroup END
    endfunction

    augroup DeniteSettings
        autocmd!
        autocmd FileType denite         call s:denite_ready() | call HideCursor()
        autocmd FileType denite-filter  call s:denite_filter()
        autocmd User     denite-preview call s:denite_preview()
    augroup END

    " floating preview is not well defined
    call denite#custom#option('_', {
                \   'max_dynamic_update_candidates' : 100000,
                \   'split'                         : 'floating',
                \   'floating_border'               : 'rounded',
                \   'floating_preview'              : 0,
                \   'match_highlight'               : 0,
                \   'smartcase'                     : 0,
                \   'auto_resize'                   : 1,
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
                \   'matcher/substring',
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
    let g:fruzzy#usenative = filereadable(g:pretty_home . '/rplugin/python3/fruzzy_mod.so')
    let g:fruzzy#sortonempty = 1
    " }}}

    " Denite Menu {{{
    let s:menus = {}

    let s:menus.nvim = {
                \ 'command_candidates' : [
                \   [ '1. init.vim                  ', 'edit ' . $MYVIMRC                    ],
                \   [ '2. init/...                  ', 'Denite -path=' . g:pretty_home . '/init file/rec' ],
                \ ]}

    let s:menus.edit = {
                \ 'command_candidates' : [
                \   [ '1. Undo               u  ', 'undo                                    '],
                \   [ '2. Redo               U  ', 'redo                                    '],
                \   [ '3. Format code           ', 'ALEFix                                  '],
                \   [ '4. Edit nvim ...         ', 'Denite menu:nvim                        '],
                \ ]}

    let s:menus.move = {
                \ 'command_candidates' : [
                \   [ '1. Move above    CTRL-k  ', 'wincmd k                                '],
                \   [ '2. Move below    CTRL-j  ', 'wincmd j                                '],
                \   [ '3. Move left     CTRL-h  ', 'wincmd h                                '],
                \   [ '4. Move right    CTRL-l  ', 'wincmd l                                '],
                \ ]}

    let s:menus.main = {
                \ 'command_candidates' : [
                \   [ '1. Finder        CTRL-o  ', 'Finder                                  '],
                \   [ '2. Buffer        CTRL-e  ', 'Buffer                                  '],
                \   [ '3. Search        CTRL-g  ', 'Denite -start-filter grep:::!           '],
                \   [ '4. Edit ...              ', 'Denite menu:edit                        '],
                \   [ '5. Move ...              ', 'Denite menu:move                        '],
                \   [ '6. Explorer          F9  ', 'Explorer                                '],
                \   [ '7. Taglist          F10  ', 'Taglist                                 '],
                \   [ '8. LazyGit          F12  ', 'VCS                                     '],
                \   [ '9. Close         CTRL-w  ', 'BufferClose                             '],
                \   [ 'Quit                     ', 'confirm quit                            '],
                \   [ 'Help                     ', 'edit ' . g:pretty_home . '/README.md    '],
                \ ]}

    call denite#custom#var('menu', 'menus', s:menus)
    " }}}
endif
