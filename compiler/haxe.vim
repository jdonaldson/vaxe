" Vim compiler file
" Compiler:     haxe
" Maintainer:   Justin Donaldson <jdonaldson@gmail.com>



" select a build file if none is available
" this function sets the makeprg
if !exists("b:vaxe_hxml")
    let b:vaxe_build = vaxe#DefaultHxml()
endif

let &l:errorformat="%E%f:%l: characters %c-%*[0-9] : %m,%I%m"

