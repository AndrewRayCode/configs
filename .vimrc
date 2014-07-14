" Plugins installed:
":read !ls ~/.vim/bundle
"Rename
"ZoomWin
"abolish
"ack.vim
"choosewin
"ctrlp.vim
"delvarworld-javascript
"django.vim
"dragvisuals
"easymotion
"extradite
"fugitive
"git-conflict-edit
"gundo
"indent-anything
"indexed-search
"match-tag
"matchit
"mru
"nerd-tree
"nerdcommenter
"powerline
"qargs
"rainbow-parentheses
"repeat
"surround
"syntastic
"tabular
"tagbar
"textobj-entire
"textobj-lastpat
"ultisnips
"unimpaired
"vim-expand-region
"vim-nerdtree-tabs
"vim-perl
"vim-project
"vim-script-runner
"vim-textobj-comment
"vim-textobj-function-javascript
"vim-textobj-function-perl
"vim-textobj-user
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
"lusty-juggler
"neocomplcache
"neosnippet
"ultisnips-snips
"snipmate-snippets

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
set cursorline

" Experimental and possibly terrible
highlight Cursor guibg=#FF92BB guifg=#fff
highlight iCursor guibg=red
set guicursor=n-c:ver30-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-iCursor/lCursor,r-cr:hor20-Cursor/lCursor,v-sm:block-Cursor

" Don't try to highlight lines longer than 800 characters.
set synmaxcol=800

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
" au VimEnter * RainbowParenthesesToggle
" au Syntax javascript RainbowParenthesesLoadRound
" au Syntax javascript RainbowParenthesesLoadSquare
" au Syntax javascript RainbowParenthesesLoadBraces

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

" Fix ctrl-p's mixed mode https://github.com/kien/ctrlp.vim/issues/556
"let g:ctrlp_extensions = ['mixed']
nnoremap <c-p> :CtrlPMixed<cr>

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

" Remove non visible buffers
" From http://stackoverflow.com/questions/1534835/how-do-i-close-all-buffers-that-arent-shown-in-a-window-in-vim
function! Wipeout()
    "From tabpagebuflist() help, get a list of all buffers in all tabs
    let tablist = []
    for i in range(tabpagenr('$'))
        call extend(tablist, tabpagebuflist(i + 1))
    endfor

    "Below originally inspired by Hara Krishna Dara and Keith Roberts
    "http://tech.groups.yahoo.com/group/vim/message/56425
    let nWipeouts = 0
    for i in range(1, bufnr('$'))
        if bufexists(i) && !getbufvar(i,"&mod") && index(tablist, i) == -1
        "bufno exists AND isn't modified AND isn't in the list of buffers open in windows and tabs
            silent exec 'bwipeout' i
            let nWipeouts = nWipeouts + 1
        endif
    endfor
    echomsg nWipeouts . ' buffer(s) wiped out'
endfunction

" Fix vim's default shitty { } motions
function! ParagraphMove(delta, visual, count)
    normal m'
    normal |
    if a:visual
        normal gv
    endif

    if a:count == 0
        let limit = 1
    else
        let limit = a:count
    endif

    let i = 0
    while i < limit
        if a:delta > 0
            " first whitespace-only line following a non-whitespace character
            let pos1 = search("\\S", "W")
            let pos2 = search("^\\s*$", "W")
            if pos1 == 0 || pos2 == 0
                let pos = search("\\%$", "W")
            endif
        elseif a:delta < 0
            " first whitespace-only line preceding a non-whitespace character
            let pos1 = search("\\S", "bW")
            let pos2 = search("^\\s*$", "bW")
            if pos1 == 0 || pos2 == 0
                let pos = search("\\%^", "bW")
            endif
        endif
        let i += 1
    endwhile
    normal |
endfunction

nnoremap <silent> } :<C-U>call ParagraphMove( 1, 0, v:count)<CR>
nnoremap <silent> { :<C-U>call ParagraphMove(-1, 0, v:count)<CR>

" Make all searches very magic
nnoremap / /\v

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
    let conflicted = split( filter, '\n')
    let massaged = []

    for conflict in conflicted
        let tmp = substitute(conflict, '\_s\+', '', 'g')
        if len( tmp ) > 0
            call add( massaged, tmp )
        endif
    endfor

    call ProcessConflictFiles( massaged )
endfunction

function! EditConflitedArgs()
    call ProcessConflictFiles( argv() )
endfunction

" Experimental function to load vim with all conflicted files
function! ProcessConflictFiles( conflictFiles )
    " These will be conflict files to edit
    let conflicts = []

    " Read git attributes file into a string
    let gitignore = readfile('.gitattributes')
    let ignored = []
    for ig in gitignore
        " Remove any extra things like -diff (this could be improved to
        " actually use some syntax to know which files ot ignore, like check
        " if [1] == 'diff' ?
        let spl = split( ig, ' ' )
        if len( spl ) > 0
            call add( ignored, spl[0] )
        endif
    endfor

    " Loop over each file in the arglist (passed in to vim from bash)
    for conflict in a:conflictFiles

        " If this file is not ignored in gitattributes (this could be improved)
        if index( ignored, conflict ) < 0

            " Grep each file for the starting error marker
            let cmd = system("grep -n '<<<<<<<' ".conflict)

            " Remove the first line (grep command) and split on linebreak
            let markers = split( cmd, '\n' )

            for marker in markers
                let spl = split( marker, ':' )

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

" }}}
" Highlight Word {{{
"
" This mini-plugin provides a few mappings for highlighting words temporarily.
"
" Sometimes you're looking at a hairy piece of code and would like a certain
" word or two to stand out temporarily.  You can search for it, but that only
" gives you one color of highlighting.  Now you can use <leader>N where N is
" a number from 1-6 to highlight the current word in a specific color.

function! HiInterestingWord(n) " {{{
    " Save our location.
    normal! mz

    " Yank the current word into the z register.
    normal! "zyiw

    " Calculate an arbitrary match ID.  Hopefully nothing else is using it.
    let mid = 86750 + a:n

    " Clear existing matches, but don't worry if they don't exist.
    silent! call matchdelete(mid)

    " Construct a literal pattern that has to match at boundaries.
    let pat = '\V\<' . escape(@z, '\') . '\>'

    " Actually match the words.
    call matchadd("InterestingWord" . a:n, pat, 1, mid)

    " Move back to our original location.
    normal! `z
endfunction " }}}

hi def InterestingWord1 guifg=#000000 ctermfg=16 guibg=#ffa724 ctermbg=214
hi def InterestingWord2 guifg=#000000 ctermfg=16 guibg=#aeee00 ctermbg=154
hi def InterestingWord3 guifg=#000000 ctermfg=16 guibg=#8cffba ctermbg=121
hi def InterestingWord4 guifg=#000000 ctermfg=16 guibg=#b88853 ctermbg=137
hi def InterestingWord5 guifg=#000000 ctermfg=16 guibg=#ff9eb8 ctermbg=211
hi def InterestingWord6 guifg=#000000 ctermfg=16 guibg=#ff2c4b ctermbg=195

" How do I turn this shit off??
nnoremap <silent> <leader>1 :call HiInterestingWord(1)<cr>
nnoremap <silent> <leader>2 :call HiInterestingWord(2)<cr>
nnoremap <silent> <leader>3 :call HiInterestingWord(3)<cr>
nnoremap <silent> <leader>4 :call HiInterestingWord(4)<cr>
nnoremap <silent> <leader>5 :call HiInterestingWord(5)<cr>
nnoremap <silent> <leader>6 :call HiInterestingWord(6)<cr>

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
nnoremap zg z=

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

" Ultisnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
" let g:UltiSnipsExpandTrigger="<c-b>"
let g:UltiSnipsJumpForwardTrigger='<c-b>'
let g:UltiSnipsJumpBackwardTrigger='<c-z>'

let g:UltiSnipsSnippetDirectories=[ 'UltiSnips', 'delvarworld-snippets' ]

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

function! g:UltiSnips_Complete()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            return "\<C-n>"
        else
            call UltiSnips#JumpForwards()
            if g:ulti_jump_forwards_res == 0
               return "\<TAB>"
            endif
        endif
    endif
    return ""
endfunction

au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsListSnippets="<c-e>"
" this mapping Enter key to <C-y> to chose the current highlight item and
" close the selection list, same as other IDEs.  CONFLICT with some plugins
" like tpope/Endwise
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Ack
nnoremap <Leader>aw "zyiw:exe "Ack! ".@z.""<CR>
nnoremap <Leader>aW "zyiW:exe "Ack! ".@z.""<CR>

nnoremap <Leader>rp :call rainbow_parentheses#Toggle()<cr>

" Source vim when this file is updated
nnoremap <Leader>sv :source $MYVIMRC<cr>
nnoremap <silent> <Leader>so :source %<cr>
nnoremap <Leader>v :tabe $MYVIMRC<cr>
nnoremap <Leader>ss :tabe ~/.vim/delvarworld-snippets/javascript/javascript.snippets<cr>
nnoremap <Leader>hs :tabe /etc/hosts<cr>
nnoremap <Leader>js :tabe ~/.jsl<cr>

" Copy current buffer path relative to root of VIM session to system clipboard
nnoremap <Leader>yp :let @*=expand("%")<cr>:echo "Copied file path to clipboard"<cr>
" Copy current filename to system clipboard
nnoremap <Leader>yf :let @*=expand("%:t")<cr>:echo "Copied file name to clipboard"<cr>
" Copy current buffer path without filename to system clipboard
nnoremap <Leader>yd :let @*=expand("%:h")<cr>:echo "Copied file directory to clipboard"<cr>

" select last yanked / pasted text
nnoremap <Leader>ht `[v`]

" select last paste in visual mode
nnoremap <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'

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
noremap <Leader>sw :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

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
nmap <space> <Plug>(choosewin)
let g:choosewin_overlay_clear_multibyte = 1
nmap <S-Space> <C-w>W

" Delete current buffer
nmap <Leader>db :bdelete<CR>

" :W is now :w (http://stackoverflow.com/questions/3878692/aliasing-a-command-in-vim)
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))

function! FormatPerlObj()
    silent! exec '%s/\v\S+\s*\=\>\s*[^,]*,/\0\r'
    silent! exec '%s/\v\S+\s*\=\>\s*\{/\0\r'
    silent! exec '%s/\v[^{]\zs\},/\r\0'
    normal vie=
    exec 'set ft=perl'
endfunction

function! FormatJson()
    silent! exec '%s/\v\S+\s*:\s*[^,]*,/\0\r'
    silent! exec '%s/\v\S+\s*:\s*\{/\0\r'
    silent! exec '%s/\v[^{]\zs\},/\r\0'
    normal vie=
    exec 'set ft=javascript'
endfunction

function! FormatVarList()
    silent! exec '%s/\v\S+\s*\=\>\s*[^,]*,/\0\r'
    silent! exec '%s/\v\S+\s*\=\>\s*\{/\0\r'
    silent! exec '%s/\v[^{]\zs\},/\r\0'
    normal vie=
    exec 'set ft=perl'
endfunction

" ------------------------------------------------------------------------------------------
" VIM setup
" ------------------------------------------------------------------------------------------

" Make all line substituions /g
set gdefault

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
set shiftround

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
let g:syntastic_perl_lib_path = [ './locallib/lib/perl5' ]

" Vim-script-unner
let g:script_runner_perl = "perl -Ilib -MData::Dumper -Mv5.10"
let g:script_runner_javascript = "node"

" Backspace: Act like normal backspace and go into insert mode
nnoremap <bs> i<bs>

nnoremap z= z=1<cr><cr>

" Vimshell plugin settings
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_prompt =  '$ '


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
Project  '~/crowdtilt/crowdtilt-public-site',   'public-site'
Project  '~/crowdtilt/crowdtilt-internal-api',  'internal-api'
Project  '~/big-bubble' , 'bubble'
Project  '~/parser',  'parser'
Project  '~/blag',  'blag'
Project  '~/bellesey-blog',  'bellesey'
" default starting path (the home directory)
call project#rc()

vmap  <expr>  <LEFT>   DVB_Drag('left')
vmap  <expr>  <RIGHT>  DVB_Drag('right')
vmap  <expr>  <DOWN>   DVB_Drag('down')
vmap  <expr>  <UP>     DVB_Drag('up')
vmap  <expr>  D        DVB_Duplicate()

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

" Resize splits when the window is resized
au VimResized * :wincmd =

" In commit edit turn on spell check, make diff bigger, and switch to other
" window in insertmode
au BufNewFile,BufRead COMMIT_EDITMSG setlocal spell | DiffGitCached | resize +20 | call feedkeys("\<C-w>p")

" Make ⌘-v repeatable. Does not work
inoremenu Edit.Paste <esc>:set paste<cr>a<C-r>*<esc>:set nopaste<cr>a

" More commands in q: q/ etc
set history=200

" ----------------------------------------------------------------------
" ----------------------------------------------------------------------
" ----------------------------------------------------------------------
" ----------------------------------------------------------------------

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
 
function! s:DimInactiveWindows()
  for i in range(1, tabpagewinnr(tabpagenr(), '$'))
    let l:range = "80"
    if i != winnr()
      if &wrap
        " HACK: when wrapping lines is enabled, we use the maximum number
        " of columns getting highlighted. This might get calculated by
        " looking for the longest visible line and using a multiple of
        " winwidth().
        let l:width=256 " max
      else
        let l:width=winwidth(i)
      endif
      let l:range = join(range(1, l:width), ',')
    endif
    call setwinvar(i, '&colorcolumn', l:range)
  endfor
endfunction
augroup DimInactiveWindows
  au!
  au WinEnter * call s:DimInactiveWindows()
augroup END

" ------------------------------------------------------------------------------------------
" I no spell gud
" ------------------------------------------------------------------------------------------

ab bototm bottom
ab funcion function
ab funicton function
ab funciton function
ab fucntion function
ab dupate update
ab upate update
ab udpate update
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
ab positon position
ab animaiton animation

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
" regex_aa:
"       Select around attribute a="stuff"
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
\   'regex_aa': {
\     'select': 'aa',
\     '*pattern*': '\v(\w|-)+\=".{-}"'
\   },
\ })
