;Touch - program for create file
;Use: touch [fname] [size] [type(00/FF)]
;Example: touch prog.bin 3A29 FF
db "touch"
db 5 dup(0x20)
dw end_touch - start_touch
db 0xff
org LOAD_PROG_ORG
start_touch:
	mov cx,10	;{Clear buff for file name
	mov ax,0x20
	mov di,USER_BUFFER_ORG
	rep stosb	;}
	
	mov ah,4 				;{Check count arg if less print msg and back in shell
	mov bh,1
	int 0xfe
	
	cmp cx,4
	jz @f
	xor ax,ax
	xor bx,bx
	mov si,error_touch_arg
	int 0xfe
	ret						;}
@@:	
	mov ah,4		;{Get name
	mov bh,0
	mov bl,1
	int 0xfe
	mov di,USER_BUFFER_ORG
@@:	
	lodsb
	cmp al,0x20
	jz @f
	stosb
	jmp @b			;}
@@:
	mov ah,5	;{Get size
	mov bh,1
	int 0xfe
	mov ch,al
	
	mov ah,5
	mov bh,1
	int 0xfe
	mov cl,al 	;}
	
	mov ah,4	;{Get type
	mov bh,0
	mov bl,3
	int 0xfe
	
	mov ah,5
	mov bh,1
	int 0xfe	;}
	
	mov ah,3	;{Create file
	mov bh,1
	mov si,USER_BUFFER_ORG
	xor di,di
	int 0xfe	;}
	test al,al
	jz @f
	xor ax,ax
	xor bx,bx
	mov si,errtcf
	int 0xfe
@@:	
	ret
error_touch_arg db "Use: touch [fname] [size] [type(00/FF)]",13,10
db "Example: touch prog.bin 3A29 FF",13,10,0
errtcf db "Cant't create file!",13,10,0
end_touch:
