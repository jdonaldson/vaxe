Vaxe is a vim bundle for [Haxe](http://www.haxe.org) and
[Hss](http://ncannasse.fr/projects/hss).  It provides support for
syntax highlighting, indenting, compiling, and many more options.  vaxe has
"vimdoc" documentation.  You can see the current vimdoc documentation
[here](https://raw.github.com/jdonaldson/vaxe/master/doc/vaxe.txt), as well as
through using `:help vaxe` within vim.  This page will describe some of the
special or optional features that vaxe supports, in addition to recommended
configuration settings.

![Vaxe Screenshot](http://i.imgur.com/JFvze.png) (screenshot shows
neocomplcache completion mode, vim-airline, tagbar, and monokai color theme)

The recommended way to install vaxe is using a bundle management system such
as [pathogen][], [vundle][], or [vam][].

# Install with Pathogen

1. Install pathogen using the [instructions][pathogen].
2. Create/cd into `~/.vim/bundle/`
3. Make a clone of the vaxe repo:
    `git clone https://github.com/jdonaldson/vaxe.git`

To update:

1. cd into `~/.vim/bundle/vaxe/`
2. git pull

# Install with Vundle

1. Install vundle using the [instructions][vundle]
2. Add vaxe to your bundle list in `.vimrc` and re-source it:
    `Bundle 'jdonaldson/vaxe'`
3. Run `:BundleInstall`

To update, just run `:BundleUpdate`

# Install with VAM

1. Install VAM using the [instructions][vam]
2. Add vaxe to the list of your activated bundles and re-source it:
    `call vam#ActivateAddons(['github:jdonaldson/vaxe'])`


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

If vaxe has found your build file, you can just run the make command:

```viml
:make
```

Vaxe will also specify an
[errorformat](http://vimdoc.sourceforge.net/htmldoc/options.html#'errorformat'),
so that errors and trace messages show up in the
[quickfix](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#quickfix)
window.

## Lime Project Support
![Lime](http://i.imgur.com/rc8vLi2.png)

Vaxe supports [Lime](https://github.com/openfl/lime)
workflows.  If a Lime project is found, Vaxe will use it for builds and
completions. You can specify a default target if you only work with one
platform.

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

    # display completions

If Vaxe finds that line, it will use that target to generate completions and
perform other miscellaneous tasks.  The target that Vaxe uses is called the
"active" target here.

# HSS Support
Vaxe will also support the [hss](http://ncannasse.fr/projects/hss) language,
with support for syntax highlighting, and compilation to css.

# Recommended Plugins/Additions/Config

Vaxe will work fine on its own, but it is designed to integrate cleanly with
a number of other bundles and plugins. Once again, it is recommended to use
pathogen, vundle, or vam to manage installation and updates.

## Misc Config
Vaxe provides a full completion specification for vim, which includes providing
function documentation via the [preview
window]( http://vimdoc.sourceforge.net/htmldoc/windows.html#preview-window ).
This can be turned off with:

```viml
set completeopt=menu
```

This will only use the menu, and not the preview window.  See ```:help
preview-window``` for more details.

Also, it is recommended that ```autowrite``` is set for haxe/hxml files.
Otherwise, completions will not be available as you type.  See
```help autowrite``` for more details.  If autowrite is not set,
Vaxe will return an error when completions are requested.  It is possible to
turn this off, see the help for g:vaxe_completion_require_autowrite.

## Airline

Airline ( [by Bailey Ling](https://github.com/bling/vim-airline)) is a handy
[status line](http://vimdoc.sourceforge.net/htmldoc/windows.html#status-line)
replacement.  I think it looks better, and provides a good deal more
functionality over a normal status line setting.  Airline support is provided by
default in vaxe.  Current support enables the display of the current hxml build
file.  You can disable this by changing ```g:vaxe_enable_airline``` to 0.

Personally, I'm perfectly happy using airline, but If you're looking for support
for the original [powerline](https://github.com/Lokaltog/powerline), you can
check [my repo](https://github.com/jdonaldson/linepower.vim).  The original
powerline version is more powerful, but much more difficult to install and
configure.  Copy the configuration information from my linepower repo instead of
the configuration information from the main powerline repo in order to enable
the vaxe plugin.

## Tags

Vim has great support for
[ctags](http://vimdoc.sourceforge.net/htmldoc/tagsrch.html), which are really
useful for navigating a large code base.

You'll need to define some patterns for ctags in order for it to work with
Haxe.  Put these lines in your `.ctags` file in your home directory:

```bash
    --langdef=haxe
    --langmap=haxe:.hx
    --regex-haxe=/^[ \t]*((@:?[a-zA-Z]+) )*((macro|private|public|static|inline) )*function[ \t]+([A-Za-z0-9_]+)/\5/f,function,functions/
    --regex-haxe=/^[ \t]*((@:?[a-zA-Z]+) )*((private|public|static|inline) )+var[ \t]+([A-Za-z0-9_]+)/\5/v,variable,variables/
    --regex-haxe=/^[ \t]*package[ \t]*([A-Za-z0-9_\.]+)/\1/p,package/
    --regex-haxe=/^[ \t]*((@:?[a-zA-Z]+) )*(extern[ \t]+)?class[ \t]+([A-Za-z0-9_]+)[ \t]*[^\{]*/\4/c,class,classes/
    --regex-haxe=/^[ \t]*((@:?[a-zA-Z]+) )*(extern[ \t]+)?interface[ \t]+([A-Za-z0-9_]+)/\4/i,interface/
    --regex-haxe=/^[ \t]*typedef[ \t]+([A-Za-z0-9_]+)/\1/t,typedef/
    --regex-haxe=/^[ \t]*enum[ \t]+([A-Za-z0-9_]+)/\1/e,enum/
```

Vaxe can generate a set of tags specific to the given build by running:
    vaxe#Ctags()
This will feed the paths used by the compiler into ctags.  Only the relevant
paths for the current target will be used.

Other utilities, like vaxe#ImportClass() can then use this tag information in
order to programmatically import classes.  E.g. calling vaxe#ImportClass on
this line:

```as3
    var l = new FastList<Int>();
```

will generate:

```as3
    import haxe.FastList;
    ...
    var l = new FastList<Int>();
```


## Tagbar

Using the ctags lines above, the
[Tagbar](http://majutsushi.github.com/tagbar/) bundle can display a nice
overview of the classes, methods, and variables in your current haxe file.  You
do not need to call `vaxe#Ctags()` in order to use Tagbar, it works
automatically, but only for the current vaxe buffer.

## Syntastic

[Syntastic](https://github.com/scrooloose/syntastic) is a popular bundle that
enables syntax errors to be displayed in a small gutter on the left of the
editor buffer.  I've patched Syntastic to use vaxe compilation information for
haxe and hss, including errors and traces.  All that is necessary is to install
the bundle.


## YouCompleteMe
[YouCompleteMe](https://github.com/Valloric/YouCompleteMe) (YCM) is a bundle that
provides completeions for c-style languages.  However, it has the ability to
provide support for other languages as well, such as the completion methods
provided through vaxe.  Vaxe will let YCM use its completion methods
automatically, all that is required is that YCM (and its libraries) be compiled
and installed.

## Autocomplpop
[AutoComplPop](http://www.vim.org/scripts/script.php?script_id=1879) is an
older vim script that automatically pops up a completion menu when an
omnicompletion is available.  It should offer good basic completions using
pure vimscript. Vaxe will let ACP use its completion methods automatically.

## Neocomplcache
[Neocomplcache](https://github.com/Shougo/neocomplcache) is a plugin for vim
that can manage virtually any type of completion (omni, keyword, file, etc). It
can be tricky to set up, so follow their documentation carefully.pc

# Acknowledgements
* Marc Weber (marco-oweber@gmx.de) : Most of the early work for the bundle was
based off of his [vim-haxe bundle](https://github.com/MarcWeber/vim-haxe).
Some of the hss functionality comes from his work on
[scss-vim](https://github.com/cakebaker/scss-syntax.vim).

* Ganesh Gunasegaran(me at itsgg.com) : I based my hxml syntax file off of [his
version](http://lists.motion-twin.com/pipermail/haxe/2008-July/018220.html).

* Laurence Taylor (polysemantic at gmail): I based my ctags description of of [his mailing list post]
(http://haxe.org/forum/thread/3395#nabble-td3443583)

* Luca Deltodesco (luca@deltaluca.me.uk): The main Haxe syntax file is based
off of [his version](https://gist.github.com/deltaluca/6330630).
