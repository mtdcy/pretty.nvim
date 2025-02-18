" Author: dsifford <dereksifford@gmail.com>
" Description: A performant type-checker supporting LSP for Python 3 created by Facebook

call ale#Set('python_pyre_executable', 'pyre')
call ale#Set('python_pyre_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_pyre_auto_pipenv', 0)
call ale#Set('python_pyre_auto_poetry', 0)
call ale#Set('python_pyre_auto_uv', 0)

function! ale_linters#python#pyre#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'python_pyre_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'python_pyre_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'python_pyre_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif

    return ale#python#FindExecutable(a:buffer, 'python_pyre', ['pyre'])
endfunction

function! ale_linters#python#pyre#GetCommand(buffer) abort
    let l:executable = ale_linters#python#pyre#GetExecutable(a:buffer)
    let l:exec_args = (l:executable =~? '\(pipenv\|poetry\|uv\)$' ? ' run pyre' : '') . ' persistent'

    return ale#Escape(l:executable) . l:exec_args
endfunction

function! ale_linters#python#pyre#GetCwd(buffer) abort
    let l:local_config = ale#path#FindNearestFile(a:buffer, '.pyre_configuration.local')

    return fnamemodify(l:local_config, ':h')
endfunction

call ale#linter#Define('python', {
\   'name': 'pyre',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#python#pyre#GetExecutable'),
\   'command': function('ale_linters#python#pyre#GetCommand'),
\   'project_root': function('ale#python#FindProjectRoot'),
\   'completion_filter': 'ale#completion#python#CompletionItemFilter',
\   'cwd': function('ale_linters#python#pyre#GetCwd'),
\})
