[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/jdonaldson/vaxe?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Vaxe is a vim bundle for [Haxe][https://haxe.org/] and
[Hss][https://github.com/ncannasse/hss].  It provides support for syntax
highlighting, indenting, compiling, and many more options.  Vaxe has vimdoc,
accessible using `:help vaxe` within vim.

Vaxe is designed to work with very recent versions of vim and neovim.  In
general, make sure that your vim runtime supports asynchronous I/O, virtual
text, and floating windows.  Also make sure that you are using updated plugins
and colorschemes.


This page will describe some of the special or optional features that vaxe
supports, in addition to recommended configuration settings.

# Install with vim-plug

Add vaxe to your plugin list in `.vimrc` and re-source it:

```viml
call plug#begin('~/.vim/plugged')


Plug 'jdonaldson/vaxe', {'branch' : 'neovaxe', 'do' : 'sh install.sh'}

" add coc.nvim and recommended extensions
Plug 'neoclide/coc.nvim'
    let g:coc_global_extensions = ['coc-snippets']

"add snippets and add additional directories for vaxe snippets
Plug 'SirVer/ultisnips'
    let g:UltiSnipsSnippetDirectories=["UltiSnips", "bundle/UltiSnips/UltiSnips"]

call plug#end()
```


# Compiling Haxe Projects with vaxe

## HXML File Support

Vaxe will automatically try to determine the appropriate hxml file you are
using.  It will also let you easily override this with a specific file
(see vim docs for more details).

If vaxe has found your build file, you can just run the make command:

```viml
:make
```

Vaxe will also specify an errorfmt so that errors and trace messages show up in
the quickfix window.

## Lime Project Support

Vaxe supports [Lime][https://github.com/openfl/lime]
workflows.  If a Lime project is found, Vaxe will use it for builds and
completions. You can specify a default target if you only work with one
platform.


# HSS Support

Vaxe will also support the [hss][https://github.com/ncannasse/hss] preprocessor,
with support for syntax highlighting, and compilation to css.

# Recommended Plugins/Additions/Config

Vaxe will work fine on its own, but it is designed to integrate cleanly with
a number of other bundles and plugins. Once again, it is recommended to use
pathogen, vundle, or vam to manage installation and updates.


## Colorscheme - gruvbox

Vim and Neovim have additional features (e.g. pmenu, floating/virtual text) that
may produce jarring color combinations on older colorschemes.  It is recommended
to use a colorscheme that handles these new features.  The screenshots here use
a color scheme called [gruvbox by morhetz](https://github.com/morhetz/gruvbox).

## Completions - Coc.nvim

Coc.nvim ([by neoclide][https://github.com/neoclide/coc.nvim]) is a full
featured intellisense engine.  Vaxe will detect and automatically configure
Coc.nvim if it detects it running on startup.

Coc.nvim is a very complex plugin that has extensive options.  Please read the
documentation thoroughly.

## Status Bar - Airline

Airline ( [by Bailey Ling][https://github.com/vim-airline/vim-airline]) is a
handy status line replacement.  I think it looks better, and provides a good
deal more functionality over a normal status line setting.  Airline support is
provided by default in vaxe.  Current support enables the display of the current
hxml build file.  The hxml name has an empty star if it's in default mode (☆ ),
and a filled star if it's in project mode (★ ).  You can disable all of
this by changing ```g:vaxe_enable_airline``` to 0.

