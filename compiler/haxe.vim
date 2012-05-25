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
    let g:vihxen_prefer = 'build.hxml'       " prefer build.hxml files
endif


function! g:SelectHxml()
    let b:vihxen_build = findfile(g:vihxen_prefer,".;")
    if len(b:vihxen_build) == 0
        echomsg "Preferred build file not found, please create one."
    endif
    set omnifunc=g:HaxeComplete
    let build_command = "cd '".fnamemodify(b:vihxen_build,":p:h")."';haxe '".b:vihxen_build."' 2>&1;"
    echomsg build_command
    let &makeprg = build_command
    "CompilerSet errorformat=%E%f:%l:\ characters\ %c-%*[0-9\]\ :\ %m
    CompilerSet errorformat=%E%f:%l:\ characters\ %c-%*[0-9]\ :\ %m,%I%f:%l:\ %m
    return b:vihxen_build
endfunction

if !exists("b:vihxen_build")
    let b:vihxen_build = g:SelectHxml()
endif

function! g:RawCompletion(file_name, byte_count)
    let hxfile = join(readfile(b:vihxen_build),"\n")
    let parts = split(hxfile,'--next')
    let parts = map(parts, 'substitute(v:val,"#.*","","")')
    let parts = map(parts, 'substitute(v:val,"\s*-cmd\s*.*","","")')
    let complete = filter(copy(parts), 'match(v:val, "^\s*#\s*vihxen")')
    if len(complete) == 0
        complete = parts
    endif
    return complete[0]."\n"."--display ".a:file_name.'@'.a:byte_count
endfunction

function! g:DisplayCompletion()
    if  synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") == 'Comment'
        return []
    endif
    let complete_args = g:RawCompletion(expand("%:p"), (line2byte('.')+col('.')-2))
    let hxml_cd = fnamemodify(b:vihxen_build,":p:h")
    let hxml_sys = "cd\ ".hxml_cd."; haxe ".complete_args."\ 2>&1"
    let hxml_sys =  join(split(hxml_sys,"\n")," ")
    echomsg(hxml_sys)
    silent exe ":w"
    let complete_output = system(hxml_sys)
    let output = []
    "echomsg hxml_sys
    "echomsg complete_output
python << endpython
import vim, re, HTMLParser
import xml.etree.ElementTree as ET
import HTMLParser

complete_output = vim.eval("complete_output")
if complete_output is None: complete_output = ''
completes = []
print(complete_output)
# wrap in a tag to prevent parsing errors
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
        if info is None:
            info = ''
        else:
            info = info.strip()
        abbr = word
        kind = 'v'
        if  menu == '': kind = 'm'
        elif re.search("\->", menu): kind = 'f' # if it has a ->
        return {'word': word, 'info':info, 'kind':kind, 'menu':menu,'abbr':abbr}
    completes = map(fieldxml2completion, fields)
elif len(types) > 0:
    otype = types[0]
    h = HTMLParser.HTMLParser()
    word = ' '
    info = h.unescape(otype.text).strip()
    completes= [{'word':word,'abbr':info }]
vim.command("let output = " + str(completes))
endpython
    for o in output
        let o['info'] = o['info'] . "\n" . o['menu']
    endfor

    return output
endfunction

function! g:HaxeComplete(findstart,base)
   if a:findstart
       return col('.')
   else
       return g:DisplayCompletion()
   endif
endfunction

