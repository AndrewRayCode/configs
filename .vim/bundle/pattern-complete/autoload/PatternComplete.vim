" PatternComplete.vim: Insert mode completion for matches of queried / last search pattern.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - CompleteHelper.vim autoload script
"
" Copyright: (C) 2011-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.007	01-Sep-2012	Make a:matchObj in CompleteHelper#ExtractText()
"				optional; it's not used there, anyway.
"	006	20-Aug-2012	Split off functions into separate autoload
"				script and documentation into dedicated help
"				file.
"	005	14-Dec-2011	BUG: Forgot to rename s:Process().
"	004	12-Dec-2011	Factor out s:ErrorMsg().
"				Error message delay is only necessary when
"				'cmdheight' is 1.
"	003	04-Oct-2011	CompleteHelper multiline handling is now
"				disabled; remove dummy function.
"	002	04-Oct-2011	Move s:Process() to CompleteHelper#Abbreviate().
"	001	03-Oct-2011	file creation from MotionComplete.vim.

function! s:GetCompleteOption()
    return (exists('b:PatternComplete_complete') ? b:PatternComplete_complete : g:PatternComplete_complete)
endfunction

function! s:ErrorMsg( exception )
    " v:exception contains what is normally in v:errmsg, but with extra
    " exception source info prepended, which we cut away.
    let v:errmsg = substitute(a:exception, '^Vim\%((\a\+)\)\=:', '', '')
    echohl ErrorMsg
    echomsg v:errmsg
    echohl None

    if &cmdheight == 1
	sleep 500m
    endif
endfunction
function! PatternComplete#PatternComplete( findstart, base )
    if a:findstart
	" This completion does not consider the text before the cursor.
	return col('.') - 1
    else
	try
	    let l:matches = []
	    call CompleteHelper#FindMatches( l:matches, s:pattern, {'complete': s:GetCompleteOption()} )
	    call map(l:matches, 'CompleteHelper#Abbreviate(v:val)')
	    return l:matches
	catch /^Vim\%((\a\+)\)\=:E/
	    call s:ErrorMsg(v:exception)
	    return []
	endtry
    endif
endfunction
function! PatternComplete#WordPatternComplete( findstart, base )
    if a:findstart
	" This completion does not consider the text before the cursor.
	return col('.') - 1
    else
	try
	    let l:matches = []
	    call CompleteHelper#FindMatches( l:matches, '\<\%(' . s:pattern . '\m\)\>', {'complete': s:GetCompleteOption()} )
	    if empty(l:matches)
		call CompleteHelper#FindMatches( l:matches, '\%(^\|\s\)\zs\%(' . s:pattern . '\m\)\ze\%($\|\s\)', {'complete': s:GetCompleteOption()} )
	    endif

	    call map(l:matches, 'CompleteHelper#Abbreviate(v:val)')
	    return l:matches
	catch /^Vim\%((\a\+)\)\=:E/
	    call s:ErrorMsg(v:exception)
	    return []
	endtry
    endif
endfunction

function! s:PatternInput( isWordInput )
    call inputsave()
    let s:pattern = input('Pattern to find ' . (a:isWordInput ? 'word-' : '') . 'completions: ')
    call inputrestore()
endfunction
function! PatternComplete#InputExpr( isWordInput )
    call s:PatternInput(a:isWordInput)
    if empty(s:pattern)
	" Note: When nothing is returned, the command-line isn't cleared
	" correctly, so it isn't clear that we're back in insert mode. Avoid
	" this by making a no-op insert.
	"return ''
	return "$\<BS>"
    endif

    if a:isWordInput
	set completefunc=PatternComplete#WordPatternComplete
    else
	set completefunc=PatternComplete#PatternComplete
    endif
    return "\<C-x>\<C-u>"
endfunction
function! PatternComplete#SearchExpr()
    if empty(@/)
	let v:errmsg = 'E35: No previous regular expression'
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None

	return "$\<BS>"
    endif

    let s:pattern = @/
    set completefunc=PatternComplete#PatternComplete
    return "\<C-x>\<C-u>"
endfunction



function! PatternComplete#GetNextSearchMatch( completeOption )
    " As an optimization, try a buffer-search from the cursor position first,
    " before triggering the full completion search over all windows.
    let l:startPos = searchpos(@/, 'cnw')
    if l:startPos != [0, 0]
	let l:endPos = searchpos(@/, 'enw')
	if l:endPos != [0, 0]
	    let l:searchMatch = CompleteHelper#ExtractText(l:startPos, l:endPos)
	    if ! empty(l:searchMatch)
		return l:searchMatch
	    endif
	endif
    endif

    if empty(a:completeOption) || a:completeOption ==# '.'
	" No completion from other buffers desired.
	return @/
    endif

    " Do a full completion search.
    " XXX: As the CompleteHelper#FindMatches() implementation visits every
    " window (and this is not allowed in a :cmap), we need to jump out of
    " command-line mode for that, and then do the insertion into the
    " command-line ourselves.
    let [s:cmdline, s:cmdpos] = [getcmdline(), getcmdpos()]
    return "\<C-c>:call PatternComplete#SetSearchMatch(" . string(a:completeOption) . ")\<CR>"
endfunction
function! PatternComplete#SetSearchMatch( completeOption )
    try
	let l:completeMatches = []
	" As the command-line is directly set via c_CTRL-\_e, no translation of
	" newlines is necessary.
	call CompleteHelper#FindMatches(l:completeMatches, @/, {'complete': a:completeOption})
	if ! empty(l:completeMatches)
	    let s:match = l:completeMatches[0].word
	else
	    " Fall back to returning the search pattern itself. It's up to the
	    " user to turn it into literal text by editing out the regular
	    " expression atoms.
	    let s:match = @/
	endif

	call feedkeys(":\<C-\>e(PatternComplete#SetSearchMatchCmdline())\<CR>")
    catch /^Vim\%((\a\+)\)\=:E/
	" v:exception contains what is normally in v:errmsg, but with extra
	" exception source info prepended, which we cut away.
	let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    endtry
endfunction
function! PatternComplete#SetSearchMatchCmdline()
    call setcmdpos(s:cmdpos + len(s:match))
    return strpart(s:cmdline, 0, s:cmdpos - 1) . s:match . strpart(s:cmdline, s:cmdpos - 1)
endfunction
function! PatternComplete#SearchMatch()
    " For the command-line, newlines must be represented by a ^@; otherwise, the
    " newline would be interpreted as <CR> and prematurely execute the
    " command-line.
    return substitute(PatternComplete#GetNextSearchMatch(s:GetCompleteOption()), '\n', "\<C-v>\<C-@>", 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
