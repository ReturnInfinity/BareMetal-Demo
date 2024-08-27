; Hello World Assembly Test Program (v1.0, January 27 2020)
; Written by Ian Seyler
;
; BareMetal compile:
; nasm hello.asm -o hello.app
;
; This simple test program outputs the string in hello_message
; 1) Load the string address into the `RSI` register. The `LEA` instruction is used here. `MOV` could also be used via `mov rsi, hello_message`
; 2) Load the number of characters to output into the `RCX` register. `ECX` is used since a `MOV` to it will clear the high 32-bits
; 3) Call the kernel function to output characters. It depends on the string address in `RSI` and the number of characters to output in `RCX`
; 4) Return to the OS/CLI

[BITS 64]

%INCLUDE "libBareMetal.asm"

start:					; Start of program label
	lea rsi, [rel hello_message]	; Load RSI with the relative memory address of string
	mov ecx, 14			; Output 14 characters
	call [b_output]			; Print the string that RSI points to
	ret				; Return to OS

hello_message: db 10, 'Hello, world!', 0
