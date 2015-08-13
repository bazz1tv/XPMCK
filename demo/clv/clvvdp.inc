.EQU VDP_DATA $BE
.EQU VDP_CTRL $BF

.MACRO VDP_SETREG
	ld	a,\2
	out	(VDP_CTRL),a
	ld	a,\1|$80
	out	(VDP_CTRL),a
.ENDM


.MACRO VDP_SETVRAMADR
	ld	a,\1&$FF
	out	(VDP_CTRL),a
	ld	a,\1/256|$40
	out	(VDP_CTRL),a
.ENDM


.MACRO VDP_SETCRAMADR
	ld	a,\1&$FF
	out	(VDP_CTRL),a
	ld	a,\1/256|$C0
	out	(VDP_CTRL),a
.ENDM
