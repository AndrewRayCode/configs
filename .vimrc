" Plugins installed:
" Command-T
" Gundo
" NERDCommenter
" Fugitive

set nocompatible
filetype plugin indent on

" Make .tal files have HTML syntax
au BufRead, BufNewFile *.tal setfiletype html
au BufRead, BufNewFile *.djhtml setfiletype html

" Source vim when this file is updated (although it doesn't work since it thinks we're in cygwin, dammit)
nmap ,s :source ~/.vimrc<cr>
nmap ,v :tabe ~/.vimrc<cr>
nmap ,h :tabe /etc/hosts<cr>
nmap cd :cd %:h<cr>

" Don't want no lousy .swp files in my directoriez
set backupdir=~

nnoremap <LocalLeader>t :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

" Command-T file finder
nnoremap <silent> ,t :CommandT<cr>

" Gundo tree viewer
nnoremap ,u :GundoToggle<CR>

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

" Fugitive
nmap ,gs :Gstatus<CR>
nmap ,gc :Gcommit<CR>
nmap ,gd :Gdiff<CR>

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


" * and # search for next/previous of selected text when used in visual mode
vnoremap * :<C-u>call <SID>VSetSearch()<CR>/<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>?<CR>

function! s:VSetSearch()
  let old = @"
  norm! gvy
  let @/ = '\V' . substitute(escape(@", '\'), '\n', '\\n', 'g')
  let @" = old
endfunction

