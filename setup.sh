#!/usr/bin/env bash

./clean.sh

cd src
if [ -x "$(command -v curl)" ]; then
	curl -s -o libBareMetal.asm https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.asm
	curl -s -o libBareMetal.c https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.c
	curl -s -o libBareMetal.h https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.h
	curl -s -o libBareMetal.asm https://raw.githubusercontent.com/ReturnInfinity/BareMetal-Monitor/master/api/lib-ui.asm
	curl -s -o libBareMetal.h https://raw.githubusercontent.com/ReturnInfinity/BareMetal-Monitor/master/api/lib-ui.h
else
	wget -q https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.asm
	wget -q https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.c
	wget -q https://raw.githubusercontent.com/ReturnInfinity/BareMetal/master/api/libBareMetal.h
	wget -q https://raw.githubusercontent.com/ReturnInfinity/BareMetal-Monitor/master/api/lib-ui.asm
	wget -q https://raw.githubusercontent.com/ReturnInfinity/BareMetal-Monitor/master/api/lib-ui.h
fi
cd ..

mkdir bin

./build.sh
