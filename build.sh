echo "Cleaning up previous build..."

# Delete everything inside the bin folder except the folder itself
rm -r bin/*

echo "Building .love file..."

# Create a .love file
cp -r . /tmp/lua-tank-game > /dev/null
rm -r /tmp/lua-tank-game/bin

(cd /tmp/lua-tank-game && zip -9 -r ../lua-tank-game.love . > /dev/null)

mv /tmp/lua-tank-game.love bin

echo "Downloading Love2D..."

# Download the Love2D binaries (windows32, will run on 64-bit windows as well as linux and macos)
wget -q -P bin https://github.com/love2d/love/releases/download/11.5/love-11.5-win32.zip

echo "Extracting Love2D..."

# Unzip the love2d binaries
unzip bin/love-11.5-win32.zip -d bin

echo "Building .exe file..."

# Create a .exe file from the .love file
cat bin/love-11.5-win32/love.exe bin/lua-tank-game.love > bin/love-11.5-win32/game.exe

echo "Customizing..."

# Rename and remove objects
mv bin/love-11.5-win32 bin/lua-tank-game
rm bin/love-11.5-win32.zip
rm bin/lua-tank-game/love.exe
rm bin/lua-tank-game/lovec.exe

# Change the icons, etc in the future

echo "Zipping..."

# Zip the game
(cd bin && zip -r lua-tank-game.zip lua-tank-game > /dev/null)

echo "Cleaning up..."

# Clean up
rm bin/lua-tank-game.love
rm -r bin/lua-tank-game

echo "Done! File is in bin/lua-tank-game.zip"