" Run perl, python, ruby, bash, etc. scripts from within vim.
" Maintainer: Naveed Massjouni <https://github.com/ironcamel/vim-script-runner>
" Version: 0.0.1

if !exists('g:script_runner_key')
    let g:script_runner_key = '<F5>'
endif
execute "nnoremap ".g:script_runner_key." :call Run(&ft)<CR>"
cabbrev sx call Run(&ft)
cabbrev pyx call Run('python')
cabbrev perlx call Run('perl')
cabbrev rubyx call Run('ruby')

let s:ft_cmd = {
    \'json' : 'json_pp',
    \'xml'  : 'xmllint --format -',
\}

autocmd BufEnter *.json set ft=json

fu! NewThrowawayBuffer()
    new
    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    map <buffer> q :quit<CR>
endf

fu! Run(cmd)
    let s:real_cmd = a:cmd

    if(exists("g:script_runner_".a:cmd))
        " Use the users custom setting
        execute "let s:real_cmd = g:script_runner_".a:cmd
    elseif(has_key(s:ft_cmd, a:cmd))
        " Use our default, if there is one
        let s:real_cmd = s:ft_cmd[a:cmd]
    endif

    only
    %y
    call NewThrowawayBuffer()
    wincmd J
    resize 15
    0 put
    exe '%!' . s:real_cmd
    0 read !date
    append
----------------------------
.
    wincmd w
endf
