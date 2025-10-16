; System Test Program (v1.0, August 21 2024)
; Written by Ian Seyler
;
; BareMetal compile:
; nasm systest.asm -o systest.app

[BITS 64]
DEFAULT ABS

%include "libBareMetal.asm"

start:
	lea rsi, [rel startstring]
	call output

systest_wait_for_input:
	call [b_input]
	or al, 00100000b		; Convert to lowercase

	cmp al, "1"
	je systest_smp
	cmp al, "2"
	je systest_mem
	cmp al, "3"
	je systest_net
	cmp al, "4"
	je systest_sto
	cmp al, "q"
	je systest_end
	jmp systest_wait_for_input

systest_smp:
	lea rsi, [rel smpteststring]
	call output
	mov rcx, SMP_SET		; API Code
	lea rax, [rel smp_task]		; Code for CPU to run
	xor edx, edx			; Start at ID 0
systest_smp_startloop:
	call [b_system]			; Give the CPU a code address
	add edx, 1			; Increment to the next CPU
	cmp rdx, 256			; Set a maximum of 256 CPUs
	jne systest_smp_startloop
	call smp_task			; Call the code on this CPU as well
systest_smp_startwait:
	mov rcx, SMP_BUSY
	call [b_system]
	cmp al, 0
	jne systest_smp_startwait
	lea rsi, [rel donestring]
	call output
	jmp start

systest_mem:
	lea rsi, [rel memteststring]
	call output
	mov rdi, 0xFFFF800000000000
	mov rax, rdi
	call dump_rax
	lea rsi, [rel memteststring2]
	call output
	mov rcx, FREE_MEMORY		; 32-bit - Amount of free RAM in MiBs
	call [b_system]
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
	lea rsi, [rel memtesterror]
	call output
	mov rax, rdi
	call dump_rax
	mov rsi, memtesterror2
	call output
systest_mem_done:
	lea rsi, [rel donestring]
	call output
	jmp start

systest_net:
	lea rsi, [rel netteststring1a]
	call output

	xor edx, edx
systest_net_disp:
	mov rcx, NET_STATUS
	call [b_system]
	cmp eax, 0
	je systest_net_disp_done
	push rax
	mov al, dl
	call dump_al
	lea rsi, [rel space]
	call output
	lea rsi, [rel dash]
	call output
	lea rsi, [rel space]
	call output
	pop rax

	ror rax, 40
	mov ecx, 5			; Display the first 5 with separators after
systest_net_disp_MAC:
	call dump_al
	lea rsi, [rel macsep]
	call output
	rol rax, 8
	sub ecx, 1
	test ecx, ecx
	jnz systest_net_disp_MAC
	call dump_al			; Display the last

	lea rsi, [rel newline]
	call output
	inc edx
	jmp systest_net_disp
systest_net_disp_done:

	lea rsi, [rel netteststring1b]
	call output

systest_net_wait_for_input:
	call [b_input]
	or al, 00100000b		; Convert to lowercase
	xor edx, edx
	cmp al, "0"
	je systest_net_test
	inc edx
	cmp al, "1"
	je systest_net_test
	cmp al, "q"
	je systest_net_finish
	jmp systest_net_wait_for_input

systest_net_test:
	; Get the host MAC
	mov ecx, NET_STATUS
	call [b_system]
	cmp eax, 0
	je systest_net_wait_for_input

	lea rdi, [rel source]
	mov rcx, 6
	ror rax, 40
systest_net_srcmacnext:
	stosb
	rol rax, 8
	sub rcx, 1
	cmp rcx, 0
	jne systest_net_srcmacnext

;	; Clear counters
	xor r14, r14			; Packet counter
	xor r15, r15			; Byte counter

	; Prep buffer for packets
	mov ecx, NET_CONFIG
	; EDX already set
	mov rax, 0xFFFF800000200000
	call [b_system]

; Select test type
	lea rsi, [rel netteststring2]
	call output
systest_net_test_wait_for_input:
	call [b_input]
	or al, 00100000b		; Convert to lowercase
	cmp al, "0"
	je systest_net_main_title
	cmp al, "1"
	je systest_net_main_counter_title
	cmp al, "2"
	je systest_net_main_netflood_title
	cmp al, "q"
	je systest_net_finish
	jmp systest_net_test_wait_for_input


; Main network test. Received packets are displayed. Packets can be sent.
systest_net_main_title:
	lea rsi, [rel netteststring3]
	call output
systest_net_main:
	call [b_net_rx]			; RDI will be set to the address of the packet
	cmp cx, 0			; Check if data was received
	jne systest_net_receive
	call [b_input]
	or al, 00100000b		; Convert to lowercase
	cmp al, "s"
	je systest_net_send
	cmp al, "q"
	je systest_net_finish
	jmp systest_net_main

; Network counter test. Keeps track of packets and bytes received
systest_net_main_counter_title:
	lea rsi, [rel netteststring4]
	call output
systest_net_main_counter:
	call [b_net_rx]			; RDI will be set to the address of the packet
	cmp cx, 0			; Check if data was received
	jne systest_net_main_counter_inc
	call [b_input]
	or al, 00100000b		; Convert to lowercase
	cmp al, "q"
	je systest_net_finish
	jmp systest_net_main_counter

systest_net_main_counter_inc:
	inc r14
	add r15, rcx
	jmp systest_net_main_counter

; Network flood test. Keeps track of packets and bytes received
systest_net_main_netflood_title:
	lea rsi, [rel netteststring5]
	call output
	xor r13, r13
	xor r12, r12
systest_net_main_netflood:
	call [b_input]
	or al, 00100000b		; Convert to lowercase
	cmp al, "q"
	je netflood_clear
	call [b_net_rx]			; RDI will be set to the address of the packet
	cmp cx, 0			; Check if data was received
	je systest_net_main_netflood
	inc r14
	add r15, rcx
	mov r12, [rdi+0x10]		; Get current packet #
	cmp r12, r13			; Compare to expected value
	jne netflood_missed		; Not equal, print error
	inc r13				; Otherwise, increment expected value for next packet
	jmp systest_net_main_netflood

netflood_missed:
	lea rsi, [rel nettestflood1]
	call output
	mov rax, r13
	call dump_rax
	lea rsi, [rel nettestflood2]
	call output
	mov rax, r12
	call dump_rax
	lea rsi, [rel newline]
	call output
	; Remove comments to keep test running
;	mov r13, r12
;	jmp systest_net_main_netflood

netflood_clear:
	call [b_net_rx]			; RDI will be set to the address of the packet
	cmp cx, 0			; Check if data was received
	jne netflood_clear
	jmp systest_net_finish

systest_net_finish:
	; Output # of packets recevied
	lea rsi, [rel nettestpackets]
	call output
	mov rax, r14
	call dump_rax
	; Output # of bytes received
	lea rsi, [rel nettestbytes]
	call output
	mov rax, r15
	call dump_rax
	lea rsi, [rel newline]
	call output
	jmp start

; Network send
systest_net_send:
	lea rsi, [rel nettestsendstring]
	call output
	lea rsi, [rel packet]
	mov rcx, 64
	call [b_net_tx]
	jmp systest_net_main

; Network receive and output
systest_net_receive:
	inc r14
	add r15, rcx
	lea rsi, [rel nettestreceivestring]
	call output
	mov rsi, rdi			; RDI holds the address of the packet

	; Output the destination MAC
	mov rcx, 6
systest_net_receive_dest:
	lodsb
	call dump_al
	sub rcx, 1
	cmp rcx, 0
	jne systest_net_receive_dest
	push rsi
	lea rsi, [rel space]
	call output
	pop rsi

	; Output the source MAC
	mov rcx, 6
systest_net_receive_src:
	lodsb
	call dump_al
	sub rcx, 1
	cmp rcx, 0
	jne systest_net_receive_src
	push rsi
	lea rsi, [rel space]
	call output
	pop rsi

	; Output the EtherType
systest_net_receive_type:
	lodsb
	mov bl, al
	shl bx, 8
	call dump_al
	lodsb
	mov bl, al
	call dump_al
	push rsi
	lea rsi, [rel space]
	call output
	pop rsi
	jmp systest_net_main

systest_sto:
	lea rsi, [rel stoteststring]
	call output
	mov r8, 32768			; Starting sector variable. 128MiB into the disk
	call dump_rax

	; Get disk information (maximum sector)

systest_sto_next:
	; Create 2MiB of test data
	mov rdi, 0xFFFF800000200000	; Test memory
	mov edx, 0
	mov ecx, TSC
systest_sto_create_data:
	call [b_system]			; Return TSC in RAX
	stosq
	inc edx
	cmp edx, 262144
	jne systest_sto_create_data

	; Write 2MiB of test data to storage
	xor edx, edx
	mov rsi, 0xFFFF800000200000
	mov ecx, 512			; 2MiB (512 4096-byte sectors)
	mov rax, r8
	call [b_nvs_write]

	; Read 2MiB from storage
	xor edx, edx
	mov rdi, 0xFFFF800000400000
	mov ecx, 512			; 2MiB (512 4096-byte sectors)
	mov rax, r8
	call [b_nvs_read]

	; Compare 2MiB of data in memory
	mov ecx, 262144
	mov rsi, 0xFFFF800000200000
	mov rdi, 0xFFFF800000400000
systest_sto_compare:
	mov rax, [rsi]
	mov rbx, [rdi]
	cmp rax, rbx
	jne systest_sto_error
	dec ecx
	jnz systest_sto_compare
	add r8, 512
	lea rsi, [rel period]
	call output
	jmp systest_sto_next

systest_sto_finish:
	lea rsi, [rel donestring]
	call output
	jmp start

systest_sto_error:
	lea rsi, [rel stotesterror]
	call output
	jmp start

systest_end:
	ret


; -----------------------------------------------------------------------------
; This code will be executed on every available CPU in the system
; The mutex is used so only one CPU can output its message at a time
align 16
smp_task:
	lea rax, [rel outputlock]	; Location of the mutex
	mov rcx, SMP_LOCK		; Aquire the lock
	call [b_system]
	lea rsi, [rel smptestmessage]	; Output the "Hello..." message
	call output
	mov rcx, SMP_ID			; Get the APIC ID of the CPU
	call [b_system]
	call dump_al
	lea rax, [rel outputlock]
	mov rcx, SMP_UNLOCK		; Release the mutex
	call [b_system]
	ret
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; output -- Displays text
;  IN:	RSI = message location (zero-terminated string)
; OUT:	All registers preserved
output:
	push rcx

	call string_length		; Calculate the string length
	call [b_output]			; Output the string via the kernel syscall

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
startstring: db "SysTest", 10, "========", 10, "1 - SMP Test", 10, "2 - Memory Test", 10, "3 - Network Test", 10, "4 - Storage Test", 10, "q - Quit", 10, "Enter selection: ", 0
smpteststring: db 10, "SMP Test", 10, "A message from each core should be displayed", 0
smptestmessage: db 10, "Hello from core 0x", 0
memteststring: db 10, "Memory Test", 10, "Starting at 0x", 0
memteststring2: db ", testing up to ", 0
memtesterror: db 10, "Error at ", 0
memtesterror2: db 10, "Ending test early", 0
netteststring1a: db 10, "Network Test", 10, "============", 10, "Available interfaces:", 10, 0
netteststring1b: db 10, "Select interface (or Q to quit): ", 0
netteststring2: db 10, "Select type of test", 10, "0 - Display packets", 10, "1 - Count packets/bytes received", 10, "2 - netflood test", 10, " ", 10, "Select network test (or Q to quit): ", 0
netteststring3: db 10, "Press S to send a packet, Q to quit.", 10, "Received packets will display automatically", 0
netteststring4: db 10, "Received packets/bytes are being counted", 10, "Press Q to quit.", 0
netteststring5: db 10, "Received packets/bytes are being inspected", 10, "Press Q to quit.", 0
nettestsendstring: db 10, "Sending packet.", 0
nettestreceivestring: db 10, "Received packet: ", 0
nettestflood1: db 10, "Expected 0x", 0
nettestflood2: db ", received 0x", 0
nettestpackets: db 10, "Packets recevied: 0x", 0
nettestbytes: db 10, "  Bytes recevied: 0x", 0
stoteststring: db 10, "Storage Test", 10, "Starting at sector 0x", 0
stotesterror: db 10, "Data mismatch!", 0
donestring: db 10, "Done!", 10, 0
hextable: db "0123456789ABCDEF"
space: db " ", 0
period: db ".", 0
macsep: db ":", 0
dash: db "-", 0
newline: db 10, 0
outputlock: dq 0
tchar: db 0, 0, 0

align 16

packet:
destination: db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
source: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
type: db 0xAB, 0xBA
data: db "This is test data from EthTest for BareMetal"

align 16

buffer: db 0