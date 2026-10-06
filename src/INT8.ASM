OPTION PROC:PRIVATE
CSEG            SEGMENT PARA PUBLIC 'CODE'
		ASSUME  CS:CSEG, DS:CSEG

		;exter func
		EXTRN   HardCur:NEAR
		EXTRN   TransCurpos:NEAR
		EXTRN   RefrOnOff:NEAR
		EXTRN    ShadowMem:NEAR
		EXTRN   DispTran:NEAR
		EXTRN   TimerRun:NEAR
		EXTRN   ScrHardBlkLen:NEAR
		EXTRN   SpeedVAR:NEAR

		PUBLIC  Old_int08h_offs
		PUBLIC  Old_int08h_seg
		PUBLIC  New_int08h
		PUBLIC  INCODE1
		PUBLIC  INCODE2
		PUBLIC  INCODE3
		PUBLIC  INCODE4
		PUBLIC  INCODE20
		PUBLIC  INCODE21
		PUBLIC  INCODE22
		PUBLIC  INCODE23

		PUBLIC  INCODE50
		PUBLIC  INCODE51

		PUBLIC  OffsetCode1

		PUBLIC  TableTIS
		PUBLIC  KU_TIS
		PUBLIC  TIS_KU
		PUBLIC  SCT_TIS
		PUBLIC  TIS_SCT
		PUBLIC  FLAG_25LINE
		PUBLIC  MediamTable
		PUBLIC  Transtable
		PUBLIC  L_refresh1
		PUBLIC  Shearsor1

		PUBLIC  MediamTable
		PUBLIC  TimeRecode

		;Tis_Tis
TableTIS        DB  080h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh
		DB  090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh
		DB  0A0h,0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh
		DB  0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
		DB  0C0h,0C1h,0C2h,0C3h,0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh
		DB  0D0h,0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h,0D8h,0D9h,0DAh,0DBh,0DCh,0DDh,0DEh,0DFh
		DB  0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E6h,0E7h,0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh
		DB  0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0FAh,0FBh,0FCh,0FDh,0FEh,0FFh

		;Ku_TIS
KU_TIS          DB  0DFh,0FAh,0E5h,09Fh,08Ch,08Dh,08Eh,08Fh,08Bh,08Ah,080h,081h,082h,083h,084h,085h
		DB  0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0A3h,0A5h,088h,089h,087h,086h
		DB  0A0h,0A1h,0A2h,0A4h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh,0B0h,0B1h
		DB  0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh,0C0h,0C1h
		DB  0C2h,0C3h,0C4h,0C5h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0D0h,0C6h,0D2h,0D3h
		DB  0E0h,0E1h,0E2h,0E3h,0E4h,0E6h,0CFh,0D8h,0D9h,0D4h,0D5h,0D6h,0D7h,0D1h,0DAh,0E7h
		DB  0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh,020h,020h,080h,081h,082h,083h,084h,085h
		DB  090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,0FFh

TIS_KU          DB  08Ah,08Bh,08Ch,08Dh,08Eh,08Fh,09Fh,09Eh,09Ch,09Dh,089h,088h,084h,085h,086h,087h
		DB  0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0FAh,0FBh,0FCh,0FDh,0FEh,083h
		DB  08Eh,0A1h,0A2h,09Ah,0A3h,09Bh,0A4h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh
		DB  0AEh,0AFh,0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh
		DB  0BEh,0BFh,0C0h,0C1h,0C2h,0C3h,0CDh,0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0D6h
		DB  0CCh,0DDh,0CEh,0CFh,0D9h,0DAh,0DBh,0DCh,0D7h,0D8h,0DEh,08Ah,08Ch,08Fh,09Eh,080h
		DB  0D0h,0D1h,0D2h,0D3h,0D4h,082h,0D5h,0DFh,0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E4h,0E7h
		DB  090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,081h,020h,020h,020h,020h,020h

TIS_SCT         DB  080h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh
		DB  090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh
		DB  0A0h,0C1h,0C2h,0C2h,0C3h,0C3h,0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh
		DB  0CEh,0CFh,0D0h,0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h,0D8h,0D9h,0DAh,0DBh,0DCh,0DDh
		DB  0DEh,0DFh,0E0h,0E1h,0E2h,0E3h,0E2h,0E4h,0E5h,0E6h,0E7h,0E8h,0E9h,0EAh,0EBh,0FEh
		DB  0ECh,0EDh,0EEh,0EFh,0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0FBh,020h,020h,020h,020h,0BAh
		DB  0F6h,0F7h,0F8h,0F9h,0FAh,0EEh,0FCh,0A7h,0A1h,0A3h,0A4h,0A6h,0BCh,0BDh,0BEh,0BFh
		DB  0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BBh,0FDh,020h,020h,020h,0FFh

SCT_TIS         DB  080h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh
		DB  090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh
		DB  020h,0E8h,020h,0E9h,0EAh,020h,0EBh,0E7h,0DBh,0DCh,0DDh,0DEh,0FCh,0FDh,0A3h,0A5h
		DB  0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0DFh,0FAh,0ECh,0EDh,0EEh,0EFh
		DB  0A0h,0A1h,0A2h,0A4h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh,0B0h,0B1h
		DB  0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh,0C0h,0C1h
		DB  0C2h,0C3h,0C4h,0C5h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0D0h,0D1h,0D2h,0D3h
		DB  0D4h,0D5h,0D6h,0D7h,0D8h,0D9h,0E0h,0E1h,0E2h,0E3h,0E4h,0DAh,0E6h,0FBh,0CFh,0FFh

;------------
StartAddress      DW    0000h,00a0h,0140h,01E0h,0280h,0320h,03C0h,0460h,0500h,05A0h,0640h,06E0h,0780h
		  DW    0820h,08C0h,0960h,0a00h,0aA0h,0b40h,0bE0h,0c80h,0d20h,0dC0h,0e60h,0f00h
FLAG_25LINE       DB      52 dup(1)       ;even = FLAG odd = VALUE

;-------------


ColRow            DW    ?

Old_int08h_vector LABEL DWORD

Old_int08h_offs   DW     ?
Old_int08h_seg    DW     ?


New_int08h      PROC  NEAR
		sti
		pushf
		call  cs:Old_int08h_vector
		cmp   BYTE PTR cs:RefrOnOff,1     ;1= off refresh screen. when POP-UP
		je    New_int8end
		cmp   cs:ReEntrance,1             ;protect re-entrance
		je    New_int8end
		call  WORD PTR cs:TimerRun
New_int8end:    iret
New_int08h      ENDP

ReEntrance      DB 0            ;re- entrance protect

BlankCount        DB    0
OffsetCount       DB    0
TimeRecode        DB    0
L_refresh1      PROC    NEAR
		  sti
		  push  si
		  push  di
		  push  es
		  push  ds
		  push  bp
		  push  dx
		  push  cx
		  push  bx
		  push  ax

		  push  cs                      ;must re initail segment RST
		  pop   ds                      ;

		  mov   BYTE PTR cs:ReEntrance,1 ; ** Protect Re-Entrance CDC concept

		  inc   TimeRecode
		  mov   al,BYTE PTR SpeedVar
		  cmp   TimeRecode,al
		  jne   L_refrOUT
		  mov   TimeRecode,0            ;clear Restart
		  call  HardCur              ;<get cursor position from Register
		  mov   cx,25                    ;set loop one time
		  mov   bx,160
		  xor   si,si

refresh:          push  cx
		  call L_refresh2
		  pop   cx
		  add   si,bx                ;begin each line
		  loop  refresh               ;loop

L_refrOUT:        mov   BYTE PTR cs:ReEntrance,0  ; ** On refresher
		  pop   ax
		  pop   bx
		  pop   cx
		  pop   dx
		  pop   bp
		  pop   ds
		  pop   es
		  pop   di
		  pop   si
		  ret
L_refresh1      ENDP


;---------------------------------------------------------------------------
;Enter:  SI point start line Old screen
;----------------------------------------------------------------------------


L_refresh2         PROC  NEAR
		  push  bx
		  push  di     ;10
		  push  si     ;8
	      ;    cli                 <<<<<< for CDC terminal concept
		  cld
		  push  cs              ;
		  pop   es              ;data segment = code segment
		  mov   di,si           ;copy
INCODE50::       mov     bx,0B000h       ;OldPage   B000 , b800 <<<<
		mov     ds,bx
		mov     cx,80

		mov     bx,OFFSET ShadowMem
		add     di,bx           ;destin ds:si+bx      shadow
		mov     bx,si
		mov     ax,di
		repe    cmpsw           ;source es:di         screen
		jne     go_refresh
		jmp     out_loop
go_refresh:     mov     si,bx           ;screen
		mov     di,ax           ;shadow
		mov     cx,80

		rep   movsw           ;mov block
		mov     si,bx
		mov     di,bx
		mov     ax,cs           ;data seg = code seg
		mov     ds,ax
		  shl   di,1            ;adjust new screen pointer *2
		  mov   dh,2            ;define dh = flag = 2
		  mov   bp,80           ;set bp is counter 80 column a line
turn_back:        xor   dl,dl           ;clear DL flag
INCODE1::          mov   bx,0B000h       ;old screen segment <<<<
		  mov   es,bx
		  mov   ax,es:[si]      ;read ascii & attribut from old screen
		  cmp   al,128          ;if code under 128 not change
		  jb    middle1          ;below 128 goto middle directly
		  mov   bx,WORD PTR DispTran       ;get address of table
		  xlat                  ;chang code
untransl:         cmp   al,0D1h
		  je    SHORT upper0    ;go set DL flag
		  cmp   al,0D4h         ;
		  jb    SHORT middle
		  cmp   al,0DBh
		  jb    SHORT upper0    ;go set DL flag
		  cmp   al,0E7h         ;
		  jb    SHORT middle
		  je    SHORT special
		  cmp   al,0EDh
		  ja    SHORT middle       ;more than 0EDh is middle line
		  je    SHORT special           ;Barlee special
		  cmp   al,0ECh
		  jne   SHORT upper1            ;more than and less than goto
		  cmp   cl,0D4h                 ;cl save Old charecter
		  je    SHORT upper1
		  cmp   cl,0D8h
		  je    SHORT  upper1
	   ;       jmp   SHORT special           ;any set special
special:          inc   dl              ;DL=2 Tell Way0=F2 ,Way1= wrong way
upper0:           inc   dl              ;DL=1 tell way0=F1 ,way1=Wrong
INCODE2::
upper1:           mov   bx,0B200h       ;upper segment   <<<<
		  mov   es,bx           ;chang to upper new screen
		  cmp   dh,1            ;compare flag by 1
		  jb    SHORT zero
		  je    SHORT one
		  mov   dh,2            ;set flag=2
		  jmp   SHORT two
middle1:          jmp   middle
zero:             inc   OffsetCount     ;<<<<<<>>>>>>
		  cmp   dl,1            ;test flag = 1? (rigth/wrong)
		  je    SHORT f1        ;Yes DL = F1
		  mov   dh,2
f2_1:             mov   cl,al           ;copy old char
f2_2:   ;          jmp   fillup0         ;go fillup routine
;----------------------------------------------------------------------------
;FILL_UP  is small routine for  fill the character on Upper level
fillup0:        mov     bx,OFFSET Transtable -209   ;backward 209
		xlat                            ;translate to page font
		or      es:[di-2],al        ;
		jmp     SHORT l_quit0


f1:               mov   dh,1
		  cmp   al,0d8h         ;test o oo o
		  jb    f2_1            ;if below D8h to fill up
		  mov   ah,cl           ;transfer flag
		  mov   cl,al           ;copy old char for test when ' comming
	 ;         jmp   filldown0       ;go filldown routine
;-----------------------------------------------------------------------------
;FILL_DOWN  is routine for filling under level character o oo o
filldown0:      sub     al,0D7h         ;convert to 0 1 2 3 or 00 40 80 C0
		ror     al,1
		ror     al,1
		or      es:[di+320-2],al         ;add to screen
		jmp     SHORT l_quit0


one:              mov   dh,2
		  cmp   dl,0            ;0 = E8 E9 EA EB EC
		  jne   SHORT two       ;No goto Wrong way
		  inc   OffsetCount      ;<<<<<<>>>>>>
		  cmp   cl,0D7h         ;check o oo o must use fillup0
		  ja    f2_2
		  sub   al,0E7h         ;convert to 0 1 2 3 4
		  add   es:[di-2],al    ;displacement ------>
		  jmp   l_quit0
;--------------------------
middle:           xor   dh,dh           ;flag = 0
INCODE3::
two:              mov   bx,0B200h       ;segment middle on screen <<<<
		  mov   es,bx           ;copy

OffsetCode1::    cmp     al,20h       ;blank check
		je      IncBlankCount
		mov     BlankCount,0    ;Reset Blank Counter
		  cmp   al,128
		  jb    nonConvert

		and   ah,11110111b    ;block character thai above 127
		cmp     al,9Fh
		ja     nonConvert
		jmp    LineGraphic     ;Hey goto Line graphic

nonConvert:
		and   BYTE PTR es:[di],11000000b          ;mask off - = -----clear upper
convert3:       and   BYTE PTR  es:[di+320],00111111b     ;mask off o oo o   clear lower
		  mov   bx,OFFSET MediamTable
		  xlat
		  mov   es:[di+160],ax  ;move ascii,att to new screen cur_p
		  or    ah,01000b       ;active page 2
INCODE4::          and   ah,11111110b    ;off under line     <<<<
		  mov   es:[di+1],ah    ;copy attribute to upper line
		  inc   di              ;point upper quit
		  inc   di              ;shift column on New screen
       ;           jmp   SHORT l_quit0
;--------------------------
l_quit0:          inc   si              ;shift pointer old screen next column
		  inc   si
	     ;     cmp   si,WORD PTR CurPoint
	     ;     jne   koog
	     ;     call  TransCurpos
koog:             dec   bp
		  jz    SHORT EraseBack ;out_loop
		  jmp   turn_back      ;repeat until 80

EraseBack:        mov   cl,OffsetCount  ;counter
		  or    cl,cl
		  jz    SHORT out_loop  ;test zero erase

eraseBack1:       mov   al,37h        ;blank and normal attrib
		  mov   es:[di+160],ax  ;move ascii,att to new screen cur_p
		  or    ah,01000b       ;active page 2
	     ;      and   ah,11111110b    ;off under line     <<<<
		  mov   es:[di+1],ah    ;copy attribute to upper line
		  and   BYTE PTR  es:[di+320],00111111b     ;mask off o oo o   clear lower
		  and   BYTE PTR es:[di],11000000b          ;mask off - = -----clear upper
		  inc   di              ;point upper quit
		  inc   di              ;shift column on New screen
		  dec   cl
	     ;     dec   OffsetCount
		  jnz   eraseBack1
		  jmp   SHORT out_loop


IncBlankCount:    inc   BlankCount
		  mov   bl,BYTE PTR ScrHardBlkLen            ;Offset Long
		  cmp   BlankCount,bl    ;offset compare
		  jnz   nonConvert

		  inc   OffsetCount
erase:            mov   al,37h        ;blank and normal attrib
		  mov   es:[di+160],ax  ;move ascii,att to new screen cur_p
		  or    ah,01000b       ;active page 2
INCODE51::         and   ah,11111110b    ;off under line     <<<<
		  mov   es:[di+1],ah    ;copy attribute to upper line
		  and   BYTE PTR  es:[di+320],00111111b     ;mask off o oo o   clear lower
		  and   BYTE PTR es:[di],11000000b          ;mask off - = -----clear upper
		  inc   di              ;point upper quit
		  inc   di              ;shift column on New screen
		  dec   OffsetCount
		  jnz   erase
		  mov   BlankCount,0
		  jmp   SHORT l_quit0



out_loop:       ;  cmp   si,di
		;  je    out_loop2
		;  mov   ax,720h         ;value blank
		;  mov   bx,0B400h
		;  mov   es,bx
		;  mov   es:[di],ax      ;clear last line
		;out_loop2:

		mov     ax,cs
		mov     ds,ax
		mov   OffsetCount,0
		  pop   si
		  pop   di
		  pop   bx
		  ret                   ;return to caller

LineGraphic:    push    ax              ;save single byte command
		push    si
		sub     al,80h          ;change to start 0
		xor     ah,ah           ;zero high byte
		sal     ax,1            ;*2 look up
		mov     si,ax           ; put to si for branch
		call    cs:[si+OFFSET LineGraphRoutin]
		pop     si
		pop     ax              ;restore single command
		jmp     convert3
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
		and   BYTE PTR es:[di],11000000b          ;mask off - = -----clear upper
		ret
NonGraph        ENDP

L_refresh2         ENDP


;----------------------------------------------------------------------------
Transtable  DB  1,0,0,6,12,17,22, 15 dup(0),27,28,29,30,31,32,33,34   ; <---- new table
;               0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
MediamTable DB 055,024,025,026,027,028,029,030,031,032,033,034,035,036,037,038
	    DB 039,040,041,042,043,044,045,046,047,048,049,050,051,052,053,054
	    DB 055,056,057,058,059,060,061,062,063,099,100,101,102,103,104,105
	    DB 106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121
	    DB 122,123,124,125,126,127,163,164,165,166,167,168,169,170,171,172
	    DB 173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188
	    DB 189,190,191,227,228,229,230,231,232,233,234,235,236,237,238,239
	    DB 240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

	    DB 208,209,210,211,212,213,214,215,216,217,218,219,223,224,225,226
	    DB 192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
	    DB 220,064,065,066,067,068,069,070,071,072,073,074,075,076,077,078
	    DB 079,080,081,082,083,084,085,086,087,088,089,090,091,092,093,094
	    DB 095,096,097,098,128,129,130,131,132,133,134,135,136,137,138,139
	    DB 140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155
	    DB 156,157,158,159,160,161,162,000,001,002,003,004,005,006,007,008
	    DB 009,010,011,012,013,014,015,016,017,018,019,020,021,022,023,055

;-----------------------------------------------------------------------------
RowStart        DW      0
Shearsor1       PROC    NEAR                    ;this routine for AutoMix
		push    ds                      ;cut out some piece Old screen
		push    di
		push    cs
		pop     ds
		mov     di,RowStart
		call    Shearsor2
	     ;   je      Emply                  ;<------- for appen More time
	     ;   add
Enply:          add     RowStart,160
		cmp     RowStart,0f00h
		jb      NotReset

		mov     RowStart,0
NotReset:       pop     di
		pop     ds
		ret
Shearsor1       ENDP
;------------------
;Shearsor2 copy Old page to New page (only char differance Old,Buffer
;Entry  DI   begin Row
;Retern Zero    Emply
;       Non-Zero

Shearsor2        PROC    NEAR
		  push  ax
		  push  bx
		  push  cx
		  push  dx
		  push  di     ;10
		  push  si     ;8
		  push  ds     ;6
		  push  es     ;4
		  push  bp     ;2
		;  push  cs              ;
		;  pop   ds              ;data segment = code segment

INCODE20::       mov     bx,0B000h       ;OldPage   B000 , b800 <<<<
		mov     es,bx
		mov     cx,80
		mov     bp,di

NextScan:       mov     si,di
		mov     bx,OFFSET ShadowMem
		add     si,bx           ;source ds:si+bx      shadow
		repe    cmpsw           ;destin es:di         screen
		jne     NextScan1
		jmp     Sout_loop
NextScan1:      sub     di,2            ;turn back 1 position
		inc     cx
		mov     bx,di
		mov     ax,bp           ;RowStart
		sub     bx,ax           ;find col
		mov     si,ax           ;
		shl     si,1            ;find row   screen pointer *2
		add     si,bx           ;Row + Col
INCODE21::
Sturn_back:     mov     bx,0B000h       ;old screen segment <<<<
		mov     es,bx
		mov     bx,OFFSET ShadowMem
		mov     ax,es:[di]              ;read ascii & attribut from old screen
		cmp     ds:[di+bx],ax
		je      NextScan        ;cx = bp
		mov     ds:[di+bx],ax              ;copy to shadow

		cmp     al,128          ;if code under 128 not change
		jb      Smiddle         ;below 128 goto middle directly
		mov     bx,WORD PTR DispTran     ;get address of table
		xlat                    ;chang code
INCODE22::
Smiddle:        mov     bx,0B400h       ;segment middle on screen <<<<
		mov     es,bx           ;copy
		cmp     al,128
		jb      SHORT SnonConvert
		and     ah,11110111b    ;block character thai above 127
SnonConvert:    mov     bx,OFFSET MediamTable
		xlat
		mov     es:[si+160],ax  ;move ascii,att to new screen cur_p
		or      ah,01000b       ;active page 2
INCODE23::       and     ah,11111110b    ;off under line            <<<<
		mov     es:[si+1],ah    ;copy attribute to upper line
		and     BYTE PTR  es:[si+320],00111111b     ;mask off o oo o   clear lower
		and     BYTE PTR es:[si],11000000b          ;mask off - = -----clear upper
		inc     si              ;point upper quit
		inc     si              ;shift column on New screen
		inc     di              ;shift pointer old screen next column
		inc     di
		loop    Sturn_back      ;repeat until 80

Sout_loop:      or      ah,ah           ;non-zero
		pop     bp
		pop     es
		pop     ds
		pop     si
		pop     di
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		ret                   ;return to caller


Shearsor2        ENDP


CSEG        ENDS
		END
