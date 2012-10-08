" CompleteHelper/Abbreviate.vim: Utility functions to shorten completion items.
"
" DEPENDENCIES:
"   - EchoWithoutScrolling.vim autoload script
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.10.002	05-May-2012	ENH: Offer full completion word in the preview
"				window when it is shown abbreviated. Clients get
"				this automatically when using
"				CompleteHelper#Abbreviate#Word().
"	001	04-May-2012	file creation from CompleteHelper.vim autoload
"				script

function! s:ListChar( settingFilter, fallback )
    let listchar = matchstr(&listchars, a:settingFilter)
    return (empty(listchar) ? a:fallback : listchar)
endfunction
let s:tabReplacement = s:ListChar('tab:\zs..', '^I')
let s:eolReplacement = s:ListChar('eol:\zs.', '^J') " Vim commands like :reg show newlines as ^J.
delfunction s:ListChar

function! CompleteHelper#Abbreviate#Translate( text )
    let l:text = substitute(a:text, '\t', s:tabReplacement, 'g')
    let l:text = substitute(l:text, "\n", s:eolReplacement, 'g')
    return l:text
endfunction
function! CompleteHelper#Abbreviate#Truncate( text )
    let l:maxDisplayLen = &columns / 2
    " Optimization: As <Tab> characters should already have been translated via
    " CompleteHelper#Abbreviate#Translate(), and it's unlikely to have lines
    " containing mostly unprintable ASCII characters like ^V, we can assume that
    " one display column is represented by at least one byte in the text (or
    " more, in case of non-ASCII characters). So if there are less bytes, we
    " don't need to bother with truncation.
    return (len(a:text) > l:maxDisplayLen ? EchoWithoutScrolling#TruncateTo(a:text, l:maxDisplayLen) : a:text)
endfunction
function! CompleteHelper#Abbreviate#Text( text )
"******************************************************************************
"* PURPOSE:
"   Shorten a:text and change (invisible) <Tab> and newline characters to what's
"   defined in 'listchars'.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text	    Completion match word or menu.
"* RETURN VALUES:
"   Potentially shortened text.
"******************************************************************************
    return CompleteHelper#Abbreviate#Truncate(CompleteHelper#Abbreviate#Translate(a:text))
endfunction

function! CompleteHelper#Abbreviate#Word( matchObj )
"******************************************************************************
"* PURPOSE:
"   Shorten the match abbreviation and change (invisible) <Tab> and newline
"   characters to what's defined in 'listchars'. Offer the full word for showing
"   in the preview window (with :set completeopt+=preview) when any information
"   is lost in the abbreviation.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:matchObj	    The match object to be returned to the completion function.
"* RETURN VALUES:
"   Possibly extended match object with 'abbr' and 'info' attributes.
"******************************************************************************
    let l:translatedWord = CompleteHelper#Abbreviate#Translate(a:matchObj.word)
    let l:abbr = CompleteHelper#Abbreviate#Truncate(l:translatedWord)
    if l:abbr !=# a:matchObj.word
	" Use an abbreviation in the popup menu.
	let a:matchObj.abbr = l:abbr

	" Don't count leading and trailing empty lines; these are shown just
	" fine through the translation of newlines.
	let l:hasInternalMultiLine = (a:matchObj.word =~# '\n\@!.\n\n\@!.')
	let l:wasTruncated = l:translatedWord !=# l:abbr
	if l:hasInternalMultiLine || l:wasTruncated
	    " Offer the full (possibly multi-line) word for showing in the preview
	    " window.
	    let a:matchObj.info = a:matchObj.word
	endif
    endif
    return a:matchObj
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
