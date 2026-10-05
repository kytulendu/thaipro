		DOSSEG
		.MODEL  SMALL
		.STACK  100h
		.DATA
CONTROL_P          DB '^P$'
		.CODE
Ctrl_p          EQU     16
start:          MOV     ax,@DATA
		mov     ds,ax
wait_key:       mov     ah,1
		int     16h
		jz      wait_key                ;check key stroke
		mov     ah,0
		int     16h                     ;get ascii Thai/Eng
		cmp     al,Ctrl_p               ;test control-p '^p'
		jz      WriteCtrl_p
		cmp     al,'x'                  ;test exit 'x'
		jz      exit
WriteChar:      mov     ah,2
		mov     dl,al                   ;ascii
		int     21h                     ;write char on screen
		jmp     wait_key                ;get next char

WriteCtrl_p:    mov     ah,9
		mov     dx,OFFSET CONTROL_P
		int     21h                     ;print ^p on screen
func8c:         mov     ah,1
		int     16h
		jz      func8c                  ;check key stroke
		mov     ah,8ch                  ;
		int     60h                     ;get ascii Eng
		jmp     WriteChar

exit:           mov     ax,4c00h
		int     21h

		END     start

