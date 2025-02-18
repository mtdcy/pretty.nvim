" lightline + bufferline 

" => Options
let g:dark_mode = 1 " light or drak
let g:lightline_enabled = 1

" => Color and Theme
set termguicolors
if g:dark_mode
    set background=dark
else
    set background=light
endif
colorscheme solarized8
if !has('gui_running')
    set t_Co=256
endif
set guicursor=a:blinkwait5-blinkon5-blinkoff5

" => Font
if has('linux')
    "set guifont=Droid\ Sans\ Mono\ 13
    set guifont=DroidSansM\ Nerd\ Font\ Mono\ 12
else
    "set guifont=Droid\ Sans\ Mono:h13
    set guifont=DroidSansM\ Nerd\ Font\ Mono:h12
endif

if has('gui_running')
    if has('gui_win32')         " why this only work on win32 gui
        language en             " always English
        language messages en
    endif
    " remove left and right scrollbars
    set guioptions-=rl
else
    " fix paste without gui, like ssh + vim
    "set paste => cause inoremap stop working
    "set pastetoggle=<F12>
endif

" => Misc settings
" 显示行号
set number
" 上下移动时，留1行
set scrolloff=1
" 高亮当前行
set cursorline
set nocursorcolumn
" 语法高亮
syntax enable
"set regexpengine=1  " force old regex engine, solve slow problem
" 一直启动鼠标
set mouse=a

if g:lightline_enabled
    set laststatus=2
    set showtabline=2
    set noshowmode  " mode is displayed in the statusline
    " 把会跳变的元素放在左边最后一位或右边最前一位
    let g:lightline = {
                \ 'colorscheme'         : 'one',
                \ 'separator'           : { 'left' : "\ue0b0",          'right' : '' },
                \ 'subseparator'        : { 'left' : '',                'right' : '' },
                \ 'tabline'             : { 'left' : [[ 'buffers' ]],   'right' : [] },
                \ 'inactive'            : { 'left' : [[ 'filename' ]],  'right' : [] },
                \ 'active'              : {
                \   'left'              : [
                \       [ 'mode', 'paste' ],
                \       [ 'gitbranch' ],
                \       [ 'readonly', 'filename', 'modified' ]
                \ ],
                \   'right'             : [
                \       [ 'percent' ],
                \       [ 'datetime'],
                \       [ 'fileformat', 'fileencoding', 'filetype'],
                \       [ 'linter_ok', 'linter_errors', 'linter_warnings' ]
                \ ]},
                \ 'component'           : {
                \   'gitbranch'         : '%{GitBranch()}',
                \   'readonly'          : '%{&readonly ? "" : ""}',
                \   'filename'          : '%{RelativeFileName()}',
                \   'datetime'          : '%{strftime("%m-%d %H:%M:%S")}',
                \ },
                \ 'component_expand'    : {
                \   'buffers'           : 'lightline#bufferline#buffers',
                \   'linter_ok'         : 'lightline#ale#ok',
                \   'linter_infos'      : 'lightline#ale#infos',
                \   'linter_warnings'   : 'lightline#ale#warnings',
                \   'linter_errors'     : 'lightline#ale#errors',
                \ },
                \ 'component_type'      : {
                \   'buffers'           : 'tabsel',
                \   'linter_ok'         : 'right',
                \   'linter_infos'      : 'right',
                \   'linter_warnings'   : 'warning',
                \   'linter_errors'     : 'error',
                \ },
                \ 'component_raw'       : {
                \   'buffers'           : 1,
                \ }}

    let g:lightline#bufferline#enable_devicons = 1
    let g:lightline#bufferline#unicode_symbols = 1
    let g:lightline#bufferline#shorten_path = 0 " shorten path not readable
    let g:lightline#bufferline#smart_path = 1 " shorten path stop working if enabled
    let g:lightline#bufferline#clickable = 1
    "autocmd User LightlineBufferlinePreClick :echom "== clicked " . bufname('%')
    let g:lightline#bufferline#show_number = 2
    let g:lightline#bufferline#ordinal_number_map = {
                \ 0: '₀', 1: '₁', 2: '₂', 3: '₃', 4: '₄',
                \ 5: '₅', 6: '₆', 7: '₇', 8: '₈', 9: '₉',
                \ }

    let g:lightline#ale#indicator_checking = "\uf110 "
    let g:lightline#ale#indicator_infos = "\uf129 "
    let g:lightline#ale#indicator_warnings = "\uf071 "
    let g:lightline#ale#indicator_errors = "\uf05e "
    let g:lightline#ale#indicator_ok = "\uf00c"

    " 所有模式使用同样长度字符，防止界面抖动
    let g:lightline.mode_map = { 'n':'N', 'i':'I', 'R':'R', 'v':'v', 'V':'V', "\<C-v>":'v', 'c':'C', 's':'s', 'S':'S', "\<C-s>":'s', 't':'T' }
    function! GitBranch() abort
        let head = trim(system('git branch --show-current 2>/dev/null'))
        if head !=? ''
            let l:git = fnamemodify(finddir('.git', '.;'), ':p:h:h:t')
            let head = l:git . '  ' . head
        endif
        return head
    endfunction

    function! RelativeFileName() abort
        let l:bufname = bufname()
        if l:bufname =~# 'NERD_tree_\d\+'       | return 'NERDTree'
        elseif l:bufname =~# '__Tagbar__.\d\+'  | return 'Tagbar'
        elseif l:bufname =~# '\[denite\]-*'     | return 'denite'
        else                                    | return expand('%:~:.')
        endif
    endfunction
endif " lightline_enabled 
