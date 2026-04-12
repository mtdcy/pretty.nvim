" =============================================================================
" ALE (Asynchronous Lint Engine) 配置
" =============================================================================
" 功能：异步语法检查和语言服务器协议 (LSP) 客户端
" 特点：
"   - 支持 LSP 服务器和命令行 Linter 工具
"   - 独立于 Neovim 内置的 vim.lsp 系统
"   - 专注于语法检测，不包含代码修复和自动补全功能
"   - 所有功能在后台异步执行，不影响编辑体验
"
" 设计原则：
"   1. 轻量级：仅启用必要的 Linter
"   2. 智能检测：根据项目配置自动启用/禁用 Linter
"   3. 无侵入：错误显示在虚拟文本和位置列表，不自动打开窗口
"   4. 可扩展：支持 15+ 种编程语言的 Linter
"
" 注意：本配置已禁用自动修复和自动补全功能，仅保留 Linter 功能。
" =============================================================================

let g:ale_symbols = ''

" ALE 检测延迟（毫秒），减少界面闪烁
let g:ale_jitter = 200

" -----------------------------------------------------------------------------
" 基础配置
" -----------------------------------------------------------------------------

" 手动补全功能：保留 ALE 的 omnifunc（使用 <C-X><C-O> 触发）
set omnifunc=ale#completion#OmniFunc
let g:ale_completion_autoimport = 1

" 禁用自动修复功能：专注于语法检查，不自动格式化代码
let g:ale_fix_on_save = 0
let g:ale_fixers = { '*' : [] }

" -----------------------------------------------------------------------------
" 悬浮提示 (Hover) 配置
" -----------------------------------------------------------------------------
" 显示函数签名、类型信息等文档
let g:ale_hover_cursor = 0              " 默认显示在状态栏
let g:ale_hover_to_preview = 0          " 不使用预览窗口
let g:ale_hover_to_floating_preview = 1 " 使用浮动窗口显示
let g:ale_close_preview_on_insert = 0   " 进入插入模式时不关闭悬浮窗
let g:ale_floating_preview_popup_opts = g:pretty_hints_window " 使用统一的浮动窗口配置

" -----------------------------------------------------------------------------
" 错误显示配置
" -----------------------------------------------------------------------------

" 状态栏错误提示（已禁用，避免影响命令行体验）
let g:ale_echo_cursor = 0

" 禁用行号旁的错误标记（避免窗口布局变化）
let g:ale_set_signs = 0

" 虚拟文本显示（在代码行内显示错误信息）
let g:ale_virtualtext_delay = g:ale_jitter       " 延迟显示，减少闪烁
let g:ale_virtualtext_cursor = 'all'             " 为所有错误显示虚拟文本
let g:ale_virtualtext_prefix = '%linter%:: %code%: '  " 虚拟文本前缀格式

" -----------------------------------------------------------------------------
" 错误列表配置
" -----------------------------------------------------------------------------
" 使用位置列表 (loclist) 而非快速修复列表 (quickfix)
let g:ale_set_loclist = 1           " 使用位置列表（每个窗口独立）
let g:ale_set_quickfix = 0          " 不使用全局快速修复列表
let g:ale_open_list = 0             " 不自动打开错误列表窗口
let g:ale_keep_list_window_open = 3 " 错误清除后自动关闭列表窗口

" -----------------------------------------------------------------------------
" Lint 触发时机配置
" -----------------------------------------------------------------------------
" 平衡性能与实时性：避免过于频繁的 Lint
let g:ale_lint_on_filetype_changed = 1  " 文件类型变化时
let g:ale_lint_on_text_changed = 0      " 文本变化时（禁用，避免性能问题）
let g:ale_lint_on_insert_leave = 1      " 离开插入模式时
let g:ale_lint_on_enter = 1             " 进入缓冲区时 => 尽早加载 lsp
let g:ale_lint_on_save = 1              " 保存文件时
let g:ale_lint_delay = g:ale_jitter     " Lint 延迟

" -----------------------------------------------------------------------------
" LSP 和 Linter 显示配置
" -----------------------------------------------------------------------------
let g:ale_lsp_suggestions = 1                    " 启用 LSP 建议
let g:ale_lsp_show_message_format = '%linter%:: %severity%: %s'  " 消息格式
let g:ale_detail_to_floating_preview = 1         " 详细信息显示在浮动窗口

" Linter 帮助函数
" {{{
function! s:linter_ftype(linter, append = v:false) abort
    if exists('b:ale_linters') == 0 || has_key(b:ale_linters, &filetype) == 0
        let linters = has_key(g:ale_linters, &filetype) ? g:ale_linters[&filetype] : []
        let b:ale_linters = { &filetype : linters }
    endif
    if a:append
        let b:ale_linters = { &filetype : b:ale_linters[&filetype] + [ a:linter ] }
    else
        let b:ale_linters = { &filetype : [ a:linter ] }
    endif
endfunction

function! s:linter_ftype_if(executable, files, linter, append = v:false) abort
    let b:linter = a:executable == '' ? 'nil' : PrettyFindExecutable(a:executable)
    let b:lintrc = a:files == '' ? 'nil' : PrettyFindFiles('', a:files)
    if b:linter != '' && b:lintrc != ''
        call s:linter_ftype(a:linter, a:append)
        return v:true
    endif
    return v:false
endfunction
" }}}

" =============================================================================
" 语言特定的 Linter 配置
" =============================================================================
" 功能：为 15+ 种编程语言配置智能 Linter 选择
"
" 设计原则：
"   #1. 优先级：语言服务器 (LS) > 专用 Linter > 通用 Linter
"   #2. 条件启用：只在可执行文件和配置文件存在时启用
"   #3. 避免冲突：不重复配置相同功能的 Linter
"   #4. 轻量优先：简单文件类型不使用语言服务器
"
" 配置结构：
"   1. 全局禁用所有默认 Linter
"   2. 根据文件类型自动条件加载
"   3. 每个语言有明确的优先级和启用条件
"
" 支持的编程语言：
"   - Vim Script, Lua, Shell, C/C++, Go, Python
"   - YAML, JSON, Markdown, Make, CMake, Dockerfile
"   - HTML, CSS, 以及其他配置格式
" =============================================================================

" 全局设置：禁用所有默认 Linter，显式配置每个语言
let g:ale_linters_explicit = 1
" 初始化空的 Linter 配置
let g:ale_linters = { '*' : [] }

" {{{
augroup ALELinterSetup
    autocmd!
    " vim: vimls + vint ( enable only when .vintrc exists )
    autocmd FileType vim
                \ if s:linter_ftype_if('vim-language-server', '', 'vimls')       |
                \   let b:ale_vim_vimls_executable = b:linter                    |
                \   let b:ale_vim_vimls_config = {
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
                \ }                                                              |
                \ endif                                                          |
                \ if s:linter_ftype_if('vint', ".vintrc*", 'vint', 1)            |
                \   let b:ale_vim_vint_executable = b:linter                     |
                \   let b:ale_vim_vint_show_style_issues = v:false               |
                \ endif

    " lua: luals + luacheck
    "  luals: some version won't work with ale
    "   => https://github.com/LuaLS/lua-language-server/issues/2899
    autocmd FileType lua
                \ if s:linter_ftype_if('lua-language-server', '.luarc.json', 'lua_language_server')    |
                \   let b:ale_lua_language_server_executable = b:linter                                |
                \   let b:ale_lua_language_server_config = { 'Lua' : json_decode(readfile(b:lintrc)) } |
                \ endif                                                                                |
                \ if s:linter_ftype_if('luacheck', '.luacheckrc', 'luacheck', v:true)                  |
                \   let b:ale_lua_luacheck_executable = b:linter                                       |
                \   let b:ale_lua_luacheck_options = b:lintrc                                          |
                \ endif

    " shellcheck: preferred
    " bash-language-server: very slow, `touch .bashls` to enable it
    autocmd FileType sh,bash
                \ if s:linter_ftype_if('bash-language-server', ".bashls", 'language_server')                                                       |
                \   let b:ale_sh_language_server_executable = b:linter                                                                             |
                \ endif                                                                                                                            |
                \ if s:linter_ftype_if('shellcheck', '', 'shellcheck', v:true)                                                                     |
                \   let b:ale_sh_shellcheck_executable = b:linter                                                                                  |
                \   let b:ale_sh_shellcheck_options = '--extended-analysis=false ' . PrettyFindFiles('--rcfile=', '.shellcheckrc', 'shellcheckrc') |
                \ endif

    " c,cpp: clangd  + clang-tidy or cpplint
    "   💡 clangd 是 llvm 官方出口，而 ccls 只是社区产品，两者都依赖 llvm
    "   export CPATH=$(xcrun --show-sdk-path)/usr/include - 否则 clang-tidy 找不到标准头文件
    autocmd FileType c,cpp 
                \ if s:linter_ftype_if('clangd', '.clangd', 'clangd')                              |
                \   let b:ale_c_clangd_executable = b:linter                                       |
                \   let b:ale_cpp_clangd_executable = b:linter                                     |
                \ endif                                                                            |
                \ if s:linter_ftype_if('clang-tidy', '.clang-tidy', 'clangtidy', 1)                |
                \   let b:ale_c_clangtidy_executable = b:linter                                    |
                \   let b:ale_cpp_clangtidy_executable = b:linter                                  |
                \ elseif s:linter_ftype_if('cpplint', '', 'cpplint', 1)                            |
                \   let b:ale_c_cpplint_executable = b:linter                                      |
                \   let b:ale_cpp_cpplint_executable = b:linter                                    |
                \   let b:ale_c_cpplint_options = "--filter=-whitespace/braces --linelength=120"   |
                \   let b:ale_cpp_cpplint_options = "--filter=-whitespace/braces --linelength=120" |
                \ endif

    " gopls & gofmt
    autocmd FileType go call s:linter_ftype_if('gopls', '', 'gopls')

    " rust: rust-analyzer or cargo (fallback)
    autocmd FileType rust 
                \ if s:linter_ftype_if('rust-analyzer', '', 'analyzer') == v:false |
                \   echom "⚠️ no rust-analyzer lsp, fallback to cargo"             |
                \   call s:linter_ftype('cargo')                                   |
                \ endif

    " python: jedils + pylint or flake8
    "   flake8 is more popular, enable pylint if pylintrc exists
    autocmd FileType python
                \ if s:linter_ftype_if('jedi-language-server', '', 'jedils')        |
                \   let b:ale_python_jedils_executable = b:linter                   |
                \ endif                                                             |
                \ if s:linter_ftype_if('pylint', '.pylintrc;pylintrc', 'pylint', 1) |
                \   let b:ale_python_pylint_executable = b:linter                   |
                \   let b:ale_python_pylint_options = '--rcfile ' . b:lintrc        |
                \ elseif s:linter_ftype_if('flake8', '', 'flake8', 1)               |
                \   let b:ale_python_flake8_executable = b:linter                   |
                \   let b:ale_python_flake8_options = "--max-line-length 120"       |
                \ endif

    " yaml: yamllint
    autocmd FileType yaml
                \ if s:linter_ftype_if('yamllint', '', 'yamllint')                                           |
                \   let b:ale_yaml_yamllint_executable = b:linter                                            |
                \   let b:ale_yaml_yamllint_options = PrettyFindFiles('-c ', '.yamllint.*', 'yamllint.yaml') |
                \ endif

    " json: jsonlint (preferred) or eslint ( enable when .eslintrc.json exists )
    autocmd FileType json,json5
                \ if s:linter_ftype_if('eslint', ".eslintrc.json", 'eslint') |
                \   let b:ale_json_eslint_executable = b:linter              |
                \ elseif s:linter_ftype_if('jsonlint', '', 'jsonlint')       |
                \   let b:ale_json_jsonlint_executable = b:linter            |
                \ endif

    autocmd FileType xml
                \ if s:linter_ftype_if('xmllint', '', 'xmllint') |
                \   let b:ale_xml_xmllint_executable = b:linter  |
                \ endif

    " markdown: markdownlint
    autocmd FileType markdown
                \ if s:linter_ftype_if('markdownlint', '', 'markdownlint')                                                            |
                \   let b:ale_markdown_markdownlint_executable = b:linter                                                             |
                \   let b:ale_markdown_markdownlint_options = PrettyFindFiles('--config ', '.markdownlint.yaml', 'markdownlint.yaml') |
                \ endif

    " make: checkmake
    autocmd FileType make
                \ if s:linter_ftype_if('checkmake', '', 'checkmake')                                               |
                \   let b:ale_make_checkmake_executable = b:linter                                                 |
                \   let b:ale_make_checkmake_config = PrettyFindFiles('--config ', '.checkmake.ini;checkmake.ini') |
                \ endif

    " cmake:
    autocmd FileType cmake
                \ if s:linter_ftype_if('cmakelint', '', 'cmakelint')                                                |
                \   let b:ale_cmake_cmakelint_executable = b:linter                                                 |
                \   let b:ale_cmake_cmakelint_options = PrettyFindFiles('--config=', '.cmakelintrc', 'cmakelintrc') |
                \ endif

    " hadolint:
    autocmd FileType dockerfile
                \ if s:linter_ftype_if('hadolint', '.hadolint*', 'hadolint') |
                \   let b:ale_dockerfile_hadolint_executable = b:linter      |
                \   let b:ale_dockerfile_hadolint_options = '-c ' . b:lintrc |
                \ endif

    " html: htmlhint (preferred) or eslint ( only when .eslintrc exists )
    autocmd FileType html
                \ if s:linter_ftype_if('eslint', '.eslintrc*', 'eslint')                        |
                \   let b:ale_html_eslint_executable = b:linter                                 |
                \ elseif s:linter_ftype_if('htmlhint', '', 'htmlhint')                          |
                \   let b:ale_html_htmlhint_executable = b:linter                               |
                \   let b:ale_html_htmlhint_options = PrettyFindFiles('-c ', '.htmlhintrc', '') |
                \ endif

    " css: stylelint (preferred) or csslint (only when .csslintrc exists)
    autocmd FileType css
                \ if s:linter_ftype_if('csslint', '.csslintrc*', 'csslint')                       |
                \   let b:ale_css_csslint_executable = b:linter                                   |
                \ elseif s:linter_ftype_if('stylelint', '', 'stylelint')                          |
                \   let b:ale_css_stylelint_executable = b:linter                                 |
                \   let b:ale_css_stylelint_options = PrettyFindFiles('-c ', '.stylelintrc*', '') |
                \ endif

    " typescript/javascript: tsserver + eslint (事实标准)
    "  ⚠️ tsserver_config_path 好像没生效
    autocmd FileType typescript,javascript
                \ if s:linter_ftype_if('tsserver', 'tsconfig.json;jsconfig.json', 'tsserver') |
                \   let b:ale_typescript_tsserver_executable = b:linter                       |
                \   let b:ale_javascript_tsserver_executable = b:linter                       |
                \   let b:ale_typescript_tsserver_config_path = b:lintrc                      |
                \   let b:ale_javascript_tsserver_config_path = b:lintrc                      |
                \ endif                                                                       |
                \ if s:linter_ftype_if('eslint', 'eslint.config.*;.eslintrc.*', 'eslint', 1)  |
                \   let b:ale_typescript_eslint_executable = b:linter                         |
                \   let b:ale_javascript_eslint_executable = b:linter                         |
                \   let b:ale_typescript_eslint_options = "-c " .. b:lintrc                   |
                \   let b:ale_javascript_eslint_options = "-c " .. b:lintrc                   |
                \ endif
augroup END
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

" =============================================================================
" 符号查找和导航功能
" =============================================================================
" 功能：提供代码导航功能（定义、引用、实现、类型、悬浮提示）
"
" 问题：ALE 的原生 GoToDefinition 功能会分割窗口，体验不佳
" 解决方案：将 ALE 的查找结果转换为 Quickfix 列表，通过 Finder 统一显示
" =============================================================================

" -----------------------------------------------------------------------------
" 函数：s:ale_show_selections - 处理 ALE 查找结果并显示
" -----------------------------------------------------------------------------
" 功能：
"   1. 将 ALE 的查找结果转换为 Quickfix 格式
"   2. 关闭 ALE 的原生结果窗口
"   3. 通过 Finder 显示格式化的结果
"
" 触发时机：当 ALE 打开预览选择窗口时自动调用
" 注意：ale-preview-selection 文件类型由 ALE 内部创建
" -----------------------------------------------------------------------------
function! s:ale_show_selections()
    let bufnr = bufnr('%')

    lua vim.treesitter.stop()

    " ALE 的原生 GoToDefinition 会分割窗口，体验不佳
    " 解决方案：手动将查找结果转换为 Quickfix 格式
    call PrettyQuickfixLoad(bufnr, " " .. g:ale_symbols)

    " 关闭 ALE 的原生结果窗口
    close

    " 通过 Finder 显示格式化的 Quickfix 结果
    exe "FinderOpen quickfix"
endfunction

" -----------------------------------------------------------------------------
" 函数：s:ale_find_symbols - 统一的符号查找入口函数
" -----------------------------------------------------------------------------
" 参数：
"   action : string  查找类型（def, hint, type, impl, ref）
"            - '' 或 'def'    : 跳转到定义
"            - 'hint'         : 显示悬浮提示
"            - 'type'         : 跳转到类型定义
"            - 'impl'         : 跳转到实现
"            - 其他           : 查找引用
"
" 功能：根据 action 参数调用对应的 ALE 查找功能
" 注意：该函数存储当前光标下的单词供后续处理使用
" -----------------------------------------------------------------------------
function! s:ale_find_symbols(action = '', ...) abort
    " 获取当前光标下的单词（存储在脚本作用域变量中）
    let g:ale_symbols = expand('<cword>')

    " 根据 action 参数调用对应的 ALE 功能
    if a:action == "refactor"
        call ale#rename#Execute() " 💡 重命名 <cword>
    elseif a:action =~? "^hint"
        " 显示悬浮提示
        call ale#hover#ShowAtCursor()
    elseif a:action == '' || a:action =~? "^def"
        " 跳转到定义
        call ale#definition#GoToCommandHandler('')
    elseif a:action =~? "^type"
        " 跳转到类型定义
        call ale#definition#GoToCommandHandler('type')
    elseif a:action =~? "^impl"
        " 跳转到实现
        call ale#definition#GoToCommandHandler('implementation')
    else
        " 查找引用（references）
        call ale#references#Find()
    endif
endfunction

" -----------------------------------------------------------------------------
" 用户命令和快捷键配置
" -----------------------------------------------------------------------------

" ALE doautocmd in non-main event loop, echo won't work, use vim.notify instead
function! s:ale_show_status()
    if exists('b:ale_linters') == 0 || has_key(b:ale_linters, &filetype) == 0
        return
    endif

    " check only once for filetype
    if !exists('g:ale_status_checked') | let g:ale_status_checked = {} | endif
    if !has_key(g:ale_status_checked, &filetype) | let g:ale_status_checked[&filetype] = 0 | endif
    if g:ale_status_checked[&filetype] | return | endif

    " lua vim.notify("💡 buffer info: " .. vim.inspect(vim.fn.getbufinfo()))

    if getbufvar('%', 'ale_linted', 0) == 0
        lua vim.notify("⏳ ALE: loading " .. vim.inspect(vim.b.ale_linters[vim.bo.filetype], { plain = true }))
    else
        let g:ale_status_checked[&filetype] = 1
        lua vim.notify("✅ ALE: " .. vim.inspect(vim.b.ale_linters[vim.bo.filetype], { plain = true }) .. " is ready")
    endif
endfunction

augroup ALESettings
    autocmd!
    " 自动命令：当 ALE 创建预览选择窗口时自动处理
    autocmd FileType ale-preview-selection call <sid>ale_show_selections()

    autocmd User ALELSPStarted call <sid>ale_show_status()
    autocmd User ALELintPost call <sid>ale_show_status()
augroup END

" 注册用户命令：PrettyFindSymbols
" 用法：:PrettyFindSymbols [action]
command! -nargs=* PrettyFindSymbols call <sid>ale_find_symbols(<f-args>)

" 快捷键映射：<C-i> 显示悬浮提示
" 背景：nvim-cmp 无法触发 ale 的悬浮提示功能
" 解决方案：手动触发 ALE 的悬浮提示功能
nnoremap <silent> <C-i>     :PrettyFindSymbols hints<cr>
inoremap <silent> <C-i>     <C-o>:PrettyFindSymbols hints<cr>

" Go to Define and Back (Top of stack)
" TODO: map K,<C-]>,gD,... to one key
"nnoremap gd         <C-]>
nnoremap <silent> gr        :PrettyFindSymbols refactor<cr>
nnoremap <silent> gd        :PrettyFindSymbols definition<cr>
nnoremap <silent> gD        :PrettyFindSymbols implementation<cr>
nnoremap <silent> gs        :PrettyFindSymbols references<cr>
nnoremap <silent> gb        <C-T>

" Go to man or doc
nnoremap <silent> gk        K

" Go to Type
" nmap gt

" Go to next error of ale
nnoremap <silent> ge        <Plug>(ale_next_wrap)

