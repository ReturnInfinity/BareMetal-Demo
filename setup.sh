#!/bin/sh

./clean.sh

cd src
wget -q https://github.com/ReturnInfinity/BareMetal/raw/master/api/libBareMetal.asm 
cd ..

mkdir bin

./build.sh
