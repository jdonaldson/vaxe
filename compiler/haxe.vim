" Vim compiler file
" Compiler:     haxe
" Maintainer:   Justin Donaldson <jdonaldson@gmail.com>

" prefer build.hxml files
if !exists('g:vihxen_prefer_hxml')
    let g:vihxen_prefer_hxml = '**/build.hxml'
endif

" select a build file if none is available
if !exists("b:vihxen_hxml")
    let b:vihxen_build = vihxen#FindHxml(g:vihxen_prefer_hxml, 1)
endif


