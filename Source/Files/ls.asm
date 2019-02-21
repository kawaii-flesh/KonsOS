;Displays the contents of the file system
;Example: ls or ls -m(Shows the size and file type)

db "ls"
db 8 dup (0x20)
dw end_ls - start_ls
db 0xff
org LOAD_PROG_ORG
start_ls:	
	mov si,START_FILE_SPACE
	mov di,FSHI.efs
wls:
	push di si	;{compare end fs(efsb)
	mov cx,8
	rep cmpsb
	pop si di
	jz qls		;}if end fs leave else go next

	push di si
	xor ax,ax	;{Print file name
	mov bh,1
	mov cx,10
	int 0xfe	;}
	
	push si
	mov ah,4				;{if set flag m(ls -m)
	mov bh,0
	mov bl,1
	int 0xfe
	cmp byte[si+1],'m'	;}get more information
	pop si
	jnz @f
	
show_information:
;{Get size
	push si
	mov ah,5		;{make number
	mov al,[si+11]	;size
	mov di,ssib+3	;{make msg for print
	xor bx,bx
	int 0xfe
	
	mov ah,5
	mov al,[si+10]
	xor bx,bx
	mov di,ssib+5
	int 0xfe		;}}
	
	xor ax,ax		;{Print msg(size)
	mov bh,1
	mov cx,13
	mov si,ssib
	int 0xfe		;}
;}	
;{Get type	
	pop si
	xor ax,ax			;{File or program
	xor bx,bx
	cmp byte[si+12],0
	jnz ptp
	mov si,tif
	int 0xfe
	jmp @f
ptp:	
	mov si,tip
	int 0xfe			;}
;}	
@@:	
	xor ax,ax			;{Go new line
	xor bx,bx
	mov si,ends
	int 0xfe			;}
	pop si di

	add si,13			;{Go next file
	add si,[si-3]
	jmp wls				;}
qls:
	ret	;back in shell
ssib db " - ",0,0,0,0," Bytes"
tip	 db " - Excecution file",0
tif	 db " - Simple file",0
ends db 13,10,0
end_ls: 
