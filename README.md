Vihxen is a vim bundle for [Haxe](http://www.haxe.org).  It provides support
for syntax highlighting, indenting, compiling, and many more options.

The recommended way to install vihxen is using a bundle management system such
as [pathogen][] or
[vundle][].

# Install with Pathogen

1. Install pathogen using the [instructions][pathogen]. 
2. Create/cd into `~/.vim/bundle/`
3. Make a clone of the vihxen repo:
    git clone https://github.com/jdonaldson/vihxen.git

To update:

1. cd into `~/.vim/bundle/vihxen/`
2. git pull

# Install with Vundle

1. Install vundle using the [instructions][vundle] 
2. Add vihxen to your bundle list in `.vimrc`:
    Bundle 'jdonaldson/vihxen'
3. Run :BundleInstall

To update, just run `:BundleInstall!`

[pathogen]:https://github.com/tpope/vim-pathogen
[vundle]:https://github.com/gmarik/vundle

# Compiling Haxe Projects with Vihxen 

## HXML File Support
Vihxen supports [hxml build files](http://haxe.org/doc/compiler), which provide
all of the arguments for the compiler, similar to a  [make
file](http://en.wikipedia.org/wiki/Make_(software). 


Vihxen will attempt to find a suitable hxml file by looking in the current
working directory, and checking each parent folder for a `build.hxml` file.
You can change the name of the preferred build file name by setting a variable
in your `.vimrc`:

    let g:vihxen_preferred_hxml = "some_other_file_name.hxml"

You can also search for a valid hxml file using a vim file glob:

    :call vihxen#FindHxml("**/*.hxml")

Once found, a variable `b:vihxen_hxml` will be set for the current buffer.

Vihxen will specify a custom
[makeprg](http://vimdoc.sourceforge.net/htmldoc/options.html#'makeprg') using
the given hxml file. The makeprg will cd to the directory containing the hxml,
execute the haxe compiler with the hxml file, and pipe output to stdout.

Vihxen will also specify an
[errorformat](http://vimdoc.sourceforge.net/htmldoc/options.html#'errorformat'),
so that errors and trace messages show up in the
[quickfix](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#quickfix)
window. 

## Omni-completions

Vihxen provides an
[omnicompletion](http://vimdoc.sourceforge.net/htmldoc/version7.html#new-omni-completion)
function that can use the haxe compiler in order to [display field
completions](http://haxe.org/manual/completion).  Visual Studio users will
recognize this as being similar to "intellisense".

You can trigger an omnicompletion (C-X C-O in Insert Mode) after the period at
the start of a field, submodule, or class access, or after the first
parentheses of a function invocation. See the [haxe
documentation](http://haxe.org/manual/completion) for more details.

### Dealing with multiple completion targets

In some cases, an hxml file may specify multiple targets via a `--next`
directive.  Vihxen will use the first target it finds in order to generate
completions by default.  It is possible to specify a different target by
inserting a line like this into your hxml:

    # vihxen

If vihxen finds that line, it will use that target to generate completions.

# Recommended Plugins/Additions

Vihxen will work fine on its own, but it is designed to integrate cleanly with 
a number of other bundles and plugins. Once again, it is recommended to use 
pathogen or vundle to manage installation and updates.

## Powerline

Powerline ( [by Kim Silkebækken](https://github.com/lokaltog)) is a handy
[status line](http://vimdoc.sourceforge.net/htmldoc/windows.html#status-line)
replacement.  I think it looks better, and provides a good deal more
functionality over a normal status line setting.  Unfortunately, Powerline is
still fairly new, and doesn't have a plugin framework for it yet.  So, I have a
special branch of it available [here on
github](https://github.com/jdonaldson/vim-powerline).

When it is installed, the current hxml build file will be displayed next to the
file info.

## Tags 

Vim has great support for
[ctags](http://vimdoc.sourceforge.net/htmldoc/tagsrch.html). While ctags were
originally developed for the C language, they can be used by virtually any
other language.  They provide a way of quickly navigating through a complex
project structure, and for looking up details on classes, variables, and other
fields.

Vihxen has a special function `vihxen#Ctags()` that will generate tags for the
current compilation target (using the same "Dealing with multiple completion
        targets" method). For this to work, it is necessary to have a hxml file
specified (b:vihxen_hxml).  This function will call `ctags -R` on all of the
class paths currently used by the haxe compiler for the given target, including
any paths set by haxelib. 

# Acknowledgements


