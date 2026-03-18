" AI: CodeCompanion.nvim configuration
" Environment variables already loaded by init.vim

" Global options, must set properly
let g:aicoding_ftype="codecompanion"
let g:aicoding_tips_ready='🌹 AI Chat Ready✨!  Enter: 发送消息，Shift-Enter: 换行 '
let g:aicoding_tips_thinking='🤖 AI is thinking ...'

" => Check API Key first
" => Load corresponding configuration
if empty($OPENAI_API_KEY)
    finish
endif

luafile <sfile>:h/codecompanion.lua

" => Basic commands
command! -nargs=* AICodingInline CodeCompanion <args>
command! -nargs=* AIChatLaunch CodeCompanionActions <args>
command! -nargs=* AIChatToggle CodeCompanionChat Toggle <args>
command! -nargs=0 AIChatSubmit lua require('codecompanion').last_chat():submit()

augroup AICodingChat
    autocmd!
    autocmd User CodeCompanionChatCreated   call AIChatReady()
    autocmd User CodeCompanionChatDone      call AIChatReady()
augroup END

" ============================================================================
" AI Functions (unified for both engines)
" ============================================================================
function! s:AICodingContext() abort
    " find out the right winnr & bufnr
    let l:winnr = winnr()
    " use last window's winnr if this is AI chat window
    if &filetype == g:aicoding_ftype | let l:winnr = winnr('#') | endif

    let l:bufnr = winbufnr(l:winnr)

    " win_getid: line() do not accept winnr
    let l:start = line("'<", win_getid(l:winnr))
    let l:end = line("'>", win_getid(l:winnr))

    " LLM accept file:#line or file:<start,end> format (tested)
    if l:start != l:end && visualmode() ==? 'v'
        let l:lines = "<" .. l:start .. "," ..  l:end .. ">"
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

function! AIChatEdit() abort
    " 1. clear tips
    call ShowTips('')

    " 2. to the end
    call cursor(line('$'), 0)

    " 3. start insert
    startinsert
endfunction

function! AIChatSend() abort
    " 1. exit insert mode
    stopinsert

    " 2. append context to last
    call append(line('$'), s:AICodingContext())
    call append(line('$'), "") " always append a empty line
    call cursor(line('$'), 0)

    " 3. show tips
    call ShowTips(g:aicoding_tips_thinking)

    " 4. submit using AIChatSubmit command
    exe ":AIChatSubmit"
endfunction

function! AIChatReady() abort
    if &filetype != g:aicoding_ftype | return | endif

    " 1. exit insert mode
    stopinsert

    " 2. show tips
    call ShowTips(g:aicoding_tips_ready)

    " 3. do keymaps
    call CloseWith('AIChatToggle')
    call StartInsertWith('call AIChatEdit()')
    call StopInsertWith('call AIChatReady()')

    " => Enter: insert at end (Normal mode)
    nnoremap <silent><buffer> <CR>  :call AIChatEdit()<CR>
    " => Enter: submit message (Insert mode)
    inoremap <silent><buffer> <CR>  <C-o>:call AIChatSend()<CR>
endfunction

" Inline mode - <leader>ai
nnoremap <silent> <leader>ai :call <SID>AICodingInline()<CR>
" Visual mode - suppress the automatic range with <C-U>
"  - without <C-U> function will be called twice.
vnoremap <silent> <leader>ai :<C-u>call <SID>AICodingInline()<CR>

" Chat mode - F5
noremap  <silent> <S-F5> : AIChatLaunch<CR>
noremap  <silent> <F5>   : AIChatToggle<CR>
