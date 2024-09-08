; SMP Test Program (v1.0, February 24 2024)
; Output a test message from every available CPU
; Written by Ian Seyler
;
; BareMetal compile:
; nasm smptest.asm -o smptest.app

[BITS 64]
[ORG 0xFFFF800000000000]

%include 'libBareMetal.asm'

start:
	mov rsi, startstring
	mov rcx, 8
	call [b_output]
	mov rcx, SMP_SET		; API Code
	mov rax, smp_task		; Code for CPU to run
	xor edx, edx			; Start at ID 0
startloop:
	call [b_system]			; Give the CPU a code address
	add edx, 1			; Increment to the next CPU
	cmp rdx, 256			; Set a maximum of 256 CPUs
	jne startloop
	call smp_task			; Call the code on this CPU as well
startwait:
	mov rcx, SMP_BUSY
	call [b_system]
	cmp al, 0
	jne startwait
	ret

; This code will be executed on every available CPU in the system
; The mutex is used so only one CPU can output its message at a time
align 16
smp_task:
	mov rax, outputlock		; Location of the mutex
	mov rcx, SMP_LOCK		; Aquire the lock
	call [b_system]
	mov rsi, message		; Output the "Hello..." message
	mov rcx, 19
	call [b_output]
	mov rcx, SMP_ID			; Get the APIC ID of the CPU
	call [b_system]
	call dump_al
	mov rax, outputlock
	mov rcx, SMP_UNLOCK		; Release the mutex
	call [b_system]
	ret




; -----------------------------------------------------------------------------
; dump_al -- Dump content of AL
;  IN:	AL = content to dump
; OUT:	Nothing, all registers preserved
dump_al:
	push rsi
	push rcx
	push rbx
	push rax

	mov rsi, tchar
	mov rcx, 2
dump_al_next_nibble:
	rol al, 4
	mov bl, al
	and bl, 0x0F			; Isolate low nibble
	add bl, 0x30			; Convert to ASCII value starting at '0'
	cmp bl, 0x39			; Check if it is above '9'
	jna dump_al_not_AF
	add bl, 7			; Add offset to 'A'
dump_al_not_AF:
	mov [rsi], byte bl		; Store the character
	add rsi, 1
	dec rcx
	jnz dump_al_next_nibble

	mov rsi, tchar
	mov rcx, 2
	call [b_output]

	pop rax
	pop rbx
	pop rcx
	pop rsi
	ret
; -----------------------------------------------------------------------------

startstring: db 10, 'SMPTest'
message: db 10, 'Hello from core 0x'
outputlock: dq 0
tchar: