" This file contains both syntax files found on haxe.org
" Probably they share much code. I haven't checked yet.

" Vim syntax file
" Language:     haxe

"set errorformat=%f\:%l\:\ characters\ %c-%*[^\ ]\ %m,%f\:%l\:\ %m

" Quit when a syntax file was already loaded
if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  " we define it here so that included files can test for it
  let main_syntax='haxe'
endif

" don't use standard HiLink, it will not work with included syntax files
if version < 508
  command! -nargs=+ HaxeHiLink hi link <args>
else
  command! -nargs=+ HaxeHiLink hi def link <args>
endif

" some characters that cannot be in a haxe program (outside a string)
syn match haxeError "[\\@`]"
syn match haxeError "<<<\|=>\|<>\|||=\|&&=\|\*\/"

" use separate name so that it can be deleted in haxecc.vim
syn match   haxeError2 "#\|=<"
HaxeHiLink haxeError2 haxeError


" keyword definitions
syn keyword haxeExternal	import extern package
syn keyword haxeConditional	if else switch
syn keyword haxeRepeat		while for do in
syn keyword haxeBoolean		true false
syn keyword haxeConstant	null
syn keyword haxeTypedef		this super
syn keyword haxeOperator	new cast 
syn keyword haxeType		Void Bool Int Float Dynamic
syn keyword haxeStatement	return
syn keyword haxeStorageClass    function var final typedef enum
" syn keyword haxeStatic		
syn keyword haxeExceptions      throw try catch finally untyped
syn keyword haxeAssert		assert
syn keyword haxeMethodDecl      synchronized throws
syn keyword haxeClassDecl       extends implements interface
syn match   haxeOperator "\.\.\."
" to differentiate the keyword class from MyClass.class we use a match here
syn match   haxeTypedef		"\.\s*\<class\>"ms=s+1
syn match   haxeClassDecl       "^class\>"
syn match   haxeClassDecl       "[^.]\s*\<class\>"ms=s+1
syn keyword haxeBranch		break continue nextgroup=haxeUserLabelRef skipwhite
syn match   haxeUserLabelRef    "\k\+" contained
syn keyword haxeScopeDecl       static public protected private abstract override  inline


syn keyword Include	macro

" haxe.lang.*
syn match haxeLangClass "\<System\>"
syn keyword haxeLangClass  Array BasicType Class Date DateTools EReg Hash IntHash IntIter Iterator Lambda List Math Md5 Reflect Std String StringBuf StringTools Xml XmlType
HaxeHiLink haxeLangClass		     haxeConstant
HaxeHiLink haxeLangObject		     haxeConstant
syn cluster haxeTop add=haxeLangObject,haxeLangClass
syn cluster haxeClasses add=haxeLangClass

if filereadable(expand("<sfile>:p:h")."/haxeid.vim")
  source <sfile>:p:h/haxeid.vim
endif

if exists("haxe_space_errors")
  if !exists("haxe_no_trail_space_error")
    syn match   haxeSpaceError  "\s\+$"
  endif
  if !exists("haxe_no_tab_space_error")
    syn match   haxeSpaceError  " \+\t"me=e-1
  endif
endif

syn region  haxeLabelRegion     transparent matchgroup=haxeLabel start="\<case\>" matchgroup=NONE end=":" contains=haxeNumber
syn match   haxeUserLabel       "^\s*[_$a-zA-Z][_$a-zA-Z0-9_]*\s*:"he=e-1 contains=haxeLabel
syn keyword haxeLabel		default

" The following cluster contains all haxe groups except the contained ones
syn cluster haxeTop add=haxeExternal,haxeError,haxeError,haxeBranch,haxeLabelRegion,haxeLabel,haxeConditional,haxeRepeat,haxeBoolean,haxeConstant,haxeTypedef,haxeOperator,haxeType,haxeType,haxeStatement,haxeStorageClass,haxeAssert,haxeExceptions,haxeMethodDecl,haxeClassDecl,haxeClassDecl,haxeClassDecl,haxeScopeDecl,haxeError,haxeError2,haxeUserLabel,haxeLangObject


" Comments
syn keyword haxeTodo		 contained TODO FIXME XXX
if exists("haxe_comment_strings")
  syn region  haxeCommentString    contained start=+"+ end=+"+ end=+$+ end=+\*/+me=s-1,he=s-1 contains=haxeSpecial,haxeCommentStar,haxeSpecialChar,@Spell
  syn region  haxeComment2String   contained start=+"+  end=+$\|"+  contains=haxeSpecial,haxeSpecialChar,@Spell
  syn match   haxeCommentCharacter contained "'\\[^']\{1,6\}'" contains=haxeSpecialChar
  syn match   haxeCommentCharacter contained "'\\''" contains=haxeSpecialChar
  syn match   haxeCommentCharacter contained "'[^\\]'"
  syn cluster haxeCommentSpecial add=haxeCommentString,haxeCommentCharacter,haxeNumber
  syn cluster haxeCommentSpecial2 add=haxeComment2String,haxeCommentCharacter,haxeNumber
endif
syn region  haxeComment		 start="/\*"  end="\*/" contains=@haxeCommentSpecial,haxeTodo,@Spell
syn match   haxeCommentStar      contained "^\s*\*[^/]"me=e-1
syn match   haxeCommentStar      contained "^\s*\*$"
syn match   haxeLineComment      "//.*" contains=@haxeCommentSpecial2,haxeTodo,@Spell
HaxeHiLink haxeCommentString haxeString
HaxeHiLink haxeComment2String haxeString

syn cluster haxeTop add=haxeComment,haxeLineComment

if exists("haxe_haxedoc") || main_syntax == 'jsp'
  syntax case ignore
  " syntax coloring for haxedoc comments (HTML)
  " syntax include @haxeHtml <sfile>:p:h/html.vim
  " unlet b:current_syntax
  syn region  haxeDocComment    start="/\*\*"  end="\*/" keepend contains=haxeCommentTitle,@haxeHtml,haxeDocTags,haxeTodo,@Spell
  syn region  haxeCommentTitle  contained matchgroup=haxeDocComment start="/\*\*"   matchgroup=haxeCommentTitle keepend end="\.$" end="\.[ \t\r<&]"me=e-1 end="[^{]@"me=s-2,he=s-1 end="\*/"me=s-1,he=s-1 contains=@haxeHtml,haxeCommentStar,haxeTodo,@Spell,haxeDocTags

  syn region haxeDocTags  contained start="{@\(link\|linkplain\|inherit[Dd]oc\|doc[rR]oot\|value\)" end="}"
  syn match  haxeDocTags  contained "@\(see\|param\|exception\|throws\|since\)\s\+\S\+" contains=haxeDocParam
  syn match  haxeDocParam contained "\s\S\+"
  syn match  haxeDocTags  contained "@\(version\|author\|return\|deprecated\|serial\|serialField\|serialData\)\>"
  syntax case match
endif

" match the special comment /**/
syn match   haxeComment		 "/\*\*/"

" constants
syn match   haxeSpecialError     contained "\\."
" syn match   haxeSpecialCharError contained "[^']"
syn match   haxeSpecialChar      contained "\\\([4-9]\d\|[0-3]\d\d\|[\"\\'ntbrf]\|u\x\{4\}\)"
syn match haxeEregEscape	contained "\(\\\\\|\\/\)"
syn region  haxeEreg		start=+\~\/+ end=+\/[gims]*+ contains=haxeEregEscape

" Strings "foo" and 'bar${x}'
syn region  haxeString		start=+"+ end=+"+ contains=haxeSpecialChar,haxeSpecialError,@Spell
syn match   haxeStringInterpolation      contained "\${[^}]*}"
syn region  haxeSingleString  start=+'+ skip=+\\'+ end=+'+  contains=haxeStringInterpolation

" next line disabled, it can cause a crash for a long line
"syn match   haxeStringError	  +"\([^"\\]\|\\.\)*$+
syn match   haxeNumber		 "\<\(0[0-7]*\|0[xX]\x\+\|\d\+\)[lL]\=\>"
"syn match   haxeNumber		 "\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\=[fFdD]\="
syn match   haxeNumber		 "\(\<\d\+\.\d\+\)\([eE][-+]\=\d\+\)\=[fFdD]\="
syn match   haxeNumber		 "\<\d\+[eE][-+]\=\d\+[fFdD]\=\>"
syn match   haxeNumber		 "\<\d\+\([eE][-+]\=\d\+\)\=[fFdD]\>"


syn match haxeCondIf "#if\>"
syn match haxeCondElse "#else\>"
syn match haxeCondEnd "#end\>"

" unicode characters
syn match   haxeSpecial "\\u\d\{4\}"

if exists("haxe_highlight_functions")
  if haxe_highlight_functions == "indent"
    syn match  haxeFuncDef "^\(\t\| \{8\}\)[_$a-zA-Z][_$a-zA-Z0-9_. \[\]]*([^-+*/()]*)" contains=haxeScopeDecl,haxeType,haxeStorageClass,@haxeClasses
    syn region haxeFuncDef start=+^\(\t\| \{8\}\)[$_a-zA-Z][$_a-zA-Z0-9_. \[\]]*([^-+*/()]*,\s*+ end=+)+ contains=haxeScopeDecl,haxeType,haxeStorageClass,@haxeClasses
    syn match  haxeFuncDef "^  [$_a-zA-Z][$_a-zA-Z0-9_. \[\]]*([^-+*/()]*)" contains=haxeScopeDecl,haxeType,haxeStorageClass,@haxeClasses
    syn region haxeFuncDef start=+^  [$_a-zA-Z][$_a-zA-Z0-9_. \[\]]*([^-+*/()]*,\s*+ end=+)+ contains=haxeScopeDecl,haxeType,haxeStorageClass,@haxeClasses
  else
    " This line catches method declarations at any indentation>0, but it assumes
    " two things:
    "   1. class names are always capitalized (ie: Button)
    "   2. method names are never capitalized (except constructors, of course)
    syn region haxeFuncDef start=+^\s\+\(\(public\|protected\|private\|static\|abstract\|override\|final\|native\|synchronized\)\s\+\)*\(\(void\|boolean\|char\|byte\|short\|int\|long\|float\|double\|\([A-Za-z_][A-Za-z0-9_$]*\.\)*[A-Z][A-Za-z0-9_$]*\)\(\[\]\)*\s\+[a-z][A-Za-z0-9_$]*\|[A-Z][A-Za-z0-9_$]*\)\s*(+ end=+)+ contains=haxeScopeDecl,haxeType,haxeStorageClass,haxeComment,haxeLineComment,@haxeClasses
  endif
  syn match  haxeBraces  "[{}]"
  syn cluster haxeTop add=haxeFuncDef,haxeBraces
endif

if exists("haxe_mark_braces_in_parens_as_errors")
  syn match haxeInParen		 contained "[{}]"
  HaxeHiLink haxeInParen	haxeError
  syn cluster haxeTop add=haxeInParen
endif

" catch errors caused by wrong parenthesis
syn region  haxeParenT  transparent matchgroup=haxeParen  start="("  end=")" contains=@haxeTop,haxeParenT1,haxeString,haxeSingleString
syn region  haxeParenT1 transparent matchgroup=haxeParen1 start="(" end=")" contains=@haxeTop,haxeParenT2 contained
syn region  haxeParenT2 transparent matchgroup=haxeParen2 start="(" end=")" contains=@haxeTop,haxeParenT  contained
syn match   haxeParenError       ")"
HaxeHiLink haxeParenError       haxeError

if !exists("haxe_minlines")
  let haxe_minlines = 10
endif
exec "syn sync ccomment haxeComment minlines=" . haxe_minlines

" The default highlighting.
if version >= 508 || !exists("did_haxe_syn_inits")
  if version < 508
    let did_haxe_syn_inits = 1
  endif
  HaxeHiLink haxeFuncDef		Function
  HaxeHiLink haxeBraces		Function
  HaxeHiLink haxeBranch		Conditional
  HaxeHiLink haxeUserLabelRef	haxeUserLabel
  HaxeHiLink haxeLabel		Label
  HaxeHiLink haxeUserLabel		Label
  HaxeHiLink haxeConditional	Conditional
  HaxeHiLink haxeRepeat		Repeat
  HaxeHiLink haxeExceptions		Exception
  HaxeHiLink haxeAssert		Statement
  HaxeHiLink haxeStatic MoreMsg
  HaxeHiLink haxeStorageClass	StorageClass
  HaxeHiLink haxeMethodDecl		haxeStorageClass
  HaxeHiLink haxeClassDecl		haxeStorageClass
  HaxeHiLink haxeScopeDecl		haxeStorageClass
  HaxeHiLink haxeBoolean		Boolean
  HaxeHiLink haxeSpecial		Special
  HaxeHiLink haxeSpecialError	Error
  HaxeHiLink haxeSpecialCharError	Error
  HaxeHiLink haxeString		String
  HaxeHiLink haxeStringInterpolation Include
  HaxeHiLink haxeSingleString	String
  HaxeHiLink haxeEreg Special
  HaxeHiLink haxeEregEscape Special
  HaxeHiLink haxeSpecialChar	SpecialChar
  HaxeHiLink haxeNumber		Number
  HaxeHiLink haxeError		Error
  HaxeHiLink haxeStringError	Error
  HaxeHiLink haxeStatement		Statement
  HaxeHiLink haxeOperator		Operator
  HaxeHiLink haxeComment		Comment
  HaxeHiLink haxeDocComment		Comment
  HaxeHiLink haxeLineComment	Comment
  HaxeHiLink haxeConstant		Constant
  HaxeHiLink haxeTypedef		Typedef
  HaxeHiLink haxeTodo		Todo

  HaxeHiLink haxeCommentTitle	SpecialComment
  HaxeHiLink haxeDocTags		Special
  HaxeHiLink haxeDocParam		Function
  HaxeHiLink haxeCommentStar	haxeComment

  HaxeHiLink haxeType		Type
  HaxeHiLink haxeExternal		Include

  HaxeHiLink htmlComment		Special
  HaxeHiLink htmlCommentPart	Special
  HaxeHiLink haxeSpaceError		Error

  HaxeHiLink haxeCondIf Macro
  HaxeHiLink haxeCondElse Macro
  HaxeHiLink haxeCondEnd Macro
  HaxeHiLink haxeCondError Error
endif

delcommand HaxeHiLink

let b:current_syntax = "haxe"

if main_syntax == 'haxe'
  unlet main_syntax
endif

let b:spell_options="contained"

if exists('g:haxe_conceal') && has("conceal")
  syn match Ignore 'urn' transparent conceal containedin=haxeStatement
  syn match Ignore 'ction' transparent conceal containedin=haxeStorageClass,haxeStatement
  syn match Ignore 'ati' transparent conceal containedin=haxeStorageClass
  syn match Ignore 'nline\|tati\|ubli' transparent conceal containedin=haxeScopeDecl
endif
