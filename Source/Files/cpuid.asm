;------------
;Get cpu info
;------------
db "cpuid" 
db 5 dup(0x20)
dw end_cpuid - start_cpuid
db 0xff
org LOAD_PROG_ORG
start_cpuid:
	pushfd 				;{Check cpuid supported
	pop  eax
	mov  ebx,eax     
	xor  eax,200000h     
	push eax
	popfd
	pushfd
	pop eax   
	cmp eax,ebx       
	jne @f
	xor ax,ax
	xor bx,bx
	mov si,cpuidns
	int 0xfe
	ret					;}if not print message and return
cpuidns db "CpuID not supported",13,10,0
@@:	
	mov di,USER_BUFFER_ORG			;{Get info
	mov eax,0x80000002
	mov ecx,3
@@:	
	test ecx,ecx
	jz @f
	push ecx
	push eax
	cpuid
	stosd
	xchg eax,ebx
	stosd
	xchg eax,ecx
	stosd
	xchg eax,edx
	stosd
	pop eax
	pop ecx
	inc eax
	dec ecx
	jmp @b				;}
@@:	
	mov si,USER_BUFFER_ORG		;{Search string end and add endl(13,10)
@@:	
	lodsb
	test al,al
	jnz @b
	
	dec si
	mov di,si
	mov al,13
	mov ah,10
	stosw				;}
	
	xor ax,ax			;{Just print info
	xor bx,bx
	mov si,USER_BUFFER_ORG
	int 0xfe			;}
	ret					;back in black
end_cpuid:
