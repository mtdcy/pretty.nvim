" AI: codecompanion.nvim - Vimscript configuration
" Environment variables already loaded by init.vim

" => Check API Key
if empty($OPENAI_API_KEY)
    let g:codecompanion_enabled = 0
    finish
else
    let g:codecompanion_enabled = 1
endif

let g:pretty_ai_prompt='🌹 AI Coding: '
let g:pretty_ai_message='🌹 AI Coding Ready✨! Enter 发送消息, Shift-Enter 换行'

" => Load Lua configuration (adapters setup only)
luafile <sfile>:h/ai.lua

" => Key Mappings
" Inline mode - <leader>ai
noremap <silent> <leader>ai :CodeCompanion<CR>

" Open Chat - F5 (right side split, mutually exclusive with tagbar)
noremap <silent> <F5>       :CodeCompanionChat Toggle<CR>

" => Chat Buffer Keymaps
" In normal mode, Enter enters insert mode instead of sending
augroup CodeCompanionChat
    autocmd!
    autocmd User CodeCompanionChatCreated silent! call s:AIChatSettings()
    " when CodeCompanion chat created, no BufEnter event
    autocmd User CodeCompanionChatCreated silent! call s:AIChatReady()
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

    " get previous window's bufnr
    let l:bufnr = winbufnr(winnr('#'))
    let l:bufname = bufname(l:bufnr)
    if l:bufname != '' && l:bufname != '[No Name]'
        " Store bufnr
        let g:pretty_ai_bufnr = l:bufnr
        " Store bufname
        let g:pretty_ai_bufname = l:bufname
        " Store cursor line
        let g:pretty_ai_line = line('.')
    endif

    " Show welcome message
    echom g:pretty_ai_message
endfunction

function! s:AIChatSend() abort
    " 1. Exit insert mode, user needs to scroll text after AI is done
    stopinsert

    " 2. Show "AI is working..." message
    echom '🤖 AI is working...'

    " 3. Send user prompt to LLM
    "  requires CodeCompanion send bind to Enter in normal mode
    call feedkeys("\<CR>")
    " XXX: find out CodeCompanion command to send
endfunction
