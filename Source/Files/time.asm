;show/set date and time
;Example show: time
;Example set date: time -d 2001-03-14
;Example set time: time -t 17:49:15
;show date and time

db "time"
db 6 dup (0x20)
dw end_time - start_time
db 0xff
org LOAD_PROG_ORG
start_time:
	mov ah,4	;{Get first arg
	mov bh,0
	mov bl,1
	int 0xfe	;}
	
	cmp byte[si+1],'d'
	jnz @f
	
	mov ah,4 ;{Set date
	mov bh,0
	mov bl,2
	int 0xfe
	
	mov ah,5
	mov bh,1
	int 0xfe
	mov ch,al
	
	mov ah,5
	mov bh,1
	int 0xfe
	mov cl,al
	inc si
	
	mov ah,5
	mov bh,1
	int 0xfe
	mov dh,al
	inc si
	
	mov ah,5
	mov bh,1
	int 0xfe
	mov dl,al
	
	mov ah,5
	int 0x1a	;}
	jmp .qtime
@@:	
	cmp byte[si+1],'t'
	jnz @f
	
	mov ah,4	;{Set time
	mov bh,0
	mov bl,2
	int 0xfe
	
	mov ah,5
	mov bh,1
	int 0xfe
	mov ch,al
	inc si
	
	mov ah,5
	mov bh,1
	int 0xfe
	mov cl,al
	inc si
	
	mov ah,5
	mov bh,1
	int 0xfe
	mov dh,al

	xor dl,dl
	
	mov ah,3
	int 0x1a	;}
	
	jmp .qtime
@@:	
	mov ah,4	;{Get Year,Month,Day
	int 0x1a	;}
	
	jnc @f		;{if clock not work print msg and out
	xor ax,ax
	xor bx,bx
	mov si,error_clock_msg
	int 0xfe
	ret
@@:	
	mov ah,5	;{preparation msg
	xor bx,bx	;Year
	mov al,ch
	mov di,td
	int 0xfe
	mov ah,5
	mov al,cl
	xor bx,bx
	int 0xfe
	
	inc di
	
	mov ah,5
	mov al,dh	;Month
	xor bx,bx
	int 0xfe
	
	inc di
	
	mov ah,5
	mov al,dl	;Day
	xor bx,bx
	int 0xfe	;}
	
	mov ah,2	;{Get Hour,Minute,Second
	int 0x1a	;}
	
	mov ah,5	;{preparation msg
	mov al,ch
	mov di,tt	;Hour
	xor bx,bx
	int 0xfe
	
	inc di
	
	mov ah,5
	mov al,cl	;Minute
	xor bx,bx
	int 0xfe
	
	inc di
	
	mov ah,5
	mov al,dh	;Second
	xor bx,bx
	int 0xfe	;}
	
	xor ax,ax	;{Print msg
	mov bh,1
	mov si,td
	mov cx,36
	int 0xfe	;}

.qtime:	
	ret	;back in black

td db 0,0,0,0,"-",0,0,"-",0,0,"(Y-M-D)",13,10
tt db 0,0,":",0,0,":",0,0,"(H:M:S)",13,10
error_clock_msg db "Clock not work!",13,10,0
end_time:
