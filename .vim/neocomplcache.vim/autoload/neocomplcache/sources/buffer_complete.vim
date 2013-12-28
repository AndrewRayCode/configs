"=============================================================================
" FILE: buffer_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 27 May 2013.
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

" Important variables.
if !exists('s:buffer_sources')
  let s:buffer_sources = {}
  let s:async_dictionary_list = {}
endif

let s:source = {
      \ 'name' : 'buffer_complete',
      \ 'kind' : 'manual',
      \ 'mark' : '[B]',
      \ 'rank' : 5,
      \ 'min_pattern_length' :
      \     g:neocomplcache_auto_completion_start_length,
      \ 'hooks' : {},
      \}

function! s:source.hooks.on_init(context) "{{{
  let s:buffer_sources = {}

  augroup neocomplcache "{{{
    " Caching events
    autocmd BufEnter,BufRead,BufWinEnter *
          \ call s:check_source()
    autocmd CursorHold,CursorHoldI *
          \ call s:check_cache()
    autocmd BufWritePost *
          \ call s:check_recache()
    autocmd InsertEnter,InsertLeave *
          \ call neocomplcache#sources#buffer_complete#caching_current_line()
  augroup END"}}}

  " Create cache directory.
  if !isdirectory(neocomplcache#get_temporary_directory() . '/buffer_cache')
    call mkdir(neocomplcache#get_temporary_directory() . '/buffer_cache', 'p')
  endif

  " Initialize script variables. "{{{
  let s:buffer_sources = {}
  let s:cache_line_count = 70
  let s:rank_cache_count = 1
  let s:disable_caching_list = {}
  let s:async_dictionary_list = {}
  "}}}

  call s:check_source()
endfunction
"}}}

function! s:source.hooks.on_final(context) "{{{
  delcommand NeoComplCacheCachingBuffer
  delcommand NeoComplCachePrintSource
  delcommand NeoComplCacheOutputKeyword
  delcommand NeoComplCacheDisableCaching
  delcommand NeoComplCacheEnableCaching

  let s:buffer_sources = {}
endfunction"}}}

function! s:source.gather_candidates(context) "{{{
  call s:check_source()

  let keyword_list = []
  for [key, source] in s:get_sources_list()
    call neocomplcache#cache#check_cache_list('buffer_cache',
          \ source.path, s:async_dictionary_list, source.keyword_cache, 1)

    let keyword_list += neocomplcache#dictionary_filter(
          \ source.keyword_cache, a:context.complete_str)
    if key == bufnr('%')
      let source.accessed_time = localtime()
    endif
  endfor

  return keyword_list
endfunction"}}}

function! neocomplcache#sources#buffer_complete#define() "{{{
  return s:source
endfunction"}}}

function! neocomplcache#sources#buffer_complete#get_frequencies() "{{{
  " Current line caching.
  return get(get(s:buffer_sources, bufnr('%'), {}), 'frequencies', {})
endfunction"}}}
function! neocomplcache#sources#buffer_complete#caching_current_line() "{{{
  " Current line caching.
  return s:caching_current_buffer(
        \ max([1, line('.') - 10]), min([line('.') + 10, line('$')]))
endfunction"}}}
function! neocomplcache#sources#buffer_complete#caching_current_block() "{{{
  " Current line caching.
  return s:caching_current_buffer(
          \ max([1, line('.') - 500]), min([line('.') + 500, line('$')]))
endfunction"}}}
function! s:caching_current_buffer(start, end) "{{{
  " Current line caching.

  if !s:exists_current_source()
    call s:word_caching(bufnr('%'))
  endif

  let source = s:buffer_sources[bufnr('%')]
  let keyword_pattern = source.keyword_pattern
  let keyword_pattern2 = '^\%('.keyword_pattern.'\m\)'
  let keywords = source.keyword_cache

  let completion_length = 2
  let line = join(getline(a:start, a:end))
  let match = match(line, keyword_pattern)
  while match >= 0 "{{{
    let match_str = matchstr(line, keyword_pattern2, match)

    " Ignore too short keyword.
    if len(match_str) >= g:neocomplcache_min_keyword_length "{{{
      " Check dup.
      let key = tolower(match_str[: completion_length-1])
      if !has_key(keywords, key)
        let keywords[key] = {}
      endif
      if !has_key(keywords[key], match_str)
        " Append list.
        let keywords[key][match_str] = match_str
        let source.frequencies[match_str] = 30
      endif
    endif"}}}

    " Next match.
    let match = match(line, keyword_pattern, match + len(match_str))
  endwhile"}}}
endfunction"}}}

function! s:get_sources_list() "{{{
  let sources_list = []

  let filetypes_dict = {}
  for filetype in neocomplcache#get_source_filetypes(
        \ neocomplcache#get_context_filetype())
    let filetypes_dict[filetype] = 1
  endfor

  for [key, source] in items(s:buffer_sources)
    if has_key(filetypes_dict, source.filetype)
          \ || has_key(filetypes_dict, '_')
          \ || bufnr('%') == key
          \ || (source.name ==# '[Command Line]' && bufnr('#') == key)
      call add(sources_list, [key, source])
    endif
  endfor

  return sources_list
endfunction"}}}

function! s:initialize_source(srcname) "{{{
  let path = fnamemodify(bufname(a:srcname), ':p')
  let filename = fnamemodify(path, ':t')
  if filename == ''
    let filename = '[No Name]'
    let path .= '/[No Name]'
  endif

  let ft = getbufvar(a:srcname, '&filetype')
  if ft == ''
    let ft = 'nothing'
  endif

  let buflines = getbufline(a:srcname, 1, '$')
  let keyword_pattern = neocomplcache#get_keyword_pattern(ft)

  let s:buffer_sources[a:srcname] = {
        \ 'keyword_cache' : {},
        \ 'frequencies' : {},
        \ 'name' : filename, 'filetype' : ft,
        \ 'keyword_pattern' : keyword_pattern,
        \ 'end_line' : len(buflines),
        \ 'accessed_time' : 0,
        \ 'cached_time' : 0,
        \ 'path' : path, 'loaded_cache' : 0,
        \ 'cache_name' : neocomplcache#cache#encode_name(
        \   'buffer_cache', path),
        \}
endfunction"}}}

function! s:word_caching(srcname) "{{{
  " Initialize source.
  call s:initialize_source(a:srcname)

  let source = s:buffer_sources[a:srcname]

  if !filereadable(source.path)
        \ || getbufvar(a:srcname, '&buftype') =~ 'nofile'
    return
  endif

  let source.cache_name =
        \ neocomplcache#cache#async_load_from_file(
        \     'buffer_cache', source.path,
        \     source.keyword_pattern, 'B')
  let source.cached_time = localtime()
  let source.end_line = len(getbufline(a:srcname, 1, '$'))
  let s:async_dictionary_list[source.path] = [{
        \ 'filename' : source.path,
        \ 'cachename' : source.cache_name,
        \ }]
endfunction"}}}

function! s:check_changed_buffer(bufnumber) "{{{
  let source = s:buffer_sources[a:bufnumber]

  let ft = getbufvar(a:bufnumber, '&filetype')
  if ft == ''
    let ft = 'nothing'
  endif

  let filename = fnamemodify(bufname(a:bufnumber), ':t')
  if filename == ''
    let filename = '[No Name]'
  endif

  return s:buffer_sources[a:bufnumber].name != filename
        \ || s:buffer_sources[a:bufnumber].filetype != ft
endfunction"}}}

function! s:check_source() "{{{
  if !s:exists_current_source()
    call neocomplcache#sources#buffer_complete#caching_current_block()
    return
  endif

  for bufnumber in range(1, bufnr('$'))
    " Check new buffer.
    let bufname = fnamemodify(bufname(bufnumber), ':p')
    if (!has_key(s:buffer_sources, bufnumber)
          \ || s:check_changed_buffer(bufnumber))
          \ && !has_key(s:disable_caching_list, bufnumber)
          \ && (!neocomplcache#is_locked(bufnumber) ||
          \    g:neocomplcache_disable_auto_complete)
          \ && !getwinvar(bufwinnr(bufnumber), '&previewwindow')
          \ && getfsize(bufname) <
          \      g:neocomplcache_caching_limit_file_size
      " Caching.
      call s:word_caching(bufnumber)
    endif

    if has_key(s:buffer_sources, bufnumber)
      let source = s:buffer_sources[bufnumber]
      call neocomplcache#cache#check_cache_list('buffer_cache',
            \ source.path, s:async_dictionary_list, source.keyword_cache, 1)
    endif
  endfor
endfunction"}}}
function! s:check_cache() "{{{
  let release_accessd_time =
        \ localtime() - g:neocomplcache_release_cache_time

  for [key, source] in items(s:buffer_sources)
    " Check deleted buffer and access time.
    if !bufloaded(str2nr(key))
          \ || (source.accessed_time > 0 &&
          \ source.accessed_time < release_accessd_time)
      " Remove item.
      call remove(s:buffer_sources, key)
    endif
  endfor
endfunction"}}}
function! s:check_recache() "{{{
  if !s:exists_current_source()
    return
  endif

  let release_accessd_time =
        \ localtime() - g:neocomplcache_release_cache_time

  let source = s:buffer_sources[bufnr('%')]

  " Check buffer access time.
  if (source.cached_time > 0 && source.cached_time < release_accessd_time)
        \  || (neocomplcache#util#has_vimproc() && line('$') != source.end_line)
    " Buffer recache.
    if g:neocomplcache_enable_debug
      echomsg 'Caching buffer: ' . bufname('%')
    endif

    call neocomplcache#sources#buffer_complete#caching_current_block()
  endif
endfunction"}}}

function! s:exists_current_source() "{{{
  return has_key(s:buffer_sources, bufnr('%'))
endfunction"}}}

" Command functions. "{{{
function! neocomplcache#sources#buffer_complete#caching_buffer(name) "{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      let bufnr = bufnr('%')

      " No swap warning.
      let save_shm = &shortmess
      set shortmess+=A

      " Open new buffer.
      execute 'silent! edit' fnameescape(a:name)

      let &shortmess = save_shm

      if bufnr('%') != bufnr
        setlocal nobuflisted
        execute 'buffer' bufnr
      endif
    endif

    let number = bufnr(a:name)
  endif

  " Word recaching.
  call s:word_caching(number)
  call s:caching_current_buffer(1, line('$'))
endfunction"}}}
function! neocomplcache#sources#buffer_complete#print_source(name) "{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  if !has_key(s:buffer_sources, number)
    return
  endif

  silent put=printf('Print neocomplcache %d source.', number)
  for key in keys(s:buffer_sources[number])
    silent put =printf('%s => %s', key, string(s:buffer_sources[number][key]))
  endfor
endfunction"}}}
function! neocomplcache#sources#buffer_complete#output_keyword(name) "{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  if !has_key(s:buffer_sources, number)
    return
  endif

  " Output buffer.
  for keyword in neocomplcache#unpack_dictionary(
        \ s:buffer_sources[number].keyword_cache)
    silent put=string(keyword)
  endfor
endfunction "}}}
function! neocomplcache#sources#buffer_complete#disable_caching(name) "{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  let s:disable_caching_list[number] = 1

  if has_key(s:buffer_sources, number)
    " Delete source.
    call remove(s:buffer_sources, number)
  endif
endfunction"}}}
function! neocomplcache#sources#buffer_complete#enable_caching(name) "{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  if has_key(s:disable_caching_list, number)
    call remove(s:disable_caching_list, number)
  endif
endfunction"}}}
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
