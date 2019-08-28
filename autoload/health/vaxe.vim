let s:root = expand('<sfile>:h:h:h')

function! s:checkEnvironment() abort
    let valid = 1
    if !executable('haxe')
        let valid = 0
        call health#report_error('Haxe not found! Please install Haxe >= 4.0')
    endif

    if !executable('haxelib')
        let valid = 0
        call health#report_error('Haxelib not found! Please install Haxe >= 4.0')
    endif

    if !executable('npx')
        let valid = 0
        call health#report_error('npx not found! Please install npx')
    endif

    if !executable('node')
        let valid = 0
        call health#report_error('node not found! Please install node >= 8.10')
    endif

    let lix_output = system('haxelib list lix')
    if v:shell_error && lix_output !=# ""
        let valid = 0
        echohl Error | echom lix_output | echohl None
        return
    endif


    let haxe_v_output = system('haxe --version')
    if v:shell_error && haxe_v_output !=# ""
        let valid = 0
        echohl Error | echom haxe_v_output | echohl None
        return
    endif
    let ms = matchlist(haxe_v_output, '\(\d\+\).\(\d\+\).\(\d\+\)')
    if empty(ms) || str2nr(ms[0]) < 4 
        let valid = 0
        call health#report_error('Haxe version '.haxe_v_output.' < 4, please upgrade haxe')
    endif

    if valid
        call health#report_ok('Environment check passed')
    endif
endfunction

function! health#vaxe#check() abort
    call s:checkEnvironment()
endfunction
