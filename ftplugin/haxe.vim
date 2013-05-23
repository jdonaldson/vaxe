compiler haxe
setlocal omnifunc=vaxe#HaxeComplete
if (!&autowrite)
    echomsg "Please enable autowrite (see :help autowrite) in order for autocompletion to work naturally"
endif
let s:server_started = 0
if g:vaxe_cache_server_enable && !s:server_started
    if has('unix')
        call system("haxe --wait " . g:vaxe_cache_server_port . "&")
        echomsg "started a vaxe cache server on port ". g:vaxe_cache_server_port
        let s:server_started=1
        " let g:vaxe_cache_server_pid = system("echo $!")
        " elseif has('win32') || has('win64')
        "     call system("start haxe --wait " . g:vaxe_cache_server_port)
    else
        echoerr "unsupported platform, send a note to the maintainer about adding support"
    end
    autocmd VimLeave call vaxe#KillCacheServer()
endif
