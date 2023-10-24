#!/bin/sh

./clean.sh

cd src
if which curl &> /dev/null; then
	curl -s -o libBareMetal.asm https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.asm
	curl -s -o libBareMetal.c https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.c
	curl -s -o libBareMetal.h https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.h
else
	wget https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.asm
	wget https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.c
	wget https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.h
fi
cd ..

mkdir bin

./build.sh
