.memorymap
	defaultslot 0

	slotsize $8000
	slot 0 $0000
.endme

.rombanksize $8000
.rombanks 4

.bank 0 slot 0
.orga $2000

init:
	clc
	adc		#1
	sta		xpmp_songNum
	lda		#<xpmp_song_tbl
	sta		xpmp_songTblLo
	lda		#>xpmp_song_tbl
	sta		xpmp_songTblHi
	jsr		xpmp_init
	rts

; $2011
play:
	jsr	 	xpmp_update
	rts

.include "..\..\lib\at8\xpmp_at8.asm"

.orga $3000
; Include the music data 
.include "at8music.asm"
