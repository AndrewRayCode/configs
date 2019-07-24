" Search this file for "important" for the most important lines

" =============================================================================
" ====
" =====
" ======
" Setup And Styles And Colors:
" ======
" =====
" ====
" ===
" =============================================================================

colorscheme vividchalk
set nocompatible

" Pathogen loading
filetype off
call pathogen#infect()
Helptags " Added to avoid having to manually install docs for plugins
filetype plugin indent on

" The "right" way to set color. Use `enable` because `on` will overwrite all
" other colors. Guard because no reason to call it more than once
if !exists("g:syntax_on")
    syntax enable
endif

" Highlight column 80 and don't make it default bright red (needs to be done
" after syntax set)
highlight ColorColumn guibg=#331111
set colorcolumn=80
set cursorline

set novisualbell

" Make the cursor a thin line (not a block) and color it differently in insert
" and normal mode. Makes it WAY easier to see where the cursor is. This is the
" most important thing in this file
highlight Cursor guibg=#FF92BB guifg=#ffffff
highlight iCursor guibg=red
set guicursor=n-c:ver30-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-iCursor/lCursor,r-cr:hor20-Cursor/lCursor,v-sm:block-Cursor

" Highlight trailing whitespace in vim on non empty lines, but not while
" typing in insert mode. Super useful!
highlight ExtraWhitespace ctermbg=red guibg=Brown
au ColorScheme * highlight ExtraWhitespace guibg=red
au BufEnter * match ExtraWhitespace /\S\zs\s\+$/
au InsertEnter * match ExtraWhitespace /\S\zs\s\+\%#\@<!$/
au InsertLeave * match ExtraWhiteSpace /\S\zs\s\+$/

" Always show vim's tab bar
set showtabline=2

" =============================================================================
" ====
" =====
" ======
" Vanilla Vim Settings:
" ======
" =====
" ====
" ===
" =============================================================================

" Make all searches very magic. This is the most important thing in this file.
" Also mark the position before you start searching to copy text back to
nnoremap / ms/\v
nnoremap ? ms?\v

" Don't put two spaces after a period when joining lines with gq or J or
" whatever
set nojoinspaces

" Don't try to highlight lines longer than 800 characters.
set synmaxcol=800

" Always splits to the right and below, since Bram doesn't read left to right
set splitright
" This makes :help open at the bottom, which I don't like, so removing for now
"set splitbelow

" Custom file type syntax highlighting
au BufRead,BufNewFile .aprc set ft=ruby syntax=ruby
au BufRead,BufNewFile .pryrc set ft=ruby syntax=ruby
au BufRead,BufNewFile onboarding-tech-notes set ft=markdown syntax=markdown
au BufRead,BufNewFile .bash_config set ft=sh syntax=sh
au BufRead,BufNewFile .jshintrc set ft=javascript
au BufRead,BufNewFile .eslintrc set ft=javascript
au BufRead,BufNewFile *.json set ft=javascript
au BufRead,BufNewFile *.pryrc set ft=ruby

" Make all line substituions global (same as pattern/g) by default
set gdefault

" Store the GUI window position when making a vim session. I totally forgot
" Vim has a concept of "sessions" beacuse it's poorly designed and
" inconvenient to work with, so I never use this.
set sessionoptions+=winpos

" Don't want no lousy .swp files in my directoriez
set backupdir=/tmp
set directory=/tmp

" Hide buffers instead of closing, can do :e on an unsaved buffer
set hidden

" Add the "A" flag to shortmess, which means that when given an existing swap
" buffer warning, it won't demand that you press enter when the message is
" more than one line long.
set shortmess=filnxtToOA

" Wildignore all of these when autocompleting
set wig=*.swp,*.bak,*.pyc,*.class,node_modules*,*.ipr,*.iws,built,locallib

" Always snap to multiples of shiftwidth when using > and <
set shiftround

" You always, always want relativenumber on. This is most important thing in
" this file
setglobal relativenumber

" Use non-windows linebreaks. This command errors in modifiable off files, so
" suppress errors with silent :(
silent! set ff=unix

" Ignore caase in search, unless you type any capital letters, then it
" automatically switches to case sensitive search
set ignorecase
set smartcase

" Highlight search results
set hlsearch

" Live search while typing, shows matches before hitting enter
set incsearch

" GUI Vim (MacVim) configuraiton
" m = Always show menu bar(?)
" e = Always show nice GUI looking tabs, don't attempt to badly draw with
" vim's default tab setting
" r = Always show scrollbar
set guioptions=mer

" Use spaces always
set expandtab

" Copy indent from current line when starting a new line
set autoindent

" Break at specific characters when wrapping long lines (:set breakat?)
set lbr

" Give one virtual space at end of line so the cursor can go to the end of the
" line (useful)
set virtualedit=onemore

" Always have statusline so powerline shows up on non-split windows
set laststatus=2

" Include $ in varibale names, so viw works with jQuery variables
set iskeyword=@,48-57,_,192-255,#,$

" Backspace in normal mode: Act like normal backspace and go into insert mode
nnoremap <bs> i<bs>

" More commands in q: q/ etc (default is 50)
set history=200

" VIM LITERALLY CAN'T INDENT HTML AND THERE'S NO HELP FOR THIS VARIABLE NAME
" BUT LOOK AT :h html-indent **OBVIOUSLY**
let g:html_indent_inctags = "body,head,tbody,p"
" This does not work, obviously, it should make anything inside html tags not
" indented. myabe a plugin conflict?
let g:html_indent_autotags = "html"

" If you set the above variables, you have to call the below function IN THE
" HTML BUFFER after setting the global variables to get proper HTML
" indenting... come on Vim
" call HtmlIndent_CheckUserSettings()

" Jump to last known cursor position when opening file
" warning: This appears to break jump-to-line when opening a file with CtrlP
autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \ exe "normal g'\"" |
    \ endif

" In commit edit turn on spell check, make diff bigger, and switch to other
" window in insertmode
au BufNewFile,BufRead COMMIT_EDITMSG setlocal spell | DiffGitCached

" Equalize splits when the window is resized. I don't think I actually want
" this becasue it can mess up terminal vim when resizing the terminal when
" editing a git commit message, which has split of msg/code change
"au VimResized * :wincmd =

" Some experimental stuff

" Experimental to make command line completion easier?
set wildmenu

" Experimental make lines that wrap have same indenting as their parent
set breakindent

" Maybe I should remove these? Annoying when I'm in a 2 space project and have
" to manually set
set tabstop=4
set shiftwidth=4
set smarttab

" Disable C-style indenting. Experimental
set nocindent

" Set bottom indicator. Probably does nothing with vim-powerline
set ruler
set showcmd

" Why do I have this?
set path=.,/usr/include,$PWD


" =============================================================================
" ====
" =====
" ======
" Non Plugin Custom Key Mappings And Setup:
" ======
" =====
" ====
" ===
" =============================================================================

" Let mapleader be space. This is the most important line in this file
let mapleader = "\<Space>"

" In search mode, remove \v (very magic) with ctrl-v
cnoremap <C-v> <C-f>02l"zyg_:q<cr>/<c-r>za

" Title case a line or selection (doesn't work at all)
vnoremap <Leader>ti :s/\%V\<\(\w\)\(\w*\)\>/\u\1\L\2/ge<cr>
nnoremap <Leader>ti :s/.*/\L&/<bar>:s/\<./\u&/g<cr>

" Lets you do w!! to sudo write the file. I'd eventually like to fix this to
" not warn on file save that the file changed
nnoremap <Leader>ww :w !sudo tee % >/dev/null<cr>

" delete a line, but only copy a whitespace-trimmed version to " register
nnoremap <Leader>dd _yg_"_dd
nnoremap <Leader>yy _yg_

" underline a line with dashes or equals
nnoremap <Leader>r- :t.<cr>:norm 0vg_r-<cr>
nnoremap <Leader>r= :t.<cr>:norm 0vg_r=<cr>

" Clear search highlighting
nnoremap <silent> <Leader>/ :nohlsearch<CR>

" Source vim when this file is updated
nnoremap <Leader>sv :source $MYVIMRC<cr>
nnoremap <silent> <Leader>so :source %<cr>:echo "Sourced this file!"<cr>

" Quick file open shortcuts
nnoremap <Leader>b :tabe ~/.bashrc<cr>
nnoremap <Leader>v :tabe $MYVIMRC<cr>
nnoremap <Leader>ss :tabe ~/.vim/delvarworld-snippets/javascript/javascript.snippets<cr>
nnoremap <Leader>hs :tabe /etc/hosts<cr>:setlocal noreadonly<cr>:setlocal autoread<cr>
nnoremap <Leader>js :tabe ~/.jsl<cr>

" Copy current filename to system clipboard
nnoremap <Leader>yf :let @*=expand("%:t")<cr>:echo "Copied file name to clipboard"<cr>
" Copy current buffer path without filename to system clipboard
nnoremap <Leader>yd :let @*=expand("%:h")<cr>:echo "Copied file directory to clipboard"<cr>

" select last yanked / pasted text, using the [ marks (:h `[)
nnoremap <Leader>ht `[v`]

" select last paste in visual mode
nnoremap <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'

" Change to working directory of current file and echo new location
nnoremap cd :cd %:h<cr>:pwd<cr>

" Prepare a file prefixed with the path of the current buffer
nmap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Never, ever let vim look up the word under the cursor and ruin your life.
" Map to normal up
map K k

" Same with Q. Very bad and easy to type accidentally
nmap Q q

" Strip one layer of nesting
nnoremap <Leader>sn [{mzjV]}k<]}dd`zdd

" Alphabetize CSS rules if on mulitple lines
nnoremap <Leader>rs vi{:sort<cr>

" trim trailing whitespace
noremap <Leader>sw :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

" See ~/.gvimrc
" Execute VIM colon command under cursor with <⌘-e>
nnoremap <D-e> yy:<C-r>"<backspace><cr>

" Copy line to last changed postition
nnoremap <silent> <Leader>t. :t'.<cr>
vnoremap <silent> <Leader>t. :t'.<cr>

" copy last changed line here
nnoremap <silent> <Leader>t; :'.t.<cr>
vnoremap <silent> <Leader>t; :'.t.<cr>

" Make Y yank till end of line. Super useful. This is the most important thing
" in this file
nnoremap Y y$

" In command line mode use ctrl-direction to move instead of arrow keys. Super
" useful.
cnoremap <C-j> <t_kd>
cnoremap <C-k> <t_ku>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" See also https://github.com/tpope/vim-rsi
" Ctrl-e: Go to end of line like bash and command mode
inoremap <c-e> <esc>A

" Ctrl-a: Go to start of line like bash and command mode
"inoremap <c-a> <esc>I
" Commenting this out to try using ctlr-a for inserting last inserted text

" Ctrl-h / l: Move left/right by word in command mode
cnoremap <c-h> <s-left>
cnoremap <c-l> <s-right>

" Same for insert mode, including up down
inoremap <c-h> <s-left>
inoremap <c-l> <s-right>

" Ctrl-j in insert mode: Move cursor down if autocomplete menu is closed
inoremap <expr> <c-j> pumvisible() ? "\<C-e>\<Down>" : "\<Down>"
" Ctrl-k in insert mode: Move cursor up if autocomplete menu is closed
inoremap <expr> <c-k> pumvisible() ? "\<C-e>\<Up>" : "\<Up>"

" use space to cycle between splits. I never use this garbage
"nmap <S-Space> <C-w>W

" Delete current buffer
nmap <Leader>bd :bdelete<CR>

" Map :W to :w (http://stackoverflow.com/questions/3878692/aliasing-a-command-in-vim)
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))

" Map :H to :h
cnoreabbrev <expr> H ((getcmdtype() is# ':' && getcmdline() is# 'H')?('h'):('H'))

" Even with MacVim, Command-V to paste isn't repeatable. I have no idea what's
" up with that. This maps it to a normal Vim command and now I can repeat with
" . but I don't know why this fixes it
inoremenu Edit.Paste <C-r><C-p>*

" Jump backwards to previous function, assumes code is indented (useful when
" inside function)
nnoremap <Leader>ff ?^func\\|^[a-zA-Z].*func<CR>,/

" Faster tab switching. I never use these cause macvim lets me use
" command-shift-[ which is way nicer
nnoremap <C-l> gt
nnoremap <C-h> gT

" Todo fix b
nnoremap <Leader>cp dd?✅<cr>p0ls✅<esc><c-o>

" experimental - enter to go into command mode (otherwise useless shortcut).
" See clickable_maps for preventing vim clickable from messing this up. Also
" see :h <cr> which is duplicated by BOTH ctrl-m AND + lol
" I never ended up using this
" nmap <CR> :

" Ray-Frame testing thingy
" nnoremap <Leader>x:tabe a.js


" =============================================================================
" ====
" =====
" ======
" Custom Functions And Hand Written Plugins:
" ======
" =====
" ====
" ===
" =============================================================================


"------------------------------------------------------------------------------
" CloseVimIfLastBufferIsQuickFix
" Quit vim if the only buffer open is the quickfix list. Vim is not "well
" designed" http://vim.wikia.com/wiki/Automatically_quit_Vim_if_quickfix_window_is_the_last
"------------------------------------------------------------------------------
function! CloseVimIfLastBufferIsQuickFix()
    " if the window is quickfix go on
    if &buftype=="quickfix"
        " if this window is last on screen quit without warning
        if winbufnr(2) == -1
            quit!
        endif
    endif
endfunction
au BufEnter * call CloseVimIfLastBufferIsQuickFix()


"------------------------------------------------------------------------------
" FixVimSpellcheck
" Map z=, which normally opens a big useless list of suggested spelling
" corrections, to automatiaclly replace the word under the cursor with the
" first most likely spell suggestion, even if set spell is off
"------------------------------------------------------------------------------
function! FixVimSpellcheck()
    if &spell
        normal! 1z=
    else
        set spell
        normal! 1z=
        set nospell
    endif
endfunction

nnoremap z= :call FixVimSpellcheck()<cr>

" While we're here, disable the zg (add to dictionary) shortcut, because it's
" awful functionality and I hit it all the time because who on earth remembers
" what zg and z= do
nnoremap zg z=


"------------------------------------------------------------------------------
" ToggleQuickFix
" There's no way to close the quickfix window without jumping to it and :q or
" whatever. That's bad. Let me close it from anywhere
"------------------------------------------------------------------------------
function! ToggleQuickFix()
    if exists("g:qwindow")
        cclose
        execute "wincmd p"
        unlet g:qwindow
    else
        try
            copen
            execute "wincmd J"
            let g:qwindow = 1
        catch
            echo "Error!"
        endtry
    endif
endfunction

nnoremap <Leader>cx :call ToggleQuickFix()<CR>


"------------------------------------------------------------------------------
" TextEnableCodeSnip
" Highlight blocks of text as one syntax style with start/end markers
"------------------------------------------------------------------------------

" Garbage doesn't work yet http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
    let ft=toupper(a:filetype)
    let group='textGroup'.ft
    if exists('b:current_syntax')
        let s:current_syntax=b:current_syntax
        " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
        " do nothing if b:current_syntax is defined.
        unlet b:current_syntax
    endif
    execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
    try
        execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
    catch
    endtry
    if exists('s:current_syntax')
        let b:current_syntax=s:current_syntax
    else
        unlet b:current_syntax
    endif
    execute 'syntax region textSnip'.ft.'
                \ matchgroup='.a:textSnipHl.'
                \ start="'.a:start.'" end="'.a:end.'"
                \ contains=@'.group
endfunction

call TextEnableCodeSnip('ruby', '@begin=ruby@', '@end=ruby@', 'SpecialComment')
call TextEnableCodeSnip('glsl', '@begin=glsl@', '@end=glsl@', 'SpecialComment')


"------------------------------------------------------------------------------
" FixJumpChangeList
" I want g; (jump to older change) to only jump to the line if the change was
" far away (not on the same line)... I think. But this doesn't work.
"------------------------------------------------------------------------------

" this is a good start but not quite there yet, it goes in a loop
function! FixJumpChangeList()
    redir @a
    silent changes
    redir end

    let s:current_line = line('.')
    let s:lines = reverse( split(@a, '\n') )
    let s:idx = 1
    let s:bail = min([ 10, len( s:lines ) ])
    while s:idx < s:bail
        let s:rows = split( s:lines[ s:idx ], '\s\+' )
        if abs( s:rows[ 1 ] - s:current_line ) > 1
            echo "Jumped to line " . s:rows[ 1 ] . " from " . s:current_line
            execute "normal " . s:rows[ 1 ] . "G"
            keepjumps execute "normal 0" . s:rows[ 2 ] . "l"
            break
        endif
        let s:idx = s:idx + 1
    endwhile
endfunction

nnoremap g; :call FixJumpChangeList()<cr>


"------------------------------------------------------------------------------
" Wipeout (helpful!)
" Remove non visible buffers
" From http://stackoverflow.com/questions/1534835/how-do-i-close-all-buffers-that-arent-shown-in-a-window-in-vim
"------------------------------------------------------------------------------
function! Wipeout()
    "From tabpagebuflist() help, get a list of all buffers in all tabs
    let tablist = []
    for i in range(tabpagenr('$'))
        call extend(tablist, tabpagebuflist(i + 1))
    endfor

    let nWipeouts = 0
    for i in range(1, bufnr('$'))
        if bufexists(i) && !getbufvar(i,"&mod") && index(tablist, i) == -1
            "bufno exists AND isn't modified AND isn't in the list of buffers
            "open in windows and tabs
            silent exec 'bwipeout' i
            let nWipeouts = nWipeouts + 1
        endif
    endfor
    echomsg nWipeouts . ' buffer(s) wiped out'
endfunction

nnoremap <Leader>x :tabcl<cr>:call Wipeout()<cr>


"------------------------------------------------------------------------------
" ParagraphMove
" Fix vim's default { } motions by treating lines containing only whitespace
" as blank, so they aren't jumped to
" see http://stackoverflow.com/questions/1853025/make-and-ignore-lines-containing-only-whitespace
"------------------------------------------------------------------------------
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


"------------------------------------------------------------------------------
" EditConflictFiles
" Paired with the "vc" function in my .bashrc. This loads all files that Git
" has marked as conflicts (during merge/rebase/cherry-pick etc) into the
" arglist, and loads all conflict markers (<<<<<<<<) etc into the quickfix
" list, so you can easily jump between them
"------------------------------------------------------------------------------
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
    silent! let gitignore = readfile('.gitattributes')
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

                    " Get the line number by removing the white space around
                    " it
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

    " Highlight diff markers and then party
    highlight Conflict guifg=white guibg=red
    match Conflict /^=\{7}.*\|^>\{7}.*\|^<\{7}.*/
    echom "Use ]n or [n to navigate to conflict markers with vim-unimpaired"
endfunction


"------------------------------------------------------------------------------
" TabMove
" Move a tab left or right with a keystroke. Pretty strange this isn't in Vim
" by default
"------------------------------------------------------------------------------
" @param direction -1 for left, 1 for right.
function! TabMove(direction)
    let s:current_tab = tabpagenr()
    let s:total_tabs = tabpagenr("$")

    " Wrap to end
    if s:current_tab == 1 && a:direction == -1
        tabmove
    " Wrap to start
    elseif s:current_tab == s:total_tabs && a:direction == 1
        tabmove 0
    " Normal move
    else
        execute (a:direction > 0 ? "+" : "-") . "tabmove"
    endif
    echo "Moved to tab " . tabpagenr() . " (previosuly " . s:current_tab . ")"
endfunction

" Move tab left or right
map <D-H> :call TabMove(-1)<CR>
map <D-L> :call TabMove(1)<CR>


"------------------------------------------------------------------------------
" FormatX
" Attempts to format and properly indent different types of files. Like if you
" have a big indented JSON string, run :call FormatJson()<cr> and this
" attempts to format it. These work pretty poorly and I should probably
" replace with a command line tool and never, ever use Vim for things like
" this
"------------------------------------------------------------------------------
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

function! FormatAdiumLogs()
    silent! exec '%g/\vleft the room/d'
    silent! exec '%g/\ventered the room/d'
    silent! exec '%s/\v time\="[^"]+"\>\<div\>\<span style\="[^"]+"//'
    normal vie=
    exec 'set ft=html'
endfunction

function! FormatHtml()
    silent! exec '%s/\v\>\</\>\r\<'
    normal vie=
    exec 'set ft=html'
endfunction


"------------------------------------------------------------------------------
" JumpToWebpackError
" Uhhh...ignore this one probably. I don't even remember writing it
"------------------------------------------------------------------------------
function! JumpToWebpackError()
    let cmd = system("node ./find_webpack_error.js")
    let place = split( cmd, ' ' )
    exe ":tabe " . place[0]
endfunction

nnoremap <leader>fw :call JumpToWebpackError()<cr>


"------------------------------------------------------------------------------
" HandleURI
" Open a URL-looking thing with the system "open" command, which opens it in
" the default browser. Note this doesn't conflict with vim-clickable, but
" clickable gives you this by default
"------------------------------------------------------------------------------
function! HandleURI()
    let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:]*')
    echo s:uri
    if s:uri != ""
        exec "!open \"" . s:uri . "\""
    else
        echo "No URI found in line."
    endif
endfunction
nnoremap <Leader>op :call HandleURI()<CR>


"------------------------------------------------------------------------------
" ToggleRelativeAbsoluteNumber
" Toggle relative / line number. I never use this garbage
"------------------------------------------------------------------------------
function! ToggleRelativeAbsoluteNumber()
    if &number
    set relativenumber
    else
    set number
    endif
endfunction

nnoremap <leader>rl :call ToggleRelativeAbsoluteNumber()<CR>


"------------------------------------------------------------------------------
" Refactor
" Locally (local to block) rename a variable. Every day I want Vim to be an
" IDE, but it will always be a text editor
"------------------------------------------------------------------------------
function! Refactor()
    call inputsave()
    let @z=input("What do you want to rename '" . @z . "' to? ")
    call inputrestore()
endfunction

nnoremap <Leader>rf "zyiw:call Refactor()<cr>mx:silent! norm gd<cr>:silent! norm [{<cr>$V%:s/<C-R>//<c-r>z/g<cr>`x


"------------------------------------------------------------------------------
" VSetSearch
" Let * and # search for next/previous of selected text when you have text
" selected in visual mode (you want this)
"------------------------------------------------------------------------------
function! s:VSetSearch()
    let old = @"
    norm! gvy
    let @/ = '\V' . substitute(escape(@", '\'), '\n', '\\n', 'g')
    let @" = old
endfunction

vnoremap * :<C-u>call <SID>VSetSearch()<CR>/<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>?<CR>


"------------------------------------------------------------------------------
" Highlight Word
" This mini-plugin provides a few mappings for highlighting words temporarily.
" Sometimes you're looking at a hairy piece of code and would like a certain
" word or two to stand out temporarily. You can search for it, but that only
" gives you one color of highlighting. Now you can use <leader>N where N is
" a number from 1-6 to highlight the current word in a specific color.
"------------------------------------------------------------------------------
function! HiInterestingWord(n)
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
endfunction

" Clear all matches
function! TurnOffInterestingHighlight()
    let mid = 86750
    silent! call matchdelete(mid + 1)
    silent! call matchdelete(mid + 2)
    silent! call matchdelete(mid + 3)
    silent! call matchdelete(mid + 4)
    silent! call matchdelete(mid + 5)
    silent! call matchdelete(mid + 6)
endfunction

hi def InterestingWord1 guifg=#000000 ctermfg=16 guibg=#ffa724 ctermbg=214
hi def InterestingWord2 guifg=#000000 ctermfg=16 guibg=#aeee00 ctermbg=154
hi def InterestingWord3 guifg=#000000 ctermfg=16 guibg=#8cffba ctermbg=121
hi def InterestingWord4 guifg=#000000 ctermfg=16 guibg=#b88853 ctermbg=137
hi def InterestingWord5 guifg=#000000 ctermfg=16 guibg=#ff9eb8 ctermbg=211
hi def InterestingWord6 guifg=#000000 ctermfg=16 guibg=#ff2c4b ctermbg=195

nnoremap <silent> <leader>h1 :call HiInterestingWord(1)<cr>
nnoremap <silent> <leader>h2 :call HiInterestingWord(2)<cr>
nnoremap <silent> <leader>h3 :call HiInterestingWord(3)<cr>
nnoremap <silent> <leader>h4 :call HiInterestingWord(4)<cr>
nnoremap <silent> <leader>h5 :call HiInterestingWord(5)<cr>
nnoremap <silent> <leader>h6 :call HiInterestingWord(6)<cr>
" Turn off above
nnoremap <silent> <leader>hx :call TurnOffInterestingHighlight()<cr>
nnoremap <silent> <leader>h0 :call TurnOffInterestingHighlight()<cr>
nnoremap <silent> <leader>hd :call TurnOffInterestingHighlight()<cr>


"------------------------------------------------------------------------------
" AttemptToSwapTwoThings
" Everyone wants the most efficient way to swap two pieces of text in Vim.
" This is my attempt to guess at what the user wants to swpa
"------------------------------------------------------------------------------
function! AttemptToSwapTwoThings()
    let l:lastSearch = @/
    " Search backwards for an opening brace, but only on current line
    let l:match = search('\v[({<[]', 'b', line("."))

    " If there was no match (opening brace), jump to the first non-blank char
    if !l:match
        normal g^
    else
        normal w
    endif

    " Go to the first thing to match and mark
    execute "normal! mz"
    " Set search for dividing character, or the closing brace
    let @/ = '\v\s*\zs([,/)\]>}\-+:]|(\.|as|in|\|\|?|\&\&?|\?|\=)\s)|$|;'
    " select and yank till that dividng character into z
    execute "normal vnge\"zy"
    " go past diving character to the next thing and mark y
    execute "normal! nwmy"
    " paste z in place of second thing. second thing now in paste register
    execute "normal! vnge\"zp"
    " go back to first word
    execute "normal! `z"
    " select first word until old match, then paste
    execute "normal! vngep"
    let @/ = l:lastSearch
    execute "normal :nohlsearch\<cr>"
endfunction

function! AttemptToSwapThingsInVisualMode()
    let l:lastSearch = @/
    " Go to the first thing to match and mark
    execute "normal! \<Esc>`<mz`>mx`z"
    " Set search for dividing character, or the closing brace
    let @/ = '\v\s*\zs([,/)\]>}\-+:]|(\.|as|in|\|\|?|\&\&?|\?|\=)\s)|$|;'
    " select and yank till that dividng character into z
    execute "normal vnge\"zy"
    " go past diving character to the next thing and mark y
    execute "normal! nwmy"
    " paste z in place of second thing. second thing now in paste register
    execute "normal! vnge\"zp"
    " go back to first word
    execute "normal! `z"
    " select first word until old match, then paste
    execute "normal! vngep"
    let @/ = l:lastSearch
    execute "normal :nohlsearch\<cr>"
    execute "normal `zv`x"
endfunction

" Swap two parameters in a function
nnoremap <Leader>- :call AttemptToSwapTwoThings()<cr>
vnoremap <Leader>- :call AttemptToSwapThingsInVisualMode()<cr>


"------------------------------------------------------------------------------
" DimInactiveWindows
" Since it's usually hard to tell where the Vim cursor is when using splits,
" set the background color of splits you're not focused on to a "dimmed"
" color. Note for some reason on command line vim, the color is bright red
"------------------------------------------------------------------------------
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


"------------------------------------------------------------------------------
" MyTabLine
" Attempt to show what folder files are in (doesn't work)
"------------------------------------------------------------------------------
"function! MyTabLine()
    "let s = ''

    "let path = split(expand('%:p'), '/')
    "return path[-2] . '/' . path[-1]

    "return s
"endfunction

" Count number of splits in current buffer, ignoring nerd tree
"function! GuiTabLabel()
    "let label = ''
    "let bufnrlist = tabpagebuflist(v:lnum)

    "" Add '+' if one of the buffers in the tab page is modified
    "for bufnr in bufnrlist
    "if getbufvar(bufnr, "&modified")
        "let label = '+'
        "break
    "endif
    "endfor

    "let panes = map(range(1, tabpagenr('$')), '[v:val, bufname(winbufnr(v:val))]')
    "let wincount = tabpagewinnr(v:lnum, '$')
    "echo join(panes, ':')

    "for pane in panes
        "if !empty(matchstr(pane[1], 'NERD\|/runtime/doc/')) || empty(pane[1])
            "let wincount -= 1
        "endif
    "endfor

    "" Append the number of windows in the tab page if more than one
    "if wincount > 1
        "let label .= '('.wincount.') '
    "endif

    "" Append the buffer name
    "return label . fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum) - 1]), ':t')
"endfunction

"set guitablabel=%!MyTabLine()


" =============================================================================
" ====
" =====
" ======
" Third Party Vim Plugins:
" ======
" =====
" ====
" ===
" =============================================================================


let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'json', 'javascript', 'ruby', 'glsl']

" To refresh the list of plugins installed, uncomment the line below and hit
" command-E on it (see the <d-e> mapping in this file

" silent execute 'normal mzjV}kdk' | silent execute "read !ls ~/.vim/bundle" | silent execute "normal `zjV}k\<space>c\<space>'z0gcl'"
"Rename
"YouCompleteMe
"ZoomWin
"abolish
"ack.vim
"anzu
"applescript.vim
"clam.vim
"clickable
"clickable-things
"coffee-script
"commentary
"ctrlp.vim
"ctrlspace
"delimitMate
"django.vim
"dragvisuals
"easymotion
"endwise
"extradite
"fugitive
"gitgutter
"glsl
"gundo
"html-entities
"indent-anything
"indent-object
"indentwise
"jison
"less
"match-tag
"matchit
"mru
"multiple-cursors
"mustache-handlebars
"nerd-tree
"nerdcommenter
"node
"over
"powerline
"qargs
"qlist
"repeat
"snippets
"splitjoin.vim
"stylus
"surround
"syntastic
"tabular
"test-runner
"textobj-entire
"textobj-lastpat
"unimpaired
"vim-javascript
"vim-jsx
"vim-nerdtree-tabs
"vim-perl
"vim-project
"vim-script-runner
"vim-snippets
"vim-textobj-comment
"vim-textobj-function-perl
"vim-textobj-user
"vimproc.vim

" Dead Plugins I Have Removed:
"unite
"choosewin
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
"ultisnips
"ultisnips-snips
"snipmate-snippets
"rainbow_parentheses.vim
"tagbar
"vim-expand-region

" Plugins You Absolutely Need From The Above List:
" - NerdTree
" - NerdTreeTabs
" - ack.vim
" - ctrlp.vim
" - gundo
" - multiple-cursors
" - qargs
" - repeat
" - surround
" - syntastic
" - unimpaired

" Plugin Notes:
" - GitGutter doesn't seem to be highlighting anymore? Conflict with color
"   scheme or highlighting? But it did work after calling max_signs again
" - Removing ultisnips for now because never got it to work right

" Personal Notes Ignore This Section:
" - Use gc or gcc for commenting motions from vim-commentary
" - use vac or vic to select inside / around comments
" - I set mark s for place-before-search
" - From https://www.youtube.com/watch?v=3TX3kV3TICU use ctrl-a in insert to
"       repeat last typed text. use ctrl-x ctrl-p to complete sentences in some
"       magical way. ctrl-x ctrl-o is a way to complete syntax
"       aware lke fn.<c-x><c-o> completion. I will never type this
" - Use ]I and [I (and lowercase) to show lines containing word under cursor
" - leader aa is for ack with out -i
" - /%V is how you match only visual selection, since ranges are linewise and
" - Abolish.vim does some fancy case-sensitive search and replace stuff, that
"   I never, ever, ever use nor want to use
" - I have both match-tag and matchit. What's up with that?
" - I have spltjoin.vim, which lets you use gS and gJ to one-linerize code.
"   But I never use it because I forget and probably don't do that often


" =============================================================================
" ====
" =====
" ======
" Plugin Configurations And Mappings:
" ======
" =====
" ====
" ===
" =============================================================================
" Alphabetical excluding any Vim- prefix

"------------------------------------------------------------------------------
" Ack.vim
"------------------------------------------------------------------------------

" Visual ack, used to ack for highlighted text
function! s:VAck()
    let old = @"
    norm! gvy
    let @z = substitute(escape(@", '\'), '\n', '\\n', 'g')
    let @" = old
endfunction

" Ack for visual selection
vnoremap <Leader>av :<C-u>call <SID>VAck()<CR>:exe "Ack! ".@z.""<CR>
" Ack for word under cursor
nnoremap <Leader>av :Ack!<cr>
" Open Ack
nnoremap <Leader>ao :Ack! -i 
nnoremap <Leader>aa :Ack! 

" Ack for word under cursor
nnoremap <Leader>aw "zyiw:exe "Ack! ".@z.""<CR>
nnoremap <Leader>aW "zyiW:exe "Ack! ".@z.""<CR>


"------------------------------------------------------------------------------
" Anzu (show n/total search count)
"------------------------------------------------------------------------------

" Note, I removed these from an older version of my vimrc. So maybe these will
" destory everything. Why? Does it conflict with something else?
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)


"------------------------------------------------------------------------------
" Clickable (does this still work? need to investigate)
"------------------------------------------------------------------------------
" Remove enter from clickable action
let g:clickable_maps = '<2-LeftMouse>,<C-2-LeftMouse>,<S-2-LeftMouse>,<C-CR>,<S-CR>,<C-S-CR>'


"------------------------------------------------------------------------------
" CtrlP
"------------------------------------------------------------------------------

" Set Ctrl-P to show match at top of list instead of at bottom, which is awful
" that it's not default
let g:ctrlp_match_window_reversed = 0

" Tell Ctrl-P to keep the current VIM working directory when starting a
" search
let g:ctrlp_working_path_mode = 0

" Ctrl-P ignore target dirs so VIM doesn't have to! Yay!
let g:ctrlp_custom_ignore = {
    \ 'dir': 'public\-build$\|dist$\|\.git$\|\.hg$\|\.svn$\|target$\|built$\|.build$\|node_modules\|\.sass-cache\|locallib$\|log$|vendor$',
    \ 'file': '\.ttc$',
    \ }

let g:ctrlspace_ignored_files = '\v\.git$|\.hg$|\.svn$|target$|built$|.build$|node_modules|\.sass-cache|locallib$|log$'

" Fix ctrl-p's mixed mode https://github.com/kien/ctrlp.vim/issues/556
"let g:ctrlp_extensions = ['mixed']

nnoremap <c-p> :CtrlP<cr>

" Set up some custom ignores
"call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep',
      "\ 'ignore_pattern', join([
      "\ '\.git\|\.hg\|\.svn\|target\|built\|.build\|node_modules\|\.sass-cache',
      "\ '\.ttc$',
      "\ ], '\|'))

" Open multiplely selected files in a tab by default
let g:ctrlp_open_multi = '10t'


"------------------------------------------------------------------------------
" delimitMate
"------------------------------------------------------------------------------
let delimitMate_expand_space = 1 " Make typing space after (| convert to ( | )
let delimitMate_balance_matchpairs = 1


"------------------------------------------------------------------------------
" Extradite
"------------------------------------------------------------------------------
nnoremap <Leader>gl :Extradite!<CR>


"------------------------------------------------------------------------------
" Fugitive
"------------------------------------------------------------------------------
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gb :Gblame<CR>


"------------------------------------------------------------------------------
" Git Gutter
"------------------------------------------------------------------------------
highlight SignColumn guibg=#111111
highlight GitGutterAdd guifg=#00ff00
highlight GitGutterChange guifg=#fff000 guibg=#111111
highlight GitGutterChangeDelete guifg=#fff000 guibg=#111111

let g:gitgutter_sign_column_always = 1
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '-'
let g:gitgutter_sign_modified_removed = '-'
let g:gitgutter_sign_modified = '*'


"------------------------------------------------------------------------------
" Gundo
"------------------------------------------------------------------------------
" Gundo doesn't map an open shortcut by default
nnoremap <Leader>u :GundoToggle<CR>


"------------------------------------------------------------------------------
" MRU (most recently used files list)
"------------------------------------------------------------------------------
" MRU mappings, open most recent files list
nnoremap <Leader>ml :MRU<cr>
" Opens mru which lets files autocomplete
nnoremap <Leader>me :MRU 


"------------------------------------------------------------------------------
" MultipleCursors
"------------------------------------------------------------------------------

" Fix multiple cursors mode switching
let g:multi_cursor_exit_from_insert_mode=0
let g:multi_cursor_exit_from_visual_mode=0

" Fix no highlighting too
highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
highlight link multiple_cursors_visual Visual

" Multiple cursors has no default way to highlight every occurance yet, so I
" wrote this. May eventually go into core: https://github.com/terryma/vim-multiple-cursors/issues/151
function! FindAllMultipleCursors( type )

    " Yank the (w)ord under the cursor into reg z. If we (were) in visual mode,
    " use gv to re-select the last visual selection first
    if a:type == "v"
        norm! gv"zy
    else
        norm! "zyiw
    endif

    " Find how many occurrences of this word are in the current document, see
    " :h count-items. Redirect the output to register x silently otherwise it
    " spits out the search output
    redir @x | silent execute "%s/\\v" . @z . "/&/gn" | redir END

    " Get the first word in output ("n of n matches") which is count. Split
    " on non-word chars because output has linebreaks
    let s:count = split( @x, '\W' )[ 0 ]

    if s:count > 15
        call inputsave()
        let s:yn = input('There are ' . s:count . ' matches, and MultipleCurors is slow. Are you sure? (y/n) ')
        call inputrestore()
        redraw
        if s:yn != "y"
            echo "Aborted FindAllMultipleCursors."
            return
        endif
    endif

    execute "MultipleCursorsFind " . @z
endfunction

nnoremap <leader>fa :call FindAllMultipleCursors("")<cr>
vnoremap <leader>fa :call FindAllMultipleCursors("v")<cr>

"------------------------------------------------------------------------------
" NERDTree / NERDTreeTabs
"------------------------------------------------------------------------------

" Don't open nerdtree feature expander open on startup
let g:nerdtree_tabs_open_on_gui_startup=0

" Do I really need this still?
let NERDTreeIgnore=['pubilc-build']

" If typing :bd in nerdtree, switch to main file and close that instead. While
" we're here, do the same for the quickfix list
autocmd FileType nerdtree cnoreabbrev <buffer> bd :echo "No you don't"<cr>
autocmd FileType qf cnoreabbrev <buffer> bd :echo "No you don't"<cr>

" Toggle nerdtree (nerdtreetabs plugin does not map this by default)
nnoremap <Leader>nt :NERDTreeTabsToggle<cr>

" When switching tabs, attempt to move cursor to a file and out of nerdtree,
" quickfix and help windows
function! FixNerdTreeTabSwitching()
    for i in [1, 2, 3]
        let s:_ft = &filetype
        if s:_ft == "nerdtree" || s:_ft == "help" || s:_ft == "qf"
            execute "wincmd w"
        else
            break
        endif
    endfor
endfunction

autocmd TabLeave * call FixNerdTreeTabSwitching()

" Copy current buffer path relative to root of VIM session to system
" clipboard. SUPER helpful, I use this all the time to get the relative path
" for the file I'm workIng on
function! CopyPathOrNERDPath()
    let s:ft = &filetype
    if s:ft == "nerdtree"
        let s:n = g:NERDTreeFileNode.GetSelected()
        if s:n != {}
            let@*=s:n.path.str()
            echo "Copied file path to clipboard"
        endif
    else
        let @*=expand("%")
        echo "Copied file path to clipboard"
    endif
endfunction

nnoremap <Leader>yp :call CopyPathOrNERDPath()<cr>

" Helpful mapping to jump to this file in nerdtree. By default nerdtreefind
" will IGNORE your cwd/pwd if nerdtree is closed, and open the tree with the
" root being the folder of the file you're in.
function! OpenNerdTreeWithFileHighlightedInRightContext()
  let s:open = exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
  if s:open
    5wincmd h
    normal R
    " hurrrggghhhh
    wincmd w
    NERDTreeFind
  else
    NERDTreeTabsToggle
    " omgggggg
    wincmd w
    NERDTreeFind
  endif
endfunction

nnoremap <silent> <Leader>nf :call OpenNerdTreeWithFileHighlightedInRightContext()<cr>zz


"------------------------------------------------------------------------------
" Powerline
"------------------------------------------------------------------------------

" Powerline custom font. Why did I remove this?
"if has('gui_running')
    "set guifont=Menlo\ for\ Powerline
"endif

" Powerline symbols instead of letters
let g:Powerline_symbols = 'fancy'


"------------------------------------------------------------------------------
" Project, great plugin
"------------------------------------------------------------------------------
set rtp+=~/.vim/bundle/vim-project/
let g:project_disable_tab_title = 1
"let g:project_enable_welcome = 0
let g:project_use_nerdtree = 1

" default starting path (the home directory)
call project#rc("~/")

Project  '~/fq'                           , 'fq'
Project  '~/shader-studio'                , 'shader-studio'
Project  '~/runtime-shaderfrog'           , 'shaderfrog-runtime'
Project  '~/doopy-butts'                  , 'doopy-butts'
Project  '~/cats-react'                   , 'cats-react'
Project  '~/big-bubble'                   , 'bubble'
Project  '~/glsl2js'                      , 'parser'
Project  '~/mood-engine'                  , 'mood engine'
Project  '~/blog'                         , 'blog'
Project  '~/blag'                         , 'blag'
Project  '~/dev'                          , 'gr-dev'
Project  '~/dev/engineering'              , 'gr-engineering'
Project  '~/dev/brizo'                    , 'gr-brizo'
Project  '~/dev/tp'                       , 'tp'
Project  '~/dev/monger-cordova'           , 'monger-cordova'
Project  '~/dev/jarvis'                   , 'jarvis'
Project  '~/dev/devise-two-factor/demo'   , 'devise-two-factor-demo'
Project  '~/workerbee/OpusWeb/mvp_webpack', 'bee site'
Project  '~/rails-tutorial'               , 'rails tutorial'
Project  '~/dev/onboarding-tech-notes'    , 'onboarding tech notes'
Project  '~/closed-source-projects'       , 'closed source projects'

"------------------------------------------------------------------------------
" Script-runner (I don't really use this anymore)
"------------------------------------------------------------------------------
let g:script_runner_perl = "perl -Ilib -MData::Dumper -Mv5.10"
let g:script_runner_javascript = "node"


"------------------------------------------------------------------------------
" Surround
"------------------------------------------------------------------------------
" Switch " and ' with c (VERY useful)
nmap c' cs'"
nmap c" cs"'


"------------------------------------------------------------------------------
" Syntastic
"------------------------------------------------------------------------------

" Place error visual marker in gutter
let g:syntastic_enable_signs=1
let g:syntastic_perl_lib_path = [ './locallib/lib/perl5' ]
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_javascript_eslint_exec = './node_modules/.bin/eslint'


"------------------------------------------------------------------------------
" Tabularize
"------------------------------------------------------------------------------

" Attempt to format a list of things that have equals signs, aligning them
" automatically using the tabularize plugin. Tabularize is finnicky and has
" bad defaults, so we have to tell it exactly what we think we want
function! FormatEquals()
    normal gg
    let @z=@/
    let @/='\v^((var.+\=.+;|import.+from.+|^)(\n^$))+(\n^((var.+\=.+require|import)@!|var.+createClass))'
endfunction

nnoremap <leader>= :call FormatEquals()<cr> <bar> Vn:Tabularize /\v(\=\|from)<cr> <bar> :let @/=@z<cr>
" tabularize around : or =
vnoremap <silent> <Leader>tt :Tabularize /:\zs/l0r1<CR>
vnoremap <silent> <Leader>t= :Tabularize /=\zs/l0r1<cr>
vnoremap <silent> <Leader>t, :Tabularize /,\zs/l0r1<cr>
nnoremap <silent> <Leader>tt :Tabularize<CR>


"------------------------------------------------------------------------------
" Textobj-User
"------------------------------------------------------------------------------
" You can't put comments in text objects, because that would mean Vim was well
" designed. This block comment applies to the below text objects
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
"       Select around (a)ttribute a="stuff" including jsx props a={hi}
" regex_ar:
" regex_ir:
"       Select inside around css (r)ules, including react createstyle rules.
"       Useful for ysr' to surround unquoted css
" regex_ih:
"       Inside ( function, args ) ignoring parens and whitespace. I (h)ave no
"       idea
"

call textobj#user#plugin('vimisntgreat', {
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
\   'regex_ar': {
\     'select': 'ar',
\     '*pattern*': ':\zs.\+\ze(;|\s+)'
\   },
\   'regex_ir': {
\     'select': 'ir',
\     '*pattern*': '\v:\s*\zs.+\ze\s*[,;]\s*$'
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
\     '*pattern*': '\v(\w|-)+\=[{"].{-}[}"]'
\   },
\   'regex_ia': {
\     'select': 'ia',
\     '*pattern*': '\v(\w|-)+\=[{"]\zs.{-}\ze[}"]'
\   },
\   'regex_ih': {
\     'select': 'ih',
\     '*pattern*': '\v((\w|[''"+,.])(\s\w)?)+'
\   },
\ })


"------------------------------------------------------------------------------
" Unite.vim
"------------------------------------------------------------------------------
" TODO: I need to investigate more if unite is worth using. never really got
" into it

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
"

"let g:unite_source_history_yank_enable = 1
"let g:unite_split_rule = "botright"
"let g:unite_update_time = 200
"let g:unite_enable_start_insert = 1

"autocmd FileType unite call s:unite_my_settings()
"function! s:unite_my_settings()
    "" Overwrite settings.
    "nmap <buffer> <ESC>      <Plug>(unite_exit)
"endfunction

" =============================================================================
" ====
" =====
" ======
" Spelling Corrections:
" ======
" =====
" ====
" ===
" =============================================================================

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
ab campagin campaign
ab campagn campaign
ab campiagn campaign
ab camapaign campaign
ab respone response
ab closeset closest
ab contribuiton contribution
ab contribuiton contribution
ab contribuiotn contribution
ab conribution contribution
ab contribuitos contributions
ab contribuitos contributions
ab contribuiots contributions
ab conributions contributions
ab positon position
ab animaiton animation
ab promsie promise
ab siez size
ab palatte palette
ab palette palette
ab pallate palette
ab pallete palette
ab pallette palette
ab pallate palette
ab stlyes styles
" why is this an english word
ab glypg glyph
ab glpygh glyph
ab glpyh glyph
ab glpyh glyph
ab glpy glyph
ab glphy glyph
ab exprot export
ab improt import
ab paylaod payload
ab marign margin
ab marthin margin
ab amrgin margin

" JSX class to classname :)
autocmd FileType javascript ab class= className=

