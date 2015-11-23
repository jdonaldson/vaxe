if exists("g:loaded_vaxe_plugin")
    finish
endif

let g:loaded_vaxe_plugin = 1

command -nargs=? -complete=file DefaultHxml call vaxe#DefaultHxml(<q-args>)
command -nargs=? -complete=file ProjectHxml call vaxe#ProjectHxml(<q-args>)
command VaxeToggleLogging let g:vaxe_logging = !g:vaxe_logging

" Lime commands
command -nargs=? -complete=file ProjectLime
            \ call vaxe#lime#ProjectLime(<q-args>)

command -nargs=? -complete=customlist,vaxe#lime#Targets LimeTarget
            \ call vaxe#lime#Target(<q-args>)

command -nargs=? LimeClean
            \ call vaxe#lime#Clean(<q-args>)

command -nargs=? LimeUpdate
            \ call vaxe#lime#Update(<q-args>)

command -nargs=? LimeRebuildHxml
            \ call vaxe#lime#RebuildHxml()


" Flow commands
command -nargs=? -complete=file ProjectFlow
            \ call vaxe#flow#ProjectFlow(<q-args>)

command -nargs=? -complete=customlist,vaxe#flow#Targets FlowTarget
            \ call vaxe#flow#Target(<q-args>)

command -nargs=? FlowClean
            \ call vaxe#flow#Clean(<q-args>)

command -nargs=? FlowRebuildHxml
            \ call vaxe#flow#RebuildHxml()

" Completion Server Commands
command VaxeStopCompletionServer call vaxe#KillCacheServer()
command VaxeStartCompletionServer call vaxe#StartCacheServer()

command VaxeCtags call vaxe#Ctags()

autocmd FileType haxe setlocal commentstring=//%s

let g:tagbar_type_haxe = {
    \ 'ctagstype' : 'haxe',
    \ 'kinds'     : [
        \ 'a:abstracts',
        \ 'c:classes',
        \ 'e:enums',
        \ 'i:interfaces',
        \ 't:typedefs',
        \ 'v:variables',
        \ 'f:functions',
        \ ]
    \ }

" a short alias, since I use this all over the place
let s:c = function("vaxe#util#Config")

" misc options
let g:vaxe_haxe_version        = s:c('g:vaxe_haxe_version', 3)
let g:vaxe_cache_server        = s:c('g:vaxe_cache_server', 0)
let g:vaxe_logging             = s:c('g:vaxe_logging', 0)
let g:vaxe_trace_absolute_path = s:c('g:vaxe_trace_absolute_path', 1)

" completion options
let g:vaxe_completion_require_autowrite
            \= s:c('g:vaxe_require_completion_autowrite', 1)
let g:vaxe_completion_disable_optimizations
            \= s:c('g:vaxe_completion_disable_optimizations', 1)
let g:vaxe_completion_alter_signature
            \= s:c('g:vaxe_completion_alter_signature', 1)
let g:vaxe_completion_collapse_overload
            \= s:c('g:vaxe_completion_collapse_overload', 0)
let g:vaxe_completion_write_compiler_output
            \= s:c('g:vaxe_completion_write_compiler_output', 0)
let g:vaxe_completion_prevent_bufwrite_events
            \= s:c('g:vaxe_completion_prevent_bufwrite_events',1)
let g:vaxe_completeopt_menuone
            \= s:c('g:vaxe_completeopt_menuone', 1)

" cache server options
let g:vaxe_cache_server_port      = s:c('g:vaxe_cache_server_port', 6878)
let g:vaxe_cache_server_autostart = s:c('g:vaxe_cache_server_autostart', 1)

" lime options
let g:vaxe_lime_test_on_build     = s:c('g:vaxe_lime_test_on_build', 1)
let g:vaxe_lime_target            = s:c('g:vaxe_lime_target',"")
let g:vaxe_lime_completion_target = s:c('g:vaxe_lime_completion_target', 'flash')

" flow options
let g:vaxe_flow_target            = s:c('g:vaxe_flow_target', "")
let g:vaxe_flow_completion_target = s:c('g:vaxe_flow_completion_target', 'web')

" default build options
let g:vaxe_prefer_hxml               = s:c('g:vaxe_prefer_hxml', "build.hxml")
let g:vaxe_prefer_lime               = s:c('g:vaxe_prefer_lime', "*.lime")
let g:vaxe_prefer_flow               = s:c('g:vaxe_prefer_flow', "*.flow")
let g:vaxe_prefer_openfl             = s:c('g:vaxe_prefer_openfl', "project.xml")
let g:vaxe_prefer_first_in_directory = s:c('g:vaxe_prefer_first_in_directory', 1)
let g:vaxe_default_parent_search_patterns
            \= s:c('g:vaxe_default_parent_search_patterns'
            \, [g:vaxe_prefer_lime, g:vaxe_prefer_flow, g:vaxe_prefer_openfl, g:vaxe_prefer_hxml, "*.hxml"])

" Supported 3rd party plugin options
let g:vaxe_enable_airline_defaults = s:c('g:vaxe_enable_airline_defaults', 1)
let g:vaxe_enable_ycm_defaults     = s:c('g:vaxe_enable_ycm_defaults', 1)
let g:vaxe_enable_acp_defaults     = s:c('g:vaxe_enable_acp_defaults', 1)

if !exists('g:vaxe_haxe_binary')
	let g:vaxe_haxe_binary = 'haxe'
endif

" YCM
if (g:vaxe_enable_ycm_defaults)
    if ( exists("g:ycm_semantic_triggers")  )
        let g:ycm_semantic_triggers['haxe'] = ['.', '(']
    else
        let g:ycm_semantic_triggers = { 'haxe' : ['.', '('] }
    endif
endif

" ACP
if (g:vaxe_enable_acp_defaults)
    if !exists('g:acp_behavior')
        let g:acp_behavior = {}
    endif

    function! haxe#meetsForFile(context)
        return a:context =~ '\(\.\|(\)$'
    endfunction
    if  !has_key(g:acp_behavior, 'haxe')
        let g:acp_behavior['haxe'] = []
    endif

    let vaxe_entry = {
                \ "meets" : "haxe#meetsForFile",
                \ "command": "\<C-X>\<C-O>",
                \ "completefunc" : "vaxe#HaxeComplete"}

    call add(g:acp_behavior['haxe'] , vaxe_entry)
endif
