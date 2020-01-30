#!/bin/sh

./clean.sh

cd src
wget -q https://github.com/ReturnInfinity/BareMetal/raw/master/api/libBareMetal.asm 
wget -q https://github.com/ReturnInfinity/BareMetal/raw/master/api/libBareMetal.c 
wget -q https://github.com/ReturnInfinity/BareMetal/raw/master/api/libBareMetal.h 
cd ..

mkdir bin

./build.sh
