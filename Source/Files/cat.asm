;Displays the burned file
;Example: cat logo.txt

db "cat"
db 7 dup (0x20)
dw end_cat - start_cat
db 0xff
org LOAD_PROG_ORG
start_cat:
	mov ah,4	;{Get second arg(file name)
	mov bh,0
	mov bl,1
	int 0xfe	;}
	xor cx,cx
	push si
@@:	
	lodsb		;{Get arg size for compare name
	test al,al
	jz @f
	inc cx		;}
	jmp @b
@@:		
	mov si,START_FILE_SPACE
	mov di,si		
	pop si

ccheck_efs:
	push di si cx		;{CHECK EFS
	mov cx,8
	mov si,FSHI.efs
	rep cmpsb
	pop cx si di
	jnz csearch_file 	;if not EFS then start search
	mov al,0xff
	jmp qcat 			;}

csearch_file:
	push di si cx		;{Compare name
	rep cmpsb
	pop cx si di
	jz creturn_info 	;}if all good return addr

cover_file:
	add di,[di+10] 	;{if this file not our
	add di,13			;}then choise next
	jmp ccheck_efs

creturn_info:
	cmp cx,10		
	jz cshow
	xor bx,bx	;{if name less 10 bytes
	push si di
	mov si,di
@@:	
	lodsb
	cmp al,0x20
	jz @f
	inc bx
	jmp @b
@@:
	pop di si
	cmp cx,bx	;}if yes then all good show file data
	jnz cover_file
cshow:	
	mov si,di		;{get size and offs start data
	add si,13
	xor ax,ax
	mov bx,1
	mov cx,[di+10]
	int 0xfe
	xor bx,bx
	mov si,nlc
	int 0xfe		;}print
	jmp qcat 		   
qcat:
	cmp al,0xff		;{if file not found print error
	jnz @f
	xor ax,ax
	xor bx,bx
	mov si,cerror_found
	int 0xfe			;}
@@:	
	ret
nlc db 13,10,0
cerror_found db "File not found!",13,10,0
end_cat: 
