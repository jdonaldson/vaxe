" Vim compiler file
" Compiler:     haxe
" Maintainer:   Justin Donaldson <jdonaldson@gmail.com>



" select a build file if none is available
" this function sets the makeprg
if !exists("b:vaxe_hxml")
    call vaxe#AutomaticHxml()
endif

" errorformat captures error with character range, with lines, or a general
" output on standard out

let &l:errorformat="%E%f:%l: characters %c-%*[0-9] : %m
            \,%E%f:%l: lines %*[0-9]-%*[0-9] : %m
            \,%I%m"

