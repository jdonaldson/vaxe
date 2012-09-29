compiler haxe
setlocal omnifunc=vaxe#HaxeComplete
command! -nargs=? -complete=file -buffer DefaultHxml call vaxe#DefaultHxml(<q-args>)
command! -nargs=? -complete=file -buffer ProjectHxml call vaxe#ProjectHxml(<q-args>)
command! -buffer HaxeCtags call vaxe#Ctags()

" set quickfix to jump to working directory before populating list
autocmd QuickFixCmdPre <buffer>  exe 'cd ' . g:vaxe_working_directory
autocmd QuickFixCmdPost <buffer>  cd -
