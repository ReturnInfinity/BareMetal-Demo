#!/usr/bin/env bash

CFLAGS="-c -m64 -nostdlib -nostartfiles -nodefaultlibs -ffreestanding -falign-functions=16 -fomit-frame-pointer -mno-red-zone -fno-builtin"

cd src
nasm hello.asm -o ../bin/hello.app -l ../bin/hello-debug.txt
nasm sysinfo.asm -o ../bin/sysinfo.app -l ../bin/sysinfo-debug.txt
nasm euler1.asm -o ../bin/euler1.app
nasm ethtest.asm -o ../bin/ethtest.app
nasm smptest.asm -o ../bin/smptest.app
nasm systest.asm -o ../bin/systest.app
nasm uitest.asm -o ../bin/uitest.app
nasm mouse.asm -o ../bin/mouse.app
if [ "$(uname)" != "Darwin" ]; then
	gcc $CFLAGS -o crt0.o crt0.c
	gcc $CFLAGS -o libBareMetal.o libBareMetal.c
	gcc $CFLAGS -o helloc.o helloc.c
	ld -T c.ld -o ../bin/helloc.app crt0.o helloc.o libBareMetal.o
	gcc $CFLAGS -o uitestc.o uitestc.c
	ld -T c.ld -o ../bin/uitestc.app crt0.o uitestc.o libBareMetal.o
	gcc $CFLAGS -o raytrace.o raytrace.c
	ld -T c.ld -o ../bin/raytrace.app crt0.o raytrace.o libBareMetal.o
	gcc $CFLAGS -o gavare.o gavare.c
	ld -T c.ld -o ../bin/gavare.app crt0.o gavare.o libBareMetal.o
	gcc $CFLAGS -o minIP.o minIP.c
	ld -T c.ld -o ../bin/minIP.app crt0.o minIP.o libBareMetal.o
	gcc $CFLAGS -o cube3d.o cube3d.c
	ld -T c.ld -o ../bin/cube3d.app crt0.o cube3d.o libBareMetal.o
	gcc $CFLAGS -o color-plasma.o color-plasma.c
	ld -T c.ld -o ../bin/color-plasma.app crt0.o color-plasma.o libBareMetal.o
	gcc $CFLAGS -o ./3d-model-loader/3d-model-loader.o ./3d-model-loader/3d-model-loader.c
	ld -T c.ld -o ../bin/3d-model-loader.app crt0.o ./3d-model-loader/3d-model-loader.o libBareMetal.o
fi
cd ..
