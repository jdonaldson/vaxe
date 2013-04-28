
" Utility variable that stores the directory that this script resides in
let s:plugin_path = escape(expand('<sfile>:p:h'), '\')

let s:slash = '/'
if has('win32') || has('win64')
    let s:slash = '\'
endif

" Utility function that recursively searches parent directories for 'dir'
" until a file matching "pattern" is found.
function! s:ParentSearch(pattern, dir)
    let current_dir = fnamemodify(a:dir,":p:h")
    let last_dir = ''
    while(current_dir != last_dir)
        let last_dir = current_dir
        let match = globpath(current_dir, a:pattern)
        if (match != '')
            return match
        endif
        let current_dir = fnamemodify(current_dir, ":p:h:h")
    endwhile
    return ''
endfunction

function! vaxe#SetWorkingDir()
    exe 'cd "'.g:vaxe_working_directory.'"'
endfunction

" Utility function that lets users select from a list.  If list is length 1,
" then that item is returned.  Uses tlib#inpu#List if available.
function! s:InputList(label, items)
  if len(a:items) == 1
    return a:items[0]
  endif
  if exists("g:loaded_tlib")
      return tlib#input#List("s", a:label, a:items)
  else
      let items_list = map(range(len(a:items)),'(v:val+1)." ".a:items[v:val]')
      let items_list = [a:label] + items_list
      let sel = inputlist(items_list)
      " 0 is the label.  If that is returned, just use the first item in the
      " list instead
      if sel == 0
          let sel = 1
      endif
      return a:items[sel-1]
  endif
endfunction

" Utility logging function
function! s:Log(str)
    if g:vaxe_logging
        echomsg a:str
    endif
endfunction

" Utility function that returns a list of unique values in the list argument.
function! s:UniqueList(items)
    let d = {}
    for v in a:items
        let d[v] = 1
    endfor
    return keys(d)
endfunction

" Utility function to open the hxml file that vaxe is using.
function! vaxe#OpenHxml()
    let vaxe_hxml = vaxe#CurrentBuild()
    if filereadable(vaxe_hxml)
        exe ':edit '.fnameescape(vaxe_hxml)
    else
        echoerr 'build not readable: '.vaxe_hxml
    endif
endfunction

" Utility function that tries to 'do the right thing' in order to import a
" given class. Call it on a given line in order to import a class definition
" at that line.  E.g.
" var l = new haxe.FastList<Int>()
" becomes
" import haxe.FastList;
" ...
" var l = new FastList();
" You can also call this without a package prefix, and vaxe will try to look
" up packages that contain the (e.g. FastList) class name.
function! vaxe#ImportClass()
   let match_parts = matchlist(getline('.'), '\(\(\l\+\.\)\+\)*\(\u\w*\)')
   if len(match_parts)
       let package = match_parts[1]
       " get rid of the period at t*he end of the package declaration.
       let package = substitute(package, "\.$",'','g')
       let class = match_parts[3]
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
               echomsg "No packages found in ctags"
               return
           endif

           let package = packages[0]
           if len(packages) > 1
               let package = s:InputList("Select package", packages)
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

" A function suitable for omnifunc
function! vaxe#HaxeComplete(findstart,base)
   if !has("python")
       echoerr 'Vaxe requires python for completions'
       return 0
   endif
   if a:findstart
       let line = getline('.')
       let period = strridx(line, '.')
       let paren = strridx(line, '(')
       if (period == paren)
           return -1
       endif
       let basecol = max([period,paren]) + 1
       return basecol
   else
       return s:DisplayCompletion(a:base)
   endif
endfunction

function! s:NmeTarget(...)
    let g:vaxe_nme_target = ''
    if a:0 > 0 && a:1 != ''
        let g:vaxe_nme_target = a:1
    else
        let g:vaxe_nme_target = s:InputList("Select Target", s:nmml_targets)
        let g:vaxe_nme_target = split(g:vaxe_nme_target, ":")[0]
    endif
endfunction

function! vaxe#NmeTarget(...)
    call s:NmeTarget(a:1)
    call s:SetCompiler()
endfunction


function! vaxe#ProjectNmml(...)
    if exists('g:vaxe_nmml')
        unlet g:vaxe_nmml
    endif
    let g:vaxe_working_directory = getcwd()

    if a:0 > 0 && a:1 != ''
        let g:vaxe_nmml = expand(a:1,':p')
    else
        let nmmls = split(glob("**/*.nmml"),'\n')

        if len(nmmls) == 0
            echoerr "No nmml files found in current working directory"
            return
        else
            let base_nmml = s:InputList("Select Nmml", nmmls)
        endif

        if base_nmml !~ "^//"
            let base_nmml = getcwd() . s:slash . base_nmml
        endif

        let g:vaxe_nmml = base_nmml
    endif
    if !filereadable(g:vaxe_nmml)
        echoerr "Project nmml file not valid, please create one."
        return
    endif
    call s:SetCompiler()
    return g:vaxe_nmml
endfunction
" A function that will search for valid hxml in the current working directory
"  and allow the user to select the right candidate.  The selection will
"  enable 'project mode' for vaxe.
function! vaxe#ProjectHxml(...)
    if exists('g:vaxe_hxml')
        unlet g:vaxe_hxml
    endif

    let g:vaxe_working_directory = getcwd()

    if a:0 > 0 && a:1 != ''
        let g:vaxe_hxml = expand(a:1,':p')
    else
        let hxmls = split(glob("**/*.hxml"),'\n')
        if len(hxmls) == 0
            echoerr "No hxml files found in current working directory"
            return
        else
            let base_hxml = s:InputList("Select Hxml", hxmls)
        endif

        if base_hxml !~ "^//"
            let base_hxml = getcwd() . s:slash . base_hxml
        endif
        let g:vaxe_hxml = base_hxml
    endif
    if !filereadable(g:vaxe_hxml)
        echoerr "Project build file not valid, please create one."
        return
    endif
    call s:SetCompiler()
    return g:vaxe_hxml
endfunction

" A function that runs on a hx filetype load.  It will set the default hxml
" path if the project hxml is not set.
function! vaxe#AutomaticHxml()
    if exists ("g:vaxe_nmml")
        call vaxe#ProjectNmml(g:vaxe_nmml)
    elseif exists('g:vaxe_hxml')
        call vaxe#ProjectHxml(g:vaxe_hxml)
    else
        call vaxe#DefaultHxml()
    endif
endfunction


" A function that sets the default hxml located in the parent directories of
" the current buffer.
function! vaxe#DefaultHxml(...)
    " unlet any existing hxml variables
    if exists('b:vaxe_hxml')
        unlet b:vaxe_hxml
    endif

    if exists('b:vaxe_nmml')
        unlet b:vaxe_nmml
    endif

    if a:0 > 0 && a:1 != ''
        if match(a:1,'\.hxml$')
            let b:vaxe_hxml = a:1
        elseif match(a:1,'\.nmml\$' )
            let b:vaxe_nmml = a:1
        endif
    else
        let base_nmml = s:ParentSearch("*.nmml", fnamemodify(expand("%"),":p:h"))

        if (base_nmml != '')
            let base_nmml = split(base_nmml,'\n')[0]
        end

        let base_hxml = findfile(g:vaxe_prefer_hxml, ".;")
        if base_hxml !~ "^/"
            let base_hxml = getcwd() . s:slash . base_hxml
        endif
        if (base_nmml != '')
            if base_nmml !~ "^/"
                let base_nmml = getcwd() . s:slash . base_nmml
            endif
            let b:vaxe_nmml = base_nmml
        endif
        let b:vaxe_hxml = base_hxml
    endif

    if exists("b:vaxe_nmml")
        let base_hxml = b:vaxe_nmml.".hxml"

        if !strlen(g:vaxe_nme_target)
            call s:NmeTarget()
        endif
        let g:vaxe_working_directory = fnamemodify(b:vaxe_nmml, ":p:h")
        let cdcmd = 'cd "'.g:vaxe_working_directory.'" && '
        " pipe nme display to an hxml for completions
        let escape_base = fnameescape(base_hxml)
        call system(cdcmd. " echo '# THIS FILE IS AUTOGENERATED BY VAXE, ANY EDITS ARE DISCARDED' " . " > " . escape_base)
        call system(cdcmd . " nme display " . g:vaxe_nme_target
                    \. " >> " . escape_base )

        " build the assets dependencies
        call system(cdcmd . " nme build " . g:vaxe_nme_target)

        let g:vaxe_nmml = b:vaxe_nmml
        let b:vaxe_hxml = base_hxml
        let g:vaxe_hxml = b:vaxe_hxml
    endif

    if !filereadable(b:vaxe_hxml)
        if b:vaxe_hxml == expand("%")
            " hxml has been opened, but not written yet
            augroup temp_hxml
                autocmd BufWritePost <buffer> call vaxe#DefaultHxml(expand("%"))| autocmd! temp_hxml
            augroup END
        else
            redraw
            echomsg "Default build file not valid: " . b:vaxe_hxml
        endif
        return
    endif

    let g:vaxe_working_directory = fnamemodify(b:vaxe_hxml, ":p:h")

    " set quickfix to jump to working directory before populating list
    autocmd QuickFixCmdPre <buffer>  exe 'cd ' . fnameescape(g:vaxe_working_directory)
    autocmd QuickFixCmdPost <buffer>  cd -

    call s:SetCompiler()
endfunction


" Returns the hxml file that should be used for compilation or completion
function! vaxe#CurrentBuild()
    let vaxe_hxml = ''
    if exists('g:vaxe_hxml')
        let vaxe_hxml = g:vaxe_hxml
    elseif exists('b:vaxe_hxml')
        let vaxe_hxml = b:vaxe_hxml
    endif
    return vaxe_hxml
endfunction

" Sets the makeprg
function! s:SetCompiler()
    let abspath = []
    let escaped_wd = fnameescape(g:vaxe_working_directory)

    if exists("g:vaxe_nmml")
        let build_command = "cd " . escaped_wd . " && "
                    \."nme test ". g:vaxe_nme_target . " 2>&1"
    else
        let vaxe_hxml = vaxe#CurrentBuild()
        let escaped_hxml = fnameescape(vaxe_hxml)
        call s:Log("vaxe_hxml: " . vaxe_hxml)
        let build_command = "cd " . escaped_wd ." &&"
                    \. "haxe " . escaped_hxml . " 2>&1"
        if filereadable(vaxe_hxml)
            let lines = readfile(vaxe_hxml)
            let abspath = filter(lines, 'v:val =~ "\\s*-D\\s*absolute_path"')
        endif
    endif

    let &l:makeprg = build_command
    let &l:errorformat="%I%f:%l: characters %c-%*[0-9] : Warning : %m
                \,%E%f:%l: characters %c-%*[0-9] : %m
                \,%E%f:%l: lines %*[0-9]-%*[0-9] : %m"

    " if -D absolute_path is specified, then traces contain path information,
    " and errorfmt can use the file/folder location
    if (len(abspath)> 0)
        let &l:errorformat .= ",%I%f:%l: %m"
    endif
    " general catch all regex that will grab misc stdout
    let &l:errorformat .= ",%I%m"
endfunction

" returns a list of compiler class paths
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
   if len(paths) == 1
       echoerr "The compiler exited with an error: ". paths[0]
       return []
   endif
   let unique_paths = s:UniqueList(paths)
   return unique_paths
endfunction

" Calls ctags on the list of compiler class paths
function! vaxe#Ctags()
    let paths = vaxe#CompilerClassPaths()

    if (len(paths) > 0)
        let fixed_paths = []
        for p in paths
            if p =~ "/std/$"
                "this is the target std dir. We need to alter use it to add some
                "global std utility paths, and avoid the target paths.
                let fixed_paths = fixed_paths + [p.'haxe/', p.'sys/', p.'tools/', p.'*.hx']
            elseif p =~ "/_std/$"
                "this is the selected target paths, we can exclude the _std path
                "that includes target specific implementations of std classes.
                let p = substitute(p, "_std/$", "","g")
                let fixed_paths = fixed_paths + [p]
            elseif p =~ "^\./$"
                "this is an alt representation of the working dir, we don't
                "need it
                continue
            else
                "this is a normal path (haxelib, or via -cp)
                let fixed_paths = fixed_paths + [p]
            endif
        endfor

        let pathstr = join( fixed_paths,' ')
        let vaxe_hxml = vaxe#CurrentBuild()
        " get the hxml name so we can cd to its directory
        " TODO: this probably needs to be user specified
        let hxml_cd = fnamemodify(vaxe_hxml,":p:h")
        " call ctags recursively on the directories
        let hxml_sys = " cd " . hxml_cd . ";"
                    \." ctags --languages=haxe --exclude=_std -R " . pathstr. ";"
        call s:Log(hxml_sys)
        call system(hxml_sys)
    endif
endfunction

" Generate inline compiler declarations for the given target from the relevant
" build hxml.  Remove any flags that generate unnecessary output or activity.
function! s:CurrentBlockHxml()
    let vaxe_hxml = vaxe#CurrentBuild()
    let hxfile = join(readfile(vaxe_hxml),"\n")
    let parts = split(hxfile, '--next')

    if len(parts) == 0
        let parts = [hxfile]
    endif

    let complete = filter(copy(parts), 'v:val =~ "#\\s*display completions"')
    if len(complete) == 0
        let complete = parts
    endif

    let complete_string = complete[0]
    let parts = split(complete_string,"\n")
    let fixed = []

    for p in parts
        let p = substitute(p, '#.*','','') " strip comments
        let p = substitute(p, '\s*$', '', '') " strip trailing ws

        " strip cmd\xml\verbose directives
        let p = substitute(p, '^\s*-\(cmd\|xml\|v\)\s*.*', '', '')

        " fnameescape directives
        let p = substitute(p, '^\s*\(--\?[a-z0-9\-]\+\)\s*\(.*\)$', '\=submatch(1)." ".fnameescape(submatch(2))', '')

        call add(fixed, p)
    endfor

    let complete_string = join(fixed,"\n")
    return complete_string
endfunction


function! vaxe#CurrentBlockHxml()
    return s:CurrentBlockHxml()
endfunction

" Returns hxml that is suitable for making a --display completion call
function! s:CompletionHxml(file_name, byte_count)
    " the stripped down haxe compiler command (no -cmd, etc.)
    let stripped = s:CurrentBlockHxml()
    return stripped."\n--display ".fnameescape(a:file_name).'@'.a:byte_count
endfunction

" The main completion function that invokes the compiler, etc.
function! s:DisplayCompletion(base)
    if  synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") == 'Comment'
        return []
    endif

    let vaxe_hxml = vaxe#CurrentBuild()
    if !filereadable(vaxe_hxml)
       return [{"word" : "", "abbr" : "Compiler error: ", "menu": "No valid build file", "empty" : 1}]
    endif
    let offset = line2byte('.') + col('.')  -2
    " handle the BOM
    if &bomb
        let offset += 3
    endif
    let complete_args = s:CompletionHxml(expand("%:p"), offset)
    let hxml_cd = "cd\ \"".fnamemodify(vaxe_hxml,":p:h"). "\"&&"
    if exists("g:vaxe_hxml")
        let hxml_cd = ''
    endif

    let hxml_sys = hxml_cd." haxe ".complete_args."\ 2>&1"
    let hxml_sys =  join(split(hxml_sys,"\n")," ")
    call s:Log(hxml_sys)
    " ignore the write requests generated by completions
    "
    let events = ''
    let old_ignore = &l:eventignore
    if (g:vaxe_prevent_completion_bufwrite_events)
        let events = "BufWritePost,BufWritePre,BufWriteCmd"
    endif
    if (&l:eventignore)
        let &l:eventignore = &l:eventignore . ',' . events
    else
        let &l:eventignore = events
    endif
    if (&autowriteall)
        exe ":silent wall"
    elseif (&autowrite)
        exe ":silent update"
    endif

    let &l:eventignore = old_ignore
    let complete_output = system(hxml_sys)
    " quick and dirty check for error
    let tag = complete_output[1:4]
    if tag != "type" && tag != "list"
        let error = complete_output[:len(complete_output)-2]
        cgete error
        return [{"word" : "", "abbr" : "Compiler error: ", "menu":error, "empty" : 1}]
    endif
    let output = []
    call s:Log(complete_output)

    " execute the python completion script in autoload/vaxe.py
    exe 'pyfile '.s:plugin_path.'/vaxe.py'
    py complete('complete_output','output', 'a:base')

    for o in output
        let tag = ''
        if has_key(o,'info')
            let o['info'] = join(o['info'],"\n")
        endif
        if has_key(o,'menu')
            let o['info'] = o['info'] . "\n  " . o['menu']
        endif
    endfor

    " There was no compiler completion.  Complete a Type
    " Note, this is currently unreachable code
    if len(output) == 0 && 0
        let classes = []
        let line2col =getline('.')[0:col('.')]
        let partial_word = ''
        let obj = copy(l:)

        " shortcut function that matches a regex and sets a partial word
        " variable
        function! obj.EML(regex)
            let matches = matchlist(self.line2col, a:regex)
            if len(matches) > 0
               let self.partial_word = matches[1]
            end
            return len(matches)
        endfunction
        if obj.EML("new\\s*\\(\w*\\)$")
            let classes = filter(taglist('^'.partial_word),
                        \'v:val["kind"] == "c"')
            "echomsg "constructor"
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

let s:nmml_targets = [ "android : Create Google Android applications"
            \, "android -arm7 : Compile for arm-7a and arm5"
            \, "android -arm7-only : Compile for arm-7a for testing"
            \, "blackberry : Create BlackBerry applications"
            \, "blackberry -simulator : Build/test for the device simulator"
            \, "flash : Create SWF applications for Adobe Flash Player"
            \, "html5 : Create HTML5 canvas applications"
            \, "html5 -minify : Minify output using the Google Closure compiler"
            \, "html5 -minify -yui : Minify output using the YUI compressor"
            \, "ios : Create Apple iOS applications"
            \, "ios -simulator : Build/test for the device simulator"
            \, "ios -simulator -ipad : Build/test for the iPad Simulator"
            \, "linux : Create Linux applications"
            \, "linux -64 : Compile for 64-bit instead of 32-bit"
            \, "linux -neko : Build with Neko instead of C++"
            \, "mac : Create Apple Mac OS X applications"
            \, "mac -neko : Build with Neko instead of C++"
            \, "webos : Create HP webOS applications"
            \, "windows : Create Microsoft Windows applications"
            \, "windows -neko : Build with Neko instead of C++" ]


  " -D : Specify a define to use when processing other commands
  " -debug : Use debug configuration instead of release
  " -verbose : Print additional information (when available)
  " -clean : Add a "clean" action before running the current command
  " (display) -hxml : Print HXML information for the project
  " (display) -nmml : Print NMML information for the project
