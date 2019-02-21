;Prints the ascii and scan code of a pressed key
;Just run and press any key

db "key-code"
db 2 dup (0x20)
dw end_keycode - start_keycode
db 0xff
org LOAD_PROG_ORG
start_keycode:
	xor ax,ax	;{just print invite
	xor bx,bx
	mov si,wmsg
	int 0xfe	;}
	
	xor ah,ah	;{Get ascii and scan
	int 0x16	;}
	
	push ax
	mov ah,5		;{make msg and get number
	xor bh,bh
	mov di,ascmsg+8
	int 0xfe
	pop ax

	mov al,ah
	mov ah,5
	xor bh,bh
	mov di,ascmsg+16
	int 0xfe		;}
	
	xor ax,ax		;{print result
	mov bh,1
	mov cx,20
	mov si,ascmsg
	int 0xfe		;}
	ret
wmsg db "Press key:",0
ascmsg db 13,10,"Ascii:",0,0," Scan:",0,0,13,10
end_keycode:  
