" Plugins installed:
":read !ls ~/.vim/bundle
"Rename
"ZoomWin
"abolish
"ack.vim
"bufexplorer
"delvarworld-javascript
"django.vim
"easymotion
"extradite
"fugitive
"gundo
"indent-anything
"indexed-search
"lusty-explorer
"match-tag
"matchit
"mru
"neocomplcache.vim
"neosnippet.vim
"nerd-tree
"nerdcommenter
"powerline
"qargs
"rainbow-parentheses
"repeat
"snipmate-snippets
"surround
"syntastic
"tabular
"tagbar
"textobj-entire
"textobj-lastpat
"ultisnips-snips
"unimpaired
"unite.vim
"vim-expand-region
"vim-nerdtree-tabs
"vim-perl
"vim-script-runner
"vim-textobj-comment
"vim-textobj-function-javascript
"vim-textobj-function-perl
"vim-textobj-user
"vim-unite-history
"vimproc.vim
"vimshell.vim

" Dead plugins I have removed:
"vim-session
"scala
"vim-clojure
"coffee-script
"jira-completer
"pattern-complete " offers completions for last search pattern
"complete-helper

" ---------------------------------------------------------------
" Custom setup
" ---------------------------------------------------------------

colorscheme vividchalk
set nocompatible

" Pathogen loading
filetype off
call pathogen#infect()
filetype plugin indent on

syntax on

" Highlight column 80 and don't make it bright red like an idiot would (needs
" to be done after syntax set)
highlight ColorColumn guibg=#220000
set colorcolumn=80

" Experimental and possibly terrible
highlight Cursor guibg=#FF92BB guifg=#fff
highlight iCursor guibg=red
set guicursor=n-c:ver30-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-iCursor/lCursor,r-cr:hor20-Cursor/lCursor,v-sm:block-Cursor

" Custom file type syntax highlighting
au BufRead,BufNewFile *.djhtml set filetype=html
au BufRead,BufNewFile *.soy set filetype=clojure
au BufRead,BufNewFile .bash_config set ft=sh syntax=sh
au BufRead,BufNewFile .jshintrc set ft=javascript
au BufRead,BufNewFile *.tt2 setf html
au BufRead,BufNewFile *.tt setf html
au BufRead,BufNewFile *.js.tt set filetype=javascript
au BufRead,BufNewFile Rexfile set filetype=perl

" Fuck everything about rainbow parentheses
au VimEnter * RainbowParenthesesToggle
au Syntax javascript RainbowParenthesesLoadRound
au Syntax javascript RainbowParenthesesLoadSquare
au Syntax javascript RainbowParenthesesLoadBraces

" JSLint options for custom procesing file
let jslint_command_options = '-nofilelisting -nocontext -nosummary -nologo -conf ~/.jsl -process'
let jslint_highlight_color = 'Red'

" Set Ctrl-P to show match at top of list instead of at bottom, which is so
" stupid that it's not default
let g:ctrlp_match_window_reversed = 0

" Tell Ctrl-P to keep the current VIM working directory when starting a
" search, another really stupid non default
let g:ctrlp_working_path_mode = 0

" Ctrl-P ignore target dirs so VIM doesn't have to! Yay!
let g:ctrlp_custom_ignore = {
    \ 'dir': '\.git$\|\.hg$\|\.svn$\|target$\|built$\|.build$\|node_modules\|\.sass-cache\|locallib$',
    \ 'file': '\.ttc$',
    \ }

" Set up some custom ignores
"call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep',
      "\ 'ignore_pattern', join([
      "\ '\.git\|\.hg\|\.svn\|target\|built\|.build\|node_modules\|\.sass-cache',
      "\ '\.ttc$',
      "\ ], '\|'))

" Open multiplely selected files in a tab by default
let g:ctrlp_open_multi = '10t'

" Powerline custom font
if has('gui_running')
    "set guifont=Menlo\ for\ Powerline
endif

" ---------------------------------------------------------------
" Functions
" ---------------------------------------------------------------

" When switching tabs, attempt to move cursor to a file and out of nerdtree,
" quickfix and help windows
function! FuckAllOfVim()

    for i in [1, 2, 3]
        let s:_ft = &filetype
        if s:_ft == "nerdtree" || s:_ft == "help" || s:_ft == "qf"
            execute "wincmd w"
        else
            break
        endif
    endfor

endfunction

autocmd FileType nerdtree cnoreabbrev <buffer> bd :echo "No you don't"<cr>
" If typing bd in quickfix, close it then close the main tab
autocmd FileType qf cnoreabbrev <buffer> bd :echo "No you don't"<cr>

function! EditConflictFiles()
    let filter = system('git diff --name-only --diff-filter=U')
    let conflicted = split( filter, '\r')
    let massaged = []

    for conflict in conflicted
        let tmp = substitute(conflict, '\_s\+', '', 'g')
        if len( tmp ) > 0
            call add( massaged, tmp )
        endif
    endfor

    call ProcessConflictFiles( massaged )
endfunction

" Experimental function to load vim with all conflicted files
function! ProcessConflictFiles( files )
    " These will be conflict files to edit
    let conflicts = []

    " Read git attributes file into a string
    let gitignore = join(readfile('.gitattributes'), '')

    let conflictFiles = len( a:files ) ? a:files : argv()

    " Loop over each file in the arglist (passed in to vim from bash)
    for conflict in conflictFiles

        " If this file is not ignored in gitattributes (this could be improved)
        if gitignore !~ conflict

            " Grep each file for the starting error marker
            let cmd = system("grep -n '<<<<<<<' ".conflict)

            " Remove the first line (grep command) and split on linebreak
            let markers = split( cmd, '\r' )

            for marker in markers
                let spl = split( marker, ':' )
                echo spl

                " If this line had a colon in it (otherwise it's an empty line
                " from command output)
                if len( spl ) == 2

                    " Get the line number by removing the white space around it,
                    " because vim is a piece of shit
                    let line = substitute(spl[0], '\_s\+', '', 'g')
                    
                    " Add this file to the list with the data format for the quickfix
                    " window
                    call add( conflicts, {'filename': conflict, 'lnum': line, 'text': spl[1]} )
                endif
            endfor
        endif
        
    endfor

    " Set the quickfix files and open the list
    call setqflist( conflicts )
    execute 'copen'
    execute 'cfirst'

    " Highlight diff markers and then party until you shit
    highlight Conflict guifg=white guibg=red
    match Conflict /^=\{7}.*\|^>\{7}.*\|^<\{7}.*/
    let @/ = '>>>>>>>\|=======\|<<<<<<<'
endfunction

"" Move current tab into the specified direction.
" @param direction -1 for left, 1 for right.
function! TabMove(direction)
    " get number of tab pages.
    let ntp=tabpagenr("$")
    " move tab, if necessary.
    if ntp > 1
        " get number of current tab page.
        let ctpn=tabpagenr()
        " move left.
        if a:direction < 0
            let index=((ctpn-1+ntp-1)%ntp)
        else
            let index=(ctpn%ntp)
        endif

        " move tab page.
        execute "tabmove ".index
    endif
endfunction

" Move tab left or right
map <D-H> :call TabMove(-1)<CR>
map <D-L> :call TabMove(1)<CR>

" Count number of splits in current buffer, ignoring nerd tree
function! GuiTabLabel()
    let label = ''
    let bufnrlist = tabpagebuflist(v:lnum)

    " Add '+' if one of the buffers in the tab page is modified
    for bufnr in bufnrlist
    if getbufvar(bufnr, "&modified")
        let label = '+'
        break
    endif
    endfor

    let panes = map(range(1, tabpagenr('$')), '[v:val, bufname(winbufnr(v:val))]')
    let wincount = tabpagewinnr(v:lnum, '$')
    echo join(panes, ':')

    for pane in panes
        if !empty(matchstr(pane[1], 'NERD\|/runtime/doc/')) || empty(pane[1])
            let wincount -= 1
        endif
    endfor

    " Append the number of windows in the tab page if more than one
    if wincount > 1
        let label .= '('.wincount.') '
    endif

    " Append the buffer name
    return label . fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum) - 1]), ':t')
endfunction

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

" Visual ack, used to ack for highlighted text
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
" Replace leader. This doesn't work, needs investigating
noremap \ ,

" Title case a line or selection (better)
vnoremap <Leader>ti :s/\%V\<\(\w\)\(\w*\)\>/\u\1\L\2/ge<cr>
nnoremap <Leader>ti :s/.*/\L&/<bar>:s/\<./\u&/g<cr>

" lets you do w!! to sudo write the file
nnoremap <Leader>ww :w !sudo tee % >/dev/null<cr>

" delete a line, but only copy a whitespace-trimmed version to " register
nnoremap <Leader>dd _yg_"_dd
nnoremap <Leader>yy _yg_

" Ray-Frame testing thingy
" nnoremap <Leader>x:tabe a.js<cr>GVggx"*p<cr>:%s/;/;\r/g<cr>:w<cr>

nnoremap <Leader>x :tabcl<cr>

" zg is the stupidest fucking shortcut and I hit it all the time
nmap zg z=

" underline a line with dashes or equals
nnoremap <Leader>r- :t.<cr>:norm 0vg_r-<cr>
nnoremap <Leader>r= :t.<cr>:norm 0vg_r=<cr>

" New tab
nnoremap <Leader>te :tabe 

" Gundo tree viewer
nnoremap <Leader>u :GundoToggle<CR>

nnoremap <Leader>op :call HandleURI()<CR>

" Clear search highlighting so you don't have to search for /asdfasdf
nnoremap <silent> <Leader>/ :nohlsearch<CR>

" Jump backwards to previous function, assumes code is indented (useful when inside function)
" Jump to top level function
" nnoremap <Leader>f ?^func\\|^[a-zA-Z].*func<CR>,/

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

" Source vim when this file is updated
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

" K is one of the dumber things in vim
map K k

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

" Delete current buffer
nmap <Leader>db :bdelete<CR>

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
set wig=*.swp,*.bak,*.pyc,*.class,node_modules*,*.ipr,*.iws,built,locallib

" shiftround, always snap to multiples of shiftwidth when using > and <
set sr

" Testing out relative line number
setglobal relativenumber

" from http://jeffkreeftmeijer.com/2012/relative-line-numbers-in-vim-for-super-fast-movement/
au FocusLost * :set number
au FocusGained * :set relativenumber

set ff=unix
set ic
set smartcase
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

" Give one virtual space at end of line
set virtualedit=onemore

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
" let g:syntastic_quiet_warnings=1
" Place error visual marker in gutter
let g:syntastic_enable_signs=1

" Vim-script-unner
let g:script_runner_perl = "perl -Ilib -MData::Dumper -Mv5.10 -MClass::Autouse=:superloader"
let g:script_runner_javascript = "node"

" +/-: Increment number
nnoremap + <c-a>
nnoremap - <c-x>

" Backspace: Act like normal backspace
nnoremap <bs> X

" Vimshell plugin settings
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_prompt =  '$ '

"===============================================================================
" Neosnippet :(
"===============================================================================

" Plugin key-mappings.
"imap <C-k> <Plug>(neosnippet_expand_or_jump)
"smap <C-k> <Plug>(neosnippet_expand_or_jump)
"xmap <C-k> <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
"imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"\ "\<Plug>(neosnippet_expand_or_jump)"
"\: pumvisible() ? "\<C-n>" : "\<TAB>"
"smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"\ "\<Plug>(neosnippet_expand_or_jump)"
"\: "\<TAB>"

" For snippet_complete marker.
"if has('conceal')
  "set conceallevel=2 concealcursor=i
"endif

" YouCompleteMe?
let g:used_javascript_libs = 'underscore,backbone,jquery'

" Tern?
let g:tern_map_keys = 1
let g:tern_show_argument_hints='on_hold'
let g:tern#command = ['node', '/Users/DelvarWorld/configs/.vim/bundle/tern_for_vim/autoload/../node_modules/tern/bin/tern', '--verbose']

" Project?
set rtp+=~/.vim/bundle/vim-project/
let g:project_disable_tab_title = 1
"let g:project_enable_welcome = 0
let g:project_use_nerdtree = 1
" custom starting path
call project#rc("~/")
Project  '~/big-bubble' , 'bubble'
Project  '~/crowdtilt/crowdtilt-public-site',   'public-site'
Project  '~/crowdtilt/crowdtilt-internal-api',  'internal-api'
Project  '~/dickbot',  'dickbot'
Project  '~/blag',  'blag'
" default starting path (the home directory)
call project#rc()

"===============================================================================
" Unite
"===============================================================================

" Use the fuzzy matcher for everything
"call unite#filters#matcher_default#use(['matcher_fuzzy'])

" Use the rank sorter for everything
"call unite#filters#sorter_default#use(['sorter_rank'])

"nnoremap    [unite]   <Nop>

" Quickly switch lcd
"nnoremap <c-f><c-d> :Unite -buffer-name=change-cwd -default-action=lcd directory_mru<CR>

" General fuzzy search
"nnoremap <silent> [unite]<space> :<C-u>Unite
      "\ -buffer-name=files buffer file_mru bookmark file_rec/async<CR>

"nnoremap <C-p> :Unite file_rec/async<cr>

" Quick yank history
"nmap <c-y> [unite]y
"nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<CR>

" Quick snippet
"nnoremap <silent> [unite]s :<C-u>Unite -buffer-name=snippets snippet<CR>

" Quick file search
"nmap <c-f><c-a> [unite]f
"nnoremap <silent> [unite]f :<C-u>Unite -buffer-name=files file_rec/async file/new<CR>

" Quick MRU search
"nmap <c-m> [unite]m
"nnoremap <silent> [unite]m :<C-u>Unite -buffer-name=mru file_mru<CR>

" Quick commands
"nnoremap <silent> [unite]c :<C-u>Unite -buffer-name=commands command<CR>

" Quick bookmarks
"nnoremap <silent> [unite]b :<C-u>Unite -buffer-name=bookmarks bookmark<CR>

let g:unite_source_history_yank_enable = 1
let g:unite_split_rule = "botright"
let g:unite_update_time = 200
let g:unite_enable_start_insert = 1

autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
    " Overwrite settings.
    nmap <buffer> <ESC>      <Plug>(unite_exit)
endfunction

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
nnoremenu Edit.Paste :set paste<cr>i<C-r>*<esc>:set nopaste<cr>
inoremenu Edit.Paste <esc>:set paste<cr>a<C-r>*<esc>:set nopaste<cr>a

" More commands in q: q/ etc
set history=200

" ----------------------------------------------------------------------
" ----------------------------------------------------------------------
" ----------------------------------------------------------------------
" ----------------------------------------------------------------------

" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
"" Use smartcase.
"let g:neocomplcache_enable_smart_case = 1
"" Use camel case completion.
"let g:neocomplcache_enable_camel_case_completion = 1
"" Use underbar completion.
"let g:neocomplcache_enable_underbar_completion = 1
"" Set minimum syntax keyword length.
"let g:neocomplcache_min_syntax_length = 2
"let g:neocomplcache_max_list = 5
"let g:neocomplcache_enable_fuzzy_completion = 1
"let g:neocomplcache_fuzzy_completion_start_length = 3

" Plugin key-mappings.
"imap <C-k>     <Plug>(neocomplcache_snippets_expand)
"smap <C-k>     <Plug>(neocomplcache_snippets_expand)
"inoremap <expr><C-g>     neocomplcache#undo_completion()
"inoremap <expr><C-l>     neocomplcache#complete_common_string()
"
autocmd TabLeave * call FuckAllOfVim()

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" If typing bd in nerdtree, switch to main file and close that instead
autocmd FileType nerdtree cnoreabbrev <buffer> bd :echo "No you don't"<cr>
" If typing bd in quickfix, close it then close the main tab
autocmd FileType qf cnoreabbrev <buffer> bd :echo "No you don't"<cr>

"set guitablabel=%{GuiTabLabel()}

" ------------------------------------------------------------------------------------------
" I no spell gud
" ------------------------------------------------------------------------------------------

ab bototm bottom
ab funcion function
ab funicton function
ab funciton function
ab fucntion function
ab updateable updatable
ab Updateable Updatable
ab conosle console
ab campaing campaign
ab camapign campaign
ab campigan campaign
ab campagn campaign
ab campiagn campaign
ab closeset closest
ab camapaign campaign
ab contribuiton contribution
ab contribuiton contribution
ab contribuiotn contribution

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
"

call textobj#user#plugin('horesshit', {
\   'regex_j': {
\     'select': 'aj',
\     '*pattern*': '^\s*"\?\w\+"\?\s*:\s*{\_[^}]*}.*\n\?',
\   },
\   'regex_a': {
\     'select': 'ax',
\     '*pattern*': '\/.*\/[gicm]\{0,}',
\   },
\   'regex_i': {
\     'select': 'ix',
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
