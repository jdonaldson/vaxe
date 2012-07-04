compiler haxe
setlocal omnifunc=vaxe#HaxeComplete
command! -nargs=? -complete=file -buffer DefaultHxml call vaxe#DefaultHxml(<q-args>)
command! -nargs=? -complete=file -buffer ProjectHxml call vaxe#ProjectHxml(<q-args>)
command! -buffer HaxeCtags call vaxe#Ctags()
