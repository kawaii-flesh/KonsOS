;An example of a simple program
db "hello"
db 5 dup (0x20)
dw end_hello - start_hello
db 0xff
org LOAD_PROG_ORG
start_hello:		;{Just print Hello, World!
	xor ah,ah
	xor bh,bh
	mov si,hello_msg
	int 0xfe		;}
	ret	;go back
hello_msg db "Hello, World!",13,10,0
end_hello: 
