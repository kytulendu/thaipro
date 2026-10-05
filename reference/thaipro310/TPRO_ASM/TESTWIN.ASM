		 DOSSEG
		.MODEL  SMALL
		.STACK  100h
		.DATA
FrameChar       db  80h,81h,82h,83h,84h,85h
string2         db  '³Ú¡ÁÊ¸Ô²áµ×¡ÒÈ¿²<hb>',160,'$'
		.CODE
start:          mov     ax,@DATA
		mov     ds,ax

		mov     si,OFFSET FrameChar
		mov     ax,0000h                ;y=0, x=0
		mov     dx,184fh                ;y'=79, x'=24
		mov     bl,04h                  ;color
		mov     cx,12                   ;12 frame
win:            push    cx
		mov     cx,ax
		call    Frame                   ;call frame routine
		add     ah,1                    ;next frame smaller
		add     al,1                    ;
		sub     dh,1                    ;
		sub     dl,1                    ;
		inc     bl                      ;color
		pop     cx
		loop    win

		mov     dx,0c20h
		mov     ah,2
		int     10h
		mov     dx,OFFSET string2
		mov     ah,9                    ;write string
		int     21h

		mov     ax,4c00h
		int     21h                     ;end programe

;-----------------------------------------------------------------------
;Frame
;       Entry   BL attribute
;               DS:SI frame character
;               CH y  coordinate, upper left corner of window
;               CL x  coordinate, upper left corner of window
;               DH y' coordinate, lower right corner of window
;               DL x' coordinate, lower right corner of window
;       Destroy DI
;               BP
Frame:          push    ax
		push    bx
		push    cx
		push    dx              ;save register
		push    di
		push    bp

		mov     di,dx           ;x'y'
		mov     bp,cx           ;x y
		mov     bh,0
		mov     dx,bp
		mov     al,[si]         ;get upper left char
		call    Write           ;write char
		mov     ax,di
		sub     al,dl
		xor     ch,ch           ;clear upper register
		mov     cl,al
		push    cx              ;save counter
		inc     dl              ;next column
		mov     al,[si+5]       ;get line char
		mov     ah,2
		int     10h
		mov     ah,9
		int     10h             ;write repeat cx
		mov     ax,di
		mov     dl,al           ;get x' position
		mov     al,[si+1]       ;get upper right char
		call    Write
		mov     ax,di
		mov     dh,ah           ;get y' position
		mov     ax,bp
		mov     dl,al           ;get x  position
		mov     al,[si+2]       ;get lower left char
		call    Write
		mov     ah,2
		inc     dl              ;next column
		int     10h
		mov     ah,9
		mov     al,[si+5]       ;get line char
		pop     cx
		int     10h
		mov     dx,di           ;x' y'  position
		mov     al,[si+3]       ;get lower right char
		call    Write
		mov     ax,dx
		mov     dx,bp           ;x  y
		sub     ah,dh           ;y'- y
		mov     cl,ah
		xor     ch,ch           ;clear up register
		dec     cx
		push    cx              ;save counter
		mov     al,[si+4]       ;get vertical char |
vert1:          push    cx
		inc     dh
		call    Write
		pop     cx
		loop    vert1
		pop     cx              ;next vertical counter
		mov     ax,di
		mov     dl,al
		mov     ax,bp
		mov     dh,ah
		mov     al,[si+4]       ;get vertical char |
vert2:          push    cx
		inc     dh
		call    Write
		pop     cx
		loop    vert2

		pop     bp
		pop     di
		pop     dx              ;restore register
		pop     cx
		pop     bx
		pop     ax
		ret

Write:          mov     ah,2
		int     10h
		mov     ah,9
		mov     cx,1
		int     10h
		ret

		END     start


