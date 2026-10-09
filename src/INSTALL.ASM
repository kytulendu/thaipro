OPTION PROC:PRIVATE

CSEG            SEGMENT PARA PUBLIC 'CODE'
		ASSUME  CS:CSEG, DS:CSEG, SS:STACK

		EXTRN   New_int09h:NEAR
		EXTRN   Old_int09h_offs:NEAR, Old_int09h_seg:NEAR
		EXTRN   New_int10h:NEAR
		EXTRN   Old_int10h_offs:NEAR, Old_int10h_seg:NEAR
		EXTRN   New_int08h:NEAR
		EXTRN   Old_int08h_offs:NEAR, Old_int08h_seg:NEAR

		EXTRN   New_int17h:NEAR
		EXTRN   Old_int17h_offs:NEAR, Old_int17h_seg:NEAR

		EXTRN   Old_int16h_offs:NEAR, Old_int16h_seg:NEAR

		EXTRN   New_int6fh:NEAR
		EXTRN   Old_int6fh_offs:NEAR, Old_int6fh_seg:NEAR

		EXTRN   Clscreen:NEAR, ClscreenOdd:NEAR, ClscreenOrg:NEAR, Setmode:NEAR
		EXTRN   VAR_int6f_int8:NEAR
		EXTRN   IndexPort:NEAR,CRT_MODE:NEAR, OldPage:NEAR, NewPage:NEAR
		EXTRN   INCODE1:NEAR,INCODE2:NEAR,INCODE3:NEAR
		EXTRN   INCODE4:NEAR,INCODE5:NEAR,INCODE6:NEAR,INCODE7:NEAR

		EXTRN   INCODE8:NEAR, INCODE9:NEAR, INCODE10:NEAR,INCODE11:NEAR
		EXTRN   INCODE12:NEAR,INCODE13:NEAR,INCODE14:NEAR,INCODE15:NEAR,INCODE15_1:NEAR
		EXTRN   INCODE16:NEAR,INCODE17:NEAR,INCODE18:NEAR,INCODE19:NEAR
		EXTRN   INCODE20:NEAR,INCODE21:NEAR,INCODE22:NEAR,INCODE23:NEAR
		EXTRN   INCODE24:NEAR,INCODE25:NEAR

		EXTRN   INCODE50:NEAR,INCODE51:NEAR,INCODE52:NEAR

		EXTRN   INCODEn1:NEAR

		EXTRN   EnglishMode:NEAR
		EXTRN   COLOR1:NEAR,COLOR2:NEAR,COLOR3:NEAR,COLOR4:NEAR
		EXTRN   COLOR5:NEAR,COLOR6:NEAR,COLOR7:NEAR,COLOR8:NEAR
		EXTRN   COLOR9:NEAR,COLOR10:NEAR
		EXTRN   ITAoffset:NEAR, RWoffset:NEAR, SAHAoffset:NEAR
		EXTRN   TransCurpos:NEAR
		EXTRN   NewVisit:NEAR
		EXTRN   NumPort1:NEAR
		EXTRN   NumPort2:NEAR
		EXTRN   NumPort3:NEAR
		EXTRN   PortVAR:NEAR
		EXTRN   PrnfVAR:NEAR

		EXTRN   PROTECT_A000H:NEAR

		EXTRN   RefPos:NEAR

		EXTRN   IndexPort:NEAR
		EXTRN   PSP:NEAR
		EXTRN   AdapterType:NEAR
		EXTRN   HotkeyLebel:NEAR

		PUBLIC  VGAita
		PUBLIC  VGArwfont
		PUBLIC  VGAfont2
		PUBLIC  VGAfont1
		PUBLIC  LimitDown
		PUBLIC  EGAita
		PUBLIC  EGARWfont
		PUBLIC  EGAsaha
		PUBLIC  EGAfont2
		PUBLIC  EGAfont1

INCLUDE F_EGA1.INC
INCLUDE F_EGA2.INC
INCLUDE F_EGARW.INC
INCLUDE F_EGATIS.INC
INCLUDE F_EGAI.INC

END_OF_RESIDENT_CODE     LABEL    BYTE

INCLUDE F_VGA1.INC
INCLUDE F_VGA2.INC
INCLUDE F_VGARW.INC
INCLUDE F_VGATIS.INC
INCLUDE F_VGAI.INC

END_FONT  LABEL BYTE

;---------------------------------------------------------------



LimitDown       DW      OFFSET END_OF_RESIDENT_CODE +1

Already         DB  'Thai Professional Install already.',10,13
		DB  'Please press $'
Already2        DB  ' to active MENU.',10,13,'$'
NOT_EGA_VGA     DB  'Ega/Vga not found$'


Install         PROC    NEAR
		mov     ax,cs
		mov     ds,ax                   ;data segment = code segment
		mov    WORD PTR PSP,es                  ;get psp
		jmp      CKthaiExist

Exit:

		mov     ah,9
		int     21h
		mov     ax,4c00h
		int     21h                     ;terminat program

CKthaiExist:

		mov     ah,50h
		int     17h
		cmp     al,0eeh                 ;check exist Thai Driver
		jne     NoThai
		mov     dx,offset Already        ;print install already 1.
		mov     ah,9
		int     21h

		mov     dx,offset HotkeyLebel    ;print suggestion Hotkey
		mov     ah,9
		int     21h

		mov     dx,offset Already2       ;print install already 2.
		jmp     Exit



;set hardware stringray

NoThai:
		MOV     AH,12h                  ;
		MOV     BL,84h                   ;
		INT     10h                      ;
		MOV     AX,1201h                 ;
		MOV     BL,8Fh                   ;
		INT     10h                      ;
		MOV     AL,0BFh                  ;
		MOV     DX,03C4h                 ;
		OUT     DX,AL                    ;
		INC     DX                       ;
		IN      AL,DX                    ;
		PUSH    AX                       ;
		OR      AL,80h                   ;>EXPAND MODE Stringray Bios
		OUT     DX,AL                    ;
		MOV     AH,0Fh                   ;
		INT     10h                      ;
		XOR     AH,AH                    ;
		INT     10h                      ;
		MOV     DX,3C4h                  ;
		MOV     AL,0BFh                  ;
		OUT     DX,AL                    ;
		INC     DX                       ;
		POP     AX                       ;
		AND     AL,7Fh                   ;
		OUT     DX,AL                   ;


;check display adapter

		CLD
		MOV     AX,500H                 ;set page 0
		INT     10H
		MOV     AX,40H
		MOV     ES,AX
		MOV     AX,1A00H                ;get display info
		INT     10H
		CMP     AL,1AH                  ;function supported?
		JNZ     CK_EGA                  ;No check EGA
		CMP     BL,7                    ;Is it MONO?
		JZ      GET_CRT_MODE            ;
		CMP     BL,8                    ;Is it COLOR?
		JZ      GET_CRT_MODE            ;

CK_EGA:         MOV     BYTE PTR cs:AdapterType,2   ;Scan line of EGA
		MOV     BL,10H                      ;get EGA info
		MOV     AH,12H
		INT     10H
		MOV     DX,OFFSET NOT_EGA_VGA
		CMP     BL,10H                  ;Is there EGA ?
		JZ      ERROR_MSG               ;No
		TEST    ES:BYTE PTR [87h],8     ;Is EGA active?
		JNZ     ERROR_MSG               ;No
		jz      GET_CRT_MODE                          ;Yes pass to CRT mode

ERROR_MSG:      mov     ah,9                    ;print string function
		int     21h
		MOV     ax,4c01h
		int     21h                     ;TERMINATE

GET_CRT_MODE:   MOV     BL,ES:[49h]             ;get mode number from BIOS data
		push    cs
		pop     ds
		CMP     BL,7                    ;Mono
		JZ      SavePort

		MOV     AX,3
		INT     10H                     ;Else Switch to Color80
		MOV     BL,3

SavePort:       MOV     BYTE PTR CRT_MODE,BL
		mov     dx,es:[8]                ;LPT 1   Get address Port#
		MOV     WORD PTR NumPort1,dx
		mov     dx,es:[10]               ;LPT 2
		MOV     WORD PTR NumPort2,dx
		mov     dx,es:[12]               ;LPT 3
		MOV     WORD PTR NumPort3,dx

		CALL    SetUp

OK_install:

		push    cs
		pop     es
		cli
		mov      ah,35h
		mov      al,09h                  ;get interrupt
		int      21h                     ;same = installed
		mov      WORD PTR Old_int09h_offs,bx      ;save old offset
		mov      WORD PTR Old_int09h_seg,es       ;save old segment
                mov      ah,25h
		mov      al,09h                  ;set new interrupt timer
		mov      dx,offset New_int09h
		int      21h
		sti

		cli
		mov      ah,35h
		mov      al,10h                  ;get interrupt
		int      21h                     ;same = installed
		mov      WORD PTR Old_int10h_offs,bx      ;save old offset
		mov      WORD PTR Old_int10h_seg,es       ;save old segment
		mov      ah,25h
		mov      al,10h                  ;set new interrupt
		mov      dx,offset New_int10h
		int      21h
		sti

		cli
		mov      ah,35h
		mov      al,17h                  ;get interrupt
		int      21h                     ;same = installed
		mov      WORD PTR Old_int17h_offs,bx      ;save old offset
		mov      WORD PTR Old_int17h_seg,es       ;save old segment
		mov      ah,25h
		mov      al,17h                  ;set new interrupt
		mov      dx,offset New_int17h
		int      21h
		sti

		cli
		mov      ah,35h
		mov      al,16h                  ;get interrupt
		int      21h                     ;same = installed
		mov      WORD PTR Old_int16h_offs,bx      ;save old offset
		mov      WORD PTR Old_int16h_seg,es       ;save old segment
		sti

		cli
		mov      ah,35h
		mov      al,060h                  ;get interrupt
		int      21h                     ;same = installed
		mov      WORD PTR Old_int6fh_offs,bx      ;save old offset
		mov      WORD PTR Old_int6fh_seg,es       ;save old segment
		mov      ah,25h
		mov      al,060h                  ;set new interrupt
		mov      dx,offset New_int6fh
		int      21h
		sti


		mov      ah,35h
		mov      al,08h                  ;get interrupt
		int      21h                     ;same = installed
		cli
		mov      WORD PTR Old_int08h_offs,bx      ;save old offset
		mov      WORD PTR Old_int08h_seg,es       ;save old segment
		mov      ah,25h
		mov      al,08h                  ;set new interrupt timer
		mov      dx,offset New_int08h
		int      21h
		sti

		mov  dx,WORD PTR IndexPort
		add  dx,0006h
		in   al,dx
		mov  al,0
		mov  dx,3C0h                 ;off screen
		out  dx,al

		call    Clscreen
		call    ClscreenOdd
		call    ClscreenOrg
		call    Setmode

		mov     ah,1
		mov     dx,0
		int     17h               ;initail printer0
		mov     ah,1
		mov     dx,1
		int     17h               ;initail printer1
		mov     ah,1
		mov     dx,2
		int     17h               ;initail printer2

		mov     al,BYTE PTR PortVAR
		mov     ah,8
		int     060h
		call    VAR_int6f_int8


		mov      ah,2             ;set cursor position
		mov      bh,0             ;page number
		mov      dx,0
		int      10h
		jmp     printbanner


banner          DB  'Thai Professional version 3.10',10,13
		DB  ' (C) Copyright Powersoft Co.,Ltd. 1989-1992.',10,13,10,13  ,'$'

Logo DB ' лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл',10,13
 DB ' л                                                                            л',10,13
 DB ' л                                                                            л',10,13
 DB ' л                                                                            л',10,13
 DB ' л   лллллл   ллллл  лл      лл лллллл лллллл   ллллл   ллллл  лллллл лллллл  л',10,13
 DB ' л   лл   лл лл   лл лл      лл лл     лл   лл лл   лл ллллллл лл       лл    л',10,13
 DB ' л   лл   лл лл   лл лл      лл лл     лл   лл лл      ллллллл лл       лл    л',10,13
 DB ' л   лл   лл лл   лл лл  лл  лл лл     лл   лл лл      ллллллл лл       лл    л',10,13
 DB ' л   лллллл  лл   лл лл  лл  лл лллллл лллллл   ллллл  ллл ллл ллллл    лл    л',10,13
 DB ' л   лл      лл   лл лл лллл лл лл     лл  ллл      лл ллллллл лл       лл    л',10,13
 DB ' л   лл      лл   лл лллл  лллл лл     лл   лл      лл ллллллл лл       лл    л',10,13
 DB ' л   лл      лл   лл  лл    лл  лл     лл   лл лл   лл ллллллл лл       лл    л',10,13
 DB ' л   лл       ллллл   лл    лл  лллллл лл   лл  ллллл   ллллл  лл       лл    л',10,13
 DB ' л                                                                            л',10,13
 DB ' л                                                                            л',10,13
 DB ' л                                                                            л',10,13
 DB ' лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл',10,13,'$'

printbanner:    mov      dx,offset banner
		mov      ah,9
		int      21h                    ;print banner

		mov     si,OFFSET Logo
LogoNext:
		lodsb                   ;load ascii
		cmp     al,'$'          ;compare end of string
		jz      LogoEnd
		mov     bl,07h          ;normal
		cmp     al,'л'          ;compare Block ASCII
		jnz     LogoNor
		mov     al,' '
		mov     bl,10h          ;reverse
LogoNor:        cmp     al,32
		jb      LogoTTY
		mov     cx,1
		mov     bh,0
		mov     ah,9
		int     10h
LogoTTY:        mov     ah,0Eh          ;TTY function
		int     10h
		jmp     LogoNext
LogoEnd:


TSR:            mov     dx,CS:LimitDown
		add     dx,0Fh          ;round up
		shr     dx,1            ; offset convert to paragraph
		shr     dx,1            ; by shift 4
		shr     dx,1
		shr     dx,1
		add     dx,0100h        ;original keeps 4KB extra after resident code

		MOV     AX,3100H
		INT     21H


SetUp:          cmp     BYTE PTR CRT_MODE,7              ;Is monochrome ?
		jne     SetUp1
		jmp     CRTdefault              ;Yes not change
SetUp1:         mov     WORD PTR IndexPort,3D4h          ;Number port for color
		mov     WORD PTR OldPage,0B800h          ;color page 0
		mov     WORD PTR NewPage,0BC00h          ;new page
		mov     BYTE PTR INCODE1 + 2,0B8h ;
		mov     BYTE PTR INCODE2 + 2,0BAh
		mov     BYTE PTR INCODE3 + 2,0BAh ;UPdate in program
		mov     BYTE PTR INCODE4 + 1,0FFh ;MASK of underline
		mov     BYTE PTR INCODE5 + 2,0B8h
		mov     BYTE PTR INCODE6 + 1,0D4h
		mov     BYTE PTR INCODE7 + 1,0D4h

		mov     BYTE PTR INCODE8 + 2,0BCh       ;B4
		mov     BYTE PTR INCODE9 + 1,0FFh   ;U
		mov     BYTE PTR INCODE10+ 2,0BCh       ;B4
		mov     BYTE PTR INCODE11+ 2,0BCh       ;B4
		mov     BYTE PTR INCODE12+ 2,0BCh       ;B4
		mov     BYTE PTR INCODE13+ 2,0BCh       ;B4
		mov     BYTE PTR INCODE14+ 2,0BCh       ;B4
		mov     BYTE PTR INCODE15+ 1,0D4h   ;PORT
		mov     BYTE PTR INCODE15_1+ 1,0D4h   ;PORT
		mov     BYTE PTR INCODE16+ 2,0BCh       ;B4
		mov     BYTE PTR INCODE17+ 2,0BCh       ;B4
		mov     BYTE PTR INCODE18+ 1,0FFh   ;U
		mov     BYTE PTR INCODE19+ 1,0FFh   ;U
		mov     BYTE PTR INCODE20+ 2,0B8h     ;B0
		mov     BYTE PTR INCODE21+ 2,0B8h     ;B0
		mov     BYTE PTR INCODE22+ 2,0BCh       ;B4
		mov     BYTE PTR INCODE23+ 1,0FFh   ;U
		mov     BYTE PTR INCODE24+ 2,0BCh       ;B4
		mov     BYTE PTR INCODE50+ 2,0B8h     ;B0
		mov     BYTE PTR INCODE51+ 1,0FFh   ;U
		mov     BYTE PTR INCODE52+ 1,0D4h   ;PORT

		mov     BYTE PTR INCODEn1+ 2,0BCh       ;B4 in int10 func2



		mov     WORD PTR EnglishMode+8,0607h     ;cursor size
		mov     WORD PTR EnglishMode+8+15,0607h
		mov     WORD PTR EnglishMode+8+30,0607h
		mov     WORD PTR EnglishMode+8+45,0500h
		mov     WORD PTR EnglishMode+8+60,0500h  ;vga= 0607h
		mov     WORD PTR EnglishMode+8+75,0500h
		mov     BYTE PTR EnglishMode+10,0ffh       ;OFF under
		mov     BYTE PTR EnglishMode+10+15,0ffh
		mov     BYTE PTR EnglishMode+10+30,0ffh
		mov     BYTE PTR EnglishMode+10+45,0ffh
		mov     BYTE PTR EnglishMode+10+60,0ffh
		mov     BYTE PTR EnglishMode+10+75,0ffh

		mov     BYTE PTR COLOR1  + 1,17h
		mov     BYTE PTR COLOR2  + 2,01h
		mov     BYTE PTR COLOR3  + 1,7ch
		mov     BYTE PTR COLOR4  + 1,0ch

		mov     BYTE PTR PROTECT_A000H + 7,0Eh    ;direc Mov font

		push    es
		mov     ax,ds
		mov     es,ax
		mov     cx,42                   ;length of choice attri
		mov     al,78h                  ;find      78
		mov     di,OFFSET COLOR5
		cld                             ;forward
NextAtt:        repnz   scasb
		or      cx,cx                   ;test counter
		jz      finishAtt
		mov     BYTE PTR es:[di-1],7ch  ;change to 7c
		jmp     NextAtt                 ;again
finishAtt:      pop     es

		mov     BYTE PTR COLOR6  + 2,01h
		mov     BYTE PTR COLOR7  + 2,74h
		mov     BYTE PTR COLOR8  + 2,7ch
		mov     BYTE PTR COLOR9  + 2,7ch
		mov     BYTE PTR COLOR10 + 1,0ah
		jmp     AcrossMonoAtt

CRTdefault:
		push    es
		mov     ax,ds
		mov     es,ax
		mov     cx,42                   ;length of choice attri
		mov     al,7Ch                  ;find      7C
		mov     di,OFFSET COLOR5
		cld                             ;forward
NextAtt1:       repnz   scasb
		or      cx,cx                   ;test counter
		jz      finishAtt1
		mov     BYTE PTR es:[di-1],78h  ;change to 78
		jmp     NextAtt1                 ;again
finishAtt1:     pop     es

AcrossMonoAtt:  mov     bh,BYTE PTR AdapterType                  ;get font address es:bp
		mov     ax,1130h
		int     10h
		mov     ax,es
		push    cs
		pop     ds
		mov     WORD PTR EnglishMode+1,ax    ; font SEG
		mov     WORD PTR EnglishMode+1+15,ax ;
		mov     WORD PTR EnglishMode+1+30,ax ;
		mov     ax,ds                         ;
		mov     WORD PTR EnglishMode+1+45,ax ;
		mov     WORD PTR EnglishMode+1+60,ax ;
		mov     WORD PTR EnglishMode+1+75,ax ;
		mov     ax,bp
		mov     WORD PTR EnglishMode+3,ax    ; font OFFSET  b1
		mov     WORD PTR EnglishMode+3+15,ax ;
		mov     WORD PTR EnglishMode+3+30,ax ;

		mov     WORD PTR EnglishMode+5,ax    ; font OFFSET  b2
		mov     WORD PTR EnglishMode+5+15,ax ;
		mov     WORD PTR EnglishMode+5+30,ax ; <*** VGA cursor

		mov     ax,OFFSET EGAfont1
		mov     WORD PTR EnglishMode+3+45,ax ;
		mov     WORD PTR EnglishMode+3+60,ax ;
		mov     WORD PTR EnglishMode+3+75,ax ;
		mov     ax,OFFSET EGAfont2
		mov     WORD PTR EnglishMode+5+45,ax ;
		mov     WORD PTR EnglishMode+5+60,ax ;
		mov     WORD PTR EnglishMode+5+75,ax ;
		push    ds
		pop     es                              ;same segment


		cmp     BYTE PTR AdapterType,2             ;if 2 =EGA(defualt) 6=VGA
		je      AdaptDefault                  ; go out
;VGA SECTION
		cld
		mov     si,OFFSET VGAfont1
		mov     di,OFFSET EGAfont1              ;MOV VGA replace EGA
		mov     cx,OFFSET END_FONT - OFFSET VGAfont1 ;8192 ,8*256*2 + 16*128 + 16*256 =  size
		cld
		rep     movsb
		inc     di
		mov     LimitDown,di                    ;SET BOTTOM RESIDENT
		mov     WORD PTR EnglishMode+5+45,OFFSET EGAfont1 +2048        ;NEW start VGAfont2
		mov     WORD PTR EnglishMode+5+60,OFFSET EGAfont1 +2048        ;NEW start VGAfont2
		mov     WORD PTR EnglishMode+5+75,OFFSET EGAfont1 +2048        ;NEW start VGAfont2
		mov     WORD PTR RWoffset,OFFSET EGAfont1   +2048 +2048       ;NEW VGARWfont
		mov     WORD PTR SAHAoffset,OFFSET EGAfont1 +2048 +2048 +2048      ;NEW VGARWfont
		mov     WORD PTR ITAoffset,OFFSET EGAfont1  +2048 +2048 +2048 +2048

		mov     BYTE PTR EnglishMode+0,16       ;VGA tall
		mov     BYTE PTR EnglishMode+15,16
		mov     BYTE PTR EnglishMode+30,16
		mov     BYTE PTR EnglishMode+45,8
		mov     BYTE PTR EnglishMode+60,8
		mov     BYTE PTR EnglishMode+75,8

		mov     WORD PTR EnglishMode+8,0607h     ;cursor size
		mov     WORD PTR EnglishMode+8+15,0607h
		mov     WORD PTR EnglishMode+8+30,0607h  ;-------------
		mov     WORD PTR EnglishMode+8+45,0607h
		mov     WORD PTR EnglishMode+8+60,0607h  ;vga= 0607h
		mov     WORD PTR EnglishMode+8+75,0607h
		mov     WORD PTR INCODE25+1 ,0607H      ;STATUS CORSUR
AdaptDefault:   ret
Install         ENDP




CSEG            ENDS

STACK           SEGMENT PARA STACK 'STACK'
		DW 100H
STACK           ENDS

		END   Install
