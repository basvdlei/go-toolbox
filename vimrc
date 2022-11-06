set nocompatible
set encoding=utf-8
"set noautochdir
set colorcolumn=80
set history=1000
set shell=/bin/bash
syntax on
colorscheme jellybeans
set nobackup

filetype plugin indent on

" Somehow gofmt on save is completly broken for me
au BufWritePost *.go :GoFmt

let g:ycm_key_detailed_diagnostics = '<leader>D'
let g:go_def_mode='gopls'
let g:go_fmt_command = "goimports"
let g:go_autodetect_gopath = 1
let g:go_list_type = "quickfix"

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_generate_tags = 1

let g:terraform_fmt_on_save = 1

au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)

au FileType go nmap <Leader>ds <Plug>(go-def-split)
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>dt <Plug>(go-def-tab)

au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)

au FileType go nmap <Leader>gb <Plug>(go-doc-browser)

set number
set relativenumber
set backspace=2
set whichwrap+=<,>,h,l
set mouse=a
set clipboard=unnamedplus
set noerrorbells
set vb
set ruler

" Create an extra status line with Git branch info
set statusline=%{fugitive#statusline()}  " Add git info
set statusline+=%f                       " Path to the file
set statusline+=%=                       " Switch to the right side
set statusline+=%l                       " Current line
set statusline+=/                        " Separator
set statusline+=%L                       " Total lines
set laststatus=2                         " Always display status bar
