Vaxe is a vim bundle for [Haxe](http://www.haxe.org).  It provides support
for syntax highlighting, indenting, compiling, and many more options.  vaxe
has "vimdoc" documentation, so check that for in depth details.  This page will
describe some of the special or optional features that vaxe supports, in
addition to recommended configuration settings.

![Vaxe Screenshot](http://i.imgur.com/JFvze.png) (screenshot shows
neocomplcache completion mode, vim-powerline, tagbar, and monokai color theme)

The recommended way to install vaxe is using a bundle management system such
as [pathogen][], [vundle][], or [vam][].

# Install with Pathogen

1. Install pathogen using the [instructions][pathogen].
2. Create/cd into `~/.vim/bundle/`
3. Make a clone of the vaxe repo:
    git clone https://github.com/jdonaldson/vaxe.git

To update:

1. cd into `~/.vim/bundle/vaxe/`
2. git pull

# Install with Vundle

1. Install vundle using the [instructions][vundle]
2. Add vaxe to your bundle list in `.vimrc` and re-source it:
    Bundle 'jdonaldson/vaxe'
3. Run :BundleInstall

To update, just run `:BundleInstall!`

# Install with VAM

1. Install VAM using the [instructions][vam]
2. Add vaxe to the list of your activated bundles and re-source it:
    call vam#ActivateAddons(['github:jdonaldson/vaxe'])


[pathogen]:https://github.com/tpope/vim-pathogen

[vundle]:https://github.com/gmarik/vundle

[vam]:https://github.com/MarcWeber/vim-addon-manager

# Compiling Haxe Projects with vaxe

## HXML File Support
Vaxe supports [hxml build files](http://haxe.org/doc/compiler), which provide
all of the arguments for the compiler, similar to a  [make
file](http://en.wikipedia.org/wiki/Make_(software).

Vaxe will automatically try to determine the appropriate hxml file you are 
using.  It will also let you easily override this with a specific file
(see vim docs for more details).

Vaxe will specify a custom
[makeprg](http://vimdoc.sourceforge.net/htmldoc/options.html#'makeprg') using
the given hxml file. The makeprg will cd to the directory containing the hxml,
execute the haxe compiler with the hxml file, and pipe output to stdout.

Vaxe will also specify an
[errorformat](http://vimdoc.sourceforge.net/htmldoc/options.html#'errorformat'),
so that errors and trace messages show up in the
[quickfix](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#quickfix)
window.

## Omni-completions

Vaxe provides an
[omnicompletion](http://vimdoc.sourceforge.net/htmldoc/version7.html#new-omni-completion)
function that can use the haxe compiler in order to [display field
completions](http://haxe.org/manual/completion).  Visual Studio users will
recognize this as being similar to "intellisense".

You can trigger an omnicompletion (C-X C-O in Insert Mode) after the period at
the start of a field, submodule, or class access, or after the first
parentheses of a function invocation. See the [haxe
documentation](http://haxe.org/manual/completion) for more details.

### Active Targets: Dealing with --next 

In some cases, an hxml file may specify multiple targets via a `--next`
directive.  Vaxe will use the first target it finds in order to generate
completions.  It is possible to specify a different target by
inserting a line like this into your hxml:

    # vaxe

If Vaxe finds that line, it will use that target to generate completions and
perform other miscellaneous tasks.  The target that Vaxe uses is called the
"active" target here.

# Recommended Plugins/Additions

Vaxe will work fine on its own, but it is designed to integrate cleanly with
a number of other bundles and plugins. Once again, it is recommended to use
pathogen, vundle, or vam to manage installation and updates.

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
    --regex-haxe=/^[ \t]*+([A-Za-z0-9_]+)(;|\([^)]*:[^)]*\))/\1/t,enum_field/

Vaxe can generate a set of tags specific to the given build by running:
    vaxe#Ctags()
This will feed the paths used by the compiler into ctags.  Only the relevant 
paths for the current target will be used.  

Other utilities, like vaxe#ImportClass() can then use this tag information in
order to programmatically import classes.  E.g. calling vaxe#ImportClass on 
this line:

    var l = new FastList<Int>();

will generate:

    import haxe.FastList;
    ...
    var l = new FastList<Int>();


## Tagbar

Using the ctags lines above, the
[Tagbar](http://majutsushi.github.com/tagbar/) bundle can display a nice
overview of the classes, methods, and variables in your current haxe file.  You
do not need to call `vaxe#Ctags()` in order to use Tagbar, it works
automatically, but only for the current vaxe buffer.

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

Once enabled, Neocomplcache will automatically invoke vaxe omnicompletion
when you type a "." after a variable with fields, etc.

# Acknowledgements
* Marc Weber (marco-oweber@gmx.de) : Most of the syntax and snippets are based 
off of his [vim bundle](https://github.com/MarcWeber/vim-haxe).

* Ganesh Gunasegaran(me at itsgg.com) : I based my hxml syntax file off of [his
version](http://lists.motion-twin.com/pipermail/haxe/2008-July/018220.html).

* Laurence Taylor (polysemantic at gmail): I based my ctags description of of [his mailing list post]
(http://haxe.org/forum/thread/3395#nabble-td3443583)
