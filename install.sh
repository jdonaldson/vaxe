cd haxe-language-server
echo "Installing npm package..."
npm install
echo "Be patient, this takes a while..." && npx lix run vshaxe-build -t language-server
