#!/usr/bin/env bash

source cross.sh

cd src

# Assembler programs
$NASM hello.asm -o ../bin/hello.app -l ../bin/hello-debug.txt
$NASM sysinfo.asm -o ../bin/sysinfo.app -l ../bin/sysinfo-debug.txt
$NASM euler1.asm -o ../bin/euler1.app
$NASM ethtest.asm -o ../bin/ethtest.app
$NASM smptest.asm -o ../bin/smptest.app
$NASM systest.asm -o ../bin/systest.app
$NASM uitest.asm -o ../bin/uitest.app
$NASM mouse.asm -o ../bin/mouse.app

# C programs
$CC $CFLAGS -o crt0.o crt0.c
$CC $CFLAGS -o libBareMetal.o libBareMetal.c
$CC $CFLAGS -o helloc.o helloc.c
$LD $LDFLAGS -T c.ld -o ../bin/helloc.app crt0.o helloc.o libBareMetal.o
$CC $CFLAGS -o uitestc.o uitestc.c
$LD $LDFLAGS -T c.ld -o ../bin/uitestc.app crt0.o uitestc.o libBareMetal.o
$CC $CFLAGS -o raytrace.o raytrace.c
$LD $LDFLAGS -T c.ld -o ../bin/raytrace.app crt0.o raytrace.o libBareMetal.o
$CC $CFLAGS -o gavare.o gavare.c
$LD $LDFLAGS -T c.ld -o ../bin/gavare.app crt0.o gavare.o libBareMetal.o
$CC $CFLAGS -o minIP.o minIP.c
$LD $LDFLAGS -T c.ld -o ../bin/minIP.app crt0.o minIP.o libBareMetal.o
$CC $CFLAGS -o cube3d.o cube3d.c
$LD $LDFLAGS -T c.ld -o ../bin/cube3d.app crt0.o cube3d.o libBareMetal.o
$CC $CFLAGS -o color-plasma.o color-plasma.c
$LD $LDFLAGS -T c.ld -o ../bin/color-plasma.app crt0.o color-plasma.o libBareMetal.o
$CC $CFLAGS -o ./3d-model-loader/3d-model-loader.o ./3d-model-loader/3d-model-loader.c
$LD $LDFLAGS -T c.ld -o ../bin/3d-model-loader.app crt0.o ./3d-model-loader/3d-model-loader.o libBareMetal.o

cd ..
