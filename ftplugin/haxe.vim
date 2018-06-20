compiler haxe


let run_once = 0

if (!run_once)

   " Utility variable that stores the directory that this script resides in
   "Load the first time a haxe file is opened
   let s:plugin_path = escape(expand('<sfile>:p:h') . '/../python/', '\')
   " load special configuration for vim-airline if it exists
   if (exists("g:loaded_airline") && g:vaxe_enable_airline_defaults )
      function! AirlineBuild(...)
         if &filetype == 'haxe'
            let w:airline_section_c =
                     \  '%{VaxeAirlineProject()}'
                     \. ' %{pathshorten(fnamemodify(vaxe#CurrentBuild(), ":."))}'
                     \. g:airline_left_alt_sep
                     \. ' %f%m'
         endif
      endfunction
      call add(g:airline_statusline_funcrefs, function('AirlineBuild'))
   endif
endif

function! VaxeAirlineProject()
   return exists("g:vaxe_hxml") ? '★ ' : '☆ '
endfunction

