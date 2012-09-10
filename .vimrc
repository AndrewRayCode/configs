" Plugins installed:
":read !ls ~/.vim/bundle
"NrrwRgn
"Rename
"ZoomWin
"ack.vim
"autocomplpop
"bufexplorer
"coffee-script
"ctrlp.vim
"delvarworld-javascript
"django.vim
"easymotion
"extradite
"fugitive
"gundo
"indent-anything
"indexed-search
"jira-completer
"lusty-explorer
"lusty-juggler
"matchit
"mru
"neocomplete
"nerd-tree
"nerdcommenter
"powerline
"rainbow-parentheses
"repeat
"scala
"search-replace-highlight
"supertab
"surround
"syntastic
"tabular
"tagbar
"ultisnips
"vim-clojure
"vim-l9
"vim-nerdtree-tabs
"vim-perl
"vim-script-runner
"vim-session
"vim-textobj-comment
"vim-textobj-function-javascript
"vim-textobj-function-perl
"vim-textobj-user
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

" Highlight column 80 and don't make it bright red like an idiot would (needs
" to be done after syntax set)
highlight ColorColumn guibg=#220000
set colorcolumn=80

" Custom file type syntax highlighting
au BufRead,BufNewFile *.djhtml set filetype=html
au BufRead,BufNewFile *.soy set filetype=clojure
au BufRead,BufNewFile .bash_config set ft=sh syntax=sh
au BufRead,BufNewFile .jshintrc set ft=javascript
au BufRead,BufNewFile *.tt2 setf html
au BufRead,BufNewFile *.tt setf html
au BufRead,BufNewFile *.js.tt set filetype=javascript

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
let g:ctrlp_custom_ignore = {'dir': '\.git$\|\.hg$\|\.svn$\|target$|built$|.build$|node_modules'}

" Open multiplely selected files in a tab by default
let g:ctrlp_open_multi = '10t'

" Powerline custom font
if has('gui_running')
  set guifont=Menlo\ for\ Powerline
endif

" ---------------------------------------------------------------
" Functions
" ---------------------------------------------------------------

function! HandleURI()
  let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:]*')
  echo s:uri
  if s:uri != ""
	  exec "!open \"" . s:uri . "\""
  else
	  echo "No URI found in line."
  endif
endfunction

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

nnoremap <Leader>op :call HandleURI()<CR>

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
nnoremap <Leader>gb :Gblame<CR>

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
nnoremap <Leader>sw :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

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

" tabularize around : or =
vnoremap <silent> <Leader>tt :Tabularize /:\zs<CR>
vnoremap <silent> <Leader>t= :Tabularize /=<cr>
vnoremap <silent> <Leader>t. :Tabularize /=><cr>
nnoremap <silent> <Leader>tt :Tabularize<CR>

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

" Delete unnamed buffers
nmap <Leader>da :bufdo if expand("%") == "" \| bd! \| endif<cr>

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

" Vim-script-unner
let g:script_runner_perl = "perl -Ilib -MData::Dumper -Mv5.10 -MClass::Autouse=:superloader"
let g:script_runner_javascript = "node"

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

" In commit edit turn on spell check, make diff bigger, and switch to other
" window in insertmode
au BufNewFile,BufRead COMMIT_EDITMSG setlocal spell | DiffGitCached | resize +20 | call feedkeys("\<C-w>p")

" Make ⌘-v repeatable
inoremenu Edit.Paste <C-r>*

" ----------------------------------------------------------------------
" ----------------------------------------------------------------------
" ----------------------------------------------------------------------
" ----------------------------------------------------------------------

" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 2
let g:neocomplcache_max_list = 5
let g:neocomplcache_enable_fuzzy_completion = 1
let g:neocomplcache_fuzzy_completion_start_length = 3

" Plugin key-mappings.
imap <C-k>     <Plug>(neocomplcache_snippets_expand)
smap <C-k>     <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()

" AutoComplPop like behavior.
let g:neocomplcache_enable_auto_select = 1

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" ------------------------------------------------------------------------------------------
" I no spell gud
" ------------------------------------------------------------------------------------------

ab funcion function
ab funicton function
ab funciton function
ab updateable updatable
ab Updateable Updatable

" ------------------------------------------------------------------------------------------
" Text objects?
" ------------------------------------------------------------------------------------------
" Fuck you uncommentable text objects
" regex_a:
"      Select around a regex `/bob/gi` with a/
" regex_i:
"      Select inside a regex /`bob`/gi with i/
" regex_r:
"       Select a css rule margin:`0 10px`; with ir
" regex_h:
"       I have no idea what this one was for
" regex_v:
"       Select a value?
" regex_in:
"       Select inside a number `-0.1`em with in
" regex_an:
"       Select around a number `-0.1em` with an


call textobj#user#plugin('horesshit', {
\   'regex_a': {
\     'select': 'a/',
\     '*pattern*': '\/.*\/[gicm]\{0,}',
\   },
\   'regex_i': {
\     'select': 'i/',
\     '*pattern*': '\/\zs.\+\ze\/'
\   },
\   'regex_r': {
\     'select': 'ir',
\     '*pattern*': ':\zs.\+\ze;'
\   },
\   'regex_h': {
\     'select': 'ih',
\     '*pattern*': '[a-zA-Z-\/]\+'
\   },
\   'regex_v': {
\     'select': 'iv',
\     '*pattern*': '[0-9a-zA-Z-\/-]\+'
\   },
\   'regex_in': {
\     'select': 'in',
\     '*pattern*': '\-\?[0-9\.]\+'
\   },
\   'regex_an': {
\     'select': 'an',
\     '*pattern*': '\-\?[\#0-9.a-z%]\+'
\   },
\ })
