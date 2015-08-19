; Test program for the Cross Platform Music Player
; Amstrad CPC version
; /Mic, 2009
;
; The relevant parts here are the calls to xpmp_init and xpmp_update.
;
; Build with WLA-DX:
;  wla-z80 -o testcpc.asm testcpc.o
;  wlalink -b testcpc.link testcpc.raw
;  amsdoshd 16384 16384 testcpc.raw testcpc.bin

.DEFINE XPMP_RAM_START $7800

; CPC firmware functions
.EQU SCR_SET_MODE $BC0E
.EQU TXT_OUTPUT $BB5A
.EQU TXT_SET_COLUMN $BB6F
.EQU TXT_SET_ROW $BB72

.memorymap
	defaultslot 0

	slotsize $4000
	slot 0 $0000
	slot 1 $4000
	slot 2 $8000
	slot 3 $C000
.endme

.rombanksize $4000
.rombanks 2


.bank 0 slot 1
.orga $4000


main:
	di
	ld 	hl,$C9FB
	ld 	($38),hl		; Put "EI RET" at $38
	ei
	
	ld	sp,$7FFF
	
	ld	a,0
	call	SCR_SET_MODE

	ld	b,$F7              	; 8255 Control port
	ld	a,$86			; PPI port A as output, port B as input  
	out	(c),a 

	ld	a,6
	call	TXT_SET_COLUMN
	ld	a,8
	call	TXT_SET_ROW
	ld	hl,string1
	call	print_bg
	
	; Initialize the music player
	ld 	hl,xpmp_song_tbl
	ld 	a,1			; Play the first song
	call 	xpmp_init
	

wait_vblank:
	ld 	b,$F5
	in 	a,(c)
	rra
	jr 	nc,wait_vblank+2

	djnz 	$
	djnz 	$
	djnz 	$
	djnz 	$
	djnz 	$
				
	call 	xpmp_update
	
	halt
	jr 	wait_vblank


print_bg:
	ld 	a,(hl)
	cp	0

	ret	z
	inc	hl
	call	TXT_OUTPUT
	jr	print_bg
	

string1:
	.db "Music Test",0
	
; Include the song data
.include "cpcmusic.asm"	

; Include the music player
.include "..\..\lib\kss\xpmp_kss.asm"


				