echo off
"../rgbgfx" -o data/tiles.2bpp tiles.png
echo on
"../rgbasm" -L -o bin/main.o main.asm
echo off
"../rgblink" -o bin/metriodvania.gb -m bin/main.map bin/main.o
"../rgbfix" -v -p 0 bin/metriodvania.gb
echo on