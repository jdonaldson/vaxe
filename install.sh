cd haxe-languageserver
haxelib git haxe-hxparser https://github.com/vshaxe/haxe-hxparser --always
haxelib git vshaxe-build https://github.com/vshaxe/vshaxe-build.git --always
haxelib install hxnodejs --always
echo y | haxelib run vshaxe-build -t language-server -m both
