;Prints argument
;Example: echo Hello, World!

db "echo"
db 6 dup(0x20)
dw end_echo - start_echo
db 0xff
org LOAD_PROG_ORG
start_echo:
	mov si,BUFFER_COM_ORG+5	;Get arg for print
	xor ax,ax	;{Print arg and go new line
	xor bx,bx
	int 0xfe
	mov si,nl
	int 0xfe	;}
@@:
	ret
nl db 13,10,0
end_echo: 
