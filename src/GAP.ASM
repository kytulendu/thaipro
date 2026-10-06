OPTION PROC:PRIVATE
; ---------------------------------------------------------------------------
; GAP.ASM - reconstructed "video support" module for Powersoft Thai
; Professional EGA/VGA 3.10.  Recovered from the reference THAIPRO.EXE
; (Nov 1991) by disassembly.  Original CSEG offsets are shown as comments
; (ref = 0x2F85-0x33E6 in the reference image).
; ---------------------------------------------------------------------------
CSEG            SEGMENT PARA PUBLIC 'CODE'
		ASSUME  CS:CSEG, DS:CSEG

		EXTRN   DISPTRAN:WORD                   ;MENU
		EXTRN   ScrHardBlkLen:BYTE              ;MENU
		EXTRN   CurrMode:BYTE                   ;MENU
		EXTRN   Code8line:BYTE                  ;MENU
		EXTRN   Old_int10h_vector:NEAR          ;INT10 (DWORD)
		EXTRN   EGAfont1:NEAR                   ;INSTALL (font blob)
		EXTRN   EGAfont2:NEAR                   ;INSTALL (font blob)
		EXTRN   EGARWfont:NEAR                   ;INSTALL (font blob)
		EXTRN   EGAsaha:NEAR                   ;INSTALL (font blob)
		EXTRN   EGAita:NEAR                   ;INSTALL (font blob)

		PUBLIC  IndexPort, CRT_MODE, OldPage, NewPage
		PUBLIC  CursorLevel, EnglishMode
		PUBLIC  HardCur, TransCurpos, SetCurShape
		PUBLIC  Clscreen, ClscreenOdd, ClscreenOrg, Setmode
		PUBLIC  INCODE5, INCODE6, INCODE7, INCODE52
		PUBLIC  OffsetCode2, PROTECT_A000H
		PUBLIC  CurPoint, NewVisit, RWoffset, SAHAoffset, ITAoffset

; ---- dispatch thunk + zero work vars (ref 0x2F85-0x2F96)
		call    WORD PTR [bx]                   ;0x2F85
		ret                             ;0x2F87
		DB      13 DUP (0)              ;0x2F88
CurPoint        DW      0                       ;0x2F95 cursor offset

; ---- HardCur: read cursor position from 6845 CRTC (ref 0x2F97-0x2FD1)
HardCur         PROC    NEAR
		push    dx                      ;0x2F97
		push    cx
		push    bx
		push    ax
INCODE7         LABEL   NEAR                    ;0x2F9B (patch +1 -> D4)
		mov     dx,03B4h
		cli                             ;0x2F9E
		mov     al,0Eh
		out     dx,al
		inc     dx
		in      al,dx
		mov     ch,al
		dec     dx
		mov     al,0Fh
		out     dx,al
		inc     dx
		in      al,dx
		sti                             ;0x2FAC
		mov     cl,al
		cmp     cx,07D0h                ;0x2FAF
		ja      HardQuit
		mov     ax,cx
		shl     cx,1
		mov     CurPoint,cx             ;0x2FB9
		xor     dx,dx
		mov     cx,050h
		div     cx
		mul     cx
		mov     si,ax
		shl     si,1
		call    TransCurpos             ;0x2FCA
HardQuit:       pop     ax                      ;0x2FCD
		pop     bx
		pop     cx
		pop     dx
		ret
HardCur         ENDP

TranCur1        DW      0                       ;0x2FD2
Tran_space      DB      0                       ;0x2FD4
Tran_state      DB      0                       ;0x2FD5

; ---- TransCurpos: walk shadow screen, translate Thai levels,
;      reprogram CRTC start address + cursor (ref 0x2FD6-0x30EE)
TransCurpos     PROC    NEAR
		push    bx                      ;0x2FD6
		push    di
		push    si
		mov     di,si
		mov     TranCur1,di             ;0x2FDB
		mov     ax,cs
		mov     ds,ax
		shl     di,1
		mov     dh,2
		mov     bp,050h
Tran_loop:      cmp     si,CurPoint             ;0x2FEA
		jne     Tran_nocur
		push    di
		push    dx
		push    cx
		mov     cx,TranCur1             ;0x2FF3
		sub     di,cx
		sub     di,cx
		shr     di,1
		add     di,cx
		add     di,1050h
		mov     cx,di
INCODE52        LABEL   NEAR                    ;0x3005 (patch +1 -> D4)
		mov     dx,03B4h
		mov     al,0Ch
		out     dx,al
		inc     dx
		mov     al,010h
		out     dx,al
		dec     dx
		mov     al,0Eh
		out     dx,al
		inc     dx
		mov     al,ch
		out     dx,al
		dec     dx
		mov     al,0Fh
		out     dx,al
		inc     dx
		mov     al,cl
		out     dx,al
		mov     cx,CursorLevel          ;0x301F
		dec     dx
		mov     al,0Ah
		out     dx,al
		inc     dx
		mov     al,ch
		out     dx,al
		dec     dx
		mov     al,0Bh
		out     dx,al
		inc     dx
		mov     al,cl
		out     dx,al
		pop     cx
		pop     dx
		pop     di
Tran_nocur:     xor     dl,dl                   ;0x3036
INCODE5         LABEL   NEAR                    ;0x3038 (patch +2 -> B8)
		mov     bx,0B000h
		mov     es,bx
		mov     ax,es:[si]
		cmp     al,080h
		jb      Tran_plain
		mov     bx,DISPTRAN
		xlatb
		cmp     al,0D1h
		je      Tran_up2
		cmp     al,0D4h
		jb      Tran_plain
		cmp     al,0DBh
		jb      Tran_up2
		cmp     al,0E7h
		jb      Tran_plain
		je      Tran_up1
		cmp     al,0EDh
		ja      Tran_plain
		je      Tran_up1
		cmp     al,0ECh
		jne     Tran_chkst
		cmp     cl,0D4h
		je      Tran_chkst
		cmp     cl,0D8h
		je      Tran_chkst
Tran_up1:       inc     dl                      ;0x306F
Tran_up2:       inc     dl                      ;0x3071
Tran_chkst:     cmp     dh,1                    ;0x3073
		jb      Tran_low
		je      Tran_mid
		mov     dh,2
		jmp     Tran_next
Tran_low:       inc     Tran_state              ;0x307E
		cmp     dl,1
		je      Tran_low1
		mov     dh,2                    ;0x3087
Tran_lowc:      mov     cl,al                   ;0x3089
Tran_jadv:      jmp     Tran_adv                ;0x308B
Tran_low1:      mov     dh,1                    ;0x308D
		cmp     al,0D8h
		jb      Tran_lowc
		mov     ah,cl
		mov     cl,al
		jmp     Tran_adv
Tran_mid:       mov     dh,2                    ;0x3099
		cmp     dl,0
		jne     Tran_next
		inc     Tran_state
		cmp     cl,0D7h
		ja      Tran_jadv
		jmp     Tran_adv
Tran_plain:     xor     dh,dh                   ;0x30AC
Tran_next:
OffsetCode2     LABEL   NEAR
		cmp     al,020h                 ;0x30AE
		je      Tran_blank
		mov     BYTE PTR Tran_space,0   ;0x30B2
Tran_zinc:      inc     di                      ;0x30B7
		inc     di
Tran_adv:       inc     si                      ;0x30B9
		inc     si
		dec     bp
		je      Tran_done
		jmp     Tran_loop
Tran_blank:     inc     Tran_space              ;0x30C1
		mov     bl,ScrHardBlkLen
		cmp     Tran_space,bl
		jne     Tran_zinc
		inc     Tran_state              ;0x30CF
Tran_fill:      inc     di                      ;0x30D3
		inc     di
		dec     Tran_state
		jne     Tran_fill
		mov     BYTE PTR Tran_space,0
		jmp     Tran_adv
Tran_done:      mov     ax,cs                   ;0x30E2
		mov     ds,ax
		mov     BYTE PTR Tran_state,0
		pop     si
		pop     di
		pop     bx
		ret
TransCurpos     ENDP

; ---- hardware cursor shape helper (ref 0x30EF-0x310F)
SetCurShape     PROC    NEAR
		push    bp                      ;0x30EF
		mov     bp,sp
		push    di
		push    dx
		push    cx
		mov     cx,CursorLevel
INCODE6         LABEL   NEAR                    ;0x30F9 (patch +1 -> D4)
		mov     dx,03B4h                ;0x30F9
		mov     al,0Ah
		out     dx,al
		inc     dx
		mov     al,ch
		out     dx,al
		dec     dx
		mov     al,0Bh
		out     dx,al
		inc     dx
		mov     al,cl
		out     dx,al
		pop     cx
		pop     dx
		pop     di
		pop     bp
		ret
SetCurShape     ENDP

; ---- video variables (ref 0x3110-0x312B)
IndexPort       DW      03B4h                   ;0x3110 6845 index port
CRT_MODE        DB      7                       ;0x3112 BIOS video mode
OldPage         DW      0B000h                  ;0x3113 visible page seg
NewPage         DW      0B400h                  ;0x3115 shadow page seg
ModeWork        DB      7                       ;0x3117 entry+0 height
		DW      0                       ;0x3118 entry+1 font segment
FontW1          DW      OFFSET EGAfont1         ;0x311A entry+3 font off
FontW2          DW      OFFSET EGAfont2         ;0x311C entry+5 font off 2
		DB      4                       ;0x311E entry+7 font block
CursorLevel     DW      0500h                   ;0x311F entry+8 cursor size
		DB      6                       ;0x3121 entry+10
		DB      2                       ;0x3122 entry+11
		DB      020h                    ;0x3123 entry+12
		DW      00F00h                  ;0x3124 entry+13 clear attr
RWoffset        LABEL   WORD                    ;same variable (INSTALL patches it for VGA)
FontPtrV1       DW      OFFSET EGARWfont        ;0x3126 = EGARWfont
SAHAoffset      LABEL   WORD
FontPtrV2       DW      OFFSET EGAsaha          ;0x3128 = EGAsaha
ITAoffset       LABEL   WORD
FontPtrV3       DW      OFFSET EGAita           ;0x312A = EGAita

; ---- EnglishMode: per-mode parameter table, 15 bytes per entry
;      (ref 0x312C-0x3185, 6 entries; INSTALL patches cursor size +8+15k)
EnglishMode     LABEL   BYTE
		DB      00Eh,00,00, 00,00,00,00,00, 00Dh,00Bh,00Dh,00,00, 007h,020h
		DB      00Eh,00,00, 00,00,00,00,05, 00Dh,00Bh,00Dh,00,00, 007h,020h
		DB      00Eh,00,00, 00,00,00,00,04, 00Dh,00Bh,00Dh,00,00, 007h,020h
		DB      007h,00,00, 00,00,00,00,04, 000h,005h,006h,02,010h, 000h,00Fh
		DB      007h,00,00, 00,00,00,00,04, 000h,005h,006h,02,020h, 000h,00Fh
		DB      007h,00,00, 00,00,00,00,04, 000h,005h,006h,02,020h, 000h,00Fh

		DB      "here string"           ;0x3186 (original debug marker)

; ---- Setmode: program CRTC, load fonts, set cursor (ref 0x3191-0x32DE)
Setmode         PROC    NEAR
		push    bp                      ;0x3190
		push    ax
		push    bx
		push    cx
		push    dx
		push    di
		push    si
		push    es
		push    ds
		push    cs
		pop     ds
		push    cs
		pop     es
		mov     si,OFFSET EnglishMode   ;0x319E
		xor     ch,ch
		mov     cl,0Fh
		mov     al,CurrMode
		mul     cl
		add     si,ax
		mov     di,OFFSET ModeWork
		cld
		rep     movsb
		mov     dx,IndexPort            ;0x31B2
		add     dx,6
		in      al,dx
		mov     al,0
		mov     dx,03C0h
		out     dx,al
		mov     ax,WORD PTR ModeWork+1           ;0x31C0
		mov     es,ax
		mov     bp,WORD PTR ModeWork+3
		mov     dx,0
		mov     cx,0100h
		mov     bh,ModeWork
		mov     bl,0
		mov     ax,1110h
		call    FontLoad                ;0x31D8
		mov     bp,WORD PTR ModeWork+5
		mov     dx,0
		mov     cx,0100h
		mov     bh,ModeWork
		mov     bl,1
		mov     ax,1110h
		call    FontLoad                ;0x31EE
		push    cs
		pop     es
		cmp     BYTE PTR CurrMode,1              ;0x31F3
		je      Setm_1
		cmp     BYTE PTR CurrMode,2
		jne     Setm_clr
		mov     bp,FontPtrV3            ;0x3201 (orig reads 0x312A)
		mov     dx,0
		mov     cx,080h
		mov     bh,ModeWork
		mov     bl,1
		mov     ax,1110h
		call    FontLoad
Setm_1:         mov     bp,FontPtrV1            ;0x3217 (orig reads 0x3126)
		cmp     BYTE PTR Code8line,0
		je      Setm_2
		mov     bp,FontPtrV2
Setm_2:         mov     dx,080h                 ;0x3226
		mov     cx,080h
		mov     bh,ModeWork
		mov     bl,1
		mov     ax,1110h
		call    FontLoad
Setm_clr:       cld                             ;0x3238
		mov     cx,050h
		mov     ax,cs:NewPage
		cmp     BYTE PTR CurrMode,3
		jne     Setm_c1
		sub     ah,2
Setm_c1:        mov     es,ax
		mov     di,01F40h
		mov     ax,WORD PTR ModeWork+13
		rep     stosw
		mov     dx,IndexPort            ;0x3254
		mov     al,9
		out     dx,al
		inc     dx
		mov     al,ModeWork
		dec     al
		out     dx,al
		mov     dx,IndexPort
		mov     al,0Ch
		out     dx,al
		inc     dx
		mov     al,ModeWork+12
		out     dx,al
		mov     ax,040h                 ;0x326E
		mov     es,ax
		mov     bx,084h
		mov     BYTE PTR es:[bx],018h
		mov     bl,ModeWork+7
		mov     ax,1103h
		pushf
		call    DWORD PTR Old_int10h_vector  ;0x3282
		cmp     CRT_MODE,3              ;0x3286
		je      Setm_wait
		mov     dx,IndexPort
		mov     al,014h
		out     dx,al
		inc     dx
		mov     al,ModeWork+10
		out     dx,al
Setm_wait:      mov     cx,0FFFFh               ;0x3299
Setm_w2:        loop    Setm_w2
		mov     dx,IndexPort            ;0x329E
		add     dx,6
		in      al,dx
		mov     al,020h
		mov     dx,03C0h
		out     dx,al
		mov     bx,0F12h                ;0x32AC
		cmp     BYTE PTR CurrMode,2
		jb      Setm_p1
		mov     bx,0712h
Setm_p1:        mov     ax,1000h
		pushf
		call    DWORD PTR Old_int10h_vector  ;0x32BD
		mov     cx,CursorLevel          ;0x32C1
		mov     ah,1
		int     10h
		mov     dx,IndexPort            ;0x32C9
		mov     al,8
		out     dx,al
		inc     dx
		mov     al,ModeWork+11
		out     dx,al
		pop     ds                      ;0x32D5
		pop     es
		pop     si
		pop     di
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		pop     bp
		ret
Setmode         ENDP

; ---- register tables for font RAM access (ref 0x32DF-0x32F2)
FontSeqTab      DB      002h,004h,004h,007h,005h,000h,006h,004h,004h,002h
PROTECT_A000H   LABEL   BYTE                    ;0x32E9 (patch +7 -> 0E)
		DB      002h,003h,004h,003h,005h,010h,006h,00Ah,004h,000h

; ---- FontLoad: EGA/VGA font RAM write helper (ref 0x32F3-0x3337)
FontLoad        PROC    NEAR
		push    es                      ;0x32F3
		mov     si,OFFSET FontSeqTab
		cli
		call    SeqWrite                ;0x32F8
		push    es                      ;0x32FB
		pop     ds
		push    dx
		mov     dx,0A000h
		mov     es,dx
		pop     dx
		push    cx                      ;0x3304
		mov     cl,5
		shl     dx,cl
		pop     cx
		or      bl,bl
		je      FontL_1
FontL_2:        add     dx,04000h               ;0x330E
		dec     bl
		jne     FontL_2
FontL_1:        mov     al,bh                   ;0x3316
		sub     ah,ah
		mov     di,dx
		mov     si,bp
		jcxz    FontL_out
FontL_row:      push    cx                      ;0x3320
		mov     cx,ax
		rep     movsb
		sub     di,ax
		add     di,020h
		pop     cx
		loop    FontL_row
		push    cs                      ;0x332D
		pop     ds
		mov     si,OFFSET PROTECT_A000H
		call    SeqWrite
		sti
FontL_out:      pop     es                      ;0x3336
		ret
FontLoad        ENDP

; ---- SeqWrite: write reg/value pairs to 3C4 then 3CE (ref 0x3338-0x3358)
SeqWrite        PROC    NEAR
		push    cx                      ;0x3338
		push    dx
		push    ax
		mov     cx,2
		mov     dx,03C4h
		call    SeqPairs
		mov     cx,3
		mov     dl,0CEh
		call    SeqPairs
		pop     ax
		pop     dx
		pop     cx
		ret
SeqPairs:       lodsb                           ;0x3350
		out     dx,al
		inc     dx
		lodsb
		out     dx,al
		dec     dx
		loop    SeqPairs
		ret
SeqWrite        ENDP

; ---- Clscreen: clear shadow page (ref 0x3359-0x338D)
Clscreen        PROC    NEAR
		push    es                      ;0x3359
		push    di
		push    cx
		push    ax
		push    ds
		cld
		mov     ax,cs:NewPage
		cmp     BYTE PTR CurrMode,3
		jne     Cls_1
		sub     ah,2
Cls_1:          mov     es,ax
		xor     di,di
		mov     cx,01Ah
Cls_row:        push    cx
		mov     cx,050h
		mov     ax,0F00h
		rep     stosw
		mov     cx,050h
		mov     ax,0737h
		rep     stosw
		pop     cx
		loop    Cls_row
		pop     ds
		pop     ax
		pop     cx
		pop     di
		pop     es
		ret
Clscreen        ENDP

; ---- ClscreenOdd: same, mode-3 adjustment inverted (ref 0x338E-0x33C2)
ClscreenOdd     PROC    NEAR
		push    es                      ;0x338E
		push    di
		push    cx
		push    ax
		push    ds
		cld
		mov     ax,cs:NewPage
		cmp     BYTE PTR CurrMode,3
		je      ClsO_1
		sub     ah,2
ClsO_1:         mov     es,ax
		xor     di,di
		mov     cx,01Ah
ClsO_row:       push    cx
		mov     cx,050h
		mov     ax,0F00h
		rep     stosw
		mov     cx,050h
		mov     ax,0737h
		rep     stosw
		pop     cx
		loop    ClsO_row
		pop     ds
		pop     ax
		pop     cx
		pop     di
		pop     es
		ret
ClscreenOdd     ENDP

; ---- ClscreenOrg: clear visible page (ref 0x33C3-0x33DC)
ClscreenOrg     PROC    NEAR
		push    es                      ;0x33C3
		push    di
		push    cx
		push    ax
		cld
		mov     ax,cs:OldPage
		mov     es,ax
		xor     di,di
		mov     cx,07D0h
		mov     ax,0720h
		rep     stosw
		pop     ax
		pop     cx
		pop     di
		pop     es
		ret
ClscreenOrg     ENDP

; ---- extra variables referenced by INSTALL (1992 additions)
NewVisit        DB      0

CSEG            ENDS
		END
