" Plugins installed:
" :read !ls ~/.vim/bundle
"Rename
"ack.vim
"bufexplorer
"coffee-script
"ctrlp.vim
"django.vim
"easymotion
"fugitive
"gundo
"indexed-search
"javascript-lint
"jira-completer
"lusty-explorer
"lusty-juggler
"matchit
"mru
"neocomplete
"nerd-tree
"nerdcommenter
"rainbow-parentheses
"repeat
"scala
"search-replace-highlight
"surround
"tagbar
"ultisnips
"vim-clojure
"vim-nerdtree-tabs
"vim-pasta
"vim-powerline
"vim-unimpaired

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
au BufRead,BufNewFile *.tt set filetype=html
au BufRead,BufNewFile *.djhtml set filetype=html
au BufRead,BufNewFile *.soy set filetype=clojure
au BufRead,BufNewFile .bash_config set ft=sh syntax=sh
au BufRead,BufNewFile .jshintrc set ft=javascript

" Fuck everything about rainbow parentheses
au VimEnter * RainbowParenthesesToggle
au Syntax javascript RainbowParenthesesLoadRound
au Syntax javascript RainbowParenthesesLoadSquare
au Syntax javascript RainbowParenthesesLoadBraces

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
let g:ctrlp_custom_ignore = {'dir': '\.git$\|\.hg$\|\.svn$\|target$|built$'}

" Open multiplely selected files in a tab by default
let g:ctrlp_open_multi = '10t'

" Powerline custom font
if has('gui_running')
  set guifont=Menlo\ for\ Powerline
endif

" ---------------------------------------------------------------
" Functions
" ---------------------------------------------------------------
"
function! ToggleRelativeAbsoluteNumber()
    if &number
    set relativenumber
    else
    set number
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

" Jump to template definition
function! s:TemplateAck()
    let old = @"
    norm! gvy
    let list = split(@", "\\.")

    " not namespaced
    if len(list) == 1
        let @z = "'{template.\\." . list[0] . "}' --soy -1 --nocolor"
    " namespaced
    elseif
        let @z = "'^(?\\!.*namespace.*" . list[0] . ").*" . list[1] . "' --soy -1 --nocolor"
    end
    let @" = old

    redir => captured
    exe ":silent !ack " . @z
    redir END

    let lines = split(captured)
    let lineNo = split(lines[6], ":")[0]

    exe ":tabe " . lines[5]
    " Jump to line no
    exe "normal" . lineNo . "GV"
endfunction

" Jump to template definition
function! s:SSPAck()
    let old = @"
    norm! gvy

    " not namespaced
    let @z = '. -regex ".*' . @" . '.ssp"'
    let @" = old

    redir => captured
    exe ":silent !find " . @z
    redir END

    exe ":tabe " . split(captured)[4]
endfunction

" ---------------------------------------------------------------
" Key mappings
" ---------------------------------------------------------------

" change the mapleader from \ to ,
let mapleader=","

" lets you do w!! to sudo write the file
nnoremap <Leader>ww :w !sudo tee % >/dev/null<cr>

" Ray-Frame testing thingy
" nnoremap <Leader>x:tabe a.js<cr>GVggx"*p<cr>:%s/;/;\r/g<cr>:w<cr>

nnoremap <Leader>x :tabcl<cr>

" Command-T file finder
nnoremap <silent> <Leader>T :CommandT<cr>
let g:CommandTAcceptSelectionMap = '<C-o>'
let g:CommandTAcceptSelectionTabMap = '<CR>'

" New tab
nnoremap <Leader>te :tabe 

" Gundo tree viewer
nnoremap <Leader>u :GundoToggle<CR>

" Clear search highlighting so you don't have to search for /asdfasdf
nnoremap <silent> <Leader>/ :nohlsearch<CR>

" Jump backwards to previous function, assumes code is indented (useful when inside function)
" Jump to top level function
nnoremap <Leader>f ?^func\\|^[a-zA-Z].*func<CR>,/

" faster tab switching
nnoremap <C-l> gt
nnoremap <C-h> gT

" Fugitive
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>gd :Gdiff<CR>

" Extradite
nnoremap <Leader>gl :Extradite!<CR>
nnoremap <Leader>df :tabe<cr>:Explore .<cr>:Git! diff<CR>

" Ack
nnoremap <Leader>aw "zyiw:exe "Ack! ".@z.""<CR>
nnoremap <Leader>aW "zyiW:exe "Ack! ".@z.""<CR>

nnoremap <Leader>rp :call rainbow_parentheses#Toggle()<cr>

" Source vim when this file is updated (although it doesn't work since it thinks we're in cygwin, dammit)
nnoremap <Leader>sv :source $MYVIMRC<cr>
nnoremap <silent> <Leader>so :source %<cr>
nnoremap <Leader>v :tabe $MYVIMRC<cr>
nnoremap <Leader>ss :tabe ~/.vim/bundle/ultisnips/UltiSnips/javascript.snippets<cr>
nnoremap <Leader>hs :tabe /etc/hosts<cr>
nnoremap <Leader>js :tabe ~/.jsl<cr>

" Copy current buffer path relative to root of VIM session to system clipboard
nnoremap <Leader>yp :let @*=expand("%")<cr>:echo "Copied file path to clipboard"<cr>
" Copy current filename to system clipboard
nnoremap <Leader>yf :let @*=expand("%:t")<cr>:echo "Copied file name to clipboard"<cr>
" Copy current buffer path without filename to system clipboard
nnoremap <Leader>yd :let @*=expand("%:h")<cr>:echo "Copied file directory to clipboard"<cr>

" Highlight last yanked / pasted text
nnoremap <Leader>ht `[v`]

" NerdTree
nnoremap <Leader>nt :NERDTreeTabsToggle<cr>

" Change to working directory of current file and echo new location
nnoremap cd :cd %:h<cr>:pwd<cr>

" Surround mappings, switch " and ' with c
nmap c' cs'"
nmap c" cs"'

" Swap two parameters in a function
nnoremap <Leader>- lF(ldWf)i, pF,dt)

" Strip one layer of nesting
nnoremap <Leader>sn [{mzjV]}k<]}dd`zdd

" MRU mappings, open most recent files list
nnoremap <Leader>ml :MRU<cr>
" Opens mru which lets files autocomplete
nnoremap <Leader>me :MRU 

" Alphabetize CSS rules if on mulitple lines
nnoremap <Leader>rs vi{:sort<cr>

" trim trailing whitespace
nnoremap <LocalLeader>sw :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

" * and # search for next/previous of selected text when used in visual mode
vnoremap * :<C-u>call <SID>VSetSearch()<CR>/<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>?<CR>

" Ack for visual selection
vnoremap <Leader>av :<C-u>call <SID>VAck()<CR>:exe "Ack! ".@z.""<CR>
" Ack for word under cursor
nnoremap <Leader>av :Ack!<cr>
" Open Ack
nnoremap <Leader>ao :Ack! -i 

nnoremap <Leader>at vi":<C-u>call <SID>TemplateAck()<CR>

nnoremap <Leader>as vi":<C-u>call <SID>SSPAck()<CR>

" tagbar open
nnoremap <silent> <Leader>tb :TagbarToggle<CR>

" Execute VIM colon command under cursor with <⌘-e>
nnoremap <D-e> yy:<C-r>"<backspace><cr>

" Locally (local to block) rename a variable
nnoremap <Leader>rf "zyiw:call Refactor()<cr>mx:silent! norm gd<cr>:silent! norm [{<cr>$V%:s/<C-R>//<c-r>z/g<cr>`x

" Close the quickfix window from anywhere
nmap <Leader>cl :ccl<cr>

" Make Y yank till end of line
nnoremap Y y$

" In command line mode use ctrl-direction to move instead of arrow keys
cnoremap <C-j> <t_kd>
cnoremap <C-k> <t_ku>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" Toggle relative / line number
nnoremap <leader>rl :call ToggleRelativeAbsoluteNumber()<CR>

" use space to cycle between splits
nmap <Space> <C-w>w
nmap <S-Space> <C-w>W

" ------------------------------------------------------------------------------------------
" VIM setup
" ------------------------------------------------------------------------------------------

set sessionoptions+=winpos

" Paste toggle
set pastetoggle=<F2>

" Don't want no lousy .swp files in my directoriez
set backupdir=~

" hide buffers instead of closing, can do :e on an unsaved buffer
set hidden

" wildignore all of these when autocompleting
set wig=*.swp,*.bak,*.pyc,*.class,node_modules*,*.ipr,*.iws,built

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

" Ignore syntastic warnings
let g:syntastic_quiet_warnings=1

" Vim-script-runner
let g:script_runner_map = "<Leader>sx"
let g:script_runner_perl = "perl -Ilib -MData::Dumper"
let g:script_runner_javascript = "node"

"autocmd! BufWritePost,FileWritePost *.vm :silent !echo " " >> atlassian-universal-plugin-manager-plugin/src/main/java/com/atlassian/upm/PluginManagerServlet.java

" Highlight trailing whitespace in vim on non empty lines, but not while
" typing in insert mode!
highlight ExtraWhitespace ctermbg=red guibg=Brown
au ColorScheme * highlight ExtraWhitespace guibg=red
au BufEnter * match ExtraWhitespace /\S\zs\s\+$/
au InsertEnter * match ExtraWhitespace /\S\zs\s\+\%#\@<!$/
au InsertLeave * match ExtraWhiteSpace /\S\zs\s\+$/
 
" Jump to last known cursor position when opening file
autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \ exe "normal g'\"" |
    \ endif

" ------------------------------------------------------------------------------------------
" I no spell gud
" ------------------------------------------------------------------------------------------

ab funcion function
ab funicton function
ab funciton function
ab updateable updatable
ab Updateable Updatable
