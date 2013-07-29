let unsuppmrted_msg = 'Unsupported platform, send a note to the maintainer about adding support'

function! vaxe#SetWorkingDir()
    exe 'cd "'.g:vaxe_working_directory.'"'
endfunction

" Utility logging function
function! s:Log(str)
    if g:vaxe_logging
        echomsg a:str
    endif
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

" Generate a nicely formatted build file name for powerline, etc.
function! vaxe#CurrentBuildPowerline()
   let short_name = fnamemodify(vaxe#CurrentBuild(), ":.")
   return "☢ " . short_name
endfunction

function! vaxe#KillCacheServer()
    if has('unix')
        call system("kill ". g:vaxe_cache_server_pid)
        unlet g:vaxe_cache_server_pid
    else
        echoerr unsupported_msg
    endif
endfunction

function! vaxe#StartCacheServer()
    if has('unix')
        let haxe_version = vaxe#util#HaxeServerVersion()
        if haxe_version != '0'
            echomsg "Compilation server is already running on port "
                        \ . g:vaxe_cache_server_port
        else
            let pid =  vaxe#util#SimpleSystem("haxe --wait "
                        \. g:vaxe_cache_server_port . "& echo $!")
            if pid =~ '\v[0-9]+'
                let g:vaxe_cache_server_pid = pid
                echomsg "Started a haxe compilation cache server on port "
                            \ . g:vaxe_cache_server_port
                            \ . " with pid " . g:vaxe_cache_server_pid
                autocmd VimLeavePre * call vaxe#KillCacheServer()
            else
                echoerr "Could not start haxe cache server."
                            \. "See docs for more details."
                            \. "(help vaxe-cache-server)"
            endif
        endif
    else
        echoerr unsupported_msg
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
       " get rid of the period at the end of the package declaration.
       let package = substitute(package, "\.$",'','g')
       let class = match_parts[3]
       if search("^\\s*import\\s*\\(\\a\\+\\.\\)*".class, 's') > 0
           echomsg "Class has already been imported"
           return
       endif
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
               let package = vaxe#util#InputList("Select package", packages)
           endif
       endif

       if package == ''
           echomsg "No package found for class"
           return
       endif
       let oldpos = getpos('.')

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
    " ERROR: no python
    if !has("python")
        echoerr 'Vaxe requires python for completions'
        return []
    endif

    " EXIT: trace does not have function argument completion
    let linepart = strpart(getline('.'), 0, col('.'))
    if match(linepart, "trace($") > 0
        return []
    endif

    " EXIT: comments/constants shouldn't be completed
    let syntax_type = synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
    if syntax_type == 'Comment' || syntax_type == 'Constant'
        return []
    endif

    call s:HandleWriteEvent()

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
        return s:FormatDisplayCompletion(a:base)
    endif
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
            let base_hxml = vaxe#util#InputList("Select Hxml", hxmls)
        endif

        if base_hxml !~ "^//"
            let base_hxml = getcwd() . '/' . base_hxml
        endif
        let g:vaxe_hxml = base_hxml
    endif
    if !filereadable(g:vaxe_hxml)
        echoerr "Project build file not valid, please create one."
        return
    endif
    call vaxe#SetCompiler()
    return g:vaxe_hxml
endfunction


" A function that runs on a hx filetype load.  It will set the default hxml
" path if the project hxml or nmml are not set.
function! vaxe#AutomaticHxml()
    if exists ("g:vaxe_nmml")
        call vaxe#nme#ProjectNmml(g:vaxe_nmml)
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

    if exists('b:vaxe_openfl')
       unlet b:vaxe_openfl
    endif

    "First check if an hxml/nmml was passed explicitly
    if a:0 > 0 && a:1 != ''
        if match(a:1,'\.hxml$')
            let b:vaxe_hxml = a:1
        elseif match(a:1,'\.nmml$' )
            let b:vaxe_nmml = a:1
        elseif match(a:1,'\.xml$' )
            let b:vaxe_openfl = a:1
        endif
    else " check if there's an nmml in the parent roots...
        let base_build = vaxe#util#ParentSearch(
                    \ g:vaxe_default_parent_search_patterns
                    \ , fnamemodify(expand("%"),":p:h"))
        if (base_build != '')
            let base_builds = split(base_build,'\n')
            if g:vaxe_prefer_first_in_directory
                let base_build = base_builds[0]
            else
                let base_build = vaxe#util#InputList(base_builds, "Select build file")
            endif
            if base_build !~ '^/'
                let base_build = getcwd() . '/' . base_build
            endif

            if base_build =~ '\.xml'
               let b:vaxe_openfl = base_build
               call vaxe#openfl#BuildOpenflHxml()
            elseif base_build =~'\.nmml'
               let b:vaxe_nmml = base_build
               call vaxe#nme#BuildNmmlHxml()
            else
                let b:vaxe_hxml = base_build
            endif
        end
    endif

    if !exists('b:vaxe_hxml')
        let b:vaxe_hxml = ''
    endif

    if !filereadable(b:vaxe_hxml)
        if b:vaxe_hxml == expand("%")
            " hxml has been opened, but not written yet
            " Set an autocmd to set the hxml after the buffer is written
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
    " this is necessary since use may cd to different directories during
    " session
    autocmd QuickFixCmdPre <buffer>  exe 'cd ' . fnameescape(g:vaxe_working_directory)
    autocmd QuickFixCmdPost <buffer>  cd -

    call vaxe#SetCompiler()
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
function! vaxe#SetCompiler()
    let abspath = []
    let escaped_wd = fnameescape(g:vaxe_working_directory)

    if exists("g:vaxe_openfl")
        let build_verb = "build"
        if g:vaxe_openfl_test_on_build
            let build_verb = "test"
        endif
        let build_command = "cd " . escaped_wd . " && "
                    \."openfl ".build_verb." ". g:vaxe_openfl_target . " 2>&1"
    elseif exists("g:vaxe_nmml")
        let build_verb = "build"
        if g:vaxe_nme_test_on_build
            let build_verb = "test"
        endif
        let build_command = "cd " . escaped_wd . " && "
                    \."nme ".build_verb." ". g:vaxe_nme_target . " 2>&1"
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
   let complete_args = vaxe#CurrentBlockHxml()
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
   let unique_paths = vaxe#util#UniqueList(paths)
   return unique_paths
endfunction

" Calls ctags on the list of compiler class paths
function! vaxe#Ctags()
    let paths = vaxe#CompilerClassPaths()

    if (len(paths) > 0)
        let fixed_paths = []
        for p in paths
            " escape spaces in paths
            let p = substitute(p, " ", "\\\\ ", "g")
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
        let hxml_cd = substitute(hxml_cd, " ", "\\\\ ", "g")
        " call ctags recursively on the directories
        let hxml_sys = " cd " . hxml_cd . ";"
                    \." ctags --languages=haxe --exclude=_std -R " . pathstr. ";"
        call s:Log(hxml_sys)
        call system(hxml_sys)
    endif
endfunction


" Generate inline compiler declarations for the given target from the relevant
" build hxml string.  Remove any flags that generate unnecessary output or activity.
function! s:CurrentBlockHxml(hxml_str)
    let parts = split(a:hxml_str, '--next')

    if len(parts) == 0
        let parts = [hxml_str]
    endif

    let complete = filter(copy(parts), 'v:val =~ "#\\s*display completions"')
    if len(complete) == 0
        let complete = parts
    endif

    return s:SanitizeHxml(complete[0])
endfunction


" clean up hxml in string form by removing -(cmd|v|xml) directives
" also escape spaces in arguments
function! s:SanitizeHxml(complete_string)
    let parts = split(a:complete_string,"\n")
    let fixed = []

    for p in parts
        let p = substitute(p, '#.*','','') " strip comments
        let p = substitute(p, '\s*$', '', '') " strip trailing ws

        " strip cmd\xml\verbose\times directives
        let p = substitute(p, '^\s*-\(cmd\|xml\|v\|-times\)\s*.*', '', '')

        " fnameescape directives
        let p = substitute(p, '^\s*\(--\?[a-z0-9\-]\+\)\s*\(.*\)$', '\=submatch(1)." ".escape(fnameescape(submatch(2)), "()")', '')

        call add(fixed, p)
    endfor

    return join(fixed,"\n")
endfunction






function! vaxe#CurrentBlockHxml()
    let vaxe_hxml = vaxe#CurrentBuild()
    let hxml_str = join(readfile(vaxe_hxml),"\n")
    return s:CurrentBlockHxml(hxml_str)
endfunction

" Returns hxml that is suitable for making a --display completion call
function! s:CompletionHxml(file_name, byte_count)
    " the stripped down haxe compiler command (no -cmd, etc.)
    let stripped = vaxe#CurrentBlockHxml()
    if (g:vaxe_cache_server_enable)
        " let stripped \. stripped " the stripped hxml
        let stripped = "--cwd " . fnameescape(g:vaxe_working_directory)
                    \. " \n--connect "
                    \.  g:vaxe_cache_server_port
                    \. " \n" . stripped
    endif
    return stripped."\n--display ".fnameescape(a:file_name).'@'.a:byte_count
endfunction

if g:vaxe_haxe_version >=3
function! vaxe#JumpToDefinition()
    let output = []
    let extra = "\n-D display-mode=position"
    let complete_output = s:RawCompletion(b:vaxe_hxml, extra)
    " execute the python completion script in autoload/vaxe.py
    call s:Log(complete_output)
    py locations('complete_output','output')
    let output_str = join(output, '\n')
    lexpr(output_str)
endfunction
endif

" ignore the write requests generated by completions
function! s:HandleWriteEvent()
    let events = ''
    let old_ignore = &l:eventignore
    if (g:vaxe_prevent_completion_bufwrite_events)
        let events = "BufWritePost,BufWritePre,BufWriteCmd"
    endif
    let &l:eventignore = old_ignore
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

endfunction

" a 'raw completion' function that will just return unformatted output
" pass extra string options to append to the current hxml
function! s:RawCompletion(vaxe_hxml, extra_string)
    let offset = line2byte('.') + col('.')  -2
    " handle the BOM
    if &bomb
        let offset += 3
    endif

    let complete_args = s:CompletionHxml(expand("%:p"), offset)
    let complete_args = complete_args . ' ' . a:extra_string

    let hxml_cd = "cd\ \"".fnamemodify(a:vaxe_hxml,":p:h"). "\"&&"
    if exists("g:vaxe_hxml")
        let hxml_cd = ''
    endif

    let hxml_sys = hxml_cd." haxe ".complete_args."\ 2>&1"
    let hxml_sys =  join(split(hxml_sys,"\n")," ")
    call s:Log(hxml_sys)
    let complete_output = system(hxml_sys)
    return complete_output
endfunction

" The main completion function that invokes the compiler, etc.
function! s:FormatDisplayCompletion(base)
    let vaxe_hxml = vaxe#CurrentBuild()
    if !filereadable(vaxe_hxml)
       return [{"word" : "", "abbr" : "Compiler error: ", "menu": "No valid build file", "empty" : 1}]
    endif
    let complete_output = s:RawCompletion(vaxe_hxml, '')
    " quick and dirty check for error
    let tag = complete_output[1:4]
    if tag != "type" && tag != "list" && tag != "pos>"
        let error = complete_output[:len(complete_output)-2]
        cgete error
        return [{"word" : "", "abbr" : "Compiler error: "
                    \, "menu":error, "empty" : 1}]
    endif
    let output = []
    call s:Log('compiler output: ' . complete_output)

    " execute the python completion script in autoload/vaxe.py
    py complete('complete_output','output'
                \, 'a:base', 'g:vaxe_completion_alter_signature'
                \, 'g:vaxe_completion_collapse_overload')

    call s:Log("display elements: " . len(output))
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
    return output
endfunction

