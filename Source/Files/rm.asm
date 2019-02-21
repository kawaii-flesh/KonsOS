;rm - program for remove file
;Use: rm [fname]
;Example: rm file
db "rm"
db 8 dup(0x20)
dw end_rm - start_rm
db 0xff
org LOAD_PROG_ORG
start_rm:
	mov ah,4 		;{Check count arg if less print msg and back in shell
	mov bh,1
	int 0xfe
	cmp cx,2
	jz @f
	xor ax,ax
	xor bx,bx
	mov si,earm
	int 0xfe
	ret				;}
@@:	
	mov cx,10	;{Clear buff for file name
	mov al,0x20
	mov di,USER_BUFFER_ORG
	rep stosb	;}
	
	mov si,BUFFER_ARG_ORG+10	;Get file name from buff_arg
	
	mov di,USER_BUFFER_ORG		;{Get name
@@:	
	lodsb
	test al,al
	jz @f
	stosb
	jmp @b			;}
@@:
	
	mov ah,3		;{Remove file
	mov bh,2
	mov si,USER_BUFFER_ORG
	int 0xfe		;}
	ret
earm db "Use: rm [fname]",13,10,"Example: rm file",13,10,0	
effrm db "File not found!",13,10,0
end_rm:
