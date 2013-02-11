if exists("g:loaded_vaxe_plugin")
    finish
endif
let g:loaded_vaxe_plugin = 1

command -nargs=? -complete=file DefaultHxml call vaxe#DefaultHxml(<q-args>)
command -nargs=? -complete=file ProjectHxml call vaxe#ProjectHxml(<q-args>)
command -nargs=? -complete=file ProjectNmml call vaxe#ProjectNmml(<q-args>)
command -nargs=? -complete=file NmeTarget call vaxe#NmeTarget(<q-args>)
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

if !exists("g:vaxe_nme_target")
    let g:vaxe_nme_target  = ""
endif

if !exists("g:vaxe_nme_completion_target")
    let g:vaxe_nme_completion  = "flash"
endif

