db "shell.bin",0x20
dw end_shell - start_shell
db 0xff

start_shell:
	
	xor ah,ah			;{print if load good
	xor bh,bh
	mov si,load_shell
	int 0xfe			;}
	
	mov ah,3 		;{Load logo.txt
	xor bh,bh
	mov di,START_FILE_SPACE
	mov si,logotxt
	int 0xfe 		;}
	
	xor ax,ax	;{Print logo
	xor bx,bx
	mov si,di
	int 0xfe	;}
	
wait_com:
	xor ax,ax		;{show invite
	xor bh,bh
	mov si,input_wc
	int 0xfe		;}

	mov cx,512		;{Clear buffs
	xor ax,ax
	push cx
	mov di,BUFFER_COM_ORG
	rep stosb
	pop cx
	mov di,BUFFER_ARG_ORG
	rep stosb		;}
	
	mov ah,1		;{read command
	mov cx,512
	mov di,BUFFER_COM_ORG
	int 0xfe		;}

	mov si,BUFFER_COM_ORG
	mov di,BUFFER_ARG_ORG
	mov cx,10
	push si
@@:
	cmp cx,-1			;{if file name larger 10 bytes print error
	jz error_found_file
	lodsb				;{make right command(add desiderata byte for file name)
	test al,al
	jz adder
	cmp al,0x20
	jz adder
    stosb
   	dec cx
    jmp @b
adder:
	mov al,0x20
	rep stosb
cdone:
	pop si
@@:
	lodsb
	test al,al
	jz fdone
	cmp al,0x20
	jz ncheck
	jmp @b
ncheck:
@@:
	lodsb
	test al,al
	jz fdone
	stosb
	jmp @b		;}
	
fdone:
	mov ah,3					;{load program
	xor bh,bh
	mov si,BUFFER_ARG_ORG
	mov di,START_FILE_SPACE
	int 0xfe					;}
	cmp al,0xee	;{if all good go next else print msg
	jnz @f
	
error_found_file:	
	xor ax,ax
	xor bh,bh
	mov si,error_found
	int 0xfe
	jmp wait_com
	
@@:				;{
	cmp byte [di-1],0		;{if it's not program print msg and go back
	jnz @f
	mov si,error_executing
	xor ax,ax
	xor bx,bx
	int 0xfe
	jmp wait_com			;}
@@:	
	mov si,di		;{Load program in SPACE FOR PROGRAM
	mov di,LOAD_PROG_ORG
	push di
	rep movsb
	pop di			;}
	call di					;go execution program(in di start program offs)
	jmp wait_com

;SHELL_DATA
load_shell db "shell.bin  - done!",13,10,"================================",13,10,0
logotxt 	db "logo.txt  "
error_found db "File not found!",13,10,0
error_executing db "It is not a program!",13,10,0
input_wc db "[->",0
end_shell: 
