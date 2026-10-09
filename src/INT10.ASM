ifndef MASM
OPTION PROC:PRIVATE
endif

CSEG            SEGMENT PARA PUBLIC 'CODE'
		ASSUME  CS:CSEG, DS:CSEG

		EXTRN   CurPoint:NEAR, NewVisit:NEAR
		EXTRN   Setmode:NEAR
		EXTRN   RefrOnOff:NEAR, CursorLevel:NEAR
		EXTRN   EnglishMode:NEAR
		EXTRN   CurrMode:NEAR
		EXTRN   NewPage:NEAR, IndexPort:NEAR
		EXTRN   MediamTable:NEAR, DispTran:NEAR, Transtable:NEAR
		EXTRN   KbTran:NEAR
		EXTRN   TransCurpos:NEAR, SetCurShape:NEAR
		EXTRN   Clscreen:NEAR, ClscreenOdd:NEAR, ClscreenOrg:NEAR
		EXTRN   Sound:NEAR

		EXTRN   int10Table:NEAR

		EXTRN   fucn2:NEAR
		EXTRN   fucn3:NEAR
		EXTRN   fucn5:NEAR
		EXTRN   fucn6:NEAR
		EXTRN   fucn7:NEAR
		EXTRN   fucn8:NEAR
		EXTRN   fucn9:NEAR
		EXTRN   fucnA:NEAR
		EXTRN   fucnE:NEAR


		PUBLIC  Old_int10h_vector
		PUBLIC  Old_int10h_offs
		PUBLIC  Old_int10h_seg
		PUBLIC  New_int10h
		PUBLIC  Int10funcE
		PUBLIC  Int10func2_2
		PUBLIC  Int10func3_2
		PUBLIC  Int10func6_2
		PUBLIC  Int10func7_2
		PUBLIC  Int10func8_2
		PUBLIC  Int10func9_2
		PUBLIC  Int10funcA_2
		PUBLIC  Int10funcE_2
		PUBLIC  SetCurSor

		PUBLIC  Int10func0
		PUBLIC  Int10func1
		PUBLIC  Int10func2
		PUBLIC  VideoReturn
		PUBLIC  OldVDOReturn
		PUBLIC  CurOffset

		PUBLIC  LastChar
		PUBLIC  INCODE8        ;b400
		PUBLIC  INCODE9        ;under
		PUBLIC  INCODE10       ;b400
		PUBLIC  INCODE11       ;b400
		PUBLIC  INCODE12       ;b400
		PUBLIC  INCODE13       ;b400
		PUBLIC  INCODE14       ;b400
		PUBLIC  INCODE15       ;3b4
		PUBLIC  INCODE15_1     ;3b4

		PUBLIC  INCODE16       ;b400
		PUBLIC  INCODE17       ;b400
		PUBLIC  INCODE18        ;under
		PUBLIC  INCODE19        ;under
		PUBLIC  INCODEn1

Old_int10h_vector LABEL DWORD
Old_int10h_offs   DW     ?
Old_int10h_seg    DW     ?

CurOffset       DW      0
LastChar        DB      ?
LastFlag        DB      ?
BStable         DB      0,0,1,1,1,1,0,6,6,6,6,6,0,0ch,0ch,0ch,0ch,0,11h,11h,11h,11h,0,16h,16h,16h,16h,0,0,0,0,0,0,0,0




New_int10h      PROC  NEAR
		push  ax    ;14
		push  bx    ;12
		push  cx    ;10
		push  dx    ;8
		push  di    ;6
		push  si    ;4
		push  ds    ;2
		push  es    ;0

		push    cs              ;RST programe
		pop     ds
		push    ax

		mov     al,ah           ;to low byte
		xor     ah,ah           ;zero high byte
		sal     ax,1            ;*2 look up
		mov     si,ax           ; put to si for branch
		cmp     ax,52   ;Mil
		pop     ax
		jae     OldVDOReturn
		jmp     cs:[si+OFFSET int10Table]

VideoReturn::    pop   es
		pop   ds    ;0
		pop   si
		pop   di
		pop   dx    ;6
		pop   cx
		pop   bx
		pop   ax
		iret

OldVDOReturn::   pop   es
		pop   ds    ;0
		pop   si
		pop   di
		pop   dx    ;6
		pop   cx
		pop   bx
		pop   ax
		pushf
		call  cs:Old_int10h_vector
		iret
New_int10h      ENDP

Int10func0      PROC  NEAR
		cmp     al,7            ;80 column monochrome mode
		je      OwnerSet
		cmp     al,2            ;80 column B&W mode
		je      OwnerSet
		cmp     al,3            ;80 column coler mode
		je      OwnerSet
		jmp     NormalOperat    ;
OwnerSet:       pushf
		call  cs:Old_int10h_vector

	   mov  dx,WORD PTR IndexPort
	   add  dx,0006h
	   in   al,dx
	   mov  al,0
	   mov  dx,3C0h                 ;off screen
	   out  dx,al

		call    Clscreen        ;DS wrong
		call    ClscreenOdd
		call    ClscreenOrg
		call    Setmode

		mov     al,BYTE PTR cs:CurrMode
		cmp     al,4
		jb      OrigianalBios                         ;lower 4
		mov     BYTE PTR RefrOnOff,1                  ;off it
		mov     WORD PTR fucn2,OFFSET Int10func2_2
		mov     WORD PTR fucn3,OFFSET Int10func3_2
		mov     WORD PTR fucn5,OFFSET VideoReturn     ;request by WEARNES
		mov     WORD PTR fucn6,OFFSET Int10func6_2
		mov     WORD PTR fucn7,OFFSET Int10func7_2
		mov     WORD PTR fucn8,OFFSET Int10func8_2
		mov     WORD PTR fucn9,OFFSET Int10func9_2
		mov     WORD PTR fucnA,OFFSET Int10funcA_2
		mov     WORD PTR fucnE,OFFSET Int10funcE_2
		cmp     al,5
		jnz     SetCurO_O
		mov     BYTE PTR RefrOnOff,0                   ;ON 25 AUTOmix

SetCurO_O:      mov     dx,0                                   ;set cursor position 0,0
		mov     ah,2
		mov     bh,0
		int     10h
		jmp     VideoReturn


OrigianalBios:  mov     BYTE PTR RefrOnOff,1                  ;off it
		mov     WORD PTR fucn2,OFFSET OldVDOReturn    ;Int10func2
		mov     WORD PTR fucn3,OFFSET OldVDOReturn
		mov     WORD PTR fucn5,OFFSET VideoReturn     ;request by WEARNES
		mov     WORD PTR fucn6,OFFSET OldVDOReturn
		mov     WORD PTR fucn7,OFFSET OldVDOReturn
		mov     WORD PTR fucn8,OFFSET OldVDOReturn
		mov     WORD PTR fucn9,OFFSET OldVDOReturn
		mov     WORD PTR fucnA,OFFSET OldVDOReturn
		mov     WORD PTR fucnE,OFFSET OldVDOReturn
		cmp     al,3
		jnz     SetCurO_O
		mov     BYTE PTR RefrOnOff,0                   ;ON 25 AUTOmix
		jmp     SetCurO_O

NormalOperat:   cli
		mov     BYTE PTR RefrOnOff,1                  ;off it
		mov     WORD PTR fucn2,OFFSET OldVDOReturn    ;Int10func2
		mov     WORD PTR fucn3,OFFSET OldVDOReturn
		mov     WORD PTR fucn5,OFFSET OldVDOReturn    ;request by WEARNES
		mov     WORD PTR fucn6,OFFSET OldVDOReturn
		mov     WORD PTR fucn7,OFFSET OldVDOReturn
		mov     WORD PTR fucn8,OFFSET OldVDOReturn
		mov     WORD PTR fucn9,OFFSET OldVDOReturn
		mov     WORD PTR fucnA,OFFSET OldVDOReturn
		mov     WORD PTR fucnE,OFFSET OldVDOReturn      ;Int10funcE
		sti
		jmp     OldVDOReturn

Int10func0      ENDP


Int10func1      PROC    NEAR
		cmp     BYTE PTR CurrMode,3
		jb      Int10func1_3
Int10func1_1:   mov     dx,cx           ;copy cursor size
		mov     WORD PTR CursorLevel,dx
		mov     bx,OFFSET EnglishMode
		xor     ch,ch
		mov     cl,15
		mov     al,BYTE PTR CurrMode
		mul     cl
		add     bx,ax                   ;sourse
		mov     [bx+8],dx               ;save in table
		inc     BYTE PTR NewVisit
		call    SetCurShape

		jmp     VideoReturn
Int10func1_3:   pushf
		call  cs:Old_int10h_vector
		jmp     VideoReturn
Int10func1      ENDP



Int10funcE      PROC    NEAR
		pushf
		call  cs:Old_int10h_vector
		mov   ax,40h
		mov   ds,ax           ;bios data segment
		mov   bx,50h          ;offset variable
		mov   dx,[bx]         ;save col row in BIOS variable
		mov   ax,160
		mul   dh              ;#row * 160
		xor   dh,dh
		shl   dx,1              ;mul col * 2
		add   ax,dx           ;real offset for L_refresh
		push    cs
		pop     ds
		mov     BYTE PTR NewVisit,1        ;flag tell CursorRefresh
		jmp     VideoReturn
Int10funcE      ENDP


;--------------------
;Entry  AL = ASCII
;       BH = Page
;       BL = foreground color in Graphic
;


Int10funcE_2    PROC    NEAR

		cmp   al,0dh          ;Is it carriage return
		ja    ItASCII
		jmp     DetectCode
ItASCII:        mov   di,CurOffset    ;get Cur position
		shl   di,1            ;adjust new screen pointer *2
		mov   dh,LastFlag     ; flag = 0 1 2
		mov   cl,LastChar
		xor   dl,dl           ;clear DL internal flag
INCODE8::        mov   bx,0B400h       ;b400 ,bc00   <<<<
		mov   es,bx           ;chang to upper new screen

		cmp   al,128          ;if code under 128 not change
		jb    mediam          ;below 128 goto mediam directly
		mov   bx,WORD PTR DispTran       ;get address of table
		xlat                  ;chang code
		cmp   al,0D1h
		je    SHORT upper0    ;go set DL flag
		cmp   al,0D4h         ;
		jb    SHORT mediam
		cmp   al,0DBh
		jb    SHORT upper0    ;go set DL flag
		cmp   al,0E7h         ;
		jb    SHORT mediam
		je    SHORT special
		cmp   al,0EDh
		ja    SHORT mediam       ;more than 0EDh is mediam line
		je    SHORT special           ;Barlee special
		cmp   al,0ECh
		jne   SHORT upper1            ;more than and less than goto
		cmp   cl,0D4h                 ;cl save Old charecter
		je    SHORT upper1
		cmp   cl,0D8h
		je    SHORT  upper1
		jmp   SHORT special           ;any set special
special:        inc   dl              ;DL=2 Tell Way0=F2 ,Way1= wrong way
upper0:         inc   dl              ;DL=1 tell way0=F1 ,way1=Wrong
upper1:         cmp   dh,1            ;compare flag by 1
		jb    SHORT zero
		je    SHORT one
		mov   dh,2            ;set flag=2
		jmp   SHORT two

zero:           cmp   dl,1            ;test flag = 1? (rigth/wrong)
		je    SHORT f1        ;Yes DL = F1
		mov   dh,2
f2_1:           mov   cl,al           ;copy old char

;--------FILL_UP  is small routine for  fill the character on Upper level
fillup0:        mov     bx,OFFSET Transtable -209   ;backward 209
		xlat                            ;translate to page font
		or      es:[di-2],al        ;
		jmp     SHORT WrCharOut

f1:             mov     dh,1
		cmp     al,0d8h         ;test o oo o
		jb      SHORT f2_1            ;if below D8h to fill up
		mov     ah,cl           ;transfer flag
		mov     cl,al           ;copy old char for test when ' comming
;---------FILL_DOWN  is routine for filling under level character o oo o
filldown0:      sub     al,0D7h         ;convert to 0 1 2 3 or 00 40 80 C0
		ror     al,1
		ror     al,1
		or      es:[di+320-2],al         ;add to screen
		jmp     SHORT WrCharOut

one:            mov     dh,2
		cmp     dl,0            ;0 = E8 E9 EA EB EC
		jne     SHORT two       ;No goto Wrong way
		cmp     cl,0D7h         ;check o oo o must use fill up0
		mov   cl,al             ;copy char
		ja      SHORT fillup0
		sub     al,0E7h         ;convert to 0 1 2 3 4
		add     es:[di-2],al    ;displacement ------>
		jmp     SHORT WrCharOut
;--------------------------
mediam:         xor   dh,dh           ;flag = 0
two:            cmp   al,128
		mov   cl,al             ;copy char
		jb    nonConvert

		and   BYTE PTR  es:[di+320],00111111b     ;mask off o oo o   clear lower
		and   BYTE PTR es:[di],11000000b          ;mask off - = -----clear upper

		cmp     al,9Fh
		ja      convert2
		call    LineGraphic     ;Hey goto Line graphic

convert2:
		and   ah,11110111b    ;block character thai above 127
nonConvert:     mov   bx,OFFSET MediamTable
		xlat
		mov   es:[di+160],al  ;move ascii only to new screen cur_p
		or    ah,01000b       ;active page 2
INCODE9::        and   ah,11111110b    ;off under line                       <<<<

	       ; inc   ColPos          ;increase Cursor position
		push    ds
		xor     ax,ax
		mov     ds,ax           ;segment = 0000
		inc     BYTE PTR ds:[450h]   ;increase Col position
		pop     ds


WrCharOut:      mov     LastFlag,dh             ;save LastFlag for next entry
		mov     LastChar,cl             ;and LastChar
;[----------------------------------------------------------------------]

		push    ds
		xor     ax,ax
		mov     ds,ax                   ;segment = 0000
		mov     dx,WORD PTR ds:[450h]      ;get position
		pop     ds


		cmp     dl,80           ;Column = 80
		jnz     U7              ;No
		mov     dl,0            ;Yes set to 0
		cmp     dh,24           ;Row =24
		jnz     U6              ;

U1:             call    SetCurSor       ;set new vision cursor

	       ; call    ReadAscAtt      ;read attribute from cursor position
;scroll up
		push    ds
INCODE10::       mov     bx,0B400H       ;B400 BC00 WORD PTR NewPage             ;<<<<
		mov     es,bx
		mov     ah,es:[1ea1h]       ;read attribute
		mov     al,ah           ;copy to al
		or      al,00001000b    ;sw page2
		mov     ds,bx
		mov     di,0            ;start first line
		mov     si,320          ;start second line
		mov     cx,4000 -160    ; 51 - 2 =49*80 =3920
		rep     movsw
		mov     cx,80
lowerLine:      movsb                   ;copy only ASCII
		stosb
		inc     si
		loop    lowerLine


		mov     al,55           ;blank ASCII
		mov     cx,80          ;fill just one line
		rep     stosw
		mov     al,0
		or      ah,01000b      ;sw page 2
		mov     cx,80          ;fill just one line
		rep     stosw

		mov     di,0            ;first line must clear o oo o
		mov     cx,80
Offbit:         and     BYTE PTR [di],00111111b
		add     di,2
		loop    Offbit
		pop     ds
		jmp     VideoReturn     ;Return back caller

U6:             inc     dh              ;increase Row position
U7:             call    SetCurSor       ;set new vision cursor
		jmp     VideoReturn     ;Return back caller

DetectCode:

		push    ds
		push    ax
		xor     ax,ax
		mov     ds,ax                   ;segment = 0000
		mov     dx,WORD PTR ds:[450h]      ;get position to DX
		pop     ax
		pop     ds

		cmp   al,0dh
		je    CRcode
		cmp   al,0ah          ;Is it line feed
		je    LFcode
		cmp   al,8            ;Is it back space
		je    BScode
		cmp   al,7            ;Is it bell
		je    BELLcode
		jmp     ItASCII

CRcode:         mov     dl,0
		jmp     U7              ;Here must to be clear Last Char and Last Flag

LFcode:         cmp     dh,24
		jne     U6
		jmp     U1

BScode:         cmp     dl,0
		je      U7

		mov     di,CurOffset             ;get Cur position
		shl     di,1
INCODE11::       mov     bx,0B400H       ;WORD PTR NewPage ;upper segment <<<<
		mov     es,bx                    ;chang to upper new screen

		mov     al, BYTE PTR es:[di-2]   ;Read at Cur-1 position
		mov     ah,al
		cmp     al,23h          ; ' | '
		jnz     upLevel
		mov     BYTE PTR es:[di-2],0            ;clear in  Memory
		jmp     down

upLevel:        and     al,00111111b                    ;take out upper o oo o
		jz      down                            ;If zero goto next check
		and     ah,11000000b                    ; chang pattern of lower
		mov     bx,OFFSET BStable
		xlat                                    ;open Base pattern
		or      al,ah                           ;include both Pattern
		mov     BYTE PTR es:[di-2],al           ;Replace it in Memory

		jmp     VideoReturn                     ;Return back caller

down:           mov     al,BYTE PTR es:[di+320-2]       ;Read at Cur-1 lower
		mov     ah,al
		and     al,11000000b                    ;take out lower (i ee)
		jz      mideim                          ;If it zero goto next step
		and     ah,00111111b                    ;chang Pattern
		mov     BYTE PTR es:[di+320-2],ah       ;Replace

		jmp     VideoReturn                     ;Return back caller

mideim:         dec     dl                      ;back the cursor
		call    SetCurSor       ;set new vision cursor
		call    GetLast
		jmp     VideoReturn     ;Return back caller

BELLcode:       mov     bl,2
		mov     ax,0530h                 ;bell sound
		mov     cx,0C000h               ;long time
		call    Sound

		jmp     VideoReturn       ;Return back caller


LineGraphic::    push    ax              ;save single byte command
		sub     al,80h          ;change to start 0
		xor     ah,ah           ;zero high byte
		sal     ax,1            ;*2 look up
		mov     bx,ax           ; put to si for branch
		pop     ax              ;restore single command
		call    cs:[bx+OFFSET LineGraphRoutin]
		ret
LineGraphRoutin LABEL   WORD
char80          DW      OFFSET NonGraph
char81          DW      OFFSET NonGraph
char82          DW      OFFSET UpperGraph
char83          DW      OFFSET UpperGraph
char84          DW      OFFSET UpperGraph
char85          DW      OFFSET NonGraph
char86          DW      OFFSET UpperGraph
char87          DW      OFFSET UpperGraph
char88          DW      OFFSET UpperGraph
char89          DW      OFFSET NonGraph
char8A          DW      OFFSET UpperGraph
char8B          DW      OFFSET NonGraph
char8C          DW      OFFSET NonGraph
char8D          DW      OFFSET NonGraph
char8E          DW      OFFSET NonGraph
char8F          DW      OFFSET NonGraph

char90          DW      OFFSET NonGraph
char91          DW      OFFSET NonGraph
char92          DW      OFFSET NonGraph
char93          DW      OFFSET NonGraph
char94          DW      OFFSET NonGraph
char95          DW      OFFSET NonGraph
char96          DW      OFFSET NonGraph
char97          DW      OFFSET NonGraph
char98          DW      OFFSET UpperGraph
char99          DW      OFFSET UpperGraph
char9A          DW      OFFSET NonGraph
char9B          DW      OFFSET UpperGraph
char9C          DW      OFFSET UpperGraph
char9D          DW      OFFSET UpperGraph
char9E          DW      OFFSET NonGraph
char9F          DW      OFFSET UpperGraph

UpperGraph      PROC    NEAR
		mov   BYTE PTR es:[di],23h   ;'|'
		ret
UpperGraph      ENDP
NonGraph        PROC    NEAR
		ret
NonGraph        ENDP

Int10funcE_2    ENDP

Int10funcA_2    PROC    NEAR
		mov   di,CurOffset              ;get Cur position
		shl   di,1                      ;adjust new screen pointer *2
	   ;     mov   ah,bl                     ;copy attribute

		push    ds
		xchg    ax,si
		xor     ax,ax
		mov     ds,ax                   ;segment = 0000
		mov     al,BYTE PTR ds:[451h]      ;get position DH=row
		mov     bx,160*2                  ;ROWx80x2
		mul     bx
		add     ax,160                  ;odd
		xchg    ax,si
		pop     ds

INCODE12::       mov   bx,0B400H         ;WORD PTR NewPage       ;upper segment <<<<
		mov   es,bx                     ;chang to upper new screen

AitAscii:       push    cx                      ;Repeater
		push    ax
		xor   dl,dl                     ;clear DL internal flag
		mov   dh,LastFlag               ; flag = 0 1 2
		mov   cl,LastChar
		cmp   al,128                    ;if code under 128 not change
		jb    Amediam                  ;below 128 goto mediam directly
		mov   bx,WORD PTR DispTran       ;get address of table
		xlat                            ;chang code
		cmp   al,0D1h
		je    SHORT Aupper0    ;go set DL flag
		cmp   al,0D4h           ;
		jb    SHORT Amediam
		cmp   al,0DBh
		jb    SHORT Aupper0     ;go set DL flag
		cmp   al,0E7h           ;
		jb    SHORT Amediam
		je    SHORT Aspecial
		cmp   al,0EDh
		ja    SHORT Amediam            ;more than 0EDh is mediam line
		je    SHORT Aspecial           ;Barlee special
		cmp   al,0ECh
		jne   SHORT Aupper1            ;more than and less than goto
		cmp   cl,0D4h                   ;cl save Old charecter
		je    SHORT Aupper1
		cmp   cl,0D8h
		je    SHORT  Aupper1
		jmp   SHORT Aspecial           ;any set special
Aspecial:       inc   dl                ;DL=2 Tell Way0=F2 ,Way1= wrong way
Aupper0:        inc   dl                ;DL=1 tell way0=F1 ,way1=Wrong
Aupper1:        cmp   dh,1              ;compare flag by 1
		jb    SHORT Azero
		je    SHORT Aone
		mov   dh,2              ;set flag=2
		jmp   SHORT Atwo

Azero:          mov     LastChar,al             ;appen
		cmp     dl,1                    ;test flag = 1? (rigth/wrong)
		je      SHORT Af1              ;Yes DL = F1
		mov     LastFlag,2
Af2_1:          mov     cl,al                           ;copy old char
Afillup0:       mov     bx,OFFSET Transtable -209       ;backward 209
		xlat                                    ;translate to page font
		or      es:[di-2],al            ;
		jmp     SHORT AWrCharOut

Af1:            mov     LastFlag,1
		cmp     al,0d8h                 ;test o oo o
		jb      SHORT Af2_1            ;if below D8h to fill up
		mov     ah,cl                   ;transfer flag
		mov     cl,al                   ;copy old char for test when ' comming
		sub     al,0D7h                 ;convert to 0 1 2 3 or 00 40 80 C0
		ror     al,1
		ror     al,1
		or      es:[di+320-2],al        ;add to screen
		jmp     SHORT AWrCharOut
;--------------------------
Amediam:        xor     dh,dh                   ;flag = 0
Atwo:           and     BYTE PTR es:[di+320],00111111b  ;mask off o oo o   clear lower
		and     BYTE PTR es:[di],11000000b      ;mask off - = -----clear upper
		cmp     al,128
		mov     LastFlag,dh             ;set flag for next time
		jb      AnonConvert

		cmp     al,9Fh
		ja      Aconvert2
		call    LineGraphic     ;Hey goto Line graphic
Aconvert2:

	      ;  and     ah,11110111b            ;block character thai above 127
AnonConvert:    mov     bx,OFFSET MediamTable
		xlat
		mov     es:[di+160],al                  ;move Ascii Only to new screen cur_p
		or      ah,01000b                       ;active page 2
INCODE18::       and     ah,11111110b                    ;off under line <<<<
	      ;  mov   es:[di+1],ah    ;copy attribute to upper line

		add     di,2            ;Next column
		jmp     SHORT AWrCharOut

Aone:           mov     dh,2
		cmp     dl,0                    ;0 = E8 E9 EA EB EC
		jne     SHORT Atwo             ;No goto Wrong way
		cmp     cl,0D7h                 ;check o oo o must use fill up0
		ja      SHORT Afillup0
		sub     al,0E7h                 ;convert to 0 1 2 3 4
		add     es:[di-2],al            ;displacement ------>
		jmp     SHORT AWrCharOut

AWrCharOut:     pop     ax
		pop     cx
		dec     cx
		jz      AOutloop
		cmp     di,si                   ;just in line?
		jb      AInline                 ;Yes
		add     di,160                   ;across line
		add     si,320                    ;next point
AInline:        jmp     AitAscii
AOutloop:       jmp     VideoReturn             ;Return back caller


Int10funcA_2    ENDP

TransBack   DB  255,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246
	    DB  247,248,249,250,251,252,253,254,  1,  2,  3,  4,  5,  6,  7,  8
	    DB    9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
	    DB   25, 26, 27, 28, 29, 30, 31,255, 33, 34, 35, 36, 37, 38, 39, 40
	    DB  161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176
	    DB  177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192
	    DB  193,194,195, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53
	    DB   54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69

	    DB  196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211
	    DB  212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227
	    DB  228,229,230, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82
	    DB   83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98
	    DB  144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
	    DB  128,129,130,131,132,133,134,135,136,137,138,139,160,  0,  0,140
	    DB  141,142,143, 99,100,101,102,103,104,105,106,107,108,109,110,111
	    DB  112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127

Int10func8_2    PROC    NEAR
		push    bp                      ;save BP register
		mov     bp,sp
		mov     di,CurOffset            ;get Cur position
		shl     di,1                    ;adjust new screen pointer *2
INCODE13::       mov     bx,0B400H       ;WORD PTR NewPage     ;upper segment            <<<<
		mov     es,bx                   ;chang to upper new screen
		mov     ax,es:[di+160]          ;move Ascii Attri only to new screen cur_p
		mov     bx,OFFSET TransBack
		xlat
		cmp     al,128
		jb      Int10Notchange
		mov     bx,WORD PTR KbTran       ;Table Code
		xlat                           ;chang code
Int10Notchange: mov     [bp+16],ax
		pop     bp                      ;restore BP
		jmp     VideoReturn             ;Return back caller
Int10func8_2    ENDP

;999999999999999999999999999999999999999999999999999

LastFlg         db 0
LastChr         db 0
Int10func9_2    PROC    NEAR
		mov   di,CurOffset              ;get Cur position
		shl   di,1                      ;adjust new screen pointer *2
		mov   ah,bl                     ;copy attribute

		push    ds
		xchg    ax,si                   ;save ax
		xor     ax,ax
		mov     ds,ax                   ;segment = 0000
		mov     al,BYTE PTR ds:[451h]      ;get position DH=row
		mov     bx,160*2                ;ROWx80x2
		mul     bx
		add     ax,160                  ;odd
		xchg    ax,si                   ;restore ax and value to si
		pop     ds

INCODE14::       mov   bx,0B400H         ;WORD PTR NewPage       ;upper segment <<<<
		mov   es,bx                     ;chang to upper new screen

_9itAscii:      push    cx                      ;Repeater
		push    ax
		xor   dl,dl                     ;clear DL internal flag
		mov   dh,LastFlag               ; flag = 0 1 2
		mov   cl,LastChar
		cmp   al,128                    ;if code under 128 not change
		jb    _9mediam                  ;below 128 goto mediam directly
		mov   bx,WORD PTR DispTran       ;get address of table
		xlat                            ;chang code
		cmp   al,0D1h
		je    SHORT _9upper0    ;go set DL flag
		cmp   al,0D4h           ;
		jb    SHORT _9mediam
		cmp   al,0DBh
		jb    SHORT _9upper0     ;go set DL flag
		cmp   al,0E7h           ;
		jb    SHORT _9mediam
		je    SHORT _9special
		cmp   al,0EDh
		ja    SHORT _9mediam            ;more than 0EDh is mediam line
		je    SHORT _9special           ;Barlee special
		cmp   al,0ECh
		jne   SHORT _9upper1            ;more than and less than goto
		cmp   cl,0D4h                   ;cl save Old charecter
		je    SHORT _9upper1
		cmp   cl,0D8h
		je    SHORT  _9upper1
		jmp   SHORT _9special           ;any set special
_9special:      inc   dl                ;DL=2 Tell Way0=F2 ,Way1= wrong way
_9upper0:       inc   dl                ;DL=1 tell way0=F1 ,way1=Wrong
_9upper1:       cmp   dh,1              ;compare flag by 1
		jb    SHORT _9zero
		je    SHORT _9one
		mov   dh,2              ;set flag=2
		jmp   SHORT _9two

_9zero:         mov     LastChar,al             ;appen
		cmp     dl,1                    ;test flag = 1? (rigth/wrong)
		je      SHORT _9f1              ;Yes DL = F1
		mov     LastFlag,2
_9f2_1:         mov     cl,al                           ;copy old char
_9fillup0:      mov     bx,OFFSET Transtable -209       ;backward 209
		xlat                                    ;translate to page font
		or      es:[di-2],al            ;
		jmp     SHORT _9WrCharOut

_9f1:           mov     LastFlag,1
		cmp     al,0d8h                 ;test o oo o
		jb      SHORT _9f2_1            ;if below D8h to fill up
		mov     ah,cl                   ;transfer flag
		mov     cl,al                   ;copy old char for test when ' comming
		sub     al,0D7h                 ;convert to 0 1 2 3 or 00 40 80 C0
		ror     al,1
		ror     al,1
		or      es:[di+320-2],al        ;add to screen
		jmp     SHORT _9WrCharOut
;--------------------------
_9mediam:       xor     dh,dh                   ;flag = 0
_9two:          and     BYTE PTR es:[di+320],00111111b  ;mask off o oo o   clear lower
		and     BYTE PTR es:[di],11000000b      ;mask off - = -----clear upper
		cmp     al,128
		mov     LastFlg,dh             ;set flag for next time/////
		jb      _9nonConvert

		cmp     al,9Fh
		ja      _9convert2
		call    LineGraphic     ;Hey goto Line graphic
_9convert2:

		and     ah,11110111b            ;block character thai above 127
_9nonConvert:   mov     bx,OFFSET MediamTable
		xlat
		mov     es:[di+160],ax                  ;move Ascii Attribute to new screen cur_p
		or      ah,01000b                       ;active page 2
INCODE19::       and     ah,11111110b                    ;off under line <<<<
		mov   es:[di+1],ah    ;copy attribute to upper line

		add     di,2            ;Next column
		jmp     SHORT _9WrCharOut

_9one:          mov     dh,2
		cmp     dl,0                    ;0 = E8 E9 EA EB EC
		jne     SHORT _9two             ;No goto Wrong way
		cmp     cl,0D7h                 ;check o oo o must use fill up0
		ja      SHORT _9fillup0
		sub     al,0E7h                 ;convert to 0 1 2 3 4
		add     es:[di-2],al            ;displacement ------>
		jmp     SHORT _9WrCharOut

_9WrCharOut:    pop     ax
		pop     cx
		dec     cx
		jz     _9Outloop
		cmp     di,si                   ;just in line?
		jb     _9Inline                 ;Yes
		add     di,160                    ;across line
		add     si,320                    ;next point

_9Inline:       jmp     _9itAscii
_9Outloop:      jmp     VideoReturn             ;Return back caller

Int10func9_2    ENDP

Int10func2      PROC    NEAR
	      ;  mov     WORD PTR ColPos,dx

		push    ds
		xor     ax,ax
		mov     ds,ax                   ;segment = 0000
		mov     WORD PTR ds:[450h],dx      ;get position
		pop     ds

		jmp     OldVDOReturn
Int10func2      ENDP

Int10func2_3    PROC  NEAR
		cmp     dl,0              ;column 0 flag=2
		mov     LastFlag,2
		je      Protect
		mov     LastFlag,0
Protect:        call    SetCurSor
		call    GetLast
		jmp     VideoReturn       ;Return back caller
Int10func2_3    ENDP

OffSum          db      0             ;add sara wanayu for Hard blank

Int10func2_2    PROC  NEAR
	      ;  mov     WORD PTR ColPos,dx
		push    ds
		xor     ax,ax
		mov     ds,ax                   ;segment = 0000
		mov     WORD PTR ds:[450h],dx      ;get position DH=row
		pop     ds

		cmp     dl,0              ;column 0 flag=2
		je      Protect2_3
		mov     cl,0              ;new column = 0
		mov     ch,dh             ;store row in CH
		mov     al,80
		mul     dh
		xor     dh,dh
		shl     ax,1
		shl     ax,1
		add     ax,2              ;-_ first position
		mov     di,ax
INCODEn1::       mov     bx,0b400h
		mov     es,bx
		mov     cs:OffSum,0        ;clear offset sum

newLoop:        mov     al,BYTE PTR es:[di+160-2]
		cmp     al,220                          ;Hard blank
		jz      AddToDL

CommondWork:    mov     al,BYTE PTR es:[di+320-2]
		cmp     al,023h           ; |
		jz      lineGraph
		and     al,11000000b      ;take out lower (i ee)
		jnz     uppercheck
		mov     al,BYTE PTR es:[di-2]
		cmp     al,023h           ; |
		jz      lineGraph
		and     al,00011111b      ;take out upper (o oo)
		jnz     LookTable
lineGraph:      mov     bl,1              ;col-1
SubCol:         mov     bh,bl             ;copy another register not affect
		dec     bh
		add     cs:OffSum,bh         ;add sum
		inc     di
		inc     di                ;pointer ++
		inc     cl                ;new column
		sub     dl,bl             ;col-x
		ja      newLoop
		mov     dx,cx             ;dl = new Column and old Row

Protect2_3:     call    CursorXY            ;SetCurSor
		call    GetLast        ;///////
		jmp     VideoReturn       ;Return back caller

AddToDL:        add     dl,cs:OffSum         ;add back
		mov     OffSum,0          ;clear for new loop
		jmp     CommondWork

uppercheck:     mov     bl,2              ;col-2
		mov     al,BYTE PTR es:[di-2]
		and     al,00111111b      ;take out upper (o oo)
		jz      SubCol
		mov     bl,3              ;col-3
		jmp     SubCol
LookTable:      mov     bx,OFFSET DecValue ;
		xlat
		mov     bl,al             ;col-table
		jmp     SubCol
Int10func2_2    ENDP

DecValue        DB      1,2,3,3,3,3, 2,3,3,3,3,3, 2,3,3,3,3, 2,3,3,3,3, 2,3,3,3,3, 2,2,2,2,2,2,2,2

;---
CursorXY:
		mov     al,80           ;langth = 80
		mul     dh
		xor     dh,dh           ;clear upper register
		shl     ax,1            ; * 2 for double 50 line
		add     ax,dx            ;add column
		mov     CurOffset,ax    ;save
		add     ax,2050h        ;add offset for new screen  may be********
		mov     cx,ax           ;result physical cursor
INCODE15_1:     mov     dx,03B4H        ;WORD PTR IndexPort                   ;<<<<
		mov     al,0Eh          ;index register
		out     dx,al
		inc     dx              ;data register
		mov     al,ch
		out     dx,al           ;first register
		dec     dx              ;index again
		mov     al,0Fh          ;
		out     dx,al
		inc     dx              ;data again
		mov     al,cl           ;second register
		out     dx,al
		ret
;----


Int10func3_2    PROC    NEAR
		push    bp              ;save BP register
		mov     bp,sp
	    ;    mov     dx,WORD PTR ColPos
		push    ds
		xor     ax,ax
		mov     ds,ax                   ;segment = 0000
		mov     dx,WORD PTR ds:[450h]      ;get position
		pop     ds

		mov     [bp+8+2],dx               ;cursor position
		mov     dx,WORD PTR CursorLevel
		mov     [bp+10+2],dx              ;cursor size
		pop     bp              ;retore BP   << +2
		jmp     VideoReturn
Int10func3_2    ENDP
;-------------------------
;Entry  DH = row
;       DL = column
;       Bh = page number

SetCurSor       PROC    NEAR
		push    ax
		push    dx
	      ;  mov     WORD PTR ColPos,dx
		push    ds
		push    ax
		xor     ax,ax
		mov     ds,ax                   ;segment = 0000
		mov     WORD PTR ds:[450h],dx      ;get position
		pop     ax
		pop     ds


		mov     al,80           ;langth = 80
		mul     dh
		xor     dh,dh           ;clear upper register
		shl     ax,1            ; * 2 double 50 line
		add     ax,dx
		mov     CurOffset,ax    ;save
		add     ax,2050h        ;add offset for new screen  may be********
		mov     cx,ax           ;result physical cursor
INCODE15::       mov     dx,03B4H        ;WORD PTR IndexPort                   ;<<<<
		mov     al,0Eh          ;index register
		out     dx,al
		inc     dx              ;data register
		mov     al,ch
		out     dx,al           ;first register
		dec     dx              ;index again
		mov     al,0Fh          ;
		out     dx,al
		inc     dx              ;data again
		mov     al,cl           ;second register
		out     dx,al
		pop     dx
		pop     ax
		ret
SetCurSor       ENDP

LastTable       DB      0000,0,0D1h,1,0E8h,2,0E9h,2,0EAh,2,0EBh,2
		DB      0D4h,1,0E8h,2,0E9h,2,0EAh,2,0EBh,2,0ECh,2
		DB      0D5h,1,0E8h,2,0E9h,2,0EAh,2,0EBh,2
		DB      0D6h,1,0E8h,2,0E9h,2,0EAh,2,0EBh,2
		DB      0D7h,1,0E8h,2,0E9h,2,0EAh,2,0EBh,2
		DB      0E7h,2,0E8h,2,0E9h,2,0EAh,2,0EBh,2,0ECh,2,0EDh,2,0EEh,2
										       ;* *  *
TranBack        DB      0E7h,0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh,0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0FAh,0FBh,0FBh,0FBh,0FBh,001h,002h,003h,004h,005h,006h,007h,008h
		DB      009h,00Ah,00Bh,00Ch,00Dh,00Eh,00Fh,010h,011h,012h,013h,014h,015h,016h,017h,018h,019h,01Ah,01Bh,01Ch,01Dh,01Eh,01Fh,020h,021h,022h,023h,024h,025h,026h,027h,028h
		DB      0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh,0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh,0C0h
		DB      0C1h,0C2h,0C3h,029h,02Ah,02Bh,02Ch,02Dh,02Eh,02Fh,030h,031h,032h,033h,034h,035h,036h,037h,038h,039h,03Ah,03Bh,03Ch,03Dh,03Eh,03Fh,040h,041h,042h,043h,044h,045h
		DB      0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh,0D0h,0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h,0D8h,0D9h,0DAh,0DBh,0DCh,0DDh,0DEh,0DFh,0E0h,0E1h,0E2h,0E3h
		DB      0E4h,0E5h,0E6h,046h,047h,048h,049h,04Ah,04Bh,04Ch,04Dh,04Eh,04Fh,050h,051h,052h,053h,054h,055h,056h,057h,058h,059h,05Ah,05Bh,05Ch,05Dh,05Eh,05Fh,060h,061h,062h
		DB      090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh,080h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08Ah,08Bh,020h,08Bh,08Bh,08Ch
		DB      08Dh,08Eh,08Fh,063h,064h,065h,066h,067h,068h,069h,06Ah,06Bh,06Ch,06Dh,06Eh,06Fh,070h,071h,072h,073h,074h,075h,076h,077h,078h,079h,07Ah,07Bh,07Ch,07Dh,07Eh,07Fh

;Get the last Char & Flag at CursorOffset
;
      ;          mov     alBYTE PTR es:[di+320-2]       ;Read at Cur-1 lower
      ;          and     al,011000000b
      ;          jz      NoIncLastFlag
      ;          inc     BYTE PTR LastFlag

GetLast         PROC    NEAR
		mov     di,CurOffset             ;get Cur position
		shl     di,1
INCODE16::       mov     bx,0B400H       ;WORD PTR NewPage      ;upper segment  <<<<
		mov     es,bx                    ;chang to upper new screen
		mov     al, BYTE PTR es:[di-2]   ;Read at Cur-1 position
		and     al,00111111b                    ;take out upper o oo o
		jz      GetLastdown                            ;If zero goto next check
		mov     bx,OFFSET LastTable
		xor     ah,ah
		shl     al,1
		add     bx,ax
		mov     ax,[bx]                 ;copy last char & flag
		mov     WORD PTR LastChar,ax
NoIncLastFlag:  ret                                     ;Return back caller

GetLastdown:    mov     al,BYTE PTR es:[di+320-2]       ;Read at Cur-1 lower
		and     al,11000000b                    ;take out lower (i ee)
		jz      GetLastMid                      ;If it zero goto next step
		rol     al,1
		rol     al,1
		add     al,0D7h         ;convert  00 40 80 C0 to smo code
		mov     LastChar,al
		mov     LastFlag,1
		ret                                     ;Return back caller

GetLastMid:     mov     bx,OFFSET TranBack
		mov     al,BYTE PTR es:[di+160-2]
		xlat
		mov     LastChar,al
		mov     LastFlag,0                        ;back the cursor
		ret                                     ;Return back caller
GetLast         ENDP


ReadAscAtt      PROC    NEAR
INCODE17::       mov     ax,0B400H       ;WORD PTR NewPage             ;<<<<
		mov     es,ax
		mov     bx,CurOffset
		mov     ax,es:[bx]
		ret
ReadAscAtt      ENDP




CRT_COLS     DB      160



Int10func6_2    PROC    NEAR
		push    bp                      ;save BP
		mov     bl,al                   ;save line counter
		mov     ax,WORD PTR NewPage     ;for New page  <<<<
		mov     es,ax
		push    bx
		mov     ax,cx
	   ;     sub     ah,bl                   ;my method
		call    ScrollPos
		jz      N7
		add     si,ax
		mov     ah,dh                   ;#Row in block
		sub     ah,bl                   ;#Row to be move
		call    UpperPatch6_2           ;patch first line
		add     si,bp
		add     di,bp                   ;point to next line
		dec     ah                      ;decrement counter

N2:             call    MoveRow
		add     si,bp
		add     di,bp
		dec     ah
		jnz     N2

N3:             pop     ax
		call    LowerPatch6_2
		add     di,bp
		dec     bl
		jz      N4_1

N4:             call    FillBlank
		add     di,bp
		dec     bl
		jnz     N4
N4_1:           call    TurnOffLow6_2
		pop     bp                      ;restore BP
		jmp     VideoReturn
N7:             mov     bl,dh
		jmp     N3
Int10func6_2    ENDP

UpperPatch6_2:  mov     cl,dl                   ;counter
		push    si
		push    di
UpperPatch1:    lodsb                           ;get data to AL
		and     al,00111111b            ;turn off upper
		and     BYTE PTR [di],11000000b ;turn off lower Target
		or      [di],al
		add     di,2
		inc     si
		loop    UpperPatch1
		pop     di
		pop     si

		mov     cl,dl
		push    si
		push    di
		add     si,160          ;next half line
		add     di,160
		rep     movsw
		pop     di
		pop     si
		ret

LowerPatch6_2:  mov     cl,dl
		push    ax
		push    si
		push    di
		or      ah,01000b               ;switch page 2
LowerPatch1:    lodsb                           ;get data to AL
		and     al,11000000b            ;turn off lower
		mov      [di],al
		mov     [di+1],ah
		add     di,2
		inc     si
		loop    LowerPatch1
		pop     di
		pop     si
		pop     ax

		mov     cl,dl
		mov     al,55           ;blank ASCII
		push    di
		add     di,160          ;next half line
		rep     stosw
		pop     di
		ret

TurnOffLow6_2:   mov     cl,dl                   ;counter
		 push    si
		 push    di
TurnOffLower1:   and     BYTE PTR [di],00111111b
		 add     di,2
		 loop    TurnOffLower1
		 pop     di
		 pop     si
		 ret

;---------------------------
Int10func7_2    PROC    NEAR
		push    bp              ;save BP
		std
		mov     bl,al
		mov     ax,WORD PTR NewPage     ;for New page <<<<
		mov     es,ax
		push    bx
	 ;       add     dh,bl                   ;add row to address
		mov     ax,dx

		call    ScrollPos
		jz      N16
		sub     si,ax
		mov     ah,dh
		sub     ah,bl
		call    LowerPatch7_2
N13:            call    MoveRow
		sub     si,bp
		sub     di,bp
		dec     ah
		jnz     N13
		call    TurnOffLow7_2
N14:            pop     ax
		dec     bl                      ;decrement counter
		jz      N15_1
N15:            call    FillBlank
		sub     di,bp
		dec     bl
		jnz     N15
N15_1:          call    UpperPatch7_2
		pop     bp                      ;restore BP
		jmp     VideoReturn

N16:            mov     bl,dh
		jmp     N14
Int10func7_2    ENDP

LowerPatch7_2:  mov     cl,dl                   ;counter
		push    si
		push    di
		add     si,320                 ;half line
		add     di,320
LowerPatch71:   lodsb                           ;get data to AL
		and     al,11000000b            ;turn off lower
		and     BYTE PTR [di],00111111b ;turn off upper Target
		or      [di],al
		sub     di,2
		dec     si
		loop    LowerPatch71
		pop     di
		pop     si
		ret

UpperPatch7_2:  mov     cl,dl
		push    ax
		push    di
		or      ah,01000b               ;switch page 2
UpperPatch71:   and     BYTE PTR [di],11000000b
		mov     [di+1],ah
		sub     di,2
		loop    UpperPatch71
		pop     di
		pop     ax

		mov     cl,dl
		mov     al,55           ;blank ASCII
		push    di
		add     di,160          ;next half line
		rep     stosw
		pop     di
		ret

TurnOffLow7_2:  mov     cl,dl                   ;counter
		push    di
		add     di,320
TurnOffLower12: and     BYTE PTR [di],00111111b
		sub     di,2
		loop    TurnOffLower12
		pop     di
		ret

ScrollPos:      call    POSITION
		mov     di,ax
		mov     si,ax
		sub     dx,cx           ;DX = #Row , #Column in block
		inc     dh
		inc     dl              ;Increment for origin 0
		mov     bp,320          ;only one line (160+160)

		mov     al,bl           ;get line counter
		mov     ch,160          ;
		mul     ch
		xor     ch,ch
		add     ax,ax
		push    es
		pop     ds
		cmp     bl,0
		ret

MoveRow:        mov     cl,dl
		push    si
		push    di
		rep     movsw
		pop     di
		pop     si


		mov     cl,dl
		push    si
		push    di
		add     si,160          ;next half line
		add     di,160
		rep     movsw
		pop     di
		pop     si
		ret

FillBlank:      mov     cl,dl
		push    ax
		mov     al,0            ;blank ASCII
		or      ah,01000b      ;sw page 2
		push    di
		rep     stosw
		pop     di
		pop     ax

		mov     cl,dl
		mov     al,55           ;blank ASCII
		push    di
		add     di,160          ;next half line
		rep     stosw
		pop     di
		ret

POSITION        PROC    NEAR
		push    bx
		mov     bx,ax
		mov     al,ah
		mul     BYTE PTR CRT_COLS       ;<<<<
		xor     bh,bh
		add     ax,bx
		sal     ax,1
		pop     bx
		ret
POSITION        ENDP


CSEG        ENDS
		END
