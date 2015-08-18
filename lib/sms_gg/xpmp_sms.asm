; Cross Platform Music Player
; SMS/GG/CLV version
; /Mic, 2008-2010
;
; The player code/data requires 2-5kB of ROM depending on which effects that are used.


; Define the starting address of XPMP's RAM chunk. About 270 consecutive bytes are used (about 800 when FM is used).
.IFNDEF XPMP_RAM_START
.DEFINE XPMP_RAM_START $D000
.ENDIF

.IFDEF XPMP_COLECOVISION
.DEFINE XPMP_SN_PORT $FF
.ELSE
.DEFINE XPMP_SN_PORT $7F
.ENDIF

; For YM2413
.DEFINE XPMP_OPLL_ADDR $F0
.DEFINE XPMP_OPLL_DATA $F1

.DEFINE XPMP_ENABLE_CHANNEL_A
.DEFINE XPMP_ENABLE_CHANNEL_B
.DEFINE XPMP_ENABLE_CHANNEL_C
.DEFINE XPMP_ENABLE_CHANNEL_D
.IFDEF XPMP_ENABLE_FM
.DEFINE XPMP_ENABLE_CHANNEL_E
.DEFINE XPMP_ENABLE_CHANNEL_F
.DEFINE XPMP_ENABLE_CHANNEL_G
.DEFINE XPMP_ENABLE_CHANNEL_H
.DEFINE XPMP_ENABLE_CHANNEL_I
.DEFINE XPMP_ENABLE_CHANNEL_J
.DEFINE XPMP_ENABLE_CHANNEL_K
.DEFINE XPMP_ENABLE_CHANNEL_L
.DEFINE XPMP_ENABLE_CHANNEL_M
.ENDIF

.EQU CMD_NOTE   $00
.EQU CMD_REST	$0C
.EQU CMD_REST2	$0D
.EQU CMD_VOLUP	$0E
.EQU CMD_OCTAVE $10
.EQU CMD_DUTY   $20
.EQU CMD_VOL2   $30
.EQU CMD_OCTUP  $40
.EQU CMD_OCTDN  $50
.EQU CMD_NOTE2	$60
.EQU CMD_ARPOFF $90
.EQU CMD_JSR	$96
.EQU CMD_RTS	$97
.EQU CMD_LEN	$9A
.EQU CMD_WRMEM  $9B
.EQU CMD_WRPORT $9C
.EQU CMD_TRANSP $9F
.EQU CMD_MODE   $A0
.EQU CMD_WRFM   $B0
.EQU CMD_OPER   $C0
.EQU CMD_RSCALE $D0
.EQU CMD_CBOFF  $E0
.EQU CMD_CBONCE $E1
.EQU CMD_CBEVNT $E2
.EQU CMD_CBEVVC $E3
.EQU CMD_CBEVVM $E4
.EQU CMD_CBEVOC $E5
.EQU CMD_HWTE	$E8
.EQU CMD_HWVE	$E9
.EQU CMD_HWAM   $EA
.EQU CMD_MODMAC $EB
.EQU CMD_DETUNE $ED
.EQU CMD_ADSR   $EE
.EQU CMD_MULT   $EF
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


.EQU _CHN_POS_L	  2
.EQU _CHN_POS_H	  3
.EQU _CHN_NOTE	  7
.EQU _CHN_OCTAVE  9
.EQU _CHN_VOL    13
.EQU _CHN_VMAC	 22
.EQU _PSG_TRANSP 59

; For PSG channels
.STRUCT xpmp_channel_t
dataPtr		dw	; 0
dataPos		dw	; 2
delay		dw	; 4
delayHi		db	; 6
note		db	; 7
noteOffs	db	; 8
octave		db	; 9
duty		db	; 10
freq		dw	; 11
volume		db	; 13
volOffs		db	; 14
volOffsLatch	db	; 15
freqOffs	dw	; 16
freqOffsLatch	dw	; 18
detune		dw 	; 20
vMac		db	; 22
vMacPtr		dw	; 23
vMacPos		db	; 25
enMac		db	; 26
enMacPtr	dw	; 27
enMacPos	db	; 29
en2Mac		db	; 30
en2MacPtr	dw	; 31
en2MacPos	db	; 33
epMac		db	; 34
epMacPtr	dw	; 35
epMacPos	db	; 37
mpMac		db	; 38
mpMacPtr	dw	; 39
mpMacDelay	db	; 41
loop1		db	; 42
loop2		db	; 43
loopPtr		dw	; 44
cbEvnote	dw	; 46
returnAddr	dw	; 48
oldPos		dw	; 50
delayLatch	dw	; 52
delayLatch2	db	; 54
csMac		db	; 55
csMacPtr	dw	; 56
csMacPos	db	; 58
transpose	db	; 59
.ENDST


.STRUCT xpmp_fm_channel_t
dataPtr		dw	; 0
dataPos		dw	; 2
delay		dw	; 4
delayHi		db	; 6. Note delays are 24 bit unsigned fixed point in 16.8 format
note		db	; 7
noteOffs	db	; 8
octave		db	; 9
duty		db	; 10
freq		dw	; 11
volume		db	; 13
volOffs		db	; 14
volOffsLatch	db	; 15
freqOffs	dw	; 16
freqOffsLatch	dw	; 18
detune		dw 	; 20
vMac		db	; 22
vMacPtr		dw	; 23
vMacPos		db	; 25
enMac		db	; 26
enMacPtr	dw	; 27
enMacPos	db	; 29
en2Mac		db	; 30
en2MacPtr	dw	; 31
en2MacPos	db	; 33
epMac		db	; 34
epMacPtr	dw	; 35
epMacPos	db	; 37
csMac		db	; 38
csMacPtr	dw	; 39
csMacPos	db	; 41
mpMac		db	; 42
mpMacPtr	dw	; 43
mpMacDelay	db	; 45
loop1		db	; 46
loop2		db	; 47
loopPtr		dw	; 48
returnAddr	dw	; 50
oldPos		dw	; 52
algo		db	; 54
cbEvnote	dw	; 55
delayLatch	dw	; 57
delayLatch2	db	; 59
transpose	db	; 60
.ENDST


.IFDEF XPMP_ENABLE_FM
.ENUM XPMP_RAM_START
xpmp_channel0	INSTANCEOF xpmp_channel_t
xpmp_channel1 	INSTANCEOF xpmp_channel_t
xpmp_channel2 	INSTANCEOF xpmp_channel_t
xpmp_channel3 	INSTANCEOF xpmp_channel_t
xpmp_channel4 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel5 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel6 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel7 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel8 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel9 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel10 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel11 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel12 	INSTANCEOF xpmp_fm_channel_t
xpmp_freqChange	db
xpmp_volChange 	db
xpmp_lastNote	db
xpmp_chnum	db
xpmp_chsel	db
xpmp_pan	db
xpmp_ym2413Oper db
xpmp_ym2413Rhythm db
xpmp_ym2413Reg0 db
xpmp_ym2413Reg1 db
xpmp_jump_tbl	dw
xpmp_vMacPtr	dw
xpmp_enMacPtr	dw
xpmp_en2MacPtr	dw
xpmp_epMacPtr	dw
xpmp_alMacPtr	dw
xpmp_fbMacPtr	dw
xpmp_panL	dw
xpmp_panR	dw
xpmp_panC	db
xpmp_tempv	dw
xpmp_tempw	dw
xpmp_fmBufPtr	dw
.ENDE
.ELSE
.ENUM XPMP_RAM_START
xpmp_channel0	INSTANCEOF xpmp_channel_t
xpmp_channel1 	INSTANCEOF xpmp_channel_t
xpmp_channel2 	INSTANCEOF xpmp_channel_t
xpmp_channel3 	INSTANCEOF xpmp_channel_t
xpmp_freqChange	db
xpmp_volChange 	db
xpmp_lastNote	db
xpmp_chnum	db
xpmp_chsel	db
xpmp_pan	db
xpmp_fmBufPtr	dw
xpmp_jump_tbl	dw
xpmp_vMacPtr	dw
xpmp_enMacPtr	dw
xpmp_en2MacPtr	dw
xpmp_epMacPtr	dw
xpmp_alMacPtr	dw
xpmp_fbMacPtr	dw
xpmp_panL	dw
xpmp_panR	dw
xpmp_panC	db
xpmp_tempv	dw
xpmp_tempw	dw
.ENDE
.ENDIF


.MACRO INC_DATAPOS
	.IF \1 == 1
	inc	(ix+_CHN_POS_L)
	jr	nz,+
	inc	(ix+_CHN_POS_H)
	+:
	.ELSE
	ld	e,(ix+_CHN_POS_L)
	ld	d,(ix+_CHN_POS_H)
	.rept \1
	inc	de
	.endr
	ld	(ix+_CHN_POS_L),e
	ld	(ix+_CHN_POS_H),d
	.ENDIF
.ENDM


; Compare HL with an immediate 16-bit number and jump if less (unsigned)
.MACRO JL_IMM16
	push	hl
	ld	de,\1
	and	a
	sbc	hl,de
	pop	hl
	jp	c,\2
.ENDM


; Compare HL with an immediate 16-bit number and jump if greater or equal (unsigned)
.MACRO JGE_IMM16
	push	hl
	ld	de,\1
	and	a
	sbc	hl,de
	pop	hl
	jp	nc,\2
.ENDM



.MACRO INIT_DATA_PTR 
	.IFDEF \1
	ex	de,hl
	ld	hl,xpmp_channel\2.loop1-1
	ld	(xpmp_channel\2.loopPtr),hl
	ex	de,hl
	ld	a,1
	ld	(xpmp_channel\2.delay+1),a
	ld	a,(hl)
	ld	(xpmp_channel\2.dataPtr),a
	.ENDIF
	inc	hl
	.IFDEF \1
	ld	a,(hl)
	ld	(xpmp_channel\2.dataPtr+1),a
	.ENDIF
	inc	hl
.ENDM


.IFDEF XPMP_ENABLE_FM
write_ym2413_buffer:
	ld	a,iyl
	ld	l,a
	ld	a,iyh
	ld	h,a
	ld	de,xpmp_fmBufPtr
	and	a	; clear carry
	sbc	hl,de
-:
	ld	a,0
	cp	l
	ret	z
	ld	a,(de)
	out	(XPMP_OPLL_ADDR),a
	inc	de
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld	a,(de)
	dec	l
	dec	l
	out	(XPMP_OPLL_DATA),a
	inc	de
	nop
	nop
	jr	-
	ret
.ENDIF


; Initialize the music player
; HL = pointer to song table, A = song number
xpmp_init:
	ld	b,0
	dec	a
.IFDEF XPMP_ENABLE_FM
	ld	c,a
	add	a,a
	ld	c,a	; c = song*2

	add	a,a
	add	a,a

	ld	b,a	; b = song*8
	add	a,a	; a = song*16
	add	a,b	; a = song*24
	add	a,c	; a = song*26
	ld	c,a
.ELSE
	add	a,a
	add	a,a
	add	a,a
	ld	c,a
.ENDIF
	add	hl,bc

	; Initialize all the player variables to zero
	ld 	bc,XPMP_RAM_START
	ld 	a,0
	ld 	de,xpmp_tempw+2-XPMP_RAM_START
	xpmp_init_zero:
		ld	a,0
		ld 	(bc),a
		inc 	bc
		dec 	de
		ld	a,d
		or	e
		jr 	nz,xpmp_init_zero
		
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_A,0
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_B,1
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_C,2
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_D,3

.IFDEF XPMP_ENABLE_FM
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_E,4
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_F,5
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_G,6
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_H,7
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_I,8
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_J,9
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_K,10
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_L,11
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_M,12
.ENDIF	
	
	; Generate white noise by default
	ld	a,4
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld	(xpmp_channel3.duty),a
	.ENDIF
	
	ld	a,$FF
	ld	(xpmp_pan),a

	.IFDEF XPMP_ENABLE_FM
	ld	a,0
	ld	(xpmp_ym2413Oper),a
	ld	(xpmp_ym2413Rhythm),a
	.ENDIF
	
	ret
	

; Note / rest
xpmp_tone_cmd_00:
xpmp_tone_cmd_60:
	ld	hl,(xpmp_tempw)

	ld	a,c
	cp	CMD_VOLUP
	jr	nz,xpmp_tone_cmd_00_2
	INC_DATAPOS 1
	ld	a,(ix+_CHN_VOL)
	inc	hl
	add	a,(hl)
	ld	(ix+_CHN_VOL),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	(ix+_CHN_VMAC),EFFECT_DISABLED	; Volume set overrides volume macros
	ret
	
xpmp_tone_cmd_00_2:
	ld	a,(ix+_CHN_NOTE)
	ld	(xpmp_lastNote),a
	ld	a,c
	and	$0F
	ld	(ix+_CHN_NOTE),a
	ld	a,c
	and	$F0
	cp	CMD_NOTE2
	jr	z,xpmp_tone_cmd_00_std_delay
	INC_DATAPOS 2
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_tone_cmd_00_short_note
		inc	de
		ld	(ix+_CHN_POS_L),e
		ld	(ix+_CHN_POS_H),d
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
		ld	a,(ix+4)	
		add	a,(hl)
		ld	(ix+4),a		; Fractional part
		ld	hl,0 
		adc	hl,de
		ld	(ix+5),l		; Whole part
		ld	(ix+6),h
		jp 	xpmp_tone_cmd_00_got_delay
	xpmp_tone_cmd_00_short_note:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(ix+4)	
	add	a,(hl)
	ld	(ix+4),a			; Fractional part
	ld	hl,0 
	adc	hl,de
	ret	z
	ld	(ix+5),l			; Whole part
	ld	(ix+6),h
	jp 	xpmp_tone_cmd_00_got_delay
	xpmp_tone_cmd_00_std_delay:		; Use delay set by last CMD_LEN
	ld	a,(ix+52)
	ld	b,a
	ld	a,(ix+4)
	add	a,b
	ld	(ix+4),a
	ld 	l,(ix+53)
	ld	h,(ix+54)
	ld	de,0
	adc	hl,de
	ret	z
	ld	(ix+5),l
	ld	(ix+6),h
	xpmp_tone_cmd_00_got_delay:
	ld	a,2
	ld	(xpmp_freqChange),a
	ld	a,(ix+_CHN_NOTE)
	cp	CMD_REST	
	ret	z				; If this was a rest command we can return now
	cp	CMD_REST2
	ret	z
	.IFNDEF XPMP_VMAC_NOT_USED
	ld	a,(ix+_CHN_VMAC)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_v_mac	; Reset effects as needed..
	jr	xpmp_tone_v_reset
	+:
	call	xpmp_step_v
	xpmp_tone_v_reset:	
	;ld	a,(ix+_CHN_VMAC)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_tone_reset_v_mac	; Reset effects as needed..
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	ld	a,(ix+26)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_en_mac	; Reset effects as needed..
	jr	xpmp_tone_en_reset
	+:
	call	xpmp_step_en
	xpmp_tone_en_reset:	
	.ENDIF
	.IFNDEF XPMP_EN2MAC_NOT_USED
	ld	a,(ix+30)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_en2_mac	; Reset effects as needed..
	jr	xpmp_tone_en2_reset
	+:
	call	xpmp_step_en2
	xpmp_tone_en2_reset:	
	.ENDIF
	.IFNDEF XPMP_MPMAC_NOT_USED
	ld	a,(ix+38)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_mp_mac	; Reset effects as needed..
	jr	xpmp_tone_mp_reset
	+:
	call	xpmp_step_mp
	xpmp_tone_mp_reset:	
	;ld	a,(ix+38)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_tone_reset_mp_mac
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	ld	a,(ix+34)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_ep_mac	; Reset effects as needed..
	jr	xpmp_tone_ep_reset
	+:
	call	xpmp_step_ep
	xpmp_tone_ep_reset:	
	;ld	a,(ix+34)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_tone_reset_ep_mac
	.ENDIF
	.IFDEF XPMP_GAME_GEAR
	ld	a,(ix+55)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_cs_mac	; Reset effects as needed..
	jr	xpmp_tone_cs_reset
	+:
	call	xpmp_step_cs
	xpmp_tone_cs_reset:	
	;ld	a,(ix+55)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_tone_reset_cs_mac
	.ENDIF	
	ld	l,(ix+46)
	ld	h,(ix+47)
	ld	a,h
	or	l
	ret	z
	jp	(hl)				; If a callback has been set for EVERY-NOTE we call it now
	ret
	
; Set octave
xpmp_tone_cmd_10:
	ld	a,c 
	and	$0F
	sub	2				; Minimum octave is 2
	ld	b,a
	add	a,a
	add	a,a
	sla	b
	sla	b
	sla	b
	add	a,b				; A = (C & $0F) * 12
	ld	(ix+_CHN_OCTAVE),a
	ret
	
xpmp_tone_cmd_20:
	ret

; Set volume (short)
xpmp_tone_cmd_30:
	ld	a,c
	and	$0F
	ld	(ix+_CHN_VOL),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	(ix+_CHN_VMAC),EFFECT_DISABLED	; Volume set overrides volume macros
	ret

; Octave up + note	
xpmp_tone_cmd_40:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+_CHN_OCTAVE)
	add	a,12
	ld	(ix+_CHN_OCTAVE),a
	ld 	a,c
	add 	a,$20
	ld 	c,a
	jp	xpmp_tone_cmd_00_2

; Octave down + note
xpmp_tone_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+_CHN_OCTAVE)
	sub	12
	ld	(ix+_CHN_OCTAVE),a
	ld 	a,c
	add 	a,$10
	ld 	c,a
	jp	xpmp_tone_cmd_00_2

;xpmp_tone_cmd_60:
xpmp_tone_cmd_70:
xpmp_tone_cmd_80:
	ret

; Turn off arpeggio macro
xpmp_tone_cmd_90:
	ld	a,c
	cp	CMD_JSR
	jr	z,xpmp_tone_cmd_90_jsr
	cp	CMD_RTS
	jr	z,xpmp_tone_cmd_90_rts
	cp	CMD_LEN
	jr	z,xpmp_tone_cmd_90_len
	cp	CMD_WRMEM
	jp	z,xpmp_tone_cmd_90_wrmem
	cp	CMD_WRPORT
	jp	z,xpmp_tone_cmd_90_wrport
	cp	CMD_TRANSP
	jp	z,xpmp_tone_cmd_90_transp
	
	ld	hl,(xpmp_tempw)
	ld	a,0
	ld	(ix+26),a
	ld	(ix+30),a
	ld	(ix+8),a
	ret

	; Jump to pattern
	xpmp_tone_cmd_90_jsr:
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	ld	(ix+50),e
	ld	(ix+51),d
	ld	a,(ix+0)
	ld	(ix+48),a
	ld	a,(ix+1)
	ld	(ix+49),a
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	a,(hl)
	ld	de,xpmp_pattern_tbl
	ld	h,0
	add	a,a
	ld	l,a
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(ix+0),e
	ld	(ix+1),d
	ld	a,$FF
	ld	(ix+2),a
	ld	(ix+3),a
	ret
	
	; Return from pattern
	xpmp_tone_cmd_90_rts:
	ld	a,(ix+48)
	ld	(ix+0),a
	ld	a,(ix+49)
	ld	(ix+1),a
	ld	a,(ix+50)
	ld	(ix+2),a
	ld	a,(ix+51)
	ld	(ix+3),a
	ret

	xpmp_tone_cmd_90_len:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 2
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_tone_cmd_90_short_delay
		inc	de
		ld	(ix+2),e
		ld	(ix+3),d
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
		ld	(ix+52),a	; Fractional part
		ld	(ix+53),e	; Whole part
		ld	(ix+54),d
		ret
	xpmp_tone_cmd_90_short_delay:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(hl)
	ld	(ix+52),a	; Fractional part
	ld	(ix+53),e	; Whole part
	ld	(ix+54),d	; ...
	ret

	xpmp_tone_cmd_90_wrmem:
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc 	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)
	ld	(de),a
	-:
	INC_DATAPOS 2
	ret
	
	xpmp_tone_cmd_90_wrport:
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	c,(hl)
	inc 	hl
	inc	hl
	ld	a,(hl)
	out	(c),a
	jr	-
	
	xpmp_tone_cmd_90_transp:
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	a,(hl)
	ld	(ix+_PSG_TRANSP),a
	INC_DATAPOS 1
	ret	

xpmp_tone_cmd_A0:
xpmp_tone_cmd_B0:
xpmp_tone_cmd_C0:
xpmp_tone_cmd_D0:
	ret

; Callback
xpmp_tone_cmd_E0:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 1
	ld	a,c
	cp	CMD_CBOFF
	jr	z,xpmp_tone_cmd_E0_cboff
	cp	CMD_CBONCE
	jr	z,xpmp_tone_cmd_E0_cbonce
	cp	CMD_CBEVNT
	jr	z,xpmp_tone_cmd_E0_cbevnt
	;.IF \1 < 3
	cp	CMD_DETUNE
	jr	z,xpmp_tone_cmd_E0_detune
	;.ENDIF
	ret
	
	xpmp_tone_cmd_E0_cboff:
	ld	a,0
	ld	(ix+46),a
	ld	(ix+47),a
	ret
	
	xpmp_tone_cmd_E0_cbonce:
	inc	hl
	ld	a,(hl)
	ld	de,xpmp_callback_tbl
	ld	h,0
	add	a,a
	ld	l,a
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	jp	(hl)
	ret
	
	; Every note
	xpmp_tone_cmd_E0_cbevnt:
	inc	hl
	ld	a,(hl)
	ld	de,xpmp_callback_tbl
	ld	h,0
	add	a,a
	ld	l,a
	add	hl,de
	ld	a,(hl)
	ld	(ix+46),a
	inc	hl
	ld	a,(hl)
	ld	(ix+47),a
	ret

	;.IF \1 < 3
	xpmp_tone_cmd_E0_detune:
	inc	hl
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_tone_cmd_E0_detune_pos
	ld	d,$FF
	xpmp_tone_cmd_E0_detune_pos:
	ld	(ix+20),e
	ld	(ix+21),d
	ret
	;.ENDIF
	
xpmp_tone_cmd_F0:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 1
	; Initialize volume macro	
	ld	a,c

	.IFNDEF XPMP_VMAC_NOT_USED
	cp	CMD_VOLMAC
	;.IF \1 < 3
	jr	nz,xpmp_tone_cmd_F0_check_VIBMAC
	;.ELSE
	;jr	nz,xpmp_\1_cmd_F0_check_JMP
	;.ENDIF
	inc	hl
	ld	a,(hl)
	ld	(ix+_CHN_VMAC),a
	xpmp_tone_reset_v_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_v_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+23),a
	inc	hl
	ld	a,(hl)
	ld	(ix+24),a
	ld	l,(ix+23)
	ld	h,(ix+24)
	ld	a,(hl)
	ld	(ix+13),a
	ld	a,1
	ld	(xpmp_volChange),a	
	ld	a,1
	ld	(ix+25),a
	ret
	.ENDIF
	
	;.IF \1 < 3
	xpmp_tone_cmd_F0_check_VIBMAC:
	.IFNDEF XPMP_MPMAC_NOT_USED
	; Initialize vibrato macro
	cp	CMD_VIBMAC
	jr	nz,xpmp_tone_cmd_F0_check_SWPMAC
	inc	hl
	ld	a,(hl)
	cp	EFFECT_DISABLED
	jr	z,xpmp_tone_cmd_F0_disable_VIBMAC
	ld	(ix+38),a
	xpmp_tone_reset_mp_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_MP_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	ld	(ix+39),a
	inc	hl
	ld	a,(hl)
	ld	(ix+40),a
	ld	l,(ix+39)
	ld	h,(ix+40)
	ld	a,(hl)
	ld	(ix+41),a
	inc	hl
	ld	(ix+39),l
	ld	(ix+40),h
	inc	hl
	ld	a,(hl)
	ld	(ix+18),a
	ld	a,0
	ld	(ix+19),a
	ld	(ix+16),a
	ld	(ix+17),a
	ret
	xpmp_tone_cmd_F0_disable_VIBMAC:
	ld	(ix+38),a
	ld	(ix+16),a
	ld	(ix+17),a
	ret
	.ENDIF
	
	; Initialize sweep macro
	xpmp_tone_cmd_F0_check_SWPMAC:
	.IFNDEF XPMP_EPMAC_NOT_USED
	cp	CMD_SWPMAC
	jr	nz,xpmp_tone_cmd_F0_check_JMP
	inc	hl
	ld	a,(hl)
	ld	(ix+34),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_tone_cmd_F0_disable_SWPMAC	
	xpmp_tone_reset_ep_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_EP_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+35),a
	inc	hl
	ld	a,(hl)
	ld	(ix+36),a
	ld	l,(ix+35)
	ld	h,(ix+36)
	ld	a,1
	ld	(ix+37),a
	dec	a
	ld	(ix+17),a
	ld	a,(hl)
	ld	(ix+16),a
	bit	7,a
	ret	z
	ld	a,$FF
	ld	(ix+17),a
	ret
	xpmp_tone_cmd_F0_disable_SWPMAC:
	ld	(ix+34),a
	ld	(ix+16),a
	ld	(ix+17),a
	ret
	.ENDIF
	
	; Jump
	xpmp_tone_cmd_F0_check_JMP:
	cp	CMD_JMP
	jr	nz,xpmp_tone_cmd_F0_check_LOPCNT
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+_CHN_POS_L),e
	ld	(ix+_CHN_POS_H),d
	ret

	; Set loop count
	xpmp_tone_cmd_F0_check_LOPCNT:
	cp	CMD_LOPCNT
	jr	nz,xpmp_tone_cmd_F0_check_DJNZ
	inc	hl
	ld	a,(hl)
	ld	l,(ix+44)
	ld	h,(ix+45)
	inc	hl
	ld	(hl),a
	ld	(ix+44),l
	ld	(ix+45),h
	ret

	; Decrease and jump if not zero
	xpmp_tone_cmd_F0_check_DJNZ:
	cp	CMD_DJNZ
	jr	nz,xpmp_tone_cmd_F0_check_APMAC2
	ld	l,(ix+44)
	ld	h,(ix+45)
	dec	(hl)
	jr	z,xpmp_tone_cmd_F0_DJNZ_Z	; Check if the counter has reached zero
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+2),e
	ld	(ix+3),d
	ret
	xpmp_tone_cmd_F0_DJNZ_Z:
	dec	hl
	ld	(ix+44),l
	ld	(ix+45),h
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_tone_cmd_F0_check_APMAC2:
	.IFNDEF XPMP_EN2MAC_NOT_USED
	cp	CMD_APMAC2
	jr	nz,xpmp_tone_cmd_F0_check_ARPMAC
	inc	hl
	ld	a,(hl)
	ld	(ix+30),a
	xpmp_tone_reset_en2_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_EN_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+31),a
	inc	hl
	ld	a,(hl)
	ld	(ix+32),a
	ld	l,(ix+31)
	ld	h,(ix+32)
	ld	a,(hl)
	ld	(ix+8),a
	ld	a,1
	ld	(ix+33),a
	dec	a
	ld	(ix+26),a
	ret
	.ENDIF
	
	; Initialize non-cumulative arpeggio macro
	xpmp_tone_cmd_F0_check_ARPMAC:
	.IFNDEF XPMP_ENMAC_NOT_USED
	cp	CMD_ARPMAC
	jr	nz,xpmp_tone_cmd_F0_check_PANMAC
	inc	hl
	ld	a,(hl)
	ld	(ix+26),a
	xpmp_tone_reset_en_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_EN_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+27),a
	inc	hl
	ld	a,(hl)
	ld	(ix+28),a
	ld	l,(ix+27)
	ld	h,(ix+28)
	ld	a,(hl)
	ld	(ix+8),a
	ld	a,1
	ld	(ix+29),a
	dec	a
	ld	(ix+30),a
	ret
	.ENDIF
	
	xpmp_tone_cmd_F0_check_PANMAC:
	cp	CMD_PANMAC
	jr	nz,xpmp_tone_cmd_F0_check_J1
	inc	hl
	ld	a,(hl)
	ld	(ix+55),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_tone_cs_off
	xpmp_tone_reset_cs_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_CS_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+56),a
	inc	hl
	ld	a,(hl)
	ld	(ix+57),a
	ld	l,(ix+56)
	ld	h,(ix+57)
	ld	a,1
	ld	(ix+58),a
	ld	a,(hl)
	xpmp_tone_write_pan:
	bit	7,a
	jr	z,xpmp_tone_reset_cs_pos
	ld	a,(xpmp_pan)
	ld	hl,xpmp_panL
	and	(hl)
	inc	hl
	or	(hl)
	ld	(xpmp_pan),a
	.IFDEF	XPMP_GAME_GEAR
	out	($06),a
	.ENDIF
	ret
	xpmp_tone_reset_cs_pos:
	cp	0
	jr	nz,xpmp_tone_reset_cs_right
	xpmp_tone_cs_off:
	ld	hl,xpmp_panC
	ld	a,(xpmp_pan)
	or	(hl)
	ld	(xpmp_pan),a
	.IFDEF	XPMP_GAME_GEAR
	out	($06),a
	.ENDIF
	ret
	xpmp_tone_reset_cs_right:
	ld	a,(xpmp_pan)
	ld	hl,xpmp_panR
	and	(hl)
	inc	hl
	or	(hl)
	ld	(xpmp_pan),a
	.IFDEF	XPMP_GAME_GEAR
	out	($06),a
	.ENDIF
	ret
	
	
	; Jump if one
	xpmp_tone_cmd_F0_check_J1:
	cp	CMD_J1
	jr	nz,xpmp_tone_cmd_F0_check_END
	ld	l,(ix+44)
	ld	h,(ix+45)
	ld	a,(hl)
	cp	1
	jr	nz,xpmp_tone_cmd_F0_J1_N1	; Check if the counter has reached 1
	dec	hl
	ld	(ix+44),l
	ld	(ix+45),h
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+2),e
	ld	(ix+3),d
	ret
	xpmp_tone_cmd_F0_J1_N1:
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	ret
	
	
	xpmp_tone_cmd_F0_check_END:
	cp	CMD_END
	jr	nz,xpmp_tone_cmd_F0_not_found
	ld	a,CMD_END
	ld	(ix+7),a			; Playback of this channel should end
	ld	a,2
	ld	(xpmp_freqChange),a		; The command-reading loop should exit	
	ret

	xpmp_tone_cmd_F0_not_found:
	ret

;---------------------------

xpmp_noise_cmd_00:
	ld	hl,(xpmp_tempw)

	ld	a,c
	cp	CMD_VOLUP
	jr	nz,xpmp_noise_cmd_00_2
	INC_DATAPOS 1
	ld	a,(ix+_CHN_VOL)
	inc	hl
	add	a,(hl)
	ld	(ix+_CHN_VOL),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	(ix+_CHN_VMAC),EFFECT_DISABLED	; Volume set overrides volume macros
	ret
	
xpmp_noise_cmd_00_2:
	ld	a,(xpmp_channel3.note)
	ld	(xpmp_lastNote),a
	ld	a,c
	and	$0F
	ld	(xpmp_channel3.note),a
	INC_DATAPOS 2
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_noise_cmd_00_short_note
		inc	de
		ld	(ix+2),e
		ld	(ix+3),d
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
		ld	a,(ix+4)	
		add	a,(hl)
		ld	(ix+4),a		; Fractional part
		ld	hl,0 
		adc	hl,de
		ld	(ix+5),l		; Whole part
		ld	(ix+6),h
		jp 	xpmp_noise_cmd_00_got_delay
	xpmp_noise_cmd_00_short_note:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(ix+4)	
	add	a,(hl)
	ld	(ix+4),a			; Fractional part
	ld	hl,0 
	adc	hl,de
	ret	z
	ld	(ix+5),l			; Whole part
	ld	(ix+6),h
	xpmp_noise_cmd_00_got_delay:
	ld	a,2
	ld	(xpmp_freqChange),a
	ld	a,(xpmp_channel3.note)
	cp	CMD_REST	
	ret	z				; If this was a rest command we can return now
	cp	CMD_REST2
	ret	z
	.IFNDEF XPMP_VMAC_NOT_USED
	ld	a,(ix+22)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_v_mac	; Reset effects as needed..
	jr	xpmp_noise_v_reset
	+:
	call	xpmp_step_v
	xpmp_noise_v_reset:
	;ld	a,(ix+22)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_tone_reset_v_mac	; Reset effects as needed..
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	ld	a,(ix+26)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_en_mac	; Reset effects as needed..
	jr	xpmp_noise_en_reset
	+:
	call	xpmp_step_en
	xpmp_noise_en_reset:
	;ld	a,(ix+26)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_tone_reset_en_mac
	.ENDIF
	.IFNDEF XPMP_EN2MAC_NOT_USED
	ld	a,(ix+30)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_en2_mac	; Reset effects as needed..
	jr	xpmp_noise_en2_reset
	+:
	call	xpmp_step_en2
	xpmp_noise_en2_reset:
	;ld	a,(ix+30)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_tone_reset_en2_mac
	.ENDIF
	.IFDEF XPMP_GAME_GEAR
	ld	a,(ix+55)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_cs_mac	; Reset effects as needed..
	jr	xpmp_noise_cs_reset
	+:
	call	xpmp_step_cs
	xpmp_noise_cs_reset:
	.ENDIF		
	ret
	
xpmp_noise_cmd_20:
	ld	hl,(xpmp_tempw)
	ld	a,c
	and	1
	xor	1
	add	a,a
	add	a,a
	ld	(xpmp_channel3.duty),a
	ret

; Octave up + note	
xpmp_noise_cmd_40:
	ld	hl,(xpmp_tempw)
	ld	a,(xpmp_channel3.octave)
	add	a,12
	ld	(xpmp_channel3.octave),a
	ld a,c
	add a,$20
	ld c,a
	jp	xpmp_tone_cmd_60

; Octave down + note
xpmp_noise_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(xpmp_channel3.octave)
	sub	12
	ld	(xpmp_channel3.octave),a
	ld a,c
	add a,$10
	ld c,a
	jp	xpmp_tone_cmd_60


; Callback
xpmp_noise_cmd_E0:
	ld	hl,(xpmp_tempw)
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	ld	a,c
	cp	CMD_CBOFF
	jp	z,xpmp_tone_cmd_E0_cboff
	cp	CMD_CBONCE
	jp	z,xpmp_tone_cmd_E0_cbonce
	cp	CMD_CBEVNT
	jp	z,xpmp_tone_cmd_E0_cbevnt
	ret
	
	
xpmp_noise_cmd_F0:
	ld	hl,(xpmp_tempw)
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	ld	a,c


	cp	CMD_DUTMAC
	jp	nz,+
	inc	hl
	ld	a,(hl)
	ld	(ix+38),a
	xpmp_noise_reset_dt_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_dt_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+39),a
	inc	hl
	ld	a,(hl)
	ld	(ix+40),a
	ld	l,(ix+39)
	ld	h,(ix+40)
	ld	a,(hl)
	and	1
	ld	(ix+10),a
	ld	(ix+41),1
	ret
	
	+:
	.IFNDEF XPMP_VMAC_NOT_USED
	cp	CMD_VOLMAC
	jp	nz,xpmp_tone_cmd_F0_check_JMP
	inc	hl
	ld	a,(hl)
	ld	(ix+22),a
	xpmp_noise_reset_v_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_v_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+23),a
	inc	hl
	ld	a,(hl)
	ld	(ix+24),a
	ld	l,(ix+23)
	ld	h,(ix+24)
	ld	a,(hl)
	ld	(ix+13),a
	ld	a,1
	ld	(xpmp_volChange),a	
	ld	a,1
	ld	(ix+25),a
	ret
	.ENDIF
	
	

xpmp_call_hl:
	jp (hl)
	

xpmp_update_psg:
	ld	(xpmp_chnum),a
	add	a,a
	ld	e,a
	ld	d,0
	ld	hl,xpmp_channel_ptr_tbl
	add	hl,de
	ld	a,(hl)
	ld	(xpmp_tempw),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_tempw+1),a
	ld	ix,(xpmp_tempw)

	ld	a,(xpmp_chnum)
	rrca
	rrca
	rrca
	ld	(xpmp_chsel),a
	
	ld	a,0
	ld	(xpmp_freqChange),a
	ld	(xpmp_volChange),a
	
	ld	a,(ix+7)
	cp	CMD_END
	ret	z				; Playback has ended for this channel - all processing should be skipped
	
	ld 	l,(ix+5)			; Decrement the whole part of the delay and check if it has reached zero
	ld	h,(ix+6)
	dec	hl
	ld	a,h
	or	l
	jp 	nz,xpmp_update_psg_effects	
	
	; Loop here until a note/rest or END command is read (signaled by xpmp_freqChange == 2)
	xpmp_update_psg_read_cmd:
	ld	l,(ix+0)
	ld	h,(ix+1)
	ld	e,(ix+2)
	ld	d,(ix+3)
	add 	hl,de
	ld 	c,(hl)
	ld	(xpmp_tempw),hl			; Store HL for later use
	ld	a,c
	srl	a
	srl	a
	srl	a
	res	0,a				; A = (C>>3)&~1 = (C>>4)<<1
	ld	l,a
	ld	h,0
	ld	de,(xpmp_jump_tbl)	
	add	hl,de
	ld	e,(hl)				; HL = jump_tbl + (command >> 4)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	call	xpmp_call_hl

	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,xpmp_update_psg_freq_change
	jp 	xpmp_update_psg_read_cmd
	
	xpmp_update_psg_freq_change:
	ld	a,(ix+_CHN_NOTE)
	cp	CMD_REST
	jp	z,xpmp_update_psg_rest
	cp	CMD_REST2
	ret	z
	cp	CMD_END
	jp	z,xpmp_update_psg_rest
	ld	b,a
	ld	a,(ix+8)
	ld 	d,a
	ld	a,(ix+_PSG_TRANSP)
	add	a,d
	add	a,b
	ld	b,a
	ld	a,(xpmp_chnum)
	cp	3
	jr	z,xpmp_update_psg_noise
	ld	a,(ix+9)
	add	a,b
	ld	hl,xpmp_freq_tbl
	ld	d,0
	add	a,a
	ld	e,a
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	e,(ix+16)
	ld	d,(ix+17)
	and	a
	sbc	hl,de
	ld	e,(ix+20)
	ld	d,(ix+21)
	and	a
	sbc	hl,de
	JL_IMM16 $03EF,xpmp_update_psg_lb_ok
	ld	hl,(xpmp_freq_tbl+18)
	jp	xpmp_update_psg_freq_ok
	xpmp_update_psg_lb_ok:
	JGE_IMM16 $001C,xpmp_update_psg_freq_ok
	ld	hl,$001C
	xpmp_update_psg_freq_ok:
	ld	a,(xpmp_chsel)
	ld	b,a
	ld	a,l
	and	$0F
	or	$80
	or	b

	out	(XPMP_SN_PORT),a

	ld	a,h
	sla	l		
	rla			
	sla	l
	rla	
	sla	l
	rla	
	sla	l
	rla	
	out	(XPMP_SN_PORT),a

	jr	xpmp_update_psg_tone
	xpmp_update_psg_noise:
	ld	a,b
	and	3
	ld	b,a
	ld	a,(xpmp_channel3.duty)
	or	b
	or	$E0
	out	(XPMP_SN_PORT),a
	xor	$E0
	out	(XPMP_SN_PORT),a
	xpmp_update_psg_tone:
	ld	a,(xpmp_lastNote)
	cp	CMD_REST
	jr	nz,xpmp_update_psg_set_vol2
	jp	xpmp_update_psg_set_vol3

	xpmp_update_psg_set_vol:
	ld	a,(ix+7)
	cp	CMD_REST
	jr	z,xpmp_update_psg_rest
	xpmp_update_psg_set_vol2:
	; Update the volume if it has changed
	ld	a,(xpmp_volChange)
	cp	0
	ret	z
	xpmp_update_psg_set_vol3:
	ld	a,(xpmp_chsel)
	or	(ix+13)
	xor	$9F
	out	(XPMP_SN_PORT),a
	res	7,a
	out	(XPMP_SN_PORT),a
	
	xpmp_update_psg_no_vol_change:
	ret
	
	; Mute the channel
	xpmp_update_psg_rest:
	ld	a,(xpmp_chsel)
	or	$9F
	out	(XPMP_SN_PORT),a
	res	7,a
	out	(XPMP_SN_PORT),a
	ret

	xpmp_update_psg_effects:
	ld 	(ix+5),l
	ld	(ix+6),h

	call	xpmp_step_v_frame
	call	xpmp_step_en_frame
	call	xpmp_step_en2_frame
	;ld	a,(xpmp_chnum)
	;cp	3
	;jp	z,xpmp_update_psg_effects_done	
	call	xpmp_step_ep_frame
	call	xpmp_step_mp_frame
	call	xpmp_step_cs_frame

	xpmp_update_psg_effects_done:
	ld	a,(xpmp_freqChange)
	cp	0
	jp	nz,xpmp_update_psg_freq_change
	jp	xpmp_update_psg_set_vol
	ret	

	
	xpmp_step_v_frame:
	bit 	7,(ix+22)
	ret	nz
	xpmp_step_v:	
	.IFNDEF XPMP_VMAC_NOT_USED
	; Volume macro
	ld 	a,(ix+22)
	cp 	EFFECT_DISABLED
	jr 	z,xpmp_update_psg_v_done 
	xpmp_update_psg_v:
	ld 	l,(ix+23)
	ld	h,(ix+24)
	ld	a,1
	ld	(xpmp_volChange),a
	ld 	d,0
	ld 	a,(ix+25)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_psg_v_loop
	ld	(ix+13),a		 	; Set a new volume
	inc	de				; Increase the position
	ld	a,e
	ld	(ix+25),a
	jp	xpmp_update_psg_v_done
	xpmp_update_psg_v_loop:
	ld	a,(ix+22)			; Which volume macro are we using?
	and	$7F
	dec	a
	ld	e,a
	sla	e				; Each pointer is two bytes
	ld	bc,xpmp_v_mac_loop_tbl
	ld	hl,(xpmp_vMacPtr)
	ex	de,hl
	add	hl,bc 				; HL = xpmp_vMac_loop_tbl + (vMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a				; Store in xpmp_\1_vMac_ptr
	inc 	de	
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(ix+25),a
	ld	l,(ix+23)
	ld	h,(ix+24)
	ld	a,(hl)
	ld	(ix+13),a
	xpmp_update_psg_v_done:
	.ENDIF
	ret
	
	xpmp_step_en_frame:
	bit 	7,(ix+26)
	ret	nz
	xpmp_step_en:	
	.IFNDEF XPMP_ENMAC_NOT_USED
	; Cumulative arpeggio
	ld 	a,(ix+26)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_psg_EN_done
	xpmp_update_psg_EN:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	l,(ix+27)
	ld	h,(ix+28)
	ld 	d,0
	ld 	e,(ix+29)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_psg_EN_loop
	ld	b,a
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+29),a
	jp	xpmp_update_psg_EN_done		
	xpmp_update_psg_EN_loop:
	ld	a,(ix+26)			; Which arpeggio macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,(xpmp_enMacPtr)
	ld	bc,xpmp_EN_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a
	inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(ix+29),a			; Reset position
	ld	l,(ix+27)
	ld	h,(ix+28)
	ld	b,(hl)
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Reset note offset
	xpmp_update_psg_EN_done:
	.ENDIF
	ret
	
	xpmp_step_en2_frame:
	bit 	7,(ix+30)
	ret	nz
	xpmp_step_en2:		
	.IFNDEF XPMP_EN2MAC_NOT_USED
	; Non-cumulative arpeggio
	ld 	a,(ix+30)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_psg_EN2_done
	xpmp_update_psg_EN2:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	l,(ix+31)
	ld	h,(ix+32)
	ld 	d,0
	ld 	e,(ix+33)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_psg_EN2_loop
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+33),a
	jp	xpmp_update_psg_EN2_done		
	xpmp_update_psg_EN2_loop:
	ld	a,(ix+30)			; Which arpeggio macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,(xpmp_en2MacPtr)
	ld	bc,xpmp_EN_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (en2Mac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a
	inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(ix+33),a			; Reset position
	ld	l,(ix+31)
	ld	h,(ix+32)
	ld	a,(hl)
	ld	(ix+8),a			; Reset note offset
	xpmp_update_psg_EN2_done:
	.ENDIF
	ret
	
	;ld	a,(xpmp_chnum)
	;cp	3
	;jp	z,xpmp_update_psg_effects_done
	xpmp_step_ep_frame:
	bit 	7,(ix+34)
	ret	nz
	xpmp_step_ep:	
	.IFNDEF XPMP_EPMAC_NOT_USED
	; Sweep macro
	ld 	a,(ix+34)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_psg_EP_done
	xpmp_update_psg_EP:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	l,(ix+35)
	ld	h,(ix+36)
	ld 	d,0
	ld 	a,(ix+37)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_psg_EP_loop
	ld	b,a
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+37),a
	ld	e,b
	ld	d,0
	bit	7,b
	jr	z,xpmp_update_psg_pos_freq
	ld	d,$FF
	xpmp_update_psg_pos_freq:
	ld	l,(ix+16)
	ld	h,(ix+17)
	add	hl,de
	ld	(ix+16),l
	ld	(ix+17),h
	jp	xpmp_update_psg_EP_done		
	xpmp_update_psg_EP_loop:
	ld	a,(ix+34)			; Which sweep macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,(xpmp_epMacPtr)
	ld	bc,xpmp_EP_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EP_mac_loop_tbl + (epMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a
	inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(ix+37),a			; Reset position
	ld	l,(ix+35)
	ld	h,(ix+36)
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_update_psg_pos_freq_2
	ld	d,$FF
	xpmp_update_psg_pos_freq_2:
	ld	l,(ix+16)
	ld	h,(ix+17)
	add	hl,de
	ld	(ix+16),l
	ld	(ix+17),h
	xpmp_update_psg_EP_done:
	.ENDIF
	ret

	xpmp_step_mp_frame:
	bit 	7,(ix+38)
	ret	nz
	xpmp_step_mp:	
	.IFNDEF XPMP_MPMAC_NOT_USED
	; Vibrato
	;jp xpmp_update_psg_MP_done
	ld 	a,(ix+38)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_psg_MP_done
	ld	a,(ix+41)
	cp	0
	jr 	nz,xpmp_update_psg_MP_done2
	xpmp_update_psg_MP:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	l,(ix+39)
	ld	h,(ix+40)
	ld	e,(ix+18) 			; Load the frequency offset from the latch, then negate the latch
	ld	(ix+16),e
	ld	d,(ix+19)
	ld	(ix+17),d
	and	a				; Clear carry
	ld 	a,(hl)				; Reload the vibrato delay
	ld	hl,0
	sbc	hl,de
	ld	(ix+18),l
	ld	(ix+19),h
	inc	a
	xpmp_update_psg_MP_done2:
	dec	a
	ld	(ix+41),a
	xpmp_update_psg_MP_done:
	.ENDIF
	ret

	xpmp_step_cs_frame:
	bit 	7,(ix+55)
	ret	nz
	xpmp_step_cs:		
	.IFDEF XPMP_GAME_GEAR
	; Channel separation (pan) macro
	ld 	a,(ix+55)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_psg_CS_done
	xpmp_update_psg_CS:
	ld	l,(ix+56)
	ld	h,(ix+57)
	ld 	d,0
	ld 	a,(ix+58)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_psg_CS_loop
	ld	b,a
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+58),a
	jp	xpmp_update_psg_CS_do_write		
	xpmp_update_psg_CS_loop:
	ld	a,(ix+55)			; Which pan macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	bc,xpmp_CS_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_CS_mac_loop_tbl + (csMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+56),a
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+57),a
	ld	(ix+58),1			; Reset position
	ld	l,(ix+56)
	ld	h,(ix+57)
	ld	b,(hl)
	xpmp_update_psg_CS_do_write:
	ld	a,b
	call	xpmp_tone_write_pan
	xpmp_update_psg_CS_done:
	.ENDIF
	ret
	


xpmp_update:

.IFDEF XPMP_ENABLE_CHANNEL_A
	ld	a,0
	ld	iy,xpmp_panL
	ld	(iy+0),$FE
	ld	(iy+1),$10
	ld	(iy+2),$EF
	ld	(iy+3),$01
	ld	(iy+4),$11
	ld	hl,xpmp_tone_jump_tbl
	ld	(xpmp_jump_tbl),hl
	ld	hl,xpmp_channel0.vMacPtr
	ld	(xpmp_vMacPtr),hl
	ld	hl,xpmp_channel0.enMacPtr
	ld	(xpmp_enMacPtr),hl
	ld	hl,xpmp_channel0.en2MacPtr
	ld	(xpmp_en2MacPtr),hl
	ld	hl,xpmp_channel0.epMacPtr
	ld	(xpmp_epMacPtr),hl
	call 	xpmp_update_psg
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_B
	ld	a,1
	ld	iy,xpmp_panL
	ld	(iy+0),$FD
	ld	(iy+1),$20
	ld	(iy+2),$DF
	ld	(iy+3),$02
	ld	(iy+4),$22
	ld	hl,xpmp_tone_jump_tbl
	ld	(xpmp_jump_tbl),hl
	ld	hl,xpmp_channel1.vMacPtr
	ld	(xpmp_vMacPtr),hl
	ld	hl,xpmp_channel1.enMacPtr
	ld	(xpmp_enMacPtr),hl
	ld	hl,xpmp_channel1.en2MacPtr
	ld	(xpmp_en2MacPtr),hl
	ld	hl,xpmp_channel1.epMacPtr
	ld	(xpmp_epMacPtr),hl
	call 	xpmp_update_psg
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_C
	ld	a,2
	ld	iy,xpmp_panL
	ld	(iy+0),$FB
	ld	(iy+1),$40
	ld	(iy+2),$BF
	ld	(iy+3),$04
	ld	(iy+4),$44
	ld	hl,xpmp_tone_jump_tbl
	ld	(xpmp_jump_tbl),hl
	ld	hl,xpmp_channel2.vMacPtr
	ld	(xpmp_vMacPtr),hl
	ld	hl,xpmp_channel2.enMacPtr
	ld	(xpmp_enMacPtr),hl
	ld	hl,xpmp_channel2.en2MacPtr
	ld	(xpmp_en2MacPtr),hl
	ld	hl,xpmp_channel2.epMacPtr
	ld	(xpmp_epMacPtr),hl
	call 	xpmp_update_psg
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_D
	ld	a,3
	ld	iy,xpmp_panL
	ld	(iy+0),$F7
	ld	(iy+1),$80
	ld	(iy+2),$7F
	ld	(iy+3),$08
	ld	(iy+4),$88
	ld	hl,xpmp_noise_jump_tbl
	ld	(xpmp_jump_tbl),hl
	ld	hl,xpmp_channel3.vMacPtr
	ld	(xpmp_vMacPtr),hl
	ld	hl,xpmp_channel3.enMacPtr
	ld	(xpmp_enMacPtr),hl
	ld	hl,xpmp_channel3.en2MacPtr
	ld	(xpmp_en2MacPtr),hl
	ld	hl,xpmp_channel3.epMacPtr
	ld	(xpmp_epMacPtr),hl
	call 	xpmp_update_psg
.ENDIF

.IFDEF XPMP_ENABLE_FM
	ld	iy,xpmp_fmBufPtr
.ENDIF

.IFDEF XPMP_ENABLE_CHANNEL_E
	ld	a,0
	call 	xpmp_update_ym2413
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_F
	ld	a,1
	call 	xpmp_update_ym2413
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_G
	ld	a,2
	call 	xpmp_update_ym2413
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_H
	ld	a,3
	call 	xpmp_update_ym2413
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_I
	ld	a,4
	call 	xpmp_update_ym2413
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_J
	ld	a,5
	call 	xpmp_update_ym2413
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_K
	ld	a,6
	call 	xpmp_update_ym2413
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_L
	ld	a,7
	call 	xpmp_update_ym2413
.ENDIF

.IFDEF XPMP_ENABLE_CHANNEL_M
	ld	a,8
	call 	xpmp_update_ym2413
.ENDIF

.IFDEF XPMP_ENABLE_FM
	call	write_ym2413_buffer
.ENDIF

ret
	


xpmp_channel_ptr_tbl:
.dw xpmp_channel0
.dw xpmp_channel1
.dw xpmp_channel2
.dw xpmp_channel3



xpmp_tone_jump_tbl:
.dw xpmp_tone_cmd_00
.dw xpmp_tone_cmd_10
.dw xpmp_tone_cmd_20
.dw xpmp_tone_cmd_30
.dw xpmp_tone_cmd_40
.dw xpmp_tone_cmd_50
.dw xpmp_tone_cmd_60
.dw xpmp_tone_cmd_70
.dw xpmp_tone_cmd_80
.dw xpmp_tone_cmd_90
.dw xpmp_tone_cmd_A0
.dw xpmp_tone_cmd_B0
.dw xpmp_tone_cmd_C0
.dw xpmp_tone_cmd_D0
.dw xpmp_tone_cmd_E0
.dw xpmp_tone_cmd_F0

xpmp_noise_jump_tbl:
.dw xpmp_noise_cmd_00
.dw xpmp_tone_cmd_10
.dw xpmp_noise_cmd_20
.dw xpmp_tone_cmd_30
.dw xpmp_noise_cmd_40
.dw xpmp_noise_cmd_50
.dw xpmp_tone_cmd_60
.dw xpmp_tone_cmd_70
.dw xpmp_tone_cmd_80
.dw xpmp_tone_cmd_90
.dw xpmp_tone_cmd_A0
.dw xpmp_tone_cmd_B0
.dw xpmp_tone_cmd_C0
.dw xpmp_tone_cmd_D0
.dw xpmp_noise_cmd_E0
.dw xpmp_tone_cmd_F0



xpmp_freq_tbl:
.IFDEF XPMP_50_HZ
.IFDEF XPMP_TUNE_SMS
.dw $02A9,$0249,$01EF,$019A,$0149,$00FD,$00B5,$0072,$0032,$03F6,$03BD,$0387
.dw $0354,$0324,$02F7,$02CD,$02A4,$027E,$025A,$0239,$0219,$01FB,$01DE,$01C3
.dw $01AA,$0192,$017B,$0166,$0152,$013F,$012D,$011C,$010C,$00FD,$00EF,$00E1
.dw $00D5,$00C9,$00BD,$00B3,$00A9,$009F,$0096,$008E,$0086,$007E,$0077,$0070
.dw $006A,$0064,$005E,$0059,$0054,$004F,$004B,$0047,$0043,$003F,$003B,$0038
.dw $0035,$0032,$002F,$002C,$002A,$0027,$0025,$0023,$0021,$001F,$001D,$001C
.ELSE
.dw $029E,$023F,$01E5,$0191,$0141,$00F5,$00AE,$006B,$002B,$03EF,$03B7,$0381
.dw $034F,$031F,$02F2,$02C8,$02A0,$027A,$0257,$0235,$0215,$01F7,$01DB,$01C0
.dw $01A7,$018F,$0179,$0164,$0150,$013D,$012B,$011A,$010A,$00FB,$00ED,$00E0
.dw $00D3,$00C7,$00BC,$00B2,$00A8,$009E,$0095,$008D,$0085,$007D,$0076,$0070
.dw $0069,$0063,$005E,$0059,$0054,$004F,$004A,$0046,$0042,$003E,$003B,$0038
.dw $0034,$0031,$002F,$002C,$002A,$0027,$0025,$0023,$0021,$001F,$001D,$001C
.ENDIF
.ELSE
.IFDEF XPMP_TUNE_SMS
.dw $02B9,$0258,$01FD,$01A7,$0156,$0109,$00C0,$007C,$003C,$03FF,$03C5,$038F
.dw $035C,$032C,$02FE,$02D3,$02AB,$0284,$0260,$023E,$021E,$01FF,$01E2,$01C7
.dw $01AE,$0196,$017F,$0169,$0155,$0142,$0130,$011F,$010F,$00FF,$00F1,$00E3
.dw $00D7,$00CB,$00BF,$00B4,$00AA,$00A1,$0098,$008F,$0087,$007F,$0078,$0071
.dw $006B,$0065,$005F,$005A,$0055,$0050,$004C,$0047,$0043,$003F,$003C,$0038
.dw $0035,$0032,$002F,$002D,$002A,$0028,$0026,$0023,$0021,$001F,$001E,$001C
.ELSE
.dw $02AE,$024E,$01F3,$019E,$014D,$0101,$00B9,$0075,$0035,$03F8,$03BF,$0389
.dw $0357,$0327,$02F9,$02CF,$02A6,$0280,$025C,$023A,$021A,$01FC,$01DF,$01C4
.dw $01AB,$0193,$017C,$0167,$0153,$0140,$012E,$011D,$010D,$00FE,$00EF,$00E2
.dw $00D5,$00C9,$00BE,$00B3,$00A9,$00A0,$0097,$008E,$0086,$007F,$0077,$0071
.dw $006A,$0064,$005F,$0059,$0054,$0050,$004B,$0047,$0043,$003F,$003B,$0038
.dw $0035,$0032,$002F,$002C,$002A,$0028,$0025,$0023,$0021,$001F,$001D,$001C
.ENDIF
.ENDIF



;***********************************************************


.DEFINE _YM2413_PTR_L 0
.DEFINE _YM2413_PTR_H 1
.DEFINE _YM2413_POS_L 2
.DEFINE _YM2413_POS_H 3
.DEFINE _YM2413_DELAY 4
.DEFINE _YM2413_NOTE 7
.DEFINE _YM2413_NOTEOFFS 8
.DEFINE _YM2413_OCTAVE 9
.DEFINE _YM2413_INST 10
.DEFINE _YM2413_VOL 13
.DEFINE _YM2413_MODE 15
.DEFINE _YM2413_VMAC 22
.DEFINE _YM2413_ENMAC 26
.DEFINE _YM2413_EN2MAC 30
.DEFINE _YM2413_OCT2 41
.DEFINE _YM2413_LOOPPTR 48
.DEFINE _YM2413_RETADDR 50
.DEFINE _YM2413_OLDPOS 52
.DEFINE _YM2413_DELAYLATCH 57
.DEFINE _YM2413_TRANSP 60

.IFDEF XPMP_ENABLE_FM

; Note / rest
xpmp_ym2413_cmd_00:
xpmp_ym2413_cmd_60:
	ld	hl,(xpmp_tempw)

	ld	a,c
	cp	CMD_VOLUP
	jr	nz,xpmp_ym2413_cmd_00_2
	inc	(ix+_YM2413_POS_L)
	jr	nz,+
	inc	(ix+_YM2413_POS_H)
	+:
	ld	a,(ix+_YM2413_VOL)
	inc	hl
	add	a,(hl)
	ld	(ix+_YM2413_VOL),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	a,EFFECT_DISABLED
	ld	(ix+_YM2413_VMAC),a		; Volume set overrides volume macros
	ret
	
xpmp_ym2413_cmd_00_2:
	ld	a,(ix+_YM2413_NOTE)
	ld	(xpmp_lastNote),a
	ld	a,c
	and	$0F
	ld	(ix+_YM2413_NOTE),a
	ld	a,c
	and	$F0
	cp	CMD_NOTE2
	jr	z,xpmp_ym2413_cmd_00_std_delay	
	INC_DATAPOS 2
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_ym2413_cmd_00_short_note
		inc	de
		ld	(ix+_YM2413_POS_L),e
		ld	(ix+_YM2413_POS_H),d
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
		ld	a,(ix+_YM2413_DELAY)	
		add	a,(hl)
		ld	(ix+_YM2413_DELAY),a		; Fractional part
		ld	hl,0 
		adc	hl,de
		ld	(ix+_YM2413_DELAY+1),l		; Whole part
		ld	(ix+_YM2413_DELAY+2),h
		jp 	xpmp_ym2413_cmd_00_got_delay
	xpmp_ym2413_cmd_00_short_note:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(ix+_YM2413_DELAY)	
	add	a,(hl)
	ld	(ix+_YM2413_DELAY),a			; Fractional part
	ld	hl,0 
	adc	hl,de
	ret	z
	ld	(ix+_YM2413_DELAY+1),l			; Whole part
	ld	(ix+_YM2413_DELAY+2),h
	jp 	xpmp_ym2413_cmd_00_got_delay
	xpmp_ym2413_cmd_00_std_delay:			; Use delay set by last CMD_LEN
	ld	a,(ix+_YM2413_DELAYLATCH)
	ld	b,a
	ld	a,(ix+_YM2413_DELAY)
	add	a,b
	ld	(ix+_YM2413_DELAY),a
	ld 	l,(ix+_YM2413_DELAYLATCH+1)
	ld	h,(ix+_YM2413_DELAYLATCH+2)
	ld	de,0
	adc	hl,de
	ret	z
	ld	(ix+_YM2413_DELAY+1),l
	ld	(ix+_YM2413_DELAY+2),h
	xpmp_ym2413_cmd_00_got_delay:
	ld	a,2
	ld	(xpmp_freqChange),a
	ld	a,(ix+_YM2413_NOTE)
	cp	CMD_REST	
	ret	z					; If this was a rest command we can return now
	cp	CMD_REST2
	ret	z
	.IFNDEF XPMP_VMAC_NOT_USED
	ld	a,(ix+_YM2413_VMAC)
	cp	EFFECT_DISABLED
	call	nz,xpmp_ym2413_reset_v_mac		; Reset effects as needed..
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	ld	a,(ix+_YM2413_ENMAC)
	cp	EFFECT_DISABLED
	call	nz,xpmp_ym2413_reset_en_mac
	.ENDIF
	.IFNDEF XPMP_EN2MAC_NOT_USED
	ld	a,(ix+_YM2413_EN2MAC)
	cp	EFFECT_DISABLED
	call	nz,xpmp_ym2413_reset_en2_mac
	.ENDIF
	.IFNDEF XPMP_MPMAC_NOT_USED
	;ld	a,(ix+38)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_ym2413_reset_mp_mac
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	;ld	a,(ix+34)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_ym2413_reset_ep_mac
	.ENDIF
	ret
	
; Set octave
xpmp_ym2413_cmd_10:
	ld	a,c 
	and	$0F
	ld	b,a
	add	a,a
	ld	(ix+_YM2413_OCT2),a
	add	a,a
	sla	b
	sla	b
	sla	b
	add	a,b				; A = (C & $0F) * 12
	ld	(ix+_YM2413_OCTAVE),a
	ret

; Set instrument
xpmp_ym2413_cmd_20:
	ld	a,(xpmp_chnum)
	cp	6
	jr	c,+
	ld	a,(ix+_YM2413_MODE)
	cp	1
	jr	nz,+
	ld	a,c
	and	3
	ld	d,a
	ld	a,(xpmp_chnum)
	ld	e,a
	add	a,a
	add	a,e
	add	a,d
	ld	e,a
	ld	d,0
	ld	hl,xpmp_ym2413_drums
	add	hl,de
	ld	a,(hl)
	ld	(ix+_YM2413_INST),a
	ret
	+:
	ld	a,c
	and	$0F
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	(ix+_YM2413_INST),a
	ret

; Set volume (short)
xpmp_ym2413_cmd_30:
	ld	a,c
	and	$0F
	ld	(ix+_YM2413_VOL),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	a,EFFECT_DISABLED
	ld	(ix+_YM2413_VMAC),a			; Volume set overrides volume macros
	ret

; Octave up + note	
xpmp_ym2413_cmd_40:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+_YM2413_OCTAVE)
	add	a,12
	ld	(ix+_YM2413_OCTAVE),a
	ld	a,(ix+_YM2413_OCT2)
	add	a,2
	ld	(ix+_YM2413_OCT2),a
	ld 	a,c
	add 	a,$20
	ld 	c,a
	jp	xpmp_ym2413_cmd_00_2

; Octave down + note
xpmp_ym2413_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+_YM2413_OCTAVE)
	sub	12
	ld	(ix+_YM2413_OCTAVE),a
	ld	a,(ix+_YM2413_OCT2)
	sub	2
	ld	(ix+_YM2413_OCT2),a
	ld 	a,c
	add 	a,$10
	ld 	c,a
	jp	xpmp_ym2413_cmd_00_2
	

xpmp_ym2413_cmd_70:
xpmp_ym2413_cmd_80:
	ret

; Turn off arpeggio macro
xpmp_ym2413_cmd_90:
	ld	hl,(xpmp_tempw)
	ld	a,c
	cp	CMD_ARPOFF
	jr	z,xpmp_ym2413_cmd_90_90
	;cp	CMD_FBKMAC
	;jr	z,xpmp_ym2413_cmd_90_91
	cp	CMD_JSR
	jp	z,xpmp_ym2413_cmd_90_jsr
	cp	CMD_RTS
	jr	z,xpmp_ym2413_cmd_90_rts
	cp	CMD_LEN
	jp	z,xpmp_ym2413_cmd_90_len
	cp	CMD_WRMEM
	jp	z,xpmp_tone_cmd_90_wrmem
	cp	CMD_WRPORT
	jp	z,xpmp_tone_cmd_90_wrport
	cp	CMD_TRANSP
	jp	z,xpmp_ym2413_cmd_90_transp
	ret
	
	xpmp_ym2413_cmd_90_90:
	ld	(ix+_YM2413_ENMAC),0
	ld	(ix+_YM2413_EN2MAC),0
	ld	(ix+8),0
	ret

	xpmp_ym2413_cmd_90_91:
	inc	(ix+_YM2413_POS_L)
	jr	nz,+
	inc	(ix+_YM2413_POS_H)
	+:
	ret

	; Return from pattern
	xpmp_ym2413_cmd_90_rts:
	ld	a,(ix+_YM2413_RETADDR)
	ld	(ix+_YM2413_PTR_L),a
	ld	a,(ix+_YM2413_RETADDR+1)
	ld	(ix+_YM2413_PTR_H),a
	ld	a,(ix+_YM2413_OLDPOS)
	ld	(ix+_YM2413_POS_L),a
	ld	a,(ix+_YM2413_OLDPOS+1)
	ld	(ix+_YM2413_POS_H),a
	ret
	
	; Jump to pattern
	xpmp_ym2413_cmd_90_jsr:
	ld	e,(ix+_YM2413_POS_L)
	ld	d,(ix+_YM2413_POS_H)
	inc	de
	ld	(ix+_YM2413_OLDPOS),e
	ld	(ix+_YM2413_OLDPOS+1),d
	ld	a,(ix+_YM2413_PTR_L)
	ld	(ix+_YM2413_RETADDR),a
	ld	a,(ix+_YM2413_PTR_H)
	ld	(ix+_YM2413_RETADDR+1),a
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	a,(hl)
	ld	de,xpmp_pattern_tbl
	ld	h,0
	add	a,a
	ld	l,a
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(ix+_YM2413_PTR_L),e
	ld	(ix+_YM2413_PTR_H),d
	ld	(ix+_YM2413_POS_L),$FF
	ld	(ix+_YM2413_POS_H),$FF
	ret
	
	xpmp_ym2413_cmd_90_len:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 2	
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_ym2413_cmd_90_short_delay
		inc	de
		ld	(ix+_YM2413_POS_L),e
		ld	(ix+_YM2413_POS_H),d
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
		ld	(ix+_YM2413_DELAYLATCH),a	; Fractional part
		ld	(ix+_YM2413_DELAYLATCH+1),e	; Whole part
		ld	(ix+_YM2413_DELAYLATCH+2),d	; ...
		ret
	xpmp_ym2413_cmd_90_short_delay:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(hl)
	ld	(ix+_YM2413_DELAYLATCH),a	; Fractional part
	ld	(ix+_YM2413_DELAYLATCH+1),e	; Whole part
	ld	(ix+_YM2413_DELAYLATCH+2),d
	ret

	xpmp_ym2413_cmd_90_transp:
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	a,(hl)
	ld	(ix+_YM2413_TRANSP),a
	INC_DATAPOS 1
	ret		

; Set mode
xpmp_ym2413_cmd_A0:
	ld	a,c
	and	1
	ld	(ix+_YM2413_MODE),a
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	b,a
	ld	a,(xpmp_ym2413Rhythm)
	and	$1F
	or	b
	ld	(xpmp_ym2413Rhythm),a
	ret


; Set feedback
xpmp_ym2413_cmd_B0:
	ld	(iy+0),3
	ld	a,c
	and	7
	ld	(iy+1),a
	inc	iy
	inc	iy
	ret
	
	
; Set operator	
xpmp_ym2413_cmd_C0:
	ld	a,c
	and	3
	ld	(xpmp_ym2413Oper),a
	ret

; Set rate scaling
xpmp_ym2413_cmd_D0:
	ld	hl,(xpmp_tempw)
	inc	(ix+_YM2413_POS_L)
	jr	nz,+
	inc	(ix+_YM2413_POS_H)
	+:
	ret

xpmp_ym2413_cmd_E0:
	ld	hl,(xpmp_tempw)
	inc	(ix+_YM2413_POS_L)
	jr	nz,+
	inc	(ix+_YM2413_POS_H)
	+:
	ld	a,c
	cp	CMD_ADSR
	jr	z,xpmp_ym2413_cmd_E0_adsr
	cp	CMD_DETUNE
	jp	z,xpmp_ym2413_cmd_E0_detune
	cp	CMD_MULT
	jp	z,xpmp_ym2413_cmd_E0_mult
	cp	CMD_HWTE
	jp	z,xpmp_ym2413_cmd_E0_hwte
	cp	CMD_HWVE
	jp	z,xpmp_ym2413_cmd_E0_hwve
	cp	CMD_HWAM
	jp	z,xpmp_ym2413_cmd_E0_am
	cp	CMD_MODMAC
	jp	z,xpmp_ym2413_cmd_E0_mod
	ret

xpmp_ym2413_cmd_E0_adsr:
	inc	hl
	ld	a,(hl)
	dec	a
	add	a,a
	ld	hl,xpmp_ADSR_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(xpmp_ym2413Oper)
	cp	0
	jr	z,xpmp_ym2413_adsr_all
	xpmp_ym2413_adsr_spec:
	add	a,3
	ld	(iy+0),a
	add	a,2
	ld	(iy+2),a
	ld	a,(hl)
	ld	(iy+1),a
	inc	hl
	ld	a,(hl)
	ld	(iy+3),a
	inc	iy
	inc	iy
	inc	iy
	inc	iy
	ret
	xpmp_ym2413_adsr_all:
	ld	(xpmp_tempv),hl
	ld	a,1
	call	xpmp_ym2413_adsr_spec
	ld	hl,(xpmp_tempv)	
	ld	a,2
	call	xpmp_ym2413_adsr_spec
	ret

xpmp_ym2413_cmd_E0_mult:
	inc	hl
	ld	a,(hl)
	and	15
	ld	c,a
	ld	a,(xpmp_ym2413Oper)
	cp	2
	jr	nc,xpmp_ym2413_mult_op2
	ld	(iy+0),0
	ld	a,(xpmp_ym2413Reg0)
	and	$F0
	or	c
	ld	(xpmp_ym2413Reg0),a
	ld	(iy+1),a
	inc	iy
	inc	iy
	xpmp_ym2413_mult_op2:
	ld	a,(xpmp_ym2413Oper)
	cp	1
	ret	z
	ld	(iy+0),1
	ld	a,(xpmp_ym2413Reg1)
	and	$F0
	or	c
	ld	(xpmp_ym2413Reg1),a
	ld	(iy+1),a
	inc	iy
	inc	iy
	ret
	
xpmp_ym2413_cmd_E0_detune:
	inc	hl
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_ym2413_cmd_E0_detune_pos
	ld	d,$FF
	xpmp_ym2413_cmd_E0_detune_pos:
	ld	(ix+20),e
	ld	(ix+21),d
	ret

; Set EGTYP for instrument 0
xpmp_ym2413_cmd_E0_hwte:
	inc	hl
	ld	a,(hl)
	and	1
	rrca
	rrca
	rrca
	ld	l,a
	ld	a,(xpmp_ym2413Oper)
	cp	2
	jr	nc,xpmp_ym2413_hwte_op2
	ld	(iy+0),a
	ld	a,(xpmp_ym2413Reg0)
	and	$DF
	or	l
	ld	(xpmp_ym2413Reg0),a
	ld	(iy+1),a
	inc	iy
	inc	iy
	xpmp_ym2413_hwte_op2:
	ld	a,(xpmp_ym2413Oper)
	cp	1
	ret	z
	ld	(iy+0),1
	ld	a,(xpmp_ym2413Reg1)
	and	$DF
	or	l
	ld	(xpmp_ym2413Reg1),a
	ld	(iy+1),a
	inc	iy
	inc	iy
	ret

; Set TL for instrument 0	
xpmp_ym2413_cmd_E0_hwve:
	ld	(iy+0),2
	inc	hl
	ld	a,(hl)
	ld	(iy+1),a
	inc	iy
	inc	iy
	ret
	
xpmp_ym2413_cmd_E0_am:
	inc	hl
	ld	a,(hl)
	rrca
	ld	l,a
	ld	a,(xpmp_ym2413Oper)
	cp	2
	jr	nc,xpmp_ym2413_am_op2
	ld	(iy+0),0
	ld	a,(xpmp_ym2413Reg0)
	and	$7F
	or	l
	ld	(xpmp_ym2413Reg0),a
	ld	(iy+1),a
	inc	iy
	inc	iy
	xpmp_ym2413_am_op2:
	ld	a,(xpmp_ym2413Oper)
	cp	1
	ret	z
	ld	(iy+0),1	
	ld	a,(xpmp_ym2413Reg1)
	and	$7F
	or	l
	ld	(xpmp_ym2413Reg1),a
	ld	(iy+1),a
	inc	iy
	inc	iy
	ret

xpmp_ym2413_cmd_E0_mod:
	inc	hl
	ld	a,(hl)
	; TODO
	ret
	

xpmp_ym2413_cmd_F0:
	ld	hl,(xpmp_tempw)
	inc	(ix+_YM2413_POS_L)
	jr	nz,+
	inc	(ix+_YM2413_POS_H)
	+:
	ld	a,c
	cp	CMD_VOLMAC
	jr	z,xpmp_ym2413_cmd_F0_VOLMAC
	cp	CMD_SWPMAC
	jp	z,xpmp_ym2413_cmd_F0_SWPMAC
	cp	CMD_ARPMAC
	jp	z,xpmp_ym2413_cmd_F0_ARPMAC
	cp	CMD_APMAC2
	jp	z,xpmp_ym2413_cmd_F0_APMAC2
	cp	CMD_LOPCNT
	jp	z,xpmp_ym2413_cmd_F0_LOPCNT
	cp	CMD_DJNZ
	jp	z,xpmp_ym2413_cmd_F0_DJNZ
	cp	CMD_JMP
	jp	z,xpmp_ym2413_cmd_F0_JMP
	cp	CMD_J1
	jp	z,xpmp_ym2413_cmd_F0_J1
	cp	CMD_END
	jr	z,xpmp_ym2413_cmd_F0_END
	ret

	xpmp_ym2413_cmd_F0_END:
	ld	a,CMD_END
	ld	(ix+_YM2413_NOTE),a		; Playback of this channel should end
	ld	a,2
	ld	(xpmp_freqChange),a		; The command-reading loop should exit	
	ret
	
	xpmp_ym2413_cmd_F0_VOLMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+_YM2413_VMAC),a
	xpmp_ym2413_reset_v_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_v_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+_YM2413_VMAC+1),a
	inc	hl
	ld	a,(hl)
	ld	(ix+_YM2413_VMAC+2),a
	ld	l,(ix+_YM2413_VMAC+1)
	ld	h,(ix+_YM2413_VMAC+2)
	ld 	(ix+_YM2413_VMAC+3),1 		; Macro position
	ld 	b,(hl)
	ld 	(ix+_YM2413_VOL),b
	ld	a,1
	ld	(xpmp_volChange),a
	ret
	
	; Initialize sweep macro
	xpmp_ym2413_cmd_F0_SWPMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+34),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_ym2413_cmd_F0_disable_SWPMAC	
	xpmp_ym2413_reset_ep_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_EP_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+35),a
	inc	hl
	ld	a,(hl)
	ld	(ix+36),a
	ld	l,(ix+35)
	ld	h,(ix+36)
	ld	a,1
	ld	(ix+37),a
	dec	a
	;ld	(ix+12),a
	ld	a,(hl)
	;ld	(ix+11),a
	bit	7,a
	ret	z
	ld	a,$FF
	;ld	(ix+12),a
	ret
	xpmp_ym2413_cmd_F0_disable_SWPMAC:
	ld	(ix+34),a
	;ld	(ix+11),a
	;ld	(ix+12),a
	ret
	
	; Jump
	xpmp_ym2413_cmd_F0_JMP:
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+_YM2413_POS_L),e
	ld	(ix+_YM2413_POS_H),d
	ret

	; Set loop count
	xpmp_ym2413_cmd_F0_LOPCNT:
	inc	hl
	ld	a,(hl)
	ld	l,(ix+_YM2413_LOOPPTR)
	ld	h,(ix+_YM2413_LOOPPTR+1)
	inc	hl
	ld	(hl),a
	ld	(ix+_YM2413_LOOPPTR),l
	ld	(ix+_YM2413_LOOPPTR+1),h
	ret

	; Jump if one
	xpmp_ym2413_cmd_F0_J1:
	ld	l,(ix+_YM2413_LOOPPTR)
	ld	h,(ix+_YM2413_LOOPPTR+1)
	ld	a,(hl)
	cp	1
	jr	nz,xpmp_ym2413_cmd_F0_J1_N1	; Check if the counter has reached 1
	dec	hl
	ld	(ix+_YM2413_LOOPPTR),l
	ld	(ix+_YM2413_LOOPPTR+1),h
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+_YM2413_POS_L),e
	ld	(ix+_YM2413_POS_H),d
	ret
	xpmp_ym2413_cmd_F0_J1_N1:
	inc	(ix+_YM2413_POS_L)
	jr	nz,+
	inc	(ix+_YM2413_POS_H)
	+:
	ret
	
	; Decrease and jump if not zero
	xpmp_ym2413_cmd_F0_DJNZ:
	ld	l,(ix+_YM2413_LOOPPTR)
	ld	h,(ix+_YM2413_LOOPPTR+1)
	dec	(hl)
	;foo: jr foo
	jr	z,xpmp_ym2413_cmd_F0_DJNZ_Z	; Check if the counter has reached zero
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+_YM2413_POS_L),e
	ld	(ix+_YM2413_POS_H),d
	ret
	xpmp_ym2413_cmd_F0_DJNZ_Z:
	dec	hl
	ld	(ix+_YM2413_LOOPPTR),l
	ld	(ix+_YM2413_LOOPPTR+1),h
	inc	(ix+_YM2413_POS_L)
	jr	nz,+
	inc	(ix+_YM2413_POS_H)
	+:
	ret

	xpmp_ym2413_cmd_F0_ALGMAC:
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_ym2413_cmd_F0_APMAC2:
	inc	hl
	ld	a,(hl)
	ld	(ix+_YM2413_EN2MAC),a
	xpmp_ym2413_reset_en2_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_EN_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+_YM2413_EN2MAC+1),a
	inc	hl
	ld	a,(hl)
	ld	(ix+_YM2413_EN2MAC+2),a
	ld	l,(ix+_YM2413_EN2MAC+1)
	ld	h,(ix+_YM2413_EN2MAC+2)
	ld	a,(hl)
	ld	(ix+8),a
	ld	(ix+_YM2413_EN2MAC+3),1
	ld	(ix+_YM2413_ENMAC),0
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_ym2413_cmd_F0_ARPMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+_YM2413_ENMAC),a
	xpmp_ym2413_reset_en_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_EN_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+_YM2413_ENMAC+1),a
	inc	hl
	ld	a,(hl)
	ld	(ix+_YM2413_ENMAC+2),a
	ld	l,(ix+_YM2413_ENMAC+1)
	ld	h,(ix+_YM2413_ENMAC+2)
	ld	a,(hl)
	ld	(ix+8),a
	ld	(ix+_YM2413_ENMAC+3),1
	ld	(ix+_YM2413_EN2MAC),0
	ret
	
	
xpmp_update_ym2413:
	ld	(xpmp_chnum),a
	add	a,a
	ld	e,a
	ld	d,0
	ld	hl,xpmp_ym2413_channel_ptr_tbl
	add	hl,de
	ld	a,(hl)
	ld	(xpmp_tempw),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_tempw+1),a
	ld	ix,(xpmp_tempw)
	
	ld	a,0
	ld	(xpmp_freqChange),a
	ld	(xpmp_volChange),a
	
	ld	a,(ix+_YM2413_NOTE)
	cp	CMD_END
	ret	z				; Playback has ended for this channel - all processing should be skipped
	
	ld 	l,(ix+_YM2413_DELAY+1)		; Decrement the whole part of the delay and check if it has reached zero
	ld	h,(ix+_YM2413_DELAY+2)
	dec	hl
	ld	a,h
	or	l
	jp 	nz,xpmp_update_ym2413_effects	
	
	; Loop here until a note/rest or END command is read (signaled by xpmp_freqChange == 2)
	xpmp_update_ym2413_read_cmd:
	ld	l,(ix+_YM2413_PTR_L)
	ld	h,(ix+_YM2413_PTR_H)
	ld	e,(ix+_YM2413_POS_L)
	ld	d,(ix+_YM2413_POS_H)
	add 	hl,de
	ld 	c,(hl)
	ld	(xpmp_tempw),hl			; Store HL for later use
	ld	a,c
	srl	a
	srl	a
	srl	a
	res	0,a				; A = (C>>3)&~1 = (C>>4)<<1
	ld	l,a
	ld	h,0
	ld	de,xpmp_ym2413_jump_tbl	
	add	hl,de
	ld	e,(hl)				; HL = jump_tbl + (command >> 4) * 2
	inc	hl
	ld	d,(hl)
	ex	de,hl
	call	xpmp_call_hl

	inc	(ix+_YM2413_POS_L)
	jr	nz,+
	inc	(ix+_YM2413_POS_H)
	+:
	
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,xpmp_update_ym2413_freq_change
	jp 	xpmp_update_ym2413_read_cmd
	
	xpmp_update_ym2413_freq_change:
	ld	a,(ix+_YM2413_NOTE)
	cp	CMD_REST
	jp	z,xpmp_update_ym2413_rest
	cp	CMD_REST2
	ret	z
	cp	CMD_END
	jp	z,xpmp_update_ym2413_rest
	ld	c,a

	ld	a,(xpmp_freqChange)
	cp	2
	jr	nz,+
	ld	a,(xpmp_chnum)
	add	a,$20
	ld	(iy+0),a
	ld	(iy+1),0	; KEY_OFF
	inc	iy
	inc	iy
	+:
	
	ld	d,(ix+_YM2413_NOTEOFFS)
	ld	a,(ix+_YM2413_TRANSP)
	add	a,d
	add	a,c
	ld	b,a
	ld	a,(ix+_YM2413_OCTAVE)
	add	a,b
	bit	7,a
	jr	z,ym2413_note_lb_ok
	ld	a,0
	jr	ym2413_note_ok
	ym2413_note_lb_ok:
	cp	96
	jr	c,ym2413_note_ok
	ld	a,95
	ym2413_note_ok:
	
	ld	hl,xpmp_ym2413_freq_tbl
	ld	d,0
	add	a,a
	ld	e,a
	add	hl,de
	ld	a,(xpmp_chnum)
	add	a,$10
	ld	(iy+0),a
	ld	a,(hl)
	ld	(iy+1),a
	inc	iy
	inc	iy
	inc	hl
	ld	a,(ix+_YM2413_OCT2)
	or	(hl)
	or	$30
	ld	(iy+1),a

	ld	a,(xpmp_chnum)
	add	a,$20
	ld	(iy+0),a
	inc	iy
	inc	iy
	
	ld	a,(xpmp_lastNote)
	cp	CMD_REST
	jr	nz,xpmp_update_ym2413_set_vol2
	jp	xpmp_update_ym2413_set_vol3

	xpmp_update_ym2413_set_vol:
	ld	a,(ix+_YM2413_NOTE)
	cp	CMD_REST
	jr	z,xpmp_update_ym2413_rest
	xpmp_update_ym2413_set_vol2:
	; Update the volume if it has changed
	ld	a,(xpmp_volChange)
	cp	0
	ret	z
	xpmp_update_ym2413_set_vol3:
	ld	a,(xpmp_chnum)
	add	a,$30
	ld	(iy+0),a
	ld	a,(ix+_YM2413_VOL)
	xor	15
	or	(ix+_YM2413_INST)
	ld	(iy+1),a
	inc	iy
	inc	iy
	xpmp_update_ym2413_no_vol_change:
	ret
	
	; Mute the channel
	xpmp_update_ym2413_rest:
	;ld	a,(xpmp_chnum)
	;add	a,$20
	;ld	(iy+0),a
	;ld	a,15
	;or	(ix+_YM2413_INST)
	;ld	(iy+1),a
	;inc	iy
	;inc	iy
	ld	a,(xpmp_chnum)
	add	a,$20
	ld	(iy+0),a
	ld	(iy+1),0	; KEY_OFF
	inc	iy
	inc	iy
	
	ret	
	
	xpmp_update_ym2413_effects:
	ld 	(ix+_YM2413_DELAY+1),l
	ld	(ix+_YM2413_DELAY+2),h

	.IFNDEF XPMP_VMAC_NOT_USED
	; Volume macro
	ld 	a,(ix+_YM2413_VMAC)
	cp 	EFFECT_DISABLED
	jr 	z,xpmp_update_ym2413_v_done 
	xpmp_update_ym2413_v:
	ld 	l,(ix+_YM2413_VMAC+1)
	ld	h,(ix+_YM2413_VMAC+2)
	ld	a,1
	ld	(xpmp_volChange),a
	ld 	d,0
	ld 	a,(ix+_YM2413_VMAC+3)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ym2413_v_loop
	ld	(ix+_YM2413_VOL),a		 	; Set a new volume
	inc	de				; Increase the position
	ld	a,e
	ld	(ix+_YM2413_VMAC+3),a
	jp	xpmp_update_ym2413_v_done
	xpmp_update_ym2413_v_loop:
	ld	a,(ix+_YM2413_VMAC)		; Which volume macro are we using?
	dec	a
	ld	e,a
	sla	e				; Each pointer is two bytes
	ld	bc,xpmp_v_mac_loop_tbl
	;ld	hl,(xpmp_vMacPtr)
	ex	de,hl
	add	hl,bc 				; HL = xpmp_vMac_loop_tbl + (vMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+_YM2413_VMAC+1),a		; Store in xpmp_\1_vMac_ptr
	;inc 	de	
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+_YM2413_VMAC+2),a
	ld	(ix+_YM2413_VMAC+3),1		; Reset position
	ld	l,(ix+_YM2413_VMAC+1)
	ld	h,(ix+_YM2413_VMAC+2)
	ld	a,(hl)
	ld	(ix+_YM2413_VOL),a
	xpmp_update_ym2413_v_done:
	.ENDIF
	
	.IFNDEF XPMP_ENMAC_NOT_USED
	; Cumulative arpeggio
	ld 	a,(ix+_YM2413_ENMAC)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ym2413_EN_done
	xpmp_update_ym2413_EN:
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	ld	l,(ix+_YM2413_ENMAC+1)
	ld	h,(ix+_YM2413_ENMAC+2)
	ld 	d,0
	ld 	e,(ix+_YM2413_ENMAC+3)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ym2413_EN_loop
	ld	b,a
	ld	a,(ix+_YM2413_NOTEOFFS)
	add	a,b
	ld	(ix+_YM2413_NOTEOFFS),a		; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+_YM2413_ENMAC+3),a
	jp	xpmp_update_ym2413_EN_done		
	xpmp_update_ym2413_EN_loop:
	ld	a,(ix+_YM2413_ENMAC)		; Which arpeggio macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	;ld	hl,(xpmp_enMacPtr)
	ld	bc,xpmp_EN_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+_YM2413_ENMAC+1),a
	;inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+_YM2413_ENMAC+2),a
	ld	(ix+_YM2413_ENMAC+3),1		; Reset position
	ld	l,(ix+_YM2413_ENMAC+1)
	ld	h,(ix+_YM2413_ENMAC+2)
	ld	b,(hl)
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Reset note offset
	xpmp_update_ym2413_EN_done:
	.ENDIF
	
	.IFNDEF XPMP_EN2MAC_NOT_USED
	; Non-cumulative arpeggio
	ld 	a,(ix+_YM2413_EN2MAC)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ym2413_EN2_done
	xpmp_update_ym2413_EN2:
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	ld	l,(ix+_YM2413_EN2MAC+1)
	ld	h,(ix+_YM2413_EN2MAC+2)
	ld 	d,0
	ld 	e,(ix+_YM2413_EN2MAC+3)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ym2413_EN2_loop
	ld	(ix+_YM2413_NOTEOFFS),a		; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+_YM2413_EN2MAC+3),a
	jp	xpmp_update_ym2413_EN2_done		
	xpmp_update_ym2413_EN2_loop:
	ld	a,(ix+_YM2413_EN2MAC)		; Which arpeggio macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	;ld	hl,(xpmp_en2MacPtr)
	ld	bc,xpmp_EN_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (en2Mac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+_YM2413_EN2MAC+1),a
	;inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+_YM2413_EN2MAC+2),a
	;ld	a,1
	ld	(ix+_YM2413_EN2MAC+3),1		; Reset position
	ld	l,(ix+_YM2413_EN2MAC+1)
	ld	h,(ix+_YM2413_EN2MAC+2)
	ld	a,(hl)
	ld	(ix+_YM2413_NOTEOFFS),a		; Reset note offset
	xpmp_update_ym2413_EN2_done:
	.ENDIF

	xpmp_update_ym2413_effects_done:
	ld	a,(xpmp_freqChange)
	cp	0
	jp	nz,xpmp_update_ym2413_freq_change
	jp	xpmp_update_ym2413_set_vol
	
	ret



xpmp_ym2413_freq_tbl:
.dw 171,181,192,203,216,228,242,256,272,288,305,323
.dw 171,181,192,203,216,228,242,256,272,288,305,323
.dw 171,181,192,203,216,228,242,256,272,288,305,323
.dw 171,181,192,203,216,228,242,256,272,288,305,323
.dw 171,181,192,203,216,228,242,256,272,288,305,323
.dw 171,181,192,203,216,228,242,256,272,288,305,323
.dw 171,181,192,203,216,228,242,256,272,288,305,323
.dw 171,181,192,203,216,228,242,256,272,288,305,323


xpmp_ym2413_channel_ptr_tbl:
.dw xpmp_channel4
.dw xpmp_channel5
.dw xpmp_channel6
.dw xpmp_channel7
.dw xpmp_channel8
.dw xpmp_channel9
.dw xpmp_channel10
.dw xpmp_channel11
.dw xpmp_channel12


xpmp_ym2413_jump_tbl:
.dw xpmp_ym2413_cmd_00
.dw xpmp_ym2413_cmd_10
.dw xpmp_ym2413_cmd_20
.dw xpmp_ym2413_cmd_30
.dw xpmp_ym2413_cmd_40
.dw xpmp_ym2413_cmd_50
.dw xpmp_ym2413_cmd_60
.dw xpmp_ym2413_cmd_70
.dw xpmp_ym2413_cmd_80
.dw xpmp_ym2413_cmd_90
.dw xpmp_ym2413_cmd_A0
.dw xpmp_ym2413_cmd_B0
.dw xpmp_ym2413_cmd_C0
.dw xpmp_ym2413_cmd_D0
.dw xpmp_ym2413_cmd_E0
.dw xpmp_ym2413_cmd_F0

xpmp_ym2413_drums:
.db $10,$10,$10
.db $08,$01,$09
.db $02,$04,$06
.ENDIF

	