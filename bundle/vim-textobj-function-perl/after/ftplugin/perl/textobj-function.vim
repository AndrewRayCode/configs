" Vim additional ftplugin: perl/textobj-function
" Version: 0.1.1
" Author : thinca <http://d.hatena.ne.jp/thinca/>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:textobj_function_perl_select')
  function! g:textobj_function_perl_select(object_type)
    return s:select_{a:object_type}()
  endfunction

  function! s:select_a()
    let c = v:count1
    let range = 0
    while c
      unlet! r
      let r = s:function_range()
      if type(r) == type(0)
        break
      endif

      call setpos('.', r[0])
      call s:left()

      unlet! range
      let range = r
      let c -= 1
    endwhile

    if type(range) == type([])
      let type = 'v'
      call setpos('.', range[0])
      if col('.') == 1 || getline('.')[:col('.') - 2] =~ '^\s*$'
        call setpos('.', range[1])
        if getline('.')[col('.'):] =~ '^\s*$'
          let type = 'V'
        endif
      endif
      let range = [type] + range
    endif
    return range
  endfunction


  function! s:select_i()
    let range = s:select_a()
    if type(range) == type(0)
      return 0
    endif

    let type = 'v'

    let endpos = range[2]
    call setpos('.', endpos)

    let linewise = 0
    if col('.') == 1 || getline('.')[:col('.') - 2] =~ '^\s*$'
      normal! k$
    let linewise = 1
    else
      call s:left()
    endif
    let e = getpos('.')

    call setpos('.', endpos)
    call s:jump_to_pair()

    if getline('.')[col('.'):] =~ '^\s*$'
      normal! j0
      if linewise
        let type = 'V'
      endif
    else
      normal! l
    endif
    let b = getpos('.')

    return [type, b, e]
  endfunction

  function! s:function_range()
    let start = getpos('.')
    while search('\<sub\>', 'bcW') != 0
      let b = getpos('.')

      call search('\v<sub>\s*\k*\s*.', 'ceW')
      if s:cursor_char() == '('
        call s:jump_to_pair()
      endif

      while s:cursor_char() != '{' || s:cursor_syn() ==# 'Comment'
        if search('{', 'W') == 0
          return 0
        endif
      endwhile
      call s:jump_to_pair()
      let e = getpos('.')

      if e[1] < start[1] || (e[1] == start[1] && e[2] < start[2])
        call setpos('.', b)
        call s:left()
        continue
      endif
      return [b, e]
    endwhile
    return 0
  endfunction

  function! s:jump_to_pair()
    normal %
  endfunction

  function! s:left()
    if col('.') == 1
      if line('.') != 1
        normal! k$
      endif
    else
      normal! h
    endif
  endfunction

  function! s:cursor_char()
    return getline('.')[col('.') - 1]
  endfunction

  function! s:cursor_syn()
    return synIDattr(synIDtrans(synID(line('.'), col('.'), 0)), 'name')
  endfunction
endif


let b:textobj_function_select = function('g:textobj_function_perl_select')



if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= ' | '
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'unlet b:textobj_function_select'


let &cpo = s:save_cpo
unlet s:save_cpo
