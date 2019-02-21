db "kernel.bin"
dw end_kernel - start_kernel
db 0xff

start_kernel:
	mov si,4*0xfe 		;{Set interput
	mov word [si],intc
	mov word [si+2],0 ;}

	xor ah,ah
	xor bh,bh
	mov si,load_kernel
	int 0xfe

	mov ah,3 		;{Load shell.bin
	mov si,fnshell
	mov di,START_FILE_SPACE
	int 0xfe 		;}

	call di 		;{Go work}

;=======[INTERPUT]=======
intc:
	test ah,ah
	jnz i1
i0:
	push si ax bx cx
	test bh,bh
	jnz i0f1
	mov ah,0x0e
@@:
	lodsb 	 	;{load byte from si and show
	test al,al
	jz @f
	int 0x10 	;}
	jmp @b
@@:
	pop cx bx ax si
	jmp qintc

i0f1:
	mov ah,0x0e
@@:
	test cx,cx	;{load byte from si and show
	jz @f
	lodsb
	int 0x10
	dec cx 		;}
	jmp @b
@@:
	pop cx bx ax si
	jmp qintc
;-----------------		
i1:
	dec ah
	jnz i2
	mov si,di
@@:
	xor ah,ah	;{Get key and compare 
	int 0x16
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
	jz .e		
	test cx,cx	;check limit
	jz @b 		;{

	stosb 		;{write symbol in buff_com and show
	mov ah,0x0e
	int 0x10
	dec cx 		;}
	jmp @b
;-----------------	
.l:
	cmp di,si
	jz .ql
	push cx
	mov ah,3 	;{move cursor left
	xor bx,bx
	int 0x10
	dec dl
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
	mov ah,3 	;{move cursor right
	xor bx,bx
	int 0x10
	inc dl
	mov ah,2
	int 0x10 	;}
	inc di
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

	inc cx
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

	inc cx
	jmp @b	
;-----------------	
.h:
	push cx
	mov ah,3 	;{move cursor to start
	xor bx,bx
	int 0x10
	sub di,si
	sub dx,di
	mov ah,2
	int 0x10 	;}
	pop cx
	mov di,si
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
	mov al,13 	;{go new line
	mov ah,0x0e
	int 0x10
	mov al,10
	int 0x10 	;}
	jmp qintc
;-----------------	
i2:
	dec ah
	jnz i3
	test bh,bh
	jnz i2f1
	push dx cx ax bx
	xor dx,dx		;{calculation lba
	div [FSHI.spt]
	mov cl,dl
	inc cl
	div [FSHI.hc]
	mov dh,ah
	mov ch,al
	mov dl,[FSHI.disk_id]
	mov al,bl
	mov bx,di		;{
	mov si,3
@@:
	mov ah,2		;{try load sectors
	int 0x13
	jnc @f
	xor ah,ah
	int 0x13
	dec si
	jnz @b			;}
	pop bx ax cx dx
	mov al,0xee
	jmp qintc
@@:
	pop bx ax cx dx
	xor al,al
	jmp qintc
i2f1:
	dec bh
	jnz qintc
	push dx cx ax bx
	xor dx,dx		;{calculation lba
	div [FSHI.spt]
	mov cl,dl
	inc cl
	div [FSHI.hc]
	mov dh,ah
	mov ch,al
	mov dl,[FSHI.disk_id]
	mov al,bl
	mov bx,di		;{
	mov si,3
@@:
	mov ah,3		;{try write sectors
	int 0x13
	jnc @f
	xor ah,ah
	int 0x13
	dec si
	jnz @b			;}
	pop bx ax cx dx
	mov al,0xee
	jmp qintc
@@:
	pop bx ax cx dx
	xor al,al
	jmp qintc
;-----------------		
i3:
	dec ah
	jnz i4
	test bh,bh
	jnz i3f1
.check_efs:
	push di si 			;{CHECK EFS
	mov cx,8
	mov si,FSHI.efs
	rep cmpsb
	pop si di
	jnz .search_file 	;if not EFS then start search
	mov al,0xee
	jmp qintc 			;}
	
.search_file:
	push di si 		;{Compare name
	mov cx,10
	rep cmpsb
	pop si di
	jz .return_info ;}if all good return addr

.over_file:
	add di,[di+10] 	;{if this file not our
	add di,13			;}then choise next
	jmp .check_efs

.return_info:
	mov si,di 		;{return info
	mov cx,[di+10]
	add di,13
	mov al,[di-1]
	jmp qintc 		;}
i3f1:
	dec bh
	jnz i3f2
	mov dx,di
	push si cx ax
	mov si,START_FILE_SPACE
@@:					;{Search EFS
	push si di
	mov cx,8
	mov di,FSHI.efs
	rep cmpsb
	pop di si
	jz @f
	inc si
	jmp @b
@@:					;}
	mov di,si		;{Write file in mem(name,size,type and write EFS(0xff,0xff,0xff,0xff,0xff))
	pop ax cx si
	push cx
	mov cx,10
	rep movsb
	pop cx
	push ax
	mov ax,cx
	stosw
	pop ax
	stosb
	
	mov si,dx
	rep movsb
	
	mov al,0xff
	mov cx,8
	rep stosb		;}

	mov di,START_FILE_SPACE				;{
	xor dx,dx 				;Write
	mov al,[FSHI.ffl]		;all
	mov ah,2
	mov bh,1
	mov bl,[FSHI.sfsf]	 	;files
	int 0xfe				;}
	xor al,al
	jmp qintc

i3f2:
	dec bh
	jnz qintc
	mov ah,3		;{SEARCH_FILE
	xor bh,bh
	mov di,START_FILE_SPACE
	int 0xfe		;}
	cmp al,0xee
	jz qintc
	
	add cx,13		;{REMOVE FILE AND FILING ZERO
	push si
	mov di,si
	xor ax,ax
	rep stosb
	push di			;{
		
@@:					;{CHECK EFS
	mov cx,8
	mov si,FSHI.efs
	rep cmpsb
	jnz @b			;}

	xchg cx,di	;{MOVE ALL FILES(AFTER DEL FILE)
	pop si
	sub cx,si
	pop di
	rep movsb	;}
	
	mov di,START_FILE_SPACE		;{
	xor dx,dx 				;Write
	mov al,[FSHI.ffl]		;all
	mov ah,2
	mov bh,1
	mov bl,[FSHI.sfsf]	 	;files
	int 0xfe				;}
	jmp qintc
;-----------------		
i4:
	dec ah
	jnz i5
	test bh,bh
	jnz i4f1
;GET_ARG - 0, BL - ARG NUMBER
	mov si,BUFFER_ARG_ORG
@@:
	test bl,bl	;{get arg offs
	jz qintc
	lodsb
	test al,al
	jz qintc
	cmp al,0x20
	jz gna		;}
	jmp @b
gna:
	lodsb		;{go next arg
	cmp al,0x20
	jz gna
	dec bl
	dec si		;}
	jmp @b
i4f1:
	dec bh
	jnz qintc
;GET_ARG_COUNT - 1;CX - COUNT
	mov si,BUFFER_ARG_ORG
	xor cx,cx
gnaicl:	
	lodsb
	test al,al
	jz qintc
	inc cx
@@:	
	lodsb
	test al,al
	jz qintc
	cmp al,0x20	
	jnz @b
@@:	
	lodsb
	cmp al,0x20
	jz @b
	dec si
	jmp gnaicl
;-----------------		
i5:	
	dec ah
	jnz i6
	test bh,bh
	jnz i5f1
	mov bx,stable
	push ax
	shr al,4
	xlatb
	stosb
	pop ax
	and al,1111b
	xlatb
	stosb
	jmp qintc
stable db "0123456789ABCDEF"
	
i5f1:
	dec bh
	jnz qintc
	lodsb		;{Make high bits
	cmp al,'A'
	jnl @f
	sub al,0x30
	jmp .hbd
@@:	
	sub al,0x37
	cmp al,'G'
	jnz @f
	dec al
@@:	
.hbd:
	shl al,4
	mov bl,al	;}

	lodsb		;{Make low bits
	cmp al,'A'
	jnl @f
	sub al,0x30
	jmp .lbd
@@:
	sub al,0x37
	cmp al,'G'
	jnz @f
	dec al
@@:	
.lbd:		
	add al,bl	;}
	jmp qintc	
;-----------------		
i6:	
qintc:
	iret

;KERNEL_DATA
load_kernel db "kernel.bin - done!",13,10,0
fnshell db "shell.bin",0x20
end_kernel: 
