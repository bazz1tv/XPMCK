.memorymap
	defaultslot 0

	slotsize $7000
	slot 0 $0FFE 
.endme

.rombanksize $7000
.rombanks 1

.orga $0FFE
.dw $1000	; Load address

init:
clc
adc	#1
sta	xpmp_songNum
lda	#<xpmp_song_tbl
sta	xpmp_songTblLo
lda	#>xpmp_song_tbl
sta	xpmp_songTblHi
jsr	xpmp_init
rts

play:
jsr	 xpmp_update
rts


; Include the music data and the player
.include "c64music.asm"
.include "..\..\lib\c64\xpmp_c64.asm"
