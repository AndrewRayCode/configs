"=============================================================================
" FILE: helper.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 04 Jun 2013.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! neocomplcache#helper#get_cur_text() "{{{
  let cur_text =
        \ (mode() ==# 'i' ? (col('.')-1) : col('.')) >= len(getline('.')) ?
        \      getline('.') :
        \      matchstr(getline('.'),
        \         '^.*\%' . col('.') . 'c' . (mode() ==# 'i' ? '' : '.'))

  if cur_text =~ '^.\{-}\ze\S\+$'
    let complete_str = matchstr(cur_text, '\S\+$')
    let cur_text = matchstr(cur_text, '^.\{-}\ze\S\+$')
  else
    let complete_str = ''
  endif

  let neocomplcache = neocomplcache#get_current_neocomplcache()
  if neocomplcache.event ==# 'InsertCharPre'
    let complete_str .= v:char
  endif

  let filetype = neocomplcache#get_context_filetype()
  let wildcard = get(g:neocomplcache_wildcard_characters, filetype,
        \ get(g:neocomplcache_wildcard_characters, '_', '*'))
  if g:neocomplcache_enable_wildcard &&
        \ wildcard !=# '*' && len(wildcard) == 1
    " Substitute wildcard character.
    while 1
      let index = stridx(complete_str, wildcard)
      if index <= 0
        break
      endif

      let complete_str = complete_str[: index-1]
            \ . '*' . complete_str[index+1: ]
    endwhile
  endif

  let neocomplcache.cur_text = cur_text . complete_str

  " Save cur_text.
  return neocomplcache.cur_text
endfunction"}}}

function! neocomplcache#helper#keyword_escape(complete_str) "{{{
  " Fuzzy completion.
  let keyword_len = len(a:complete_str)
  let keyword_escape = s:keyword_escape(a:complete_str)
  if g:neocomplcache_enable_fuzzy_completion
        \ && (g:neocomplcache_fuzzy_completion_start_length
        \          <= keyword_len && keyword_len < 20)
    let pattern = keyword_len >= 8 ?
          \ '\0\\w*' : '\\%(\0\\w*\\|\U\0\E\\l*\\)'

    let start = g:neocomplcache_fuzzy_completion_start_length
    if start <= 1
      let keyword_escape =
            \ substitute(keyword_escape, '\w', pattern, 'g')
    elseif keyword_len < 8
      let keyword_escape = keyword_escape[: start - 2]
            \ . substitute(keyword_escape[start-1 :], '\w', pattern, 'g')
    else
      let keyword_escape = keyword_escape[: 3] .
            \ substitute(keyword_escape[4:12], '\w',
            \   pattern, 'g') . keyword_escape[13:]
    endif
  else
    " Underbar completion. "{{{
    if g:neocomplcache_enable_underbar_completion
          \ && keyword_escape =~ '[^_]_\|^_'
      let keyword_escape = substitute(keyword_escape,
            \ '\%(^\|[^_]\)\zs_', '[^_]*_', 'g')
    endif
    if g:neocomplcache_enable_underbar_completion
          \ && '-' =~ '\k' && keyword_escape =~ '[^-]-'
      let keyword_escape = substitute(keyword_escape,
            \ '[^-]\zs-', '[^-]*-', 'g')
    endif
    "}}}
    " Camel case completion. "{{{
    if g:neocomplcache_enable_camel_case_completion
          \ && keyword_escape =~ '\u\?\U*'
      let keyword_escape =
            \ substitute(keyword_escape,
            \ '\u\?\zs\U*',
            \ '\\%(\0\\l*\\|\U\0\E\\u*_\\?\\)', 'g')
    endif
    "}}}
  endif

  call neocomplcache#print_debug(keyword_escape)
  return keyword_escape
endfunction"}}}

function! neocomplcache#helper#is_omni_complete(cur_text) "{{{
  " Check eskk complete length.
  if neocomplcache#is_eskk_enabled()
        \ && exists('g:eskk#start_completion_length')
    if !neocomplcache#is_eskk_convertion(a:cur_text)
          \ || !neocomplcache#is_multibyte_input(a:cur_text)
      return 0
    endif

    let complete_pos = call(&l:omnifunc, [1, ''])
    let complete_str = a:cur_text[complete_pos :]
    return neocomplcache#util#mb_strlen(complete_str) >=
          \ g:eskk#start_completion_length
  endif

  let filetype = neocomplcache#get_context_filetype()
  let omnifunc = get(g:neocomplcache_omni_functions,
        \ filetype, &l:omnifunc)

  if neocomplcache#check_invalid_omnifunc(omnifunc)
    return 0
  endif

  let syn_name = neocomplcache#helper#get_syn_name(1)
  if syn_name ==# 'Comment' || syn_name ==# 'String'
    " Skip omni_complete in string literal.
    return 0
  endif

  if has_key(g:neocomplcache_force_omni_patterns, omnifunc)
    let pattern = g:neocomplcache_force_omni_patterns[omnifunc]
  elseif filetype != '' &&
        \ get(g:neocomplcache_force_omni_patterns, filetype, '') != ''
    let pattern = g:neocomplcache_force_omni_patterns[filetype]
  else
    return 0
  endif

  if a:cur_text !~# '\%(' . pattern . '\m\)$'
    return 0
  endif

  " Set omnifunc.
  let &omnifunc = omnifunc

  return 1
endfunction"}}}

function! neocomplcache#helper#is_enabled_source(source_name) "{{{
  if neocomplcache#is_disabled_source(a:source_name)
    return 0
  endif

  let neocomplcache = neocomplcache#get_current_neocomplcache()
  if !has_key(neocomplcache, 'sources')
    call neocomplcache#helper#get_sources_list()
  endif

  return index(keys(neocomplcache.sources), a:source_name) >= 0
endfunction"}}}

function! neocomplcache#helper#get_source_filetypes(filetype) "{{{
  let filetype = (a:filetype == '') ? 'nothing' : a:filetype

  let filetype_dict = {}

  let filetypes = [filetype]
  if filetype =~ '\.'
    if exists('g:neocomplcache_ignore_composite_filetype_lists')
          \ && has_key(g:neocomplcache_ignore_composite_filetype_lists, filetype)
      let filetypes = [g:neocomplcache_ignore_composite_filetype_lists[filetype]]
    else
      " Set composite filetype.
      let filetypes += split(filetype, '\.')
    endif
  endif

  if exists('g:neocomplcache_same_filetype_lists')
    for ft in copy(filetypes)
      let filetypes += split(get(g:neocomplcache_same_filetype_lists, ft,
            \ get(g:neocomplcache_same_filetype_lists, '_', '')), ',')
    endfor
  endif

  return neocomplcache#util#uniq(filetypes)
endfunction"}}}

function! neocomplcache#helper#get_completion_length(plugin_name) "{{{
  " Todo.
endfunction"}}}

function! neocomplcache#helper#complete_check() "{{{
  let neocomplcache = neocomplcache#get_current_neocomplcache()
  if g:neocomplcache_enable_debug
    echomsg split(reltimestr(reltime(neocomplcache.start_time)))[0]
  endif
  let ret = (!neocomplcache#is_prefetch() && complete_check())
        \ || (neocomplcache#is_auto_complete()
        \     && g:neocomplcache_skip_auto_completion_time != ''
        \     && split(reltimestr(reltime(neocomplcache.start_time)))[0] >
        \          g:neocomplcache_skip_auto_completion_time)
  if ret
    let neocomplcache = neocomplcache#get_current_neocomplcache()
    let neocomplcache.skipped = 1

    redraw
    echo 'Skipped.'
  endif

  return ret
endfunction"}}}

function! neocomplcache#helper#get_syn_name(is_trans) "{{{
  return len(getline('.')) < 200 ?
        \ synIDattr(synIDtrans(synID(line('.'), mode() ==# 'i' ?
        \          col('.')-1 : col('.'), a:is_trans)), 'name') : ''
endfunction"}}}

function! neocomplcache#helper#match_word(cur_text, ...) "{{{
  let pattern = a:0 >= 1 ? a:1 : neocomplcache#get_keyword_pattern_end()

  " Check wildcard.
  let complete_pos = s:match_wildcard(
        \ a:cur_text, pattern, match(a:cur_text, pattern))

  let complete_str = (complete_pos >=0) ?
        \ a:cur_text[complete_pos :] : ''

  return [complete_pos, complete_str]
endfunction"}}}

function! neocomplcache#helper#filetype_complete(arglead, cmdline, cursorpos) "{{{
  " Dup check.
  let ret = {}
  for item in map(
        \ split(globpath(&runtimepath, 'syntax/*.vim'), '\n') +
        \ split(globpath(&runtimepath, 'indent/*.vim'), '\n') +
        \ split(globpath(&runtimepath, 'ftplugin/*.vim'), '\n')
        \ , 'fnamemodify(v:val, ":t:r")')
    if !has_key(ret, item) && item =~ '^'.a:arglead
      let ret[item] = 1
    endif
  endfor

  return sort(keys(ret))
endfunction"}}}

function! neocomplcache#helper#unite_patterns(pattern_var, filetype) "{{{
  let keyword_patterns = []
  let dup_check = {}

  " Composite filetype.
  for ft in split(a:filetype, '\.')
    if has_key(a:pattern_var, ft) && !has_key(dup_check, ft)
      let dup_check[ft] = 1
      call add(keyword_patterns, a:pattern_var[ft])
    endif

    " Same filetype.
    if has_key(g:neocomplcache_same_filetype_lists, ft)
      for ft in split(g:neocomplcache_same_filetype_lists[ft], ',')
        if has_key(a:pattern_var, ft) && !has_key(dup_check, ft)
          let dup_check[ft] = 1
          call add(keyword_patterns, a:pattern_var[ft])
        endif
      endfor
    endif
  endfor

  if empty(keyword_patterns)
    let default = get(a:pattern_var, '_', get(a:pattern_var, 'default', ''))
    if default != ''
      call add(keyword_patterns, default)
    endif
  endif

  return join(keyword_patterns, '\m\|')
endfunction"}}}

function! neocomplcache#helper#ftdictionary2list(dictionary, filetype) "{{{
  let list = []
  for filetype in neocomplcache#get_source_filetypes(a:filetype)
    if has_key(a:dictionary, filetype)
      call add(list, a:dictionary[filetype])
    endif
  endfor

  return list
endfunction"}}}

function! neocomplcache#helper#get_sources_list(...) "{{{
  let filetype = neocomplcache#get_context_filetype()

  let source_names = exists('b:neocomplcache_sources_list') ?
        \ b:neocomplcache_sources_list :
        \ get(a:000, 0,
        \   get(g:neocomplcache_sources_list, filetype,
        \     get(g:neocomplcache_sources_list, '_', ['_'])))
  let disabled_sources = get(
        \ g:neocomplcache_disabled_sources_list, filetype,
        \   get(g:neocomplcache_disabled_sources_list, '_', []))
  call neocomplcache#init#_sources(source_names)

  let all_sources = neocomplcache#available_sources()
  let sources = {}
  for source_name in source_names
    if source_name ==# '_'
      " All sources.
      let sources = all_sources
      break
    endif

    if !has_key(all_sources, source_name)
      call neocomplcache#print_warning(printf(
            \ 'Invalid source name "%s" is given.', source_name))
      continue
    endif

    let sources[source_name] = all_sources[source_name]
  endfor

  let neocomplcache = neocomplcache#get_current_neocomplcache()
  let neocomplcache.sources = filter(sources, "
        \ index(disabled_sources, v:val.name) < 0 &&
        \   (empty(v:val.filetypes) ||
        \    get(v:val.filetypes, neocomplcache.context_filetype, 0))")

  return neocomplcache.sources
endfunction"}}}

function! neocomplcache#helper#clear_result() "{{{
  let neocomplcache = neocomplcache#get_current_neocomplcache()

  let neocomplcache.complete_str = ''
  let neocomplcache.candidates = []
  let neocomplcache.complete_results = []
  let neocomplcache.complete_pos = -1
endfunction"}}}

function! neocomplcache#helper#call_hook(sources, hook_name, context) "{{{
  for source in neocomplcache#util#convert2list(a:sources)
    try
      if !has_key(source.hooks, a:hook_name)
        if a:hook_name ==# 'on_init' && has_key(source, 'initialize')
          call source.initialize()
        elseif a:hook_name ==# 'on_final' && has_key(source, 'finalize')
          call source.finalize()
        endif
      else
        call call(source.hooks[a:hook_name],
              \ [extend(source.neocomplcache__context, a:context)],
              \ source.hooks)
      endif
    catch
      call unite#print_error(v:throwpoint)
      call unite#print_error(v:exception)
      call unite#print_error(
            \ '[unite.vim] Error occured in calling hook "' . a:hook_name . '"!')
      call unite#print_error(
            \ '[unite.vim] Source name is ' . source.name)
    endtry
  endfor
endfunction"}}}

function! neocomplcache#helper#call_filters(filters, source, context) "{{{
  let context = extend(a:source.neocomplcache__context, a:context)
  let _ = []
  for filter in neocomplcache#init#_filters(
        \ neocomplcache#util#convert2list(a:filters))
    try
      let context.candidates = call(filter.filter, [context], filter)
    catch
      call unite#print_error(v:throwpoint)
      call unite#print_error(v:exception)
      call unite#print_error(
            \ '[unite.vim] Error occured in calling filter '
            \   . filter.name . '!')
      call unite#print_error(
            \ '[unite.vim] Source name is ' . a:source.name)
    endtry
  endfor

  return context.candidates
endfunction"}}}

function! s:match_wildcard(cur_text, pattern, complete_pos) "{{{
  let complete_pos = a:complete_pos
  while complete_pos > 1 && a:cur_text[complete_pos - 1] == '*'
    let left_text = a:cur_text[: complete_pos - 2]
    if left_text == '' || left_text !~ a:pattern
      break
    endif

    let complete_pos = match(left_text, a:pattern)
  endwhile

  return complete_pos
endfunction"}}}

function! s:keyword_escape(complete_str) "{{{
  let keyword_escape = escape(a:complete_str, '~" \.^$[]')
  if g:neocomplcache_enable_wildcard
    let keyword_escape = substitute(
          \ substitute(keyword_escape, '.\zs\*', '.*', 'g'),
          \ '\%(^\|\*\)\zs\*', '\\*', 'g')
  else
    let keyword_escape = escape(keyword_escape, '*')
  endif

  return keyword_escape
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
