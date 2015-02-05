function! test#cucumber#test_file(file) abort
  return a:file =~# '\.feature$'
endfunction

function! test#cucumber#build_position(type, position) abort
  if a:type == 'nearest'
    return [a:position['file'].':'.a:position['line']]
  elseif a:type == 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction

function! test#cucumber#build_args(args) abort
  return a:args
endfunction

function! test#cucumber#executable() abort
  if filereadable('.zeus.sock')
    return 'zeus cucumber'
  elseif filereadable('bin/cucumber')
    return './bin/cucumber'
  elseif filereadable('Gemfile')
    return 'bundle exec cucumber'
  else
    return 'cucumber'
  endif
endfunction
