if exists("g:loaded_vihxen_plugin")
    finish
endif
let g:loaded_vihxen_plugin = 1

let g:tagbar_type_haxe = {
    \ 'ctagstype' : 'haxe',
    \ 'kinds'     : [
        \ 'c:classes',
        \ 'v:variables',
        \ 'f:functions',
    \ ]
        \ }

" prevent buffer write events triggered by completions
if !exists("g:vihxen_prevent_completion_bufwrite_events")
    let g:vihxen_prevent_completion_bufwrite_events = 1
endif

" prefer build.hxml files
if !exists('g:vihxen_prefer_hxml')
    let g:vihxen_prefer_hxml = 'build.hxml'
endif

