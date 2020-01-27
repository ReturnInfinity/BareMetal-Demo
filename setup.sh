#!/bin/sh

./clean.sh

cd src
wget https://github.com/ReturnInfinity/BareMetal/raw/master/api/libBareMetal.asm 
cd ..

mkdir bin

./build.sh
