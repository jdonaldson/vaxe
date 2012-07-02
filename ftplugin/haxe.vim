compiler haxe
setlocal omnifunc=vaxe#HaxeComplete
command! -buffer DefaultHxml call vaxe#DefaultHxml()
command! -buffer ProjectHxml call vaxe#ProjectHxml()
command! -buffer HaxeCtags call vaxe#Ctags()
