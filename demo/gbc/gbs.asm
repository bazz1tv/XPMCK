.MEMORYMAP
	DEFAULTSLOT 0
	SLOTSIZE $8000
	SLOT 0 $0400
.ENDME

.ROMBANKSIZE $4000
.ROMBANKS 2


.ORGA $400

init:
	inc	a
	ld 	hl,xpmp_song_tbl
	call 	xpmp_init
	ret

play:
	call	xpmp_update
	ret

metronome:
	ret
	
.include "cgb_hardware.i"
.include "gbmusic.asm"
.include "..\..\lib\gbc\xpmp_gbc.asm"

