echo "Cleaning up previous build..."

# Delete everything inside the bin folder except the folder itself
rm -r bin/*

echo "Creating .love file..."

# Create a .love file
cp -r . /tmp/lua-tank-game > /dev/null
rm -r /tmp/lua-tank-game/bin

(cd /tmp/lua-tank-game && zip -9 -r ../lua-tank-game.love . > /dev/null)

mv /tmp/lua-tank-game.love bin

echo "Downloading Love2D for Windows..."

# Download the Love2D binaries (windows32, will run on 64-bit windows as well as linux and macos)
wget -q -P bin https://github.com/love2d/love/releases/download/11.5/love-11.5-win32.zip

echo "Extracting Love2D for Windows..."

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
(cd bin && zip -r lua-tank-game-windows-x86_64.zip lua-tank-game > /dev/null)
rm -r bin/lua-tank-game

echo "Finished building for Windows!"
echo "Downloading Love2D for MacOS..."

# Download the Love2D binaries (macos)
wget -q -P bin https://github.com/love2d/love/releases/download/11.5/love-11.5-macos.zip

echo "Unzipping..."

# Unzip
mkdir bin/lua-tank-game
unzip bin/love-11.5-macos.zip -d bin/lua-tank-game
rm bin/love-11.5-macos.zip

echo "Copying files..."

# Copy the love file into the love.app/Contents/Resources folder
cp bin/lua-tank-game.love bin/lua-tank-game/love.app/Contents/Resources

# TODO: Change the icons, name, in the plist file

# Zip
echo "Zipping..."

(cd bin && zip -r lua-tank-game-macos.zip lua-tank-game > /dev/null)
rm -r bin/lua-tank-game

echo "Finished building for MacOS!"
echo "Creating Linux version..."

# Zip
cp build_assets/linux_readme.txt bin/readme.txt
(cd bin && zip -r lua-tank-game-linux-x86_64.zip lua-tank-game.love readme.txt)
rm bin/lua-tank-game.love
rm bin/readme.txt

echo "Cleaning up..."

# Clean up
rm -rf /tmp/lua-tank-game

echo "Done! All files are in the bin folder."