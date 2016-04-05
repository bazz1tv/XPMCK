.DEFINE XPMP_RAM_START $7180
.MEMORYMAP
	DEFAULTSLOT 0
	SLOTSIZE $8000
	SLOT 0 $0000
	SLOT 1 $8000
.ENDME

.ROMBANKSIZE $8000
.ROMBANKS 1

.BANK 0 SLOT 1
.ORGA $8000

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
