#!/bin/bash

cd src
nasm hello.asm -o ../bin/hello.app -l ../bin/hello-debug.txt
nasm sysinfo.asm -o ../bin/sysinfo.app -l ../bin/sysinfo-debug.txt
cd ..
