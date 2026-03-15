" AI: codecompanion.nvim - Vimscript configuration
" Environment variables already loaded by init.vim

" => Check API Key
if empty($OPENAI_API_KEY)
    let g:codecompanion_enabled = 0
    finish
else
    let g:codecompanion_enabled = 1
endif

let g:pretty_ai_namespace = nvim_create_namespace('pretty.nvim.ai')

" => Load Lua configuration (adapters setup only)
luafile <sfile>:h/codecompanion.lua

" => Key Mappings
" Inline mode - <leader>ai
"  e.g: check this function - works
nnoremap <silent> <leader>ai :call <SID>AICodingInline()<CR>
" Select mode - AICodingInline not work in select mode (FIXME)
"  e.g: write a function - works
xnoremap <silent> <leader>ai :CodeCompanion<CR>

" Chat mode - F5
noremap <silent> <F5>       :CodeCompanionChat Toggle<CR>

" AI Coding context make prompt simple, e.g:
"  check this function
" => with context, LLM knowns where to start the work
function! s:AICodingContext() abort
    " find out the right winnr & bufnr
    let l:winnr = winnr()
    " use last window's winnr
    if &filetype == "codecompanion" | let l:winnr = winnr('#') | endif

    let l:bufnr = winbufnr(l:winnr)

    let l:start = line("'<", bufwinid(l:bufnr))
    let l:end = line("'>", bufwinid(l:bufnr))

    if l:start != l:end
        let l:lines = "{" .. l:start .. ", " ..  l:end .. "}"
    else
        let l:lines = "#" .. line(".", bufwinid(l:bufnr))
    endif

    " AI coding context: file:line
    "  - I have tested a lot format, LLM can understand this format
    return "📄 File: " .. bufname(l:bufnr) .. ":" .. l:lines .. " #{buffer}"
endfunction

function! s:AICodingInline() abort
    " read user prompt
    call inputsave()
    let l:prompt = input('🌹 AI Coding: '.. mode(), "")
    call inputrestore()

    if l:prompt == ''
        echom '⚠️ empty input'
        return
    endif

    exe ":CodeCompanion " .. l:prompt .. " " .. s:AICodingContext()
endfunction

" => Chat Buffer Keymaps
" In normal mode, Enter enters insert mode instead of sending
augroup AICodingChat
    autocmd!
    autocmd User CodeCompanionChatCreated silent! call s:AIChatSettings()
    " when CodeCompanion chat created, no BufEnter event
    autocmd User CodeCompanionChatCreated silent! call s:AIChatReady()
    autocmd User CodeCompanionChatDone silent! call s:AIChatReady()
    " prepare for AI every time enter chat window
    autocmd BufEnter * call s:AIChatReady()
augroup END

function! s:AIChatSettings() abort
    " Normal mode: Send to LLM (keymaps.send in CodeCompanion)
    " Insert mode: Send (use <C-o> run command in insert mode)
    inoremap <silent><buffer> <CR> <C-o>:call <SID>AIChatSend()<CR>
endfunction

" called when enter AI chat window
function! s:AIChatReady() abort
    " only codecompanion
    if &filetype != "codecompanion" | return | endif

    " Show welcome message
    call s:AIChatMessage('🌹 AI Coding Ready✨! Enter 发送消息, Shift-Enter 换行')

    noremap <silent><buffer> i :call <SID>AIChatEdit()<CR>
endfunction

function! s:AIChatMessage(message) abort
    let l:bufnr = bufnr('%')

    " clear virtual text
    call nvim_buf_clear_namespace(l:bufnr, g:pretty_ai_namespace, 0, -1)

    if a:message == '' | return | endif

    " append a new line if last line is not empty
    if getline('$') =~ '^\\s*$'
        call append(line('$'), "")
    endif

    " show virtual text at last line
    "  XXX: getline('$') is last line, but line('$') is line count
    call nvim_buf_set_extmark(l:bufnr, g:pretty_ai_namespace, line('$') - 1, 0, {
        \ 'virt_text': [[a:message, 'Keyword']],
        \ 'virt_text_pos': 'eol',
        \ 'hl_mode': 'combine',
        \ })
endfunction

function! s:AIChatEdit() abort
    " clear virtual text
    call s:AIChatMessage('')

    " go to last line
    normal! G

    " start insert
    startinsert
endfunction

function! s:AIChatSend() abort
    " 1. Exit insert mode, user needs to scroll text after AI is done
    stopinsert

    " 2. auto insert messages
    call append(line('.') - 1, s:AICodingContext())

    " 3. Show "AI is working..." message
    call s:AIChatMessage('🤖 AI is working...')

    " 4. Send user prompt to LLM
    "  requires CodeCompanion send bind to Enter in normal mode
    call feedkeys("\<CR>")
    " XXX: find out CodeCompanion command to send
endfunction
