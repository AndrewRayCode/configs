
" Open vim's bundle directory when clicked.
"
fun! s:init()
    let Class = clickable#class#init()
    let File = clickable#class#file#init()


    let s:bundle_pattern = '\v%(^\s*%(Neo)=Bundle\s+)\@='
                \ .'(["''])[[:alnum:]/._-]+\1\s*$'
    let bundle = Class('bundle', File, {
        \ 'name': 'bundle',
        \ 'pattern': s:bundle_pattern,
        \ 'syn_sep': '~',
        \ 'filetype': 'vim',
        \ 'tooltip': 'bundle:',
        \ 'hl_group': 'Label',
        \ })


    fun! bundle.post_validate() dict "{{{
        let str = self._hl.obj.str
        " get "xxxx"
        let str = matchstr(str, s:bundle_pattern)
        " trim ' and "
        let str = substitute(str, '"\|''', '', 'g')
        " get last part sep by /
        let str = split(str,'/')[-1]

        " get the .vim or .oh-my-vim path
        let path1 = expand('~/.vim/bundle/') . str
        let path2 = expand('~/.oh-my-vim/bundle/') . str
        if exists("g:bundle_directory")
            let path3 = expand(g:bundle_directory) . str
            let paths = [path1, path2, path3]
        else
            let paths = [path1, path2]
        endif

        let self.full_path = path1

        for p in paths
            if isdirectory(p)
                let self.full_path = p
                break
            endif
        endfor

        let self.short_path = fnamemodify(self.full_path, ':t')
    endfun "}}}

    let config = {'bundle':bundle}
    call clickable#export(config)
endfun

call s:init()
