"=============================================
"  Plugin: Clickable.vim
"  File:   autoload/clickable/config.vim
"  Author: Rykka<rykka@foxmail.com>
"  Update: 2014-09-30
"=============================================
let s:cpo_save = &cpo
set cpo-=C

" The Config object will load all configs 
" from vim file and clickable_type file
" use>
"
" then wrap them in a config object and push in a config queue.
"   There are two kind of queue:
"
"   The All Queue: for all file 
"   The FileType Queue: a dict of ft:queues.
"
"
" Then When executing in buffer,
" The relevent config object will be load
" Then highlight/hover/click/navigate events will be added
" and be triggered at the right time.


fun! s:init_config_queue() "{{{
    " Create A Config Class
    let Class = clickable#class#init()
    " let Config = Class('Config',{'FileType':{}, 'All':[] })

    let g:_clickable_config_queue = {}
    let s:_ConfigQue = g:_clickable_config_queue
    let ConfigQue = clickable#class#config_queue#init()
    let s:_ConfigQue.ALL = ConfigQue.new({'name': 'ALL', 'buffer_only':0})


endfun "}}}
fun! s:load_config_queue(var, ...) "{{{
    " Load Config from local Var, 
    " And optionally 
    "   local file
    "   remote file
    
    " Load All Configs
    let configs = a:var
    " let namespace = get(a:000, 0 , 'clickable')
    
    let ConfigQue = clickable#class#config_queue#init()
    
    " Create A config Instance
    " have config instance
    " let config = {}
    " let config.ALL = Config.new({'name': 'ALL'})
    " put config into FileType queue and All queue.
    for key in keys(configs)
        if has_key(configs[key], 'filetype')
            for ft in split(configs[key]['filetype'],',')
                if !exists("s:_ConfigQue[ft]")
                    let s:_ConfigQue[ft] = ConfigQue.new({'name':ft, 'extend':'ALL'})
                endif
                " let configs[key].namespace = namespace
                call add(s:_ConfigQue[ft].objects, configs[key])
            endfor
        else
                " let configs[key].namespace = namespace
            call add(s:_ConfigQue.ALL.objects, configs[key])
        endif
    endfor

    " return the config object
    return s:_ConfigQue
endfun "}}}


fun! s:local_config()
    let Class = clickable#class#init()
    let Basic = clickable#class#basic#init()
    let File = clickable#class#file#init()
    let Link = clickable#class#link#init()

    let local_config = {}

    let local_config.mail = Class('Mail',Link, {
        \ 'name': 'mail',
        \ 'pattern': '\v<[[:alnum:]_-]+%(\.[[:alnum:]_-]+)*[@#][[:alnum:]]%([[:alnum:]-]*[[:alnum:]]\.)+[[:alnum:]]%([[:alnum:]-]*[[:alnum:]])=>',
        \ 'tooltip': 'mail:',
        \})

    function! local_config.mail.trigger(...) dict "{{{
        let mail = 'mailto:'. self._hl.obj.str
        let mail = substitute(mail, '#', '@', '')
        call clickable#util#browse(mail, self.browser)  
    endfunction "}}}

    let local_config.link = Class(Link, {
        \ 'name': 'link',
        \ 'pattern': 
        \ '\v<(([[:alnum:]-]+://?|www[.])[^[:space:]()<>]+%(\([[:alnum:]]+\)|([^[:punct:][:space:]]|/)))',
        \ 'tooltip': 'link:',
        \})
        " \ '\v<%(%(file|https=|ftp|gopher)://|%(mailto|news):)([^[:space:]''\"<>]+[[:alnum:]/])|<www[[:alnum:]_-]*\.[[:alnum:]_-]+\.[^[:space:]''\"<>]+[[:alnum:]/]',
        " http://daringfireball.net/2009/11/liberal_regex_for_matching_urls
        " \v<(([[:alnum:]-]+://?|www[.])[^[:space:]()<>]+%(\([\w\d]+\)|([^[:punct:]\s]|/)))

    let local_config.file = Class(File, {
        \ 'name': 'file',
        \ 'tooltip': 'file:',
        \})

    " let local_config.file.filetype = 'vim'


    let fname_bgn = '%(^|[[:space:]''"([{<,;!?])'
    " FIXME:
    " the .. will match the file pattern if with '\.\s'
    " let fname_end = '%($|\s|[''")\]}>:,;!?])|\.\s'
    " FIXME:
    " The file pattern is tooooooo SLOW!!!
    let fname_end = '%($|\s|[''")\]}>:,;!?])'
    let file_ext_lst = clickable#pattern#norm_list(split(clickable#get_opt('extensions'),','))
    let file_ext_ptn = join(file_ext_lst,'|')
    " 
    " let file_name = '%([[:alnum:]~.][/\\]|[/][[:alnum:].~_-]@<=)=%(\.=[[:alnum:]_-]+[~:./\\_-]=)*'
    " let file_name = '%([[:alnum:]~.][/\\]|[/][[:alnum:].~_-]@<=)=%(\.=[~[:alnum:]_-]+[~:./\\_-]=)*'
    let file_name = '%([~]=/|\w:\\)=%(\.=[~[:alnum:]_-]+[~:./\\_-]=)*'
    " let local_config.file.pattern  = '\v' . fname_bgn
    "             \. '@<=' . file_name
    "             \.'%(\.%('. file_ext_ptn .')|([[:alnum:].~_-])@<=/)\ze'
    "             \.fname_end 
    "'(^|[[:punct:][:space:]])@<='
    let local_config.file.pattern  = '\v'. '%(\w|[\//:.~_-])@<!'
                \.file_name
                \.'%(\.%('. file_ext_ptn .')|%(\w@<=[/\\]))'
                \.'%(\w|[\//:.~_-])@!'
                " \.'%($|\s|[()''"!?,;])@<='
    " echom local_config.file.pattern
    " let local_config.file.pattern = 'tevim'
    " echo local_config.file.pattern
    " echo '12312' =~ local_config.file.pattern
    " echo '" Load mappings/commands etc' =~ local_config.file.pattern


    let local_config.folding = Class('Folding', Basic, {
        \ 'name': 'folding',
        \ 'tooltip': 'This is a closed folding',
        \})
    function! local_config.folding.validate(...) dict "{{{
        return foldclosed('.') != -1
    endfunction "}}}
    function! local_config.folding.trigger(...) dict "{{{
        exe "norm! zv"
    endfunction "}}}

    let local_config.fold_marker = Class('FoldMarker', Basic, {
        \ 'name': 'fold_marker',
        \ 'tooltip': 'This is a fold marker',
        \})
    function! local_config.fold_marker.validate(...) dict "{{{
        return &fdm == 'marker' && getline('.') =~ split(&foldmarker,',')[0].'\s*$' && foldclosed('.') == -1
    endfunction "}}}
    function! local_config.fold_marker.trigger(...) dict "{{{
        exe "norm! zc"
    endfunction "}}}
    
    return local_config
endfun

fun! s:load_file_config() "{{{

    let files = split(globpath(clickable#get_opt("directory"), '*.vim'),'\n')
    let files += split(globpath(&rtp, 'clickable/*.vim'),'\n')

    for file in files
        exe 'so ' file
    endfor

    let config_queue = clickable#get_file_queue()
    for config in config_queue
        call s:load_config_queue(config)
    endfor
    
endfun "}}}

fun! clickable#config#init() "{{{

    " We should add namespace to avoid override of same key

    call s:init_config_queue()


    call s:load_config_queue(s:local_config())

    call s:load_file_config()

    return s:_ConfigQue
    
endfun "}}}

if expand('<sfile>:p') == expand('%:p') "{{{
    call clickable#config#init()
    " call clickable#util#BEcho(clickable#config#init())
    let regxp = '\v<(([[:alnum:]-]+://?|www[.])[^[:space:]()<>]+%(\([\w\d]+\)|([^[:punct:]\s]|/)))'
    let link = 'www.163.com'
    let link = 'https://16com?fefef=3&fefe=4 '
    echo matchstr(link, regxp)
endif "}}}

let &cpo = s:cpo_save
unlet s:cpo_save
