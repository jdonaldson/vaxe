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

# Compilation with HXML files

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

Vihxen will specify a custom
[makeprg](http://vimdoc.sourceforge.net/htmldoc/options.html#'makeprg') using
the given hxml file. The makeprg will cd to the directory containing the hxml,
execute the haxe compiler with the hxml file, and pipe output to stdout.

Vihxen will also specify an
[errorformat](http://vimdoc.sourceforge.net/htmldoc/options.html#'errorformat'),
so that errors and trace messages show up in the
[quickfix](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#quickfix)
window. 

# Recommended Plugins
Vihxen will work fine on its own, but it is designed to integrate cleanly with 
a number of other plugins.

