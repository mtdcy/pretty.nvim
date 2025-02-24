" nerdtree

let g:nerdtree_enabled = 1

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

    autocmd FileType nerdtree call HideCursor()
endif
" }}}

if g:nerdtree_enabled
    " open or close explorer
    command! -nargs=0 Explorer NERDTreeToggle

    " open or focus explorer
    command! -nargs=0 ExplorerFocus
                \ if bufwinnr('NERD_tree') == -1
                \ |  exe 'NERDTree'
                \ | endif
                \ | exe bufwinnr('NERD_tree') . 'wincmd w'
endif
