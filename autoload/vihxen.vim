function! vihxen#OpenHxml()
    if filereadable(b:vihxen_hxml)
        exe ':edit '.b:vihxen_hxml
    endif
endfunction


function! vihxen#HaxeComplete(findstart,base)
   if a:findstart
       return col('.')
   else
       return s:DisplayCompletion()
   endif
endfunction



function! vihxen#FindHxml(...)
    let choose_first = 1
    if a:0 > 1
        let prefer_hxml = a:1
        if a:0 == 2
            let choose_first = a:2
        endif
    else
        let prefer_hxml = "**.hxml"
    end
    let hxmls = glob(prefer_hxml)
    let hxmllist = split(hxmls,"\n")
    let hxmlnames = map(range(len(hxmllist)),'(v:val+1)." ".hxmllist[v:val]')
    if len(hxmllist) == 0
        echomsg "no hxml found"
        finish
    elseif (choose_first || len(hxmllist) == 1)
        let b:vihxen_hxml = hxmllist[0]
    else
        let index = inputlist(["Select Hxml"] + hxmlnames)
        let b:vihxen_hxml = hxmllist[index]
    endif

    if b:vihxen_hxml !~ "^//"
        let b:vihxen_hxml = getcwd() . '/' . b:vihxen_hxml
    endif

    if !filereadable(b:vihxen_hxml)
        echomsg "Preferred build file not found, please create one."
    endif

    set omnifunc=vihxen#HaxeComplete
    let build_command = "cd '".fnamemodify(b:vihxen_hxml,":p:h")."';"
                \."haxe '".b:vihxen_hxml."' 2>&1"

    "echomsg build_command
    let &l:makeprg = build_command
    if exists(":CompilerSet") != 2 " older Vim always used :setlocal
        command -nargs=* CompilerSet setlocal <args>
    endif
    CompilerSet errorformat=%E%f:%l:\ characters\ %c-%*[0-9]\ :\ %m
                \,%I%f:%l:\ %m
    return b:vihxen_hxml
endfunction

"function! vihxen#FindHxmlInWorkingDir()
"endfunction

function! vihxen#CompilerClassPaths()
   let complete_args = s:CurrentBlockHxml(b:vihxen_hxml)
   let complete_args.= "\n"."-v"."\n"."--no-output"
   let complete_args = join(split(complete_args,"\n"),' ')
   let hxml_cd = fnamemodify(b:vihxen_hxml,":p:h")
   let hxml_sys = "cd\ ".hxml_cd."; haxe ".complete_args."\ 2>&1"
   let voutput = system(hxml_sys)
   let raw_path = split(voutput,"\n")[0]
   let raw_path = substitute(raw_path, "Classpath :", "","")
   let paths = split(raw_path,';')
   let paths = filter(paths,'v:val != "/" && v:val != ""')
   return paths
endfunction

function! vihxen#Ctags()
    let paths = join(vihxen#CompilerClassPaths(),' ')
    let hxml_cd = fnamemodify(b:vihxen_hxml,":p:h")
    let hxml_sys = "cd " . hxml_cd . "; ctags -R . " . paths
    call system(hxml_sys)
endfunction

function! s:CurrentBlockHxml(file_name)
    let hxfile = join(readfile(b:vihxen_hxml),"\n")
    let parts = split(hxfile,'--next')
    let complete = filter(parts, 'match(v:val, "^\s*#\s*vihxen")')
    if len(complete) == 0
        let complete = parts
    endif
    let complete_string = complete[0]
    let parts = split(complete_string,"\n")
    let parts = map(parts, 'substitute(v:val,"#.*","","")')
    let parts = map(parts, 'substitute(v:val,"\s*-(cmd|xml|v)\s*.*","","")')
    let complete_string = join(parts,"\n")
    return complete_string
endfunction

function! s:CompletionHxml(file_name, byte_count)
    let stripped = s:CurrentBlockHxml(a:file_name)
    return stripped."\n"."--display ".a:file_name.'@'.a:byte_count
endfunction

function! s:DisplayCompletion()
    if  synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") == 'Comment'
        return []
    endif
    let complete_args = s:CompletionHxml(expand("%:p")
                \, (line2byte('.')+col('.')-2))
    let hxml_cd = fnamemodify(b:vihxen_hxml,":p:h")
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
        word = x.attrib["n"]
        menu = x.find("t").text
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
        return {  'word': word, 'info': info, 'kind': kind
                \,'menu': menu, 'abbr': abbr }
    completes = map(fieldxml2completion, fields)
elif len(types) > 0:
    otype = types[0]
    h = HTMLParser.HTMLParser()
    word = ' '
    abbr = h.unescape(otype.text).strip()
    completes= [{'word':word,'abbr':info}]
vim.command("let output = " + str(completes))
endpython
    for o in output
        let tag = ''
        if has_key(o,'menu') && has_key(o,'info')
            let o['info'] = o['info'] . "\n" . o['menu']
        endif
    endfor

    return output
endfunction


