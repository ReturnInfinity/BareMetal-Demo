; Ethernet Test Program (v1.0, November 17 2023)
; Written by Ian Seyler
;
; BareMetal compile:
; nasm ethtest.asm -o ethtest.app

[BITS 64]
[ORG 0xFFFF800000000000]

%include 'libBareMetal.asm'

start:
	mov rsi, startstring
	mov rcx, 90
	call [b_output]

	; Get the host MAC
	mov rax, [0x110048]		; TODO Get from kernel properly
	mov rdi, source
	mov rcx, 6
srcmacnext:
	stosb
	shr rax, 8
	sub rcx, 1
	cmp rcx, 0
	jne srcmacnext

; Main program loop
ethtest:
	mov rdi, buffer
	call [b_net_rx]
	cmp cx, 0
	jne ethtest_receive
	call [b_input]
	or al, 00100000b		; Convert to lowercase

	cmp al, 's'
	je ethtest_send
	cmp al, 'q'
	je ethtest_finish
	jmp ethtest

ethtest_finish:
	ret				; Return CPU control to the kernel

ethtest_send:
	mov rsi, sendstring
	mov rcx, 16
	call [b_output]
	mov rsi, packet
	mov rcx, 64
	call [b_net_tx]
	jmp ethtest

ethtest_receive:
	mov rsi, receivestring
	mov rcx, 18
	call [b_output]
	mov rsi, buffer

; Output the destination MAC
	mov rcx, 6
ethtest_receiver_dest:	
	lodsb
	call dump_al
	sub rcx, 1
	cmp rcx, 0
	jne ethtest_receiver_dest
	push rsi
	mov rsi, space
	mov rcx, 1
	call [b_output]
	pop rsi

; Output the source MAC
	mov rcx, 6
ethtest_receiver_src:
	lodsb
	call dump_al
	sub rcx, 1
	cmp rcx, 0
	jne ethtest_receiver_src
	push rsi
	mov rsi, space
	mov rcx, 1
	call [b_output]
	pop rsi

; Output the EtherType
ethtest_receiver_type:
	lodsb
	mov bl, al
	shl bx, 8
	call dump_al
	lodsb
	mov bl, al
	call dump_al
	push rsi
	mov rsi, space
	mov rcx, 1
	call [b_output]
	pop rsi
	cmp bx, 0x0806
	je ethtest_receiver_arp
	cmp bx, 0x0800
	je ethtest_receiver_ipv4
	cmp bx, 0x86DD
	je ethtest_receiver_ipv6
	jmp ethtest

ethtest_receiver_arp:
	mov rsi, strARP
	mov rcx, 4
	call [b_output]
	jmp ethtest

ethtest_receiver_ipv4:
	mov rsi, strIPv4
	mov rcx, 4
	call [b_output]
	jmp ethtest

ethtest_receiver_ipv6:
	mov rsi, strIPv6
	mov rcx, 4
	call [b_output]
	jmp ethtest

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


startstring: db 10, 'EthTest: Press S to send a packet, Q to quit.', 10, 'Received packets will display automatically'
space: db ' '
newline: db 10
sendstring: db 10, 'Sending packet.'
receivestring: db 10, 'Received packet: '
strIPv4: db 'IPv4'
strARP: db 'ARP '
strIPv6: db 'IPv6'
tchar: db 0, 0, 0

align 16

packet:
destination: db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
source: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
type: db 0xAB, 0xBA
data: db 'This is test data from EthTest for BareMetal'

align 16

buffer: db 0
