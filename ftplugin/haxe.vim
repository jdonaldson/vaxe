compiler haxe
setlocal omnifunc=vaxe#HaxeComplete

if (!&autowrite)
    echomsg "Please enable autowrite (see :help autowrite) in order for vaxe autocompletion to work naturally"
endif

" Start a server the first time a hx file is edited
let g:vaxe_cache_server_started = 0
if g:vaxe_cache_server_enable && g:vaxe_cache_server_started == 0
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
let g:vaxe_cache_server_started = 1

"Load the first time a haxe file is opened
let g:vaxe_python_script_loaded = 0
if !has("python") && g:vaxe_python_script_loaded == 0
    echomsg 'Vaxe requires python for a lot of functionality.  '
                \'Please use a version of vim compiled with python support'
else
    " Utility variable that stores the directory that this script resides in
    let s:plugin_path = escape(expand('<sfile>:p:h') . '/../python/', '\')
    exe 'pyfile '.s:plugin_path.'/vaxe.py'
endif
let g:vaxe_python_script_loaded = 1
