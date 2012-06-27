function! vaxe#OpenHxml()
    let vaxe_hxml = vaxe#CurrentBuild()
    if filereadable(vaxe_hxml)
        exe ':edit '.vaxe_hxml
    else
        echoerr 'build not readable: '.vaxe_hxml
    endif
endfunction

function! vaxe#ImportClass()
   let match_parts = matchlist(getline('.'), '\(\l\+\.\)*\(\u\w*\)')
   if len(match_parts)
       let package = match_parts[1]
       " get rid of the period at the end of the package declaration.
       let package = substitute(package, "\.$",'','g')
       let class = match_parts[2]
       let file_packages = {}
       let file_classes = {} 

       if package == ''
           for val in taglist(".")
               if val['kind'] == 'p'
                   let file_packages[val['filename']] = val['name']
               elseif val['kind'] == 'c' || val['kind'] == 't' || val['kind'] == 'i'
                   if val['name'] == class
                       let file_classes[val['filename']] = val['name']
                   endif
               endif
           endfor

           let packages = []

           for file in keys(file_classes)
               if has_key(file_packages, file)
                   let packages = packages + [file_packages[file]]
               endif
           endfor

           if len(packages) == 0
               echomsg "No packages to import"
               return
           endif

           let package = packages[0]
           if len(packages) > 1
               let package = inputlist(packages)
           endif
       endif

       if package == ''
           echomsg "No package found for class"
           return
       endif
       let oldpos = getpos('.') 


       if search("^\\s*import\\s*".package."\.".class) > 0
           let fixed = substitute(getline('.'), package.'\.', '','g')
           echomsg "Class has already been imported"
           return
       endif

       let importline = search("^\\s*import")
       if importline == 0
           let importline = search("^\\s*package")
       endif
       call cursor(oldpos[1], oldpos[2])
       let fixed = substitute(getline('.'), package.'\.', '','g')
       call setline(line('.'), fixed)
       call append(importline,['import '.package.'.'.class.';']) 
       call cursor(oldpos[1]+1, oldpos[2])
   endif
endfunction

function! vaxe#HaxeComplete(findstart,base)
   if a:findstart
       return col('.')
   else
       return s:DisplayCompletion()
   endif
endfunction

function! vaxe#ProjectHxml()
    if exists('g:vaxe_hxml')
        unlet g:vaxe_hxml
    endif

    let hxmls = split(glob("**/*.hxml"),'\n')

    if len(hxmls) == 0
        echoerr "No hxml files found in current working directory"
        return
    elseif len(hxmls) ==1
        let base_hxml = hxmls[0]
    else
        if exists('g:tlib_inputlist_pct')
            let base_hxml = tlib#input#List('s', 'Select Hxml', hxmls)
        else
            let hxmls_list = map(range(len(hxmls)),
                '(v:var+1)." ".hxmls_list[v:var]')
            let hxmls_list = ['Select Hxml'] + hxmls_list
            let sel = inputlist(hxmls_list)
            let base_hxml = hxmls_list[sel-1]
        endif
    endif

    if base_hxml !~ "^//"
        let base_hxml = getcwd().'/'.base_hxml
    endif

    let g:vaxe_hxml = base_hxml

    if !filereadable(g:vaxe_hxml)
        echoerr "Project build file not valid, please create one."
        return
    endif

    call s:SetCompiler()
    return g:vaxe_hxml
endfunction

function! vaxe#DefaultHxml()
    if exists('b:vaxe_hxml')
        unlet b:vaxe_hxml
    endif
    let base_hxml = findfile(g:vaxe_prefer_hxml, ".;")
    if base_hxml !~ "^/"
        let base_hxml = getcwd() . '/' . base_hxml
    endif
    if !filereadable(base_hxml)
        redraw
        echomsg "Default build file not valid, please create one."
        return
    endif
    let b:vaxe_hxml = base_hxml
    call s:SetCompiler()
    return b:vaxe_hxml
endfunction

function! vaxe#CurrentBuild()
    let vaxe_hxml = ''
    if exists('g:vaxe_hxml')
        let vaxe_hxml = g:vaxe_hxml
    elseif exists('b:vaxe_hxml')
        let vaxe_hxml = b:vaxe_hxml
    endif
    return vaxe_hxml
endfunction

function! s:SetCompiler()
    let vaxe_hxml = vaxe#CurrentBuild()
    if (exists("g:vaxe_hxml"))
        let build_command = "haxe '".vaxe_hxml."' 2>&1"
    else
        " do not cd to different directory after command, it won't show quick
        " fix
        let build_command = "cd '".fnamemodify(vaxe_hxml,":p:h")."';"
                    \."haxe '".vaxe_hxml."' 2>&1"
    endif

    let &l:makeprg = build_command
    " only use simple info message for catching traces (%I%m), haxe doesn't
    " output the full file path in the trace output
endfunction

function! vaxe#CompilerClassPaths()
   let complete_args = s:CurrentBlockHxml()
   let complete_args.= "\n"."-v"."\n"."--no-output"
   let complete_args = join(split(complete_args,"\n"),' ')
   let vaxe_hxml = vaxe#CurrentBuild()
   let hxml_cd = fnamemodify(vaxe_hxml,":p:h")
   let hxml_sys = "cd\ ".hxml_cd."; haxe ".complete_args."\ 2>&1"
   let voutput = system(hxml_sys)
   let raw_path = split(voutput,"\n")[0]
   let raw_path = substitute(raw_path, "Classpath :", "","")
   let paths = split(raw_path,';')
   let paths = filter(paths,'v:val != "/" && v:val != ""')
   return paths
endfunction

function! vaxe#Ctags()
    let paths = vaxe#CompilerClassPaths()

    if (len(paths) > 0)
        " the last path is the base std dir, We want to treat it differently
        let std =  remove(paths, len(paths)-1)
        " the second to last path is the target std dir. We need to alter it.
        let std_target =  remove(paths, len(paths)-1)
        " strip off the target's _std override dir
        let std_target = substitute(std_target, "_std/$", "","g")
        " specify all of the util directories in the base std, and any base
        " classes.  Include the target specific directories in std_target.
        let paths = paths + [std_target] + [std.'haxe/', std.'sys/', std.'tools/', std.'*.hx']
        let pathstr = join( paths,' ')
        let vaxe_hxml = vaxe#CurrentBuild()
        " get the hxml name so we can cd to its directory
        " TODO: this probably needs to be user specified
        let hxml_cd = fnamemodify(vaxe_hxml,":p:h")
        " call ctags recursively on the directories
        let hxml_sys = " cd " . hxml_cd . ";"
                    \." ctags --languages=haxe  --exclude=_std  -R " . pathstr. ";"
        "echomsg hxml_sys
        call system(hxml_sys)
    endif
endfunction

function! s:CurrentBlockHxml()
    let vaxe_hxml = vaxe#CurrentBuild()
    let hxfile = join(readfile(vaxe_hxml),"\n")
    let parts = split(hxfile,'--next')
    let complete = filter(parts, 'match(v:val, "^\s*#\s*vaxe")')
    if len(complete) == 0
        let complete = parts
    endif
    let complete_string = complete[0]
    let parts = split(complete_string,"\n")
    let parts = map(parts, 'substitute(v:val,"#.*","","")')
    let parts = map(parts, 'substitute(v:val,"\\s*-\\(cmd\\|xml\\|v\\)\\s*.*","","")')
    let complete_string = join(parts,"\n")
    return complete_string
endfunction

function! s:CompletionHxml(file_name, byte_count)
    let stripped = s:CurrentBlockHxml()
    return stripped."\n"."--display ".a:file_name.'@'.a:byte_count
endfunction

function! s:DisplayCompletion()
    if  synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") == 'Comment'
        return []
    endif

    let vaxe_hxml = vaxe#CurrentBuild()
    if !filereadable(vaxe_hxml)
        echoerr 'build file not readable: '.vaxe_hxml
    endif
    let complete_args = s:CompletionHxml(expand("%:p")
                \, (line2byte('.')+col('.')-2))
    let hxml_cd = fnamemodify(b:vaxe_hxml,":p:h")
    let hxml_sys = "cd\ ".hxml_cd."; haxe ".complete_args."\ 2>&1"
    let hxml_sys =  join(split(hxml_sys,"\n")," ")
    "echomsg(hxml_sys)
    " ignore the write requests generated by completions
    if (g:vaxe_prevent_completion_bufwrite_events)
        let events = "BufWritePost,BufWritePre,BufWriteCmd"
        let old_ignore = &l:eventignore
        if (&l:eventignore)
            let &l:eventignore = &l:eventignore . ',' . events
        else
            let &l:eventignore = events
        endif
        exe ":silent update"
        let &l:eventignore = old_ignore
    else
        exe ":silent update"
    endif
    let complete_output = system(hxml_sys)
    let output = []
    "echomsg complete_output
python << endpython
import vim, re, HTMLParser
import xml.etree.ElementTree as ET
import HTMLParser

complete_output = vim.eval("complete_output")
if complete_output is None: complete_output = ''
completes = []
#print(complete_output)
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
            info = ['']
        else:
            # get rid of leading/trailing ws/nl
            info = info.strip()
            # split and collapse extra whitespace
            info = [re.sub(r'\s+',' ',s.strip()) for s in info.split('\n')]
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
    info = [h.unescape(otype.text).strip()]
    abbr = info[0]
    completes= [{'word':word,'info':info, 'abbr':abbr}]
vim.command("let output = " + str(completes))
endpython
    for o in output
        let tag = ''
        if has_key(o,'info')
            let o['info'] = join(o['info'],"\n")
        endif
        if has_key(o,'menu')
            let o['info'] = o['info'] . "\n>> " . o['menu']
        endif
    endfor
    " There was no good compiler completion.  Complete a Type
    if len(output) == 0
        let classes = []
        let line2col =getline('.')[0:col('.')]
        let partial_word = ''
        let obj = copy(l:)
        function! obj.EML(regex)
            let matches = matchlist(self.line2col, a:regex)
            echomsg join(matches,' ')
            if len(matches) > 0
               let self.partial_word = matches[1]
            end
            return len(matches)
        endfunction
        if obj.EML("new\\s*\\(\w*\\)$")
            let classes = filter(taglist('^'.partial_word),
                        \'v:val["kind"] == "c"')
            echomsg "constructor"
        elseif obj.EML(":\\s*\\(\w*\\)$")
            let classes = filter(taglist('^'.partial_word),
                        \'v:val["kind"] == "c" '
                        \.'|| v:val["kind"] == "t" '
                        \.'|| v:val["kind"] == "i"')
        elseif obj.EML("import\\s*\\(\w*\\)$")
            let classes = filter(taglist('^'.partial_word),
                        \'v:val["kind"] == "p"')
        else
            "echomsg partial_word
            "echomsg "***".line2col."***"
        endif
        let output = map(classes,
                    \'{"word":substitute(v:val["name"],"^".partial_word,"","g")'
                    \.', "abbr":v:val["name"]'
                    \.', "menu":v:val["filename"]}')
    endif
    return output
endfunction

