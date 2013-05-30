if exists("g:loaded_vaxe_plugin")
    finish
endif
let g:loaded_vaxe_plugin = 1

command -nargs=? -complete=file DefaultHxml call vaxe#DefaultHxml(<q-args>)
command -nargs=? -complete=file ProjectHxml call vaxe#ProjectHxml(<q-args>)
command -nargs=? -complete=file ProjectNmml call vaxe#nme#ProjectNmml(<q-args>)
command ToggleVaxeLogging let g:vaxe_logging = !g:vaxe_logging
command -nargs=? -complete=customlist,vaxe#nme#Targets NmeTarget call vaxe#nme#Target(<q-args>)
command -nargs=? -complete=customlist,vaxe#nme#Targets NmeClean call vaxe#nme#Clean(<q-args>)
command -nargs=? -complete=customlist,vaxe#nme#Targets NmeUpdate call vaxe#nme#Update(<q-args>)
command -buffer HaxeCtags call vaxe#Ctags()

autocmd FileType haxe setlocal commentstring=//%s

let g:tagbar_type_haxe = {
    \ 'ctagstype' : 'haxe',
    \ 'kinds'     : [
        \ 'c:classes',
        \ 'e:enums',
        \ 'i:interfaces',
        \ 't:typedefs',
        \ 'v:variables',
        \ 'f:functions',
        \ ]
    \ }

let C = function("vaxe#util#Config")

" let g:vaxe_hxml_search_priority = C(g:vaxe_hxml_search_priority, ['**;

" misc options
let g:vaxe_haxe_version        = C('g:vaxe_haxe_version', 2)
let g:vaxe_cache_server_enable = C('g:vaxe_cache_server_enable', 0)
let g:vaxe_logging             = C('g:vaxe_logging', 0)

" default build options
let g:vaxe_prefer_hxml = "build.hxml"
let g:vaxe_prefer_nmml = "*.nmml"
let g:vaxe_default_parent_search_patterns = C('g:vaxe_default_parent_search_glob'
            \, [g:vaxe_prefer_nmml, g:vaxe_prefer_hxml])

" completion options
let g:vaxe_completion_alter_signature   = C('g:vaxe_completion_alter_signature', 1)
let g:vaxe_completion_collapse_overload = C('g:vaxe_completion_collapse_overload', 0)

" cache server options
let g:vaxe_cache_server_port      = C('g:vaxe_cache_server_port', 6878)
let g:vaxe_cache_server_autostart = C('g:vaxe_cache_server_autostart', 1)

" disable bufwrite events
let g:vaxe_prevent_completion_bufwrite_events
            \= C('g:vaxe_prevent_completion_bufwrite_events',1)

" nme options
let g:vaxe_nme_test_on_build     = C('g:vaxe_nme_test_on_build', 1)
let g:vaxe_nme_target            = C('g:vaxe_nme_target',"")
let g:vaxe_nme_completion_target = C('g:vaxe_nme_completion_target', 'flash')

