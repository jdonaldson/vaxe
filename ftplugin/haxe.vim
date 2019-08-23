compiler haxe


" load special configuration for vim-airline if it exists
if (exists("g:airline_statusline_funcrefs") && g:vaxe_enable_airline_defaults )
   function! AirlineBuild(...)
      if &filetype == 'haxe'
         let w:airline_section_c =
                  \  '%{vaxe#AirlineProject()}'
                  \. ' %{pathshorten(fnamemodify(vaxe#CurrentBuild(), ":."))}'
                  \. g:airline_left_alt_sep
                  \. ' %f%m'
      endif
   endfunction
   call add(g:airline_statusline_funcrefs, function('AirlineBuild'))
endif


