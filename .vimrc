" Plugins installed:
" :read !ls ~/.vim/bundle
" Pathogen!
" Rename
" ack.vim
" bufexplorer
" coffee-script
" ctrlp.vim
" django.vim
" fugitive
" gundo
" javascript-lint
" jira-completer
" lusty-juggler
" matchit
" mru
" nerd-tree
" nerdcommenter
" rainbow-parentheses
" repeat
" search-replace-highlight
" surround
" tagbar
" ultisnips
" vim-nerdtree-tabs
" vim-pasta
" vim-powerline
" vim-unimpaired

" ---------------------------------------------------------------
" Custom setup
" ---------------------------------------------------------------

colorscheme vividchalk
set nocompatible

" Pathogen loading
filetype off
call pathogen#helptags()
call pathogen#runtime_append_all_bundles() 
filetype plugin indent on

syntax on

" Custom file type syntax highlighting
au BufRead, BufNewFile *.tal setfiletype html
au BufRead, BufNewFile *.djhtml setfiletype html
au BufRead,BufNewFile .bash_config set ft=sh syntax=sh

" JSLint options for custom procesing file
let jslint_command_options = '-nofilelisting -nocontext -nosummary -nologo -conf ~/.jsl -process'
let jslint_highlight_color = 'Red'

let g:UltiSnipsExpandTrigger='<tab>'
let g:UltiSnipsJumpForwardTrigger='<tab>'
let g:UltiSnipsJumpBackwardTrigger='<s-tab>'

" Set Ctrl-P to show match at top of list instead of at bottom, which is so
" stupid that it's not default
let g:ctrlp_match_window_reversed = 0

" Tell Ctrl-P to keep the current VIM working directory when starting a
" search, another really stupid non default
let g:ctrlp_working_path_mode = 0

" Ctrl-P ignore target dirs so VIM doesn't have to! Yay!
let g:ctrlp_custom_ignore = {'dir': '\.git$\|\.hg$\|\.svn$|target'}

" Open multiplely selected files in a tab by default
let g:ctrlp_open_multi = '10t'

" Powerline custom font
if has('gui_running')
  set guifont=Menlo\ for\ Powerline
endif

" ---------------------------------------------------------------
" Functions
" ---------------------------------------------------------------

function! ToggleJSL()
    " I DO NOT WORK YET AND AM A PIECE OF SHIT DO NOT USE ME
    if !exists("s:jsl_enabled")
        let s:jsl_enabled = 0
    endif
    if s:jsl_enabled == 1
        autocmd! BufWritePost *.js call JavascriptLint()
        autocmd! FileWritePost *.js call JavascriptLint()
        autocmd! BufWinLeave * call MaybeClearCursorLineColor()
        let s:jsl_enabled = 0
    else
        autocmd BufWritePost,FileWritePost *.js call JavascriptLint()
        autocmd BufWinLeave * call MaybeClearCursorLineColor()
        let s:jsl_enabled = 1
    endif
endfunction

function! Refactor()
    call inputsave()
    let @z=input("What do you want to rename '" . @z . "' to? ")
    call inputrestore()
endfunction

function! s:VSetSearch()
  let old = @"
  norm! gvy
  let @/ = '\V' . substitute(escape(@", '\'), '\n', '\\n', 'g')
  let @" = old
endfunction

function! s:VAck()
  let old = @"
  norm! gvy
  let @z = substitute(escape(@", '\'), '\n', '\\n', 'g')
  let @" = old
endfunction

" ---------------------------------------------------------------
" Key mappings
" ---------------------------------------------------------------

" change the mapleader from \ to ,
let mapleader=","

" lets you do w!! to sudo write the file
nmap <Leader>ww :w !sudo tee % >/dev/null<cr>

" Ray-Frame testing thingy
nmap <Leader>xx :tabe a.js<cr>GVggx"*p<cr>:%s/;/;\r/g<cr>:w<cr>

" Command-T file finder
nnoremap <silent> <Leader>T :CommandT<cr>
let g:CommandTAcceptSelectionMap = '<C-o>'
let g:CommandTAcceptSelectionTabMap = '<CR>'

" Gundo tree viewer
nnoremap <Leader>u :GundoToggle<CR>

nmap <Leader>tjs :call ToggleJSL()<cr>

" Clear search highlighting so you don't have to search for /asdfasdf
nmap <silent> <Leader>/ :nohlsearch<CR>

" Jump backwards to previous function, assumes code is indented (useful when inside function)
" Jump to top level function
nmap <Leader>f ?^func\\|^[a-zA-Z].*func<CR>,/

" faster tab switching
nmap <C-l> gt
nmap <C-h> gT

" Fugitive
nmap <Leader>gs :Gstatus<CR>
nmap <Leader>gc :Gcommit<CR>
nmap <Leader>gd :Gdiff<CR>
nmap <Leader>gl :tabe %<cr>:Glog<cr><cr>:copen<cr>

" Ack
nmap <Leader>aw "zyiw:exe "Ack! ".@z.""<CR>
nmap <Leader>aW "zyiW:exe "Ack! ".@z.""<CR>

nmap <Leader>rp :call rainbow_parentheses#Toggle()<cr>

" Source vim when this file is updated (although it doesn't work since it thinks we're in cygwin, dammit)
nmap <Leader>sv :source $MYVIMRC<cr>
nmap <silent> <Leader>so :source %<cr>
nmap <Leader>v :tabe $MYVIMRC<cr>
nmap <Leader>ss :tabe ~/.vim/bundle/ultisnips/UltiSnips/javascript.snippets<cr>
nmap <Leader>hs :tabe /etc/hosts<cr>
nmap <Leader>js :tabe ~/.jsl<cr>

" Copy current buffer path relative to root of VIM session to system clipboard
nmap <Leader>yp :let @*=expand("%")<cr>:echo "Copied file path to clipboard"<cr>
" Copy current filename to system clipboard
nmap <Leader>yf :let @*=expand("%:t")<cr>:echo "Copied file name to clipboard"<cr>
" Copy current buffer path without filename to system clipboard
nmap <Leader>yd :let @*=expand("%:h")<cr>:echo "Copied file directory to clipboard"<cr>

" Highlight last yanked / pasted text
nmap <Leader>ht `[v`]

" NerdTree
nmap <Leader>nt :NERDTreeTabsToggle<cr>

" Change to working directory of current file and echo new location
nmap cd :cd %:h<cr>:pwd<cr>

" Surround mappings, switch " and ' with c
nmap c' cs'"
nmap c" cs"'

" Swap two parameters in a function
nmap <Leader>- lF(ldWf)i, pF,dt)

" Strip one layer of nesting
nmap <Leader>sn [{mzjV]}k<]}dd`zdd

" MRU mappings, open most recent files list
nmap <Leader>ml :MRU<cr>
" Opens mru which lets files autocomplete
nmap <Leader>me :MRU 

" Alphabetize CSS rules if on mulitple lines
nmap <Leader>rs vi{:sort<cr>

" trim trailing whitespace
nnoremap <LocalLeader>t :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

" * and # search for next/previous of selected text when used in visual mode
vnoremap * :<C-u>call <SID>VSetSearch()<CR>/<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>?<CR>

vnoremap <Leader>av :<C-u>call <SID>VAck()<CR>:exe "Ack! ".@z.""<CR>

" tagbar open
nnoremap <silent> <F3> :TagbarToggle<CR>

" Execute VIM colon command under cursor with <⌘-e>
nmap <D-e> yy:<C-r>"<backspace><cr>

" Locally (local to block) rename a variable
nmap <Leader>rf "zyiw:call Refactor()<cr>mx:silent! norm gd<cr>:silent! norm [{<cr>$V%:s/<C-R>//<c-r>z/g<cr>`x

" ------------------------------------------------------------------------------------------
" VIM setup
" ------------------------------------------------------------------------------------------

" Paste toggle
set pastetoggle=<F2>

" Don't want no lousy .swp files in my directoriez
set backupdir=~

" hide buffers instead of closing, can do :e on an unsaved buffer
set hidden

" wildignore all of these when autocompleting
set wig=*.swp,*.bak,*.pyc,*.class,node_modules*,*.ipr,*.iws

" shiftround, always snap to multiples of shiftwidth when using > and <
set sr

" Testing out relative line number
setglobal relativenumber

set ff=unix
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

" tell tagbar to open on left
let g:tagbar_left=1

" Powerline symbols instead of letters
let g:Powerline_symbols = 'fancy'

" Always have statusline so powerline shows up on non-split windows
set laststatus=2

" Don't open nerdtree feature expander open on startup
let g:nerdtree_tabs_open_on_gui_startup=0

" Include $ in varibale names
set iskeyword=@,48-57,_,192-255,#,$

"autocmd! BufWritePost,FileWritePost *.vm :silent !echo " " >> atlassian-universal-plugin-manager-plugin/src/main/java/com/atlassian/upm/PluginManagerServlet.java

" ------------------------------------------------------------------------------------------
" I no spell gud
" ------------------------------------------------------------------------------------------

ab funcion function
ab funicton function
ab funciton function
ab updateable updatable
ab Updateable Updatable
