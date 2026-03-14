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
