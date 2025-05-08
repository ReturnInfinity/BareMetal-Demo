
#!/usr/bin/env bash

if [ "$(uname)" != "Darwin" ]; then
# linux
CC=gcc
LD=ld
CFLAGS="-c -m64 -nostdlib -nostartfiles -nodefaultlibs -ffreestanding -falign-functions=16 -fomit-frame-pointer -mno-red-zone -fno-builtin"
LDFLAGS=
NASM=nasm
else
# darwin
CC=x86_64-elf-gcc
LD=x86_64-elf-ld
CFLAGS="-c -m64 -nostdlib -nodefaultlibs -ffreestanding -falign-functions=16 -fomit-frame-pointer -mno-red-zone -fno-builtin"
LDFLAGS=
NASM=nasm
fi
