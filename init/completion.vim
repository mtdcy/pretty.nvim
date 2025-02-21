" Completion: deoplete + ale

" settings 
let g:autocomplete = 1          " 0 - manual complete with Tab
let g:autocomplete_delay = 200  " shorten to flicker less

let g:ale_enabled = 1
let g:ale_completion_enabled = 0

if g:ale_completion_enabled 
    let g:deoplete_enabled = 0
else
    let g:deoplete_enabled = 1
endif

if g:deoplete_enabled
    let g:neosnippet_enabled = 1
else
    let g:neosnippet_enabled = 0
endif

" ALE {{{
if g:ale_enabled
    if g:ale_completion_enabled
        let g:ale_completion_autoimport = 1
        let g:ale_completion_delay = g:autocomplete_delay
        set completeopt-=preview
        set paste& " ALE complete won't work with paste

        " always set omnifunc here, can be used as source for others or be replaced by others later
        set omnifunc=ale#completion#OmniFunc " => 支持手动补全
    endif

    " 悬浮窗：Hover(函数签名)
    let g:ale_hover_cursor = 0              " to statusline by default
    let g:ale_hover_to_preview = 0          " to preview window
    let g:ale_hover_to_floating_preview = 1 " to floating preview
    let g:ale_close_preview_on_insert = 0   " don't close preview on insert
    let g:ale_floating_preview_popup_opts = 'g:FloatingWindowBottomRight'

    augroup ALEHoverEnhanced
        autocmd!
        " Hover on cursor hold
        "  => hover manually with <C-d> in insert mode
        autocmd CursorHold * ALEHover
        " Hover after completion
        autocmd User ALECompletePost ALEHover
    augroup END

    " 错误: virtualtext & statusline
    let g:ale_echo_cursor = 1 " error code to statusline
    let g:ale_set_signs = 0 " no signs which cause window changes
    let g:ale_virtualtext_delay = g:autocomplete_delay
    let g:ale_virtualtext_cursor = 'all'
    let g:ale_virtualtext_prefix = '%code%: '

    " 错误列表：loclist
    let g:ale_set_loclist = 1           " loclist instead of quickfix
    let g:ale_open_list = 0             " don't open error list
    let g:ale_keep_list_window_open = 0 " close list after error cleared

    " Linters:
    let g:ale_lint_on_text_changed = 1  " Not all linter support this
    let g:ale_lint_on_insert_leave = 0
    let g:ale_lint_on_filetype_changed = 1
    let g:ale_lint_delay = 100

    " Fixers: {{{
    "  => load fixers if rc file exists, so fix on save
    let g:ale_fix_on_save = 1
    let g:ale_fixers = {
                \ '*'           : ['remove_trailing_lines', 'trim_whitespace'],
                \ 'go'          : ['goimports', 'gofmt'],
                \ 'python'      : ['black'],
                \ }

    " no executable here => user may installed different version
    augroup ALEFixersSetup
        autocmd!
        " stylua
        autocmd FileType lua,luac
                    \ if findfile("stylua.toml", ".;") != ''
                    \ || findfile(".stylua.toml", ".;") != ''
                    \ || findfile(".styluaignore", ".;") != ''
                    \ || findfile(".editorconfig", ".;") != ''
                    \ |  let b:ale_fixers = { expand('<amatch>') : ['stylua'] }
                    \ |  if ! executable('stylua') | echom "Please install stylua: 'cargo install stylua'" | endif
                    \ | endif

        " rustfmt
        autocmd FileType rust
                    \ if findfile("rustfmt.toml", ".;") != ''
                    \ || findfile(".rustfmt.toml", ".;") != ''
                    \ |  let b:ale_fixers = { expand('<amatch>') : ['rustfmt'] }
                    \ | endif
       
        " prettier 
        autocmd FileType * 
                    \ if findfile(".prettierrc", ".;") != ''
                    \ || findfile(".prettierrc.json", ".;") != ''
                    \ |  let b:ale_fixers = { expand('<amatch>') : ['prettier'] }
                    \ | endif
    augroup END
    " }}}

    " Linter: language server preferred {{{
    let g:ale_linters_explicit = 1
    let g:ale_linters = {
                \ 'sh'          : ['shellcheck'],
                \ 'vim'         : ['vimls'],
                \ 'python'      : ['jedils'],
                \ 'c'           : ['cc'],
                \ 'cpp'         : ['cc'],
                \ 'go'          : ['gopls'],
                \ 'rust'        : ['analyzer'],
                \ 'lua'         : ['lua-language-server'],
                \ 'make'        : ['checkmake'],
                \ 'cmake'       : ['cmakelint'],
                \ 'html'        : ['vscodehtml', 'htmlhint', 'stylelint'],
                \ 'css'         : ['vscodecss', 'stylelint'],
                \ 'java'        : ['javac'],
                \ 'json'        : ['vscodejson'],
                \ 'yaml'        : ['yamllint'],
                \ 'markdown'    : ['markdownlint'],
                \ 'dockerfile'  : ['hadolint'],
                \ }
    " => jedils: how to set linter rules? use with pylint now.

    " {{{ => linter config
    function! FindLintrc(prefix, targets, def)
        for i in split(a:targets, ';')
            let l:config = findfile(i, '.;')
            if config !=# ''
                return a:prefix . fnamemodify('.', ':p') . config
            endif
        endfor
        return a:def ==# '' ? '' : a:prefix . g:pretty_home . '/' . a:def
    endfunction

    function! EnableLinters(filetype, linter) abort
        if has_key(g:ale_linters, a:filetype)
            let b:ale_linters = { a:filetype : g:ale_linters[a:filetype] + [ a:linter ] }
        else
            let b:ale_linters = { a:filetype : [ a:linter ] }
        endif
    endfunction

    augroup ALELinterSetup
        autocmd!
        " c,cpp: prefer ccls if .ccls exists
        autocmd FileType c,cpp
                    \ if findfile(".ccls", ".;") != ''
                    \ |  let b:ale_linters = { expand('<amatch>') : ['ccls'] }
                    \ | endif

        " vimls: https://github.com/iamcco/vim-language-server
        "  => enable vint linter if vintrc exists
        let g:markdown_fenced_languages = [ 'vim', 'help' ] " for document hightlight
        autocmd FileType vim
                    \ let b:ale_vim_vimls_executable = FindExecutable('vim-language-server') |
                    \ let b:ale_vim_vimls_config = {
                    \     'vim' : {
                    \       'isNeovim'      : has('nvim'),
                    \       'iskeyword'     : '@,48-57,_,192-255,-#',
                    \       'vimruntime'    : $VIMRUNTIME,
                    \       'runtimepath'   : '',
                    \       'diagnostic'    : { 'enable': v:true },
                    \       'indexes' : {
                    \         'runtimepath' : v:true,
                    \         'gap'         : 100,
                    \         'count'       : 3,
                    \         'projectRootPatterns' : ['.git', 'autoload', 'plugin']
                    \       },
                    \       'suggest' : {
                    \         'fromVimruntime'  : v:true,
                    \         'fromRuntimepath' : v:false
                    \       },
                    \     }
                    \ } |
                    \ if findfile(".vintrc.yaml", ".;") != ''
                    \ || findfile(".vintrc.yml", ".;") != ''
                    \ || findfile(".vintrc", ".;") != ''
                    \ || exepath('vim-language-server') ==# ''
                    \ |  call EnableLinters(expand('<amatch>'), 'vint')
                    \ |  let b:ale_vim_vint_executable = FindExecutable('vint')
                    \ |  let b:ale_vim_vint_show_style_issues = 1
                    \ | endif

        " gopls & gofmt
        autocmd FileType go 
                    \ let b:ale_go_gofmt_options = '-s'

        " shell:
        autocmd FileType sh 
                    \ let b:ale_sh_shellcheck_executable = FindExecutable('shellcheck') |
                    \ let b:ale_sh_shellcheck_options = FindLintrc('--rcfile=', '.shellcheckrc', 'lintrc/shellcheckrc')

        " Dockerfiles:
        autocmd FileType dockerfile 
                    \ let b:ale_dockerfile_hadolint_executable = FindExecutable('hadolint') |
                    \ let b:ale_dockerfile_hadolint_options = FindLintrc('-c ', '.hadolint.yaml;.hadolint.yml', 'lintrc/hadolint.yaml')

        " cmake:
        autocmd FileType cmake 
                    \ let b:ale_cmake_cmakelint_executable = FindExecutable('cmakelint') |
                    \ let b:ale_cmake_cmakelint_options = FindLintrc('--config=', '.cmakelintrc', 'lintrc/cmakelintrc')

        " yaml:
        autocmd FileType yaml
                    \ let b:ale_yaml_yamllint_executable = FindExecutable('yamllint') |
                    \ let b:ale_yaml_yamllint_options = FindLintrc('-c ', '.yamllint.yaml;.yamllint.yml', 'lintrc/yamllint.yaml')

        " python: flake8 is more popular, enable pylint if pylintrc exists
        "  fixer: Black has deliberately only one option (line length) to ensure consistency across many projects
        autocmd FileType python
                    \ let b:ale_python_jedils_executable = FindExecutable('jedi-language-server') |
                    \ let b:ale_python_black_executable = FindExecutable('black') |
                    \ let b:ale_python_black_options = FindLintrc('--config ', 'pyproject.toml', 'lintrc/black.toml') |
                    \ if findfile(".pylintrc", ".;") != ''
                    \ || findfile("pylintrc", ".;") != ''
                    \ |  let b:ale_linters = { 'python' : [ 'jedils', 'pylint' ] }
                    \ |  let b:ale_python_pylint_executable = FindExecutable('pylint')
                    \ |  let b:ale_python_pylint_options = FindLintrc('--rcfile ', '.pylintrc;pylintrc', 'lintrc/pylintrc')
                    \ | else
                    \ |  let b:ale_linters = { 'python' : [ 'jedils', 'flake8' ] }
                    \ |  let b:ale_python_flake8_executable = FindExecutable('flake8')
                    \ |  let b:ale_python_flake8_options = FindLintrc('--config ', '.flake8;tox.ini;setup.cfg', 'lintrc/flake8')
                    \ | endif

        " markdown:
        autocmd FileType markdown
                    \ let b:ale_markdown_markdownlint_executable = FindExecutable('markdownlint') |
                    \ let b:ale_markdown_markdownlint_options = FindLintrc('--config ', '.markdownlint.yaml', 'lintrc/markdownlint.yaml')

        " html + css
        autocmd FileType html,css
                    \ let b:ale_html_htmlhint_executable = FindExecutable('htmlhint') |
                    \ let b:ale_html_htmlhint_options = FindLintrc('--config ', '.htmlhintrc', 'lintrc/htmlhintrc') |
                    \ let b:ale_html_stylelint_executable = FindExecutable('stylelint') |
                    \ let b:ale_html_stylelint_options = FindLintrc('--config ', '.stylelintrc', 'lintrc/stylelintrc')
                    \ let b:ale_css_stylelint_executable = FindExecutable('stylelint') |
                    \ let b:ale_css_stylelint_options = FindLintrc('--config ', '.stylelintrc', 'lintrc/stylelintrc')

        " javascript,typescript
        "  => no executable here, local version preferred
        autocmd FileType javascript,typescript
                    \ if findfile("deno.json", ".;") != ''
                    \ |  call CheckExecutable('deno', 'Deno Project')
                    \ |  let b:ale_linters = { expand('<amatch>') : ['deno'] }
                    \ | else
                    \ |  call CheckExecutable('tsserver', expand('<amatch>'))
                    \ |  let b:ale_linters = { expand('<amatch>') : ['tsserver'] }
                    \ | endif

        " lua
        "  => no local executables, install with luarocks or build from sources
        "  luals: some version won't work with ale
        "   => https://github.com/LuaLS/lua-language-server/issues/2899
        "  luacheck:
        "   => enable luacheck if .luacheckrc exists or lua-language-server is missing
        autocmd FileType lua
                    \ if executable('lua-language-server') == 0
                    \ |  echom 'Please install lua-language-server for better Lua support'
                    \ | else
                    \ | let b:ale_lua_language_server_config = { 'Lua' : 
                    \       json_decode(readfile(FindLintrc('', '.luarc.json', 'lintrc/luarc.json')))
                    \ }
                    \ | endif
                    \ | if findfile(".luacheckrc", ".;") != ''
                    \ || executable('lua-language-server') == 0
                    \ |  if executable('luacheck') == 0
                    \ |     echom 'Please install luacheck: `luarocks install luacheck lanes`'
                    \ |  endif
                    \ |  call EnableLinters(expand('<amatch>'), 'luacheck')
                    \ |  let b:ale_lua_luacheck_options = FindLintrc('--config ', '.luacheckrc', 'lintrc/luacheckrc')
                    \ | endif

        " eslint: load if .eslintrc.* exists {{{
        "  => don't specify executable here => user may installed different version
        " TODO: handle eslintConfig in package.json
        autocmd FileType javascript,typescript,html
                    \ if findfile(".eslintrc.js", ".;") != ''
                    \ || findfile(".eslintrc.cjs", ".;" ) != ''
                    \ || findfile(".eslint.config.cjs", ".;" ) != ''
                    \ |  call EnableLinters(expand('<amatch>'), 'eslint')
                    \ | endif
        autocmd FileType yaml
                    \ if findfile(".eslintrc.yaml", ".;") != ''
                    \ || findfile(".eslintrc.yml", ".;" ) != ''
                    \ |  call EnableLinters(expand('<amatch>'), 'eslint')
                    \ | endif
        autocmd FileType json,jsonc
                    \ if findfile(".eslintrc.json", ".;") != ''
                    \ |  call EnableLinters(expand('<amatch>'), 'eslint')
                    \ | endif
        " }}}
    augroup END
    " }}}
    " }}}

    " {{{ => complete type unicode
    let g:ale_completion_symbols = {
                \ 'text'            : '',
                \ 'class'           : '',
                \ 'method'          : '',
                \ 'function'        : '',
                \ 'constructor'     : '',
                \ 'field'           : '',
                \ 'variable'        : '',
                \ 'interface'       : '',
                \ 'module'          : '',
                \ 'property'        : '',
                \ 'operator'        : '',
                \ 'constant'        : '',
                \ 'value'           : '',
                \ 'keyword'         : '⚷',
                \ 'enum'            : '',
                \ 'enum member'     : '',
                \ 'struct'          : '',
                \ 'event'           : '',
                \ 'unit'            : '',
                \ 'snippet'         : '',
                \ 'color'           : 'color',
                \ 'file'            : 'file',
                \ 'reference'       : 'reference',
                \ 'folder'          : 'folder',
                \ 'type_parameter'  : 'type param',
                \ '<default>'       : 'v'
                \ }
    " }}}
endif
" }}}

" deoplete {{{
if g:deoplete_enabled
    let g:deoplete#enable_at_startup = 1
    " neosnippet: 与deoplete配合
    let g:neosnippet#enable_snipmate_compatibility = 1

    set completeopt=menu,noselect,noinsert
    " scan only tags and buffers => :h 'complete'
    "  => deep scan by deoplete and ale
    set complete=t,.,b,u,w
    set paste&
    set pumheight=10
    " wish to have 'longest', but deoplete can work with it.

    " 注意补全source的顺序
    if g:ale_enabled
        " ALE as completion source for deoplete
        "  => buffer will override ale's suggestions.
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['ale', 'around', 'buffer', 'file', 'neosnippet'],
                    \ })
    else
        " 为每个语言定义completion source
        call deoplete#custom#option(
                    \ 'sources', {
                    \   '_'     : ['around', 'buffer', 'file', 'neosnippet'],
                    \   'cpp'   : ['LanguageClient'],
                    \   'c'     : ['LanguageClient'],
                    \   'vim'   : ['vim'],
                    \   'zsh'   : ['zsh'],
                    \   'python': ['jedi'],
                    \ })
    endif

    " complete with vim-go => 手动模式omni不工作，为什么？
    "if g:go_code_completion_enabled
    "    call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })
    "endif

    if g:autocomplete
        " 自动补全时给一个较大的延时
        "  => 打字够快，补全就不会干扰
        call deoplete#custom#option({
                    \ 'auto_complete_delay' : g:autocomplete_delay
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
    " mark sources
    call deoplete#custom#source('file',         'mark', '📁')   " rank: 150
    call deoplete#custom#source('file',         'rank', 100)
    call deoplete#custom#source('buffer',       'mark', '📋')   " rank: 100
    call deoplete#custom#source('buffer',       'rank', 150)
    call deoplete#custom#source('neosnippet',   'mark', '📜')
    call deoplete#custom#source('neosnippet',   'rank', 200)
    call deoplete#custom#source('around',       'mark', '📝')   " rank: 300
    call deoplete#custom#source('ale',          'mark', '⭐')
    call deoplete#custom#source('ale',          'rank', 999)    
    " => highest rank, override around|buffer|file if completion exists
    "  => won't override neosnippet
    
    " complete cross filetype for buffer source
    call deoplete#custom#var('buffer', 'require_same_filetype', v:false)
    " enable slash completion for file source
    call deoplete#custom#var('file', 'enable_slash_completion', v:true)
endif
" }}}

" Tab enhance functions {{{
" text before cursor
function! s:typed_line() abort
    let c = col('.') - 1
    return c > 0 ? getline('.')[:c-1] : ''
endfunction

" new line? => insert indent => :h i_CTRL-T
function! s:is_new_line() abort
    let typed_line = s:typed_line()
    " :h expr4 for compare op help
    if &filetype ==? 'markdown'             | return typed_line =~# '\s*\(-\|\*\|\d\+\)\s\+$'
    elseif &filetype ==? 'yaml'             | return typed_line =~# '\s*.*\(-\|:\)\s*$'
    else                                    | return typed_line ==# ''
    endif
endfunction

" new start? => insert tab
function! s:is_new_word() abort
    let typed_line = s:typed_line()
    " space before cursor?
    return typed_line[-1:] =~# '\s'
endfunction

function! s:can_complete() abort
    if g:deoplete_enabled           | return deoplete#can_complete()
    else                            | return &omnifunc !=# ''
    endif
endfunction

function! s:complete() abort
    if g:deoplete_enabled           | return deoplete#complete()
    " complete by omnifunc
    else                            | return "\<C-X>\<C-O>"
    endif
endfunction

function! s:can_jump() abort
    if g:neosnippet_enabled         | return neosnippet#jumpable() 
    else                            | return 0
    endif
endfunction

function! s:jump() abort
    if g:neosnippet_enabled         | return "\<Plug>(neosnippet_jump)"
    else                            | return ""
    endif
endfunction

function! s:can_expand() abort
    if g:neosnippet_enabled         | return neosnippet#expandable()     
    else                            | return 0
    endif
endfunction

function! s:expand() abort
    if g:neosnippet_enabled         | return "\<Plug>(neosnippet_expand)"
    else                            | return ""
    endif
endfunction

" Tab: 开始补全，选择候选词，snippets, Tab
function! s:i_tab() abort
    if pumvisible()                 | return "\<C-N>"
    elseif s:is_new_line()          | return "\<C-T>"
    elseif s:is_new_word()
        if s:can_jump()             | return s:jump()
        else                        | return "\<Tab>"
        endif
    elseif s:can_complete()         | return s:complete()
    elseif s:can_jump()             | return s:jump()
    else                            | return "\<Tab>"
    endif
endfunction

function! s:s_tab() abort
    if s:can_jump()                 | return s:jump()
    else                            | return "\<Tab>"
    endif
endfunction

" Enter: complete + snippets
function! s:i_enter() abort
    let comp = complete_info()
    if comp['selected'] >= 0
        if s:can_expand()           | return "\<C-Y>" . s:expand()
        else                        | return "\<C-Y>"
        endif
    elseif comp['pum_visible']      | return "\<C-E>\<CR>"
    else                            | return "\<CR>"
    endif
endfunction

" Space: complete only
function! s:i_space() abort
    let comp = complete_info()
    if comp['selected'] >= 0        | return "\<C-Y>\<Space>"
    elseif comp['pum_visible']      | return "\<C-E>\<Space>"
    else                            | return "\<Space>"
    endif
endfunction

" Backspace: cancel
function! s:i_backspace() abort
    let comp = complete_info()
    if comp['selected'] >= 0        | return "\<C-E>"
    elseif comp['pum_visible']      | return "\<C-E>\<BS>"
    else                            | return "\<BS>"
    endif
endfunction
" }}}

"inoremap <expr><C-L>                <sid>typed_line()
inoremap <expr><Tab>                <sid>i_tab()
snoremap <expr><Tab>                <sid>s_tab()
inoremap <expr><Enter>              <sid>i_enter()
inoremap <expr><Space>              <sid>i_space()
inoremap <expr><BS>                 <sid>i_backspace()
" Esc: 取消已经填充的部分并退出插入模式
inoremap <expr><Esc>                pumvisible() ? "\<C-E>\<Esc>"   : "\<Esc>"
cnoremap <expr><Esc>                pumvisible() ? "\<C-E>"         : "\<C-C>"
" => cuase floating window can't be closed by esc.
"tnoremap <Esc>                      <C-\><C-N>

" Arrow Keys: 选择、选取、取消候选词
noremap! <expr><Down>               pumvisible() ? "\<C-N>"         : "\<Down>"
noremap! <expr><Up>                 pumvisible() ? "\<C-P>"         : "\<Up>"
noremap! <expr><Left>               pumvisible() ? "\<C-E>"         : "\<Left>"
noremap! <expr><Right>              pumvisible() ? "\<C-Y>"         : "\<Right>"
noremap! <expr><S-Tab>              pumvisible() ? "\<C-E>\<C-D>"   : "\<C-D>"
nnoremap <S-Tab>                    <<
