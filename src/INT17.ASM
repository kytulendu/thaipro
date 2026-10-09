ifndef MASM
OPTION PROC:PRIVATE
endif

CSEG            SEGMENT PARA PUBLIC 'CODE'
		ASSUME  CS:CSEG, DS:CSEG


		EXTRN   PrinterTran:NEAR                     ;KU TIS
		EXTRN   OneLevelTran:NEAR
		EXTRN   SamDataPrinter:NEAR
		EXTRN   CodePr_convert:NEAR
		EXTRN   Spacing3:NEAR                   ;Line spacing
		EXTRN   Spacing2:NEAR                    ;Line spacing
		EXTRN   Spacing1:NEAR                    ;Line spacing for 3 level
		EXTRN   LockSpacing:NEAR                ;enable/disable line space 3 Lock
		EXTRN   ExtendFlag:NEAR                 ;enable/disable extend head

		EXTRN   Original:NEAR
		EXTRN   PrnHardBlkLen:NEAR
		EXTRN   PrnHardBlkCod:NEAR
		EXTRN   Value_Window:NEAR               ;HexToAscii routine
		EXTRN   ScrSpace:NEAR
		EXTRN   Hex72:NEAR
		EXTRN   Hex216:NEAR
		EXTRN   PrnOneLeTrn:NEAR                ;Prn one lever translation code


		PUBLIC  Old_int17h_vector
		PUBLIC  Old_int17h_offs
		PUBLIC  Old_int17h_seg
		PUBLIC  New_int17h
		PUBLIC  Tis_Tis_PR
		PUBLIC  Tis_Ku_PR
		PUBLIC  Ku_Tis_PR

Old_int17h_vector LABEL DWORD
Old_int17h_offs   DW     ?
Old_int17h_seg    DW     ?

BufSize         EQU     272*3            ;272 old buffer * 3

New_int17h      PROC  NEAR
		sti
		push  bp
		push  bx
		push  cx
		push  dx
		push  di
		push  si
		push  ds
		cmp     ah,50h             ;exist function
		je      ThaiExist

		cmp     BYTE PTR cs:Original,0      ;0 = 1 level, 1 = 3 level
		je      int17CK1Tran
		cmp     ah,00h           ;int17h function 00h
		jnz     int17_Old
		call    int17func0_3
int17Pass::      pop   ds    ;0          ;passive int17h
		pop   si    ;2
		pop   di    ;4
		pop   dx    ;6
		pop   cx    ;8
		pop   bx
		pop   bp
		iret

int17CK1Tran:   push    cs
		pop     ds
		cmp   BYTE PTR cs:PrnOneLeTrn,0
		je    int17_Old
		cmp     al,128
		jb      int17Notconvert
		cmp     BYTE PTR SamDataPrinter,0       ;0= sam, 1= code & printer differance
		je      int17Notconvert
		mov     bx,WORD PTR OneLevelTran
		xlat
int17Notconvert:
int17_Old:      pop   ds    ;0
		pop   si    ;2
		pop   di    ;4
		pop   dx    ;6
		pop   cx    ;8
		pop   bx
		pop   bp
		pushf
		call  cs:Old_int17h_vector
		iret
New_int17h      ENDP

ThaiExist       PROC    NEAR
		MOV     AL,0EEh         ;exist code
	    ;    mov     ah,0EFh         ;computech ID
		JMP     int17Pass
ThaiExist       ENDP
;------------------------------------------------------
;Entry  AH = function number
;       AL = ASCII
;       DX = Device number
;
;Return AH = Printer Status

ESC_on          DB      0       ;0=off

int17func0_3      PROC    NEAR
		push    cs              ;set data segment = code seg
		pop     ds
		mov     LST_num,dx        ;copy device number to Variable
		cmp     ESC_on,1        ;Is ESC on
		jne     check_commd1        ;yes. goto scan ESC table
		call    StoreEsc
		jmp     getStatus

check_commd1:   cmp     al,7fh          ;DEL command
		jne     check_commd2
		call    Fill3Line
		jmp     getStatus

check_commd2:   cmp     al,20h          ;No. check char or command
		jae     check_char
		call    CommandTable    ;below 20h is command.
		jmp     getStatus
check_char:     call    CharProcess     ;no it's character set. Thai Process

getStatus:      mov     ah,02h                 ;
		mov     dx,LST_num             ;
		pushf                          ;return status
		call    cs:Old_int17h_vector   ;
		jmp     func0Quit

CommandTable:   mov     di,CurPosition  ;get pointer
		mov     bp,OFFSET Prt_buf2  ;BASE
		push    ax              ;save single byte command
		xor     ah,ah           ;zero high byte
		sal     ax,1            ;*2 look up
		mov     si,ax           ; put to si for branch
		pop     ax              ;restore single command
		jmp     cs:[si+OFFSET Single_command]
func0Quit::      ret
int17func0_3      ENDP


EscStr_buf      DB      6 dup(0)
EscStr_pos      DW      0

StoreEsc:       mov     bp,OFFSET EscStr_buf    ;start ESC buffer
		mov     si,EscStr_pos           ;get position point to buffer
		mov     ds:[bp+si],al              ;put value of ESC string in buf
		cmp     si,TableSize - 1       ;5 character
		je      SearchEsc
		inc     WORD PTR EscStr_pos     ;increment pointer Esc string
		ret                             ;exit from function0 directry

SearchEsc:      mov     WORD PTR EscStr_pos,0   ;reset Esc string counter
		mov     ESC_on,0                ;turn Esc flag OFF
		mov     bx,0
		mov     si,0                    ;Esc string pointer
		mov     bp,0                    ;Jump table pointer
		mov     di,OFFSET EscStr_buf    ;address of Esc string buffer
ScanContinu:    mov     al,ds:[si+bx]+OFFSET EscStrTable           ;get data from EscTable
		cmp     al,NULL                 ;Null is terminat Esc string
		je      JumpEscTable            ;Yes terminat GO that procedure
		cmp     al,ds:[di+bx]           ;EscTable = EscStr_buf
		jne     Scan3                   ;No. go next Line Esc
		inc     bx                      ;Yes. next char fo string
		jmp     ScanContinu             ;

Scan3:          add     bp,2                    ;jmp table size
		add     si,TableSize            ;next ESC string
		mov     bx,0                    ;reset to first value
		cmp     si,OFFSET UpperLimit     ;out of table
		jb      ScanContinu             ;No. scan table continues
;
;send Esc string back medeim line
;
		mov     di,CurPosition                ;Initial for access printer buffer
		mov     bp,OFFSET Prt_buf2            ;BASE
		mov     BYTE PTR ds:[bp+di-BufSize],00h   ;
		mov     BYTE PTR ds:[bp+di],1Bh       ;insert Esc before send UNknow back
		mov     BYTE PTR ds:[bp+di+BufSize],00h   ;
		inc     WORD PTR CurPosition          ;increment next position


SendBack:       mov     si,OFFSET EscStr_buf
		add     si,bx                   ;adjust start address for send back
		cld                             ;
		mov     cx,TableSize            ;cx=5
		sub     cx,bx                   ;negative counter
SendBack1:      push    cx
		lodsb                           ;mov string to AL
		push    si

		call    int17func0_3            ;re-entrance
		pop     si
		pop     cx
		loop    SendBack1
		ret

JumpEscTable:   mov     di,CurPosition          ;Initial for access printer buffer
		mov     si,bp
		mov     bp,OFFSET Prt_buf2      ;BASE
		jmp     cs:[si]+OFFSET EscJmpTable

;-----------TABLE for ESC String and Address of Procedure-----------
;Scan Table
;
TableSize       EQU     3
NULL            EQU     0
EscStrTable     LABEL   BYTE
	DB 2dh,00,00            ;Esc + '-'  underlineing on/off
	DB 64,00,00             ;Esc + '@'  initialize the printer
	DB 73h,00,00            ;Esc + 's' Half speed=down+null
	DB 60,00,00             ;Esc + '<' Uni-directional One line
	DB 85,00,00             ;Esc + 'U' turn uni-directional printing on or off
	DB 67,00,00             ;Esc + 'C' set page length in lines
	DB 25,00,00             ;Esc + Em  cut sheet feeder control
	DB 56,00,00             ;Esc + '8' disable paper out sensor
	DB 57,00,00             ;Esc + '9' enable paper out sensor
	DB 74,00,00             ;Esc + 'J' perform n/216 inch line feed
	DB 48,00,00             ;Esc + '0'  select 1/8 inch line spacing
	DB 49,00,00             ;Esc + '1'  select 7/12inch line spacing
	DB 50,00,00             ;Esc + '2'  select 1/6 inch line spacing
	DB 51,00,00             ;Esc + '3'  set n/216 inch line spacing
	DB 65,00,00             ;Esc + 'A'  set n/72  inch line spacing
	DB 78,00,00             ;Esc + 'N' set bottom margin
	DB 79,00,00             ;Esc + 'O' cancel bottom margin
	DB 102,0,00             ;Esc + 'f' vertical skip
	DB 108,00,00            ;Esc + 'l' set left margin
	DB 81,00,00             ;Esc + 'Q' set right margin
	DB 116,00,00            ;Esc + 't' select character table
	DB 52,00,00             ;Esc + '4' select italic characters
	DB 53,00,00             ;Esc + '5' cancel italic characters
	DB 54,00,00             ;Esc + '6' expand printable area
	DB 55,00,00             ;Esc + '7' cancel printable area expansion
	DB 82,00,00             ;Esc + 'R' select international character set
	DB 109,00,00            ;Esc + 'm' select special graphic character
	DB 37,00,00             ;Esc + '%' turn user-defined character set on/off
	DB 97,00,00             ;Esc + 'a' select justification mode
	DB 120,00,00            ;Esc + 'x' select NLQ or draft
	DB 107,00,00            ;Esc + 'k' select font family
	DB 33,00,00             ;Esc + '!'  master style command
	DB 80,00,00             ;Esc + 'P'  select 10-pitch character
	DB 77,00,00             ;Esc + 'M'  select 12-pitch characters
	DB 15,00,00             ;Esc + 'SI' select condensed printing
	DB 14,00,00             ;Esc + 'SO' select double-width printing fo one line
	DB 87,00,00             ;Esc + 'W'  turn double-width printing on/off
	DB 69,00,00             ;Esc + 'E'  select emphasized printing
	DB 70,00,00             ;Esc + 'F'  cancel emphasized printing
	DB 71,00,00             ;Esc + 'G'  select double strike printing
	DB 72,00,00             ;Esc + 'H'  cancel double printing
	DB 83,00,00             ;Esc + 'S'  select superscript/subscript mode
	DB 84,00,00             ;Esc + 'T'  cancel superscript/subscript
	DB 62,00,00             ;Esc + '>'  set eighth bit of incoming data
	DB 61,00,00             ;Esc + '='  clear eighth bit of incoming data
	DB 35,00,00             ;Esc + '#'  cancel eighth bit control
	DB 43,00,00             ;Esc + '+'  set n/360 inch line spacing
	DB 36,00,00             ;Esc + '$'  set absolute dot position
	DB 92,00,00             ;Esc + '\'  set relative dot position
	DB 32,00,00             ;Esc + SP   set intercharacter space
	DB 113,00,00            ;Esc + 'q' select character style
	DB 103,00,00            ;Esc + 'g' select 15- pitch characters
	DB 112,00,00            ;Esc + 'p' proportional characters on/off
	DB 119,00,00            ;Esc + 'w' turn double-height printing on/off
	DB 40,45,00             ;Esc + '(-' set scoring style
	DB 114,00,00            ;Esc + 'r' select color printing

UpperLimit       LABEL   BYTE

EscJmpTable     LABEL   BYTE
	DW OFFSET Under_line
	DW OFFSET Initialize    ;Initialzation
	DW OFFSET Down_Null3    ;Printing speed and direction
	DW OFFSET Down_Null2
	DW OFFSET Down_Null3
	DW OFFSET PageLength    ;Paper control
	DW OFFSET Down_Null3
	DW OFFSET Down_Null2    ;Sensor control
	DW OFFSET Down_Null2
	DW OFFSET PerformLF     ;Line feeding
	DW OFFSET SetSpace2_0
	DW OFFSET SetSpace2_1
	DW OFFSET SetSpace2_2
	DW OFFSET SetSpace3_3
	DW OFFSET SetSpace3_A
	DW OFFSET Down_Null3    ;Formatting commands
	DW OFFSET Down_Null2
	DW OFFSET VerticalSkip
	DW OFFSET Down_Null3      ;...Horizontal margins
	DW OFFSET Down_Null3
	DW OFFSET Same3         ;Character set commands
	DW OFFSET Same2
	DW OFFSET Same2
	DW OFFSET Same2
	DW OFFSET Same2
	DW OFFSET Same3
	DW OFFSET Same3
	DW OFFSET Same3
	DW OFFSET Same3         ;Word processing commands
	DW OFFSET Same3         ;Print style commands
	DW OFFSET Same3
	DW OFFSET Same3
	DW OFFSET Same2         ;Print size and character width commands
	DW OFFSET Same2            ;...Character pitch
	DW OFFSET Same2            ;...Character width
	DW OFFSET Same2
	DW OFFSET Bug123  ;Same3         ;ESC+'W' double on/off
	DW OFFSET Same2         ;Print enhancement commands
	DW OFFSET Same2
	DW OFFSET Same2
	DW OFFSET Same2
	DW OFFSET Same3
	DW OFFSET Same2
	DW OFFSET Down_Null2    ;LQ PRINTER
	DW OFFSET Down_Null2    ;Control of MSB
	DW OFFSET Down_Null2
	DW OFFSET SetSpace3_P   ;Line feeding
	DW OFFSET Down_Null4    ;Print head position
	DW OFFSET Down_Null4
	DW OFFSET Same3         ;Wordprocessing commands
	DW OFFSET Same3         ;Print style command
	DW OFFSET Same2         ;Print size and character width commands
	DW OFFSET Same3
	DW OFFSET Same3
	DW OFFSET Mid_Null3     ;Print enhancement commands
	DW OFFSET Same3         ;Color commands


Same2:          mov     al,1Bh                            ;Esc code
		mov     si,OFFSET EscStr_buf
		mov     ah,[si+bx-1]                    ;second code
		mov     WORD PTR ds:[bp+di-BufSize],ax       ;
		mov     WORD PTR ds:[bp+di],ax           ;
		mov     WORD PTR ds:[bp+di+BufSize],ax        ;
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		call    SendBack
		ret

Same3:          mov     al,1Bh                            ;first  Esc code
		mov     si,OFFSET EscStr_buf
		mov     ah,[si+bx-1]                      ;second code
		mov     dl,[si+bx]                      ;third  code
		mov     WORD PTR ds:[bp+di-BufSize],ax        ;
		mov     WORD PTR ds:[bp+di],ax            ;
		mov     WORD PTR ds:[bp+di+BufSize],ax        ;

		mov     BYTE PTR ds:[bp+di-BufSize+2],dl      ;
		mov     BYTE PTR ds:[bp+di+2],dl          ;
		mov     BYTE PTR ds:[bp+di+BufSize+2],dl      ;
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     bx
		call    SendBack
		ret


Under_line:     mov     al,1Bh                            ;first  Esc code
		mov     si,OFFSET EscStr_buf
		mov     ah,[si+bx-1]                      ;second code
		mov     dl,[si+bx]                      ;third  code
		mov     UnderFlag,dl                  ;on/off flag
		mov     WORD PTR ds:[bp+di-BufSize],00h       ;
		mov     WORD PTR ds:[bp+di],ax            ;
		mov     WORD PTR ds:[bp+di+BufSize],00h       ;

		mov     BYTE PTR ds:[bp+di-BufSize+2],00h     ;
		mov     BYTE PTR ds:[bp+di+2],dl          ;
		mov     BYTE PTR ds:[bp+di+BufSize+2],00h     ;
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     bx
		call    SendBack
		ret

Hex0            DB      8         ;1/8
Hex1            DB      72        ;7/72
Hex2            DB      6         ;1/6
Ses1            DB      1         ;for  1/8, 1/6
Ses7            DB      7         ;for  7/72
SetSpace2_0     PROC    NEAR
		cmp     BYTE PTR LockSpacing,0          ;test spacing lock
		jnz      Space2Lock                      ;can not change
		call    SetSpace2
		mov     bx,OFFSET Hex0
		mov     cx,OFFSET ScrSpace+8
		call    Value_Window
		mov     bx,OFFSET Ses1
		mov     cx,OFFSET ScrSpace+4
		call    Value_Window
		ret
SetSpace2_0     ENDP

SetSpace2_1     PROC    NEAR
		cmp     BYTE PTR LockSpacing,0          ;test spacing lock
		jnz      Space2Lock                      ;can not change
		call    SetSpace2
		mov     bx,OFFSET Hex1
		mov     cx,OFFSET ScrSpace+8
		call    Value_Window
		mov     bx,OFFSET Ses7
		mov     cx,OFFSET ScrSpace+4
		call    Value_Window
		ret
SetSpace2_1     ENDP

SetSpace2_2     PROC    NEAR
		cmp     BYTE PTR LockSpacing,0          ;test spacing lock
		jnz      Space2Lock                      ;can not change
		call    SetSpace2
		mov     bx,OFFSET Hex2
		mov     cx,OFFSET ScrSpace+8
		call    Value_Window
		mov     bx,OFFSET Ses1
		mov     cx,OFFSET ScrSpace+4
		call    Value_Window
		ret
SetSpace2_2     ENDP

SetSpace2       PROC    NEAR
		mov     si,OFFSET EscStr_buf
		mov     al,[si+bx-1]          ;set underline flag
		mov     ah,0                  ;NULL
		mov     bp,OFFSET Spacing3+1  ;across ESC
		xor     ah,ah                 ;Esc x NULL ==linespacig
		mov     ds:[bp],ax               ;send spacing code to String
Space2Lock::     call    SendBack
		ret
SetSpace2       ENDP

;  bx,OFFSET Spacing3     Point to VALUE
;  cx,OFFSET ScrSpace +4  Point to Window


SetSpace3_3     PROC    NEAR
		cmp     BYTE PTR LockSpacing,0          ;test spacing lock
		jnz      Space3Lock                      ;can not change
		call    SetSpace3
		mov     bx,OFFSET Hex216
		mov     cx,OFFSET ScrSpace+8
		call    Value_Window
		mov     bx,OFFSET Spacing3+2
		mov     cx,OFFSET ScrSpace+4
		call    Value_Window
		ret
SetSpace3_3     ENDP

SetSpace3_A     PROC    NEAR
		cmp     BYTE PTR LockSpacing,0          ;test spacing lock
		jnz      Space3Lock                      ;can not change
		call    SetSpace3
		mov     bx,OFFSET Hex72
		mov     cx,OFFSET ScrSpace+8
		call    Value_Window
		mov     bx,OFFSET Spacing3+2
		mov     cx,OFFSET ScrSpace+4
		call    Value_Window
		ret
SetSpace3_A     ENDP

Hex360          DB      160        ;can't fit in 0-255
SetSpace3_P     PROC    NEAR
		cmp     BYTE PTR LockSpacing,0          ;test spacing lock
		jnz      Space3Lock                      ;can not change
		cmp     BYTE PTR Hex216,180       ;TEST for 24 pin
		jnz     Space3Lock                ;can not change
		call    SetSpace3
		mov     bx,OFFSET Hex360
		mov     cx,OFFSET ScrSpace+8
		call    Value_Window

		mov     bx,OFFSET ScrSpace+8
		mov     [bx],BYTE PTR '3'         ;[3]60

		mov     bx,OFFSET Spacing3+2
		mov     cx,OFFSET ScrSpace+4
		call    Value_Window
		ret
SetSpace3_P     ENDP


SetSpace3       PROC    NEAR
		mov     si,OFFSET EscStr_buf
		mov     ax,[si+bx-1]          ;set underline flag
		mov     bp,OFFSET Spacing3+1
		mov     ds:[bp],ax               ;send spacing code to String
Space3Lock::     inc     bx
		call    SendBack
		ret
SetSpace3       ENDP

Initialize      PROC    NEAR
		mov     UnderFlag,0             ;clear underline flag
		call    Up_Null2
		ret
Initialize      ENDP

PageLength:     mov     si,OFFSET EscStr_buf
		cmp     BYTE PTR [si+bx],00
		je      PageLength1
		call    Down_Null3
		ret
PageLength1:    call    Down_Null4
		ret

VerticalSkip:   call    Down_Null4
		ret

PerformLF: call   Down_Null3_1
		push    bx
		call    Print_out
		pop     bx
		call    SendBack
		ret

;AH,AL Data Sequense**** Ex mov ax,401bh  ****----------------------------
Down_Null2:
		mov     al,1Bh                            ;Esc code
		mov     si,OFFSET EscStr_buf
		mov     ah,[si+bx-1]                    ;second code
		mov     WORD PTR ds:[bp+di-BufSize],00h       ;
		mov     WORD PTR ds:[bp+di],00h           ;
		mov     WORD PTR ds:[bp+di+BufSize],ax        ;
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		call    SendBack
		ret

;AH,AL,DL Data sequense*** Ex mov ax,401bh mov dl,xx ****-----------------
Down_Null3:
		mov     al,1Bh                            ;first  Esc code
		mov     si,OFFSET EscStr_buf
		mov     ah,[si+bx-1]                      ;second code
		mov     dl,[si+bx]                      ;third  code
		mov     WORD PTR ds:[bp+di-BufSize],00h       ;
		mov     WORD PTR ds:[bp+di],00h           ;
		mov     WORD PTR ds:[bp+di+BufSize],ax        ;
		mov     BYTE PTR ds:[bp+di-BufSize+2],00h     ;
		mov     BYTE PTR ds:[bp+di+2],00h         ;
		mov     BYTE PTR ds:[bp+di+BufSize+2],dl      ;
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     bx                              ;over ride 1 byte ESC n n x x
		call    SendBack                        ;                 >   > >
		ret
Down_Null3_1:
		mov     al,1Bh                            ;first  Esc code
		mov     si,OFFSET EscStr_buf
		mov     ah,[si+bx-1]                      ;second code
		mov     dl,[si+bx]                      ;third  code
		mov     WORD PTR ds:[bp+di-BufSize],00h       ;
		mov     WORD PTR ds:[bp+di],00h           ;
		mov     WORD PTR ds:[bp+di+BufSize],ax        ;
		mov     BYTE PTR ds:[bp+di-BufSize+2],00h     ;
		mov     BYTE PTR ds:[bp+di+2],00h         ;
		mov     BYTE PTR ds:[bp+di+BufSize+2],dl      ;
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     bx
		ret
Down_Null4:
		mov     al,1Bh                            ;first  Esc code
		mov     si,OFFSET EscStr_buf
		mov     ah,[si+bx-3]                      ;second code
		mov     dx,[si+bx-2]                      ;third  code
		mov     WORD PTR ds:[bp+di-BufSize],00h       ;
		mov     WORD PTR ds:[bp+di],00h           ;
		mov     WORD PTR ds:[bp+di+BufSize],ax        ;
		mov     WORD PTR ds:[bp+di-BufSize+2],00h     ;
		mov     WORD PTR ds:[bp+di+2],00h         ;
		mov     WORD PTR ds:[bp+di+BufSize+2],dx      ;
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     bx
		inc     bx
		call    SendBack
		ret

Up_Null2:       mov     al,1Bh                            ;Esc code
		mov     si,OFFSET EscStr_buf
		mov     ah,[si+bx-1]                    ;
		mov     WORD PTR ds:[bp+di-BufSize],ax        ;
		mov     WORD PTR ds:[bp+di],00h           ;
		mov     WORD PTR ds:[bp+di+BufSize],00h       ;
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		call    SendBack
		ret

Bug123:         mov     si,OFFSET EscStr_buf
		and     BYTE PTR [si+bx],00000001b                        ;third  code
		call    Same3
		ret

Mid_Null3:
		mov     al,1Bh                            ;first  Esc code
		mov     si,OFFSET EscStr_buf
		mov     ah,[si+bx-1]                      ;second code
		mov     dl,[si+bx]                      ;third  code
		mov     WORD PTR ds:[bp+di-BufSize],00h       ;
		mov     WORD PTR ds:[bp+di],ax            ;
		mov     WORD PTR ds:[bp+di+BufSize],00h       ;

		mov     BYTE PTR ds:[bp+di-BufSize+2],00h     ;
		mov     BYTE PTR ds:[bp+di+2],dl          ;
		mov     BYTE PTR ds:[bp+di+BufSize+2],00h     ;
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     WORD PTR CurPosition              ;increment next posi
		inc     bx
		call    SendBack
		ret



;-------------------------------------------

Single_command  LABEL   WORD
comm00           DW      OFFSET Fill3Line
comm01           DW      OFFSET Fill3Line
comm02           DW      OFFSET Fill3Line
comm03           DW      OFFSET Fill3Line
comm04           DW      OFFSET Fill3Line
comm05           DW      OFFSET Fill3Line
comm06           DW      OFFSET Fill3Line
comm07           DW      OFFSET Bell            ;sound beeper
comm08           DW      OFFSET Fill3Line       ;back space
comm09           DW      OFFSET Fill3Line       ;tab horizontally
comm0A           DW      OFFSET Line_feed
comm0B           DW      OFFSET Vertical_tab
comm0C           DW      OFFSET Form_feed       ;form feed
comm0D           DW      OFFSET CarryReturn     ;carruage return
comm0E           DW      OFFSET Fill3Line
comm0F           DW      OFFSET Fill3Line
comm10           DW      OFFSET func0Quit
comm11           DW      OFFSET Down_Null1      ;select printer
comm12           DW      OFFSET Fill3Line
comm13           DW      OFFSET Down_Null1      ;deselect printer
comm14           DW      OFFSET Fill3Line
comm15           DW      OFFSET func0Quit
comm16           DW      OFFSET func0Quit
comm17           DW      OFFSET func0Quit
comm18           DW      OFFSET Fill3Line       ;cancel line
comm19           DW      OFFSET func0Quit
comm1A           DW      OFFSET func0Quit
comm1B           DW      OFFSET Escap
comm1C           DW      OFFSET func0Quit
comm1D           DW      OFFSET func0Quit
comm1E           DW      OFFSET func0Quit
comm1F           DW      OFFSET func0Quit



Bell:           mov   BYTE PTR ds:[bp+di],07            ;belling
		mov   BYTE PTR ds:[bp+di+BufSize],00        ;null
		mov   BYTE PTR ds:[bp+di-BufSize],00        ;null
		inc   WORD PTR CurPosition              ;increment next posi
		ret
Down_Null1:     mov   BYTE PTR ds:[bp+di-BufSize],00        ;up
		mov   BYTE PTR ds:[bp+di],00            ;mid
		mov   BYTE PTR ds:[bp+di+BufSize],al        ;down
		inc   WORD PTR CurPosition
		ret
Fill3Line:      mov   BYTE PTR ds:[bp+di],al
		mov   BYTE PTR ds:[bp+di+BufSize],al        ;fill al 3 line
		mov   BYTE PTR ds:[bp+di-BufSize],al
		inc   WORD PTR CurPosition
		ret
Line_feed:      cmp   cs:CurPosition,0              ;0A 0A after no-operate IUS bug
		jz    OutLineSpace
		mov   BYTE PTR ds:[bp+di],LF      ;put LF in buffer
		mov   BYTE PTR ds:[bp+di+BufSize],LF  ; 3 line
		mov   BYTE PTR ds:[bp+di-BufSize],LF
		call    Print_out
OutLineSpace:   ret                             ;0A 0A no-operated

Vertical_tab:   mov   WORD PTR ds:[bp+di-BufSize],0a00h        ;null
		mov   WORD PTR ds:[bp+di],0a00h            ;null
		mov   WORD PTR ds:[bp+di+BufSize],0a0bh        ;vertical tab
		call    Print_out
		ret

Form_feed:      mov   WORD PTR ds:[bp+di-BufSize],0a00h        ;null
		mov   WORD PTR ds:[bp+di],0a00h            ;null
		mov   WORD PTR ds:[bp+di+BufSize],0a0ch        ;form feed
		call  Print_out
		ret

CarryReturn:    call  Fill3Line         ;back to Left magine like LF, must be reset
		mov   OffsetCount,0     ;reset Offset count up
		ret

Escap:          mov     ESC_on,1        ;set flag ON
		ret

;---------------------------------------------------------------------------
; come with AL =char 20 to 255
;----------------------------------------------------------------------------

brigdFlag         DB      2               ;leftmost or begin line ;set flag= 2
sub0Way           DB      ?
oldChar           DB      ?
BlankCount        DB    0
OffsetCount       DB   0

mixtable          DB    092h,093h,094h,095h,092h       ;mix TIS table
		  DB    0d2h,0d2h,0d2h,0d2h,0d2h  ;use d2h:space for check
		  DB    0d3h,0d3h,0d3h,0d3h,0d3h  ;use d3 :when error happend
		  DB    096h,097h,098h,099h,09ah
		  DB    09bh,09ch,09dh,09eh,09bh
		  DB    0dbh,0dch,0ddh,0deh,0dbh
		  DB    0fbh,0fch,0fdh,0feh,0fbh


Tis_Tis_PR        DB    128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
		  DB    144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
		  DB    160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
		  DB    176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
		  DB    192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
		  DB    208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
		  DB    224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
		  DB    240,241,242,243,244,245,246,247,248,249,09fh,251,252,253,254,255


Tis_Ku_PR         DB    080h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh
		  DB    09ch,09dh,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh,0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0D0h
		  DB    0A0h,0A1h,0A2h,09Ah,0A3h,09Bh,0A4h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh
		  DB    0AEh,0AFh,0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh
		  DB    0BEh,0BFh,0C0h,0C1h,0C2h,0C3h,0CDh,0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0D6h
		  DB    0CCh,0DDh,0CEh,0CFh,0D9h,0DAh,0DBh,0DCh,0D7h,0D8h,02Eh,0F7h,0F8h,0F9h,0FAh,042h
		  DB    0D0h,0D1h,0D2h,0D3h,0D4h,0CEh,0D5h,0DFh,0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,09eh,090h
		  DB    090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,0d6h,0FBh,0FCh,0FDh,0FEh,0FFh

Ku_Tis_PR         DB    080h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh
		  DB    0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0A3h,0A5h,090h,091h,0EEh,09Fh
		  DB    0A0h,0A1h,0A2h,0A4h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh,0B0h,0B1h
		  DB    0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh,0C0h,0C1h
		  DB    0C2h,0C3h,0C4h,0C5h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0D0h,0C6h,0D2h,0D3h
		  DB    0E0h,0E1h,0E2h,0E3h,0E4h,0E6h,0CFh,0D8h,0D9h,0D4h,0D5h,0D6h,0D7h,0D1h,0EDh,0E7h
		  DB    0E8h,0E9h,0EAh,0EBh,0ECh,0DAh,092h,093h,094h,095h,092h,093h,094h,095h,096h,097h
		  DB    098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,0DBh,0DCh,0DDh,0DEh,0FBh,0FCh,0FDh,0FEh,0FFh


CharProcess     PROC    NEAR
		push  cs              ;
		pop   ds              ;data segment = code segment
		mov   sub0Way,0h       ;clear DL flag
		mov   di,CurPosition  ;get pointer
		mov   bp,OFFSET Prt_buf2  ;BASE
		cmp   al,128          ;if code under 128 not change
		jb    mediam0          ;below 128 goto mediam directly
		mov   bx,WORD PTR PrinterTran       ;get address of table
		xlat                       ;chang code
untransl:       cmp   al,0D1h
		je    SHORT upper0    ;go set DL flag
		cmp   al,0D4h         ;
		jb    SHORT mediam0
		cmp   al,0DBh
		jb    SHORT upper0    ;go set DL flag
		cmp   al,0E7h         ;
		jb    SHORT mediam0
		je    SHORT special
		cmp   al,0EDh
		ja    SHORT mediam0       ;more than 0EDh is mediam line
		je    SHORT special           ;Barlee special
		cmp   al,0ECh
		jne   SHORT upper1            ;more than and less than goto
		cmp   oldChar,0D4h                 ;oldChar save Old charecter
		je    SHORT upper1
		cmp   oldChar,0D8h
		je    SHORT  upper1
		jmp   SHORT special           ;any set special
mediam0:        jmp   SHORT mediam
oneConect:      jmp   one

special:        inc   sub0Way              ;DL=2 Tell Way0=F2 ,Way1= wrong way
upper0:         inc   sub0Way              ;DL=1 tell way0=F1 ,way1=Wrong
upper1:         cmp   brigdFlag,1            ;compare flag by 1
		jb    SHORT zero
		je    SHORT oneConect
		mov   brigdFlag,2            ;set flag=2
		jmp   SHORT two

;--------------- must move Here for jmp short instructions--------------
IncBlankCount:    inc   BlankCount
		  mov   bl,BYTE PTR PrnHardBlkLen
		  cmp   BlankCount,bl    ;offset compare
		  jnz   nonConvert

		  inc   OffsetCount
erase:            mov   al,20h
		  call  not_convert3
		  dec   OffsetCount
		  jnz   erase
		  mov   BlankCount,0
		  ret

zero:           inc   OffsetCount
		cmp   sub0Way,1            ;test flag = 1? (rigth/wrong)
		je    SHORT f1        ;Yes DL = F1
f2:             mov   brigdFlag,2
f2_1:           mov   oldChar,al           ;copy old char
f2_2:           mov     bx,WORD PTR CodePr_convert
		xlat
		mov   ds:[bp+di-BufSize-1],al   ;go fillup routine <<CHANGE
		jmp   SHORT charQuit

f1:             mov   brigdFlag,1
		cmp   al,0d8h         ;test o oo o
		jb    SHORT f2_1            ;if below D8h to fill up
		mov   oldChar,al           ;copy old char for test when ' comming
		mov     bx,WORD PTR CodePr_convert
		xlat
		mov   ds:[bp+di+BufSize-1],al     ;go filldown routine <<CHANGE
		jmp   SHORT charQuit
;--------------------------
mediam:         mov   brigdFlag,0     ;flag = 0
two:      ;      cmp     al,0A0h         ;hard blank for setup offset
	  ;      je      SetupOffset

OffsetCode1:    cmp     al,BYTE PTR PrnHardBlkCod       ;hard bank check
		je      IncBlankCount
		mov     BlankCount,0    ;Reset Blank Counter

nonConvert:
		cmp     al,128
		jb      not_convert3
		cmp     al,9fh          ;compare line graph double upper limit
		ja      CK_extend
		cmp     al,96h          ;compare line graph double lower limit
		jae     LineDoubleConect
		cmp     al,8ah          ;compare linegraphic single upper limit
		ja      CK_extend
		jmp    LineGraphic      ;Hey goto Line graphic

CK_extend:      cmp     BYTE PTR ExtendFlag,0   ;non head-extend ?
		jz      NotExtend               ;yes
		cmp     al,0E2h                 ;sara "o"
		jb      NotExtend
		cmp     al,0E4h                 ;sara "i"
		ja      NotExtend
		jmp     ExtendHead
NotExtend:      mov     bx,WORD PTR CodePr_convert      ;convert to printer code
		xlat
not_convert3:
		mov   BYTE PTR ds:[bp+di+BufSize],20h  ;up and down is blank
		mov   BYTE PTR ds:[bp+di-BufSize],20h
Next:           mov   ds:[bp+di],al         ;move ascii,att to new screen cur_p <<CHANGE
		inc   WORD PTR CurPosition         ; increment point
charQuit:       cmp   WORD PTR CurPosition, BufSize    ;out of buffer
		jne   not_Print_out
		call  Print_out
not_Print_out:  ret                   ;return to main
LineDoubleConect: jmp   LineDouble

one:            mov   brigdFlag,2
		cmp   sub0Way,0            ;0 = E8 E9 EA EB EC
		jne   SHORT two       ;No goto Wrong way
		inc   OffsetCount       ;count up the offset
		mov   ah,oldChar      ;copy old char to register AH
		cmp   ah,0D7h         ;check o oo o must use fillup0
		ja    not_mix

		sub   al,0E8h          ;find offset 0 1 2 3 4
		sub   ah,0D1h         ;find segment 0 1 2 3 4 5 6

		mov   cl,ah
		shl   ah,1            ;
		shl   ah,1            ; *5
		add   cl,ah           ;
		mov   bx,OFFSET mixtable     ;address of mix character
		xor   ch,ch
		add   bx,cx           ;base + start row table
		xlat                  ;get ASCII of printer
not_mix:        jmp   f2_2            ;fill up line




LineGraphic:    push    ax              ;save single byte command
		sub     al,80h          ;change to start 0
		xor     ah,ah           ;zero high byte
		sal     ax,1            ;*2 look up
		mov     si,ax           ; put to si for branch
		mov     al,84h          ; up down strike "|"
		mov     bx,WORD PTR CodePr_convert
		xlat
		call    cs:[si+OFFSET LineGraphRoutin]
		pop     ax              ;restore single command
		mov     bx,WORD PTR CodePr_convert
		xlat
		jmp     Next
LineGraphRoutin LABEL   WORD
char80          DW      OFFSET UnderGraph      ;
char81          DW      OFFSET UnderGraph      ;
char82          DW      OFFSET UpperGraph      ;
char83          DW      OFFSET UpperGraph      ;
char84          DW      OFFSET DoubleGraph     ;
char85          DW      OFFSET NonGraph        ;
char86          DW      OFFSET DoubleGraph     ;
char87          DW      OFFSET DoubleGraph     ;
char88          DW      OFFSET UpperGraph      ;
char89          DW      OFFSET UnderGraph      ;
char8A          DW      OFFSET DoubleGraph     ;

Double_SingleL LABEL   BYTE
		DB      80h,81h,82h,83h,85h,86h,87h,88h,89h,8Ah

LineDouble:     sub     al,96h          ;change to start 0
		mov     bx,OFFSET Double_SingleL
		xlat
		jmp     LineGraphic


UnderGraph      PROC    NEAR
		mov   BYTE PTR ds:[bp+di+BufSize],al  ;up and down is blank
		mov   BYTE PTR ds:[bp+di-BufSize],20h
		ret
UnderGraph      ENDP

UpperGraph      PROC    NEAR
		mov   BYTE PTR ds:[bp+di-BufSize],al
		mov   BYTE PTR ds:[bp+di+BufSize],20h  ;downis blank
		ret
UpperGraph      ENDP

DoubleGraph     PROC    NEAR
		mov   BYTE PTR ds:[bp+di+BufSize],al   ;up and down is sticke
		mov   BYTE PTR ds:[bp+di-BufSize],al
		ret
DoubleGraph     ENDP

NonGraph        PROC    NEAR
		mov   BYTE PTR ds:[bp+di+BufSize],20h  ;up and down is blank
		mov   BYTE PTR ds:[bp+di-BufSize],20h
		RET
NonGraph        ENDP

HeadTable       DB      90h,91h,0EEh
ExtendHead:     sub     al,0E2h
		mov     bx,OFFSET HeadTable
		xlat
		mov     bx,WORD PTR CodePr_convert
		xlat
		mov   BYTE PTR ds:[bp+di-BufSize],al
		mov   BYTE PTR ds:[bp+di+BufSize],20h  ;down is blank
		mov     al,9Fh
		mov     bx,WORD PTR CodePr_convert
		xlat
		jmp     Next

CharProcess     ENDP

CurPosition     DW      0               ;printer buffer pointer for refferance
MESSEG          DB      'PRINT BUFFER'
Prt_buf1        DB      BufSize dup(20h)      ;printer buffer BufSize character.
Prt_buf2        DB      BufSize dup(20h)      ; for condence
Prt_buf3        DB      BufSize dup(20h)


LST_out         PROC    NEAR
		pushf
		call  cs:Old_int17h_vector
		ret
LST_out         ENDP

Print_out       PROC    NEAR
		mov     bx,OFFSET Spacing1
		call    Line_space
		mov     si,OFFSET Prt_buf1
		call    Out_line

		call    UnderLineCtrl
		mov     bx,OFFSET Spacing2
		call    Line_space
		mov     si,OFFSET Prt_buf2
		call    Out_line

		mov     bx,OFFSET TurnOffUnder
		call    Line_space
		mov     bx,OFFSET Spacing3
		call    Line_space
		mov     si,OFFSET Prt_buf3
		call    Out_line
		mov     WORD PTR CurPosition,0           ;reset Current Position Buf
		mov     OffsetCount,0                 ;reset Offset count up
		mov     al,20h                  ;blank
		mov     cx,BufSize * 3              ;line buffer *3
		mov     di,OFFSET Prt_buf1
		push    es
		push    cs
		pop     es
		rep     stosb                   ;clear line buffer
		pop     es
		ret
Print_out       ENDP


;----------------------------------------
;Entry  SI      = buffer address long 272 byte
;       LST_num = device number puted in DX when call int17h f0
;Return Non
;Destroy ax,bx,cx,dx,si

LF              EQU     0Ah                     ;line feed code perfrom printed out
CR              EQU     0Dh
LST_num         DW      0                       ;priter number 0 defualt

Out_line        PROC    NEAR
		mov     dx,LST_num
		mov     cx,BufSize          ;counter for protect infinity loop
     ;           mov     bx,WORD PTR CodePr_convert
Out_li_data:    mov     al,ds:[si]                 ;get data form buffer
		inc     si                      ;increment buffer variable
     ;           cmp     al,128
     ;           jb      not_convert
     ;           xlat                            ;convert code
not_convert:    xor     ah,ah                   ;function 00h
		push    ax
		pushf                           ;for iret return
		call  cs:Old_int17h_vector      ;call old int17h
		pop     ax
		cmp     al,LF                   ;test Line Feed
		je      Out_lineQ               ;Yes. Quit
		loop    Out_li_data                ;maximun loop = 272
Out_lineQ:      ret
Out_line        ENDP

;-------------------------------------
;Entry  BX = Table of ESC line feed code 3 byte
;
;Destroy cx,dx,ax,bx

TurnOffUnder    DB      1Bh,2Dh,00h
TurnOnUnder     DB      1Bh,2Dh,01h

Line_space      PROC    NEAR
		mov     cx,3            ;set counter 3 byte
		mov     dx,LST_num      ;set device number
Line_sp_data:   mov     al,[bx]         ;string code
		inc     bx              ;next code
		mov     ah,0            ;function 0h int17h
		pushf
		call    cs:Old_int17h_vector    ;call old int17h func 0
		loop    Line_sp_data
		ret
Line_space      ENDP

UnderFlag       DB      0               ;0 = off

UnderLineCtrl   PROC    NEAR
		mov     bx,OFFSET TurnOffUnder
		cmp     UnderFlag,0
		je      underoff
		mov     bx,OFFSET TurnOnUnder
underoff:       call    Line_space
		ret
UnderLineCtrl   ENDP



CSEG        ENDS
		END
