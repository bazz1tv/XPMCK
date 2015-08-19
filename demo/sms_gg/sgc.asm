.DEFINE XPMP_RAM_START $D000
.MEMORYMAP
	DEFAULTSLOT 0
	SLOTSIZE $8000
	SLOT 0 $0400
.ENDME

.ROMBANKSIZE $8000
.ROMBANKS 1


.ORGA $400

init:
	inc	a
	ld 	hl,xpmp_song_tbl
	call 	xpmp_init
	ret

play:
	call	xpmp_update
	ret

irq_handler:
	reti
	
metronome:
	ret
	
.include "sgcmusic.asm"
.include "..\..\lib\sms_gg\xpmp_sms.asm"
