		DOSSEG
		.MODEL  SMALL
		.STACK  100h
		.DATA
BackGround      DB      "BackGround$"
ForGround       DB      10,13,"ForGround: key --->",'$'
Newline         DB      10,13,'$'
		.CODE
Ctrl_p          EQU     16
start:          MOV     ax,@DATA
		mov     ds,ax
Job1:           mov     dx,OFFSET BackGround
Job2:           mov     ah,9
		int     21h
		mov     ah,1
		int     16h
		jz      Job1
		mov     ah,00
		int     16h
		cmp     al,'x'                  ;exit key
		jz      Exit
		push    ax
		mov     dx,OFFSET ForGround
		mov     ah,9
		int     21h
		pop     ax
		mov     dl,al
		mov     cx,30                    ;8 character
PrintKey:       mov     ah,2
		int     21h
		loop    PrintKey
		mov     dx,OFFSET Newline
		jmp     Job2
Exit:           mov     ax,4c00h
		int     21h

		END     start

