" Plugins:

" => Rainbow
" let g:rainbow_active = 1 => cause conceal feature stop working
autocmd FileType vim,sh,c,cpp,html call rainbow_main#load()

" => Commenter
let g:NERDCreateDefaultMappings = 0
let g:NERDDefaultAlign = 'left'

" => Matchtags
let g:vim_matchtag_enable_by_default = 1
let g:vim_matchtag_files = '*.html,*.xml,*.js,*.jsx,*.ts,*.tsx,*.vue,*.svelte,*.jsp,*.php,*.erb'
highlight link matchTag Search
highlight link matchTag MatchParen
highlight link matchTagError Todo
highlight matchTag gui=reverse

" => devicons
" https://github.com/ryanoasis/vim-devicons/wiki/Extra-Configuration
let g:webdevicons_enable = 1
let g:webdevicons_enable_nerdtree = 1
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:DevIconsEnableFoldersOpenClose = 1
let NERDTreeDirArrowExpandable=''
let NERDTreeDirArrowCollapsible=''

let g:webdevicons_enable_denite = 1

" => tabular
" NOTHING HERE
