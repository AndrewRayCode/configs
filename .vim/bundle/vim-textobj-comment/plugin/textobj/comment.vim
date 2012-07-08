" Text objects for a comment.
" Version: 0.2.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License


if exists('g:loaded_textobj_comment')  "{{{1
  finish
endif
let g:loaded_textobj_comment = 1


let s:save_cpo = &cpo
set cpo&vim


" Interface  "{{{1
call textobj#user#plugin('comment', {
\      '-': {
\        '*sfile*': expand('<sfile>:p'),
\        'select-a': 'ac',  '*select-a-function*': 's:select_a',
\        'select-i': 'ic',  '*select-i-function*': 's:select_i',
\      }
\    })


" Functions.  "{{{1
function! s:select_a()
  call search('^\s*\%#\s*\S', 'eW')
  if !s:is_comment()
    return 0
  endif

  let c = getpos('.')
  let [b, e] = [c, c]

  let [save_ww, save_lz] = [&whichwrap, &lazyredraw]
  set whichwrap=h,l lazyredraw

  while line('.') != 1 || col('.') != 1
    normal! h
    if !s:is_comment()
      normal! l
      if search('.\n\s*\%#', 'bW')
        if s:is_comment()
          continue
        endif
      endif
      break
    endif
    let b = getpos('.')
  endwhile

  call setpos('.', c)

  let btm = line('$')
  while line('.') != btm || col('.') != col('$') - 1
    normal! l
    if !s:is_comment()
      normal! h
      if search('\%#.\n\s*\S', 'eW')
        if s:is_comment()
          continue
        endif
      endif
      break
    endif
    let e = getpos('.')
  endwhile

  let wise = s:judge_wise(b, e)
  let [&whichwrap, &lazyredraw] = [save_ww, save_lz]

  return [wise, b, e]
endfunction

function! s:select_i()
  let outer = s:select_a()
  if type(outer) == type(0)
    return 0
  endif
  let [b, e] = outer[1:]

  call setpos('.', b)
  call search('\_s\zs\S', 'W')
  let _ = getpos('.')
  if s:cmp_pos(_, e) < 0
    let b = _
  endif

  call setpos('.', e)
  call search('\S\ze\_s', 'bW')
  let _ = getpos('.')
  if s:cmp_pos(b, _) < 0
    let e = _
  endif

  let wise = s:judge_wise(b, e)
  return [wise, b, e]
endfunction

function! s:is_comment()
  for id in synstack(line('.'), col('.'))
    if synIDattr(synIDtrans(id), 'name') ==# 'Comment'
      return 1
    endif
  endfor
  return 0
endfunction

function! s:cmp_pos(a, b)
  for i in range(1, 3)
    if a:a[i] < a:b[i]
      return -1
    elseif a:a[i] > a:b[i]
      return 1
    endif
  endfor
  return 0
endfunction

function! s:judge_wise(b, e)
  return
  \ getline(a:b[1])[: a:b[2] - 1] =~# '^\s*.$' &&
  \ getline(a:e[1])[a:e[2] - 1 :] =~# '^.\s*$' ? 'V' : 'v'
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
