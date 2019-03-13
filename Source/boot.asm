;Author:	kawaii-flesh
;Compiler: 	FASM(v 1.73.02 or better)
;License:	GPL 3.0

;    KonsOS - The simple operating system is running in real mode.
;    Copyright (C) 2019  kawaii-flesh
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.

;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.

;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
use16
org 0x7c00
;[==========[CONST]==========
MAIN_ORG equ 0x7c00
START_FILE_SPACE equ 0x7c00 + 512
USER_BUFFER_ORG equ 0x7c00 - 1000
BUFFER_COM_ORG equ 0x7c00 - 2000
BUFFER_ARG_ORG equ 0x7c00 - 3000
LOAD_PROG_ORG equ 0x7c00 - 4000 
;]===========================
START:
	jmp boot
;[==========[KONSOS_FS_HEADER]==========
FSHI:
.disk_id db ? ;id number
.hc 	 db ? ;head count
.spt	 dw ? ;sector per track
.ffl	 db 1 ;sector there location first file
.sfsf	 db 10 ;sectors for store files
.efs     db 8 dup (0xff) ;magic number(END FILE SYSTEM)
;]====================================
boot:
	mov ax,cs		;{Set segment regs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,$$		;}Set stack top

;{Get disk info
	mov [FSHI.disk_id],dl ;Store disk id
	mov ah,0x08
	int 0x13

	jc error
@@:
	inc dh
	mov [FSHI.hc],dh
	and cx,111111b
	mov [FSHI.spt],cx
;}

	mov si,intro_msg		;{Just show text
	call function.printz 
	mov si,load_msg
	call function.printz	;}
	
	xor dx,dx				;{Load all files
 	mov al,[FSHI.sfsf]
	mov dl,[FSHI.disk_id]
	mov bx,START_FILE_SPACE
	mov cx,2
	mov ah,2
	int 0x13				;}
	
	add bx,13				;pass name(10b),size(2b),type(1b)
	jmp bx					;}Go execut kernel

error:
	mov si,error_msg
	call function.printz
	jmp $
;======[FUNCTIONS]======
function:
.printz:
;----
;IN:
;SI - OFFS MESSAGE LOST BYTE 0
;OUT:
;NONE
;----
	mov ah,0x0e
@@:
	lodsb
	test al,al
	jz @f
	int 0x10
	jmp @b
@@:
	ret
;============[DATA]===========
intro_msg db "=======KonsOS Boot loader=======",13,10,0
load_msg db "Load main files...",13,10,0
error_msg db "Error load files",13,10,0
rb 510-($-$$)
db 0x55,0xaa ;Magic number
;=======[SPACE_FILES]=========
;file structure
;10b file name
;2b  size bytes
;1B file/program 0/0xff
;--------------------
include "./Files/kernel.asm"
;-----------
include "./Files/shell.asm"
;-----------
include "./Files/ls.asm"
;-----------
include "./Files/touch.asm"
;-----------
include "./Files/rm.asm"
;-----------
;include "./Files/ee.asm" in the development
;-----------
include "./Files/cat.asm"
;-----------
include "./Files/clear.asm"
;-----------
include "./Files/echo.asm"
;-----------
include "./Files/restart.asm"
;-----------
include "./Files/key-code.asm"
;-----------
include "./Files/time.asm"
;-----------
include "./Files/cpuid.asm"
;-----------
include "./Files/hello.asm"
;-----------
include "./Files/logo.txt"
;-----------------
db 8 dup(0xff) ;END FS
