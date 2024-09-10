; UI Test Program (v1.0, September 8 2024)
; Written by Ian Seyler

[BITS 64]

%INCLUDE "libBareMetal.asm"

b_user equ 0x0000000000100048

start:					; Start of program label
	lea rsi, [rel newline]		; Load RSI with the relative memory address of string
	mov ecx, 1			; Output 1 character
	call [b_output]			; Print the string that RSI points to

	mov eax, 0x00FF0000		; Red
	mov cl, 0x11
	call [b_user]
	lea rsi, [rel test_message]	; Load RSI with the relative memory address of string
	mov ecx, 4			; Output 14 characters
	call [b_output]			; Print the string that RSI points to

	lea rsi, [rel newline]		; Load RSI with the relative memory address of string
	mov ecx, 1			; Output 1 character
	call [b_output]			; Print the string that RSI points to
	
	mov eax, 0x0000FF00		; Green
	mov cl, 0x11
	call [b_user]
	lea rsi, [rel test_message]	; Load RSI with the relative memory address of string
	mov ecx, 4			; Output 14 characters
	call [b_output]			; Print the string that RSI points to

	lea rsi, [rel newline]		; Load RSI with the relative memory address of string
	mov ecx, 1			; Output 1 character
	call [b_output]			; Print the string that RSI points to
	
	mov eax, 0x000000FF		; Blue
	mov cl, 0x11
	call [b_user]
	lea rsi, [rel test_message]	; Load RSI with the relative memory address of string
	mov ecx, 4			; Output 14 characters
	call [b_output]			; Print the string that RSI points to

	mov eax, 0x00FF00FF
	mov cl, 0x11
	call [b_user]
	mov eax, 0x0000FF00		; Green
	mov cl, 0x12
	call [b_user]
	mov ax, 20
	mov cl, 0x13
	call [b_user]
	mov ax, 10
	mov cl, 0x14
	call [b_user]
	lea rsi, [rel test_message]	; Load RSI with the relative memory address of string
	mov ecx, 4			; Output 14 characters
	call [b_output]			; Print the string that RSI points to

;fill:
;	lea rsi, [rel string]		; Load RSI with the relative memory address of string
;	mov ecx, 10			; Output 14 characters
;	call [b_output]			; Print the string that RSI points to
;	jmp fill

	; Set colors back to default
	mov eax, 0x00FFFFFF		; White
	mov cl, 0x11
	call [b_user]
	mov eax, 0x00404040		; Dark grey
	mov cl, 0x12
	call [b_user]

	ret				; Return to OS

newline: db 10
test_message: db 'TEST', 0
string: db '0123456789', 0
