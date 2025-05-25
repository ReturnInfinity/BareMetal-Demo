#!/usr/bin/env bash

CFLAGS="-c -m64 -nostdlib -nostartfiles -nodefaultlibs -ffreestanding -falign-functions=16 -fomit-frame-pointer -mno-red-zone -fno-builtin"
CFLAGS_RAY="-O1 -falign-jumps=16 -falign-labels=16 -falign-loops=16 -fcaller-saves -fcode-hoisting -fcrossjumping -fcse-follow-jumps -fcse-skip-blocks -fdelete-null-pointer-checks -fdevirtualize -fdevirtualize-speculatively -fexpensive-optimizations -ffinite-loops -fgcse -fgcse-lm -fhoist-adjacent-loads -finline-functions -finline-small-functions -findirect-inlining -fipa-bit-cp -fipa-cp -fipa-icf -fipa-ra -fipa-sra -fipa-vrp -fisolate-erroneous-paths-dereference -flra-remat -foptimize-sibling-calls -foptimize-strlen -fpartial-inlining -fpeephole2 -freorder-blocks-algorithm=stc -freorder-blocks-and-partition -freorder-functions -frerun-cse-after-loop -fschedule-insns -fschedule-insns2 -fsched-interblock -fsched-spec -fstore-merging -fstrict-aliasing -fthread-jumps -ftree-builtin-call-dce -ftree-loop-vectorize -ftree-pre -ftree-switch-conversion -ftree-tail-merge -ftree-vrp -fvect-cost-model=very-cheap -fgcse-after-reload -fipa-cp-clone -floop-interchange -floop-unroll-and-jam -fpeel-loops -fpredictive-commoning -fsplit-loops -fsplit-paths -ftree-loop-distribution -ftree-partial-pre -funswitch-loops -fvect-cost-model=dynamic -fversion-loops-for-strides"

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
	gcc $CFLAGS $CFLAGS_RAY -o raytrace.o raytrace.c
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
