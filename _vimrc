set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

set gfn=Consolas

" Make .tal files have HTML syntax
au BufRead, BufNewFile *.tal setfiletype html
au BufRead, BufNewFile *.djhtml setfiletype html

" Source vim when this file is updated (although it doesn't work since it thinks we're in cygwin, dammit)
autocmd! bufwritepost _vimrc source %
nmap ,s :source $VIM/_vimrc<cr>
nmap ,v :tabe $VIM/_vimrc<cr>
nmap ,h :tabe C:\Windows\System32\drivers\etc\hosts<cr>
nmap cd :cd %:h<cr>

" Nerd Tree mapping
nmap <LocalLeader>nt :NERDTreeToggle<cr>

" Don't want no lousy .swp files in my directoriez
set backupdir=G://Program\ Files//Vim//tmp

nnoremap <LocalLeader>t :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

" Insert item at end of list
nmap <LocalLeader>i [{%kA,<Esc>o

set noet
set ff=unix
colorscheme vividchalk
set ic
set scs
set guioptions=mer

set tabstop=4
set shiftwidth=4
set smarttab
" set expandtab

set nocindent
set autoindent
set lbr
set shell=G:/cygwin/bin/bash
set shellcmdflag=--login\ -c
set shellxquote=\"
