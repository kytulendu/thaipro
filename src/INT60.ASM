OPTION PROC:PRIVATE
CSEG            SEGMENT PARA PUBLIC 'CODE'
		ASSUME  CS:CSEG, DS:CSEG

NumOfChoice     EQU     47-1
		EXTRN   RegionSum:NEAR
		EXTRN   BaseAdd:NEAR
		EXTRN   MaskAllow:NEAR
		EXTRN   OffsetAdd:NEAR
		EXTRN   work1:NEAR
		EXTRN   CurrMode:NEAR
		EXTRN   Setmode:NEAR

		EXTRN   BioPos:NEAR
		EXTRN   RefPos:NEAR
		EXTRN   IndexPort:NEAR

		EXTRN   CurMediaCode:NEAR
		EXTRN   CurrMode1:NEAR
		EXTRN   CurStatus:NEAR
		EXTRN   Typ_chk:NEAR
		EXTRN   CurLayOut:NEAR
		EXTRN   CurLangKey:NEAR
		EXTRN   CurPrnCode:NEAR
		EXTRN   CurPrnLev:NEAR
		EXTRN   CurPort:NEAR


		EXTRN   MenuRefresh:NEAR
		EXTRN   RefrOnOff:NEAR
		EXTRN   NewVisit:NEAR

		EXTRN   Spacing1:NEAR               ;spacing value
		EXTRN   Spacing2:NEAR
		EXTRN   Spacing3:NEAR
		EXTRN   StrSpaceUp:NEAR             ;screen spacing
		EXTRN   StrSpaceDown:NEAR
		EXTRN   ScrSpace:NEAR

		EXTRN   Value_Window:NEAR

		EXTRN   ScrHardBlkCod:NEAR
		EXTRN   ScrHardBlkLen:NEAR

		EXTRN   PrnHardBlkCod:NEAR
		EXTRN   PrnHardBlkLen:NEAR

		EXTRN   OffsetCode1:NEAR
		EXTRN   OffsetCode2:NEAR
		EXTRN   CurOffset:NEAR          ;FROM INT10.ASM


		EXTRN   StrScrHB:NEAR
		EXTRN   StrScrLen:NEAR
		EXTRN   StrPrnHB:NEAR
		EXTRN   StrPrnLen:NEAR

		EXTRN   SpeedVAR:NEAR
		EXTRN   ScrSpeed:NEAR
		EXTRN   DispTran:NEAR
		EXTRN   CodePr_convert:NEAR
		EXTRN   KbTran:NEAR
		EXTRN   LockReturn:NEAR
		EXTRN   Ctrl_key:NEAR
		EXTRN   Ctrl_keyTemp:NEAR
		EXTRN   Trademark:NEAR
		EXTRN   HeaderArea:NEAR
		EXTRN   ETflag:NEAR
		EXTRN   SetCurSor:NEAR
		EXTRN   RealScanCode:NEAR

		EXTRN   LockSpacing:NEAR
		EXTRN   ExtendFlag:NEAR
		EXTRN   PrnOneLeTrn:NEAR
		EXTRN   BarStatus:NEAR
		EXTRN   CornerPos:NEAR

		EXTRN   ColumnCount:NEAR
		EXTRN   VideoOffset:NEAR

		PUBLIC  Old_int6fh_vector
		PUBLIC  Old_int6fh_offs
		PUBLIC  Old_int6fh_seg
		PUBLIC  New_int6fh

		PUBLIC  VAR_int6f_int8
		PUBLIC  AdapterType

Old_int6fh_vector LABEL DWORD
Old_int6fh_offs   DW     ?
Old_int6fh_seg    DW     ?
		  DB    "TEST STRING"

int6fTable      LABEL   WORD
SetFunc0           DW      OFFSET MediaCode
SetFunc1           DW      OFFSET ScreenMode
SetFunc2           DW      OFFSET Status
SetFunc3           DW      OFFSET TypingCheck
SetFunc4           DW      OFFSET LayOutKay
SetFunc5           DW      OFFSET LanguageKey
SetFunc6           DW      OFFSET PrintCode
SetFunc7           DW      OFFSET PrintLevel
SetFunc8           DW      OFFSET PortNumber
SetFunc9           DW      OFFSET LineSpace
SetFunc10          DW      OFFSET PrnHardBkCode
SetFunc11          DW      OFFSET PrnHardBkLang
SetFunc12          DW      OFFSET ScrHardBkCode
SetFunc13          DW      OFFSET ScrHardBkLang
SetFunc14          DW      OFFSET SpeedOption    ;Menu command
SetFunc15          DW      OFFSET InnerSpaceUp
SetFunc16          DW      OFFSET InnerSpaceDown
SetFunc17          DW      OFFSET PrintSetup

MenuFunc             EQU     $-int6fTable

GetFunction         LABEL   WORD
GetFunc40       DW      OFFSET GetMediaCode
GetFunc41       DW      OFFSET GetScreenMode
GetFunc42       DW      OFFSET GetStatus
GetFunc43       DW      OFFSET GetTypeCk
GetFunc44       DW      OFFSET GetLayKey
GetFunc45       DW      OFFSET GetLangKey
GetFunc46       DW      OFFSET GetPrnCode
GetFunc47       DW      OFFSET GetPrnLev
GetFunc48       DW      OFFSET GetPort
GetFunc49       DW      OFFSET GetLinSp
GetFunc4A       DW      OFFSET GetPrnHBCode
GetFunc4B       DW      OFFSET GetPrnHBLength
GetFunc4C       DW      OFFSET GetScrHBCode
GetFunc4D       DW      OFFSET GetScrHBLength
GetFunc4E       DW      OFFSET GetSpeed
GetFunc4F       DW      OFFSET GetInnerSpUp
GetFunc50       DW      OFFSET GetInnerSpDown

MidleEnd        EQU  $-GetFunction

Utility         LABEL   WORD
SetFunc80           DW      OFFSET SysLock
SetFunc81           DW      OFFSET SysUnlock
SetFunc82           DW      OFFSET SetCursorXY
SetFunc83           DW      OFFSET AscIIlevel
SetFunc84           DW      OFFSET ChangeCode
SetFunc85           DW      OFFSET DataArea
SetFunc86           DW      OFFSET PopLock
SetFunc87           DW      OFFSET PopUnlock
SetFunc88           DW      OFFSET ChangePrt
SetFunc89           DW      OFFSET Tis2any
SetFunc8A           DW      OFFSET GetKey
SetFunc8B           DW      OFFSET SetKey
SetFunc8C           DW      OFFSET GetKeyEng
SetFunc8D           DW      OFFSET Fox80column
SetFunc8E           DW      OFFSET LockUnChoice
SetFunc8F           DW      OFFSET LockUnSubWin
SetFunc90           DW      OFFSET GetVersion
SetFunc91           DW      OFFSET GetCardType
SetFunc92           DW      OFFSET SetHeadExtend
SetFunc93           DW      OFFSET SetSpaceInnor
SetFunc94           DW      OFFSET SetPrn1LevTrsl
SetFunc95           DW      OFFSET SetCorPosSta
SetFunc96           DW      OFFSET Video_Mem
SetFunc97           DW      OFFSET Mem_Video0

Uend            EQU  $-Utility             ;When you appending please change in programe also.
UtilityFunc     EQU     (Uend/2)+80h-1

EngChar         DB      1Bh,31h,32h,33h,34h,35h,36h,37h,38h,39h,30h,2Dh,3Dh,08h,09h,71h,77h,65h,72h,74h,79h,75h,69h,6Fh,70h,5Bh,5Dh,0Dh,00h,61h,73h,64h,66h,67h,68h,6Ah,6Bh,6Ch,3Bh,27h,60h
		DB      00h,5Ch,7Ah,78h,63h,76h,62h,6Eh,6Dh,2Ch,2Eh,2Fh,00h,2Ah,00h,20h,00h,3Bh,3Ch,3Dh,3Eh,3Fh,40h,41h,46h,43h,44h,00h,00h,47h,48h,49h,2Dh,4Bh,00h,4Dh,2Bh,4Fh,50h,51h,52h,53h

SysLock         PROC    NEAR
		push    cs
		pop     ds
		push    cs
		pop     es

		mov     cx,80
		mov     si,OFFSET LockMessage
		mov     di,OFFSET Trademark
		rep     movsb
		mov     si,OFFSET LockReturn + 1
		mov     BYTE PTR [si],0ffh
		ret
SysLock         ENDP


UnLockMes       DB      ' Powersoft Co.,Ltd.                             Thai Professional VGA/EGA V3.10 $'
LockMessage     DB      ' <<<<  System Locked now!  >>>>                 Thai Professional VGA/EGA V3.10 $'

SysUnlock       PROC    NEAR
		push    cs
		pop     ds
		push    cs
		pop     es

		mov     cx,80
		mov     si,OFFSET UnLockMes
		mov     di,OFFSET Trademark
		rep     movsb
		mov     si,OFFSET LockReturn + 1
		mov     BYTE PTR [si],00dh

		mov     cx,NumOfChoice+1
		mov     bx,OFFSET MaskAllow
		mov     dl,0                    ;Unlock all choice
BeFree:         mov     [bx],dl                 ;0 allow, 1 notwork
		inc     bx
		loop    BeFree
		ret
SysUnlock       ENDP

LockFlag        DB      0
PopLock         PROC    NEAR
		push    cs
		pop     ds
		push    cs
		pop     es
		cmp     LockFlag,0                 ;check coming flag
		jnz      PopLockEnd

		mov     ax,WORD PTR Ctrl_key
		mov     WORD PTR Ctrl_keyTemp,ax             ;save control key

		mov     WORD PTR Ctrl_key,0FFFFh   ;any key
		mov     LockFlag,1                 ;
PopLockEnd:     ret
PopLock         ENDP

PopUnlock       PROC    NEAR
		push    cs
		pop     ds
		push    cs
		pop     es

		mov     ax,WORD PTR Ctrl_keyTemp           ;
		mov     WORD PTR Ctrl_key,ax     ;restore control key
		mov     LockFlag,0               ;clear flag

		ret
PopUnlock       ENDP

SetCursorXY     PROC    NEAR
		call    SetCurSor               ;set cursor in 25 bios
		ret
SetCursorXY     ENDP

AscIIlevel      PROC    NEAR
		  xor   dl,dl                   ;clear flag
		  cmp   al,128                  ;if code under 128 not change
		  jb    mediam                  ;below 128 goto mediam directly
		  mov   bx,WORD PTR DispTran       ;get address of table
		  xlat                          ;chang code
untransl:         cmp   al,0D1h
		  je    SHORT upper0            ;go set DL flag
		  cmp   al,0D4h                 ;
		  jb    SHORT mediam
		  cmp   al,0DBh
		  jb    SHORT upper0            ;go set DL flag
		  cmp   al,0E7h                 ;
		  jb    SHORT mediam
		  je    SHORT special
		  cmp   al,0EDh
		  ja    SHORT mediam            ;more than 0EDh is mediam line
		  jmp   SHORT special           ;Barlee special
	   ;      cmp   al,0ECh
	   ;      jne   SHORT upper0            ;more than and less than goto
	   ;      cmp   cl,0D4h                 ;cl save Old charecter
	   ;      je    SHORT upper0
	   ;      cmp   cl,0D8h
	   ;      je    SHORT  upper0
	   ;       jmp   SHORT special           ;any set special
special:          inc   dl              ;DL=2 Tell Way0=F2 ,Way1= wrong way
upper0:           inc   dl              ;DL=1 tell way0=F1 ,way1=Wrong
mediam:           mov   al,dl
		ret
AscIIlevel      ENDP

ChangeCode      PROC    NEAR
		cmp     al,128
		jb      ChangeCodeQuit
		mov   bx,WORD PTR DispTran       ;Table Code
		xlat                  ;chang code

ChangeCodeQuit: ret
ChangeCode      ENDP

ChangePrt       PROC    NEAR
		cmp     al,128
		jb      ChangePrtQuit
		mov   bx,WORD PTR CodePr_convert       ;Table Code
		xlat                  ;chang code

ChangePrtQuit::  ret
ChangePrt       ENDP


Tis2any         PROC    NEAR
		cmp     al,128
		jb      ChangePrtQuit
		mov     bx,WORD PTR KbTran       ;Table Code
		xlat                           ;chang code
		ret
Tis2any         ENDP

GetKey          PROC    NEAR
		mov     al,BYTE PTR ETflag
		ret
GetKey          ENDP
SetKey          PROC    NEAR
		mov     BYTE PTR ETflag,al      ; 0 = Eng, NonZero = thai
		ret
SetKey          ENDP

GetKeyEng       PROC    NEAR
		mov     ah,00                   ;func 0 Read char from Keybuff
		int     16h
		cmp     BYTE PTR ETflag,0
		jz      GetKeyEngEnd
		mov     al,BYTE PTR RealScanCode         ;copy scan code
		dec     al                      ;table start from 0
		mov     bx,OFFSET EngChar
		xlat
GetKeyEngEnd:   ret
GetKeyEng       ENDP

Fox80column     PROC    NEAR
		mov     bp,sp
		pushf                           ;save another flag
		push    ds
		xor     ax,ax
		mov     ds,ax
		mov     bx,WORD PTR ds:[450h]   ;get row number
		pop     ds

		mov     al,80                   ;one row=80
		mul     bh                      ;*row
		shl     ax,1                    ;*2
		add     ax,79                   ;add endofline _____|80column

		popf                            ;restore old flag
		inc     dl
		mov     BYTE PTR [bp+10],dl         ;inc DL

		cmp     BYTE  PTR CurrMode,04h                                  ;25 bios
		jb      OriginalMode

		cmp     WORD PTR cs:CurOffset,ax   ;cmp DL,80 column
		pushf
		pop     ax
		mov     BYTE PTR [bp+20],al
		ret

OriginalMode:   cmp     dl,80
		pushf
		pop     ax
		mov     BYTE PTR [bp+20],al
		ret

Fox80column     ENDP

LockUnChoice    PROC    NEAR
		test    al,80h                  ;test Lock Unlock bit
		mov     dl,1
		jnz     LockingChoice
		mov     dl,0                    ;set Unlock
LockingChoice:  and     al,01111111b            ;turn off flag bit
		cmp     al,NumOfChoice          ;number of choice -1 (begin 0)
		ja      LockingEnd
		xor     ah,ah
		mov     bx,OFFSET MaskAllow
		add     bx,ax
		mov     [bx],dl         ;0 allow, 1 notwork
LockingEnd:     ret
LockUnChoice    ENDP


NumOfSubWin     EQU     14
RegionWin       DB      00,05,11,14,16,18,23,25,27,30,31,33,35,36,38,47
LockUnSubWin    PROC    NEAR
		test    al,80h                  ;test Lock Unlock bit
		mov     dl,1
		jnz     LockingSubWin
		mov     dl,0                    ;set Unlock
LockingSubWin:  and     al,01111111b            ;turn off flag bit
		cmp     al,NumOfSubWin          ;number of sub window
		ja      LockSubWinEnd
		xor     ah,ah
		push    ax
		inc     al                      ;next sub window for fine counter
		mov     bx,OFFSET RegionWin
		xlat                            ;find stop position
		mov     cl,al
		xor     ch,ch

		pop     ax
		mov     bx,OFFSET RegionWin
		xlat                            ;find start position
		sub     cl,al                   ;cal counter
		mov     bx,OFFSET MaskAllow
		add     bx,ax

LockSubWinFill: mov     [bx],dl         ;0 allow, 1 notwork
		inc     bx
		loop    LockSubWinFill
LockSubWinEnd:  ret
LockUnSubWin    ENDP

GetVersion      PROC    NEAR
		mov     ax,0300h                ;ThaiPro version 3.00
		ret
GetVersion      ENDP

AdapterType     DB  6                           ;EGA=2 VGA=6   (default VGA)

GetCardType     PROC    NEAR
		mov     al,AdapterType
		ret
GetCardType     ENDP


SetHeadExtend   PROC    NEAR
		mov     BYTE PTR ExtendFlag,al
		ret
SetHeadExtend   ENDP

SetSpaceInnor   PROC    NEAR
		mov     BYTE PTR LockSpacing,al
		ret
SetSpaceInnor   ENDP

SetPrn1LevTrsl  PROC    NEAR
		mov     BYTE PTR PrnOneLeTrn,al
		ret
SetPrn1LevTrsl  ENDP

SetCorPosSta    PROC    NEAR
		mov     cx,5
		mov     bx,OFFSET BarStatus
SetCor:         inc     bx
		mov     [bx],al                 ;color
		inc     bx                      ;across char
		loop    SetCor
		mov     WORD PTR CornerPos,dx
		ret
SetCorPosSta    ENDP

;___________________________________________________________________
;
;       video_memory is routinr move window in video buffer to save in
;       another memory.
;       entry:  DS      - segment of video buffer
;               ES:DI   - memory buffer
;               DH,DL   - row and column of upper left corner of window
;               CH      - width of window in column
;               CL      - number of lines in window
;
;___________________________________________________________________

Video_Mem       proc    near
		mov     bp,sp
		mov     ax,[bp+4]          ;ds
		mov     ds,ax

		mov     al,ch           ;store number of column
		mov     ah,0
		mov     WORD PTR es:ColumnCount,ax
		mov     ch,0            ;CX = number of lines
		push    di              ;save DI
		call    VideoOffset     ;get address of frist char
		mov     si,di           ;put it in SI
		pop     di              ;restore DI
V_mem1:         push    si              ;save SI for next line
		push    cx              ;save line count
		mov     cx,WORD PTR es:ColumnCount       ;set CX for call WriteL
		call    WriteLn         ;transfer one line
		pop     cx              ;restore count
		pop     si              ;
		add     si,160          ;set SI for next line addr
		loop    V_mem1          ;loop until all line are done
		ret
Video_Mem       endp
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

Mem_Video0    proc       near
		mov     bp,sp
		mov     ax,[bp+6]          ;si
		mov     si,ax
		mov     ax,[bp+4]          ;ds
		mov     ds,ax

		mov     al,ch           ;save number of columns
		mov     ah,0
		mov     WORD PTR ds:ColumnCount,ax
		mov     ch,0            ;CX = number of  lines
		call    VideoOffset     ;get address
Mem_V1:         push    di              ;save video strating addr
		push    cx              ;save line count
		mov     cx,WORD PTR ds:ColumnCount  ;
		call    WriteLn         ;move one line
		pop     cx
		pop     di
		add     di,160
		loop    Mem_V1
		ret
Mem_Video0       endp

WriteLn         proc    near
		cld
Write1:         movsw                   ;move one word
		loop    Write1
		ret
WriteLn         endp


DataArea        PROC    NEAR
		mov     bp,sp
		mov     ax,cs
		mov     [bp+2],ax
		mov     WORD PTR [bp+12+2],OFFSET HeaderArea
		ret
DataArea        ENDP

;*******I AM HERE************************************
GetMediaCode    PROC    NEAR
		mov     al, BYTE PTR CurMediaCode
		ret
GetMediaCode    ENDP

GetScreenMode   PROC    NEAR
		mov     al,BYTE PTR CurrMode1
		ret
GetScreenMode   ENDP

GetStatus       PROC    NEAR
		mov     al,BYTE PTR CurStatus
		ret
GetStatus       ENDP

GetTypeCk       PROC    NEAR
		mov     al,BYTE PTR Typ_chk
		ret
GetTypeCk       ENDP

GetLayKey       PROC    NEAR
		mov     al,BYTE PTR CurLayOut
		ret
GetLayKey       ENDP

GetLangKey      PROC    NEAR
		mov     al,BYTE PTR CurLangKey
		ret
GetLangKey      ENDP

GetPrnCode      PROC    NEAR
		mov     al,BYTE PTR CurPrnCode
		ret
GetPrnCode      ENDP

GetPrnLev       PROC    NEAR
		mov     al,BYTE PTR CurPrnLev
		ret
GetPrnLev       ENDP

GetPort         PROC    NEAR
		mov     al,BYTE PTR CurPort
		ret
GetPort         ENDP

GetLinSp        PROC    NEAR
		mov     al,BYTE PTR Spacing3 +2
		ret
GetLinSp        ENDP

GetPrnHBCode    PROC    NEAR
		mov     al,BYTE PTR PrnHardBlkCod
		ret
GetPrnHBCode    ENDP

GetPrnHBLength  PROC    NEAR
		mov     al,BYTE PTR PrnHardBlkLen
		ret
GetPrnHBLength  ENDP

GetScrHBCode    PROC    NEAR
		mov     al,BYTE PTR ScrHardBlkCod
		ret
GetScrHBCode    ENDP

GetScrHBLength  PROC    NEAR
		mov     al,BYTE PTR ScrHardBlkLen
		ret
GetScrHBLength  ENDP

GetSpeed        PROC    NEAR
		mov     al,BYTE PTR SpeedVAR
		ret
GetSpeed        ENDP

GetInnerSpUp    PROC    NEAR
		mov     al,BYTE PTR Spacing1 +2
		ret
GetInnerSpUp    ENDP

GetInnerSpDown  PROC    NEAR
		mov     al,BYTE PTR Spacing2 +2
		ret
GetInnerSpDown  ENDP



New_int6fh      PROC  NEAR
			    ;flag  20
			    ;cs    18
			    ;ip    16

		push  bx    ;      14
		push  cx    ;      12
		push  dx    ;      10
		push  di    ;      8
		push  si    ;      6
		push  ds    ;      4
		push  es    ;      2

		push    cs              ;RST programe
		pop     ds

		cmp     ah,40h          ;start get function MENU
		jb      Lowerfunc
		cmp     ah,80h          ;start Utility fucntion number
		jb      Midlefunc

		cmp     ah,UtilityFunc
		ja      VideoReturn     ;quit

		push    ax
		sub     ah,80h          ;change ah -> 0 Open table
		mov     al,ah           ;to low byte
		xor     ah,ah           ;zero high byte
		sal     ax,1            ;*2 look up
		mov     si,ax           ; put to si for branch
		cmp     ax,Uend
		pop     ax
		jae     VideoReturn
		call    cs:[si+OFFSET Utility]
		jmp     VideoReturn

Lowerfunc:      cmp     ah,MenuFunc                  ;test out of menu routine
		ja      VideoReturn             ;Yes OutOfMenu:
		push    ax
		mov     BYTE PTR OffsetAdd,al   ;set OffsetAdd
		mov     bx,OFFSET RegionSum     ;No > calculate base address
		xchg    al,ah                   ;alternate between AL AH
		xlat
		mov     BYTE PTR BaseAdd,al    ;set BaseAddress

		pop     ax
		push    ax

		mov     al,ah           ;to low byte
		xor     ah,ah           ;zero high byte
		sal     ax,1            ;*2 look up
		mov     si,ax           ; put to si for branch
		cmp     ax,MenuFunc


		pop     ax              ;offset in AL
		jae     VideoReturn
		call    cs:[si+OFFSET int6fTable]
		jmp     VideoReturn
Midlefunc:
		push    ax
		sub     ah,40h          ;change ah -> 0 Open table
		mov     al,ah           ;to low byte
		xor     ah,ah           ;zero high byte
		sal     ax,1            ;*2 look up
		mov     si,ax           ; put to si for branch
		cmp     ax,MidleEnd
		pop     ax
		jae     VideoReturn
		call    cs:[si+OFFSET GetFunction]


VideoReturn:    pop   es
		pop   ds    ;0
		pop   si
		pop   di
		pop   dx    ;6
		pop   cx
		pop   bx
		iret


New_int6fh      ENDP


MediaCode       PROC    NEAR
		cmp     al,4
		ja      MediaCodeEnd
		call    HelpThem
MediaCodeEnd:   ret
MediaCode       ENDP

ScreenMode      PROC    NEAR
		cmp     al,5
		ja      ScreenModeEnd

		push    ax
		mov     dx,WORD PTR cs:IndexPort
		add     dx,0006h
		in      al,dx
		mov     al,0
		mov     dx,3C0h                 ;off screen
		out     dx,al
		pop     ax

		push    ds
		xor     cx,cx
		mov     ds,cx
		mov     dx,WORD PTR ds:[450h]                   ;get cursor pos
		pop     ds

		cmp     BYTE  PTR CurrMode,04h                                  ;25 bios
		jb      ItRefresh
		mov     WORD PTR BioPos,dx                      ;save to bios variable
		jmp     NotRef
ItRefresh:      mov     WORD PTR RefPos,dx

NotRef:

		add     al,BYTE PTR BaseAdd      ;find the line position on screen
		mov     bx,OFFSET work1
		xor     ah,ah           ;clear
		shl     ax,1            ;multiple by 2
		add     bx,ax           ;point that address
		call    WORD PTR cs:[bx]         ;call working
		cli
		mov     al,BYTE PTR MenuRefresh
		mov     BYTE PTR RefrOnOff,al     ;return old status for Refresher
		mov     al,BYTE PTR CurrMode1      ;after Menu PUSH DOWN
		mov     BYTE PTR CurrMode,al
		call    Setmode

		sti
ScreenModeEnd:  ret
ScreenMode      ENDP

Status          PROC    NEAR
		cmp     al,2
		ja      StatusEnd
		call    HelpThem
StatusEnd:      ret
Status          ENDP


TypingCheck     PROC    NEAR
		cmp     al,1
		ja      TypingCheckEnd
		call    HelpThem
TypingCheckEnd: ret
TypingCheck     ENDP

LayOutKay       PROC    NEAR
		cmp     al,1
		ja      LayOutKayEnd
		call    HelpThem
LayOutKayEnd:   ret
LayOutKay       ENDP

LanguageKey     PROC    NEAR
		cmp     al,4
		ja      LanguageKeyEnd
		call    HelpThem
LanguageKeyEnd: ret
LanguageKey     ENDP

PrintCode       PROC    NEAR
		cmp     al,1
		ja      PrintCodeEnd
		call    HelpThem
PrintCodeEnd:   ret
PrintCode       ENDP

PrintLevel      PROC    NEAR
		cmp     al,1
		ja      PrintLevelEnd
		call    HelpThem
PrintLevelEnd:  ret
PrintLevel      ENDP

PortNumber      PROC    NEAR
		cmp     al,2
		ja      PortNumberEnd
		call    HelpThem
PortNumberEnd:  ret
PortNumber      ENDP

;  bx,OFFSET Spacing3     Point to VALUE
;  cx,OFFSET ScrSpace +4  Point to Window

LineSpace       PROC    NEAR

		mov     bx,OFFSET Spacing3 +1     ;Esc 012 00<-- don't change
		cmp     BYTE PTR [bx],'0'
		je      LineUnChange
		cmp     BYTE PTR [bx],'1'
		je      LineUnChange
		cmp     BYTE PTR [bx],'2'
		je      LineUnChange

		mov     bx,OFFSET Spacing3 +2
		mov     [bx],al                 ;save new Line Spacing Value
		mov     cx,OFFSET ScrSpace +4   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
LineUnChange:   ret
LineSpace       ENDP

InnerSpaceUp    PROC    NEAR
		mov     bx,OFFSET Spacing1 +2
		mov     [bx],al                 ;save new Line Spacing Value
		mov     cx,OFFSET StrSpaceUp +11   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		ret
InnerSpaceUp    ENDP

InnerSpaceDown  PROC    NEAR
		mov     bx,OFFSET Spacing2 +2
		mov     [bx],al                 ;save new Line Spacing Value
		mov     cx,OFFSET StrSpaceDown +11   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		ret
InnerSpaceDown  ENDP

PrnHardBkCode   PROC    NEAR
		mov     bx,OFFSET PrnHardBlkCod
		mov     [bx],al                 ;save new Line Spacing Value
		mov     cx,OFFSET StrPrnHB +15   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		ret
PrnHardBkCode   ENDP

;this routine for int6f func A
;             for Booter
VAR_int6f_int8  PROC    NEAR
		push    cs
		pop     ds
		mov     al,BYTE PTR ScrHardBlkCod                ;same 3 where
		mov     bx,OFFSET OffsetCode1 + 1
		mov     [bx],al
		mov     bx,OFFSET OffsetCode2 + 1       ;menu func int8
		mov     [bx],al
		ret
VAR_int6f_int8  ENDP


PrnHardBkLang   PROC    NEAR
		mov     bx,OFFSET PrnHardBlkLen
		mov     [bx],al                         ;save new Line Spacing Value
		mov     cx,OFFSET StrPrnLen +15         ;point to screen Data
		call    Value_Window                    ;accept Data to update Screen

		ret
PrnHardBkLang   ENDP

ScrHardBkCode   PROC    NEAR
		mov     bx,OFFSET OffsetCode1 + 1       ;real Screen Hard Code
		mov     [bx],al                         ;save new Line Spacing Value
		mov     BYTE PTR ScrHardBlkCod,al       ;same 3 where
		mov     bx,OFFSET OffsetCode2 + 1       ; func,menu, int8,
		mov     [bx],al

		mov     cx,OFFSET StrScrHB +15          ;point to screen Data
		call    Value_Window                    ;accept Data to update Screen
		ret
ScrHardBkCode   ENDP

ScrHardBkLang   PROC    NEAR
		mov     bx,OFFSET ScrHardBlkLen
		mov     [bx],al                 ;save new Line Spacing Value
		mov     cx,OFFSET StrScrLen +15   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen
		ret
ScrHardBkLang   ENDP

SpeedOption   PROC
		mov     bx,OFFSET SpeedVAR
		mov     [bx],al                 ;save new Line Spacing Value
		mov     cx,OFFSET ScrSpeed +15   ;point to screen Data
		call    Value_Window        ;accept Data to update Screen

		ret
SpeedOption   ENDP

PrintSetup      PROC    NEAR
		cmp     al,8                    ;8th function
		ja      PrintSetupEnd
		call    HelpThem
PrintSetupEnd:  ret
PrintSetup      ENDP


HelpThem        PROC    NEAR
		add     al,BYTE PTR BaseAdd      ;find the line position on screen
		mov     bx,OFFSET work1
		xor     ah,ah           ;clear
		shl     ax,1            ;multiple by 2
		add     bx,ax           ;point that address
		call    WORD PTR cs:[bx]         ;call working
		ret
HelpThem        ENDP

CSEG        ENDS
		END
