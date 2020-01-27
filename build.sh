#!/bin/bash

cd src
nasm hello.asm -o ../bin/hello.app -l ../bin/hello-debug.txt
