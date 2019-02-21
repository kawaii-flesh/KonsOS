;Restart PC

db "restart"
db 3 dup (0x20)
dw end_res - start_res
db 0xff
org LOAD_PROG_ORG
start_res:
	jmp 0xffff:0	;it's work :)
end_res: 
