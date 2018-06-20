let unsupported_msg = 'Unsupported platform, send a note to the maintainer about adding support'

function! vaxe#SetWorkingDir()
    exe 'cd "'.g:vaxe_working_directory.'"'
endfunction

" Utility logging function
function! vaxe#Log(str)
    if g:vaxe_logging
        echomsg a:str
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

        if base_hxml !~ "^\([a-zA-Z]:\)\=[/\\]"
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
" path if the project hxml or lime are not set.
function! vaxe#AutomaticHxml()
    if exists ("g:vaxe_lime")
        call vaxe#lime#ProjectLime(g:vaxe_lime)
    elseif exists ("g:vaxe_flow")
        call vaxe#flow#ProjectFlow(g:vaxe_flow)
    elseif exists('g:vaxe_hxml')
        call vaxe#ProjectHxml(g:vaxe_hxml)
    elseif exists('g:vaxe_skip_hxml')
        return
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

    "First check if an hxml/lime/flow was passed explicitly
    if a:0 > 0 && a:1 != ''
        if match(a:1,'\.hxml$')
            let b:vaxe_hxml = a:1
        endif
    else " check if there's a lime/flow in the parent roots...
        let base_build = vaxe#util#ParentSearch(
                    \ g:vaxe_default_parent_search_patterns
                    \ , fnamemodify(expand("%"),":p:h"))
        if (base_build != '')
            let base_builds = split(base_build,'\n')
            if g:vaxe_prefer_first_in_directory
                let base_build = base_builds[0]
            else
                let base_build = vaxe#util#InputList("Select build file", base_builds)
            endif
            if base_build !~ '^\([a-zA-Z]:\)\=[/\\]'
                let base_build = getcwd() . '/' . base_build
            endif

            let b:vaxe_hxml = base_build
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
    let dirs = split(&tags, ",")
    if !match(dirs, g:vaxe_working_directory)
        let &tags = &tags . ',' . g:vaxe_working_directory
    endif

    if exists("g:vaxe_lime") || exists("b:vaxe_lime")
        let build_verb = "build"
        if g:vaxe_lime_test_on_build
            let build_verb = "test"
        endif
        let build_command = "cd " . escaped_wd . " && "
                    \."lime ".build_verb." ". g:vaxe_lime_target . " 2>&1"
    elseif exists("g:vaxe_flow") || exists("b:vaxe_flow")
        let build_command = "cd " . escaped_wd . " && "
                    \."haxelib run flow build " . g:vaxe_flow_target . " 2>&1"
    else
        let vaxe_hxml = vaxe#CurrentBuild()
        let escaped_hxml = fnameescape(vaxe_hxml)
        call vaxe#Log("vaxe_hxml: " . vaxe_hxml)
        let build_command = "cd " . escaped_wd ." &&"
                    \. g:vaxe_haxe_binary . " " . escaped_hxml . " 2>&1"
        if filereadable(vaxe_hxml)
            let lines = readfile(vaxe_hxml)
        endif
    endif

    let &l:makeprg = build_command
    let &l:errorformat="%W%f:%l: characters %c-%*[0-9] : Warning : %m
                \,%E%f:%l: characters %c-%*[0-9] : %m
                \,%E%f:%l: lines %*[0-9]-%*[0-9] : %m"

    " if g:vaxe_trace_absolute_path is specified, then traces contain useful
    " path information, and errorfmt can use it to jump to the file/folder
    " location
    if (g:vaxe_trace_absolute_path)
        let &l:errorformat .= ",%I%f:%l: %m"
    endif
    " generic catch-all regex that will grab misc stdout
    let &l:errorformat .= ",%I%m"
endfunction

