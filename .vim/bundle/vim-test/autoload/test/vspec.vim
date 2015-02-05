function! test#vspec#test_file(file) abort
  return a:file =~# '\v^(t(est)?|spec)/.*\.vim$'
endfunction

function! test#vspec#build_position(type, position) abort
  if a:type == 'nearest' || a:type == 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction

function! test#vspec#build_args(args) abort
  if empty(filter(copy(a:args), 'test#file_exists(v:val)'))
    let test_dir = get(filter(['t/', 'test/', 'spec/'], 'isdirectory(v:val)'), 0)
    call add(a:args, test_dir)
  endif

  return a:args
endfunction

function! test#vspec#executable() abort
  if !executable('vim-flavor')
    throw '"vim-flavor" executable not found, get it with `gem install vim-flavor`'
  endif

  if filereadable('bin/vim-flavor')
    return 'bin/vim-flavor test'
  elseif filereadable('Gemfile')
    return 'bundle exec vim-flavor test'
  else
    return 'vim-flavor test'
  endif
endfunction
