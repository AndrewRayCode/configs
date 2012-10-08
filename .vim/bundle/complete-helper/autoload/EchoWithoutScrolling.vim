" EchoWithoutScrolling.vim: :echo overloads that truncate to avoid the hit-enter
" prompt. 
"
" DESCRIPTION:
"   When using the :echo or :echomsg commands with a long text, Vim will show a
"   'Hit ENTER' prompt (|hit-enter|), so that the user has a chance to actually
"   read the entire text. In most cases, this is good; however, some mappings
"   and custom commands just want to echo additional, secondary information
"   without disrupting the user. Especially for mappings that are usually
"   repeated quickly "/foo<CR>, n, n, n", a hit-enter prompt would be highly
"   irritating. 
"   This script provides :echo[msg]-alike functions which truncate lines so that
"   the hit-enter prompt doesn't happen. The echoed line is too long if it is
"   wider than the width of the window, minus cmdline space taken up by the
"   ruler and showcmd features. The non-standard widths of <Tab>, unprintable
"   (e.g. ^M) and double-width characters (e.g. Japanese Kanji) are taken into
"   account. 

" USAGE:
" INSTALLATION:
" DEPENDENCIES:
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
"  - EchoWithoutScrolling#RenderTabs(): The assumption index == char width
"    doesn't work for unprintable ASCII and any non-ASCII characters. 
"
" TODO:
"   - Consider 'cmdheight', add argument isSingleLine. 
"
" Copyright: (C) 2008-2009 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	003	15-May-2009	Added utility function
"				EchoWithoutScrolling#TranslateLineBreaks() to
"				help clients who want to echo a single line, but
"				have text that potentially contains line breaks. 
"	002	16-Aug-2008	Split off TruncateTo() from Truncate(). 
"	001	22-Jul-2008	file creation

function! EchoWithoutScrolling#MaxLength()
    let l:maxLength = &columns

    " Account for space used by elements in the command-line to avoid
    " 'Hit ENTER' prompts.
    " If showcmd is on, it will take up 12 columns.
    " If the ruler is enabled, but not displayed in the status line, it
    " will in its default form take 17 columns.  If the user defines
    " a custom &rulerformat, they will need to specify how wide it is.
    if has('cmdline_info')
	if &showcmd == 1
	    let l:maxLength -= 12
	else
	    let l:maxLength -= 1
	endif
	if &ruler == 1 && has('statusline') && ((&laststatus == 0) || (&laststatus == 1 && winnr('$') == 1))
	    if &rulerformat == ''
		" Default ruler is 17 chars wide. 
		let l:maxLength -= 17
	    elseif exists('g:rulerwidth')
		" User specified width of custom ruler. 
		let l:maxLength -= g:rulerwidth
	    else
		" Don't know width of custom ruler, make a conservative
		" guess. 
		let l:maxLength -= &columns / 2
	    endif
	endif
    else
	let l:maxLength -= 1
    endif
    return l:maxLength
endfunction

function! s:ReverseStr( expr )
    return join( reverse( split( a:expr, '\zs' ) ), '' )
endfunction
function! s:HasMoreThanVirtCol( expr, virtCol )
    return (match( a:expr, '^.*\%>' . a:virtCol . 'v' ) != -1)
endfunction
function! EchoWithoutScrolling#DetermineVirtColNum( expr )
    let i = 1
    while 1
	if ! s:HasMoreThanVirtCol( a:expr, i )
	    return i - 1
	endif
	let i += 1
    endwhile
endfunction
function! s:VirtColStrFromStart( expr, virtCol )
    " Must add 1 because a "before-column" pattern is used in case the exact
    " column cannot be matched (because its halfway through a tab or other wide
    " character). 
    return matchstr(a:expr, '^.*\%<' . (a:virtCol + 1) . 'v')
endfunction
function! s:VirtColStrFromEnd( expr, virtCol )
    " Virtual columns are always counted from the start, not the end. To specify
    " the column counting from the end, the string is reversed during the
    " matching. 
    return s:ReverseStr( s:VirtColStrFromStart( s:ReverseStr(a:expr), a:virtCol ) )
endfunction

function! EchoWithoutScrolling#GetTabReplacement( column, tabstop )
    return a:tabstop - (a:column - 1) % a:tabstop
endfunction
function! EchoWithoutScrolling#RenderTabs( text, tabstop, startColumn )
"*******************************************************************************
"* PURPOSE:
"   Replaces <Tab> characters in a:text with the correct amount of <Space>,
"   depending on the a:tabstop value. a:startColumn specifies at which start
"   column a:text will be printed. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:text	    Text to be rendered. 
"   a:tabstop	    tabstop value (The built-in :echo command always uses a
"		    fixed value of 8; it isn't affected by the 'tabstop'
"		    setting.)
"   a:startColumn   Column at which the text is to be rendered (typically 1). 
"* RETURN VALUES: 
"   a:text with replaced <Tab> characters. 
"*******************************************************************************
    if a:text !~# "\t"
	return a:text
    endif

    let l:pos = 0
    let l:text = a:text
    while l:pos < strlen(l:text)
	" FIXME: The assumption index == char width doesn't work for unprintable
	" ASCII and any non-ASCII characters. 
	let l:pos = stridx( l:text, "\t", l:pos )
	if l:pos == -1
	    break
	endif
	let l:text = strpart( l:text, 0, l:pos ) . repeat( ' ', EchoWithoutScrolling#GetTabReplacement( l:pos + a:startColumn, a:tabstop ) ) . strpart( l:text, l:pos + 1 )
    endwhile
    
    return l:text
endfunction

function! EchoWithoutScrolling#TruncateTo( text, length ) 
"*******************************************************************************
"* PURPOSE:
"   Truncate a:text to a maximum of a:length virtual columns. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:text	Text which may be truncated to fit. 
"   a:length	Maximum virtual columns for a:text. 
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
    if a:length <= 0
	return ''
    endif

    " The \%<23v regexp item uses the local 'tabstop' value to determine the
    " virtual column. As we want to echo with default tabstop 8, we need to
    " temporarily set it up this way. 
    let l:save_ts = &l:tabstop
    setlocal tabstop=8

    let l:text = a:text
    try
	if s:HasMoreThanVirtCol(l:text, a:length)
	    " We need 3 characters for the '...'; 1 must be added to both lengths
	    " because columns start at 1, not 0. 
	    let l:frontCol = a:length / 2
	    let l:backCol  = (a:length % 2 == 0 ? (l:frontCol - 1) : l:frontCol)
"**** echomsg '**** ' a:length ':' l:frontCol '-' l:backCol
	    let l:text =  s:VirtColStrFromStart(l:text, l:frontCol) . '...' . s:VirtColStrFromEnd(l:text, l:backCol)
	endif
    finally
	let &l:tabstop = l:save_ts
    endtry
    return l:text
endfunction
function! EchoWithoutScrolling#Truncate( text, ... ) 
"*******************************************************************************
"* PURPOSE:
"   Truncate a:text so that it can be echoed to the command line without causing
"   the "Hit ENTER" prompt (if desired by the user through the 'shortmess'
"   option). Truncation will only happen in (the middle of) a:text. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:text	Text which may be truncated to fit. 
"   a:reservedColumns	Optional number of columns that are already taken in the
"			line; if specified, a:text will be truncated to
"			(MaxLength() - a:reservedColumns). 
"* RETURN VALUES: 
"   Truncated a:text. 
"*******************************************************************************
    if &shortmess !~# 'T'
	" People who have removed the 'T' flag from 'shortmess' want no
	" truncation. 
	return a:text
    endif

    let l:reservedColumns = (a:0 > 0 ? a:1 : 0)
    let l:maxLength = EchoWithoutScrolling#MaxLength() - l:reservedColumns

    return EchoWithoutScrolling#TruncateTo( a:text, l:maxLength )
endfunction

function! EchoWithoutScrolling#Echo( text ) 
    echo EchoWithoutScrolling#Truncate( a:text )
endfunction
function! EchoWithoutScrolling#EchoWithHl( highlightGroup, text ) 
    if ! empty(a:highlightGroup)
	execute 'echohl' a:highlightGroup
    endif
    echo EchoWithoutScrolling#Truncate( a:text )
    echohl None
endfunction
function! EchoWithoutScrolling#EchoMsg( text ) 
    echomsg EchoWithoutScrolling#Truncate( a:text )
endfunction
function! EchoWithoutScrolling#EchoMsgWithHl( highlightGroup, text ) 
    if ! empty(a:highlightGroup)
	execute 'echohl' a:highlightGroup
    endif
    echomsg EchoWithoutScrolling#Truncate( a:text )
    echohl None
endfunction

function! EchoWithoutScrolling#TranslateLineBreaks( text )
"*******************************************************************************
"* PURPOSE:
"   Translate embedded line breaks in a:text into a printable characters to
"   avoid that a single-line string is split into multiple lines (and thus
"   broken over multiple lines or mostly obscured) by the :echo command and
"   EchoWithoutScrolling#Echo() functions. 
"
"   For the :echo command, strtrans() is not necessary; unprintable characters
"   are automatically translated (and shown in a different highlighting, an
"   advantage over indiscriminate preprocessing with strtrans()). However, :echo
"   observes embedded line breaks (in contrast to :echomsg), which would mess up
"   a single-line message that contains embedded \n = <CR> = ^M or <LF> = ^@. 
"
"   For the :echomsg and :echoerr commands, neither strtrans() nor this function
"   are necessary; all translation is done by the built-in command. 
"
"* LIMITATIONS:
"   When :echo'd, the translated line breaks are not rendered with the typical
"   'SpecialKey' highlighting. 
" 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:text	Text. 
"* RETURN VALUES: 
"   Text with translated line breaks; the text will :echo into a single line. 
"*******************************************************************************
    return substitute(a:text, "[\<CR>\<LF>]", '\=strtrans(submatch(0))', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
