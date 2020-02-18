#!/bin/bash

cd src
nasm hello.asm -o ../bin/hello.app -l ../bin/hello-debug.txt
nasm sysinfo.asm -o ../bin/sysinfo.app -l ../bin/sysinfo-debug.txt
nasm counter.asm -o ../bin/counter.app
gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -o libBareMetal.o libBareMetal.c
gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -o helloc.o helloc.c
ld -T c.ld -o ../bin/helloc.app helloc.o libBareMetal.o
gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -o graphics.o graphics.c
ld -T c.ld -o ../bin/graphics.app graphics.o
gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -o gavare.o gavare.c
ld -T c.ld -o ../bin/gavare.app gavare.o
cd ..
