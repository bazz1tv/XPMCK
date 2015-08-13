.memorymap
   defaultslot 0

   slotsize $8000
   slot 0 0
.endme

.rombanksize $8000
.rombanks 1

.orga   $0000
   call   xpmp_update
   ret

; Include the song data
.include "kssmusic.asm"   

; Include the music player
.include "..\..\lib\kss\xpmp_kss.asm"

; Initialize the music player
.orga   $7FF0
   inc 	a
   ld  	hl,xpmp_song_tbl
   call	xpmp_init
   ret




.orga   $7FFF
nop