OPTION PROC:PRIVATE


CSEG            SEGMENT PARA PUBLIC 'CODE'
		ASSUME  CS:CSEG, DS:CSEG

		EXTRN   OldPage:NEAR
		EXTRN   Setmode:NEAR
		EXTRN   Active:NEAR
		EXTRN   MANEE1:NEAR, CHOID1:NEAR
		EXTRN   KU_TIS:NEAR, TableTIS:NEAR
		EXTRN   TIS_KU:NEAR
		EXTRN   SCT_TIS:NEAR
		EXTRN   TIS_SCT:NEAR
		EXTRN   CursorLevel:NEAR, EnglishMode:NEAR, NewVisit:NEAR

		EXTRN   Int10func2_2:NEAR, Int10func2:NEAR
		EXTRN   Int10func3_2:NEAR
		EXTRN   Int10func6_2:NEAR
		EXTRN   Int10func7_2:NEAR
		EXTRN   Int10func8_2:NEAR
		EXTRN   Int10func9_2:NEAR
		EXTRN   Int10funcA_2:NEAR
		EXTRN   Int10funcE_2:NEAR
		EXTRN    Int10func0:NEAR
		EXTRN    Int10func1:NEAR
		EXTRN    VideoReturn:NEAR

		EXTRN   L_refresh1:NEAR, Shearsor1:NEAR
		EXTRN   Int10funcE:NEAR, OldVDOReturn:NEAR
		EXTRN   Old_int17h_vector:NEAR

		EXTRN   IndexPort:NEAR
		EXTRN   Tis_Tis_PR:NEAR
		EXTRN   Tis_Ku_PR:NEAR
		EXTRN   Ku_Tis_PR:NEAR
		EXTRN   TimeRecode:NEAR

		EXTRN   OffsetCode1:NEAR
		EXTRN   OffsetCode2:NEAR

		EXTRN   New_int08h:NEAR
		EXTRN   Old_int08h_offs:NEAR, Old_int08h_seg:NEAR
		EXTRN   New_int09h:NEAR
		EXTRN   Old_int09h_offs:NEAR, Old_int09h_seg:NEAR
		EXTRN   New_int10h:NEAR
		EXTRN   Old_int10h_offs:NEAR, Old_int10h_seg:NEAR
		EXTRN   New_int17h:NEAR
		EXTRN   Old_int17h_offs:NEAR, Old_int17h_seg:NEAR
		EXTRN   New_int6fh:NEAR
		EXTRN   Old_int6fh_offs:NEAR, Old_int6fh_seg:NEAR
		EXTRN   EGAfont1:NEAR

		PUBLIC  NumPort1
		PUBLIC  NumPort2
		PUBLIC  NumPort3
		PUBLIC  Sound
		PUBLIC  Menu
		PUBLIC  RefrOnOff
		PUBLIC  MenuRefresh
		PUBLIC  ThaiEngStatus1
		PUBLIC  ThaiEngStatus2
		PUBLIC  SaveWindow
		PUBLIC  ShadowMem
		PUBLIC  COLOR1
		PUBLIC  COLOR2
		PUBLIC  COLOR3
		PUBLIC  COLOR4
		PUBLIC  COLOR5
		PUBLIC  COLOR6
		PUBLIC  COLOR7
		PUBLIC  COLOR8
		PUBLIC  COLOR9
		PUBLIC  COLOR10
		PUBLIC  INCODE24
		PUBLIC  INCODE25


		PUBLIC  RegionSum               ;FOR switch
		PUBLIC  BaseAdd
		PUBLIC  MaskAllow
		PUBLIC  OffsetAdd
		PUBLIC  work1

		PUBLIC  ScrSpace
		PUBLIC  StrSpaceUp
		PUBLIC  StrSpaceDown

		PUBLIC  Value_Window
		PUBLIC  StrScrHB
		PUBLIC  StrScrLen
		PUBLIC  StrPrnHB
		PUBLIC  StrPrnLen

		PUBLIC  ScrSpeed

		PUBLIC  LockReturn
		PUBLIC  Trademark

		PUBLIC  HeaderArea
		PUBLIC  PSP
		PUBLIC  BarStatus
		PUBLIC  CornerPos

;************
		PUBLIC   DispTran
		PUBLIC   TimerRun
		PUBLIC   ScrHardBlkCod
		PUBLIC   ScrHardBlkLen
		PUBLIC   PrnHardBlkCod
		PUBLIC   PrnHardBlkLen

		PUBLIC   SpeedVAR
		PUBLIC   PortVAR
		PUBLIC   PrnfVAR

		PUBLIC   ETflag

		PUBLIC   Hot_Key
		PUBLIC   Ctrl_key
		PUBLIC   Ctrl_keyTemp
		PUBLIC   HotkeyLebel


		PUBLIC   Lang_key
		PUBLIC   KB_layout
		PUBLIC   KbTran
		PUBLIC   int10Table
		PUBLIC   PrinterTran                      ;KU TIS
		PUBLIC   OneLevelTran
		PUBLIC   SamDataPrinter
		PUBLIC   CodePr_convert
		PUBLIC   Spacing3                    ;Line spacing
		PUBLIC   Spacing2                    ;Line spacing
		PUBLIC   Spacing1                    ;Line spacing for 3 level
		PUBLIC   LockSpacing                 ;Lock line spacing 3
		PUBLIC   ExtendFlag                  ;extend head
		PUBLIC   PrnOneLeTrn                 ;Prn one lever translation code
		PUBLIC   Hex72
		PUBLIC   Hex216

		PUBLIC   Original
		PUBLIC   Code8line
		PUBLIC   Code8line1

		PUBLIC   CurrMode1
		PUBLIC   CurMediaCode
		PUBLIC   CurStatus
		PUBLIC   Typ_chk
		PUBLIC   CurLayOut
		PUBLIC   CurLangKey
		PUBLIC   CurPrnCode
		PUBLIC   CurPrnLev
		PUBLIC   CurPort


		PUBLIC   CurrMode
		PUBLIC   BioPos
		PUBLIC   RefPos                      ;cursor position

		PUBLIC   ColumnCount
		PUBLIC   VideoOffset

		PUBLIC   fucn2
		PUBLIC   fucn3
		PUBLIC   fucn5
		PUBLIC   fucn6
		PUBLIC   fucn7
		PUBLIC   fucn8
		PUBLIC   fucn9
		PUBLIC   fucnA
		PUBLIC   fucnE

;calling table
WORKSTART       LABEL BYTE
work1           DW      OFFSET MediaKU
work2           DW      OFFSET MediaTIS
work3           DW      OFFSET MediaSIC
work4           DW      OFFSET MediaSCT
work5           DW      OFFSET MediaUser

work6           DW      OFFSET Eng_mode
work7           DW      OFFSET ThaiChar
work8           DW      OFFSET _512char
work9           DW      OFFSET Thai25Refresh0
work10          DW      OFFSET Thai25Bios
work11          DW      OFFSET Thai25Auto
work12          DW      OFFSET CursorET
work13          DW      OFFSET SoundET
work14          DW      OFFSET CornerET

work15          DW      OFFSET Checking_f
work16          DW      OFFSET Not_check
work17          DW      OFFSET Lay_Kas
work18          DW      OFFSET Lay_Choid
work19          DW      OFFSET Lang_Cap
work20          DW      OFFSET Lang_Alt
work21          DW      OFFSET Lang_Num
work22          DW      OFFSET Lang_Scl
work23          DW      OFFSET Lang_Disable

work24          DW      OFFSET PrinterKU
work25          DW      OFFSET PrinterTIS
work26          DW      OFFSET Level1Print
work27          DW      OFFSET Level3Print
work28          DW      OFFSET Lpt1port
work29          DW      OFFSET Lpt2port
work30          DW      OFFSET Lpt3port
work31          DW      OFFSET LineSpace

work32          DW      OFFSET AdjPrnHBk
work33          DW      OFFSET AdjPrnLen
work34          DW      OFFSET AdjScrHBk
work35          DW      OFFSET AdjScrLen
work36          DW      OFFSET SpeedAdj
work37          DW      OFFSET InnerSpaceUp
work38          DW      OFFSET InnerSpaceDown


work39          DW      OFFSET PrinterFunc1
work40          DW      OFFSET PrinterFunc2
work41          DW      OFFSET PrinterFunc3
work42          DW      OFFSET PrinterFunc4
work43          DW      OFFSET PrinterFunc5
work44          DW      OFFSET PrinterFunc6
work45          DW      OFFSET PrinterFunc7
work46          DW      OFFSET PrinterFunc8
work47          DW      OFFSET PrinterFunc9

WORKEND         LABEL BYTE
ShadowMem         DW      2202 dup(?)
SaveWindow      DW      2202 dup(?)


Menu            PROC    NEAR
		push    ds

		push    cs
		pop     ds

		mov  dx,WORD PTR IndexPort
		add  dx,0006h
		in   al,dx
		mov  al,0
		mov  dx,3C0h                 ;off screen
		out  dx,al

		mov     BYTE PTR Active,1        ;change int way when Menu active
		mov     al,BYTE PTR RefrOnOff    ;save
		mov     BYTE PTR MenuRefresh,al  ;save status of refresher
		mov     BYTE PTR RefrOnOff,1     ;off it
		mov     ax,WORD PTR cs:OldPage      ;B000h or B800 source segment screen
		mov     ds,ax
		xor     si,si           ;Bx00:0000

		push    cs
		pop     es
		mov     di,OFFSET SaveWindow
		mov     cx,2000         ;2000 word all screen
		cld
savescr:        movsw                   ;save old screen to b200:DI
		loop    savescr
		nop

		mov     ax,WORD PTR cs:OldPage      ;B000h or B800 segment to be clear
		mov     es,ax
		mov     cx,2000
		mov     ax,720h         ;clear value
		xor     di,di           ;offset=0
		rep     stosw
		push    cs
		pop     ds
		mov     al,BYTE  PTR CurrMode
		mov     BYTE  PTR CurrMode1,al     ;save old mode
		mov     BYTE  PTR CurrMode,2       ;set

		push    ds
		xor     cx,cx
		mov     ds,cx
		mov     dx,WORD PTR ds:[450h]                   ;get cursor pos
		pop     ds

		cmp     al,04h                                  ;25 bios
		jb      ItRefresh
		mov     WORD PTR BioPos,dx                      ;save to bios variable
		jmp     NotRef
ItRefresh:      mov     WORD PTR RefPos,dx

NotRef:         mov     al,BYTE  PTR Code8line
		mov     BYTE  PTR Code8line1,al     ;save old 8line
		mov     BYTE  PTR Code8line,0       ;set RW

		call    Setmode
		mov     cx,2020h        ;Turn off Cursor
		mov     ah,1
		int     10h             ;Turn off cursor
;________________________________________________________________________
;print menu frame
		mov     di,24*160        ;down of screen line 24
		mov     si,OFFSET Trademark
COLOR1::         mov     ah,70h          ;attribute reverse <---70/71
		mov     cx,80
		call    PrinThai
		mov     di,3680         ;row 23 column 0
		mov     ax,07D4h        ;Ô
		stosw
		mov     ax,07CDh        ;ÍÍÍÍ
		mov     cx,78
		rep     stosw
		mov     al,0BEh         ;¾
		stosw
come::           mov     dx,0211h
COLOR2::         mov     ax,7b1h         ;±± <---07/01
		call    Clear_win
		mov     di,00a2h
		stosw
		mov     al,0b0h          ;°
		mov     cx,77
		rep     stosw
		mov     ah,07           ;attribute
		mov     al,179          ;³
		mov     di,160
		mov     cx,19
vertical0:      stosw
		add     di,156
		stosw
		loop    vertical0
		mov     al,179          ;³
		mov     di,3200
		mov     cx,3
vertical1:      stosw
		add     di,156
		stosw
		loop    vertical1

		mov     di,3040         ;row 19 column 1
		mov     al,0C6h         ;Æ
		stosw
		mov     al,0CDh         ;ÍÍÍÍ  205
		mov     cx,78
		rep     stosw
		mov     al,181          ;  µ
		stosw

		mov     di,0
		mov     ah,70h                  ;attribute for call Write String
		mov     si,OFFSET Headmark
		mov     cx,80
		call    PrinThai                ;print header
;------------
		call    Current_win                ;print sub window
		call    Shadow
		call    Cur_active
		call    bra_rever
		mov     Msg_status,0000         ;reset flag, print new help message
		call    Cur_massege
getkey::         mov     ah,1
		int     16h

		jz      getkey
		mov     ah,0
		int     16h

		cmp     al,0            ;Is extcode
		je      Extcode
LockReturn::     cmp     al,0dh          ;return key
		je      ReturnAllow
		cmp     al,27           ;ESC key
		jne     getkey

	   mov  dx,WORD PTR cs:IndexPort
	   add  dx,0006h
	   in   al,dx
	   mov  al,0
	   mov  dx,3C0h                 ;off screen
	   out  dx,al


		mov     ax,WORD PTR cs:OldPage      ;B000 or B800 alternat segment
		mov     es,ax
		xor     di,di           ;both offset is 0
		push    cs
		pop     ds
		mov     si,OFFSET SaveWindow    ;
		mov     cx,2000         ;number of character
		cld                     ;clear direction flag
restore:        movsw                   ;save old screen to b200:DI
		loop    restore         ;restore old screen
		mov     BYTE PTR Active,0        ;menu flag ON
		mov     al,BYTE PTR CurrMode1      ;after Menu PUSH DOWN
		mov     BYTE PTR CurrMode,al

		mov     al,BYTE PTR Code8line1      ;after Menu PUSH DOWN
		mov     BYTE PTR Code8line,al

		call    Setmode
		mov     al,BYTE PTR MenuRefresh
		mov     BYTE PTR RefrOnOff,al     ;return old status for Refresher

		pop     ds              ;form push at head
		retf                    ;Exit to caller
Menu            ENDP

ReturnAllow:    mov     al,BaseAdd      ;check mask allow to work
		add     al,OffsetAdd
		xor     ah,ah
		mov     bx,OFFSET MaskAllow
		add     bx,ax
		cmp     [bx],BYTE PTR 00         ;0 allow, 1 notwork
		jnz     getkey

Return:         mov     al,BaseAdd      ;find the line position on screen
		add     al,OffsetAdd
		mov     bx,OFFSET work1
		xor     ah,ah           ;clear
		shl     ax,1            ;multiple by 2
		add     bx,ax           ;point that address
		call    WORD PTR cs:[bx]         ;call working
		call    Cur_active      ;display active chioce
		call    bra_rever
		call    Cur_massege     ;when exit from editing routine
		jmp     getkey

Extcode:        cmp     ah,4Bh          ;checking left arrow
		je      left
		cmp     ah,4Dh          ;   --    right arrow key
		je      right
		cmp     ah,48h          ;   --    up
		je      up
		cmp     ah,50h          ;   --    down
		je      down

		jmp     getkey
left:           cmp     Cur_win,0       ;left arrow key com here
		jne     cur_winDec
		mov     Cur_win,MaxWindow       ;4 ;set 4-1 is a printer window
cur_winDec:     dec     Cur_win
		jmp     come            ;go come:for  Clear,New_window
right:          cmp     Cur_win,MaxWindow-1     ;3 ;rigth arrow key com here
		jne     cur_winInc
		mov     Cur_win,-1      ;1+(-1) = 0 is a data window
cur_winInc:     inc     Cur_win
		jmp     come            ;go come:for  Clear,New_window
up:             call    Cur_active      ;up com here, clear Bar reverse
		mov     bx,OFFSET Num_choice
		mov     al,Cur_win
		xlat
		cmp     OffsetAdd,00    ;compare Offset address is 00
		jne     up0             ;No continues
		mov     OffsetAdd,al    ;Yes prepare New value
up0:            dec     OffsetAdd
		jmp     bar_show        ;display New position of Bar reverse
down:           call    Cur_active      ;dowm com here, clear Bar reverse
		mov     bx,OFFSET Num_choice     ;num choice each window
		mov     al,Cur_win
		xlat
		dec     al
		cmp     OffsetAdd,al
		jne     down0
		mov     OffsetAdd,-1    ;Yes prepare New value
down0:          inc     OffsetAdd
bar_show:       call    bra_rever       ;display New position of Bar reverse
		call    Cur_massege
		jmp     getkey

bra_rever:      mov     ah,07h          ;reverse attribute
		mov     al,BaseAdd      ;find the line position on screen
		add     al,OffsetAdd
		mov     bx,OFFSET AttriBase
		xlat                    ;get line(roe) reverse on
COLOR3:         cmp     al,78h          ;<---78/7C
		jne     bra_rever1
COLOR4:         mov     ah,0fh          ;<---0f/0C
bra_rever1:     call    Cur_reverse
		ret
BioPos          DW      0               ; 25 bios, 25 Mix
RefPos          DW      0               ; ibm, 8 line, 512 char, 25 refresh


Headmark         DB     '     Data      Screen      Keyboard      Printer      Options      Esc-seq      $'
Trademark       DB      ' Powersoft Co.,Ltd.                             Thai Professional VGA/EGA V3.10 $'
;Trademark       DB      ' Powersoft Co.,Ltd.                              ThaiPro Beta-Test VGA/EGA V3.0 $'
Cursor  dw      ?
ColumnCount     dw      ?

Win_data        DB      ' ³ Data ³    S'
		DB      'ÚÁÄÄÄÄÄÄÁÄÄÄÄ¿'
		DB      '³Media code  ³'
		DB      '³   KU       ³'
		DB      '³   TIS      ³'
		DB      '³   SIC      ³'
		DB      '³   SCT      ³'
		DB      '³   User     ³'
		DB      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ'
Win_screen      DB      '  ³ Screen ³    Keyboar'
		DB      'ÚÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ¿'
		DB      '³Mode                 ³'
		DB      '³   English   Original³'
		DB      '³   Thai   8. Lines   ³'
		DB      '³   Font 512. Char    ³'
		DB      '³   Thai  25. Refresh ³'
		DB      '³   Thai  25. Bios    ³'
		DB      '³   Thai  25. AutoMix ³'
		DB      'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
		DB      '³Status               ³'
		DB      '³   Cursor            ³'
		DB      '³   Sound             ³'
		DB      '³   Corner            ³'
		DB      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'

MaskAllow       DB    (WORKEND - WORKSTART) /2 dup(0)

;*************************************************UPPER **************

HeaderArea      DW      OFFSET Menu             ;menu program
		DW      OFFSET PSP              ;Start config
		DW      OFFSET EndOfConfigArea  ;End config
		DW      OFFSET User_Tis         ;user code
		DW      OFFSET BottonArea
PSP             DW      ?
		DW      OFFSET New_int08h
		DW      OFFSET New_int09h
		DW      OFFSET New_int10h
		DW      OFFSET New_int17h
		DW      OFFSET New_int6fh
		DW      OFFSET Old_int08h_offs
		DW      OFFSET Old_int09h_offs
		DW      OFFSET Old_int10h_offs
		DW      OFFSET Old_int17h_offs
		DW      OFFSET Old_int6fh_offs
		DW      OFFSET Hot_Key
		DW      OFFSET EGAfont1
Cur_win         DB      1

DispTran          DW    OFFSET  KU_TIS -128
TimerRun          DW      OFFSET Shearsor1
ScrHardBlkCod     DB    32   ;blank
ScrHardBlkLen      DB    2               ;change from menu

PrnHardBlkCod     DB    160
PrnHardBlkLen     DB    2

SpeedVAR          DB    2               ;change from menu
PortVAR           DB    0               ;current port count from 0 1 2
PrnfVAR           DB    0               ;current function to printer

RefrOnOff       DB      1
MenuRefresh     DB      ?               ;on/off refresher  Variable
ETflag          DB      00h             ;English0 / Thai1 flag

Hot_Key         DB      3Bh             ;F1 key
Ctrl_key        DW      0004h           ;Ctrl key
HotkeyLebel     DB      'Ctrl+F1','$','20 character'
Lang_key        DB      3Ah             ;default CapsLock key
Lang0           DB      3ah             ;caps lock
Lang1           DB      38h             ;alt
Lang2           DB      45h             ;num
Lang3           DB      46h             ;scrool
Ctrl_keyTemp    DW      ?               ;temperaly First key when POPLOCK

KB_layout       DW      OFFSET MANEE1   ;address of layout table
KbTran          DW      OFFSET TIS_KU -128

ThaiEngStatus1  DW      OFFSET SoundSta
ThaiEngStatus2  DW      OFFSET BlankSta

PrinterTran          DW    OFFSET KU_TIS -128
CodePr_convert       DW    OFFSET Tis_Ku_PR - 128        ;dynamic User set
Spacing3        DB      1Bh,'3',11h     ;dynamic LineSpacing User set
Spacing1        DB      1Bh,'3',23      ; 20 = 24pin, 23 = 9pin
Spacing2        DB      1Bh,'3',23      ; 19 = 24pin, 23 = 9pin
OneLevelSP      DB      27,51,24h,255,0    ;ESC3 set n/216 line spacing
LockSpacing     DB      0               ;0=Unlock can replace, 1=Lock
ExtendFlag      DB      0               ;0 non-extend, 1 extend
PrnOneLeTrn     DB      0               ;0 by pass   , 1 translate
Hex72           DB      72              ;60 for 24 pin
Hex216          DB      216             ;180 for 24 pin

EngSound        DW      016dh
ThaiSound       DW      01c7h
BarStatus       DB      55,70h,127,70h,238,70h,231,70h,55,70h
CornerPos       DW      0136h
VgaFontStyle    DB      0               ;0=thin, 1= bold
EgaFontStyle    DB      0               ;0=thin, 1= bold
OneLevelTran    DW      OFFSET Tis_Ku_PR - 128
SamDataPrinter  DB      0               ;0=Sam, 1= Differance

Original        DB      1
Code8line       DB   0   ;RW
Code8line1      DB  ?

CurrMode1       DB  ?
CurMediaCode    DB  0   ;start KU
CurStatus       DB  1   ;1 sound
Typ_chk         DB  1   ;00typing check /01 not check
CurLayOut       DB  0   ;katmanee
CurLangKey      DB  0   ;caplock
CurPrnCode      DB  0   ;Ku
CurPrnLev       DB  1   ;3 level
CurPort         DB  0   ;LPT0

CurrMode        DB  4
KeyMode         DB      0



window0         DB      02,9,14                 ;column-start,tall,width
		DW      OFFSET  Win_data        ;address of data
window1         DB      11,15,23
		DW      OFFSET Win_screen
window2         DB      23,17,16
		DW      OFFSET Win_keyboard
window3         DB      37,18,17
		DW      OFFSET Win_printer
window4         DB      44,17,24
		DW      OFFSET Win_options
window5         DB      54,13,23
		DW      OFFSET Win_Escape

MaxWindow       EQU     6                       ;number of window
Win_Sum         DB      0,5,14,23,31,38,47            ;start number each window


Num_choice      DB      5,9,9,8,7,9                ;number of choice each window

LineAc          DB      3,4,5,6,7               ;where the reverse on
		DB      3,4,5,6,7,8,11,12,13
		DB      3,4,7,8,11,12,13,14,15
		DB      3,4,7,8,11,12,13,16
		DB      3,4,7,8,11,14,15
		DB      3,4,5,6,7,8,9,10,11

RegionSum       DB      00,05,11,14,16 ,18 ,23 ,25 ,27 ,30 ,31,32,33,34,35,36,37,38,47

WinStart        DB      ?
WinSize         DB      ?
WinTall         DB      ?
BaseAdd         DB      ?
OffsetAdd       DB      ?

int10Table      LABEL   WORD
fucn0           DW      OFFSET Int10func0
fucn1           DW      OFFSET Int10func1
fucn2           DW      OFFSET Int10func2_2       ;OldVDOReturn
fucn3           DW      OFFSET Int10func3_2
fucn4           DW      OFFSET OldVDOReturn
fucn5           DW      OFFSET VideoReturn
fucn6           DW      OFFSET Int10func6_2
fucn7           DW      OFFSET Int10func7_2
fucn8           DW      OFFSET Int10func8_2
fucn9           DW      OFFSET Int10func9_2
fucnA           DW      OFFSET Int10funcA_2
fucnB           DW      OFFSET OldVDOReturn
fucnC           DW      OFFSET OldVDOReturn
fucnD           DW      OFFSET OldVDOReturn
fucnE           DW      OFFSET Int10funcE_2     ;Int10funcE
fucnF           DW      OFFSET OldVDOReturn
fucn10          DW      OFFSET OldVDOReturn
fucn11          DW      OFFSET OldVDOReturn     ;VideoReturn
fucn12          DW      OFFSET OldVDOReturn
fucn13          DW      OFFSET OldVDOReturn
fucn14          DW      OFFSET OldVDOReturn
fucn15          DW      OFFSET OldVDOReturn
fucn16          DW      OFFSET OldVDOReturn
fucn17          DW      OFFSET OldVDOReturn
fucn18          DW      OFFSET OldVDOReturn
fucn19          DW      OFFSET OldVDOReturn
fucn1A          DW      OFFSET VideoReturn
Mil             EQU     $-int10Table

Win_Keyboard    DB      '  ³ Keyboard ³  '
		DB      'ÚÄÁÄÄÄÄÄÄÄÄÄÄÁÄ¿'
		DB      '³Typing check  ³'
		DB      '³   Check      ³'
		DB      '³   Not check  ³'
		DB      'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
		DB      '³Layout        ³'
		DB      '³   Kasmanee   ³'
		DB      '³   Patachote  ³'
		DB      'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
		DB      '³Language key  ³'
		DB      '³   CapsLock   ³'
		DB      '³   Alt        ³'
		DB      '³   NumLock    ³'
		DB      '³   ScrollLock ³'
		DB      '³   Disable    ³'
		DB      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'

Win_printer     DB      '  ³ Printer ³    '
		DB      'ÚÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄ¿'
		DB      '³Printer code   ³'
		DB      '³   KU          ³'
		DB      '³   TIS         ³'
		DB      'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
		DB      '³Printing style ³'
		DB      '³   1 level     ³'
		DB      '³   3 level     ³'
		DB      'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
		DB      '³Port number    ³'
		DB      '³   LPT:1       ³'
		DB      '³   LPT:2       ³'
		DB      '³   LPT:3       ³'
		DB      'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
		DB      '³Line spacing   ³'
ScrSpace        DB      '³    17/216 inch³'
		DB      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'


Win_options     DB      'nter    ³ Options ³    E'
		DB      'ÚÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄ¿'
		DB      '³Printer hard blank    ³'
StrPrnHB        DB      '³   Code  :    160     ³'
StrPrnLen       DB      '³   Length:      2     ³'
		DB      'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
		DB      '³Screen hard blank     ³'
StrScrHB        DB      '³   Code  :     32     ³'
StrScrLen       DB      '³   Length:      2     ³'
		DB      'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
		DB      '³Refresh mode speed    ³'
ScrSpeed        DB      '³   Speed :      2     ³'
		DB      'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
		DB      '³Inner spacing         ³'
StrSpaceUp      DB      '³   Up    : 23/216 inch³'
StrSpaceDown    DB      '³   Down  : 23/216 inch³'
		DB      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'


Win_Escape      DB      'Options    ³ Esc-seq ³ '
		DB      'ÚÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁ¿'
		DB      '³Printer setup        ³'
PrintString     DB      '³   Compressed Mode   ³'
		DB      '³   Expanded Mode     ³'
		DB      '³   Emphasized Mode   ³'
		DB      '³   Double-Strike Mode³'
		DB      '³   Elite Mode        ³'
		DB      '³   Miniature Mode    ³'
		DB      '³   Reset Print Modes ³'
		DB      '³   Skip Perforation  ³'
		DB      '³   Indent Left Margin³'
		DB      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'

;Control code strings for all of the printer setup options.
;
EscStr1         db 15,255,14 dup (0)                      ;compressed mode on
EscStr2         db 27,87,1,255,12 dup (0)                 ;expanded mode on
EscStr3         db 27,69,255,13 dup (0)                   ;emphasized mode on
EscStr4         db 27,71,255,13 dup (0)                   ;double-strike mode on
EscStr5         db 27,77,255,13 dup (0)                   ;elite mode on
EscStr6         db 15,27,83,0,27,65,6,255,8 dup (0)       ;miniature mode on
EscStr7         db 18,27,87,0,27,70,27,72,27,80,27,84,27,50,255,0      ;reset
EscStr8         db 27,78,12,255,12 dup (0)                ;perfskip on
EscStr9         db 27,108,10,255,12 dup (0)               ;indent left margin

COLOR5:
AttriBase       DB      78h,70h,70h,70h,70h                 ;<--- 78/7C
		DB      70h,70h,70h,70h,78h,70h,70h,78h,70h
		DB      70h,78h,78h,70h,78h,70h,70h,70h,70h
		DB      78h,70h,70h,78h,78h,70h,70h,78h
		DB      78h,78h,78h,78h,78h,78h,78h

EndOfConfigArea LABEL BYTE  ;___User code area ________________

		DB      70h,70h,70h,70h,70h,70h,70h,70h,70h  ;color of Esc string

		;user_Tis
User_Tis          DB    128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
		  DB    144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
		  DB    0A0h,0DBh,0DCh,0DDh,0DEh,0FCh,0FDh,0FEh,0E7h,0E8h,0E9h,0EAh,0EBh,0ECh,0EEh,0EDh
		  DB    0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0DFh,0EFh,0FAh,0FBh,0CFh,0E5h
		  DB    0E6h,0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh
		  DB    0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
		  DB    0C0h,0C1h,0C2h,0C3h,0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0D0h
		  DB    0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h,0D8h,0D9h,0DAh,0E0h,0E1h,0E2h,0E3h,0E4h,0ffh

		;Tis_User
Tis_User          DB    128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
		  DB    144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
		  DB    160, 0C1h,0C2h,0C3h,0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh
		  DB    0D0h,0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h,0D8h,0D9h,0DAh,0DBh,0DCh,0DDh,0DEh,0DFh
		  DB    0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E6h,0E7h,0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0BEh
		  DB    0EFh,0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0DBh,0DCh,0DDh,0DEh,0BAh
		  DB    0FAh,0FBh,0FCh,0FDh,0FEh,0BFh,0C0h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AFh,0AEh,0BBh
		  DB    0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BCh,0BDh,0FCh,0FDh,0FEh,0FFh

;***********************BOTTON SAVE ************************

BottonArea      LABEL   BYTE

;__________________________________________________________________________
;Curent_window thai a majer routine  Setup many Variable for another routine
;along process

Current_win     PROC    NEAR
		mov     al,Cur_win      ;get current windown
		mov     bx,OFFSET Win_Sum
		xlat
		mov     BaseAdd,al
		mov     OffsetAdd,0
		mov     bl,Cur_win
		mov     al,5            ;number of parameter
		mul     bl              ;find frist position
		mov     bx,OFFSET window0
		add     bx,ax           ;start each sub window
		mov     dh,0            ;
		mov     dl,[bx]         ;load where column start
		mov     WinStart,dl
		mov     cx,[bx+1]       ;size of window
		mov     WinSize,ch
		mov     WinTall,cl
		mov     si,[bx+3]       ;data of window
		call    Mem_Video
		ret
Current_win     ENDP

;----------------------------------------------------------------------------
;Clear_win is a routine for clear window
;       Enter   AH= ATTRIBUTE, AL= ASCII
;               ES:     segment of screen to be clear
;               DH,DL   -start row , number of line
;       Destroy BL,CX
;
Clear_win       PROC    NEAR
		push    di
		mov     bl,dl
		mov     dl,1
		call    VideoOffset     ; calculate DI
clsloop:        mov     cx,78
	   ;     mov     ax,720h         ;clear value
		rep     stosw           ;store ax in es:[di]
		add     di,4          ;next lines
		dec     bl
		jnz     clsloop
		pop     di
		ret
Clear_win       ENDP


Shadow          PROC    NEAR
		mov     dl,WinStart
		add     dl,WinSize
		mov     dh,2
		call    VideoOffset
		mov     cl,WinTall
		dec     cl
COLOR6::         mov     ax,7b0h                 ;<--- 07/01
Shadow1:        stosw
		stosw
		add     di,156
		loop    Shadow1

		mov     cl,WinSize
		shl     cx,1
		add     cx,156
		sub     di,cx
		mov     cl,WinSize
		rep     stosw
		ret
Shadow          ENDP
;____________________________________________________________________________
; Cur_reverse is routine for make a reverse bar at  LineActive. Them know where
;the line active start, by the parameter WinStart and Winsize
;       Entry   AH = attribute
;       Return  Non
;       Destroy AX,DX

Cur_reverse     PROC    NEAR
		push    bx
		push    cx
		mov     cl,ah           ;save attribute
		mov     al,BaseAdd      ;find the line position on screen
		add     al,OffsetAdd
		mov     bx,OFFSET LineAc
		xlat                    ;get line(roe) reverse on
		mov     dh,al
		mov     dl,WinStart     ;start of reverse line + 1
		inc     dl
		call    VideoOffset
		mov     al,cl           ;restore attribute
		xor     ch,ch
		mov     cl,WinSize      ;number of chioce,,end of reverse line
		sub     cl,02
Cur_reverse0:   inc     di              ;start  of line + 1
		stosb
		loop    Cur_reverse0    ;fill the attribute
		pop     cx
		pop     bx
		ret
Cur_reverse     ENDP
;___________________________________________________________________________
;Cur_active     is routine show the Active choice in the window and Mark
;
Cur_active      PROC    NEAR
		mov     bx,OFFSET Num_choice    ;base of number choice each window
		mov     al,Cur_win              ;number of window ON
		xlat                            ;get number of chioce
		mov     ch,0                    ;counter up
		mov     si,0
		mov     bx,OFFSET AttriBase     ;base of attribue
		mov     cl,BaseAdd
		add     bx,cx                   ;start attribue string for window
		mov     cl,al                   ;number of chioce
		mov     al,OffsetAdd
		push    ax                      ;save old offset
Cur_act0:       mov     OffsetAdd,ch
		mov     ah,[bx+si]                 ;attribute
		call    Cur_reverse
COLOR7::         mov     dx,7010h              ;root sing   <--- 70/74
COLOR8::         cmp     BYTE PTR [bx+si],78h       ;is intend attribute  <--- 78/7C
		jz      Cur_act1                ;plot Mark sign
		mov     dx,7020h        ;blank sign
Cur_act1:       xor     ah,ah
		mov     al,WinSize
		shl     ax,1            ;multiple *2
		sub     di,ax           ;start again
		mov     es:[di+4],dx    ;fill sign on screen
		call    Blk_active
		inc     si
	       ; inc     bx              ;increase attribute pointer
		inc     ch              ;increase counter up
		cmp     ch,cl           ;
		jb      Cur_act0        ;Yes less than repeat next line
		pop     ax
		mov     OffsetAdd,al    ;restore offset address
		ret
Cur_active      ENDP

Blk_active:     push    bx
		mov     bx,OFFSET MaskAllow     ;base of marker
		mov     al,BaseAdd
		xor     ah,ah
		add     bx,ax
		mov     dl,0fh                  ;'*' sign
		cmp     BYTE PTR [bx+si],00
		jz      Blk_act1
	   ;     mov     dl,20h                  ;blank sign
		mov     es:[di+4],dx    ;fill sign on screen
Blk_act1:       pop     bx
		ret
;__________________________________________________________________________
; Change_ac is routine change active line in the Region
;       Entry   BaseAdd,OffsetAdd == RegionSum
;
Change_ac       PROC    NEAR

		push    ax
		push    bx
		push    cx
		push    dx
		push    di
		mov     al,BaseAdd
		add     al,OffsetAdd            ;Base + Offset
		mov     bx,OFFSET RegionSum     ;table of region size ++n
Change_ac0:     cmp     al,[bx]
		jb      Change_ac1              ;Yes meet that region number
		inc     bx
		jmp     Change_ac0              ;find out the region continues
Change_ac1:     mov     di,OFFSET AttriBase     ;attribute for show where active
		xchg    di,bx
		xor     dh,dh
		mov     dl,[di-1]
		add     bx,dx                   ;start address of that region
		xor     ch,ch
		mov     cl,[di]                 ;calculat the chioce that region
		sub     cl,[di-1]               ;or counter
Change_ac2:     mov     BYTE PTR [bx],70h       ;normal attribute
		inc     bx                      ;clear all that region
		loop    Change_ac2
		mov     di,OFFSET AttriBase
		xor     ah,ah
		add     di,ax
COLOR9::         mov     BYTE PTR [di],78h       ;new one intend attribute <--- 78/7C
		pop     di
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		ret
Change_ac       ENDP


BaseThaiMasseg  DW      OFFSET M1
		DW      OFFSET M2
		DW      OFFSET M3
		DW      OFFSET M4
		DW      OFFSET M5
		DW      OFFSET M6
		DW      OFFSET M7
		DW      OFFSET M8
		DW      OFFSET M9
		DW      OFFSET M10
		DW      OFFSET M11
		DW      OFFSET M12
		DW      OFFSET M13
		DW      OFFSET M14
		DW      OFFSET M15
		DW      OFFSET M16
		DW      OFFSET M17
		DW      OFFSET M18

M1              DB      'ÐÃÜÊ¡ÁÈÝÇ¾ÎÆÎÔµÀµó³áÊ¥¡ÎÁ ÁÈÝÇ·ô¦Ì´Ø¡Ð¡ß¸ ÈÁÜÊÐÁÚÀ¡Ó¨á¦Î¡Ñºà·²ÙÇ£ä.$'
M2              DB      'ÐÃÜÊ¡ÒÈ¿²¡ÎÁµÏ¥Î·¢Ê¥¦ÊÐ¹ß·Ñ¸¸ English, 512 char, 8 ¸ÁÁµÝ², 25 ¸ÁÁµÝ².$'
M3              DB      'ÐÃÜÊ¡¡ÎÁ¸Ê¡Ç´Î·Ì¢Ê¥Ñ¹á·¼Ù¿¼äÄàÎÐ¹ß· ÔµÀ/ÊÝ¥¡ÂÆµó  cursor,  ÐÇÚÀ¥,  ÈÁÜÊµó¿×¿¦Ê.$'
M4              DB      '¦ÌÓÈáÐ£ÁûÊ¥³ÁÄ¦ÇÊ¸ÈÃÝ¡¡ÎÁ¼Ù¿¼ä¾ÎÆÎÔµÀ ÈÁÜÊÔ¿à.$'
M5              DB      '³áÊ¥¡ÎÁÑ¹á·¼Ù¿¼ä¾ÎÆÎÔµÀÑ¸¸ Ð¡Æ¿±Ú ÈÁÜÊÄàÎ ¹Ý³Ò¨³Ù.$'
M6              DB      'ÐÃÜÊ¡¹×à¿µó¦ÌµÏÈ·áÎµóÐ¹ÃóÀ·Ñ¹á·¼Ù¿¼äÁÌÈÄàÎ¥  ÔµÀ/ÊÝ¥¡ÂÆ.$'
M7              DB      'ÐÃÜÊ¡ÁÈÝÇ¢Ê¥Ð£ÁûÊ¥¼Ù¿¼äÐ¹ß·Ñ¸¸Ð¡Æ³Á ÈÁÜÊ Ç¿Ê.$'
M8              DB      'ÐÃÜÊ¡¡ÎÁ¼Ù¿¼äµóÐ£ÁûÊ¥¼Ù¿¼äÑ¸¸  1 ÁÌ²Ý¸ ÈÁÜÊ 3 ÁÌ²Ý¸.$'
M9              DB      'Çà¥¢áÊ£ÄÎ¿ÊÊ¡Ð£ÁûÊ¥¼Ù¿¼äµó Port printer.$'
M10             DB      '³ë¥ÁÌÀÌÈàÎ¥ÁÌÈÄàÎ¥¸ÁÁµÝ²¼Ù¿¼ä.$'
M11             DB      '³ë¥ÁÈÝÇ¨²Ð¨ÀÇÏÈÁÝ¸Ð£ÁûÊ¥¼Ù¿¼ä ÁÌ¸¸¨²Ð¨À¦ÌµÏ¥Î·Ð¿ûÊ¼¸ÁÈÝÇ£Á¸³Î¿£ÄÎ¿ÀÎÄµó³ë¥ÔÄá.$'
M12             DB      '³ë¥£ÄÎ¿ÀÎÄ¢Ê¥ÁÈÝÇ¨²Ð¨ÀÇÏÈÁÝ¸Ð£ÁûÊ¥¼Ù¿¼ä.$'
M13             DB      '³ë¥ÁÈÝÇ¨²Ð¨ÀÇÏÈÁÝ¸¦Ê¾Î¼ ÁÌ¸¸¨²Ð¨À¦ÌµÏ¥Î·Ð¿ûÊ¼¸ÁÈÝÇ£Á¸³Î¿£ÄÎ¿ÀÎÄµó³ë¥ÔÄá.$'
M14             DB      '³ë¥£ÄÎ¿ÀÎÄ¢Ê¥ÁÈÝÇ¨²Ð¨ÀÇÏÈÁÝ¸¦Ê¾Î¼.$'
M15             DB      '³ë¥£ÄÎ¿ÐÁßÄÇÏÈÁÝ¸¡ÎÁÑÇ²¥ºÃÓ·ÒÈ¿² 25 line refresh.$'
M16             DB      '³ë¥ÁÌÀÌÈàÎ¥¾ÎÀÓ·¸ÁÁµÝ²¼Ù¿¼äÁÌÈÄàÎ¥ ÁÌ²Ý¸¡ÃÎ¥¡Ý¸ÁÌ²Ý¸¸·.$'
M17             DB      '³ë¥ÁÌÀÌÈàÎ¥¾ÎÀÓ·¸ÁÁµÝ²¼Ù¿¼äÁÌÈÄàÎ¥ ÁÌ²Ý¸¡ÃÎ¥¡Ý¸ÁÌ²Ý¸ÃàÎ¥.$'
M18             DB      'Çà¥ÁÈÝÇ¼ÙÐÅÆ (Esc sequences) Ô¹ÀÝ¥Ð£ÁûÊ¥¼Ù¿¼äÐ¼ûÊÐ¹ÃóÀ·Ñ¹Ã¥ÁØ¹Ñ¸¸¡ÎÁ¼Ù¿¼ä.$'

Msg_status      DW      ?
;_____________________________________________________________________________
;Cur_massege is routine find out the Massege send the PrinThai routine display
;in small window
;       Entry   use the galbal variable :BaseAdd, :OffsetAdd
;               and local variable      :Msg_status
;       Return  Non
;       Destroy AX,CX,DX,SI,DI
Cur_massege     PROC    NEAR
		mov     al,BaseAdd
		add     al,OffsetAdd            ;Base + Offset
		mov     si,OFFSET RegionSum     ;table of region size ++n
		mov     di,OFFSET BaseThaiMasseg - 2;offset table Thai massege
cur_mag0:       cmp     al,[si]
		jb      ThisMeg                 ;Yes this message to displaying
		inc     si                      ;No find contineus
		add     di,2                    ;counter up
		jmp     cur_mag0                ;jump search masseg
ThisMeg:        cmp     di,Msg_status           ;Check same value
		je      Cur_Msg_Q               ;Yey! not repaet
		mov     Msg_status,di           ;change new value
		mov     dx,1403h                ;area of small window
		mov     ax,720h
		call    Clear_win               ;clear small window
		mov     si,[di]                 ;start point of string
COLOR10::        mov     ah,0fh                  ;Normal attribute <---0F/0B
		mov     di,3362                 ;offset of mediam line
		call    Central
		call    PrinThai                ;print Massege in window
Cur_Msg_Q:      ret
Cur_massege     ENDP

;--------------------------------------------------------------------------
;This routine Use before PrintThai finding Center print that line
;       Entry   SI      -Source string
;               DI      -Destinat to print
;       Return  DI      -New Center position
;       Destroy AL,DX,CX

Central         PROC    NEAR
		push    si
		xor     dx,dx           ;clear counter
		mov     cx,80*3-2        ;maximam character length
Central0:       mov     al,[si]
		cmp     al,24h          ;compare '$' 24h
		je      CentralQ           ;terminat String
		cmp     al,0D6h          ;
		ja      Central2
		inc     dx
Central2:       inc     si              ;inc string pointer
		loop    Central0           ;loop until zero
CentralQ:       add     di,80-2           ;add 40 column
		and     dx,0fffeh       ;even
		sub     di,dx
		pop     si
		ret                     ;return caller
Central         ENDP

;--------------------------------------------------------------------------
;       Entry   DS:SI   - Source of String in memory ,terminat by $
;               ES:DI   - Destination ( offset in screen buffer)
;               AH      - attribute
;       Return  Non
;       Destroy AX,BX,CX,DI
PrinThai        PROC    NEAR
		mov     cx,80*3-2        ;maximam character length
PrinTh0:        mov     al,[si]
		cmp     al,24h          ;compare '$' 24h
		je      PrinThQ           ;terminat String
		cmp     al,215          ;215 u 216 oo
		jb      PrinTh2
		cmp     al,216
		ja      PrinTh1
		mov     es:[di+158],ax  ;under line
		jmp     PrinTh3
PrinTh1:        mov     es:[di-162],ax  ;upper line
		jmp     PrinTh3
PrinTh2:        mov     es:[di],ax      ;mediam line
		add     di,2
PrinTh3:        inc     si              ;inc string pointer
		loop    PrinTh0           ;loop until zero
PrinThQ:        ret                     ;return caller
PrinThai        ENDP
;___________________________________________________________________
;
;       Mem_Video is routine move window in memory to video buffer.
;       Entry   DS:SI   - memory buffer
;               ES      - video segment
;               DH,DL   - row and column of upper left corner of window
;               CH      - width of window in column
;               CL      - number of lines in window
;
;___________________________________________________________________

Mem_Video    proc       near
		mov     al,ch           ;save number of columns
		mov     ah,0
		mov     ds:ColumnCount,ax
		mov     ch,0            ;CX = number of  lines
		call    VideoOffset     ;get address
Mem_V1:         push    di              ;save video strating addr
		push    cx              ;save line count
		mov     cx,ds:ColumnCount  ;
		mov     ah,70h          ;attribute
		call    WriteLn         ;move one line
		pop     cx
		pop     di
		add     di,160
		loop    Mem_V1
		ret

Mem_Video       endp

;___________________________________________________________________
;
;       WriteLn is routine copy a string of word from memory to another
;       Entry:  AH attribute
;               DS:SI   - source
;               ES:DI   - destination     (to screen alternate ascii,att)
;               CX      - number of worrds
;

WriteLn         proc    near
		cld
Write1:         mov     al,[si]
		stosw
		inc     si
		loop    Write1
		ret
WriteLn         endp
;------------------------------

Checking_f      PROC    NEAR
		call    Change_ac       ;change the chioce active

		mov     BYTE PTR Typ_chk,00          ;set checking flag for check
		ret
Checking_f      ENDP

Not_check       PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR Typ_chk,01          ;not check
		ret
Not_check       ENDP

Lay_Kas         PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     WORD PTR KB_layout,OFFSET MANEE1
		mov     BYTE PTR CurLayOut,00
		ret
Lay_Kas         ENDP

Lay_Choid       PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     WORD PTR KB_layout,OFFSET CHOID1
		mov     BYTE PTR CurLayOut,01
		ret
Lay_choid       ENDP

;___________________________________________________________________
;
;       VideoOffset is routine calculate offset address of char positio
;       Entry:  DH,DL   - row and column of cell
;       Exit:   DI      - offset address
;
;___________________________________________________________________
;stay here for search pattern for changing Langauge key
VideoOffset     proc    near
		push    ax
		mov     al,160
		mul     dh              ;row * 160
		shl     dl,1            ;column * 2
		mov     dh,0            ;byte to word
		add     ax,dx           ;( row * 160 ) + ( column * 2 )
		mov     di,ax           ;set offset in DI
		pop     ax
		ret
VideoOffset     endp


Lang_Cap        PROC    NEAR
		mov     KeyMode,0
Lang_Cap2::      call    Change_ac               ;change the chioce active
		mov     al,Lang0
		mov     BYTE PTR Lang_key,al
		mov     BYTE PTR CurLangKey,0
		ret
Lang_Cap        ENDP

Lang_Alt        PROC    NEAR
		mov     KeyMode,1
Lang_Alt2::      call    Change_ac               ;change the chioce active
		mov     al,Lang1
		mov     BYTE PTR Lang_key,al
		mov     BYTE PTR CurLangKey,1
		ret
Lang_Alt        ENDP

Lang_Num        PROC    NEAR
		mov     KeyMode,2
Lang_Num2::      call    Change_ac               ;change the chioce active
		mov     al,Lang2
		mov     BYTE PTR Lang_key,al
		mov     BYTE PTR CurLangKey,2
		ret
Lang_Num        ENDP

Lang_Scl        PROC    NEAR
		mov     KeyMode,3
Lang_Scl2::      call    Change_ac               ;change the chioce active
		mov     al,Lang3
		mov     BYTE PTR Lang_key,al
		mov     BYTE PTR CurLangKey,3
		ret
Lang_Scl        ENDP

Lang_Disable    PROC    NEAR
		mov     KeyMode,4
Lang_Disable2::  call    Change_ac               ;change the chioce active
		mov     BYTE PTR Lang_key,0ffh  ;disable 0ff out of scan code
		mov     BYTE PTR ETflag,0       ;change to English
		mov     BYTE PTR CurLangKey,4
		RET
Lang_Disable    ENDP

_8lineDis       PROC    NEAR
		mov     dl,BaseAdd
		mov     dh,OffsetAdd            ;save
		mov     BaseAdd,14
		mov     OffsetAdd,8
		call    Lang_Disable2            ;change key   dis
		mov     BaseAdd,23
		mov     OffsetAdd,2
		call    Level1Print             ;change level 1
		mov     BaseAdd,dl
		mov     OffsetAdd,dh            ;restore
		ret
_8lineDis       ENDP

KeyWork         DW      OFFSET Lang_Cap2
		DW      OFFSET Lang_Alt2
		DW      OFFSET Lang_Num2
		DW      OFFSET Lang_Scl2
		DW      OFFSET Lang_Disable2

_25lineEn       PROC    NEAR
		mov     dl,BaseAdd
		mov     dh,OffsetAdd            ;save

		mov     al,KeyMode
		mov     BaseAdd,18
		mov     OffsetAdd,al            ;set region

		mov     bx,OFFSET KeyWork
		xor     ah,ah                   ;clear
		shl     ax,1                    ;multiple by 2
		add     bx,ax                   ;point that address
		call    WORD PTR cs:[bx]                 ;call working

		mov     BaseAdd,23
		mov     OffsetAdd,3
		call    Level3Print             ;change level 2


		mov     BaseAdd,dl
		mov     OffsetAdd,dh            ;restore
		ret
_25lineEn       ENDP

;Input  DX
_RestorePos     PROC    NEAR
		push    ds
		push    ax
		xor     ax,ax
		mov     ds,ax
		mov     ds:[450h],dx
		pop     ax
		pop     ds
		ret
_RestorePos     ENDP

Eng_mode        PROC    NEAR
		call    Change_ac       ;change the chioce active
		call    Thai25Refresh
		mov     BYTE PTR CurrMode1,0
		mov     BYTE PTR MenuRefresh,1     ;off refresher
		call    _8lineDis
		mov     dx,WORD PTR RefPos
		call    _RestorePos                ;cursor position
		ret
Eng_mode        ENDP

ThaiChar        PROC    NEAR
		call    Change_ac       ;change the chioce active
		call    Thai25Refresh
		mov     BYTE PTR CurrMode1,1
		mov     BYTE PTR MenuRefresh,1     ;off refresher
		call    _8lineDis
		mov     dx,WORD PTR RefPos
		call    _RestorePos                ;cursor position
		ret
ThaiChar        ENDP

_512char        PROC    NEAR
		call    Change_ac       ;change the chioce active
		call    Thai25Refresh
		mov     BYTE PTR CurrMode1,2
		mov     BYTE PTR MenuRefresh,1     ;on refresher
		call    _8lineDis
		mov     dx,WORD PTR RefPos
		call    _RestorePos                ;cursor position
		ret
_512char        ENDP

Thai25Bios      PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR CurrMode1,4               ;25 line mode 4
		mov     BYTE PTR MenuRefresh,1             ;turn off refresher
		mov     WORD PTR fucn2,OFFSET Int10func2_2
		mov     WORD PTR fucn3,OFFSET Int10func3_2
		mov     WORD PTR fucn6,OFFSET Int10func6_2
		mov     WORD PTR fucn7,OFFSET Int10func7_2
		mov     WORD PTR fucn8,OFFSET Int10func8_2
		mov     WORD PTR fucn9,OFFSET Int10func9_2
		mov     WORD PTR fucnA,OFFSET Int10funcA_2
		mov     WORD PTR fucnE,OFFSET Int10funcE_2
		call    _25lineEn
		mov     dx,WORD PTR BioPos
		call    _RestorePos                ;cursor position
		ret
Thai25Bios      ENDP

Thai25Refresh0  PROC    NEAR
		mov     ax,0ffffh
		mov     di,OFFSET ShadowMem
		push    es
		push    cs
		pop     es
		mov     cx,2202
		rep     stosw
		pop     es

Thai25Refresh::  call    Change_ac       ;change the chioce active
		cli
		mov     BYTE PTR CurrMode1,3
		mov     WORD PTR fucn2,OFFSET OldVDOReturn    ;Int10func2
		mov     WORD PTR fucn3,OFFSET OldVDOReturn
		mov     WORD PTR fucn6,OFFSET OldVDOReturn
		mov     WORD PTR fucn7,OFFSET OldVDOReturn
		mov     WORD PTR fucn8,OFFSET OldVDOReturn
		mov     WORD PTR fucn9,OFFSET OldVDOReturn
		mov     WORD PTR fucnA,OFFSET OldVDOReturn
		mov     WORD PTR fucnE,OFFSET OldVDOReturn      ;Int10funcE
		mov     WORD PTR TimerRun,OFFSET L_refresh1
		mov     BYTE PTR MenuRefresh,0     ;on refresher
		sti
		call    _25lineEn
		mov     dx,WORD PTR RefPos
		call    _RestorePos                ;cursor position
		ret
Thai25Refresh0     ENDP

Thai25Auto      PROC    NEAR
		call    Change_ac       ;change the chioce active
		cli
		call    Thai25Bios
		mov     WORD PTR TimerRun,OFFSET Shearsor1
		mov     BYTE PTR CurrMode1,5                    ;mode 5
		mov     BYTE PTR MenuRefresh,0     ;on refresher
		sti
		call    _25lineEn
		mov     dx,WORD PTR BioPos
		call    _RestorePos                ;cursor position
		RET

Thai25Auto      ENDP

MediaKU         PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR Code8line1,0
		mov     BYTE PTR Code8line,0
		mov     BYTE PTR CurMediaCode,0
		call    Find1TranTable  ;finding table for 1line translat
		mov     WORD PTR DispTran,OFFSET KU_TIS -128
		mov     WORD PTR KbTran,OFFSET TIS_KU -128
		mov     WORD PTR PrinterTran,OFFSET KU_TIS -128
		ret
MediaKU         ENDP

MediaTIS        PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR Code8line1,1
		mov     BYTE PTR Code8line,1
		mov     BYTE PTR CurMediaCode,1
		call    Find1TranTable  ;finding table for 1line translat
		mov     WORD PTR DispTran,OFFSET TableTIS -128
		mov     WORD PTR KbTran,OFFSET TableTIS -128
		mov     WORD PTR PrinterTran,OFFSET TableTIS -128
		ret
MediaTIS        ENDP

MediaSIC        PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR CurMediaCode,2
		mov     WORD PTR DispTran,OFFSET TableTIS -128
		mov     WORD PTR KbTran,OFFSET TableTIS -128
		mov     WORD PTR PrinterTran,OFFSET TableTIS -128
		ret
MediaSIC        ENDP

MediaSCT        PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR CurMediaCode,3
		mov     WORD PTR DispTran,OFFSET SCT_TIS  -128
		mov     WORD PTR KbTran,OFFSET TIS_SCT  -128
		mov     WORD PTR PrinterTran,OFFSET SCT_TIS  -128
		ret
MediaSCT        ENDP

MediaUser       PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR CurMediaCode,4
		mov     WORD PTR DispTran,OFFSET User_Tis -128
		mov     WORD PTR KbTran,OFFSET Tis_User -128
		mov     WORD PTR PrinterTran,OFFSET User_Tis -128
		ret
MediaUser       ENDP


PrinterKU       PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     WORD PTR CodePr_convert,OFFSET Tis_Ku_PR -128
		mov     BYTE PTR CurPrnCode,0
		call    Find1TranTable  ;finding table for 1line translat
		ret
PrinterKU       ENDP

PrinterTIS      PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     WORD PTR CodePr_convert,OFFSET Tis_Tis_PR -128
		mov     BYTE PTR CurPrnCode,1
		call    Find1TranTable  ;finding table for 1line translat
		ret
PrinterTIS      ENDP

Find1TranTable  PROC    NEAR
		mov     SamDataPrinter,0
		mov     al,BYTE PTR CurMediaCode
		cmp     BYTE PTR CurPrnCode,al
		je      Find1Quit
		mov     SamDataPrinter,1        ;defferance
		mov     WORD PTR OneLevelTran,OFFSET Ku_Tis_PR - 128
		cmp     al,0                    ;data code == ku
		je      Find1Quit
		mov     WORD PTR OneLevelTran,OFFSET Tis_Ku_PR - 128
Find1Quit:      ret
Find1TranTable  ENDP

NumPort1        DW      ?
NumPort2        DW      ?
NumPort3        DW      ?

Lpt1port        PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PortVAR,0
		push    es
		mov     ax,40h
		mov     es,ax
		mov     ax,WORD PTR NumPort1
		or      ax,ax                   ;test emply port
		jz      NotChangPort1
		mov     es:[008],ax
NotChangPort1:  pop     es
		mov     BYTE PTR CurPort,0
		ret
Lpt1port        ENDP

Lpt2port        PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PortVAR,1
		push    es
		mov     ax,40h
		mov     es,ax
		mov     ax,WORD PTR NumPort2
		or      ax,ax                   ;test emply port
		jz      NotChangPort2
		mov     es:[008],ax
NotChangPort2:  pop     es
		mov     BYTE PTR CurPort,1
		ret
Lpt2port        ENDP

Lpt3port        PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PortVAR,2
		push    es
		mov     ax,40h
		mov     es,ax
		mov     ax,WORD PTR NumPort3
		or      ax,ax                   ;test emply port
		jz      NotChangPort3
		mov     es:[008],ax
NotChangPort3:  pop     es
		mov     BYTE PTR CurPort,2
		ret
Lpt3port        ENDP



Level1Print     PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR Original,0
		mov     BYTE PTR CurPrnLev,0

		push    si
		push    bx
		push    dx

		mov     si,OFFSET OneLevelSP

		call lpt1stat                      ;check for printer ready
		jc Level1Out
		mov bl,255               ;specify delimiter for call to LPRINTZ
		call lprintz             ;send control code string to printer


Level1Out:      pop     dx
		pop     bx
		pop     si
		ret
Level1Print     ENDP

Level3Print     PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR Original,1
		mov     BYTE PTR CurPrnLev,1
		ret
Level3Print     ENDP

PreserveMass    DB      "ÁÌÀÌÈàÎ¥µóÐ¡Ù²¦Î¡£ÏÇê¥  ESC 0,1,2  Ô¿àÇÎ¿ÎÁ´¹ÁÝ¸ÁÌÀÌÔ²á.$"
LineSpace       PROC    NEAR
		mov     bx,OFFSET Spacing3 +1     ;Esc 012 00<-- don't change
		cmp     BYTE PTR [bx],'0'
		je      Preserve
		cmp     BYTE PTR [bx],'1'
		je      Preserve
		cmp     BYTE PTR [bx],'2'
		je      Preserve
		call    Change_ac            ;change the chioce active
		mov     si,OFFSET MenualMess
		call    PrintMess
LineSp0:        mov     bx,OFFSET Spacing3 +2
		cmp     BYTE PTR [bx],0      ;lower limit
		jg      LineSp1
		mov     BYTE PTR [bx],99      ;start    = upper -1
LineSp1:        cmp     BYTE PTR [bx],100     ;upper limit
		jl      LineSp2
		mov     BYTE PTR [bx],1      ;end      = lower +1
LineSp2:        mov     cx,OFFSET ScrSpace +4   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		mov     di,2560 + 82
		mov     si,OFFSET ScrSpace +4   ;point to screen Data
		mov     ah,8fh                  ;bling attribute during change
		mov     cx,7                    ;langth of string
		call    Window_Scr
		mov     bx,OFFSET Spacing3 +2
		call    Key_Value
		jnc     LineSp0
		mov     di,2560 + 82
		mov     si,OFFSET ScrSpace +4     ;point to screen Data
		mov     ah,0fh
		mov     cx,7
		call    Window_Scr
		ret
Preserve:       mov     si,OFFSET PreserveMass
		call    PrintMess
		ret
LineSpace       ENDP


OffInnSpace     EQU     480 + 110 +160*11
InnerSpaceUp    PROC    NEAR
		call    Change_ac            ;change the chioce active
		mov     si,OFFSET MenualMess
		call    PrintMess
InnerSp0:       mov     bx,OFFSET Spacing1 +2
		cmp     BYTE PTR [bx],0      ;lower limit
		jg      InnerSp1
		mov     BYTE PTR [bx],99      ;start    = upper -1
InnerSp1:       cmp     BYTE PTR [bx],100     ;upper limit
		jl      InnerSp2
		mov     BYTE PTR [bx],1      ;end      = lower +1
InnerSp2:       mov     cx,OFFSET StrSpaceUp +11   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		mov     di,OffInnSpace
		mov     si,OFFSET StrSpaceUp +11   ;point to screen Data
		mov     ah,8fh                  ;bling attribute during change
		mov     cx,7                    ;langth of string
		call    Window_Scr
		mov     bx,OFFSET Spacing1 +2
		call    Key_Value
		jnc     InnerSp0
		mov     di,OffInnSpace
		mov     si,OFFSET StrSpaceUp +11     ;point to screen Data
		mov     ah,0fh
		mov     cx,7
		call    Window_Scr
		ret
InnerSpaceUp    ENDP

InnerSpaceDown  PROC    NEAR
		call    Change_ac            ;change the chioce active
		mov     si,OFFSET MenualMess
		call    PrintMess
InnerSpD0:      mov     bx,OFFSET Spacing2 +2
		cmp     BYTE PTR [bx],0      ;lower limit
		jg      InnerSpD1
		mov     BYTE PTR [bx],99      ;start    = upper -1
InnerSpD1:      cmp     BYTE PTR [bx],100     ;upper limit
		jl      InnerSpD2
		mov     BYTE PTR [bx],1      ;end      = lower +1
InnerSpD2:      mov     cx,OFFSET StrSpaceDown +11   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		mov     di,OffInnSpace+160
		mov     si,OFFSET StrSpaceDown +11   ;point to screen Data
		mov     ah,8fh                  ;bling attribute during change
		mov     cx,7                    ;langth of string
		call    Window_Scr
		mov     bx,OFFSET Spacing2 +2
		call    Key_Value
		jnc     InnerSpD0
		mov     di,OffInnSpace+160
		mov     si,OFFSET StrSpaceDown +11     ;point to screen Data
		mov     ah,0fh
		mov     cx,7
		call    Window_Scr
		ret
InnerSpaceDown  ENDP

OffPrnHdCode    EQU     480 + 118
AdjPrnHBk       PROC    NEAR
		call    Change_ac            ;change the chioce active
		mov     si,OFFSET MenualMess
		call    PrintMess
AdjPrnCod0:     mov     bx,OFFSET PrnHardBlkCod
		mov     cx,OFFSET StrPrnHB +15   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		mov     di,OffPrnHdCode
		mov     si,OFFSET StrPrnHB +15   ;point to screen Data
		mov     ah,8fh                  ;bling attribute during change
		mov     cx,3                    ;langth of string
		call    Window_Scr
		mov     bx,OFFSET PrnHardBlkCod
		call    Key_Value
		jnc     AdjPrnCod0
		mov     di,OffPrnHdCode
		mov     si,OFFSET StrPrnHB +15     ;point to screen Data
		mov     ah,0fh
		mov     cx,3
		call    Window_Scr
		ret
AdjPrnHBk       ENDP

OffPrnHdLen     EQU     480 +160+ 118
AdjPrnLen       PROC    NEAR
		call    Change_ac            ;change the chioce active
		mov     si,OFFSET MenualMess
		call    PrintMess
AdjPrnLen0:     mov     bx,OFFSET PrnHardBlkLen
		cmp     BYTE PTR [bx],0      ;lower limit
		jg      AdjPrnLen1
		mov     BYTE PTR [bx],9      ;start    = upper -1
AdjPrnLen1:     cmp     BYTE PTR [bx],10     ;upper limit
		jl      AdjPrnLen2
		mov     BYTE PTR [bx],1      ;end      = lower +1
AdjPrnLen2:     mov     cx,OFFSET StrPrnLen +15   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		mov     di,OffPrnHdLen
		mov     si,OFFSET StrPrnLen +15   ;point to screen Data
		mov     ah,8fh                  ;bling attribute during change
		mov     cx,3                    ;langth of string
		call    Window_Scr
		mov     bx,OFFSET PrnHardBlkLen
		call    Key_Value
		jnc     AdjPrnLen0
		mov     di,OffPrnHdLen
		mov     si,OFFSET StrPrnLen +15     ;point to screen Data
		mov     ah,0fh
		mov     cx,3
		call    Window_Scr
		ret
AdjPrnLen       ENDP

OffSrcHdCode    EQU     480 + 118 +160*4
AdjScrHBk       PROC    NEAR
		call    Change_ac            ;change the chioce active
		mov     si,OFFSET MenualMess
		call    PrintMess

AdjCod0:        mov     bx,OFFSET OffsetCode1 + 1
		mov     cx,OFFSET StrScrHB +15   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		mov     di,OffSrcHdCode
		mov     si,OFFSET StrScrHB +15   ;point to screen Data
		mov     ah,8fh                  ;bling attribute during change
		mov     cx,3                    ;langth of string
		call    Window_Scr
		mov     bx,OFFSET OffsetCode1 + 1  ;cmp al,20h
		call    Key_Value
		jnc     AdjCod0
		mov     bx,OFFSET OffsetCode1 + 1
		mov     al,[bx]
		mov     ScrHardBlkCod,al               ;same 3 where
		mov     bx,OFFSET OffsetCode2 + 1       ;menu, func, int8,
		mov     [bx],al
		mov     di,OffSrcHdCode
		mov     si,OFFSET StrScrHB +15     ;point to screen Data
		mov     ah,0fh
		mov     cx,3
		call    Window_Scr
		ret
AdjScrHBk       ENDP


OffSrcHdLen     EQU     480 + 118 +160*5

AdjScrLen       PROC    NEAR
		call    Change_ac            ;change the chioce active
		mov     si,OFFSET MenualMess
		call    PrintMess
Adjust0:        mov     bx,OFFSET ScrHardBlkLen
		cmp     BYTE PTR [bx],0      ;lower limit
		jg      Adjust1
		mov     BYTE PTR [bx],9      ;start    = upper -1
Adjust1:        cmp     BYTE PTR [bx],10     ;upper limit
		jl      Adjust2
		mov     BYTE PTR [bx],1      ;end      = lower +1
Adjust2:        mov     cx,OFFSET StrScrLen +15   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		mov     di,OffSrcHdLen
		mov     si,OFFSET StrScrLen +15   ;point to screen Data
		mov     ah,8fh                  ;bling attribute during change
		mov     cx,3                    ;langth of string
		call    Window_Scr
		mov     bx,OFFSET ScrHardBlkLen
		call    Key_Value
		jnc     Adjust0
		mov     di,OffSrcHdLen
		mov     si,OFFSET StrScrLen +15     ;point to screen Data
		mov     ah,0fh
		mov     cx,3
		call    Window_Scr
		ret
AdjScrLen       ENDP


NumSpeed      EQU     480 + (160*8) + 118

SpeedAdj        PROC    NEAR
		call    Change_ac            ;change the chioce active
		mov     si,OFFSET MenualMess
		call    PrintMess
		mov     BYTE PTR TimeRecode,0  ;Restart
Speed0:         mov     bx,OFFSET SpeedVAR
		cmp     BYTE PTR [bx],0
		jg      Speed1
		mov     BYTE PTR [bx],4
Speed1:         cmp     BYTE PTR [bx],5
		jl      Speed2
		mov     BYTE PTR [bx],1
Speed2:         mov     cx,OFFSET ScrSpeed +15   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		mov     di,NumSpeed
		mov     si,OFFSET ScrSpeed +15   ;point to screen Data
		mov     ah,8fh                  ;bling attribute during change
		mov     cx,3                    ;langth of string
		call    Window_Scr
		mov     bx,OFFSET SpeedVAR
		call    Key_Value
		jnc     Speed0
		mov     di,NumSpeed
		mov     si,OFFSET ScrSpeed +15     ;point to screen Data
		mov     ah,0fh
		mov     cx,3
		call    Window_Scr
		ret
SpeedAdj        ENDP
MenualMess      DB      'Ó¨á¹×à¿ÃØ¡ÅÁ¢ø·Ã¥ÈÁÜÊ¹×à¿©áÎÀ¢ÄÎ¹ÁÝ¸£àÎµó³áÊ¥¡ÎÁ  ÑÃÌ¡²¹×à¿ Enter ÊÚ¡£Áë¥Ð¼ûÊÊÊ¡¦Î¡¡ÎÁ³ë¥£àÎ$'

Window_Scr      PROC    NEAR
		push    es
		push    di
		mov     bx,WORD PTR OldPage
		mov     es,bx
		call    WriteLn                 ;write that
		pop     di
		pop     es
		ret
Window_Scr      ENDP

;------------------------------------
;BX point to VALUE
Key_Value       PROC    NEAR
KeyValue1:      mov     ah,1
		int     16h

		jz      KeyValue1
		mov     ah,0
		int     16h

		cmp     al,0            ;Is extcode
		je      KeyEXtcode
		cmp     al,0dh          ;return key
		je      KeyQuit
		jmp     KeyValue1
KeyEXtcode:     cmp     ah,4Bh          ;checking left arrow
		je      KeyDecValue
		cmp     ah,4Dh          ;   --    right arrow key
		je      KeyIndValue
		cmp     ah,48h          ;   --    up
		je      KeyAddTen
		cmp     ah,50h          ;   --    down
		je      KeySubTen
		jmp     KeyValue1

KeyIndValue:    inc     BYTE PTR [bx]
		jmp     KeyLoop
KeyDecValue:    dec     BYTE PTR [bx]
		jmp     KeyLoop
KeyAddTen:      add     BYTE PTR [bx],10
		jmp     KeyLoop
KeySubTen:      Sub     BYTE PTR [bx],10
		jmp     KeyLoop

KeyLoop:        clc
		ret
KeyQuit:        stc                     ;set carry flag
		ret
Key_Value       ENDP

;---------------------------------------------
;  bx,OFFSET Spacing3     Point to VALUE
;  cx,OFFSET ScrSpace +4  Point to Window
Value_Window   PROC    NEAR
		push    ds
		push    ax
		push    bx
		push    cx
		mov     al,[bx]               ;value  HEX
		mov     bx,cx
		xor     ah,ah                   ;clear up digit before divide
		mov     cl,64h                  ;digit 100
		div     cl
		xchg    ah,al                   ;alternate remainder , qoutial
		cmp     ah,0
		jne     NotZero
		mov     ah,-10h
NotZero:        add     ah,30h                  ;change to ASCII digit
		mov     [bx],ah                 ;move to screen line spaceing
		xor     ah,ah
		mov     cl,10                   ;digit 10
		div     cl
		cmp     al,0
		jne     NotZero2
		cmp     BYTE PTR [bx],20h                ;blank ASCII
		jne     NotZero2
		mov     al,-10h
NotZero2:       add     al,30h                  ;chage to ASCII
		add     ah,30h                  ;chage to ASCII
		mov     [bx+1],al
		mov     [bx+2],ah
		pop     cx
		pop     bx
		pop     ax
		pop     ds
		ret

Value_Window   ENDP

NotWork:        ret

CursorET        PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     WORD PTR ThaiEngStatus1,OFFSET CursorSta
		mov     WORD PTR ThaiEngStatus2,OFFSET CursorSta
		mov     BYTE PTR CurStatus,0
		ret
CursorET        ENDP

SoundET         PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     WORD PTR ThaiEngStatus1,OFFSET SoundSta
		mov     WORD PTR ThaiEngStatus2,OFFSET BlankSta
		mov     BYTE PTR CurStatus,1
		ret
SoundET         ENDP


CornerET        PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     WORD PTR ThaiEngStatus1,OFFSET CornerSta
		mov     WORD PTR ThaiEngStatus2,OFFSET CornerSta
		mov     BYTE PTR CurStatus,2
		RET
CornerET        ENDP

BlankSta        PROC    NEAR
		RET
BlankSta        ENDP

SoundSta        PROC    NEAR
		push    ax
		push    cx
		mov     al,0b6h
		out     43h,al
		mov     ax,EngSound             ;016dh  low frequensy = english
		cmp     BYTE PTR ETflag,0
		je      eng
		mov     ax,ThaiSound            ;01c7h  thai
eng:            mov     cx,0f00h                ;long time
		call    Sound
		pop     cx
		pop     ax
		ret
SoundSta        ENDP

Sound           PROC    NEAR
		push    ax
		push    cx
		cli
		out     42h,al
		mov     al,ah
		out     42h,al
		in      al,61h
		mov     ah,al
		or      al,3
		out     61h,al
	   ;     mov     cx,0f00h
S_delay:        loop    S_delay
		mov     al,ah
		out     61h,al
		sti
		pop     cx
		pop     ax
		ret
Sound           ENDP

CursorSta       PROC    NEAR
		push    dx
		push    cx
		push    bx
		push    ax
		cmp     BYTE PTR CurrMode,3    ; 8 line not work
		jb      CursorStaQuit
INCODE25::       mov     dx,0500h              ;English SIZE  VGA=0607h
		cmp     BYTE PTR ETflag,0
		je      CursorSta1
		mov     dx,0007h                        ;Thai   SIZE
CursorSta1:     mov     WORD PTR CursorLevel,dx
		mov     bx,OFFSET EnglishMode
		xor     ch,ch
		mov     cl,15
		mov     al,BYTE PTR CurrMode
		mul     cl
		add     bx,ax                   ;sourse
		mov     [bx+8],dx               ;save in table
		mov     cx,dx                   ;size
		mov     dx,WORD PTR IndexPort
		mov     al,10
		out     dx,al
		inc     dx
		mov     al,ch
		out     dx,al
		dec     dx
		mov     al,11
		out     dx,al
		inc     dx
		mov     al,cl
		out     dx,al

		inc     BYTE PTR NewVisit
CursorStaQuit:  pop     ax
		pop     bx
		pop     cx
		pop     dx
		ret
CursorSta       ENDP


CornerSta       PROC    NEAR
		push    bx
		push    ds
		push    es
		push    cx
		push    di
		push    si
		push    ax
		mov     bx,OFFSET BarStatus
		mov     ah,BYTE PTR [bx+1]
		mov     BYTE PTR [bx+2],127              ;E
		mov     BYTE PTR [bx+4],238              ;n
		mov     BYTE PTR [bx+6],231              ;g
		cmp     BYTE PTR ETflag,0
		je      CornerEng
		mov     BYTE PTR [bx+2],160              ;w
		mov     BYTE PTR [bx+4],086              ;m
		mov     BYTE PTR [bx+6],097              ;p thai
INCODE24::
CornerEng:      mov     cx,0b400h               ;new screen segment
		cmp BYTE PTR CurrMode,3
		jnz Notsub2
		sub ch,2
Notsub2:        mov     es,cx
		mov     si,OFFSET BarStatus
		mov     di,CornerPos            ;0136h
		mov     cx,5
		rep     movsw
		mov     al,37h                ;upper line
		sub     di,170           ;full block
		mov     cx,5
		rep     stosw
		pop     ax
		pop     si
		pop     di
		pop     cx
		pop     es
		pop     ds
		pop     bx
		ret
CornerSta       ENDP

PrinterFunc1    PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PrnfVAR,0
		mov     si,OFFSET EscStr1
		call    PrintSetup
		ret
PrinterFunc1    ENDP

PrinterFunc2    PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PrnfVAR,1
		mov     si,OFFSET EscStr2
		call    PrintSetup
		ret
PrinterFunc2    ENDP

PrinterFunc3    PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PrnfVAR,2
		mov     si,OFFSET EscStr3
		call    PrintSetup
		ret
PrinterFunc3    ENDP

PrinterFunc4    PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PrnfVAR,3
		mov     si,OFFSET EscStr4
		call    PrintSetup
		ret
PrinterFunc4    ENDP

PrinterFunc5    PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PrnfVAR,4
		mov     si,OFFSET EscStr5
		call    PrintSetup
		ret
PrinterFunc5    ENDP

PrinterFunc6    PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PrnfVAR,5
		mov     si,OFFSET EscStr6
		call    PrintSetup
		ret
PrinterFunc6    ENDP

PrinterFunc7    PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PrnfVAR,6
		mov     si,OFFSET EscStr7
		call    PrintSetup
		ret
PrinterFunc7    ENDP

PrinterFunc8    PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PrnfVAR,7
		mov     si,OFFSET EscStr8
		call    PrintSetup
		ret
PrinterFunc8    ENDP

PrinterFunc9    PROC    NEAR
		call    Change_ac       ;change the chioce active
		mov     BYTE PTR PrnfVAR,8
		mov     si,OFFSET EscStr9
		call    PrintSetup
		ret
PrinterFunc9    ENDP

;---------
; DS:SI ESC string
;---------------
PrintSetup      PROC    NEAR
		call lpt1stat                      ;check for printer ready
		jc PrtNotReady                         ;beep if printer not ready
		mov bl,255               ;specify delimiter for call to LPRINTZ
		call lprintz             ;send control code string to printer
		mov     si,OFFSET PrintOK
		call    PrintMess2              ;
		ret
PrtNotReady:    mov     si,OFFSET PrintNotOK    ;start point of string
		call    PrintMess2
		mov     cx,10
ErrerSound:     push    cx
		mov     ax,0113h                 ;thai
		mov     cx,0f00h                ;long time
		call    Sound
		pop     cx
		loop    ErrerSound
		ret


PrintMess::      mov     Msg_status,0000         ;reset flag, print new help message
PrintMess2:     push    es                      ;PrintMess2=Not clear message
		cmp   BYTE PTR cs:Active,1       ;Is menu active
		jnz     EndPrintMess             ;No
		mov     ax,WORD PTR cs:OldPage      ;B000 or B800 alternat segment
		mov     es,ax
		mov     dx,1403h                ;area of small window
		mov     ax,720h
		call    Clear_win               ;clear small window
		mov     ah,0dh                  ;Normal attribute <---0F/0B
		mov     di,3362                 ;offset of mediam line
		call    Central
		call    PrinThai                ;print Massege in window
EndPrintMess:   pop     es
		ret
PrintSetup      ENDP                               ;end of main body of program
PrintNotOK      DB      '¡ÎÁµÏ¥Î·ºÙ²¼ÃÎ² Ð£ÁûÊ¥¼Ù¿¼äÀÝ¥Ô¿à¼ÁáÊ¿µó¦ÌµÏ¥Î· ÓÈá³ÁÄ¦Ð£ÁûÊ¥¼Ù¿¼äÓÈ¿à$'
PrintOK         DB      'ÁÌÈÝÇ¼ÙÐÅÆÇà¥Ô¹ÓÈáÐ£ÁûÊ¥¼Ù¿¼äÐÁÚÀ¸ÁáÊÀÑÃáÄ$'

;---------------------------------------------------------------------------
;LPT1STAT checks the current status of printer LPT1:.  If it's either
;powered off or off-line, then an error condition is signalled upon return
;thru the carry flag.
;Exit:        Carry clear - no error
;             Carry set   - error
;---------------------------------------------------------------------------
;
lpt1stat      proc near
	      mov dx,0                  ;printer no. 0
	      mov ah,2                  ;use ROM BIOS 'get status' function
	      pushf
	      call DWORD PTR cs:Old_int17h_vector
	    ;  int 17h
	      xor  ah,10010000b
	      jz  stat1
	   ;   test ah,20h
	   ;   jne stat0
	   ;   test ah,8                 ;test bit 3, I/O error indicator
	   ;   je stat1                  ;if clear, then no error
stat0:         stc                       ;raise error flag
	      ret
stat1:        clc                       ;clear error flag
	      ret
lpt1stat      endp
;

;---------------------------------------------------------------------------
;LPRINTZ routine sends a string of bytes delimited by a user-specified byte to
;LPT1: thru INT 17h.
;Entry:       DS:SI - string address
;             BL    - delimiter (0-255)
;---------------------------------------------------------------------------
;
lprintz       proc near
	      cld                                ;for 8088 string instructions
lprintz1:     lodsb                              ;get one byte
	      cmp al,bl                          ;is it the delimiter?
	      je lprintz2                        ;yes, then exit
	      mov dx,0                           ;printer no. 0 (LPT1:)
	      mov ah,0
	      pushf
	      call DWORD PTR cs:Old_int17h_vector

	    ;  int 17h                            ;send byte to printer
	      jmp lprintz1                       ;return for next byte
lprintz2:     ret
lprintz       endp
;


CSEG        ENDS
		END
