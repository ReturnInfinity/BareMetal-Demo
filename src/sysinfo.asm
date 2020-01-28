; System Information Program (v1.0, January 28 2020)
; Written by Ian Seyler
;
; BareMetal compile:
; nasm sysinfo.asm -o sysinfo.app

[BITS 64]
[ORG 0x0000000000200000]

%INCLUDE "libBareMetal.asm"

start:				; Start of program label

	mov rsi, startmessage	; Load RSI with memory address of string
	call output		; Print the string that RSI points to

;Get processor brand string
	xor rax, rax
	mov rdi, tstring
	mov eax, 0x80000002
	cpuid
	stosd
	mov eax, ebx
	stosd
	mov eax, ecx
	stosd
	mov eax, edx
	stosd
	mov eax, 0x80000003
	cpuid
	stosd
	mov eax, ebx
	stosd
	mov eax, ecx
	stosd
	mov eax, edx
	stosd
	mov eax, 0x80000004
	cpuid
	stosd
	mov eax, ebx
	stosd
	mov eax, ecx
	stosd
	mov eax, edx
	stosd
	xor al, al
	stosb			; Terminate the string
	mov rsi, cpustringmsg
	call output
	mov rsi, tstring
check_for_space:		; Remove the leading spaces from the string
	cmp byte [rsi], ' '
	jne print_cpu_string
	add rsi, 1
	jmp check_for_space
print_cpu_string:
	call output

; Number of cores
	mov rsi, numcoresmsg
	call output
	xor rax, rax
	mov rsi, 0x5012
	lodsw
	mov rdi, tstring
	call int_to_string
	mov rsi, tstring
	call output

; Speed
	mov rsi, speedmsg
	call output
	xor rax, rax
	mov rsi, 0x5010
	lodsw
	mov rdi, tstring
	call int_to_string
	mov rsi, tstring
	call output
	mov rsi, mhzmsg
	call output

; L1 code/data cache info
	mov eax, 0x80000005	; L1 cache info
	cpuid
	mov eax, edx		; EDX bits 31 - 24 store code L1 cache size in KBs
	shr eax, 24
	mov rdi, tstring
	call int_to_string
	mov rsi, l1ccachemsg
	call output
	mov rsi, tstring
	call output
	mov rsi, kbmsg
	call output
	mov eax, ecx		; ECX bits 31 - 24 store data L1 cache size in KBs
	shr eax, 24
	mov rdi, tstring
	call int_to_string
	mov rsi, l1dcachemsg
	call output
	mov rsi, tstring
	call output
	mov rsi, kbmsg
	call output

; L2/L3 cache info
	mov eax, 0x80000006	; L2/L3 cache info
	cpuid
	mov eax, ecx		; ecx bits 31 - 16 store unified L2 cache size in KBs
	shr eax, 16
	mov rdi, tstring
	call int_to_string
	mov rsi, l2ucachemsg
	call output
	mov rsi, tstring
	call output
	mov rsi, kbmsg
	call output

	mov eax, edx		; edx bits 31 - 18 store unified L3 cache size in 512 KB chunks
	shr eax, 18
	and eax, 0x3FFFF	; Clear bits 18 - 31
	shl eax, 9		; Convert the value for 512 KB chunks to KBs (Multiply by 512)
	mov rdi, tstring
	call int_to_string
	mov rsi, l3ucachemsg
	call output
	mov rsi, tstring
	call output
	mov rsi, kbmsg
	call output

;CPU features
	mov rsi, cpufeatures
	call output
	mov rax, 1
	cpuid

checksse:
	test edx, 00000010000000000000000000000000b
	jz checksse2
	mov rsi, sse
	call output

checksse2:
	test edx, 00000100000000000000000000000000b
	jz checksse3
	mov rsi, sse2
	call output

checksse3:
	test ecx, 00000000000000000000000000000001b
	jz checkssse3
	mov rsi, sse3
	call output

checkssse3:
	test ecx, 00000000000000000000001000000000b
	jz checksse41
	mov rsi, ssse3
	call output

checksse41:
	test ecx, 00000000000010000000000000000000b
	jz checksse42
	mov rsi, sse41
	call output

checksse42:
	test ecx, 00000000000100000000000000000000b
	jz checkaes
	mov rsi, sse42
	call output

checkaes:
	test ecx, 00000010000000000000000000000000b
	jz checkavx
	mov rsi, aes
	call output

checkavx:
	test ecx, 00010000000000000000000000000000b
	jz endit
	mov rsi, avx
	call output

endit:

;RAM
	mov rsi, memmessage
	call output
	xor rax, rax
	mov rsi, 0x5020
	lodsw
	mov rdi, tstring
	call int_to_string
	mov rsi, tstring
	call output
	mov rsi, mbmsg
	call output

;Disk
;	To be added

;Fin
	mov rsi, newline
	call output

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
; int_to_string -- Convert a binary interger into an string
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


startmessage: db 'System Information:' ; String falls through to newline
newline: db 13, 0
cpustringmsg: db 'CPU String: ', 0
numcoresmsg: db 13, 'Number of cores: ', 0
speedmsg: db 13, 'Detected speed: ', 0
l1ccachemsg: db 13, 'L1 code cache: ', 0
l1dcachemsg: db 13, 'L1 data cache: ', 0
l2ucachemsg: db 13, 'L2 unified cache: ', 0
l3ucachemsg: db 13, 'L3 unified cache: ', 0
cpufeatures: db 13, 'CPU features: ', 0
kbmsg: db ' KiB', 0
mbmsg: db ' MiB', 0
mhzmsg: db ' MHz', 0
sse: db 'SSE ', 0
sse2: db 'SSE2 ', 0
sse3: db 'SSE3 ', 0
ssse3: db 'SSSE3 ', 0
sse41: db 'SSE4.1 ', 0
sse42: db 'SSE4.2 ', 0
aes: db 'AES ', 0
avx: db 'AVX ', 0
memmessage: db 13, 'RAM: ', 0

tstring: times 50 db 0
