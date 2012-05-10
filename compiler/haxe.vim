" Vim compiler file
" Compiler:     haxe
" Maintainer:   Justin Donaldson <jdonaldson@gmail.com>
" Last Change:  2012 May 5

if exists("current_compiler")
  finish
endif
let current_compiler = "haxe"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

if exists('g:vihxen_build_index')
    let g:vihxen_build_index = 0
endif   

"s:FindInParent
" find the file argument and returns the path to it.
" Starting with the current working dir, it walks up the parent folders
" until it finds the file, or it hits the stop dir.
" If it doesn't find it, it returns "Nothing"
function! s:FindInParent(fln,flsrt,flstp)
    let here = a:flsrt
    while ( strlen( here) > 0 ) 
        let p = split(globpath(here, a:fln), '\n')
        if len(p) > 0 
            let idx = 0
            if filereadable(p[0])
                let lines = readFile(p[0])
                let parts = split(lines,'--next')
                mparts = filter(parts, matchstr(v:value, '^#\s*@vihxen-complete')) 
                if length(mparts) > 0

            endif       
            return ['ok', here, fnamemodify(p[0], ':p:t'), idx ]
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

function! g:VihxenUpdateBuild()
    [success, hxmldir, hxmlname] = s:FindInParent('*.hxml', '.' , '/')    
    if success == 'ok'
        if !exists('s:vihxen_build_directory')
            let s:vihxen_build_directory = hxmldir
        endif   
        if !exists('s:vihxen_build_name')
            let s:vihxen_build_name = hxmlname
        endif
    endif

endfunction


g:VihxenUpdateBuild()

CompilerSet makeprg='cd'.g:vihxen_build_directory.'; haxe '. g:vihxen_build_name

CompilerSet errorformat=%E%f:%l:\ characters\ %c-\d\ :\ %m
