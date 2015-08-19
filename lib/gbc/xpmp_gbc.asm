; Cross Platform Music Player
; DMG/CGB version
; /Mic, 2008-2010


; Define the starting address of XPMP's RAM chunk (about 260 consecutive bytes are used).
.IFNDEF XPMP_RAM_START
.DEFINE XPMP_RAM_START $D000
.ENDIF

.DEFINE XPMP_ENABLE_CHANNEL_A
.DEFINE XPMP_ENABLE_CHANNEL_B
.DEFINE XPMP_ENABLE_CHANNEL_C
.DEFINE XPMP_ENABLE_CHANNEL_D


.EQU CMD_NOTE   $00
.EQU CMD_REST	$0C
.EQU CMD_REST2	$0D
.EQU CMD_VOLUP  $0E
.EQU CMD_OCTAVE $10
.EQU CMD_DUTY   $20
.EQU CMD_VOL2   $30
.EQU CMD_OCTUP  $40
.EQU CMD_NOTE2	$60
.EQU CMD_OCTDN  $50
.EQU CMD_ARPOFF $90
.EQU CMD_JSR	$96
.EQU CMD_RTS	$97
.EQU CMD_LEN	$9A
.EQU CMD_WRMEM  $9B
.EQU CMD_WRPORT $9C
.EQU CMD_WAVMAC $9E
.EQU CMD_TRANSP $9F
.EQU CMD_CBOFF  $E0
.EQU CMD_CBONCE $E1
.EQU CMD_CBEVNT $E2
.EQU CMD_CBEVVC $E3
.EQU CMD_CBEVVM $E4
.EQU CMD_CBEVOC $E5
.EQU CMD_HWTE   $E8
.EQU CMD_HWVE   $E9
.EQU CMD_LDWAVE $EC
.EQU CMD_DETUNE $ED
.EQU CMD_VOLSET $F0
.EQU CMD_VOLMAC $F1
.EQU CMD_DUTMAC $F2
.EQU CMD_PORMAC $F3
.EQU CMD_PANMAC $F4
.EQU CMD_VIBMAC $F5
.EQU CMD_SWPMAC $F6
.EQU CMD_VSLMAC $F7
.EQU CMD_ARPMAC $F8
.EQU CMD_JMP    $F9
.EQU CMD_DJNZ   $FA
.EQU CMD_LOPCNT $FB
.EQU CMD_APMAC2 $FC
.EQU CMD_J1	$FD
.EQU CMD_END    $FF

.EQU EFFECT_DISABLED 0


.STRUCT xpmp_channel_t
dataPtr		dw
dataPos		dw
delay		dw
delayHi		db	; Note delays are 24 bit unsigned fixed point in 16.8 format
note		db
noteOffs	db
octave		db
duty		db
freq		dw
volume		db
freqOffs	dw
freqOffsLatch	dw
NRX4		db
volEnv		db
toneEnv		db
detune		dw 
vMac		db
vMacPtr		dw
vMacPos		db
enMac		db
enMacPtr	dw
enMacPos	db
en2Mac		db
en2MacPtr	dw
en2MacPos	db
epMac		db
epMacPtr	dw
epMacPos	db
csMac		db
csMacPtr	dw
csMacPos	db
mpMac		db
mpMacPtr	dw
mpMacDelay	db
dtMac		db
dtMacPtr	dw
dtMacPos	db
loop1		db
loop2		db
loopPtr		dw
cbEvnote	dw
returnAddr	dw
oldPos		dw
delayLatch	dw
delayLatch2	db
prevVol		db
wtMacDelay	db
transpose	db
.ENDST


.ENUM XPMP_RAM_START
xpmp_channel0	INSTANCEOF xpmp_channel_t
xpmp_channel1 	INSTANCEOF xpmp_channel_t
xpmp_channel2 	INSTANCEOF xpmp_channel_t
xpmp_channel3 	INSTANCEOF xpmp_channel_t
xpmp_freqChange	db
xpmp_volChange 	db
xpmp_lastNote	db
xpmp_pan	db
xpmp_chnstart	db
xpmp_tempw	dw
.ENDE


; Compare HL with an immediate 16-bit number and jump if less (unsigned)
.MACRO JL_IMM16
	push	hl
	ld	de,-\1
	add	hl,de
	pop	hl
	jp	nc,\2
.ENDM


; Compare HL with an immediate 16-bit number and jump if greater or equal (unsigned)
.MACRO JGE_IMM16
	push	hl
	ld	de,-\1
	add	hl,de
	pop	hl
	jp	c,\2
.ENDM



; Initialize the music player
; HL = pointer to song table, A = song number
xpmp_init:
	ld		b,0
	dec		a
	ld		c,a
	sla		c
	add		hl,bc
	
	; Initialize all the player variables to zero
	ld 		bc,XPMP_RAM_START
	ld 		d,>(xpmp_tempw+2-XPMP_RAM_START)
	ld 		e,<(xpmp_tempw+2-XPMP_RAM_START)
	xpmp_init_zero:
		ld 		a,0
		ld 		(bc),a
		inc 	bc
		dec 	de
		ld		a,d
		or		e
		jr 		nz,xpmp_init_zero
	
	; Initialize channel data pointers
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ld		a,(hl)
	ld		(xpmp_channel0.dataPtr),a
	.ENDIF
	inc		hl
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ld		a,(hl)
	ld		(xpmp_channel0.dataPtr+1),a
	.ENDIF
	inc		hl
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ld		a,(hl)
	ld		(xpmp_channel1.dataPtr),a
	.ENDIF
	inc		hl
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ld		a,(hl)
	ld		(xpmp_channel1.dataPtr+1),a
	.ENDIF
	inc		hl
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ld		a,(hl)
	ld		(xpmp_channel2.dataPtr),a
	.ENDIF
	inc		hl
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ld		a,(hl)
	ld		(xpmp_channel2.dataPtr+1),a
	.ENDIF
	inc		hl
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld		a,(hl)
	ld		(xpmp_channel3.dataPtr),a
	.ENDIF
	inc		hl
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld		a,(hl)
	ld		(xpmp_channel3.dataPtr+1),a
	.ENDIF
	
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ld		hl,xpmp_channel0.loop1-1
	ld		a,l
	ld		(xpmp_channel0.loopPtr),a
	ld		a,h
	ld		(xpmp_channel0.loopPtr+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ld		hl,xpmp_channel1.loop1-1
	ld		a,l
	ld		(xpmp_channel1.loopPtr),a
	ld		a,h
	ld		(xpmp_channel1.loopPtr+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ld		hl,xpmp_channel2.loop1-1
	ld		a,l
	ld		(xpmp_channel2.loopPtr),a
	ld		a,h
	ld		(xpmp_channel2.loopPtr+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld		hl,xpmp_channel3.loop1-1
	ld		a,l
	ld		(xpmp_channel3.loopPtr),a
	ld		a,h
	ld		(xpmp_channel3.loopPtr+1),a
	.ENDIF
	
	; Initialize the delays for all channels to 1
	ld 		a,1
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ld		(xpmp_channel0.delay+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ld		(xpmp_channel1.delay+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ld		(xpmp_channel2.delay+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld		(xpmp_channel3.delay+1),a
	.ENDIF
	
	; Generate white noise by default
	ld		a,4
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld		(xpmp_channel3.duty),a
	.ENDIF

	ld		a,$FF
	ld		(xpmp_channel0.volume),a
	ld		(xpmp_channel1.volume),a
	ld		(xpmp_channel2.volume),a
	ld		(xpmp_channel3.volume),a
	
	ld		a,$80
	ldh		(R_NR52),a
	ld		a,$FF
	ldh		(R_NR50),a
	ldh		(R_NR51),a
	ld		(xpmp_pan),a
	
	ld		a,0
	ldh		(R_NR11),a
	ldh		(R_NR12),a
	ldh		(R_NR13),a
	ldh		(R_NR14),a
	ldh		(R_NR21),a
	ldh		(R_NR22),a
	ldh		(R_NR23),a
	ldh		(R_NR24),a
	ldh		(R_NR31),a
	ldh		(R_NR32),a
	ldh		(R_NR33),a
	ldh		(R_NR34),a
	ldh		(R_NR41),a
	ldh		(R_NR42),a
	ldh		(R_NR43),a
	ldh		(R_NR44),a
	
	; Disable tone sweep
	ld		a,8
	ldh		(R_NR10),a
	ld		(xpmp_channel0.toneEnv),a
	
	ret


.macro XPMP_COMMANDS

; Note / rest
xpmp_\1_cmd_00:
xpmp_\1_cmd_60:
	ld		a,(xpmp_tempw)
	ld		l,a
	ld		a,(xpmp_tempw+1)
	ld		h,a
	
	ld		a,c
	cp		CMD_VOLUP
	jr		nz,xpmp_\1_cmd_00_2

	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	ld		a,(xpmp_channel\1.volume)
.IFDEF XPMP_ALT_GB_VOLCTRL
	ld		(xpmp_channel\1.prevVol),a	; Save the previous volume
.ENDIF
	inc		hl
	add		(hl)
	ld		(xpmp_channel\1.volume),a
	ld		a,1
	ld		(xpmp_volChange),a		; Volume has changed
	ld		a,EFFECT_DISABLED
	ld		(xpmp_channel\1.vMac),a		; Volume set overrides volume macros
	ret	
	
xpmp_\1_cmd_00_2:
	ld		a,(xpmp_channel\1.note)
	ld		(xpmp_lastNote),a
	ld		a,c
	and		$0F
	ld		(xpmp_channel\1.note),a
	ld		a,c
	and		$F0
	cp		CMD_NOTE2
	jr		z,xpmp_\1_cmd_00_std_delay	
	ld		a,(xpmp_channel\1.dataPos)
	add		2
	ld		e,a
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		d,a
	ld		(xpmp_channel\1.dataPos+1),a	
	inc		hl
	ld		a,(hl)
	bit		7,a
	jr		z,xpmp_\1_cmd_00_short_note
		push 	af
		inc		de
		ld		a,e
		ld		(xpmp_channel\1.dataPos),a
		ld		a,d
		ld		(xpmp_channel\1.dataPos+1),a
		pop		af
		inc		hl
		res		7,a
		ld		d,a
		srl		d
		rrc		a
		and		$80
		ld		e,(hl)
		or		e
		ld		e,a
		inc		hl
		ld		a,(xpmp_channel\1.delay)	
		add		(hl)
		ld		(xpmp_channel\1.delay),a	; Fractional part
		ld		a,0
		adc		e
		ld		(xpmp_channel\1.delay+1),a
		ld		a,0
		adc		d
		ld		(xpmp_channel\1.delay+2),a	; Whole part
		jp 		xpmp_\1_cmd_00_got_delay
	xpmp_\1_cmd_00_short_note:
	ld		e,a
	inc		hl
	ld		a,(xpmp_channel\1.delay)	
	add		(hl)
	ld		(xpmp_channel\1.delay),a	; Fractional part
	ld		a,0
	adc		e
	ret		z
	ld		(xpmp_channel\1.delay+1),a
	ld		a,0
	adc		0
	ld		(xpmp_channel\1.delay+2),a	; Whole part
	jp 		xpmp_\1_cmd_00_got_delay
	xpmp_\1_cmd_00_std_delay:		; Use delay set by last CMD_LEN
	ld		a,(xpmp_channel\1.delayLatch)
	ld		b,a
	ld		a,(xpmp_channel\1.delay)
	add		b
	ld		(xpmp_channel\1.delay),a
	ld 		a,(xpmp_channel\1.delayLatch+1)
	adc		0
	;ret	z
	ld		(xpmp_channel\1.delay+1),a
	ld 		a,(xpmp_channel\1.delayLatch+2)
	adc		0
	ld		(xpmp_channel\1.delay+2),a	
	xpmp_\1_cmd_00_got_delay:
	ld		a,2
	ld		(xpmp_freqChange),a
	ld		a,(xpmp_channel\1.note)
	cp		CMD_REST	
	ret		z				; If this was a rest command we can return now
	cp		CMD_REST2
	ret		z
	.IF \1 != 2
	ld		a,(xpmp_channel\1.dtMac)
	bit		7,a
	jr		nz,+
	cp		EFFECT_DISABLED
	call	nz,xpmp_\1_reset_dt_mac
	jr		xpmp_\1_dt_reset
	+:
	call	xpmp_\1_step_dt
	xpmp_\1_dt_reset:
	.ELSE
	ld		a,(xpmp_channel\1.dtMac)
	bit		7,a
	jr		nz,+
	cp		EFFECT_DISABLED
	call	nz,xpmp_\1_reset_wt_mac
	+:
	.ENDIF
	.IFNDEF XPMP_VMAC_NOT_USED
	ld		a,(xpmp_channel\1.vMac)
	bit		7,a
	jr		nz,+
	cp		EFFECT_DISABLED
	call	nz,xpmp_\1_reset_v_mac		; Reset effects as needed..
	jr	xpmp_\1_v_reset
	+:
	call	xpmp_\1_step_v
	xpmp_\1_v_reset:
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN
	ld		a,(xpmp_channel\1.enMac)
	bit		7,a
	jr		nz,+
	cp		EFFECT_DISABLED
	call	nz,xpmp_\1_reset_en_mac
	jr		xpmp_\1_en_reset
	+:
	call	xpmp_\1_step_en
	xpmp_\1_en_reset:
	.ENDIF
	.ENDIF
	.IFNDEF XPMP_EN2MAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN2
	ld		a,(xpmp_channel\1.en2Mac)
	bit		7,a
	jr		nz,+
	cp		EFFECT_DISABLED
	call	nz,xpmp_\1_reset_en2_mac
	jr		xpmp_\1_en2_reset
	+:
	call	xpmp_\1_step_en2
	xpmp_\1_en2_reset:
	.ENDIF
	.ENDIF
	.IF \1 < 3
	.IFNDEF XPMP_MPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_MP
	ld		a,(xpmp_channel\1.mpMac)
	bit		7,a
	jr		nz,+
	cp		EFFECT_DISABLED
	call	nz,xpmp_\1_reset_mp_mac
	jr		xpmp_\1_mp_reset
	+:
	call	xpmp_\1_step_mp
	xpmp_\1_mp_reset:
	;ld	a,(xpmp_channel\1.mpMac)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_\1_reset_mp_mac
	.ENDIF
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EP
	ld		a,(xpmp_channel\1.epMac)
	bit		7,a
	jr		nz,+
	cp		EFFECT_DISABLED
	call	nz,xpmp_\1_reset_ep_mac
	jr		xpmp_\1_ep_reset
	+:
	call	xpmp_\1_step_ep
	xpmp_\1_ep_reset:
	;ld	a,(xpmp_channel\1.epMac)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_\1_reset_ep_mac
	.ENDIF
	.ENDIF
	.ENDIF
	ld		a,(xpmp_channel\1.csMac)
	bit		7,a
	jr		nz,+
	cp		EFFECT_DISABLED
	call	nz,xpmp_\1_reset_cs_mac
	jr		xpmp_\1_cs_reset
	+:
	call	xpmp_\1_step_cs
	xpmp_\1_cs_reset:
	
	ld		a,(xpmp_channel\1.cbEvnote)
	ld		l,a
	ld		a,(xpmp_channel\1.cbEvnote+1)
	ld		h,a
	or		l
	ret		z
	jp		hl				; If a callback has been set for EVERY-NOTE we call it now

; Set octave
xpmp_\1_cmd_10:
	ld		a,c 
	and		$0F
	.IF \1 < 2
	sub		2
	.ELSE
	dec		a
	.ENDIF
	ld		b,a
	add		a
	add		a
	sla		b
	sla		b
	sla		b
	add		b				; A = (C & $0F) * 12
	ld		(xpmp_channel\1.octave),a
	ret

; Set duty cycle	
xpmp_\1_cmd_20:
	ld		a,c
	 and	$0F
	.IF \1 == 3
	add		a
	add		a
	add		a
	.ELSE
	rrca
	rrca
	.ENDIF
	ld		(xpmp_channel\1.duty),a
	;ld		a,(xpmp_volChange)
	;cp		1
	;jr		z,+
	ld		a,1  ;7
	ld		(xpmp_volChange),a
	;+:	
	ld		a,0
	ld		(xpmp_channel\1.dtMac),a
	ret

; Set volume (short)
xpmp_\1_cmd_30:
.IFDEF XPMP_ALT_GB_VOLCTRL
	ld		a,(xpmp_channel\1.volume)
	ld		(xpmp_channel\1.prevVol),a	; Save the previous volume
.ENDIF
	ld		a,c
	and		$0F
	ld		(xpmp_channel\1.volume),a
	ld		a,1
	ld		(xpmp_volChange),a		; Volume has changed
	ld		a,EFFECT_DISABLED
	ld		(xpmp_channel\1.vMac),a		; Volume set overrides volume macros
	ret

; Octave up + note	
xpmp_\1_cmd_40:
	ld		a,(xpmp_tempw)
	ld		l,a
	ld		a,(xpmp_tempw+1)
	ld		h,a
	ld		a,(xpmp_channel\1.octave)
	add		12
	ld		(xpmp_channel\1.octave),a
	ld 		a,c
	add 	$20				; Turn it into a CMD_NOTE2 ($6n)
	ld 		c,a
	jp		xpmp_\1_cmd_00_2

; Octave down + note
xpmp_\1_cmd_50:
	ld		a,(xpmp_tempw)
	ld		l,a
	ld		a,(xpmp_tempw+1)
	ld		h,a
	ld		a,(xpmp_channel\1.octave)
	sub		12
	ld		(xpmp_channel\1.octave),a
	ld 		a,c
	add 	$10				; Turn it into a CMD_NOTE2 ($6n)
	ld		c,a
	jp		xpmp_\1_cmd_00_2

;xpmp_\1_cmd_60:
xpmp_\1_cmd_70:
xpmp_\1_cmd_80:
	ret

xpmp_\1_cmd_90:
	ld		a,c
	cp		CMD_JSR
	jr		z,xpmp_\1_cmd_90_jsr
	cp		CMD_RTS
	jr		z,xpmp_\1_cmd_90_rts
	cp		CMD_LEN
	jp		z,xpmp_\1_cmd_90_len
	cp		CMD_WRMEM
	jp		z,xpmp_\1_cmd_90_wrmem
	cp		CMD_WRPORT
	jp		z,xpmp_\1_cmd_90_wrport
	.IF \1 == 2
	cp		CMD_WAVMAC
	jp		z,xpmp_\1_cmd_90_wavmac
	.ENDIF
	cp		CMD_TRANSP
	jp		z,xpmp_\1_cmd_90_transp
	
	; Turn off arpeggio macro
	ld		a,0
	ld		(xpmp_channel\1.enMac),a
	ld		(xpmp_channel\1.en2Mac),a
	ld		(xpmp_channel\1.noteOffs),a
	ret

	; Jump to a pattern
	xpmp_\1_cmd_90_jsr:
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.oldPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.oldPos+1),a
	ld		a,(xpmp_channel\1.dataPtr)
	ld		(xpmp_channel\1.returnAddr),a
	ld		a,(xpmp_channel\1.dataPtr+1)
	ld		(xpmp_channel\1.returnAddr+1),a
	ld		a,(xpmp_tempw)
	add		1
	ld		l,a
	ld		a,(xpmp_tempw+1)
	adc		0
	ld		h,a
	ld		a,(hl)
	ld		de,xpmp_pattern_tbl
	ld		h,0
	add		a
	ld		l,a
	add		hl,de
	ld		a,(hl)
	ld		(xpmp_channel\1.dataPtr),a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.dataPtr+1),a
	ld		a,$FF
	ld		(xpmp_channel\1.dataPos),a
	ld		(xpmp_channel\1.dataPos+1),a
	ret
	
	; Return from a pattern
	xpmp_\1_cmd_90_rts:
	ld		a,(xpmp_channel\1.oldPos)
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.oldPos+1)
	ld		(xpmp_channel\1.dataPos+1),a
	ld		a,(xpmp_channel\1.returnAddr)
	ld		(xpmp_channel\1.dataPtr),a
	ld		a,(xpmp_channel\1.returnAddr+1)
	ld		(xpmp_channel\1.dataPtr+1),a
	ret
	
	xpmp_\1_cmd_90_len:
	ld		a,(xpmp_tempw)
	ld		l,a
	ld		a,(xpmp_tempw+1)
	ld		h,a	
	ld		a,(xpmp_channel\1.dataPos)
	add		2
	ld		e,a
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		d,a
	ld		(xpmp_channel\1.dataPos+1),a	
	inc		hl
	ld		a,(hl)
	bit		7,a
	jr		z,xpmp_\1_cmd_90_short_delay
		push 	af
		inc	de
		ld	a,e
		ld	(xpmp_channel\1.dataPos),a
		ld	a,d
		ld	(xpmp_channel\1.dataPos+1),a
		pop	af
		inc	hl
		res	7,a
		ld	d,a
		srl	d
		rrc	a
		and	$80
		ld	e,(hl)
		or	e
		ld	e,a
		inc	hl
		ld	a,(hl)
		ld	(xpmp_channel\1.delayLatch),a	; Fractional part
		ld	a,e
		ld	(xpmp_channel\1.delayLatch+1),a
		ld	a,d
		ld	(xpmp_channel\1.delayLatch+2),a	; Whole part
		ret
	xpmp_\1_cmd_90_short_delay:
	ld	(xpmp_channel\1.delayLatch+1),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.delayLatch),a	; Fractional part
	ld	a,0
	ld	(xpmp_channel\1.delayLatch+2),a	; Whole part
	ret

	xpmp_\1_cmd_90_wrmem:
	ld	a,(xpmp_tempw)
	ld	l,a
	ld	a,(xpmp_tempw+1)
	ld	h,a	
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)
	ld	(de),a
	-:
	ld	a,(xpmp_channel\1.dataPos)
	add	3
	ld	e,a
	ld	(xpmp_channel\1.dataPos),a
	ld	a,(xpmp_channel\1.dataPos+1)
	adc	0
	ld	d,a
	ld	(xpmp_channel\1.dataPos+1),a	
	ret
	
	xpmp_\1_cmd_90_wrport:
	jr	-

	.IF \1 == 2
	xpmp_\1_cmd_90_wavmac:
	ld	a,(xpmp_tempw)
	ld	l,a
	ld	a,(xpmp_tempw+1)
	ld	h,a	
	inc	hl
	ld	a,(xpmp_channel\1.dataPos)
	add	1
	ld	(xpmp_channel\1.dataPos),a
	ld	a,(xpmp_channel\1.dataPos+1)
	adc	0
	ld	(xpmp_channel\1.dataPos+1),a
	ld	a,(hl)
	ld	(xpmp_channel\1.dtMac),a
	xpmp_\1_reset_wt_mac:
	and	$7F
	dec	a
	add	a
	ld	hl,xpmp_WT_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(xpmp_channel\1.dtMacPtr),a
	ld	e,a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.dtMacPtr+1),a
	ld	d,a
	ld	a,(de)
	ld	b,a
	inc	de
	ld	a,(de)
	ld	(xpmp_channel\1.wtMacDelay),a
	ld	a,b
	call	xpmp_\1_load_wave
	ld	a,2
	ld	(xpmp_channel\1.dtMacPos),a
	ret
	.ENDIF

	xpmp_\1_cmd_90_transp:
	ld	a,(xpmp_tempw)
	ld	l,a
	ld	a,(xpmp_tempw+1)
	ld	h,a	
	inc	hl
	ld	a,(xpmp_channel\1.dataPos)
	add	1
	ld	(xpmp_channel\1.dataPos),a
	ld	a,(xpmp_channel\1.dataPos+1)
	adc	0
	ld	(xpmp_channel\1.dataPos+1),a
	ld	a,(hl)
	ld	(xpmp_channel\1.transpose),a
	ret

	
xpmp_\1_cmd_A0:
xpmp_\1_cmd_B0:
xpmp_\1_cmd_C0:
xpmp_\1_cmd_D0:
	ret

xpmp_\1_cmd_E0:
	ld		a,(xpmp_tempw)
	ld		l,a
	ld		a,(xpmp_tempw+1)
	ld		h,a
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	ld		a,c
	cp		CMD_CBOFF
	jr		z,xpmp_\1_cmd_E0_cboff
	cp		CMD_CBONCE
	jr		z,xpmp_\1_cmd_E0_cbonce
	cp		CMD_CBEVNT
	jr		z,xpmp_\1_cmd_E0_cbevnt
	.IF \1 == 2
	cp		CMD_LDWAVE
	jr		z,xpmp_\1_cmd_E0_EC
	.ENDIF
	.IF \1 < 3
	cp		CMD_DETUNE
	jr		z,xpmp_\1_cmd_E0_detune
	.ENDIF
	.IF \1 == 0
	cp		CMD_HWTE
	jp		z,xpmp_\1_cmd_E0_hwte
	.ENDIF
	.IF \1 != 2
	cp		CMD_HWVE
	jp		z,xpmp_\1_cmd_E0_hwve
	.ENDIF
	ret
	
	xpmp_\1_cmd_E0_cboff:
	ld		a,0
	ld		(xpmp_channel\1.cbEvnote),a
	ld		(xpmp_channel\1.cbEvnote+1),a
	ret
	
	xpmp_\1_cmd_E0_cbonce:
	inc		hl
	ld		a,(hl)
	ld		de,xpmp_callback_tbl
	ld		h,0
	add		a
	ld		l,a
	add		hl,de
	ld		e,(hl)
	inc		hl
	ld		d,(hl)
	push	de
	pop		hl
	jp		hl
	
	; Every note
	xpmp_\1_cmd_E0_cbevnt:
	inc		hl
	ld		a,(hl)
	ld		de,xpmp_callback_tbl
	ld		h,0
	add		a
	ld		l,a
	add		hl,de
	ld		a,(hl)
	ld		(xpmp_channel\1.cbEvnote),a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.cbEvnote+1),a
	ret

	; Detune
	xpmp_\1_cmd_E0_detune:
	inc		hl
	ld		e,(hl)
	ld		d,0
	bit		7,e
	jr		z,xpmp_\1_cmd_E0_detune_pos
	ld		d,$FF
	xpmp_\1_cmd_E0_detune_pos:
	ld		a,e
	ld		(xpmp_channel\1.detune),a
	ld		a,d
	ld		(xpmp_channel\1.detune+1),a
	ret

	; Load waveform
	xpmp_\1_cmd_E0_EC:
	.IF \1 == 2
	ld		a,EFFECT_DISABLED
	ld		(xpmp_channel\1.dtMac),a
	inc		hl
	ld		a,(hl)
	xpmp_\1_load_wave:
	dec		a
	ld		e,a
	ld		d,0
	sla		e
	rl		d
	sla		e
	rl		d
	sla		e
	rl		d
	sla		e
	rl		d
	ld 		hl,xpmp_waveform_data
	add		hl,de
	ld		a,0
	ldh		(R_NR30),a
	ld		d,16
	ld		c,$30
	xpmp_\1_cmd_E0_copy_wave:
	ldi		a,(hl)
	ld		($FF00+C),a
	inc		c
	dec		d
	jr		nz,xpmp_\1_cmd_E0_copy_wave
	ld		a,$80
	ldh		(R_NR30),a
	ld		a,(xpmp_channel\1.NRX4)		; High 3 bits of frequency
	or		$80
	ldh		(R_NR34),a
	.ENDIF
	ret

	; Set hardware tone envelope (tone sweep)
	.IF \1 == 0
	xpmp_\1_cmd_E0_hwte:
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel0.toneEnv),a
	ldh		(R_NR10),a
	ret
	.ENDIF
	
	; Set hardware volume envelope
	.IF \1 != 2
	xpmp_\1_cmd_E0_hwve:
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.volEnv),a
	ld		a,1
	ld		(xpmp_volChange),a
	ret
	.ENDIF
	
xpmp_\1_cmd_F0:
	ld		a,(xpmp_tempw)
	ld		l,a
	ld		a,(xpmp_tempw+1)
	ld		h,a
	ld		a,c

	.IFNDEF XPMP_VMAC_NOT_USED
	cp	CMD_VOLMAC
	.IF \1 == 2
	jr		nz,xpmp_\1_cmd_F0_check_VIBMAC
	.ELSE
	jr		nz,xpmp_\1_cmd_F0_check_DUTMAC
	.ENDIF
	inc		hl
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	ld		a,(hl)
	ld		(xpmp_channel\1.vMac),a
	xpmp_\1_reset_v_mac:
	and		$7F
	dec		a
	add		a
	ld		hl,xpmp_v_mac_tbl
	ld		d,0
	ld		e,a
	add		hl,de
	ld		a,(hl)	
	ld		(xpmp_channel\1.vMacPtr),a
	ld		e,a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.vMacPtr+1),a
	ld		d,a
	ld		a,(de) 
	ld		(xpmp_channel\1.volume),a
	ld		a,1
	ld		(xpmp_volChange),a	
	ld		a,0
	ld		(xpmp_channel\1.vMacPos),a
	ret
	.ENDIF

	.IF \1 != 2
	xpmp_\1_cmd_F0_check_DUTMAC:
	cp		CMD_DUTMAC
	jr		nz,xpmp_\1_cmd_F0_check_VIBMAC
	inc		hl
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	ld		a,(hl)
	ld		(xpmp_channel\1.dtMac),a
	xpmp_\1_reset_dt_mac:
	and		$7F
	dec		a
	add		a
	ld		hl,xpmp_dt_mac_tbl
	ld		d,0
	ld		e,a
	add		hl,de
	ld		a,(hl)	
	ld		(xpmp_channel\1.dtMacPtr),a
	ld		e,a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.dtMacPtr+1),a
	ld		d,a
	ld		a,(de) 
	rrca
	rrca
	ld		(xpmp_channel\1.duty),a
	;ld	a,(xpmp_volChange)
	;cp	1
	;jr	z,+
	;ld	a,2
	;ld	(xpmp_volChange),a
	;+:
	ld		a,0
	ld		(xpmp_channel\1.dtMacPos),a
	ret
	.ENDIF
	
	;.IF \1 < 3
	xpmp_\1_cmd_F0_check_VIBMAC:
	.IFNDEF XPMP_MPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_MP
	; Initialize vibrato macro
	cp		CMD_VIBMAC
	jr		nz,xpmp_\1_cmd_F0_check_SWPMAC
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	inc		hl
	ld		a,(hl)
	cp		EFFECT_DISABLED
	jr		z,xpmp_\1_cmd_F0_disable_VIBMAC
	ld		(xpmp_channel\1.mpMac),a
	xpmp_\1_reset_mp_mac:
	and		$7F
	dec		a
	add		a
	ld		hl,xpmp_MP_mac_tbl
	ld		d,0
	ld		e,a
	add		hl,de
	ld		a,(hl)
	ld		(xpmp_channel\1.mpMacPtr),a
	ld		e,a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.mpMacPtr+1),a
	ld		d,a
	ld		a,(de) 
	ld		(xpmp_channel\1.mpMacDelay),a
	inc		de
	ld		a,e
	ld		(xpmp_channel\1.mpMacPtr),a
	ld		a,d
	ld		(xpmp_channel\1.mpMacPtr+1),a
	inc		de
	ld		a,(de)
	ld		(xpmp_channel\1.freqOffsLatch),a
	ld		a,0
	ld		(xpmp_channel\1.freqOffsLatch+1),a
	ld		(xpmp_channel\1.freqOffs),a
	ld		(xpmp_channel\1.freqOffs+1),a
	ret
	xpmp_\1_cmd_F0_disable_VIBMAC:
	ld		(xpmp_channel\1.mpMac),a
	ld		(xpmp_channel\1.freqOffs),a
	ld		(xpmp_channel\1.freqOffs+1),a
	ret
	.ENDIF
	.ENDIF
	
	; Initialize sweep macro
	xpmp_\1_cmd_F0_check_SWPMAC:
	.IFNDEF XPMP_EPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EP
	cp		CMD_SWPMAC
	jr		nz,xpmp_\1_cmd_F0_check_JMP
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.epMac),a
	cp		EFFECT_DISABLED
	jr		z,xpmp_\1_cmd_F0_disable_SWPMAC	
	xpmp_\1_reset_ep_mac:
	and		$7F
	dec		a
	add		a
	ld		hl,xpmp_EP_mac_tbl
	ld		d,0
	ld		e,a
	add		hl,de
	ld		a,(hl)	
	ld		(xpmp_channel\1.epMacPtr),a
	ld		e,a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.epMacPtr+1),a
	ld		d,a
	ld		a,1
	ld		(xpmp_channel\1.epMacPos),a
	dec		a
	ld		(xpmp_channel\1.freqOffs+1),a
	ld		a,(de) 
	ld		(xpmp_channel\1.freqOffs),a
	bit		7,a
	ret		z
	ld		a,$FF
	ld		(xpmp_channel\1.freqOffs+1),a
	ret
	xpmp_\1_cmd_F0_disable_SWPMAC:
	ld		(xpmp_channel\1.epMac),a
	ld		(xpmp_channel\1.freqOffs),a
	ld		(xpmp_channel\1.freqOffs+1),a
	ret
	.ENDIF
	.ENDIF
	;.ENDIF
	
	; Jump
	xpmp_\1_cmd_F0_check_JMP:
	cp		CMD_JMP
	jr		nz,xpmp_\1_cmd_F0_check_LOPCNT
	inc		hl
	ld		e,(hl)
	inc		hl
	ld		d,(hl)
	dec		de				; dataPos will be increased after the return, so we decrease it here
	ld		a,e
	ld		(xpmp_channel\1.dataPos),a
	ld		a,d
	ld		(xpmp_channel\1.dataPos+1),a
	ret

	; Set loop count
	xpmp_\1_cmd_F0_check_LOPCNT:
	cp		CMD_LOPCNT
	jr		nz,xpmp_\1_cmd_F0_check_DJNZ
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	inc		hl
	ld		b,(hl)
	ld		a,(xpmp_channel\1.loopPtr)
	add		1
	ld		(xpmp_channel\1.loopPtr),a
	ld		e,a
	ld		a,(xpmp_channel\1.loopPtr+1)
	adc		0
	ld		(xpmp_channel\1.loopPtr+1),a
	ld		d,a
	ld		a,b
	ld		(de),a
	ret

	; Decrease and jump if not zero
	xpmp_\1_cmd_F0_check_DJNZ:
	cp		CMD_DJNZ
	jr		nz,xpmp_\1_cmd_F0_check_APMAC2
	ld		a,(xpmp_channel\1.loopPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.loopPtr+1)
	ld		h,a
	dec		(hl)
	jr		z,xpmp_\1_cmd_F0_DJNZ_Z		; Check if the counter has reached zero
	ld		a,(xpmp_tempw)
	ld		l,a
	ld		a,(xpmp_tempw+1)
	ld		h,a
	inc		hl
	ld		e,(hl)
	inc		hl
	ld		d,(hl)
	dec		de				; dataPos will be increased after the return, so we decrease it here
	ld		a,e
	ld		(xpmp_channel\1.dataPos),a
	ld		a,d
	ld		(xpmp_channel\1.dataPos+1),a
	ret	
	xpmp_\1_cmd_F0_DJNZ_Z:
	dec		hl
	ld		a,l
	ld		(xpmp_channel\1.loopPtr),a
	ld		a,h
	ld		(xpmp_channel\1.loopPtr+1),a
	ld		a,(xpmp_channel\1.dataPos)
	add		2
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_\1_cmd_F0_check_APMAC2:
	.IFNDEF XPMP_EN2MAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN2
	cp		CMD_APMAC2
	jr		nz,xpmp_\1_cmd_F0_check_ARPMAC
	inc		hl
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	ld		a,(hl)
	ld		(xpmp_channel\1.en2Mac),a
	xpmp_\1_reset_en2_mac:
	and		$7F
	dec		a
	add		a
	ld		hl,xpmp_EN_mac_tbl
	ld		d,0
	ld		e,a
	add		hl,de
	ld		a,(hl)	
	ld		(xpmp_channel\1.en2MacPtr),a
	ld		e,a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.en2MacPtr+1),a
	ld		d,a
	ld		a,(de) 
	ld		(xpmp_channel\1.noteOffs),a
	ld		a,1
	ld		(xpmp_channel\1.en2MacPos),a
	dec		a
	ld		(xpmp_channel\1.enMac),a
	ret
	.ENDIF
	.ENDIF
	
	; Initialize non-cumulative arpeggio macro
	xpmp_\1_cmd_F0_check_ARPMAC:
	.IFNDEF XPMP_ENMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN
	cp		CMD_ARPMAC
	jr		nz,xpmp_\1_cmd_F0_check_PANMAC 
	inc		hl
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	ld		a,(hl)
	ld		(xpmp_channel\1.enMac),a
	xpmp_\1_reset_en_mac:
	and		$7F
	dec		a
	add		a
	ld		hl,xpmp_EN_mac_tbl
	ld		d,0
	ld		e,a
	add		hl,de
	ld		a,(hl)	
	ld		(xpmp_channel\1.enMacPtr),a
	ld		e,a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.enMacPtr+1),a
	ld		d,a
	ld		a,(de) 
	ld		(xpmp_channel\1.noteOffs),a
	ld		a,1
	ld		(xpmp_channel\1.enMacPos),a
	dec		a
	ld		(xpmp_channel\1.en2Mac),a
	ret
	.ENDIF
	.ENDIF
	
	xpmp_\1_cmd_F0_check_PANMAC:
	cp	CMD_PANMAC
	jr	nz,xpmp_\1_cmd_F0_check_J1 
	inc	hl
	ld	a,(xpmp_channel\1.dataPos)
	add	1
	ld	(xpmp_channel\1.dataPos),a
	ld	a,(xpmp_channel\1.dataPos+1)
	adc	0
	ld	(xpmp_channel\1.dataPos+1),a
	ld	a,(hl)
	ld	(xpmp_channel\1.csMac),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_\1_cs_off
	xpmp_\1_reset_cs_mac:
	and	$7F
	dec	a
	add	a
	ld	hl,xpmp_CS_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	e,a
	ld	(xpmp_channel\1.csMacPtr),a
	inc	hl
	ld	a,(hl)
	ld	d,a
	ld	(xpmp_channel\1.csMacPtr+1),a
	;ld	hl,(xpmp_channel\1.csMacPtr)
	ld	a,1
	ld	(xpmp_channel\1.csMacPos),a
	ld	a,(de)
	xpmp_\1_write_pan:
	bit	7,a
	jr	z,xpmp_\1_reset_cs_center_right
	ld	a,(xpmp_pan)
	res	\1,a
	set	4+\1,a
	ld	(xpmp_pan),a
	ldh	(R_NR51),a
	ret
	xpmp_\1_reset_cs_center_right:
	cp	0
	jr	nz,xpmp_\1_reset_cs_right
	xpmp_\1_cs_off:
	ld	a,(xpmp_pan)
	or	$11<<\1
	ld	(xpmp_pan),a
	ldh	(R_NR51),a
	ret
	xpmp_\1_reset_cs_right:
	ld	a,(xpmp_pan)
	res	4+\1,a
	set	\1,a
	ld	(xpmp_pan),a
	ldh	(R_NR51),a
	ret
	
	; Jump if one
	xpmp_\1_cmd_F0_check_J1:
	cp		CMD_J1
	jr		nz,xpmp_\1_cmd_F0_check_END
	ld		a,(xpmp_channel\1.loopPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.loopPtr+1)
	ld		h,a
	ld		a,(hl)
	cp		1
	jr		nz,xpmp_\1_cmd_F0_J1_N1		; Check if the counter has reached 1
	dec		hl
	ld		a,l
	ld		(xpmp_channel\1.loopPtr),a
	ld		a,h
	ld		(xpmp_channel\1.loopPtr+1),a
	ld		a,(xpmp_tempw)
	ld		l,a
	ld		a,(xpmp_tempw+1)
	ld		h,a
	inc		hl
	ld		e,(hl)
	inc		hl
	ld		d,(hl)
	dec		de				; dataPos will be increased after the return, so we decrease it here
	ld		a,e
	ld		(xpmp_channel\1.dataPos),a
	ld		a,d
	ld		(xpmp_channel\1.dataPos+1),a
	ret
	xpmp_\1_cmd_F0_J1_N1:
	ld		a,(xpmp_channel\1.dataPos)
	add		2
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	ret
	
	xpmp_\1_cmd_F0_check_END:
	cp		CMD_END
	jr		nz,xpmp_\1_cmd_F0_not_found
	ld		a,CMD_END
	ld		(xpmp_channel\1.note),a		; Playback of this channel should end
	ld		a,2
	ld		(xpmp_freqChange),a		; The command-reading loop should exit	
	ret

	xpmp_\1_cmd_F0_not_found:
	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a	
	ret	
.endm	


xpmp_call_hl:
	jp 		hl
	


.MACRO XPMP_UPDATE_FUNC 

xpmp_\1_update:
	ld		a,0
	ld		(xpmp_freqChange),a
	ld		(xpmp_volChange),a
	
	ld		a,(xpmp_channel\1.note)
	cp		CMD_END
	ret		z				; Playback has ended for this channel - all processing should be skipped
	
	ld		a,0
	ld		(xpmp_chnstart),a
	
	ld 		a,(xpmp_channel\1.delay+1)	; Decrement the whole part of the delay and check if it has reached zero
	ld		l,a
	ld		a,(xpmp_channel\1.delay+2)
	ld		h,a
	dec		hl
	ld		a,h
	or		l
	jp 		nz,xpmp_\1_update_effects	
	
	; Loop here until a note/rest or END command is read (signaled by xpmp_freqChange == 2)
	xpmp_\1_update_read_cmd:
	ld		a,(xpmp_channel\1.dataPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.dataPtr+1)
	ld		h,a
	ld 		a,(xpmp_channel\1.dataPos)
	ld		e,a
	ld 		a,(xpmp_channel\1.dataPos+1)
	ld		d,a
	add 	hl,de
	ld 		c,(hl)
	ld		a,l
	ld		(xpmp_tempw),a			; Store HL for later use
	ld		a,h
	ld		(xpmp_tempw+1),a
	ld		a,c
	srl		a
	srl		a
	srl		a
	res		0,a				; A = (C>>3)&~1 = (C>>4)<<1
	ld		l,a
	ld		h,0
	ld		de,xpmp_\1_jump_tbl	
	add		hl,de
	ld		e,(hl)				; HL = jump_tbl + (command >> 4)
	inc		hl
	ld		d,(hl)
	push	de
	pop		hl
	call	xpmp_call_hl

	ld		a,(xpmp_channel\1.dataPos)
	add		1
	ld		(xpmp_channel\1.dataPos),a
	ld		a,(xpmp_channel\1.dataPos+1)
	adc		0
	ld		(xpmp_channel\1.dataPos+1),a
	
	ld		a,(xpmp_freqChange)
	cp		2
	jr		z,xpmp_update_\1_freq_change
	jp 		xpmp_\1_update_read_cmd
	
	xpmp_update_\1_freq_change:	
	ld		a,(xpmp_channel\1.note)
	cp		CMD_REST
	jp		z,xpmp_\1_rest
	cp		CMD_REST2
	ret		z
	cp		CMD_END
	jp		z,xpmp_\1_end
	ld		b,a
	ld		a,(xpmp_channel\1.noteOffs)
	ld		d,a
	ld		a,(xpmp_channel\1.transpose)
	add		d
	add		b
	ld		b,a
	.IF \1 != 2
	ld		a,(xpmp_channel\1.volEnv)
	cp		0
	jr		z,+
	ld		a,4
	ld		(xpmp_volChange),a
	+:
	.ENDIF
	;ld	a,(xpmp_channel\1.detune)
	;add	b
	;ld	b,a
	ld		a,(xpmp_channel\1.octave)
	add		b
	.IF \1 == 3
	ld		hl,xpmp_chn3_freq_tbl
	ld		d,0
	ld		e,a
	add		hl,de
	ld		a,(hl)
	ld		b,a
	ld		a,(xpmp_channel\1.duty)
	or		b
	ldh		(R_NR43),a
	ld		a,0
	ldh		(R_NR41),a
	;ld	a,$80
	;ldh	(R_NR44),a
	.ELSE
	.IF \1 < 2
	ld		hl,xpmp_freq_tbl
	.ELSE
	ld		hl,xpmp_chn2_freq_tbl
	.ENDIF
	ld		d,0
	add		a
	ld		e,a
	add		hl,de
	ld		e,(hl)
	inc		hl
	ld		d,(hl)
	ld		a,(xpmp_channel\1.freqOffs)
	ld		l,a
	ld		a,(xpmp_channel\1.freqOffs+1)
	ld		h,a
	add		hl,de
	.IF \1 < 2
	JL_IMM16 $07DE,xpmp_update_\1_lb_ok
	ld		hl,$07DE
	jp		xpmp_update_\1_freq_ok
	xpmp_update_\1_lb_ok:
	JGE_IMM16 $002C,xpmp_update_\1_freq_ok
	ld		hl,$002C
	xpmp_update_\1_freq_ok:
	.ELSE
	JL_IMM16 $07EF,xpmp_update_\1_lb_ok
	ld		hl,$07EF
	jp		xpmp_update_\1_freq_ok
	xpmp_update_\1_lb_ok:
	JGE_IMM16 $01,xpmp_update_\1_freq_ok
	ld		hl,$01
	xpmp_update_\1_freq_ok:
	.ENDIF
	ld		a,l
	ldh		(R_NR13+\1*5),a
	ld		a,h
	.IF	\1 < 2		; Square waves?
	.IF \1 == 0		; Square1 has HW tone sweep
	ld		b,a
	ld		c,0
	ld		a,(xpmp_channel0.toneEnv)
	cp		8
	jr		z,+
	ld		c,$80				; We need to restart the sound if the tone sweep has been enabled
	+:
	ld		a,b
	or		c
	.ENDIF
	;ld	(xpmp_channel\1.NRX4),a		; High 3 bits of frequency
	.ENDIF
	ld		(xpmp_channel\1.NRX4),a		; High 3 bits of frequency
	ldh		(R_NR14+\1*5),a
	.ENDIF
	ld		a,(xpmp_lastNote)
	cp		CMD_REST
	jr		nz,xpmp_\1_update_set_vol2
	jp		xpmp_\1_update_set_vol3


	xpmp_\1_update_set_vol:
	ld		a,(xpmp_channel\1.note)
	cp		CMD_REST
	jr		z,xpmp_\1_rest
	xpmp_\1_update_set_vol2:
	; Update the volume if it has changed
	ld		a,(xpmp_volChange)
	cp		0
	ret		z
	xpmp_\1_update_set_vol3:
	.IF \1 < 2
	ld		a,(xpmp_channel\1.duty)
	ldh		(R_NR11+\1*5),a
	ld		a,(xpmp_volChange)
	cp		7
	ret		z
	.ENDIF
	ld		a,(xpmp_channel\1.volume)
	ld		b,a
	.IF \1 == 2
	ld		hl,xpmp_vol_tbl
	ld		e,b
	ld		d,0
	add		hl,de
	ld		a,(hl)
	ldh		(R_NR32),a
	ret
	.ELSE
.IFDEF XPMP_ALT_GB_VOLCTRL	
	;ld	a,(xpmp_channel\1.prevVol)
	;cp	$FF
	ld		a,(xpmp_freqChange)
	cp		2
	jr		z,+
	ld		a,(xpmp_channel\1.prevVol)
	ld		c,a
	ld		a,b
	sub		c
	bit		7,a
	jr		z,xpmp_\1_update_set_vol_pos_diff
	add		16
xpmp_\1_update_set_vol_pos_diff:
	ld		c,a
	;ld	a,b
	;swap	a
	ld		a,8
; Set the new volume by writing DIST(newVolume, oldVolume) times to the volume
; envelope register.
xpmp_\1_update_nrx2_write_loop:
	ldh		(R_NR12+\1*5),a
	dec		c
	jr		nz,xpmp_\1_update_nrx2_write_loop
	ret
+:
.ENDIF
	ld		a,b
	swap	a
.IFDEF XPMP_ALT_GB_VOLCTRL	
	or		8
.ELSE
	ld		b,a
	ld		a,(xpmp_channel\1.volEnv)
	or		b
.ENDIF
	ldh		(R_NR12+\1*5),a
	.ENDIF
	.IF \1 != 2
	xpmp_\1_update_set_vol4:
	.IF \1 < 2
	ld		a,(xpmp_channel\1.NRX4)		; Get high 3 bits of frequency
	.ELSE
	ld		a,0				; Noise channel doesn't have the high 3 frequency bits
	.ENDIF
	ld 		b,a
	ld 		a,(xpmp_volChange)
	cp 		4
	jr 		nz,+
	ld 		a,(xpmp_freqChange)
	cp 		2
	ret 	nz
	+:
	ld 		a,b
	or		$80				; Restart the sound, required when the volume has been changed
	ldh		(R_NR14+\1*5),a
	.ENDIF
	ret


	; Mute the channel
	xpmp_\1_rest:
	ld		a,(xpmp_lastNote)
	cp		CMD_REST
	ret		z				; The channel is already muted, return
	xpmp_\1_end:
	ld		a,$00  
	ldh		(R_NR12+\1*5),a
	.IF \1 != 2
	ld		a,$80
	ldh		(R_NR14+\1*5),a
	.ENDIF
	ret

	xpmp_\1_update_effects:
	ld		a,l
	ld 		(xpmp_channel\1.delay+1),a
	ld		a,h
	ld 		(xpmp_channel\1.delay+2),a	

	call	xpmp_\1_step_dt_frame
	call	xpmp_\1_step_v_frame
	call	xpmp_\1_step_en_frame
	call	xpmp_\1_step_en2_frame
	call	xpmp_\1_step_ep_frame
	call	xpmp_\1_step_mp_frame
	call	xpmp_\1_step_cs_frame
	
	ld		a,(xpmp_freqChange)
	cp		0
	jp		nz,xpmp_update_\1_freq_change
	jp		xpmp_\1_update_set_vol


	xpmp_\1_step_dt_frame:
	ld 		a,(xpmp_channel\1.dtMac)
	bit		7,a
	ret		nz
	xpmp_\1_step_dt:	
	.IF \1 != 2
	; Duty cycle macro
	ld 		a,(xpmp_channel\1.dtMac)
	cp 		EFFECT_DISABLED
	jr 		z,xpmp_update_\1_dt_done 
	ld		a,(xpmp_volChange)
	cp		1
	jr		z,+
	ld		a,7
	ld		(xpmp_volChange),a
	+:
	xpmp_update_\1_dt:
	ld 		a,(xpmp_channel\1.dtMacPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.dtMacPtr+1)
	ld		h,a
	ld 		d,0
	ld 		a,(xpmp_channel\1.dtMacPos)
	ld 		e,a
	add 	hl,de				; Add macro position to pointer
	ld 		a,(hl)
	cp 		128				; If we read a value of 128 we should loop
	jr 		z,xpmp_update_\1_dt_loop
	rrca
	rrca
	ld		(xpmp_channel\1.duty),a 	; Set a new volume
	inc		de				; Increase the position
	ld		a,e
	ld		(xpmp_channel\1.dtMacPos),a
	jp		xpmp_update_\1_dt_done
	xpmp_update_\1_dt_loop:
	ld		a,(xpmp_channel\1.dtMac)	; Which duty cycle macro are we using?
	and		$7F
	dec		a
	add		a
	ld		l,a
	ld		h,0				
	ld		bc,xpmp_dt_mac_loop_tbl
	ld		de,xpmp_channel\1.dtMacPtr
	add		hl,bc 				; HL = xpmp_dtMac_loop_tbl + (dtMac - 1)*2
	ld		a,(hl)				; Read low byte of pointer
	ld		(de),a				; Store in xpmp_\1_dtMac_ptr
	inc 	de	
	inc		hl
	ld		a,(hl)				; Read high byte of pointer
	ld		(de),a
	ld		a,1
	ld		(xpmp_channel\1.dtMacPos),a
	ld		a,(xpmp_channel\1.dtMacPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.dtMacPtr+1)
	ld		h,a
	ld		a,(hl)
	rrca
	rrca
	ld		(xpmp_channel\1.duty),a
	xpmp_update_\1_dt_done:
	.ELSE
	; ..also used as the waveform macro
	ld 		a,(xpmp_channel\1.dtMac)
	cp 		EFFECT_DISABLED
	jr 		z,xpmp_update_\1_dt_done 
	ld		a,(xpmp_channel\1.wtMacDelay)
	cp		$80
	jr 		z,xpmp_update_\1_dt_done2 
	dec		a
	jr 		nz,xpmp_update_\1_dt_done2 
	xpmp_update_\1_dt:
	ld 		a,(xpmp_channel\1.dtMacPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.dtMacPtr+1)
	ld		h,a
	ld 		d,0
	ld 		a,(xpmp_channel\1.dtMacPos)
	ld 		e,a
	add 	hl,de				; Add macro position to pointer
	ld 		a,(hl)
	cp 		128				; If we read a value of 128 we should loop
	jr 		z,xpmp_update_\1_dt_loop
	ld		b,a
	inc		de				; Increase the position
	inc		de
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.wtMacDelay),a
	ld		a,e
	ld		(xpmp_channel\1.dtMacPos),a
	ld		a,b
	call	xpmp_\1_load_wave
	jp		xpmp_update_\1_dt_done
	xpmp_update_\1_dt_loop:
	ld		a,(xpmp_channel\1.dtMac)	; Which waveform macro are we using?
	and		$7F
	dec		a
	add		a
	ld		l,a
	ld		h,0				
	ld		bc,xpmp_WT_mac_loop_tbl
	ld		de,xpmp_channel\1.dtMacPtr
	add		hl,bc 				; HL = xpmp_dtMac_loop_tbl + (dtMac - 1)*2
	ld		a,(hl)				; Read low byte of pointer
	ld		(de),a				; Store in xpmp_\1_dtMac_ptr
	inc 	de	
	inc		hl
	ld		a,(hl)				; Read high byte of pointer
	ld		(de),a
	ld		a,2
	ld		(xpmp_channel\1.dtMacPos),a
	ld		a,(xpmp_channel\1.dtMacPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.dtMacPtr+1)
	ld		h,a
	ld		a,(hl)
	ld		b,a
	inc		hl
	ld		a,(hl)
	ld		(xpmp_channel\1.wtMacDelay),a
	ld		a,b
	call	xpmp_\1_load_wave
	jr		xpmp_update_\1_dt_done
	xpmp_update_\1_dt_done2:
	ld		(xpmp_channel\1.wtMacDelay),a
	xpmp_update_\1_dt_done:
	.ENDIF
	ret
	
	
	xpmp_\1_step_v_frame:
	ld 		a,(xpmp_channel\1.vMac)
	bit		7,a
	ret		nz
	xpmp_\1_step_v:
	.IFNDEF XPMP_VMAC_NOT_USED
	; Volume macro
	ld 		a,(xpmp_channel\1.vMac)
	cp 		EFFECT_DISABLED
	jr 		z,xpmp_update_\1_v_done
	xpmp_update_\1_v:
	ld 		a,(xpmp_channel\1.vMacPtr)
	ld		l,a
	ld 		a,(xpmp_channel\1.vMacPtr+1)
	ld		h,a
	ld 		d,0
	ld 		a,(xpmp_channel\1.vMacPos)
	ld 		e,a
	add 	hl,de				; Add macro position to pointer
	ld 		a,(hl)
	cp 		128				; If we read a value of 128 we should loop
	jr 		z,xpmp_update_\1_v_loop
	ld		b,a
	ld		a,(xpmp_channel\1.volume)
.IFDEF XPMP_ALT_GB_VOLCTRL
	ld		(xpmp_channel\1.prevVol),a
.ENDIF
	cp		b	
	ld		a,b
	ld		(xpmp_channel\1.volume),a 	; Set a new volume
	jr		z,+
	ld		a,1
	ld		(xpmp_volChange),a
+:		
	inc		de				; Increase the position
	ld		a,e
	ld		(xpmp_channel\1.vMacPos),a
	jp		xpmp_update_\1_v_done
	xpmp_update_\1_v_loop:
	ld		a,(xpmp_channel\1.vMac)		; Which volume macro are we using?
	and		$7F
	dec		a
	add		a
	ld		l,a
	ld		h,0				
	ld		bc,xpmp_v_mac_loop_tbl
	ld		de,xpmp_channel\1.vMacPtr
	add		hl,bc 				; HL = xpmp_vMac_loop_tbl + (vMac - 1)*2
	ld		a,(hl)				; Read low byte of pointer
	ld		(de),a				; Store in xpmp_\1_vMac_ptr
	inc 	de	
	inc		hl
	ld		a,(hl)				; Read high byte of pointer
	ld		(de),a
	ld		a,1
	ld		(xpmp_channel\1.vMacPos),a
	ld		a,(xpmp_channel\1.vMacPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.vMacPtr+1)
	ld		h,a
	ld		a,(xpmp_channel\1.volume)
.IFDEF XPMP_ALT_GB_VOLCTRL
	ld		(xpmp_channel\1.prevVol),a
.ENDIF
	ld		b,a
	ld		a,(hl)
	cp		b
	ld		(xpmp_channel\1.volume),a
	jr		z,+
	ld		a,1
	ld		(xpmp_volChange),a
+:			
	xpmp_update_\1_v_done:
	.ENDIF
	ret
	
	
	xpmp_\1_step_en_frame:
	ld 		a,(xpmp_channel\1.enMac)
	bit		7,a
	ret		nz
	xpmp_\1_step_en:
	.IFNDEF XPMP_ENMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN
	; Cumulative arpeggio
	ld 		a,(xpmp_channel\1.enMac)
	cp		EFFECT_DISABLED
	jr 		z,xpmp_update_\1_EN_done
	xpmp_update_\1_EN:
	ld		a,(xpmp_freqChange)
	cp		2
	jr		z,+
	ld		a,1
	ld		(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld		a,(xpmp_channel\1.enMacPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.enMacPtr+1)
	ld		h,a
	ld 		d,0
	ld 		a,(xpmp_channel\1.enMacPos)
	ld 		e,a
	add 	hl,de				; Add macro position to pointer
	ld 		a,(hl)
	cp 		128				; If we read a value of 128 we should loop
	jr 		z,xpmp_update_\1_EN_loop
	ld		b,a
	ld		a,(xpmp_channel\1.noteOffs)
	add		b
	ld		(xpmp_channel\1.noteOffs),a	; Number of semitones to offset the current note by
	inc		de				; Increase the position
	ld		a,e				
	ld		(xpmp_channel\1.enMacPos),a
	jp		xpmp_update_\1_EN_done		
	xpmp_update_\1_EN_loop:
	ld		a,(xpmp_channel\1.enMac)	; Which arpeggio macro are we using?
	and		$7F
	dec		a
	add		a				; Each pointer is two bytes
	ld		l,a
	ld		h,0
	ld		de,xpmp_channel\1.enMacPtr
	ld		bc,xpmp_EN_mac_loop_tbl
	add		hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld		a,(hl)				; Read low byte of pointer
	ld		(de),a
	inc 	de
	inc		hl
	ld		a,(hl)				; Read high byte of pointer
	ld		(de),a
	ld		a,1
	ld		(xpmp_channel\1.enMacPos),a	; Reset position
	ld		a,(xpmp_channel\1.enMacPtr)
	ld		l,a
	ld		a,(xpmp_channel\1.enMacPtr+1)
	ld		h,a
	ld		b,(hl)
	ld		a,(xpmp_channel\1.noteOffs)
	add		b
	ld		(xpmp_channel\1.noteOffs),a	; Reset note offset
	xpmp_update_\1_EN_done:
	.ENDIF
	.ENDIF
	ret
	
	
	xpmp_\1_step_en2_frame:
	ld 	a,(xpmp_channel\1.en2Mac)
	bit	7,a
	ret	nz
	xpmp_\1_step_en2:
	.IFNDEF XPMP_EN2MAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN2
	; Non-cumulative arpeggio
	ld 	a,(xpmp_channel\1.en2Mac)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_\1_EN2_done
	xpmp_update_\1_EN2:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	a,(xpmp_channel\1.en2MacPtr)
	ld	l,a
	ld	a,(xpmp_channel\1.en2MacPtr+1)
	ld	h,a
	ld 	d,0
	ld 	a,(xpmp_channel\1.en2MacPos)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_\1_EN2_loop
	ld	(xpmp_channel\1.noteOffs),a	; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(xpmp_channel\1.en2MacPos),a
	jp	xpmp_update_\1_EN2_done		
	xpmp_update_\1_EN2_loop:
	ld	a,(xpmp_channel\1.en2Mac)	; Which arpeggio macro are we using?
	and	$7F
	dec	a
	add	a				; Each pointer is two bytes
	ld	l,a
	ld	h,0
	ld	de,xpmp_channel\1.en2MacPtr
	ld	bc,xpmp_EN_mac_loop_tbl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (en2Mac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a
	inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(xpmp_channel\1.en2MacPos),a	; Reset position
	ld	a,(xpmp_channel\1.en2MacPtr)
	ld	l,a
	ld	a,(xpmp_channel\1.en2MacPtr+1)
	ld	h,a
	ld	a,(hl)
	ld	(xpmp_channel\1.noteOffs),a	; Reset note offset
	xpmp_update_\1_EN2_done:
	.ENDIF
	.ENDIF
	ret
	
	xpmp_\1_step_ep_frame:
	ld 	a,(xpmp_channel\1.epMac)
	bit	7,a
	ret	nz	
	xpmp_\1_step_ep:
	;.IF \1 < 3
	.IFNDEF XPMP_EPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EP
	; Sweep macro
	ld 	a,(xpmp_channel\1.epMac)
	cp	EFFECT_DISABLED
	jp 	z,xpmp_update_\1_EP_done
	xpmp_update_\1_EP:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	a,(xpmp_channel\1.epMacPtr)
	ld	l,a
	ld	a,(xpmp_channel\1.epMacPtr+1)
	ld	h,a
	ld 	d,0
	ld 	a,(xpmp_channel\1.epMacPos)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_\1_EP_loop
	ld	b,a
	inc	de				; Increase the position
	ld	a,e				
	ld	(xpmp_channel\1.epMacPos),a
	ld	e,b
	ld	d,0
	bit	7,b
	jr	z,xpmp_update_\1_pos_freq
	ld	d,$FF
	xpmp_update_\1_pos_freq:
	ld	a,(xpmp_channel\1.freqOffs)
	ld	l,a
	ld	a,(xpmp_channel\1.freqOffs+1)
	ld	h,a
	add	hl,de
	ld	a,l
	ld	(xpmp_channel\1.freqOffs),a
	ld	a,h
	ld	(xpmp_channel\1.freqOffs+1),a
	jp	xpmp_update_\1_EP_done		
	xpmp_update_\1_EP_loop:
	ld	a,(xpmp_channel\1.epMac)	; Which sweep macro are we using?
	and	$7F
	dec	a
	add	a				; Each pointer is two bytes
	ld	l,a
	ld	h,0
	ld	de,xpmp_channel\1.epMacPtr
	ld	bc,xpmp_EP_mac_loop_tbl
	add	hl,bc				; HL = xpmp_EP_mac_loop_tbl + (epMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a
	inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(xpmp_channel\1.epMacPos),a	; Reset position
	ld	a,(xpmp_channel\1.epMacPtr)
	ld	l,a
	ld	a,(xpmp_channel\1.epMacPtr+1)
	ld	h,a
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_update_\1_pos_freq_2
	ld	d,$FF
	xpmp_update_\1_pos_freq_2:
	ld	a,(xpmp_channel\1.freqOffs)
	ld	l,a
	ld	a,(xpmp_channel\1.freqOffs+1)
	ld	h,a
	add	hl,de
	ld	a,l
	ld	(xpmp_channel\1.freqOffs),a
	ld	a,h
	ld	(xpmp_channel\1.freqOffs+1),a
	xpmp_update_\1_EP_done:
	.ENDIF
	.ENDIF
	ret
	
	xpmp_\1_step_mp_frame:
	ld 	a,(xpmp_channel\1.mpMac)
	bit	7,a
	ret	nz	
	xpmp_\1_step_mp:
	.IFNDEF XPMP_MPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_MP
	; Vibrato
	ld 	a,(xpmp_channel\1.mpMac)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_\1_MP_done
	ld	a,(xpmp_channel\1.mpMacDelay)
	cp	0
	jr 	nz,xpmp_update_\1_MP_done2
	xpmp_update_\1_MP:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	a,(xpmp_channel\1.mpMacPtr)
	ld	l,a
	ld	a,(xpmp_channel\1.mpMacPtr+1)
	ld	h,a
	ld	a,(xpmp_channel\1.freqOffsLatch) ; Load the volume offset from the latch, then negate the latch
	ld	(xpmp_channel\1.freqOffs),a
	ld	e,a
	ld	a,(xpmp_channel\1.freqOffsLatch+1) 
	ld	(xpmp_channel\1.freqOffs+1),a
	ld	d,a
	and	a				; Clear carry
	ld 	c,(hl)				; Reload the vibrato delay
	ld	hl,0
	ld	a,l
	sub	e
	ld	(xpmp_channel\1.freqOffsLatch),a
	ld	a,h
	sbc	d
	ld	(xpmp_channel\1.freqOffsLatch+1),a
	ld	a,c
	inc	a
	xpmp_update_\1_MP_done2:
	dec	a
	ld	(xpmp_channel\1.mpMacDelay),a
	xpmp_update_\1_MP_done:
	.ENDIF
	.ENDIF
	;.ENDIF
	ret

	xpmp_\1_step_cs_frame:
	ld 	a,(xpmp_channel\1.csMac)
	bit	7,a
	ret	nz	
	xpmp_\1_step_cs:
	; Channel separation (pan) macro
	ld 	a,(xpmp_channel\1.csMac)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_\1_CS_done
	xpmp_update_\1_CS:
	ld	a,(xpmp_channel\1.csMacPtr)
	ld	l,a
	ld	a,(xpmp_channel\1.csMacPtr+1)
	ld	h,a
	ld 	d,0
	ld 	a,(xpmp_channel\1.csMacPos)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_\1_CS_loop
	ld	b,a
	inc	de				; Increase the position
	ld	a,e				
	ld	(xpmp_channel\1.csMacPos),a
	jp	xpmp_update_\1_CS_do_write		
	xpmp_update_\1_CS_loop:
	ld	a,(xpmp_channel\1.csMac)	; Which pan macro are we using?
	and	$7F
	dec	a
	add	a				; Each pointer is two bytes
	ld	l,a
	ld	h,0
	ld	de,xpmp_channel\1.csMacPtr
	ld	bc,xpmp_CS_mac_loop_tbl
	add	hl,bc				; HL = xpmp_CS_mac_loop_tbl + (csMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a
	inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(xpmp_channel\1.csMacPos),a	; Reset position
	ld	a,(xpmp_channel\1.csMacPtr)
	ld	l,a
	ld	a,(xpmp_channel\1.csMacPtr+1)
	ld	h,a
	ld	b,(hl)
	xpmp_update_\1_CS_do_write:
	ld	a,b
	call	xpmp_\1_write_pan
	xpmp_update_\1_CS_done:
	ret

	
 .ENDM

.IFDEF XPMP_ENABLE_CHANNEL_A
 XPMP_COMMANDS 0
 XPMP_UPDATE_FUNC 0
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_B
 XPMP_COMMANDS 1
 XPMP_UPDATE_FUNC 1
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_C
 XPMP_COMMANDS 2
 XPMP_UPDATE_FUNC 2
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_D
 XPMP_COMMANDS 3
 XPMP_UPDATE_FUNC 3
.ENDIF


xpmp_update:
.IFDEF XPMP_ENABLE_CHANNEL_A
	call xpmp_0_update
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_B
	call xpmp_1_update
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_C
	call xpmp_2_update
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_D
	call xpmp_3_update
.ENDIF
ret
	

.MACRO XPMP_JUMP_TABLE
xpmp_\1_jump_tbl:
.dw xpmp_\1_cmd_00
.dw xpmp_\1_cmd_10
.dw xpmp_\1_cmd_20
.dw xpmp_\1_cmd_30
.dw xpmp_\1_cmd_40
.dw xpmp_\1_cmd_50
.dw xpmp_\1_cmd_60
.dw xpmp_\1_cmd_70
.dw xpmp_\1_cmd_80
.dw xpmp_\1_cmd_90
.dw xpmp_\1_cmd_A0
.dw xpmp_\1_cmd_B0
.dw xpmp_\1_cmd_C0
.dw xpmp_\1_cmd_D0
.dw xpmp_\1_cmd_E0
.dw xpmp_\1_cmd_F0
.ENDM


.IFDEF XPMP_ENABLE_CHANNEL_A
 XPMP_JUMP_TABLE 0
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_B
 XPMP_JUMP_TABLE 1
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_C
 XPMP_JUMP_TABLE 2
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_D
 XPMP_JUMP_TABLE 3
.ENDIF

xpmp_freq_tbl:
xpmp_chn2_freq_tbl:
.dw $002C,$009C,$0106,$016A,$01C9,$0222,$0276,$02C6,$0311,$0358,$039B,$03DA
.dw $0416,$044E,$0483,$04B5,$04E4,$0511,$053B,$0563,$0588,$05AC,$05CD,$05ED
.dw $060B,$0627,$0641,$065A,$0672,$0688,$069D,$06B1,$06C4,$06D6,$06E6,$06F6
.dw $0705,$0713,$0720,$072D,$0739,$0744,$074E,$0758,$0762,$076B,$0773,$077B
.dw $0782,$0789,$0790,$0796,$079C,$07A2,$07A7,$07AC,$07B1,$07B5,$07B9,$07BD
.dw $07C1,$07C4,$07C8,$07CB,$07CE,$07D1,$07D3,$07D6,$07D8,$07DA,$07DC,$07DE
;xpmp_chn2_freq_tbl:
;.dw $002C,$009C,$0106,$016A,$01C9,$0222,$0276,$02C6,$0311,$0358,$039B,$03DA
;.dw $0416,$044E,$0483,$04B5,$04E4,$0511,$053B,$0563,$0588,$05AC,$05CD,$05ED
;.dw $060B,$0627,$0641,$065A,$0672,$0688,$069D,$06B1,$06C4,$06D6,$06E6,$06F6
;.dw $0705,$0713,$0720,$072D,$0739,$0744,$074E,$0758,$0762,$076B,$0773,$077B
;.dw $0782,$0789,$0790,$0796,$079C,$07A2,$07A7,$07AC,$07B1,$07B5,$07B9,$07BD
;.dw $07C1,$07C4,$07C8,$07CB,$07CE,$07D1,$07D3,$07D6,$07D8,$07DA,$07DC,$07DE
.dw $07E0,$07E2,$07E4,$07E5,$07E7,$07E8,$07E9,$07EB,$07EC,$07ED,$07EE,$07EF
xpmp_chn3_freq_tbl:
.IFDEF XPMP_ALT_GB_NOISE
.db $B7,$B6,$B5,$B4,$A7,$A6,$A5,$A4,$97,$96,$95,$94
.db $87,$86,$85,$84,$77,$76,$75,$74,$67,$66,$65,$64
.db $57,$56,$55,$54,$47,$46,$45,$44,$37,$36,$35,$34
.db $27,$26,$25,$24,$17,$16,$15,$14,$07,$06,$05,$04
.db $03,$02,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00
.ELSE
.db $E0,$A7,$A7,$A7,$B3,$B3,$B3,$A5,$A5,$A5,$D0,$D0
.db $D0,$97,$97,$97,$A3,$A3,$A3,$95,$95,$95,$C0,$C0
.db $C0,$87,$87,$87,$93,$93,$93,$85,$85,$85,$B0,$B0
.db $B0,$77,$77,$77,$83,$83,$83,$75,$75,$75,$A0,$A0
.db $A0,$67,$67,$67,$73,$73,$73,$65,$65,$65,$90,$90
.db $90,$57,$57,$57,$63,$63,$63,$55,$55,$55,$80,$80
.db $80,$47,$47,$47,$53,$53,$53,$45,$45,$45,$70,$70
.db $70,$37,$37,$37,$43,$43,$43,$35,$35,$35,$60,$60
.db $60,$27,$27,$27,$33,$33,$33,$25,$25,$25,$50,$50
.db $50,$17,$17,$17,$23,$23,$23,$15,$15,$15,$40,$40
.db $40,$07,$07,$07,$13,$13,$13,$05,$05,$05,$30,$30
.ENDIF

xpmp_vol_tbl:
.db $00,$60,$40,$20

			


	