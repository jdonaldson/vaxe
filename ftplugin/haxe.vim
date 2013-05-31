compiler haxe
setlocal omnifunc=vaxe#HaxeComplete

if (!&autowrite)
    echomsg "Please enable autowrite (see :help autowrite) in order for vaxe autocompletion to work naturally"
endif

" Start a server the first time a hx file is edited
if g:vaxe_cache_server_enable && ! exists('g:vaxe_cache_server_pid')
    call vaxe#StartCacheServer()
endif

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
