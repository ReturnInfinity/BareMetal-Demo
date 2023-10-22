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
	mov rcx, 83
	call [b_output]

	; Get the host MAC
	mov rax, [0x110050]		; TODO Get from kernel properly
	mov rdi, source
	mov rcx, 6
srcmacnext:
	stosb
	shr rax, 8
	sub rcx, 1
	cmp rcx, 0
	jne srcmacnext

	; Configure the function to run on network activity
	mov rax, ethtest_receiver
	mov rcx, networkcallback_set
	call [b_config]

ethtest:
	call [b_input]
	or al, 00100000b		; Convert to lowercase

	cmp al, 's'
	je ethtest_send
	cmp al, 'q'
	je ethtest_finish
	jmp ethtest

ethtest_finish:
	mov rax, 0
	mov rcx, networkcallback_set
	call [b_config]
	ret				; Return CPU control to the kernel

ethtest_send:
	mov rsi, sendstring
	mov rcx, 16
	call [b_output]
	mov rsi, packet
	mov rcx, 50
	call [b_net_tx]
	jmp ethtest

ethtest_receiver:
	mov rsi, receivestring
	mov rcx, 18
	call [b_output]
	mov rdi, buffer
	call [b_net_rx]

	mov rsi, buffer
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
	push rbx
	push rax
	mov rbx, hextable
	push rax			; Save RAX since we work in 2 parts
	shr al, 4			; Shift high 4 bits into low 4 bits
	xlatb
	mov [tchar+0], al
	pop rax
	and al, 0x0f			; Clear the high 4 bits
	xlatb
	mov [tchar+1], al
	push rsi
	push rcx
	mov rcx, 2
	mov rsi, tchar
	call [b_output]
	pop rcx
	pop rsi
	pop rax
	pop rbx
	ret

hextable: db '0123456789ABCDEF'
startstring: db 'EthTest: S to send a packet, Q to quit.', 10, 'Received packets will display automatically'
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
