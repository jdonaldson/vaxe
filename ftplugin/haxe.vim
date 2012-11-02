compiler haxe
setlocal omnifunc=vaxe#HaxeComplete

" set quickfix to jump to working directory before populating list
autocmd QuickFixCmdPre <buffer>  exe 'cd ' . g:vaxe_working_directory
autocmd QuickFixCmdPost <buffer>  cd -
