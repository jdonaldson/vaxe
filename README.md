Vihxen is a vim bundle for [Haxe](http://www.haxe.org).  It provides support
for syntax highlighting, indenting, compiling, and many more options.

![Vihxen Screenshot](http://i.imgur.com/JFvze.png)
(screenshot shows neocomplcache completion mode, vim-powerline, taglist, and monokai color theme)

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

Once found, a variable `b:vihxen_hxml` will be set for the current buffer.
In some cases, you may wish to override this behavior for certain files.  E.g.,
perhaps you are working with a project that contains multiple build files. 
In this case, you can also search for a valid hxml file in the working directory:

    :call vihxen#ProjectHxml()

This sets a `g:vihxen_hxml` variable that will override any buffer variable 
that may be set.

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
completions.  It is possible to specify a different target by
inserting a line like this into your hxml:

    # vihxen

If vihxen finds that line, it will use that target to generate completions and
perform other miscellaneous tasks.  The target that Vihxen uses is called the
"active" target here.

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
[ctags](http://vimdoc.sourceforge.net/htmldoc/tagsrch.html), which are really
useful for navigating a large code base.

You'll need to define some patterns for ctags in order for it to work with
Haxe.  Put these lines in your `.ctags` file in your home directory:

    --langdef=haxe
    --langmap=haxe:.hx
    --regex-haxe=/^package[ \t]+([A-Za-z0-9_.]+)/\1/p,package/
    --regex-haxe=/^[ \t]*[(@:macro|private|public|static|override|inline|dynamic)( \t)]*function[ \t]+([A-Za-z0-9_]+)/\1/f,function/
    --regex-haxe=/^[ \t]*([@:\w+|private|public|static|protected|inline][ \t]*)+var[ \t]+([A-Za-z0-9_]+)/\2/v,variable/
    --regex-haxe=/^[ \t]*package[ \t]*([A-Za-z0-9_]+)/\1/p,package/
    --regex-haxe=/^[ \t]*(extern[ \t]+)?class[ \t]+([A-Za-z0-9_]+)[ \t]*[^\{]*/\2/c,class/
    --regex-haxe=/^[ \t]*(extern[ \t]+)?interface[ \t]+([A-Za-z0-9_]+)/\2/i,interface/
    --regex-haxe=/^[ \t]*typedef[ \t]+([A-Za-z0-9_]+)/\1/t,typedef/
    --regex-haxe=/^[ \t]*enum[ \t]+([A-Za-z0-9_]+)/\1/t,typedef/


Vihxen has a special function `vihxen#Ctags()` that will generate tags for the
current compilation target.  This function uses the same "Dealing with
multiple completion targets" method to determine an "active" target. For this
to work, it is necessary to have a hxml file specified (b:vihxen_hxml).  This
function will call `ctags -R` on all of the class paths currently used by the
haxe compiler for the given target, including any paths set for haxelib
libraries.  Remember to regenerate your tags if you change your target.

## Taglist

Using the ctags lines above, the
[Taglist](https://github.com/vim-scripts/taglist.vim) bundle can display a nice
overview of the classes, methods, and variables in your current haxe file.  You
do not need to call `vihxen#Ctags()` in order to use Taglist, it works
automatically, but only for the current Vihxen buffer.

## Neocomplcache

[Neocomplcache](https://github.com/Shougo/neocomplcache) is a
plugin for vim that can manage virtually any type of
completion (omni, keyword, file, etc). It won't use omnicompletion by default
since it is slow for some languages.  However, since completions are built into
the compiler with Haxe, they are very fast.  In order to enable automatic
completions, you will need to add this to your `.vimrc`:

    if !exists('g:neocomplcache_omni_patterns')
        let g:neocomplcache_omni_patterns = {}
    endif
    let g:neocomplcache_omni_patterns.haxe = '\v([\]''"]|\w)(\.|\()'

Once enabled, Neocomplcache will automatically invoke Vihxen omnicompletion
when you type a "." after a variable with fields, etc.

# Acknowledgements
* Marc Weber (marco-oweber@gmx.de) : Most of the syntax and snippets are based 
off of his [vim bundle](https://github.com/MarcWeber/vim-haxe).

* Ganesh Gunasegaran(me at itsgg.com) : I based my hxml syntax file off of [his
version](http://lists.motion-twin.com/pipermail/haxe/2008-July/018220.html).

