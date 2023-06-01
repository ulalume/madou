# Install library
```
luarocks install jumper --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1

curl https://raw.githubusercontent.com/kikito/anim8/master/anim8.lua > lua_modules/share/lua/5.1/anim8.lua
```
# Build
## Create a .love-file
```
zip -9 -r Madou.love .
```
## For itch.io
```
love.js Madou.love dist -c
template/index.html

cp ./template/love.css ./dist/love.css
cp ./template/index.html ./dist/index.html
rm -r ./dist/theme 
```
love.jsのerror箇所のコメントアウトを行った。
