" pretty.nvim, copyright 2023 (c) Chen Fang, mtdcy.chen@gmail.com

" {{{ => Settings

let g:pretty_verbose      = 1   " 0 - silence
let g:pretty_dark         = 1   " light or drak
let g:pretty_autocomplete = 1   " 0 - manual complete with Tab
let g:pretty_singleclick  = 1   " mouse single click
let g:pretty_delay        = 200 " in GUI mode, flicker less, shorten this value

" {{{ => Advance
let g:pretty_debug        = 1
let g:pretty_home         = fnamemodify($MYVIMRC, ':p:h')
let g:pretty_bar_height   = min([15, winheight(0) / 3])
let g:pretty_bar_width    = min([20, winwidth(0) / 4])

let $PATH = g:pretty_home .. '/node_modules/.bin:' .. $PATH
let $PATH = g:pretty_home .. '/py3env/bin:'        .. $PATH

" debugging
if g:pretty_debug | let g:pretty_cmdlet = ":normal! "
else              | let g:pretty_cmdlet = ":silent! "
endif

" window components id
let g:pretty_winids = [ win_getid(), 0, 0, 0, 0, 0 ]
" 1 - leftbar, 2 - headbar, 3 - footbar, 4 - rightbar, 5 - toc(right)

" floating window config - ':h nvim_open_win'
let g:pretty_window = {
            \ 'border'      : 'single',
            \ 'title'       : 'pretty.nvim',
            \ 'title_pos'   : 'center',
            \ 'style'       : 'minimal'
            \ }
" }}}
" }}}

" {{{ => General Options
" set color and theme
set termguicolors
if g:pretty_dark
    set background=dark
else
    set background=light
endif
colorscheme solarized8
if !has('gui_running')
  set t_Co=256
endif
set guicursor=a:blinkwait5-blinkon5-blinkoff5

" 字体
if has('gui_running')
    if has('linux')
        set guifont=Droid\ Sans\ Mono\ 13
    else
        set guifont=Droid\ Sans\ Mono:h13
    endif
    if has('gui_win32')         " why this only work on win32 gui
        language en             " always English
        language messages en
    endif
    " remove left and right scrollbars
    set guioptions-=rl
else
    " fix paste without gui, like ssh + vim
    "set paste => cause inoremap stop working
    set pastetoggle=<F12>https://vi.stackexchange.com/questions/4493/what-is-the-order-of-winenter-bufenter-bufread-syntax-filetype-events
endif

" 显示行号
set number

" 不备份文件
set nobackup" 1 - leftbar, 2 - headbar, 3 - footbar, 4 - rightbar, 5 - toc(right)
set nowritebackup

" 上下移动时，留1行
set scrolloff=1

" Don't ask me to save file before switching buffers
set hidden

" 高亮当前行
set cursorline
set nocursorcolumn

" 语法高亮
syntax enable
"set regexpengine=1  " force old regex engine, solve slow problem

" 使用非兼容模式
set nocompatible

" 一直启动鼠标
set mouse=a

" show command on the bottom of the screen
set showcmd

" set backspace behavior
set backspace=indent,eol,start

" no bracket match
set noshowmatch

if g:pretty_verbose
    set updatetime=1000
else
    set updatetime=3000
endif
" }}}

" {{{ => Search:
" 有关搜索的选项
set hlsearch
set incsearch
set smartcase
au InsertEnter * set noic
au InsertLeave * set ic
" }}}

" {{{ => File Format
" tabstop       - tab宽度
" shiftwidth    - 自动缩进宽度
" expandtab     - 是否展开tab
" softtabstop   - 按下tab时的宽度（用tab和space组合填充）=> 比较邪恶

" For all
filetype plugin indent on

" common settings
set tabstop=4 shiftwidth=4
set expandtab
set autoindent
set smartindent
set cindent
" 文本宽, 有些过时了
set textwidth&
" 用Tab和Space组合填充Tab => 比较邪恶
set softtabstop&

"set cinwords=if,else,while,do,for,switch
"set cinkeys=0{,0},0(,0),0[,0],:,;,0#,~^F,o,O,0=if,e,0=switch,0=case,0=break,0=whilea,0=for,0=do
"set cinoptions=>s,e0,n0,f0,{0,}0,^0,Ls,:s,=s,l1,b1,g0,hs,N-s,E-s,ps,t0,is,+-s,t0,cs,C0,/0,(0,us,U0,w0,W0,k0,m1,M0,#0,P0

" 文件编码
set fileencoding=utf-8
set fileencodings=utf-8,gb18030,gbk,latin1

" 文件类型
set fileformat=unix
set fileformats=unix,dos

" Fold: 自动打开，但不自动关闭
"  => 所以'zc'就没意义了，重新绑定到'zM'
nnoremap zc zM
nnoremap zC zM
nnoremap zo zR
set foldenable
set foldopen=all
set foldmethod=syntax
set foldlevel=0
set foldnestmax=2

augroup pretty.files
    au!
    " 自动跳转到上一次打开的位置
    au BufReadPost  * silent! call <SID>jump_to_las_pos()
    " set extra properties for interest files
    au FileType vim setlocal foldmethod=marker
    au FileType markdown,yaml setlocal ts=2 sw=2
    au FileType python setlocal expandtab&
augroup END

function! s:jump_to_las_pos()
    if line("'\"") > 0 && line ("'\"") <= line('$') && &filetype !~# 'commit'
        exec g:pretty_cmdlet .. "g'\""
    endif
endfunction
"}}}

" {{{ => Plugins

" {{{ => bufexplorer
" NOTHING HERE
" }}}

" {{{ => echodoc
let g:echodoc#enable_at_startup = 1
if g:echodoc#enable_at_startup
    if has('nvim')
        let g:echodoc#type = 'floating'
        let g:echodoc#floating_config = g:pretty_window
    else
        let g:echodoc#type = 'popup'
    endif
    highlight link EchoDocFloat Pmenu
endif
" }}}

" {{{ => signify
let g:signify_disable_by_default = 0
let g:signify_number_highlight = 1
" }}}

" {{{ => ALE
let g:ale_enabled = 1
if g:ale_enabled
    " always set omnifunc here, can be used as source for others
    "  or be replaced by others later
    set omnifunc=ale#completion#OmniFunc " => 支持手动补全
    let g:ale_completion_enabled = 0     " => prefer deoplete
    if g:ale_completion_enabled
        let g:ale_completion_autoimport = 1
        let g:ale_completion_delay = g:pretty_delay
        set completeopt-=preview
        set paste& " ALE complete won't work with paste
    endif

    " 默认：只显示左侧图标，不显示virtualtext，
    "   => ale对floating window的控制逻辑有点乱，这里只使用virtualtext
    let g:ale_set_signs = 1
    let g:ale_sign_priority = 100
    let g:ale_set_highlights = 1
    let g:ale_sign_highlight_linenrs = 1
    let g:ale_sign_column_always = 1
    let g:ale_virtualtext_delay = g:pretty_delay
    let g:ale_virtualtext_cursor = 'current'
    let g:ale_set_loclist = 1
    let g:ale_open_list = 0
    if g:pretty_verbose
        let g:ale_virtualtext_cursor = 'all'
        let g:ale_open_list = 'on_save' " loclist for errors and warnings
    endif

    " Errors:
    let g:ale_echo_cursor = 0       " error message to statusline
    let g:ale_cursor_detail = 0     " error message to preview window
    let g:ale_floating_preview = 0  " error message to floating preview

    " Hover: 显示光标处函数签名
    let g:ale_hover_cursor = 1      " to statusline by default
    let g:ale_hover_to_preview = 0  " preview window
    let g:ale_hover_to_floating_preview = 0 " to floating preview
    " => 使用语言特定插件的功能更好一些

    " Linters:
    let g:ale_lint_delay = 1000     " see following BUG
    let g:ale_lint_on_enter = 1
    let g:ale_lint_on_save = 1
    let g:ale_lint_on_insert_leave = 1
    " BUG: 'never' never work
    let g:ale_lint_on_text_changed = 'never'
    " 显式指定linter和fixer => 通常情况均为一个，防止竞争的情况出现
    let g:ale_linters_explicit = 1
    let g:ale_linters = {
                \ 'sh'          : ['shellcheck'],
                \ 'c'           : ['cc'],
                \ 'cpp'         : ['cc'],
                \ 'vim'         : ['vimls'],
                \ 'go'          : ['gopls'],
                \ 'rust'        : ['cargo', 'rustc'],
                \ 'cmake'       : ['cmakelint'],
                \ 'dockerfile'  : ['hadolint'],
                \ 'html'        : ['htmlhint'],
                \ 'java'        : ['javac'],
                \ 'javascript'  : ['eslint'],
                \ 'json'        : ['jsonlint'],
                \ 'markdown'    : ['markdownlint'],
                \ 'yaml'        : ['yamllint'],
                \ 'python'      : ['pylint'],
                \ }

    function! CheckConfig(prefix, target)
        let l:found=findfile(a:target, ".;")
        if l:found != ''
            return a:prefix . found
        endif
        return ''
    endfunction
    "let g:ale_sh_shellcheck_executable = g:pretty_home . '/node_modules/.bin/shellcheck'
    "let g:ale_vim_vimls_executable = g:pretty_home . '/node_modules/.bin/vim-language-server'
    "let g:ale_html_htmlhint_executable = g:pretty_home . '/node_modules/.bin/htmlhint'
    "let g:ale_markdown_markdownlint_executable = g:pretty_home . '/node_modules/.bin/markdownlint'
    "let g:ale_dockerfile_hadolint_options = '--ignore DL3059'
    "let g:ale_html_htmlhint_options = '--rules error/attr-value-double-quotes=false'
    let g:ale_markdown_markdownlint_options = CheckConfig('--config ', '.markdownlint.yaml')
    let g:ale_yaml_yamllint_options = '-d relaxed'
    "let g:ale_python_pylint_options = '--errors-only'
    let g:ale_python_pylint_options = '--ignore-docstrings'

    let g:ale_fix_on_save=1
    let g:ale_fixers = {
                \ '*'           : ['remove_trailing_lines', 'trim_whitespace'],
                \ 'sh'          : ['shfmt'],
                \ 'c'           : ['clang-format'],
                \ 'cpp'         : ['clang-format'],
                \ 'go'          : ['goimports', 'gopls'],
                \ 'rust'        : ['rustfmt'],
                \ 'cmake'       : ['cmakeformat'],
                \ 'html'        : ['prettier'],
                \ 'java'        : ['clang-format'],
                \ 'javascript'  : ['prettier_eslint'],
                \ 'json'        : ['clang-format'],
                \ 'markdown'    : ['prettier'],
                \ 'yaml'        : ['yamlfix'],
                \ 'python'      : ['autopep8'],
                \ }
                "\ 'dockerfile'  : ['dprint'],

    " autoload/afe/fixers/clangformat.vim can not handle path properly
    "let g:ale_c_clangformat_executable = g:pretty_home . '/node_modules/.bin/clang-format'
    "let g:ale_javascript_prettier_executable = g:pretty_home . '/node_modules/.bin/prettier'
    let g:ale_c_clangformat_options = '--verbose --style="{ BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4 }"'
    let g:ale_sh_shfmt_options = '--indent=4 --case-indent --keep-padding'
    let g:ale_rust_rustfmt_options = '--force --write-mode replace'
    "let g:ale_cmake_cmakeformat_executable = 'cmake-format'
    let g:ale_cmake_cmakeformat_options = ''
    let g:ale_yaml_yamlfix_options = ''

endif
" }}}

" {{{ => vim-go
if g:ale_enabled
    let g:go_code_completion_enabled = 0
else
    let g:go_code_completion_enabled = 1
endif

set autowrite   " auto save file before run or build
let g:go_def_mode = 'gopls'
let g:go_info_mode = 'gopls'
let g:go_fmt_command = 'gopls'
let g:go_imports_mode = 'gopls'
let g:go_fillstruct_mode = 'gopls'
" BUG: not working
let g:go_def_reuse_buffer = 1

" linter and formatter => prefer ale
if !g:ale_enabled
    let g:go_metalinter_autosave = 1
    let g:go_imports_autosave = 1
    let g:go_fmt_autosave = 1
    let g:go_mod_fmt_autosave = 1
endif

" 查看变量和函数信息，这个在读代码时非常有用
let g:go_auto_sameids = 1   " highlight word under cursor
let g:go_auto_type_info = 1 " type info for word under cursor
let g:go_updatetime = max([3000, g:pretty_delay * 5]) " shorten this value as go code usually omit type
if g:pretty_verbose
    let g:go_updatetime = g:pretty_delay
endif
" => ale hover perform the same actions.

let g:go_doc_keywordprg_enabled = 0     " godoc - ':h K'
" BUG: first doc windows determine the size
let g:go_doc_max_height = 10

" use Terminal for GoRun
" BUG: the height not working
let g:go_term_enabled = 1
let g:go_term_reuse = 1
let g:go_term_height = 20
let g:go_term_close_on_exit = 0
let g:go_term_mode = "split"

let g:go_highlight_types = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_string_spellcheck = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_diagnostic_errors = 1
let g:go_highlight_diagnostic_warnings = 1

let g:go_fold_enable = ['block', 'import', 'varconst', 'package_comment']
" }}}

" {{{ => vim-racer
let g:racer_experimental_completer = 1
" }}}

" {{{ => deoplete
" 只开启一个自动补全插件 => 目录来看deoplete的补全功能更强一些
if exists('g:ale_completion_enabled') && g:ale_completion_enabled
    let g:deoplete#enable_at_startup = 0
else
    let g:deoplete#enable_at_startup = 1
endif

if g:deoplete#enable_at_startup
    " neosnippet: 与deoplete配合
    let g:neosnippet#enable_snipmate_compatibility = 1

    set completeopt=menu,noselect,noinsert
    " scan only tags and buffers => :h 'complete'
    "  => deep scan by deoplete and ale
    set complete=t,.,b,u,w
    set paste&
    set pumheight=10
    " wish to have 'longest', but deoplete can work with it.

    if g:ale_enabled
        " ALE as completion source for deoplete
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['ale', 'buffer', 'file', 'neosnippet'],
                    \ })
    else
        " 为每个语言定义completion source
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['buffer', 'file', 'neosnippet'],
                    \   'cpp'   : ['LanguageClient'],
                    \   'c'     : ['LanguageClient'],
                    \   'vim'   : ['vim'],
                    \ })
    endif

    " complete with vim-go => 手动模式omni不工作，为什么？
    if g:go_code_completion_enabled
        call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })
    endif

    if g:pretty_autocomplete
        " 自动补全时给一个较大的延时
        "  => 打字够快，补全就不会干扰
        call deoplete#custom#option({
                    \ 'auto_complete_delay' : g:pretty_delay,
                    \ })
    else
        " 后台自动补全，前台手动显示候选列表
        "  => 不仅实现了自动补全，同时还减少的界面打扰
        call deoplete#custom#option({
                    \ 'auto_complete_popup' : 'manual',
                    \ 'auto_complete_delay' : 0,
                    \ })
    endif

    call deoplete#custom#source('_', 'smart_case', v:true)
    " complete cross filetype
    call deoplete#custom#var('buffer', 'require_same_filetype', v:false)

    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1] =~# '\s'
    endfunction
    function! s:check_snippet_jump() abort
        return neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)" : "\<Tab>"
    endfunction

    " Tab: 开始补全，选择候选词，snippets, Tab
    function! SuperTab() abort
        if pumvisible()                | return "\<C-N>"
        elseif <sid>check_back_space() | return <sid>check_snippet_jump()
        elseif deoplete#can_complete() | return deoplete#complete()
        elseif neosnippet#jumpable()   | return <sid>check_snippet_jump()
        else                           | return "\<Tab>"
        endif
    endfunction

    " Enter: snippets + complete
    function! SuperEnter() abort
        let comp = complete_info()
        if neosnippet#expandable()     | return "\<Plug>(neosnippet_expand)"
        elseif comp['selected'] >= 0   | return "\<C-Y>"
        elseif comp['pum_visible']     | return "\<C-E>\<cr>"
        else                           | return "\<cr>"
        endif
    endfunction

    " Space: complete only
    function! SuperSpace() abort
        let comp = complete_info()
        if comp['selected'] >= 0       | return "\<C-Y>\<Space>"
        else                           | return "\<Space>"
        endif
    endfunction

    " Backspace: cancel
    function! SuperBack() abort
        let comp = complete_info()
        if comp['selected'] >= 0       | return "\<C-E>"
        elseif comp['pum_visible']     | return "\<C-E>\<BS>"
        else                           | return "\<BS>"
        endif
    endfunction
endif
" }}}

" {{{ => lightline
set laststatus=2
set showtabline=2
set noshowmode  " mode is displayed in the statusline
" 把会跳变的元素放在左边最后一位或右边最前一位
let g:lightline = {
            \ 'colorscheme'         : 'one',
            \ 'separator'           : { 'left' : "\ue0b4",          'right' : "\ue0b6" },
            \ 'subseparator'        : { 'left' : "",                'right' : "" },
            \ 'tabline'             : { 'left' : [[ 'buffers' ]],   'right' : [] },
            \ 'inactive'            : { 'left' : [[ 'filename' ]],  'right' : [['filetype' ]]},
            \ 'active'              : {
            \   'left'              : [
            \       [ 'mode', 'paste' ],
            \       [ 'gitbranch', 'readonly' ],
            \       [ 'filename', 'modified' ]
            \ ],
            \   'right'             : [
            \       [ 'percent' ],
            \       [ 'fileformat', 'fileencoding', 'filetype'],
            \       [ 'linter_ok', 'linter_errors', 'linter_warnings', 'linter_infos' ]
            \ ]},
            \ 'component'           : {
            \   'gitbranch'         : '%{&readonly ? "" : GitBranch()}',
            \   'readonly'          : '%{&readonly ? "\ue0a2" : ""}',
            \   'filename'          : '%{RelativeFileName()}',
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
            \ }}

let g:lightline#bufferline#clickable = 1
let g:lightline.component_raw = {'buffers': 1}
autocmd User LightlineBufferlinePreClick :echom "== clicked " .. bufname('%')
let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#ordinal_number_map = {
            \ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
            \ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹',
            \ }

" 所有模式使用同样长度字符，防止界面抖动
let g:lightline.mode_map = { 'n':'N', 'i':'I', 'R':'R', 'v':'v', 'V':'V', "\<C-v>":'v', 'c':'C', 's':'s', 'S':'S', "\<C-s>":'s', 't':'T' }
function! GitBranch() abort
    let l:git = fnamemodify(finddir('.git', '.;'), ':~:h')
    let head = FugitiveHead()
    if head != ""
        let head = l:git .. " \uf126 " . head
    endif
    return head
endfunction
function! RelativeFileName() abort
    let l:bufname = bufname()
    if l:bufname =~ 'NERD_tree_\d\+'      | return 'NERDTree'
    elseif l:bufname =~ '__Tagbar__.\d\+' | return 'Tagbar'
    else                                  | return expand('%:~:.')
    endif
endfunction
" }}}

" {{{ => tabular
" NOTHING HERE
" }}}

" }}}

" {{{ => Windows Manager

" NERDTree: {{{
"  Bug: VCS will ignore submodule
let g:NERDTreeWinPos = 'left'
let g:NERDTreeNaturalSort = 1
let g:NERDTreeMouseMode = g:pretty_singleclick + 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = ['\~$', '.git*', '.DS_Store' ]
let g:NERDTreeRespectWildIgnore = 1
let g:NERDTreeWinSize = min([30, winwidth(0) / 4])
let g:NERDTreeMinimalUI = 1
let g:NERDTreeMinimalMenu=1
let g:NERDTreeAutoDeleteBuffer=1    " drop invalid buffer after rename or delete
"" Netrw: disable for now, test later
let g:NERDTreeHijackNetrw = 0
"" cancel some key mappings: too much mappings won't help user
""  => keep only: Enter, Space, Mouse, F1/?
"let g:NERDTreeMapActivateNode = ''
" }}}

" Tagbar: use on fly tags {{{
let g:tagbar_singleclick = g:pretty_singleclick
let g:tagbar_position = 'botright vertical'
let g:tagbar_left = 0   " right
let g:tagbar_compact = 1
let g:tagbar_autofocus = 1
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
"}}}

set wildignore&
set noequalalways
set winheight=10
set winwidth=20
set winminheight=10
set winminwidth=20
set cmdheight=1

" check window parts, return filetype if it's sidebar.
function! s:wm_part_check(buf)
    let ftype = getbufvar(bufnr(a:buf), '&ft')
    if win_getid(winnr()) == g:pretty_winids[0]
        return ''
    elseif ftype == 'nerdtree' || ftype == 'tagbar'
        return ftype
    elseif ftype == 'help' || ftype == 'man' || ftype =~ '\.*doc'
        return 'docs'
    elseif ftype == 'qf' || getbufvar(bufnr(a:buf), '&bt') == 'quickfix'
        return ftype
    endif
    return ''
endfunction()

function! s:wm_part_inspect()
    echom 'perform hint @ buf:"' . bufname('%') . '"/alt:"' . bufname('#') . '"'
                \ . '/bufnr:' . bufnr() . '#' . bufnr('$')
                \ . '/ft:' . &ft . '/bt:' . &bt . '/mod:' . &mod . '/modi:'. &modifiable
                \ . '/hide:' . &bufhidden . '/buflisted:' . &buflisted . '/swapfile:' . &swapfile
                \ . '/winnr:' . winnr() . '#' . winnr('$') . '/id:' . win_getid()
                \ . '/type:' . win_gettype(winnr()) . '/winbufnr:' . winbufnr(winnr())
                \ . '/list:' . &list . '/cpoptions:' . &cpoptions
endfunction()
if g:pretty_debug == 1 | nnoremap <C-I> :call <sid>wm_part_inspect()<cr> | endif

" shorten the wincmd only, :h CTRL-W
function! s:wmcmd(id, cmd)
    return ":" .. win_id2win(g:pretty_winids[a:id]) .. "wincmd " .. a:cmd .. "\<cr>"
endfunction

function! s:wm_on_win_update()
    if win_getid() == g:pretty_winids[0] | return | endif
    "if g:pretty_debug | call <sid>wm_part_inspect() | endif
    " 1. sticky buffer: never open buffer in sidebars
    let l:buf = <sid>wm_part_check('%')
    let l:alt = <sid>wm_part_check('#')
    if l:alt != '' && l:buf != l:alt
        let l:bufnr = bufnr('%') " save bufnr
        echom "== open file in sidebar, swap it to main win."
        exec g:pretty_cmdlet .. ":buffer#\<cr>"
                    \ .. <sid>wmcmd(0, 'w')
                    \ .. ":buffer " .. l:bufnr .. "\<cr>"
    endif

    " 2. update winids
    " footbar & toc are quickfix|loclist, no way to tell here.
    if l:buf == 'docs'
        setlocal nobuflisted nolist nomodifiable
        " multiple document window types? yes! > help|man|doc
        if g:pretty_winids[2] > 0 && g:pretty_winids[2] != win_getid()
            " document window can be opened in many ways
            "  => move buffer to existing window
            let bufnr = bufnr('%') " save bufnr
            let nrbuf = len(filter(range(1, bufnr('$')), 'bufwinnr(v:val) == winnr('%')'))
            if nrbuf > 1 | exec g:pretty_cmdlet .. ":buffer#\<cr>"
            else         | exec g:pretty_cmdlet .. ":wincmd c\<cr>"
            endif
            exec g:pretty_cmdlet .. <sid>wmcmd(2, 'w')
                \ .. ":buffer" .. bufnr .. "\<cr>"
        elseif g:pretty_winids[2] <= 0
            exec g:pretty_cmdlet .. ":resize " .. g:pretty_bar_height .. "\<cr>"
            let g:pretty_winids[2] = win_getid()
        endif
    elseif l:buf == 'tagbar'
        let l:width = g:pretty_bar_width
        if g:pretty_winids[5] > 0
            echom "== toc closed as tagbar shows."
            let l:width = winwidth(win_id2win(g:pretty_winids[5]))
            exec g:pretty_cmdlet .. <sid>wmcmd(5, 'c')
        endif
        if g:pretty_winids[4] != win_getid()
            exec g:pretty_cmdlet .. ":vertical resize " .. l:width .. "\<cr"
            let g:pretty_winids[4] = win_getid()
        endif
    elseif l:buf == 'nerdtree'
        let l:width = g:pretty_bar_width
        if g:pretty_winids[1] != win_getid()
            exec g:pretty_cmdlet .. ":vertical resize " .. l:width .. "\<cr"
            let g:pretty_winids[1] = win_getid()
        endif
    endif
endfunction

" clean records on window close
"  XXX: don't use win_getid here, as au may be called outside window
function! s:wm_on_win_close(win) abort
    let winid = expand(a:win)
    if winid == g:pretty_winids[0]               | let g:pretty_winids[0] = -1
        for i in range(1, winnr('$'))            | let winid = win_getid(i)
            if index(g:pretty_winids, winid) < 0 | let g:pretty_winids[0] = winid | break
            endif
        endfor
        echom "== new main window " .. winid
    else                                         | let i = index(g:pretty_winids, expand('<amatch>'))
        if i >= 0                                | let g:pretty_winids[i] = -1
        endif
    endif
endfunction

function! s:wm_quit() abort
    if win_getid() != g:pretty_winids[0]
        exec g:pretty_cmdlet .. ":confirm quit\<cr>"
    else
        echohl WarningMsg
        let bufnr = bufnr('%') " save bufnr
        let listed = len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))
        if listed > 1 | exec g:pretty_cmdlet .. ":bprev\<cr> :confirm bdelete " .. bufnr .. "\<cr>"
        else          | echo "Last buffer, close it with :quit"
        endif
        echohl None
    endif
endfunction

augroup pretty.windows
    autocmd!
    autocmd BufEnter    * call <sid>wm_on_win_update()
    autocmd WinClosed   * call <sid>wm_on_win_close('<amatch>')
    " workarounds for NERDTree and Tagbar which set eventignore on creation
    autocmd FileType nerdtree,tagbar call <sid>wm_on_win_update()
    " quit window parts if main window went away
    autocmd BufEnter    * if !win_id2win(g:pretty_winids[0]) && <sid>wm_part_check('%') != '' | quit | endif

    autocmd BufEnter    term://* startinsert
    autocmd BufLeave    term://* stopinsert
augroup END

" {{{ => Key maps
" 非必要不加<silent>，这样我们可以很好的看到具体执行的命令
" 设置mapleader
let mapleader = ';'
let g:mapleader = ';'

" 已经有定义的按键:
"  - `w`, `b`   : word forward or backward
"  - `e`,       : word forward end
"  - `n`, `N`   : search next or prev
"  - `r`        : replace
"  - `i`, `I`   : insert, insert at line beginning
"  - `a`, `A`   : append, append at line end
"  - `o`, `O`   : new line after or before current line
"  - `y`, `Y`   : yank
"  - `p`, `P`   : paste after or before current cursor
"  ...
"  :h <char> 查看更多 => 最佳实践：使用<leader>
"
" About map - :h map-table
" => 注释不要写在map的后面，vim不会处理中间的空格

" 编辑和加载.vimrc/init.vim
nnoremap <leader>se :e $MYVIMRC<CR>
nnoremap <leader>ss :source $MYVIMRC<CR>

" Window
nnoremap <F8>       :ToggleBufExplorer<cr>
nnoremap <F9>       :NERDTreeToggle<cr>
nnoremap <F10>      :TagbarToggle<cr>

noremap  <C-q>      :call <sid>wm_quit()<cr>
tnoremap <C-q>      <C-\><C-N>:call <sid>wm_quit()<cr>

" Move focus
nnoremap <C-j>      <C-W>j
nnoremap <C-k>      <C-W>k
nnoremap <C-h>      <C-W>h
nnoremap <C-l>      <C-W>l
tnoremap <C-j>      <C-\><C-N><C-W>j
tnoremap <C-k>      <C-\><C-N><C-W>k
tnoremap <C-h>      <C-\><C-N><C-W>h
tnoremap <C-l>      <C-\><C-N><C-W>l

" Buffer
nnoremap <C-e>      :ToggleBufExplorer<cr>
nnoremap <C-n>      :bnext<cr>
nnoremap <C-p>      :bprev<cr>
tnoremap <C-n>      <C-\><C-N>:bnext<cr>
tnoremap <C-p>      <C-\><C-N>:bprev<cr>

" have to use <leader>, as Ctrl-numbers are likely unavailable.
nnoremap <leader>1  <Plug>lightline#bufferline#go(1)
nnoremap <leader>2  <Plug>lightline#bufferline#go(2)
nnoremap <leader>3  <Plug>lightline#bufferline#go(3)
nnoremap <leader>4  <Plug>lightline#bufferline#go(4)
nnoremap <leader>5  <Plug>lightline#bufferline#go(5)
nnoremap <leader>6  <Plug>lightline#bufferline#go(6)
nnoremap <leader>7  <Plug>lightline#bufferline#go(7)
nnoremap <leader>8  <Plug>lightline#bufferline#go(8)
nnoremap <leader>9  <Plug>lightline#bufferline#go(9)
nnoremap <leader>0  <Plug>lightline#bufferline#go(10)

" Special keys
inoremap <expr><Tab>    exists("*SuperTab")   ? SuperTab()   : pumvisible() ? "\<C-N>"         : "\<BS>"
inoremap <expr><Enter>  exists("*SuperEnter") ? SuperEnter() : pumvisible   ? "\<C-Y>"         : "\<cr>"
inoremap <expr><BS>     exists("*SuperBack")  ? SuperBack()  : pumvisible   ? "\<C-E>"         : "\<cr>"
noremap! <expr><Space>  exists("*SuperSpace") ? SuperSpace() : pumvisible() ? "\<C-Y>\<Space>" : "\<Space>"
" Esc: 取消已经填充的部分并退出插入模式
inoremap <expr><Esc>    pumvisible() ? "\<C-E>\<Esc>"   : "\<Esc>"
cnoremap <expr><Esc>    pumvisible() ? "\<C-E>"         : "\<C-C>"
tnoremap <Esc>          <C-\><C-N>
" Arrow Keys: 选择、选取、取消候选词
noremap! <expr><Down>   pumvisible() ? "\<C-N>"         : "\<Down>"
noremap! <expr><Up>     pumvisible() ? "\<C-P>"         : "\<Up>"
noremap! <expr><Left>   pumvisible() ? "\<C-E>"         : "\<Left>"
noremap! <expr><Right>  pumvisible() ? "\<C-Y>"         : "\<Right>"
noremap! <expr><S-Tab>  pumvisible() ? "\<C-E>\<C-D>"   : "\<C-D>"
nnoremap <S-Tab>        <<

" 跳转 - Goto
" Go to first line - `gg`
" Go to last line
noremap  gG         G
" Go to begin or end of code block
noremap  g[         [{
noremap  g]         ]}
" Go to Define and Back(Top of stack)
" TODO: map K,<C-]>,gD,... to one key
nnoremap gd         <C-]>
nnoremap gh         <C-T>
" Go to man or doc
nnoremap gk         K
" Go to Type
" nmap gt
" Go to next error of ale
nnoremap ge         <Plug>(ale_next_wrap)
" Go to yank and paste
vnoremap gy         "+y
nnoremap gp         "+p
vnoremap <C-c>      "+y
" Go to list, FIXME: what about quickfix
nnoremap gl         :lopen<CR>
" Tabularize
vnoremap /          :Tabularize /

" 其他
if g:pretty_debug
inoremap <C-o>      <Plug>(neosnippet_expand_or_jump)
snoremap <C-o>      <Plug>(neosnippet_expand_or_jump)
endif

" reasonable setting
" 'u' = undo => 'U' = redo
"  => like 'n' & 'N' in search mode
nnoremap U          :redo<cr>
" }}}

" }}}

" {{{ => Language Settings
" Markdown:
let g:vim_markdown_no_default_key_mappings=1
let g:vim_markdown_folding_level = 2
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_autowrite = 1 " autowrite when follow link
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_conceal = 1
set conceallevel=2

augroup pretty.languages
    autocmd!
    autocmd FileType go         nnoremap <buffer>gB     <Plug>(go-build)
    autocmd FileType go         nnoremap <buffer>gR     <Plug>(go-run)

    autocmd FileType go         nnoremap <buffer>gh     <Plug>(go-def-pop)
    autocmd FileType go         nnoremap <buffer>gd     <Plug>(go-def)
    autocmd FileType go         nnoremap <buffer>gt     <Plug>(go-def-type)
    autocmd FileType go         nnoremap <buffer>gk     <Plug>(go-doc-split)

    autocmd FileType rust       nnoremap <buffer>gd     <Plug>(rust-def)

    autocmd FileType markdown   nnoremap <buffer>gd     <Plug>Markdown_EditUrlUnderCursor
    autocmd FileType markdown   nnoremap <buffer>gh     :bprev<cr>
    autocmd FileType markdown   nnoremap <buffer><F10>  :Toc<cr>
                \ :setlocal nobuflisted nolist nomodifiable<cr>
                \ :TagbarClose<cr>
augroup END
" }}}
