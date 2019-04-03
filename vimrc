set nocompatible
set encoding=utf-8
set noautochdir
set colorcolumn=80
set history=1000
syntax on
colorscheme jellybeans
set nobackup

let g:ycm_key_detailed_diagnostics = '<leader>D'
let g:go_fmt_command = "goimports"

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
