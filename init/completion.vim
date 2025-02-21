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
                \ }

    function! s:apply_default_fixers(fixers) abort
        if !exists('b:ale_fixers')
            let b:ale_fixers = { &filetype : a:fixers }
        endif
    endfunction

    function! s:apply_fixers_conditional(files, cmd, fixers) abort
        for i in split(a:files, ';')
            if findfile(i, '.;') !=# ''
                let b:ale_fixers = { &filetype : a:fixers }
                return CheckExecutable(a:cmd, &filetype)
            endif
        endfor
        return 0
    endfunction

    " no executable here => user may installed different version
    "  => only one fixer for filetype
    augroup ALEFixersSetup
        autocmd!
        " stylua
        autocmd FileType lua,luac
                    \ call s:apply_fixers_conditional("stylua.toml;.stylua.toml;.styluaignore", 'stylua', ['stylua'])
        " black
        autocmd FileType python
                    \ call s:apply_default_fixers(['black'])
                    \ | let b:ale_python_black_options = s:find_lintrc('--config ', 'pyproject.toml', 'lintrc/black.toml')
        " goimports,gofmt
        autocmd FileType go
                    \ call s:apply_default_fixers(['goimports', 'gofmt'])
        " rustfmt
        autocmd FileType rust
                    \ call s:apply_fixers_conditional("rustfmt.toml;.rustfmt.toml", 'rustfmt', ['rustfmt'])
        " prettier
        autocmd FileType *
                    \ call s:apply_fixers_conditional(".prettierrc;.prettierrc.json", 'prettier', ['prettier'])
    augroup END
    " }}}

    " Linter: language server first {{{
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
                \ 'javascript'  : ['tsserver'],
                \ 'typescript'  : ['tsserver'],
                \ }
    " => jedils: how to set linter rules? use with pylint now.

    " linter config {{{
    function! s:apply_linters(linter, append = 0) abort
        if a:append && has_key(g:ale_linters, &filetype)
            let b:ale_linters = { &filetype : g:ale_linters[&filetype] + [ a:linter ] }
        else
            let b:ale_linters = { &filetype : [ a:linter ] }
        endif
    endfunction

    function! s:apply_linters_conditional(files, linter, append = 0) abort
        for i in split(a:files, ';')
            if findfile(i, '.;') !=# ''
                call s:apply_linters(a:linter, a:append)
                return 1
            endif
        endfor
        return 0
    endfunction

    function! s:find_lintrc(prefix, targets, def)
        for i in split(a:targets, ';')
            let l:config = findfile(i, '.;')
            if config !=# ''
                return a:prefix . fnamemodify('.', ':p') . config
            endif
        endfor
        return a:def ==# '' ? '' : a:prefix . g:pretty_home . '/' . a:def
    endfunction

    augroup ALELinterSetup
        autocmd!
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
                    \ }
        autocmd FileType vim
                    \ if s:apply_linters_conditional(".vintrc.yaml;.vintrc.yml;.vintrc", 'vint', 1)
                    \ |  let b:ale_vim_vint_executable = FindExecutable('vint')
                    \ |  let b:ale_vim_vint_show_style_issues = 1
                    \ | endif

        " c,cpp => prefer ccls if .ccls exists
        autocmd FileType c,cpp
                    \ call s:apply_linters_conditional(".ccls", 'ccls', 0)

        " gopls & gofmt
        autocmd FileType go
                    \ let b:ale_go_gofmt_options = '-s'

        " shell:
        autocmd FileType sh
                    \ let b:ale_sh_shellcheck_executable = FindExecutable('shellcheck') |
                    \ let b:ale_sh_shellcheck_options = s:find_lintrc('--rcfile=', '.shellcheckrc', 'lintrc/shellcheckrc')

        " Dockerfiles:
        autocmd FileType dockerfile
                    \ let b:ale_dockerfile_hadolint_executable = FindExecutable('hadolint') |
                    \ let b:ale_dockerfile_hadolint_options = s:find_lintrc('-c ', '.hadolint.yaml;.hadolint.yml', 'lintrc/hadolint.yaml')

        " cmake:
        autocmd FileType cmake
                    \ let b:ale_cmake_cmakelint_executable = FindExecutable('cmakelint') |
                    \ let b:ale_cmake_cmakelint_options = s:find_lintrc('--config=', '.cmakelintrc', 'lintrc/cmakelintrc')

        " yaml:
        autocmd FileType yaml
                    \ let b:ale_yaml_yamllint_executable = FindExecutable('yamllint') |
                    \ let b:ale_yaml_yamllint_options = s:find_lintrc('-c ', '.yamllint.yaml;.yamllint.yml', 'lintrc/yamllint.yaml')

        " python: flake8 is more popular, enable pylint if pylintrc exists
        autocmd FileType python
                    \ let b:ale_python_jedils_executable = FindExecutable('jedi-language-server')
                    \ | if s:apply_linters_conditional(".pylintrc;pylintrc", 'pylint', 1)
                    \ |  let b:ale_python_pylint_executable = FindExecutable('pylint')
                    \ |  let b:ale_python_pylint_options = s:find_lintrc('--rcfile ', '.pylintrc;pylintrc', 'lintrc/pylintrc')
                    \ | else
                    \ |  call s:apply_linters('flake8', 1)
                    \ |  let b:ale_python_flake8_executable = FindExecutable('flake8')
                    \ |  let b:ale_python_flake8_options = s:find_lintrc('--config ', '.flake8;tox.ini;setup.cfg', 'lintrc/flake8')
                    \ | endif

        " markdown:
        autocmd FileType markdown
                    \ let b:ale_markdown_markdownlint_executable = FindExecutable('markdownlint') |
                    \ let b:ale_markdown_markdownlint_options = s:find_lintrc('--config ', '.markdownlint.yaml', 'lintrc/markdownlint.yaml')

        " html + css
        autocmd FileType html,css
                    \ let b:ale_html_htmlhint_executable = FindExecutable('htmlhint') |
                    \ let b:ale_html_htmlhint_options = s:find_lintrc('--config ', '.htmlhintrc', 'lintrc/htmlhintrc') |
                    \ let b:ale_html_stylelint_executable = FindExecutable('stylelint') |
                    \ let b:ale_html_stylelint_options = s:find_lintrc('--config ', '.stylelintrc', 'lintrc/stylelintrc')
                    \ let b:ale_css_stylelint_executable = FindExecutable('stylelint') |
                    \ let b:ale_css_stylelint_options = s:find_lintrc('--config ', '.stylelintrc', 'lintrc/stylelintrc')

        " javascript,typescript deno ls => no executable here, local version preferred
        autocmd FileType javascript,typescript
                    \ if s:apply_linters_conditional("deno.json", 'deno', 1)
                    \ |  call CheckExecutable('deno', 'Deno Project')
                    \ | endif

        " lua => no executables here, install with luarocks or build from sources
        "  luals: some version won't work with ale
        "   => https://github.com/LuaLS/lua-language-server/issues/2899
        "  luacheck:
        "   => enable luacheck if .luacheckrc exists or lua-language-server is missing
        autocmd FileType lua
                    \ if CheckExecutable('lua-language-server', 'better Lua')
                    \ | let b:ale_lua_language_server_config = {
                    \     'Lua' : json_decode(readfile(s:find_lintrc('', '.luarc.json', 'lintrc/luarc.json')))
                    \ }
                    \ | endif
                    \ | if s:apply_linters_conditional(".luacheckrc", 'luacheck', 1)
                    \ |  call CheckExecutable('luacheck', 'Lua lint')
                    \ |  let b:ale_lua_luacheck_options = s:find_lintrc('--config ', '.luacheckrc', '')
                    \ | endif

        " eslint => no executable here => user may installed different version
        " TODO: handle eslintConfig in package.json
        autocmd FileType javascript,typescript,html
                    \ call s:apply_linters_conditional(".eslintrc.js;.eslintrc.cjs;eslint.config.js", 'eslint', 1)
        autocmd FileType yaml
                    \ call s:apply_linters_conditional(".eslintrc.yaml;.eslintrc.yml", 'eslint', 1)
        autocmd FileType json,jsonc
                    \ call s:apply_linters_conditional(".eslintrc.json", 'eslint', 1)
    augroup END
    " }}}
    " }}}

    " complete type unicode symbols {{{
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

    autocmd FileType denite*,nerdtree,tagbar,ale*
                \ call deoplete#custom#buffer_option('auto_complete', v:false)
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
