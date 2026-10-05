		DOSSEG
		.MODEL  SMALL
		.STACK  100h
		.CODE

start:          mov     ah,0
		mov     al,2
		int     10h                     ;clear screen

		mov     dh,13                   ;∏¡¡µ›≤µ⁄‡ 13
		mov     dl,0                    ;£ √›ø∑‰ 0
		mov     al,'A'                  ;ascii A
		mov     cx,26                   ;counter = 26
capASCII:       push    cx
		mov     ah,2                    ;set cursor position
		mov     bh,0                    ;page 0
		int     10h                     ;–¡⁄¿°∏¡Ÿ°Œ¡

		mov     ah,9                    ;write char&att at cursor
		mov     bh,0                    ;page 0
		mov     bl,24h                  ;attribute
		mov     cx,1                    ;one char
		int     10h                     ;call service

		mov     ah,8                    ;read char&att at cursor
		mov     bh,0                    ;page 0
		int     10h

		inc     dl                      ;next column
		inc     al                      ;next char

		pop     cx
		loop    capASCII

		mov     ax,4c00h
		int     21h                     ;end programe

		END     start



