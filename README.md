[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/jdonaldson/vaxe?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Vaxe is a vim bundle for [Haxe][haxe] and [Hss][ncannasse].  It provides support
for syntax highlighting, indenting, compiling, and many more options.  Vaxe has
[vimdoc][github], accessible using `:help vaxe` within vim.

Vaxe requires additional vim features in order to work fully:

1. Neovim > 0.3
2. LanguageClient-nvim

This page will describe some of the special or optional features that vaxe
supports, in addition to recommended configuration settings.

# Install with vim-plug

Add vaxe to your plugin list in `.vimrc` and re-source it:

    ```viml
    call plug#begin('~/.vim/plugged')

    Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

    Plug 'jdonaldson/vaxe' { 'branch' : 'neovaxe'}

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

Vaxe will also specify an
[errorformat][sourceforge 2],
so that errors and trace messages show up in the
[quickfix][sourceforge 3]
window.

## Lime Project Support
![Lime][imgur 2]

Vaxe supports [Lime][github 2]
workflows.  If a Lime project is found, Vaxe will use it for builds and
completions. You can specify a default target if you only work with one
platform.


# HSS Support
Vaxe will also support the [hss][ncannasse] language,
with support for syntax highlighting, and compilation to css.

# Recommended Plugins/Additions/Config

Vaxe will work fine on its own, but it is designed to integrate cleanly with
a number of other bundles and plugins. Once again, it is recommended to use
pathogen, vundle, or vam to manage installation and updates.

## Airline

Airline ( [by Bailey Ling][github 3]) is a handy
[status line][sourceforge 5]
replacement.  I think it looks better, and provides a good deal more
functionality over a normal status line setting.  Airline support is provided by
default in vaxe.  Current support enables the display of the current hxml build
file.  The hxml name has an empty star if it's in default mode (☆ ), and a
filled star if it's in project mode (★ ).  You can disable all of this by
changing ```g:vaxe_enable_airline``` to 0.



