; System Test Program (v0.1, August 4 2024)
; Written by Ian Seyler
;
; BareMetal compile:
; nasm systest.asm -o systest.app

[BITS 64]
[ORG 0xFFFF800000000000]

%include 'libBareMetal.asm'

start:
	mov rsi, startstring
	call output

systest_wait_for_input:
	call [b_input]
	or al, 00100000b		; Convert to lowercase

	cmp al, '1'
	je systest_smp
	cmp al, '2'
	je systest_mem
	cmp al, '3'
	je systest_net
	cmp al, 'q'
	je systest_end
	jmp systest_wait_for_input

systest_smp:
	mov rcx, smp_set		; API Code
	mov rax, smp_task		; Code for CPU to run
	xor edx, edx			; Start at ID 0
systest_smp_startloop:
	call [b_system]			; Give the CPU a code address
	add edx, 1			; Increment to the next CPU
	cmp rdx, 256			; Set a maximum of 256 CPUs
	jne systest_smp_startloop
	call smp_task			; Call the code on this CPU as well
systest_smp_startwait:
	mov rcx, smp_busy
	call [b_system]
	cmp al, 0
	jne systest_smp_startwait
	mov rsi, donestring
	call output
	jmp start

systest_mem:
	mov rsi, memteststring
	call output
	mov rdi, 0xFFFF800000000000
	mov rax, rdi
	call dump_rax
	mov rsi, memteststring2
	call output
	mov eax, [0x00110104]
	shl rax, 20			; Convert MiB to Bytes
	dec rax				; Decrement by 1 Byte
	add rax, rdi
	mov rdx, rax			; Maximum valid memory address
	call dump_rax
	add rdi, 0x0000000000200000	; Actually start at 0xFFFF800000200000
systest_mem_next:
	add rdi, 8
	cmp rdx, rdi
	jl systest_mem_done
	mov rax, 0x55AA55AA55AA55AA
	mov [rdi], rax
	mov rbx, [rdi]
	cmp rax, rbx
	je systest_mem_next
	mov rsi, memtesterror
	call output
	mov rax, rdi
	call dump_rax
	mov rsi, memtesterror2
	call output
systest_mem_done:
	mov rsi, donestring
	call output
	jmp start

systest_net:
	jmp systest_wait_for_input

systest_end:
	ret


; -----------------------------------------------------------------------------
; This code will be executed on every available CPU in the system
; The mutex is used so only one CPU can output its message at a time
align 16
smp_task:
	mov rax, outputlock		; Location of the mutex
	mov rcx, smp_lock		; Aquire the lock
	call [b_system]
	mov rsi, smptestmessage		; Output the "Hello..." message
	mov rcx, 19
	call [b_output]
	mov rcx, smp_get_id		; Get the APIC ID of the CPU
	call [b_config]
	call dump_al
	mov rax, outputlock
	mov rcx, smp_unlock		; Release the mutex
	call [b_system]
	ret
; -----------------------------------------------------------------------------


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
	mov rbx, hextable
	mov rdi, tchar
	push rax			; Save RAX since we work in 2 parts
	shr al, 4			; Shift high 4 bits into low 4 bits
	xlatb
	stosb
	pop rax
	and al, 0x0f			; Clear the high 4 bits
	xlatb
	stosb
	push rsi
	mov rsi, tchar
	call output
	pop rsi
	pop rax
	pop rbx
	pop rdi
	ret
; -----------------------------------------------------------------------------



startstring: db 13, 'SysTest', 13, '========', 13, '1 - SMP Test', 13, '2 - Memory Test', 13, '3 - Network Test', 13, 'q - Quit', 13, 'Enter selection: ', 0
smptestmessage: db 13, 'Hello from core 0x'
memteststring: db 13, 'mem test', 13, 'starting at 0x', 0
memteststring2: db ', testing up to ', 0
memtesterror: db 13, 'Error at ', 0
memtesterror2: db 13, 'Ending test', 0
donestring: db 13, 'Done!', 13, 0
hextable: db '0123456789ABCDEF'
newline: db 13, 0
outputlock: dq 0
tchar: db 0, 0, 0