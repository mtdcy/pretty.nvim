" AI: CodeCompanion.nvim configuration
" Environment variables already loaded by init.vim

" Global options, must set properly
let g:pretty_ai_namespace = nvim_create_namespace('pretty.nvim.ai')
let g:pretty_ai_ftype="codecompanion"

" => Check API Key first
" => Load corresponding configuration
if empty($OPENAI_API_KEY)
    finish
endif

luafile <sfile>:h/codecompanion.lua

" => Basic commands
command! -nargs=* AICodingInline CodeCompanion <args>
command! -nargs=* AIChatToggle CodeCompanionChat Toggle <args>
command! AIChatSubmit lua require('codecompanion').last_chat():submit()

augroup AICodingChat
    autocmd!
    autocmd User CodeCompanionChatCreated silent! call s:AIChatReady()
    autocmd User CodeCompanionChatDone silent! call s:AIChatReady()
augroup END

" Inline mode - <leader>ai
nnoremap <silent> <leader>ai :call <SID>AICodingInline()<CR>
" Visual mode - suppress the automatic range with <C-U>
"  - without <C-U> function will be called twice.
"vnoremap <silent> <leader>ai :<C-u>call <SID>AICodingInline()<CR>
" Visual mode - use CodeCompanion directly
"  - our AICodingInline() still has problem with visual mode.
vnoremap <silent> <leader>ai :CodeCompanion<CR>

" Chat mode - F5
noremap  <silent> <F5> :AIChatToggle<CR>

" ============================================================================
" AI Functions (unified for both engines)
" ============================================================================
function! s:AICodingContext() abort
    " find out the right winnr & bufnr
    let l:winnr = winnr()
    " use last window's winnr if this is AI chat window
    if &filetype == g:pretty_ai_ftype | let l:winnr = winnr('#') | endif

    let l:bufnr = winbufnr(l:winnr)

    " win_getid: line() do not accept winnr
    let l:start = line("'<", win_getid(l:winnr))
    let l:end = line("'>", win_getid(l:winnr))

    if l:start != l:end && visualmode() ==? 'v'
        let l:lines = "#<" .. l:start .. ", " ..  l:end .. ">"
    else
        let l:lines = "#" .. line(".", win_getid(l:winnr))
    endif

    " AI coding context: file:#line
    " - #line 和 #{buffer} 是关键
    return "📄 File: " .. bufname(l:bufnr) .. ":" .. l:lines .. " #{buffer}"
endfunction

function! s:AICodingInline() abort
    " read user prompt
    let l:prompt = input('🌹 AI Coding: ', "")

    if l:prompt == ''
        echom '⚠️ empty input'
        return
    endif

    let l:context = s:AICodingContext()

    " debug
    "echom l:context

    " inline: context - prompt
    exe ":AICodingInline " .. l:context .. "\n🙋 User:" .. l:prompt
endfunction

function! s:AIChatReady() abort
    if &filetype != g:pretty_ai_ftype | return | endif

    " 1. exit insert mode
    stopinsert

    " 2. show tips
    call s:AIChatTips('🌹 AI Chat Ready✨! Enter 发送消息，Shift-Enter 换行')

    " 3. do keymaps
    inoremap <silent><buffer> <Esc> <C-o>:call <SID>AIChatReady()<CR>
    " => Insert at end
    nnoremap <silent><buffer> i    : call <SID>AIChatEdit()<CR>
    nnoremap <silent><buffer> a    : call <SID>AIChatEdit()<CR>
    nnoremap <silent><buffer> <CR> : call <SID>AIChatEdit()<CR>
    " => Enter: submit user message (insert mode only)
    inoremap <silent><buffer> <CR> <C-o>:call <SID>AIChatSend()<CR>
endfunction

function! s:AIChatTips(message) abort
    let l:bufnr = bufnr('%')
    call nvim_buf_clear_namespace(l:bufnr, g:pretty_ai_namespace, 0, -1)
    if a:message == '' | return | endif

    " line - 1: line() start with 1, but nvim use 0-based index.
    call nvim_buf_set_extmark(l:bufnr, g:pretty_ai_namespace, line('$') - 1, 0, {
        \ 'virt_text': [[a:message, 'Keyword']],
        \ 'virt_text_pos': 'eol',
        \ 'hl_mode': 'combine',
        \ })
endfunction

function! s:AIChatEdit() abort
    " 1. clear tips
    call s:AIChatTips('')

    " 2. to the end
    call cursor(line('$'), 0)

    " 3. start insert
    startinsert
endfunction

function! s:AIChatSend() abort
    " 1. exit insert mode
    stopinsert

    " 2. append context to last
    call append(line('$'), s:AICodingContext())
    call append(line('$'), "") " always append a empty line
    call cursor(line('$'), 0)

    " 3. show tips
    call s:AIChatTips('🤖 AI is working...')

    " 4. submit using AIChatSubmit command
    exe ":AIChatSubmit"
endfunction
