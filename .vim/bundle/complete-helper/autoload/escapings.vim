" escapings.vim: Common escapings of filenames, and wrappers around new Vim 7.2
" fnameescape() and shellescape() functions. 
"
" Copyright: (C) 2009-2010 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	011	05-Apr-2010	Added escapings#shellcmdescape(). 
"	010	12-Feb-2010	BUG: Emulation of shellescape(..., {special})
"				escaped wrong characters (e.g. ' \<[') via
"				fnameescape() and the escaping was done
"				inconsistently though only 9 lines apart.
"				Corrected and factored out the characters into
"				l:specialShellescapeCharacters. 
"	009	27-Aug-2009	BF: Characters '[{$' must not be escaped on
"				Windows. Adapted pattern in
"				escapings#fnameescape() and
"				escapings#fnameunescape(). (This caused
"				ingobuffer#MakeScratchBuffer() to create an "foo
"				\[Scratch]" buffer on an unpatched Vim 7.1.) 
"	008	19-Aug-2009	BF: escapings#shellescape() caused E118 on Vim
"				7.1. The shellescape({string}) function exists
"				since Vim 7.0.111, but shellescape({string},
"				{special}) was only introduced with Vim 7.2. 
"				Now calling the one-argument function if no
"				{special} argument, and (crudely) emulating the
"				two-argument function for Vim versions that only
"				have the one-argument function. 
"	007	27-May-2009	escapings#bufnameescape() now automatically
"				expands a:filespec to the required full absolute
"				filespec in the (default) full match mode. 
"				BF: ',' must not be escaped in
"				escapings#bufnameescape(); it only has special
"				meaning inside { }, which never occurs in the
"				escaped pattern. 
"	006	26-May-2009	escapings#fnameescape() emulation part now works
"				like fnameescape() on Windows: Instead of
"				converting backslashes to forward slashes, they
"				are not escaped. (But on non-Windows systems,
"				they are.) 
"				Added and refined escapings#fnameunescape() from
"				dropquery.vim. 
"	005	02-Mar-2009	Now explicitly checking for the new escape
"				functions instead of assuming they're in Vim 7.2
"				so that users of a patched Vim 7.1 also get the
"				benefit of them. 
"	004	25-Feb-2009	Now using character list from ':help
"				fnameescape()' (plus converting \ to /). 
"	003	17-Feb-2009	Added optional a:isFullMatch argument to
"				escapings#bufnameescape(). 
"				Cleaned up documentation. 
"	002	05-Feb-2009	Added improved version of escapings#exescape()
"				that relies on fnameescape() to properly escape
"				all special Ex characters. 
"	001	05-Jan-2009	file creation

function! s:IsWindowsLike()
    return has('dos16') || has('dos32') || has('win95') || has('win32') || has('win64')
endfunction

function! escapings#bufnameescape( filespec, ... )
"*******************************************************************************
"* PURPOSE:
"   Escape a normal filespec syntax so that it can be used for the bufname(),
"   bufnr(), bufwinnr(), ... commands. 
"   Ensure that there are no double (back-/forward) slashes inside the path; the
"   anchored pattern doesn't match in those cases! 
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec	    normal filespec
"   a:isFullMatch   Optional flag whether only the full filespec should be
"		    matched (default=1). If 0, the escaped filespec will not be
"		    anchored. 
"* RETURN VALUES: 
"   Filespec escaped for the buf...() commands. 
"*******************************************************************************
    let l:isFullMatch = (a:0 ? a:1 : 1)

    " For a full match, the passed a:filespec must be converted to a full
    " absolute path (with symlinks resolved, just like Vim does on opening a
    " file) in order to match. 
    let l:escapedFilespec = (l:isFullMatch ? resolve(fnamemodify(a:filespec, ':p')) : a:filespec)

    " Backslashes are converted to forward slashes, as the comparison is done with
    " these on all platforms, anyway (cp. :help file-pattern). 
    let l:escapedFilespec = tr(l:escapedFilespec, '\', '/')

    " Special file-pattern characters must be escaped: [ escapes to [[], not \[.
    let l:escapedFilespec = substitute(l:escapedFilespec, '[\[\]]', '[\0]', 'g')

    " The special filenames '#' and '%' need not be escaped when they are anchored
    " or occur within a longer filespec. 
    let l:escapedFilespec = escape(l:escapedFilespec, '?*')

    " I didn't find any working escaping for {, so it is replaced with the ?
    " wildcard. 
    let l:escapedFilespec = substitute(l:escapedFilespec, '[{}]', '?', 'g')

    if l:isFullMatch
	" The filespec must be anchored to ^ and $ to avoid matching filespec
	" fragments. 
	return '^' . l:escapedFilespec . '$'
    else
	return l:escapedFilespec
    endif
endfunction

function! escapings#exescape( command )
"*******************************************************************************
"* PURPOSE:
"   Escape a shell command (potentially consisting of multiple commands and
"   including (already quoted) command-line arguments) so that it can be used in
"   ex commands. For example: 'hostname && ps -ef | grep -e "foo"'. 
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:command	    Shell command-line. 
"
"* RETURN VALUES: 
"   Escaped shell command to be passed to the !{cmd} or :r !{cmd} commands. 
"*******************************************************************************
    if exists('*fnameescape')
	return join(map(split(a:command, ' '), 'fnameescape(v:val)'), ' ')
    else
	return escape(a:command, '\%#|' )
    endif
endfunction

function! escapings#fnameescape( filespec )
"*******************************************************************************
"* PURPOSE:
"   Escape a normal filespec syntax so that it can be used in ex commands. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec	    normal filespec
"* RETURN VALUES: 
"   Escaped filespec to be passed as a {file} argument to an ex command. 
"*******************************************************************************
    if exists('*fnameescape')
	return fnameescape(a:filespec)
    else
	" Note: On Windows, backslash path separators and some other Unix
	" shell-specific characters mustn't be escaped. 
	return escape(a:filespec, " \t\n*?`%#'\"|!<" . (s:IsWindowsLike() ? '' : '[{$\'))
    endif
endfunction

function! escapings#fnameunescape( exfilespec, ... )
"*******************************************************************************
"* PURPOSE:
"   Converts the passed a:exfilespec to the normal filespec syntax (i.e. no
"   escaping of ex special chars like [%#]). The normal syntax is required by
"   Vim functions such as filereadable(), because they do not understand the
"   escaping for ex commands. 
"   Note: On Windows, fnamemodify() doesn't convert path separators to
"   backslashes. We don't force that neither, as forward slashes work just as
"   well and there is even less potential for problems. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:exfilespec    Escaped filespec to be passed as a {file} argument to an ex
"		    command.
"   a:isMakeFullPath	Flag whether the filespec should also be expanded to a
"			full path, or kept in whatever form it currently is. 
"* RETURN VALUES: 
"   Unescaped, normal filespec. 
"*******************************************************************************
    let l:isMakeFullPath = (a:0 ? a:1 : 0)
    return fnamemodify( a:exfilespec, ':gs+\\\([ \t\n*?`%#''"|!<' . (s:IsWindowsLike() ? '' : '[{$\') . ']\)+\1+' . (l:isMakeFullPath ? ':p' : ''))
endfunction

function! escapings#shellescape( filespec, ... )
"*******************************************************************************
"* PURPOSE:
"   Escape a normal filespec syntax so that it can be used in shell commands. 
"   The filespec will be quoted properly. 
"   When the {special} argument is present and it's a non-zero Number, then
"   special items such as "!", "%", "#" and "<cword>" will be preceded by a
"   backslash.  This backslash will be removed again by the |:!| command.
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec	    normal filespec
"   a:special	    Flag whether special items will be escaped, too. 
"
"* RETURN VALUES: 
"   Escaped filespec to be used in a :! command or inside a system() call. 
"*******************************************************************************
    let l:isSpecial = (a:0 ? a:1 : 0)
    let l:specialShellescapeCharacters = "\n%#'!"
    if exists('*shellescape')
	if a:0
	    if v:version < 702
		" The shellescape({string}) function exists since Vim 7.0.111,
		" but shellescape({string}, {special}) was only introduced with
		" Vim 7.2. Emulate the two-argument function by (crudely)
		" escaping special characters for the :! command. 
		return shellescape((l:isSpecial ? escape(a:filespec, l:specialShellescapeCharacters) : a:filespec))
	    else
		return shellescape(a:filespec, l:isSpecial)
	    endif
	else
	    return shellescape(a:filespec)
	endif
    else
	let l:escapedFilespec = (l:isSpecial ? escape(a:filespec, l:specialShellescapeCharacters) : a:filespec)

	if s:IsWindowsLike()
	    return '"' . l:escapedFilespec . '"'
	else
	    return "'" . l:escapedFilespec . "'"
	endif
    endif
endfunction

function! escapings#shellcmdescape( command )
"******************************************************************************
"* PURPOSE:
"   Wrap the entire a:command in double quotes on Windows. 
"   This is necessary when passing a command to cmd.exe which has arguments that
"   are enclosed in double quotes, e.g. 
"	""%SystemRoot%\system32\dir.exe" /B "%ProgramFiles%"". 
"
"* EXAMPLE:
"   execute '!' escapings#shellcmdescape(escapings#shellescape($ProgramFiles .
"   '/foobar/foo.exe', 1) . ' ' . escapings#shellescape(args, 1))
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:command	    Single shell command, with optional arguments. 
"		    The shell command should already have been escaped via
"		    shellescape(). 
"* RETURN VALUES: 
"   Escaped command to be used in a :! command or inside a system() call. 
"******************************************************************************
    return (s:IsWindowsLike() ? '"' . a:command . '"' : a:command)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
