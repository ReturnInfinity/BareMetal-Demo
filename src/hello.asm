; Hello World Assembly Test Program (v1.0, January 27 2020)
; Written by Ian Seyler
;
; BareMetal compile:
; nasm hello.asm -o hello.app

[BITS 64]
[ORG 0xFFFF800000000000]

%INCLUDE "libBareMetal.asm"

start:					; Start of program label

	mov rsi, hello_message		; Load RSI with memory address of string
	mov rcx, 14			; Output 14 characters
	call [b_output]			; Print the string that RSI points to

ret					; Return to OS

hello_message: db 13, 'Hello, world!', 0
