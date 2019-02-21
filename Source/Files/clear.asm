;Clear the terminal screen

db "clear"
db 5 dup (0x20)
dw end_clear - start_clear
db 0xff
org LOAD_PROG_ORG
start_clear:
	mov ah,0x0f	;{just clear screen
	int 0x10
	xor ah,ah
	int 0x10		;}
	ret
end_clear: 
