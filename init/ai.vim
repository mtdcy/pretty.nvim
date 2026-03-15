" AI: codecompanion.nvim - Vimscript configuration
" Environment variables already loaded by init.vim

" => Check API Key
if empty($OPENAI_API_KEY)
    let g:codecompanion_enabled = 0
    finish
else
    let g:codecompanion_enabled = 1
endif

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
    autocmd User CodeCompanionChatCreated call s:ChatKeymaps()
    " Track code buffer info when leaving code window for chat
    autocmd WinLeave * call s:TrackCodeBuffer()
augroup END

function! s:ChatKeymaps() abort
    " Normal mode: Enter to enter insert mode
    nnoremap <silent><buffer> <CR> i
endfunction

" Track current buffer info before entering chat
function! s:TrackCodeBuffer() abort
    let l:bufname = expand('%:p')
    if l:bufname != '' && l:bufname != '[No Name]'
        " Store file path
        let g:pretty_ai_file = l:bufname
        " Store cursor line
        let g:pretty_ai_line = line('.')
    endif
endfunction
