#!/bin/bash

cd src
nasm hello.asm -o ../bin/hello.bin -l ../bin/hello-debug.txt
