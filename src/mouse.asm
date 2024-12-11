; Mouse Test Program (v1.0, December 10 2024)
; Written by Ian Seyler

[BITS 64]

%INCLUDE "libBareMetal.asm"

b_user equ 0x0000000000100048

start:					; Start of program label
	lea rsi, [rel startstring]
	call output
	mov cl, 0x03
	call [b_user]
	mov [x], al
	mov cl, 0x04
	call [b_user]
	mov [y], al
	
mouse_loop:
	call [b_input]
	cmp al, 'q'
	je end
	; Set cursor
	xor eax, eax
	mov al, [x]
	mov cl, 0x13
	call [b_user]
	mov al, [y]
	mov cl, 0x14
	call [b_user]

	mov al, [0x110405]
	call dump_al			; dump buttons
	
	lea rsi, [rel space]
	call output

	mov al, [0x110406]
	call dump_ax			; dump x

	lea rsi, [rel space]
	call output

	mov al, [0x110408]
	call dump_ax			; dump y
	
	lea rsi, [rel space]
	call output

	mov al, [0x11040A]
	call dump_ax			; dump z

	lea rsi, [rel space]
	call output

	mov al, [0x110404]
	call dump_al			; dump count

	lea rsi, [rel space]
	call output

	mov al, [0x110400]
	call dump_eax			; dump packet

	jmp mouse_loop

end:
	ret				; Return to OS


; -----------------------------------------------------------------------------
; output -- Displays text
;  IN:	RSI = message location (zero-terminated string)
; OUT:	All registers preserved
output:
	push rcx

	call string_length	; Calculate the string length
	call [b_output]		; Output the string via the kernel syscall

	pop rcx
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; string_length -- Return length of a string
;  IN:	RSI = string location
; OUT:	RCX = length (not including the NULL terminator)
;	All other registers preserved
string_length:
	push rdi
	push rax

	xor ecx, ecx
	xor eax, eax
	mov rdi, rsi
	not rcx
	cld
	repne scasb			; compare byte at RDI to value in AL
	not rcx
	dec rcx

	pop rax
	pop rdi
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; dump_(rax|eax|ax|al) -- Dump content of RAX, EAX, AX, or AL
;  IN:	RAX = content to dump
; OUT:	Nothing, all registers preserved
dump_rax:
	rol rax, 8
	call dump_al
	rol rax, 8
	call dump_al
	rol rax, 8
	call dump_al
	rol rax, 8
	call dump_al
	rol rax, 32
dump_eax:
	rol eax, 8
	call dump_al
	rol eax, 8
	call dump_al
	rol eax, 16
dump_ax:
	rol ax, 8
	call dump_al
	rol ax, 8
dump_al:
	push rdi
	push rbx
	push rax
	lea rbx, [rel hextable]
	lea rdi, [rel tchar]
	push rax			; Save RAX since we work in 2 parts
	shr al, 4			; Shift high 4 bits into low 4 bits
	xlatb
	stosb
	pop rax
	and al, 0x0f			; Clear the high 4 bits
	xlatb
	stosb
	push rsi
	lea rsi, [rel tchar]
	call output
	pop rsi
	pop rax
	pop rbx
	pop rdi
	ret
; -----------------------------------------------------------------------------


; Strings
startstring: db 10, 'Mouse Test - q to quit', 10, '========', 10, 0
hextable: db '0123456789ABCDEF'
space: db ' ', 0
newline: db 10, 0
outputlock: dq 0
tchar: db 0, 0, 0
x: db 0
y: db 0
