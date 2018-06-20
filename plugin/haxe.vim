if exists("g:loaded_vaxe_plugin")
    finish
endif

let g:loaded_vaxe_plugin = 1

command -nargs=? -complete=file DefaultHxml call vaxe#DefaultHxml(<q-args>)
command -nargs=? -complete=file ProjectHxml call vaxe#ProjectHxml(<q-args>)
command VaxeToggleLogging let g:vaxe_logging = !g:vaxe_logging

autocmd FileType haxe setlocal commentstring=//%s

" a short alias, since I use this all over the place
let Default = function("vaxe#util#Config")

" misc options
let g:vaxe_logging             = Default('g:vaxe_logging', 0)

" default build options
let g:vaxe_prefer_hxml               = Default('g:vaxe_prefer_hxml', "build.hxml")
let g:vaxe_prefer_lime               = Default('g:vaxe_prefer_lime', "*.lime")
let g:vaxe_prefer_openfl             = Default('g:vaxe_prefer_openfl', "project.xml")
let g:vaxe_prefer_first_in_directory = Default('g:vaxe_prefer_first_in_directory', 1)
let g:vaxe_default_parent_search_patterns
            \= Default('g:vaxe_default_parent_search_patterns'
            \, [g:vaxe_prefer_hxml, "*.hxml"])

" Supported 3rd party plugin options
let g:vaxe_enable_airline_defaults = Default('g:vaxe_enable_airline_defaults', 1)

