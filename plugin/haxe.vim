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

if !exists("g:vaxe_cache_server_enable")
    let g:vaxe_cache_server_enable = 0
endif
if !exists("g:vaxe_haxe_version")
    let g:vaxe_haxe_version = 2
endif

if !exists("g:vaxe_cache_server_port")
    " 'hx' in hex code! AFAICT this isn't a commonly used port...
    let g:vaxe_cache_server_port = 6878
endif

if !exists("g:vaxe_cache_server_autostart")
    let g:vaxe_cache_server_autostart = 1

endif

" prevent buffer write events triggered by completions
if !exists("g:vaxe_prevent_completion_bufwrite_events")
    let g:vaxe_prevent_completion_bufwrite_events = 1
endif

" prefer build.hxml files
if !exists('g:vaxe_prefer_hxml')
    let g:vaxe_prefer_hxml = 'build.hxml'
endif

" disable logging
if !exists('g:vaxe_logging')
    let g:vaxe_logging = 0
endif

if !exists("g:vaxe_nme_test_on_build")
    let g:vaxe_nme_test_on_build = 1
endif

if !exists("g:vaxe_nme_target")
    let g:vaxe_nme_target  = ""
endif

if !exists("g:vaxe_nme_completion_target")
    let g:vaxe_nme_completion_target  = "flash"
endif

