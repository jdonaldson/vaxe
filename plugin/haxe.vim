if exists("g:loaded_vaxe_plugin")
    finish
endif
let g:loaded_vaxe_plugin = 1

command -nargs=? -complete=file DefaultHxml call vaxe#DefaultHxml(<q-args>)
command -nargs=? -complete=file ProjectHxml call vaxe#ProjectHxml(<q-args>)
command ToggleVaxeLogging let g:vaxe_logging = !g:vaxe_logging

" Nme commands
command -nargs=? -complete=file ProjectNmml call vaxe#nme#ProjectNmml(<q-args>)
command -nargs=? -complete=customlist,vaxe#nme#Targets NmeTarget call vaxe#nme#Target(<q-args>)
command -nargs=? -complete=customlist,vaxe#nme#Targets NmeClean call vaxe#nme#Clean(<q-args>)
command -nargs=? -complete=customlist,vaxe#nme#Targets NmeUpdate call vaxe#nme#Update(<q-args>)

" Openfl commands
command -nargs=? -complete=file ProjectOpenfl call vaxe#openfl#ProjectOpenfl(<q-args>)
command -nargs=? -complete=customlist,vaxe#openfl#Targets OpenflTarget call vaxe#openfl#Target(<q-args>)
command -nargs=? -complete=customlist,vaxe#openfl#Targets OpenflClean  call vaxe#openfl#Clean(<q-args>)
command -nargs=? -complete=customlist,vaxe#openfl#Targets OpenflUpdate call vaxe#openfl#Update(<q-args>)

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

" misc options
let g:vaxe_haxe_version        = C('g:vaxe_haxe_version', 2)
let g:vaxe_cache_server_enable = C('g:vaxe_cache_server_enable', 0)
let g:vaxe_logging             = C('g:vaxe_logging', 0)


" completion options
let g:vaxe_completion_alter_signature
            \= C('g:vaxe_completion_alter_signature', 1)
let g:vaxe_completion_collapse_overload
            \= C('g:vaxe_completion_collapse_overload', 0)
let g:vaxe_completion_write_compiler_output
            \= C('g:vaxe_completion_write_compiler_output', 0)
let g:vaxe_completion_prevent_bufwrite_events
            \= C('g:vaxe_completion_prevent_bufwrite_events',1)

" cache server options
let g:vaxe_cache_server_port      = C('g:vaxe_cache_server_port', 6878)
let g:vaxe_cache_server_autostart = C('g:vaxe_cache_server_autostart', 1)


" nme options
let g:vaxe_nme_test_on_build     = C('g:vaxe_nme_test_on_build', 1)
let g:vaxe_nme_target            = C('g:vaxe_nme_target',"")
let g:vaxe_nme_completion_target = C('g:vaxe_nme_completion_target', 'flash')

" openfl options
let g:vaxe_openfl_test_on_build     = C('g:vaxe_nme_test_on_build', 1)
let g:vaxe_openfl_target            = C('g:vaxe_nme_target',"")
let g:vaxe_openfl_completion_target = C('g:vaxe_nme_completion_target', 'flash')

" default build options
let g:vaxe_prefer_hxml = C('g:vaxe_prefer_hxml', "build.hxml")
let g:vaxe_prefer_nmml = C('g:vaxe_prefer_nmml', "*.nmml")
let g:vaxe_prefer_openfl = C('g:vaxe_prefer_openfl', "project.xml")
let g:vaxe_prefer_first_in_directory = C('g:vaxe_prefer_first_in_directory', 1)
let g:vaxe_default_parent_search_patterns = C('g:vaxe_default_parent_search_patterns'
            \, [g:vaxe_prefer_openfl, g:vaxe_prefer_nmml, g:vaxe_prefer_hxml])

" plugin options
let g:vaxe_enable_airline = C('g:vaxe_enable_airline', 1)

