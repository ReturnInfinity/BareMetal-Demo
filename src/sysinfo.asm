; System Information Program (v1.0, January 28 2020)
; Written by Ian Seyler
;
; BareMetal compile:
; nasm sysinfo.asm -o sysinfo.app

[BITS 64]
[ORG 0xFFFF800000000000]

%INCLUDE "libBareMetal.asm"

start:				; Start of program label

	mov rsi, startmessage	; Load RSI with memory address of string
	call output		; Print the string that RSI points to

; Get processor brand string
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

; CPU features
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

; RAM
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

; Storage
	mov rsi, stomessage
	call output

check_ahci:
	mov rsi, ahcimessage
	call output
	cmp byte [0x110000 + 795], 1
	je ahci_enabled
	mov rsi, dismessage
	call output
	jmp check_nvme
ahci_enabled:
	mov rsi, enmessage
	call output	

check_nvme:
	mov rsi, nvmemessage
	call output
	cmp byte [0x110000 + 794], 1
	je nvme_enabled
	mov rsi, dismessage
	call output
	jmp stoend
nvme_enabled:
	mov rsi, enmessage
	call output
	mov rsi, space
	call output
	mov rsi, quote
	call output
	mov rsi, 0x174000
	mov rcx, 71
	call [b_output]
	mov rsi, quote
	call output

stoend:

; PCI devices
	mov rsi, pcimessage
	call output
	mov edx, 2	;xor edx, edx			; Start with PCI device 0,0

next_pci:
	push rdx			; Save the PCI device

	mov rcx, pci_read		; PCI read
	call [b_config]
	mov ebx, eax			; Save the output to EBX

	cmp eax, 0xFFFFFFFF		; Non-existent device
	je skip				; Skip if there is no device

	push rax			; Save the Class Code
	mov eax, edx
	shr eax, 8
	call dump_ax			; Display Bus/Device/Function
	pop rax
	mov rsi, space
	call output
	call output
	rol eax, 8
	call dump_al			; Display Class
	mov rsi, space
	call output
	call output
	call output
	call output
	rol eax, 8
	call dump_al			; Display Subclass
	mov rsi, space
	call output
	call output
	call output
	call output
	rol eax, 16
	sub edx, 2
	call [b_config]
	rol eax, 16
	call dump_ax			; Display Device ID
	mov rsi, space
	call output
	call output
	rol eax, 16
	call dump_ax			; Display Vendor ID
	mov rsi, space
	call output
	call output
	add edx, 2

	mov eax, ebx
	shr eax, 24			; Code in AL
	shl eax, 5			; Quick multiply by 32
	mov rsi, pci_classes
	add rsi, rax
	call output			; Display Description
	
	shr eax, 5
	cmp al, 01
	je pci_storage
	cmp al, 02
	je pci_network
	cmp al, 03
	je pci_display
	jmp pci_newline

pci_storage:
	mov eax, ebx
	shr eax, 16
	and eax, 0xFF
	cmp al, 8
	jg pci_newline
	shl eax, 5			; Quick multiply by 32
	mov rsi, pci_01_subclasses
	add rsi, rax
	call output
	jmp pci_newline

pci_network:
	mov eax, ebx
	shr eax, 16
	and eax, 0xFF
	cmp al, 0
	jg pci_newline
	shl eax, 5			; Quick multiply by 32
	mov rsi, pci_02_subclasses
	add rsi, rax
	call output
	jmp pci_newline

pci_display:
	mov eax, ebx
	shr eax, 16
	and eax, 0xFF
	cmp al, 2
	jg pci_newline
	shl eax, 5			; Quick multiply by 32
	mov rsi, pci_03_subclasses
	add rsi, rax
	call output
	jmp pci_newline

pci_newline:
	mov rsi, newline		; Output a newline character
	call output

skip:
	pop rdx				; Restore the PCI device
	add edx, 0x100			; Increment to next device
	cmp edx, 0xFFFF00
	jl next_pci

	ret				; Return CPU control to the kernel

; Fin
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


startmessage: db 'System Information:' ; String falls through to newline
newline: db 13, 0
quote: db '"', 0
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
stomessage: db 13, 'Storage:', 0
ahcimessage: db 13, 'AHCI - ', 0
nvmemessage: db 13, 'NVMe - ', 0
dismessage: db 'Disabled', 0
enmessage: db 'Enabled', 0
pcimessage: db 13, 'PCI:', 13, 'BDF   Class Subcl Devic Vendr Class Description              Subclass Description', 13, 0
pci_classes:
pci_00: db 'Unclassified device            ', 0
pci_01: db 'Mass storage controller        ', 0
pci_02: db 'Network controller             ', 0
pci_03: db 'Display controller             ', 0
pci_04: db 'Multimedia controller          ', 0
pci_05: db 'Memory controller              ', 0
pci_06: db 'Bridge                         ', 0
pci_07: db 'Communication controller       ', 0
pci_08: db 'Generic system peripheral      ', 0
pci_09: db 'Input device controller        ', 0
pci_0A: db 'Docking station                ', 0
pci_0B: db 'Processor                      ', 0
pci_0C: db 'Serial bus controller          ', 0
pci_0D: db 'Wireless controller            ', 0
pci_0E: db 'Intelligent controller         ', 0
pci_0F: db 'Satellite comms controller     ', 0
pci_10: db 'Encryption controller          ', 0
pci_11: db 'Signal processing controller   ', 0
pci_12: db 'Processing accelerators        ', 0
pci_13: db 'Non-Essential Instrumentation  ', 0

pci_01_subclasses:
pci_01_00: db 'SCSI storage controller        ', 0
pci_01_01: db 'IDE interface                  ', 0
pci_01_02: db 'Floppy disk controller         ', 0
pci_01_03: db 'IPI bus controller             ', 0
pci_01_04: db 'RAID bus controller            ', 0
pci_01_05: db 'ATA controller                 ', 0
pci_01_06: db 'SATA controller                ', 0
pci_01_07: db 'Serial Attached SCSI controller', 0
pci_01_08: db 'Non-Volatile memory controller ', 0

pci_02_subclasses:
pci_02_00: db 'Ethernet controller            ', 0

pci_03_subclasses:
pci_03_00: db 'VGA compatible controller      ', 0
pci_03_01: db 'XGA compatible controller      ', 0
pci_03_02: db '3D controller                  ', 0

pci_blank: db '                               ', 0

hextable: db '0123456789ABCDEF'
tchar: db 0, 0, 0
space: db ' ', 0
tstring: times 50 db 0
