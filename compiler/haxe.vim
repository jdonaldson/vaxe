" Vim compiler file
" Compiler:     haxe
" Maintainer:   Justin Donaldson <jdonaldson@gmail.com>
" Last Change:  2012 May 5

if exists("current_compiler")
  finish
endif
let current_compiler = "haxe"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=haxe

CompilerSet errorformat=%E%f:%l:\ %m,%-Z%p^,%-C%.%#,%-G%.%#