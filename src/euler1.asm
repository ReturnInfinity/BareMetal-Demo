; https://projecteuler.net/problem=1 - v1.0, February 5 2023
; Written by Ian Seyler
;
; BareMetal compile:
; nasm euler1.asm -o euler1.app

[BITS 64]
[ORG 0xFFFF800000000000]

%INCLUDE "libBareMetal.asm"

start:					; Start of program label

loop:
	; Check if RDX is divisible by 3
	mov rax, qword [rel counter]	; Copy counter to RAX for division
	xor rdx, rdx			; Zero out RDX for division
	mov rcx, 3
	div rcx				; Divide RDX:RAX by 3, the result is in RAX, the remainder in RDX
	cmp rdx, 0			; Compare the remainder with 0
	jne check_5			; If not divisible by 3, jump to check_5
	mov rax, qword [rel counter]
	add qword [rel sum], rax
	jmp add_counter			; Jump to add_counter

	; Check if RDX is divisible by 5
check_5:
	mov rax, qword [rel counter]	; Copy RDX to RAX for division
	xor rdx, rdx			; Zero out RDX for division
	mov rcx, 5
	div rcx				; Divide RDX:RAX by 5, the result is in RAX, the remainder in RDX
	cmp rdx, 0			; Compare the remainder with 0
	jne add_counter			; If not divisible by 5, jump to add_counter
	mov rax, qword [rel counter]
	add qword [rel sum], rax

	; Add 1 to the counter and check if it's less than 1000
add_counter:
	add qword [rel counter], 1	; Increment the counter
	cmp qword [rel counter], 1000	; Compare the counter with 1000
	jl loop				; If less, jump to loop

	mov rsi, message
	call output
	mov rdi, tstring
	mov rsi, rdi
	mov rax, qword [rel sum]	; Copy sum to RAX
	call int_to_string		; Convert value to RAX to string in [RDI]
	call output

	ret				; Return to OS

message: db 10, 'Sum of multiples of 3 or 5 below 1000: ', 0
sum: dq 0
counter: dq 1

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
; int_to_string -- Convert a binary integer into an string
;  IN:	RAX = binary integer
;	RDI = location to store string
; OUT:	RDI = points to end of string
;	All other registers preserved
; Min return value is 0 and max return value is 18446744073709551615 so your
; string needs to be able to store at least 21 characters (20 for the digits
; and 1 for the string terminator).
; Adapted from http://www.cs.usfca.edu/~cruse/cs210s09/rax2uint.s
int_to_string:
	push rdx
	push rcx
	push rbx
	push rax

	mov rbx, 10					; base of the decimal system
	xor ecx, ecx					; number of digits generated
int_to_string_next_divide:
	xor edx, edx					; RAX extended to (RDX,RAX)
	div rbx						; divide by the number-base
	push rdx					; save remainder on the stack
	inc rcx						; and count this remainder
	cmp rax, 0					; was the quotient zero?
	jne int_to_string_next_divide			; no, do another division
int_to_string_next_digit:
	pop rax						; else pop recent remainder
	add al, '0'					; and convert to a numeral
	stosb						; store to memory-buffer
	loop int_to_string_next_digit			; again for other remainders
	xor al, al
	stosb						; Store the null terminator at the end of the string

	pop rax
	pop rbx
	pop rcx
	pop rdx
	ret
; -----------------------------------------------------------------------------


tstring: times 50 db 0
