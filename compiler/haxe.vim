" Vim compiler file
" Compiler:     haxe
" Maintainer:   Justin Donaldson <jdonaldson@gmail.com>
" Last Change:  2012 May 5

if exists("current_compiler")
  finish
endif

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

if exists('g:vihxen_build_index')
    let g:vihxen_build_index = 0
endif   

function! s:FindInParent(fln,flsrt,flstp)
    let here = a:flsrt
    while ( strlen( here) > 0 ) 
        let p = split(globpath(here, a:fln), '\n')
        if len(p) > 0 
            return ['ok', here, fnamemodify(p[0], ':p:t'), ]
        endif
        let fr = match(here, '/[^/]*$')
        if fr == -1
            break
        endif
        let here = strpart(here, 0, fr) 
        if here == a:flstp
            break
        endif
    endwhile
    return ['fail', '', ''] 
endfunction

function! g:Unlet(str)
    if exists(a:str)
        eval("unlet ".a:str)
    endif    
    return
endfunction    

if exists('s:vihxen_build_name')
    :unlet s:vihxen_build_name
endif   

if exists('s:vihxen_build_directory')
    :unlet s:vihxen_build_directory
endif

if exists('g:vihxen_build_name')
    s:vihxen_build_name = g:vihxen_build_name
endif

if exists('g:vihxen_build_directory')
    s:vihxen_build_directory = g:vihxen_build_directory
endif

function! s:VihxenUpdateBuild()
    let [success, hxmldir, hxmlname] = s:FindInParent('*.hxml', expand('%:p:h')  ,'/')    
    if success == 'ok'
        if !exists('s:vihxen_build_directory')
            let s:vihxen_build_directory = hxmldir
        endif   
        if !exists('s:vihxen_build_name')
            let s:vihxen_build_name = hxmlname
        endif
    endif
    if !exists('s:vihxen_build_directory')
        echoerr 'vihxen could not set a build directory'
    elseif !exists('s:vihxen_build_name')
        echoerr 'vihxen could not set a build name'
    else
        let makeprg_str = 'cd '.s:vihxen_build_directory.'; haxe '.s:vihxen_build_name
        "CompilerSet makeprg=makeprg_str
        let &makeprg=makeprg_str
        echomsg 'vihxen makeprg set: '.&makeprg 
        CompilerSet errorformat=%E%f:%l:\ characters\ %c-\d\ :\ %m
        let current_compiler = "haxe"
    endif
    return 'true'
endfunction
let test = s:VihxenUpdateBuild()

