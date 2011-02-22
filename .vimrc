set nocompatible
filetype plugin indent on
"source $VIMRUNTIME/vimrc_example.vim
"source $VIMRUNTIME/mswin.vim
"behave mswin

" set gfn=Consolas

" set diffexpr=MyDiff()
" function MyDiff()
" let opt = '-a --binary '
" if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
" if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
" let arg1 = v:fname_in
" if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
" let arg2 = v:fname_new
" if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
" let arg3 = v:fname_out
" if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
" let eq = ''
" if $VIMRUNTIME =~ ' '
" if &sh =~ '\<cmd'
" let cmd = '""' . $VIMRUNTIME . '\diff"'
" let eq = '"'
" else
" let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
" endif
" else
" let cmd = $VIMRUNTIME . '\diff'
" endif
" silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
" endfunction

" Make .tal files have HTML syntax
au BufRead, BufNewFile *.tal setfiletype html
au BufRead, BufNewFile *.djhtml setfiletype html

" Source vim when this file is updated (although it doesn't work since it thinks we're in cygwin, dammit)
nmap ,s :source ~/.vimrc<cr>
nmap ,v :tabe ~/.vimrc<cr>
nmap ,h :tabe /etc/hosts<cr>
nmap cd :cd %:h<cr>

" Nerd Tree mapping
nmap <LocalLeader>nt :NERDTreeToggle<cr>

" Don't want no lousy .swp files in my directoriez
set backupdir=~

nnoremap <LocalLeader>t :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

" Insert item at end of list
nmap <LocalLeader>i [{%kA,<Esc>o

" Clear search highlighting so you don't have to search for /asdfasdf
nmap <silent> ,/ :nohlsearch<CR>

" Jump backwards to previous function, assumes code is indented (useful when inside function)
" Jump to top level function
nmap ,f ?^func\\|^[a-zA-Z].*func<CR>,/
" Jump to start of whatever function we're inside
" nmap bf ?^\s*func<CR>,/

" faster tab switching
nmap <C-l> gt
nmap <C-h> gT

set ff=unix
colorscheme vividchalk
set ic
set scs
set guioptions=mer

set tabstop=4
set shiftwidth=4
set smarttab
set et

set nocindent
set autoindent
set lbr

" highlight search results
set hls

" incsearch is search while typing, shows matches before hitting enter
set is

" set bottom indicator
set ruler
set sc
