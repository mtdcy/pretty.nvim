" nerdtree + denite + fruzzy

let g:nerdtree_enabled = 1
let g:denite_enabled = 1

" NERDTree {{{
if g:nerdtree_enabled
    "  Bug: VCS will ignore submodule
    let g:NERDTreeWinPos = 'left'
    let g:NERDTreeNaturalSort = 1
    let g:NERDTreeMouseMode = 1 " double click
    let g:NERDTreeShowHidden = 1
    let g:NERDTreeIgnore = [
                \ '\~$', '.DS_Store', '*.pyc',
                \ '.git$', '__pycache__',
                \ '#recycle', '@eaDir'
                \ ]
    let g:NERDTreeRespectWildIgnore = 1
    let g:NERDTreeWinSize = min([30, winwidth(0) / 4])
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeMinimalMenu=1
    let g:NERDTreeAutoDeleteBuffer=1 " drop invalid buffer after rename or delete
    let g:nerdtreedirarrowcollapsible=''
    let g:nerdtreedirarrowexpandable=''
    "" Netrw: disable for now, test later
    let g:NERDTreeHijackNetrw = 0
    "" cancel some key mappings: too much mappings won't help user
    ""  => keep only: Enter, Space, Mouse, F1/?
    "let g:NERDTreeMapActivateNode = ''
endif
" }}}

" 扩展 => Denite {{{
if g:denite_enabled
    autocmd FileType denite call DeniteReady()
    function! DeniteReady() abort
        nnoremap <silent><buffer><expr> <cr>    denite#do_map('do_action')
        nnoremap <silent><buffer><expr> <space> denite#do_map('toggle_select').'j'      " select and move down
        nnoremap <silent><buffer><expr> /       denite#do_map('open_filter_buffer')     " search
        nnoremap <silent><buffer><expr> q       denite#do_map('quit')                   " quit
        nnoremap <silent><buffer><expr> <esc>   denite#do_map('quit')                   " quit
    endfunction

    autocmd FileType denite-filter call DeniteFilter()
    function! DeniteFilter() abort
        inoremap <silent><buffer>       <esc>   <Plug>(denite_filter_quit)
    endfunction

    call denite#custom#option('_',
                \ 'max_dynamic_update_candidates', 100000
                \ )
    call denite#custom#option('default', {
                \ 'split'           : 'floating',
                \ 'floating_border' : 'rounded',
                \ 'match_highlight' : 0,
                \ 'smartcase'       : 1,
                \ })

    " fruzzy is much faster than fuzzy
    call denite#custom#source('file/rec', {
                \ 'matchers' : [
                \   'matcher/fruzzy',
                \   'matcher/hide_hidden_files',
                \   'matcher/ignore_globs'
                \ ]})
    call denite#custom#filter('matcher/ignore_globs', 'ignore_globs', [
                \ '*~', '*.o', '*.exe', '*.bak', '*.a', '*.so', '*.so.*',
                \ '.DS_Store', '*.pyc', '*.sw[po]', '*.class',
                \ '.hg/', '.git/', '.bzr/', '.svn/', '.ccache/',
                \ ])

    " ripgrep is much faster
    if executable('rg')
        call denite#custom#var('file/rec', 'command', [
                    \ 'rg', '--files', '--glob', '!.git', '--color', 'never'
                    \ ])

        call denite#custom#var('grep', {
                    \ 'command': ['rg'],
                    \ 'default_opts': ['-i', '--vimgrep', '--no-heading'],
                    \ 'recursive_opts': [],
                    \ 'pattern_opt': ['--regexp'],
                    \ 'separator': ['--'],
                    \ 'final_opts': [],
                    \ })
    endif

    " enhanced filter: fruzzy
    "  => 'call fruzzy#install()' to install native libraries
    let g:fruzzy#usenative = 1
endif
" }}}

if g:nerdtree_enabled
    " open or close explorer
    command! -nargs=0 Explorer exe 'NERDTreeToggle'

    " open or focus explorer
    command! -nargs=0 ExplorerFocus
                \ if bufwinnr('NERD_tree') == -1 | exe 'Explorer'
                \ | else | exe bufwinnr('NERD_tree') . 'wincmd w' | endif
endif

if g:denite_enabled
    command! -nargs=0 Finder exe "Denite -start-filter file/rec"
    command! -nargs=0 Buffer exe "Denite -auto-resize buffer"
endif
