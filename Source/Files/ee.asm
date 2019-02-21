;ee - Easy editor
;Use: ee [file_name]
db "ee"
db 8 dup(0x20)
dw end_ee - start_ee
db 0xff
org LOAD_PROG_ORG
start_ee:
	mov ah,4	;{check count arg
	mov bh,1
	int 0xfe
	cmp cx,2
	jz @f		;}
	xor ax,ax	;{if less 2 print error msg and quit
	xor bx,bx
	mov si,msgargerr
	int 0xfe
	ret			;}
@@:

	mov si,BUFFER_ARG_ORG+10;{Get file name
	mov di,lfname
@@:	
	lodsb
	test al,al
	jz @f
	stosb
	jmp @b
@@:							;}
	mov ah,3	;{load file
	xor bx,bx
	mov si,lfname
	mov di,START_FILE_SPACE
	int 0xfe	;}
	
	cmp al,0xff	;{Check type file
	jnz @f
	xor ax,ax
	xor bx,bx
	mov si,tferr
	int 0xfe	
	ret			;}if not simple print msg
@@:	
	push ax
	mov ah,0x0f	;{just clear screen
	int 0x10
	xor ah,ah
	int 0x10	;}	
	pop ax
	mov di,USER_BUFFER_ORG
	cmp al,0xee	;{if file found print data from file
	jz .fnf
	push cx
	mov si,di
	rep movsb
	pop cx
	dec cx
	xor ax,ax
	mov bx,bx
	mov si,USER_BUFFER_ORG
	int 0xfe	;}
	mov di,si	;{For get new chr
	add di,cx	;}
	jmp @f
.fnf:
	xor cx,cx
@@:	
;=====================================
	mov si,USER_BUFFER_ORG
@@:
	xor ah,ah	;{Get key and compare 
	int 0x16
	cmp ah,1	;show menu
	jz .menu
	cmp al,13 	;enter
	jz .eif
	cmp ah,0x4b ;left
	jz .l
	cmp ah,0x4d	;right
	jz .r
	cmp ah,0xe	;back scape
	jz .b
	cmp ah,0x53	;delete
	jz .d
	cmp ah,0x47	;home
	jz .h
	cmp ah,0x4f	;end
	jz .e		;}

	stosb 		;{write symbol
	mov ah,0x0e
	int 0x10	;}
	inc cx	
	jmp @b
;-----------------	
.l:
	cmp di,si
	jz .ql
	cmp word[di-2],1310
	jnz .lne
	push cx
	sub di,2
	xor cx,cx
	xor bx,bx
	mov ah,2
	int 0x10
	pop cx	
	jmp @b
.lne:	
	push cx
	mov ah,3 	;{move cursor left
	xor bx,bx
	int 0x10
	dec dl
	xor cx,cx
	mov ah,2
	int 0x10 	;}
	dec di
	pop cx
.ql:
	jmp @b
;-----------------	
.r:
	cmp byte[di],0
	jz .qr
	cmp word[di+1],1013
	jz .qr
	push cx
	mov ah,3 	;{move cursor right
	xor bx,bx
	int 0x10
	inc dl
	mov ah,2
	int 0x10 	;}
	inc di
	pop cx
.qr:
	jmp @b
;-----------------	
.b:
	cmp di,si
	jz @b
	push cx
	mov ah,3 	;{move cursor left
	xor bx,bx
	int 0x10
	dec dl
	mov ah,2
	int 0x10 	;}
	pop cx
	push dx si
	mov si,di
	dec di
	push di
.nbd:			;{Replace byte and print
	lodsb
	test al,al
	jz .bd
	stosb
	mov ah,0x0e
	int 0x10
	jmp .nbd
.bd:	
	stosb
	mov ah,0x0e
	int 0x10	;}
	pop di si dx
	push cx dx
	mov ah,3 	;{move cursor back
	xor bx,bx
	int 0x10
	pop dx
	mov ah,2
	int 0x10 	;}
	pop cx

	dec cx
	jmp @b
;-----------------
.d:
	cmp byte[di],0
	jz @b
	push cx
	mov ah,3 	;{get position
	xor bx,bx
	int 0x10
	pop cx
	push dx si
	mov si,di
	inc si
	push di
.ndd:			;{Replace byte and print
	lodsb
	test al,al
	jz .bd
	stosb
	mov ah,0x0e
	int 0x10
	jmp .nbd
.dd:	
	stosb
	mov ah,0x0e
	int 0x10	;}
	pop di si dx
	push cx dx
	mov ah,3 	;{move cursor back
	xor bx,bx
	int 0x10
	pop dx
	mov ah,2
	int 0x10 	;}
	pop cx

	dec cx
	jmp @b	
;-----------------	
.h:
	push cx
	mov ah,3 	;{move cursor to start
	xor bx,bx
	int 0x10
	push dx
	xor dh,dh
	sub di,dx
	pop dx
	xor dl,dl
	mov ah,2
	int 0x10 	;}
	pop cx
	jmp @b
;-----------------
.e:
	push cx
	mov ah,3 	;{get position and move end
	xor bx,bx
	int 0x10
	pop cx
	push si
	mov si,di
.ces:	
	lodsb
	test al,al
	jz .ed
	inc di
	inc dl
	jmp .ces
.ed:	
	pop si
	mov ah,2
	int 0x10 	;}
	jmp @b
;-----------------	
.eif:
	push cx	;{Get position
	mov ah,3
	xor bx,bx
	int 0x10
	pop cx	;}
	mov al,13 	;{go new line
	mov ah,0x0e
	int 0x10
	stosb
	mov al,10
	int 0x10 	;}
	stosb
	add cx,2
	jmp @b
;=====================================
.menu:
	mov ah,5	;{Set page
	mov al,1
	int 0x10	;}
	
	push cx		;{move cursor to start
	mov ah,3 	
	mov bh,1
	int 0x10
	xor dx,dx
	mov ah,2
	int 0x10 	;}
	pop cx
	
	xor ax,ax	;{Show menu
	xor bx,bx
	mov si,menu
	int 0xfe	;}
	
	xor ah,ah	;{Get key and compare 
	int 0x16
	cmp al,0x30
	jz .ee_exit
	cmp al,0x31
	jz .ee_save
	jmp .ee_cancel;}

.ee_exit:	
	mov ah,5
	xor al,al
	int 0x10
	
	mov ah,0x0f	;{just clear screen
	int 0x10
	xor ah,ah
	int 0x10	;}			
	ret

.ee_save:
	push cx
	mov ah,3	;{Remove file
	mov bh,2
	mov si,USER_BUFFER_ORG
	int 0xfe	;}
	pop cx
	
	mov ah,3	;{Recreate file
	mov bh,1
	mov si,lfname
	mov di,USER_BUFFER_ORG
	xor al,al
	int 0xfe	;}
	jmp .ee_exit
	
.ee_cancel:
	mov ah,5
	xor al,al
	int 0x10
	jmp @b
;[MSG
msgargerr db "Use:ee [file_name]",13,10,0
tferr db "This is not a simple file!",13,10,0
;]
;[MENU
menu db "======Easy editor======",13,10
	 db "0.Exit without save",13,10
	 db "1.Save file",13,10
	 db "2.Cancel",13,10
	 db "=======================",13,10
	 db "Press key for choice:",0
;]
;[OTHER
lfname	db 10 dup(0x20),0
;]
end_ee:
