" CompleteHelper.vim: Generic functions to support custom insert mode completions.
"
" DEPENDENCIES:
"   - escapings.vim autoload script
"   - CompleteHelper/Abbreviate.vim autoload script for
"     CompleteHelper#Abbreviate()
"
" Copyright: (C) 2008-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.30.015	27-Sep-2012	Optimization: Skip search in other windows where
"				there's only one that got searched already by
"				s:FindMatchesInCurrentWindow().
"				Optimization: Only visit window when its buffer
"				wasn't already searched.
"				ENH: Allow skipping of buffers via new
"				a:options.bufferPredicate Funcref.
"   1.20.014	03-Sep-2012	ENH: Implement a:options.complete = 'b' (only
"				supporting single-line matches and no
"				a:options.extractor).
"				Factor out s:AddMatch().
"				Transparently handle 'autochdir': still show the
"				correct relative path in matches from other
"				windows, and restore the buffer's CWD even if it
"				was temporarily changed.
"   1.11.013	01-Sep-2012	Make a:matchObj in CompleteHelper#ExtractText()
"				optional; it's not used there, anyway. This
"				avoids having to pass an empty dictionary just
"				to satisfy the API.
"				Introduce a:alreadySearchedBuffers to allow for
"				swapped order in a:options.complete and to
"				prepare for additional complete options.
"   1.10.012	04-May-2012	Factor out CompleteHelper#Abbreviate#Text() to
"				allow processing of completion menu text, too.
"   1.00.011	31-Jan-2012	Prepare for publish.
"	010	04-Oct-2011	Turn multi-line join into
"				CompleteHelper#JoinMultiline() utility function
"				and remove the default processing, now that I
"				have found a workaround to make Vim handle
"				matches with newlines. Rename "multiline" option
"				to a convenience "processor" option, to be used
"				by LongestComplete.vim.
"	009	04-Oct-2011	Move CompleteHelper#Abbreviate() from
"				MotionComplete.vim to allow reuse.
"				Also translate newline characters.
"	008	04-Mar-2010	Collapse multiple lines consisting of only
"				whitespace and a newline into a single space,
"				not one space per line.
"	007	25-Jun-2009	Now using :noautocmd to avoid unnecessary
"				processing while searching other windows.
"	006	09-Jun-2009	Do not include a match ending at the cursor
"				position when finding completions in the buffer
"				where the completion is undertaken.
"				Vim would not offer this anyway, and this way it
"				feels cleaner and does not confuse unit tests.
"				Such a match can happen if a:base =~ a:pattern.
"	005	03-Mar-2009	Now restoring window sizes in
"				s:FindMatchesInOtherWindows() to avoid
"				increating window height from 0 to 1.
"	004	19-Aug-2008	Initial matchObj is now passed to text extractor
"				function.
"	003	18-Aug-2008	Added a:options.multiline; default is to
"				collapse newline and surrounding whitespace into
"				a single <Space>.
"	002	17-Aug-2008	BF: Check for match not yet in the list still
"				used match text, not object.
"	001	13-Aug-2008	file creation

function! s:ShouldBeSearched( options, bufnr )
    return ! has_key(a:options, 'bufferPredicate') || call(a:options.bufferPredicate, [a:bufnr])
endfunction
function! CompleteHelper#ExtractText( startPos, endPos, ... )
"*******************************************************************************
"* PURPOSE:
"   Extract the text between a:startPos and a:endPos from the current buffer.
"   Multiple lines will be delimited by a newline character.
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:startPos	    [line,col]
"   a:endPos	    [line,col]
"   a:matchObj	    The match object to be returned to the completion function.
"		    This function does not need to set anything there, the
"		    mandatory matchObj.word will be set from this function's
"		    return value automatically (and with additional processing).
"		    However, you _can_ modify other items if you deem necessary.
"		    (E.g. add a note to matchObj.menu that the text was
"		    truncated.)
"* RETURN VALUES:
"   string text; return an empty string to signal that no match should be added
"   to the list of matches.
"*******************************************************************************
    let [l:line, l:column] = a:startPos
    let [l:endLine, l:endColumn] = a:endPos
    if l:line > l:endLine || (l:line == l:endLine && l:column > l:endColumn)
	return ''
    endif

    let l:text = ''
    while 1
	if l:line == l:endLine
	    let l:text .= matchstr( getline(l:line) . "\n", '\%' . l:column . 'c' . '.*\%' . (l:endColumn + 1) . 'c' )
	    break
	else
	    let l:text .= matchstr( getline(l:line) . "\n", '\%' . l:column . 'c' . '.*' )
	    let l:line += 1
	    let l:column = 1
	endif
    endwhile
    return l:text
endfunction
function! s:AddMatch( matches, matchObj, matchText, options )
    let l:matchText = a:matchText

    " Custom processing of match text.
    if has_key(a:options, 'processor')
	let l:matchText = a:options.processor(l:matchText)
    endif

    " Store match text in match object.
    let a:matchObj.word = l:matchText

    " Only add if this is an actual match that is not yet in the list of
    " matches.
    if ! empty(l:matchText) && index(a:matches, a:matchObj) == -1
	call add(a:matches, a:matchObj)
    endif
endfunction
function! s:FindMatchesInCurrentWindow( alreadySearchedBuffers, matches, pattern, matchTemplate, options, isInCompletionBuffer )
    if has_key(a:alreadySearchedBuffers, bufnr(''))
	return
    endif
    let a:alreadySearchedBuffers[bufnr('')] = 1
    if ! s:ShouldBeSearched(a:options, bufnr(''))
	return
    endif

    let l:isBackward = has_key(a:options, 'backward_search')

    let l:save_cursor = getpos('.')

    let l:firstMatchPos = [0,0]
    while ! complete_check()
	let l:matchPos = searchpos( a:pattern, 'w' . (l:isBackward ? 'b' : '') )
	if l:matchPos == [0,0] || l:matchPos == l:firstMatchPos
	    " Stop when no matches or wrapped around to first match.
	    break
	endif
	if l:firstMatchPos == [0,0]
	    " Record first match position to detect wrap-around.
	    let l:firstMatchPos = l:matchPos
	endif

	let l:matchEndPos = searchpos( a:pattern, 'cen' )
	if a:isInCompletionBuffer && (l:matchEndPos == l:save_cursor[1:2])
	    " Do not include a match ending at the cursor position; this is just
	    " the completion base, and Vim would not offer this anyway. Such a
	    " match can happen if a:base =~ a:pattern.
	    continue
	endif

	" Initialize the match object and extract the match text.
	let l:matchObj = copy(a:matchTemplate)
	let l:matchText = (has_key(a:options, 'extractor') ? a:options.extractor(l:matchPos, l:matchEndPos, l:matchObj) : CompleteHelper#ExtractText(l:matchPos, l:matchEndPos))

	call s:AddMatch(a:matches, l:matchObj, l:matchText, a:options)
"****D echomsg '**** match from' string(l:matchPos) 'to' string(l:matchEndPos) l:matchText
    endwhile

    call setpos('.', l:save_cursor)
endfunction
function! s:FindMatchesInOtherWindows( alreadySearchedBuffers, matches, pattern, options )
    let l:originalWinNr = winnr()
    if winnr('$') == 1 && has_key(a:alreadySearchedBuffers, winbufnr(l:originalWinNr))
	" There's only one window, and we have searched it already (probably via s:FindMatchesInCurrentWindow()).
	return
    endif

    " By entering a window, its height is potentially increased from 0 to 1 (the
    " minimum for the current window). To avoid any modification, save the window
    " sizes and restore them after visiting all windows.
    let l:originalWindowLayout = winrestcmd()

    " Unfortunately, restoring the 'autochdir' option clobbers any temporary CWD
    " override. So we may have to restore the CWD, too.
    let l:save_cwd = getcwd()
    let l:chdirCommand = (haslocaldir() ? 'lchdir!' : 'chdir!')

    " The 'autochdir' option adapts the CWD, so any (relative) filepath to the
    " filename in the other window would be omitted. Temporarily turn this off;
    " may be a little bit faster, too.
    let l:save_autochdir = &autochdir
    set noautochdir

    try
	for l:winNr in range(1, winnr('$'))
	    if ! has_key(a:alreadySearchedBuffers, winbufnr(l:winNr)) && s:ShouldBeSearched(a:options, winbufnr(l:winNr))
		execute 'noautocmd' l:winNr . 'wincmd w'

		let l:matchTemplate = {'menu': bufname('')}
		call s:FindMatchesInCurrentWindow(a:alreadySearchedBuffers, a:matches, a:pattern, l:matchTemplate, a:options, 0)
	    endif
	endfor
    finally
	execute 'noautocmd' l:originalWinNr . 'wincmd w'
	silent! execute l:originalWindowLayout

	let &autochdir = l:save_autochdir
	if getcwd() !=# l:save_cwd
	    execute l:chdirCommand escapings#fnameescape(l:save_cwd)
	endif
    endtry
endfunction
function! s:GetListedBufnrs()
    return filter(
    \   range(1, bufnr('$')),
    \   'buflisted(v:val)'
    \)
endfunction
function! s:FindMatchesInOtherBuffers( alreadySearchedBuffers, matches, pattern, options )
    for l:bufnr in s:GetListedBufnrs()
	if has_key(a:alreadySearchedBuffers, l:bufnr)
	    return
	endif
	let a:alreadySearchedBuffers[l:bufnr] = 1
	if ! s:ShouldBeSearched(a:options, l:bufnr)
	    return
	endif

	let l:matchTemplate = {'menu': bufname(l:bufnr)}

	" We need to get all lines at once; there is no other way to remotely
	" determine the number of lines in the other buffer.
	for l:line in getbufline(l:bufnr, 1, '$')
	    " Note: Do not just use matchstr() with {count}, because we cannot
	    " reliably recognize whether an empty result just means "empty match
	    " at {count}" or actually means "no more matches".
	    let l:endPos = 0
	    while 1
		let l:startPos = l:endPos
		let l:endPos = matchend(l:line, a:pattern, l:startPos)
		if l:endPos == -1
		    break
		endif

		call s:AddMatch(a:matches, copy(l:matchTemplate), matchstr(l:line, a:pattern, l:startPos), a:options)
	    endwhile
	endfor

	if complete_check()
	    break
	endif
    endfor
endfunction
function! CompleteHelper#FindMatches( matches, pattern, options )
"*******************************************************************************
"* PURPOSE:
"   Find matches for a:pattern according to a:options and store them in
"   a:matches.
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:matches	(Empty) List that will hold the matches (in Dictionary format,
"		cp. :help complete-functions). Matches will be appended.
"   a:pattern	Regular expression specifying what text will match as a
"		completion candidate.
"		Note: In the buffer where the completion takes place, Vim
"		temporarily removes the a:base part (as passed to the
"		complete-function) during the completion. This helps avoiding
"		that the text directly after the cursor also matches a:pattern
"		(assuming something like '\<'.a:base.'\k\+') and appears in the
"		list.
"		Note: Matching is done via the searchpos() function, so the
"		'ignorecase' and 'smartcase' settings apply. Add |/\c| / |/\C|
"		to the regexp to set the case sensitivity.
"		Note: An empty pattern does not match at all, so take care of
"		passing a sensible default! '\V' will match every single
"		character individually; probably not what you want.
"		Note: for a:options.complete = 'b', matching is limited to
"		within single lines.
"   a:options	Dictionary with match configuration:
"   a:options.complete	    Specifies what is searched, like the 'complete'
"			    option. Supported options: '.' for current buffer,
"			    'w' for buffers from other windows, 'b' for other
"			    loaded buffers from the buffer list.
"   a:options.backward_search	Flag whether to search backwards from the cursor
"				position.
"   a:options.extractor	    Funcref that extracts the matched text from the
"			    current buffer. Will be invoked with ([startLine,
"			    startCol], [endLine, endCol], matchObj) arguments
"			    with the cursor positioned at the start of the
"			    current match; must return string; can modify the
"			    initial matchObj.
"			    Note: Is not used for a:options.complete = 'b'.
"   a:options.processor	    Funcref that processes matches. Will be invoked with
"			    an a:matchText argument; must return processed
"			    string, or empty string if the match should be
"			    discarded. Alternatively, you can filter() / map()
"			    the a:matches result returned from this function,
"			    but passing in a function may be easier for you.
"   a:options.bufferPredicate   Funcref that decides whether a particular buffer
"				should be searched. It is passed a buffer number
"				and must return 0 when the buffer should be
"				skipped.
"* RETURN VALUES:
"   a:matches
"*******************************************************************************
    let l:complete = get(a:options, 'complete', '')
    let l:searchedBuffers = {}
    for l:places in split(l:complete, ',')
	if l:places ==# '.'
	    call s:FindMatchesInCurrentWindow(l:searchedBuffers, a:matches, a:pattern, {}, a:options, 1)
	elseif l:places ==# 'w'
	    call s:FindMatchesInOtherWindows(l:searchedBuffers, a:matches, a:pattern, a:options)
	elseif l:places ==# 'b'
	    call s:FindMatchesInOtherBuffers(l:searchedBuffers, a:matches, a:pattern, a:options)
	endif
    endfor
endfunction

" Deprecated. Use CompleteHelper#Abbreviate#Word() instead.
function! CompleteHelper#Abbreviate( matchObj )
    return CompleteHelper#Abbreviate#Word(a:matchObj)
endfunction

function! CompleteHelper#JoinMultiline( text )
"******************************************************************************
"* PURPOSE:
"   Replace newline(s) plus any surrounding whitespace with a single <Space>.
"   Insert mode completion currently does not deal sensibly with multi-line
"   completions (newlines are inserted literally as ^@), so completions may want
"   to do processing to offer a better behavior.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text
"* RETURN VALUES:
"   Contents of a:text joined into a single line without newline characters.
"******************************************************************************
    return (stridx(a:text, "\n") == -1 ? a:text : substitute(a:text, "\\%(\\s*\n\\)\\+\\s*", ' ', 'g'))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
