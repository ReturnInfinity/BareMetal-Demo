#!/bin/sh

./clean.sh

cd src
curl -s -o libBareMetal.asm https://github.com/ReturnInfinity/BareMetal/raw/master/api/libBareMetal.asm 
curl -s -o libBareMetal.c https://github.com/ReturnInfinity/BareMetal/raw/master/api/libBareMetal.c 
curl -s -o libBareMetal.h https://github.com/ReturnInfinity/BareMetal/raw/master/api/libBareMetal.h 
cd ..

mkdir bin

./build.sh
