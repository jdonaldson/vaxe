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

if !exists('g:vihxen_build')
    let g:vihxen_prefer = 'build'       " prefer build.hxml files
endif

" build a list of files that match the fln regex, starting at flsrt and
" ending at flstp
function! s:FindInParent(fln,flsrt,flstp)
    let here = a:flsrt
    let p = []
    while ( strlen( here) > 0 )
        let p += split(globpath(here, a:fln),'\n')
        let fr = match(here, '/[^/]*$')
        if fr == -1
            break
        endif
        let here = strpart(here, 0, fr)
        if here == a:flstp
            break
        endif
    endwhile
    return p
endfunction

"Select a hxml file using s:FindInParent, and prefering files named
"g:vihxen_prefer
function! g:SelectHxml(...)
    let found_hxml = s:FindInParent("*.hxml", expand("%:p:h"), "/")
    for g in a:000
        let found_hxml = filter(found_hxml,
        \ 'fnamemodify(v:val,":t:r") == fnamemodify(g,":t:r")')
    endfor
    let found_title = ['Select hxml']
    let found_title += map(copy(found_hxml), '"(".(v:key+1)."):".v:val')
    let selected_index = inputlist(found_title)
    let g:vihxen_build = found_hxml[selected_index-1]
    return g:vihxen_build
endfunction

if !exists("g:vihxen_build")
    let g:vihxen_build = g:SelectHxml(g:vihxen_prefer)
endif

if !filereadable(g:vihxen_build)
    echoerr  "Could not read the specified build file: ".g:vihxen_build_file.
    \       " in the working directory: ".expand("%:p")
endif

function! g:Completion(file_name, byte_count)
    let hxfile = join(readfile(g:vihxen_build),"\n")
    let parts = split(hxfile,'--next')
    let complete = filter(copy(parts), 'match(v:val, "^\s*#\s*vihxen")')
    if len(complete) == 0
        complete = parts
    endif
    return complete[0]."\n"."--display ".a:file_name.'@'.a:byte_count
endfunction


function! g:Complete()
    let complete_args = g:Completion(expand("%:p"), (line2byte('.')+col('.')-2))
    let hxml_cd = fnamemodify(g:vihxen_build,":p:h")
    let hxml_sys = "cd ".hxml_cd."; haxe ".complete_args." 2>&1"
    let hxml_sys =  join(split(hxml_sys,"\n")," ")
    silent exe ":w"
    let complete_output = system(hxml_sys)
    echomsg complete_output
    return complete_output
endfunction


let build_command = "cd '".fnamemodify(g:vihxen_build,":p:h")."'; haxe '".g:vihxen_build."' 2>&1"

let &makeprg = build_command

CompilerSet errorformat=%E%f:%l:\ characters\ %c-%*[0-9]\ :\ %m,%I%f:%l:\ %m

