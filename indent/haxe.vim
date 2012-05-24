
" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" Indent Haxe anonymous classes correctly.
setlocal cindent cinoptions& cinoptions+=j1

" Set the function to do the work.
setlocal indentexpr=GetHaxeIndent()

let b:undo_indent = "set cin< cino< indentkeys< indentexpr<"

" Only define the function once.
if exists("*GetHaxeIndent")
  finish
endif

function! SkipHaxeBlanksAndComments(startline)
  let lnum = a:startline
  while lnum > 1
    let lnum = prevnonblank(lnum)
    if getline(lnum) =~ '\*/\s*$'
      while getline(lnum) !~ '/\*' && lnum > 1
        let lnum = lnum - 1
      endwhile
      if getline(lnum) =~ '^\s*/\*'
        let lnum = lnum - 1
      else
        break
      endif
    elseif getline(lnum) =~ '^\s*//'
      let lnum = lnum - 1
    elseif getline(lnum) =~'^\s*#'
      let lnum = lnum -1
    else
      break
    endif
  endwhile
  return lnum
endfunction

function GetHaxeIndent()

" Haxe is just like C; use the built-in C indenting and then correct a few
" specific cases.
  let theIndent = cindent(v:lnum)

" If we're in the middle of a comment then just trust cindent
  if getline(v:lnum) =~ '^\s*\*'
    return theIndent
  endif

" find start of previous line, in case it was a continuation line
  let lnum = SkipHaxeBlanksAndComments(v:lnum - 1)

" If the previous line starts with '@', we should have the same indent as
" the previous one
  if getline(lnum) =~ '^\s*@\S\+\s*$'
    return indent(lnum)
  endif

  let prev = lnum
  while prev > 1
    let next_prev = SkipHaxeBlanksAndComments(prev - 1)
    if getline(next_prev) !~ ',\s*$'
      break
    endif
    let prev = next_prev
  endwhile



" When the line starts with a }, try aligning it with the matching {,
  if getline(v:lnum) =~ '^\s*}\s*\(//.*\|/\*.*\)\=$'
    call cursor(v:lnum, 1)
    silent normal %
    let lnum = line('.')
    if lnum < v:lnum
      while lnum > 1
        let next_lnum = SkipHaxeBlanksAndComments(lnum - 1)
        if getline(lnum) !~ '^\s*\(throws\|extends\|implements\)\>'
              \ && getline(next_lnum) !~ ',\s*$'
          break
        endif
        let lnum = prevnonblank(next_lnum)
      endwhile
      return indent(lnum)
    endif
  endif


  return theIndent
endfunction

" vi: sw=2 et

