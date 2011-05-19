" Plugins installed:
" Pathogen!
" Surround (cs"' to repla"ce " with '
" Command-T
" Gundo
" Repeat (lets plugins access . for repeat)
" NERDCommenter
" Fugitive
" Matchit (Match more than (, [, etc with %)

set nocompatible

" Pathogen loading
filetype off
call pathogen#helptags()
call pathogen#runtime_append_all_bundles() 
filetype plugin indent on

" change the mapleader from \ to ,
let mapleader=","

" lets you do w!! to sudo write the file
cmap w!! w !sudo tee % >/dev/null

" experimental: remap ; to :
" nnoremap ; :

" Make .tal files have HTML syntax
au BufRead, BufNewFile *.tal setfiletype html
au BufRead, BufNewFile *.djhtml setfiletype html

" Source vim when this file is updated (although it doesn't work since it thinks we're in cygwin, dammit)
nmap ,s :source $MYVIMRC<cr>
nmap ,v :tabe $MYVIMRC<cr>
nmap ,h :tabe /etc/hosts<cr>
nmap cd :cd %:h<cr>:pwd<cr>

" Surround mappings, switch " and ' with c
nmap c' cs'"
nmap c" cs"'

" Don't want no lousy .swp files in my directoriez
set backupdir=~

" hide buffers instead of closing, can do :e on an unsaved buffer
set hidden

" wildignore all of these when autocompleting
set wig=*.swp,*.bak,*.pyc,*.class

" shiftround, always snap to multiples of shiftwidth when using > and <
set sr

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
