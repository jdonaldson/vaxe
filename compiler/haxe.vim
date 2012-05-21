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

if !exists('g:vihxen_prefer')
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
"b:vihxen_prefer
function! g:SelectHxml(...)
    let found_hxml = s:FindInParent("*.hxml", expand("%:p:h"), "/")
    for g in a:000
        let found_hxml = filter(found_hxml,
        \ 'fnamemodify(v:val,":t:r") == fnamemodify(g,":t:r")')
    endfor
    let found_title = ["Select hxml"]
    let found_title += map(range(0,len(found_hxml)-1), '"(".(v:val+1)."):".found_hxml[v:val]')
    if len(found_title) == 2
        let selected_index = 1
    else
        let selected_index = inputlist(found_title)
    endif
    let b:vihxen_build = found_hxml[selected_index-1]

    set omnifunc=g:HaxeComplete
    let build_command = "cd '".fnamemodify(b:vihxen_build,":p:h")."';haxe '".b:vihxen_build."' 2>&1;"
    echomsg build_command
    let &makeprg = build_command
    CompilerSet errorformat=%E%f:%l:\ characters\ %c-%*[0-9]\ :\ %m,%I%f:%l:\ %m

    return b:vihxen_build
endfunction

if !exists("b:vihxen_build")
    let b:vihxen_build = g:SelectHxml(g:vihxen_prefer)
endif

if !filereadable(b:vihxen_build)
    echoerr  "Could not read the specified build file:"
    echoerr b:vihxen_build
    finish
endif

function! g:RawCompletion(file_name, byte_count)
    let hxfile = join(readfile(b:vihxen_build),"\n")
    let parts = split(hxfile,'--next')
    let parts = map(parts, 'substitute(v:val,"#.*","","")')
    "let parts = map(parts, 'substitute(v:val,"\s*-cmd","","")')
    let complete = filter(copy(parts), 'match(v:val, "^\s*#\s*vihxen")')
    if len(complete) == 0
        complete = parts
    endif
    return complete[0]."\n"."--display ".a:file_name.'@'.a:byte_count
endfunction


function! g:DisplayCompletion()
    let complete_args = g:RawCompletion(expand("%:p"), (line2byte('.')+col('.')-2))
    let hxml_cd = fnamemodify(b:vihxen_build,":p:h")
    let hxml_sys = "cd\ ".hxml_cd."; haxe ".complete_args."\ 2>&1"
    let hxml_sys =  join(split(hxml_sys,"\n")," ")
    echomsg(hxml_sys)
    silent exe ":w"
    let complete_output = system(hxml_sys)
    let output = []
    echomsg hxml_sys
    echomsg complete_output
python << endpython
import vim, re, HTMLParser
import xml.etree.ElementTree as ET
import HTMLParser

complete_output = vim.eval("complete_output")
if complete_output is None: complete_output = ''
print(complete_output) 
completes = []
# wrap in a tag to prevent parsing errors

print(complete_output)
root= ET.XML("<output>"+complete_output+"</output>")
fields = root.findall("list/i")
types = root.findall("type")
completes = []
if len(fields) > 0:
    def fieldxml2completion(x):
        word =x.attrib["n"]
        menu =x.find("t").text
        info = x.find("d").text
        menu = '' if menu is None else menu
        info = '' if info is None else info.strip()
        abbr = word
        kind = 'v'
        if  menu == '': kind = 'm'
        elif re.search("\->", menu): kind = 'f' # if it has a ->
        return {'word': word, 'info':info, 'kind':kind, 'menu':menu,'abbr':abbr}
    completes = map(fieldxml2completion, fields)
elif len(types) > 0:
    print(types[0].text)
    otype = types[0]
    h = HTMLParser.HTMLParser()
    info = h.unescape(otype.text).strip()
    completes= [{'info':"signature "+ info, 'word':' ','abbr':info }]

vim.command("let output = " + str(completes))
endpython
    return output
endfunction

function! g:HaxeComplete(findstart,base)
   if a:findstart
       return col('.')
   else
       return g:DisplayCompletion()
       "return ['foo','bar']
   endif
endfunction

    CompilerSet errorformat=%E%f:%l:\ characters\ %c-%*[0-9]\ :\ %m,%I%f:%l:\ %m
