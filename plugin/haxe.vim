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

" ignore buffer write events triggered by completions
if !exists("g:vihxen_ignore_completion_events")
    let g:vihxen_ignore_completion_events = 1
endif

