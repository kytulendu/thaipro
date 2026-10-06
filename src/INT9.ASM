OPTION PROC:PRIVATE

CSEG            SEGMENT PARA PUBLIC 'CODE'
		ASSUME  CS:CSEG, DS:CSEG

		EXTRN   Menu:NEAR,Setmode:NEAR
		EXTRN   ThaiEngStatus1:NEAR
		EXTRN   ThaiEngStatus2:NEAR
		EXTRN   CurrMode1:NEAR, CurrMode:NEAR, MenuRefresh:NEAR
		EXTRN   Code8line1:NEAR, Code8line:NEAR
		EXTRN   RefrOnOff:NEAR, NewVisit:NEAR
		EXTRN   OldPage:NEAR
		EXTRN   TableTIS:NEAR
		EXTRN   DispTran:NEAR
		EXTRN   LastChar:NEAR
		EXTRN   Sound:NEAR

		EXTRN   ETflag:NEAR
		EXTRN   Hot_Key:NEAR
		EXTRN   Ctrl_key:NEAR
		EXTRN   Lang_key:NEAR
		EXTRN   KB_layout:NEAR
		EXTRN   Typ_chk:NEAR
		EXTRN   KbTran:NEAR
		EXTRN   SetCurSor:NEAR


		PUBLIC  Old_int09h_offs
		PUBLIC  Old_int09h_seg
		PUBLIC  New_int09h
		PUBLIC  Old_int16h_vector
		PUBLIC  Old_int16h_offs
		PUBLIC  Old_int16h_seg

		PUBLIC  RealScanCode
		PUBLIC  Active
		PUBLIC  MANEE1
		PUBLIC  CHOID1

Bios_data       SEGMENT AT      40h

		ORG     17h
		Kbd_stat DW      ?
		ORG     1Ah
		Head    DW      ?
		Tail    DW      ?
		Buffer  DW      16      DUP(?)
		Buffer_end      LABEL WORD
		ORG     50h
		Curpos  DW      ?
Bios_data       ENDS

;**************************************************************************
;below is KEY BOARD section
;

Ctrlkey         EQU     0004h
Shift_on        EQU     0003h
Caps_on         EQU     0040h
KeyTable1       EQU     0012h           ; ScroolLock, Left shift
KeyTable2       EQU     0011h           ; ScroolLock, Right shift

New_int09h      PROC  NEAR
		cmp     cs:Active,0h    ;Menu active?
		je     in_act           ;Yes. Disable Thai keyboard
		jmp     cs:Old_int09h_vector
in_act:         sti                     ;interrupt flag on
		push    es
		push    ds
		push    si
		push    di
		push    dx
		push    cx
		push    bx
		push    ax

		push    cs             ;must be reinitial for RST program
		pop     ds
		cld                    ;clear direction flag for String Instruction
		mov     ax,40h         ;bios data area
		mov     es,ax
		in      al,60h          ;get scan code dirrectry

		mov    ds:RealScanCode,al ;save scan code

		cmp     al,BYTE PTR Hot_Key     ;3bh = F1 key , HOT key?
		jne     LangKey           ;No. goto Next key check
		mov     dx,es:Kbd_stat
		and     dx,WORD PTR Ctrl_key     ;mark bit
		cmp     dx,WORD PTR Ctrl_key     ;Is the Hot key "Ctrl-F1"?
		jne     LangKey
		call    ChangIn
		call    Kb_reset
		push    cs   ;call far program
		call    Menu             ;Yes go POP-UP Menu
		call    ChangOut
	;    inc     BYTE PTR NewVisit
		push     ds
		xor      ax,ax
		mov      ds,ax           ;bios data segment
		mov      dx,ds:[450h]         ;save col row in BIOS variable
		pop      ds
		cmp      BYTE PTR CurrMode,4    ;it's 25 bios, 25 mix
		jae      _25biosSet

		mov      ah,2
		mov      bh,0
		int      10h
		jmp     k_quit
_25biosSet:     call    SetCurSor
		jmp     k_quit

LangKey:        cmp     al,BYTE PTR Lang_key     ;Is Language key
		jne     Not_intercept
		mov     dx,es:Kbd_stat
		and     dx,0F00Fh         ;except when control key Press
		jnz     Not_intercept     ;if any of key pressed go out
		not     BYTE PTR ETflag          ;toggle Thai/English flag
		call    WORD PTR cs:ThaiEngStatus1
		call    Kb_reset
		jmp     k_quit

Not_intercept:  call    WORD PTR cs:ThaiEngStatus2
		mov     di,es:Tail         ;get position of tail
		mov     si,es:Head          ;and Head for THAI_K
		pushf
		call    cs:Old_int09h_vector

		mov     dx,es:Kbd_stat
		and     dx,Ctrlkey     ;if Control key press goto english
		cmp     dx,Ctrlkey     ;
		je      k_quit           ;Yes English (by passing)
		call    LineGraph
		cmp     BYTE PTR ETflag,0       ;English/Thai flag?
		je      k_quit           ;Yes English (by passing)
		call    Th_process             ;,No goto Thai Processor
k_quit:         pop     ax
		pop     bx
		pop     cx
		pop     dx
		pop     di
		pop     si
		pop     ds
		pop     es
		iret                    ;exit

New_int09h      ENDP

LineGraph       PROC    NEAR
		mov     bx,OFFSET BLOCK1
		mov     dx,es:Kbd_stat
		and     dx,KeyTable1    ;test line graphic 1
		cmp     dx,KeyTable1    ;
		je      LineGraph1
		mov     bx,OFFSET BLOCK2
		mov     dx,es:Kbd_stat
		and     dx,KeyTable2    ;test line graphic 2
		cmp     dx,KeyTable2    ;
		je      LineGraph1
LineQuit:       ret
LineGraph1:
LineGraph2:     cmp     di,es:Tail        ;test shifting old-new position
		je      LineQuit
		cmp     al,047h           ;key pad number 7
		jb      LineQuit
		cmp     al,051h           ;key number 3
		ja      LineQuit
		push    ax
		push    bx
		push    cx
		push    dx
		sub     al,047h         ;Reduce scan code for short table
		jmp     over_chk        ;let's over checking



LineGraph       ENDP
;-----------------------------------------------------------------------------
;Use    DI = Old tail   SI  = Old head
;
;       AL = Scan code
Th_process          PROC    NEAR
		push    ax
		push    bx
		push    cx
		push    dx
		cmp     di,es:Tail        ;test shifting old-new position
		je      Th_PQuit
		mov     bx,WORD PTR KB_layout
		mov     dx,es:Kbd_stat
		and     dx,Shift_on       ;
		jz      Lim_key           ; shift off
		add     bx,OFFSET MANEE2 - MANEE1
		jmp     Lim_key
	    ;    cmp     al,047h           ;key pad number 7
	    ;    jb      Lim_key
	    ;    cmp     al,051h           ;key number 3
	    ;    ja      Lim_key
	    ;    mov     bx,OFFSET BLOCK   ;base point table1
	    ;    sub     al,047h         ;Reduce scan code for short table
	    ;    jmp     over_chk        ;let's over checking

Th_PQuit:       pop     dx
		pop     cx
		pop     bx
		pop     ax
		ret

Lim_key:        cmp     al,035h         ;check scan code limit 0-35?
		ja      Th_PQuit          ;Yes! out off range to quit
over_chk::       xor     ah,ah           ;clear upper significant
		add     bx,ax           ;reach table
		mov     al,[bx]         ;get Acsii from ASCII TABLE
		mov     ch,al           ;Save before branch
		mov     cl,0            ;flag off
		cmp     BYTE PTR Typ_chk,01h      ;Typeing check 00 /no check 01
		je      ReplaceCon         ;yes it's No check go out

		cmp     al,0D1h         ;
		je      Th_filter       ;checking the Thai ASCII can replace
		cmp     al,0D4h         ;
		jb      ReplaceCon         ;less than D4 allow Ascii
		cmp     al,0DAh
		jbe      Th_filter       ;Must be pass Thai filter.
		cmp     al,0E7h
		jb      ReplaceCon
		cmp     al,0E7h
		je      Th_filter
		cmp     al,0EDh
		je      Th_filter
		ja     Replace         ;
		mov     cl,1            ;flag on
Th_filter:      cmp     di,si           ;compare old Head=Tail
		jne     K_buf           ;Head != Tail to read Tail-1

		mov     dx,es:Curpos       ;read cursor position
		mov     al,160          ; 160 byte a line
		mul     dh              ;multiple by Row
		xor     dh,dh           ;
		shl     dx,1            ; column * 2
		add     ax,dx           ;add Column
		sub     ax,2              ;Cur-1  position
		mov     bx,ax           ;chang to base register
		cmp     BYTE PTR CurrMode,3    ;refresh mode
		jne     GetBios

		push    es              ;save bios_data segment
		mov     ax,WORD PTR cs:OldPage   ;b000, b800
		mov     es,ax           ;set es = screen segment
		mov     ax,es:[bx]      ;old Ascii from Screen
		pop     es              ;restore bios_data segment
		mov     bx,WORD PTR DispTran    ;translat
		xlat
		jmp     T_analist       ;(AL = ASCII)
ReplaceCon:     jmp     Replace

GetBios:        mov     al,cs:BYTE PTR LastChar
		jmp     T_analist

K_buf:          sub     di,2
		cmp     di,OFFSET Buffer
		jae     No_Wrap1
		mov     di,OFFSET Buffer_end
		sub     di,2
No_Wrap1:       mov     ax,es:[di]         ;old Ascii from buffer tail-2(Al= ASCII)
T_analist:      cmp     al,0A1h
		jb      Back_step
		cmp     al,0CFh
		jb      Replace
		cmp     al,0D1h
		je      next_chk
		cmp     al,0D4h
		jb      Back_step
		cmp     al,0DAh         ;o oo o
		ja      Back_step
next_chk:       cmp     cl,1            ;test flag on
		jne     Back_step
		cmp     ch,0ECh         ;appen
		jne     Replace         ;No normal way
		cmp     al,0D4h         ;first character allow
		je      Replace
		cmp     al,0D8h         ;second character allow
		jne     Back_step
Replace:        cmp     ch,128
		jb      unopen
		mov     bx,WORD PTR KbTran     ;get address backward 128
		mov     al,ch           ;transfer to
		mov     dl,ch           ;cl internal code
		xlat                           ;open table
		mov     ch,al                  ;transfer back
unopen:         mov     bx,es:Tail
		sub     bx,2
		cmp     bx,OFFSET Buffer
		jae     no_wrap2
		mov     bx,OFFSET Buffer_end
		sub     bx,2
no_wrap2:       mov     ax,es:[bx]    ;read from tail-1
		mov     al,ch           ;restore new Thai ASCII
		cmp     al,240         ;specail code
		je      specailcode
		cmp     al,224         ;specail code
		jne     normalCode
specailcode:    xor     ah,ah           ;set scan code = 0 ALT key
normalCode:     mov     es:[bx],ax    ;replace (AL=ASCII) ah still
		jmp     then

Back_step:      mov     bx,es:Tail    ;cancel key stroke
		sub     bx,2
		mov     ax,0113h        ;frequency
		mov     cx,0f00h        ;long time
		call    Sound
		cmp     bx,OFFSET Buffer
		jae     dont_wrap
		mov     bx,OFFSET Buffer_end
		sub     bx,2
dont_wrap:      mov     es:Tail,bx
		jmp     Th_PQuit

then:           cmp     ah,48           ;scan code key B
		je      yes
		cmp     ah,8
		jne     Th_PQuit0
yes:            cmp     dl,0d1h
		jne     Th_PQuit0

		add     bx,2                    ;bx=Tail

		cmp     bx,OFFSET Buffer_end
		jl      no_wrap4
		mov     bx,OFFSET Buffer
no_wrap4:       cmp     bx,es:Head
		je      buffer_full

		mov     dx,bx
		add     dx,2                    ;Tail +1

		cmp     dx,OFFSET Buffer_end
		jl      no_wrap3
		mov     dx,OFFSET Buffer
no_wrap3:       cmp     dx,es:Head
		je      buffer_full
		mov     al,0e9h
		push    bx                   ;save buffer pointer
		mov     bx,WORD PTR KbTran     ;get address backward 128
		xlat
		pop     bx                   ;restore buffer pointer
		mov     es:[bx],ax
		mov     bx,dx
		mov     es:Tail,bx
buffer_full:
Th_PQuit0:      jmp     Th_PQuit

Th_process          ENDP

TempInt9ip        DW      ?
TempInt9cs        DW      ?

Old_int09h_vector LABEL DWORD
Old_int09h_offs   DW     ?
Old_int09h_seg    DW     ?

Old_int16h_vector LABEL DWORD
Old_int16h_offs   DW     ?
Old_int16h_seg    DW     ?

RealScanCode    DB      ?
Active          DB      00h             ;0= NonActive (Menu active VAR)

ChangIn         PROC    NEAR
		cli
		push    es
		xor     ax,ax
		mov     es,ax
		mov     ax,es:[24h]        ;ip
		mov     TempInt9ip,ax
		mov     ax,es:[26h]     ;cs
		mov     TempInt9cs,ax
		mov     ax,OFFSET New_int09h
		mov     es:[24h],ax
		mov     ax,CS
		mov     es:[26h],ax
		pop     es
		sti
		ret
ChangIn         ENDP

ChangOut        PROC    NEAR               ;protect same sk
		cli
		push    es
		xor     ax,ax
		mov     es,ax
		mov     ax,TempInt9ip
		mov     es:[24h],ax        ;ip
		mov     ax,TempInt9cs
		mov     es:[26h],ax        ;cs
		pop     es
		sti
		ret
ChangOut        ENDP

Kb_reset        PROC    NEAR
		in      al,61h          ;get current control port value
		mov     ah,al           ;save in AH
		or      al,80h          ;set bit 7
		out     61h,al          ;send reset value
		mov     al,ah           ;get original value
		out     61h,al          ;send it out to enable keyboard
		cli                     ;suspend interrupts
		mov     al,20h          ;get EOI value
		out     20h,al          ;send EOI to 8259
		sti
		ret
Kb_reset        ENDP

CHOID1          DB      000h,01Bh,0E5h,0F2h,0F3h,0F4h,0F5h,0D9h,0F7h,0F8h,0F9h
		DB      0F0h,0F1h,0F6h,008h,009h,0E7h,0B5h,0C2h,0CDh,0C3h,0E8h
		DB      0B4h,0C1h,0C7h,0E1h,0E3h,0ACh,00Dh,000h,0E9h,0B7h,0A7h
		DB      0A1h,0D1h,0D5h,0D2h,0B9h,0E0h,0E4h,0A2h,0DAh,000h,0A3h
		DB      0BAh,0BBh,0C5h,0CBh,0D4h,0A4h,0CAh,0D0h,0A8h,0BEh

CHOID2          DB      000h,01Bh,0DFh,022h,02Fh,02Ch,03Fh,0D8h,05Fh,02Eh,028h
		DB      029h,02Dh,025h,008h,00Fh,0EAh,0C4h,0E6h,0ADh,0C9h,0D6h
		DB      0BDh,0ABh,0B6h,0B2h,0CFh,0C6h,00Dh,000h,0EBh,0B8h,0D3h
		DB      0B3h,0ECh,0D7h,0BCh,0AAh,0E2h,0B2h,0B1h,0EDh,000h,0A5h
		DB      0AEh,0AFh,0B0h,0C0h,0D1h,0C8h,0CEh,0BFh,0A9h,0CCh

MANEE1          DB      000h,01Bh,0E5h,02Fh,05Fh,0C0h,0B6h,0D8h,0D6h,0A4h,0B5h
		DB      0A8h,0A2h,0AAh,008h,009h,0E6h,0E4h,0D3h,0BEh,0D0h,0D1h
		DB      0D5h,0C3h,0B9h,0C2h,0BAh,0C5h,00Dh,000h,0BFh,0CBh,0A1h
		DB      0B4h,0E0h,0E9h,0E8h,0D2h,0CAh,0C7h,0A7h,0EFh,000h,0A3h
		DB      0BCh,0BBh,0E1h,0CDh,0D4h,0D7h,0B7h,0C1h,0E3h,0BDh

MANEE2          DB      000h,01Bh,0DFh,0F1h,0F2h,0F3h,0F4h,0D9h,0D1h,0F5h,0F6h
		DB      0F7h,0F8h,0F9h,008h,00Fh,0F0h,022h,0AEh,0B1h,0B8h,0EDh
		DB      0EAh,0B3h,0CFh,0ADh,0B0h,02Ch,00Dh,000h,0C4h,0A6h,0AFh
		DB      0E2h,0ACh,0E7h,0EBh,0C9h,0C8h,0ABh,02Eh,0FAh,000h,0A5h
		DB      028h,029h,0A9h,0CEh,0DAh,0ECh,03Fh,0B2h,0CCh,0C6h

BLOCK1          DB      080h,089h,081h,085h,086h,08Ah,087h,084h,082h,088h,083h
BLOCK2          DB      096h,09Eh,097h,09Ah,09Bh,09Fh,09Ch,084h,098h,09Dh,099h


;KU_TIS          DB


CSEG        ENDS
		END
