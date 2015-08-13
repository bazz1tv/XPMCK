; Cross Platform Music Player
; Genesis Z80 driver
; /Mic, 2008-2010


.memorymap
	defaultslot 0

	slotsize $2000
	slot 0 0
.endme

.rombanksize $2000
.rombanks 1


; The effect pointer tables are copied to fixed addresses in Z80 RAM by the 68k code.
; These addresses are defined here.
.DEFINE xpmp_dt_mac_tbl 	$1E40
.DEFINE xpmp_dt_mac_loop_tbl 	$1E42
.DEFINE xpmp_v_mac_tbl 		$1E44
.DEFINE xpmp_v_mac_loop_tbl 	$1E46
.DEFINE xpmp_EP_mac_tbl 	$1E48
.DEFINE xpmp_EP_mac_loop_tbl 	$1E4A
.DEFINE xpmp_EN_mac_tbl 	$1E4C
.DEFINE xpmp_EN_mac_loop_tbl 	$1E4E
.DEFINE xpmp_MP_mac_tbl		$1E50
.DEFINE xpmp_ADSR_tbl 		$1E52
.DEFINE xpmp_MOD_tbl		$1E54
.DEFINE xpmp_pattern_tbl	$1E56
.DEFINE xpmp_FB_mac_tbl 	$1E58
.DEFINE xpmp_FB_mac_loop_tbl 	$1E5A
.DEFINE xpmp_song_tbl		$1E5C
	
.DEFINE XPMP_RAM_START 		$1B00

; The FM command buffer has the following structure:
;  nCommandsInBuffer command command command ...
;
; Each command is two bytes. The first byte contains
; the register to write to, the second byte contains
; the value to write.
.DEFINE XPMP_FM_BUF 		$1E80	

.DEFINE XPMP_ENABLE_CHANNEL_A
.DEFINE XPMP_ENABLE_CHANNEL_B
.DEFINE XPMP_ENABLE_CHANNEL_C
.DEFINE XPMP_ENABLE_CHANNEL_D


.EQU CMD_NOTE   $00
.EQU CMD_REST	$0C
.EQU CMD_REST2  $0D
.EQU CMD_VOLUP	$0E
.EQU CMD_OCTAVE $10
.EQU CMD_DUTY   $20
.EQU CMD_VOL2   $30
.EQU CMD_OCTUP  $40
.EQU CMD_OCTDN  $50
.EQU CMD_NOTE2	$60
.EQU CMD_ARPOFF $90
.EQU CMD_FBKMAC $91
.EQU CMD_JSR	$96
.EQU CMD_RTS	$97
.EQU CMD_LEN	$9A
.EQU CMD_WRMEM  $9B
.EQU CMD_WRPORT $9C
.EQU CMD_TRANSP $9F
.EQU CMD_MODE   $A0
.EQU CMD_FEEDBK $B0
.EQU CMD_OPER   $C0
.EQU CMD_RSCALE $D0
.EQU CMD_CBOFF  $E0
.EQU CMD_CBONCE $E1
.EQU CMD_CBEVNT $E2
.EQU CMD_CBEVVC $E3
.EQU CMD_CBEVVM $E4
.EQU CMD_CBEVOC $E5
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
.EQU CMD_J1     $FD
.EQU CMD_END    $FF

.EQU EFFECT_DISABLED 0


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
transpose	db	; 55
.ENDST


.EQU _CHN_DATAPTR	0
.EQU _CHN_DATAPOS 	2
.EQU _CHN_DELAY		4
.EQU _CHN_NOTE 		7
.EQU _CHN_NOTEOFFS	8
.EQU _CHN_OCTAVE	9
.EQU _PSG_VOLUME	13
.EQU _FM_VOLUME 	15
.EQU _FM_VMAC 		16
.EQU _PSG_VMAC 		22
.EQU _PSG_ENMAC		26
.EQU _PSG_EN2MAC	30
.EQU _FM_LOOPPTR	34
.EQU _FM_OCT8		38
.EQU _FM_OPER 		39
.EQU _FM_REG3X		40
.EQU _FM_REG4X		44
.EQU _FM_REG5X		48
.EQU _PSG_TRANSP	55
.EQU _FM_TL 		83
.EQU _FM_TRANSP		87

; For YM2612 channels
.STRUCT xpmp_fm_channel_t
dataPtr		dw	; 0
dataPos		dw	; 2
delay		dw	; 4
delayHi		db	; 6
note		db	; 7
noteOffs 	db	; 8
octave		db	; 9
algo		db	; 10
freqOffs	dw	; 11
freqOffsLatch 	dw	; 13
volume		db	; 15
vMac		db	; 16
vMacPtr		dw	; 17
vMacPos		db	; 19
enMac		db	; 20
enMacPtr	dw	; 21
enMacPos	db	; 23
en2Mac		db	; 24
en2MacPtr	dw	; 25
en2MacPos	db	; 27
epMac		db	; 28
epMacPtr	dw	; 29
epMacPos	db	; 31
loop1		db	; 32
loop2		db	; 33
loopPtr		dw	; 34
cbEvnote	dw	; 36
oct8		db	; 38
operator	db	; 39
reg30_1		db	; 40
reg30_2		db	; 41
reg30_3		db	; 42
reg30_4		db	; 43
reg40_1		db	; 44
reg40_2		db	; 45
reg40_3		db	; 46
reg40_4		db	; 47
reg50_1		db	; 48
reg50_2		db	; 49
reg50_3		db	; 50
reg50_4		db	; 51
reg60_1		db	; 52
reg60_2		db	; 53
reg60_3		db	; 54
reg60_4		db	; 55
reg70_1		db	; 56
reg70_2		db	; 57
reg70_3		db	; 58
reg70_4		db	; 59
reg80_1		db	; 60
reg80_2		db	; 61
reg80_3		db	; 62
reg80_4		db	; 63
reg90_1		db	; 64
reg90_2		db	; 65
reg90_3		db	; 66
reg90_4		db	; 67
alMac		db	; 68
alMacPtr	dw	; 69
alMacPos	db	; 71
fbMac		db	; 72
fbMacPtr	dw	; 73
fbMacPos	db	; 75
returnAddr	dw	; 76
oldPos		dw	; 78
delayLatch	dw	; 80
delayLatch2	db	; 82
tl0		db	; 83
tl1		db	; 84
tl2		db	; 85
tl3		db	; 86
transpose	db	; 87
.ENDST


.ENUM XPMP_RAM_START EXPORT
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
xpmp_tempv	dw
xpmp_tempw	dw
.ENDE


.MACRO INC_DATAPOS
	.IF \1 == 1
	inc	(ix+_CHN_DATAPOS)
	jr	nz,+
	inc	(ix+_CHN_DATAPOS+1)
	+:
	.ELSE
	ld	e,(ix+_CHN_DATAPOS)
	ld	d,(ix+_CHN_DATAPOS+1)
	.rept \1
	inc	de
	.endr
	ld	(ix+_CHN_DATAPOS),e
	ld	(ix+_CHN_DATAPOS+1),d
	.ENDIF
.ENDM


.MACRO RESET_EFFECT
	ld	a,(ix+\1)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_\2_reset_\3_mac		; Reset effects as needed..
	jr	xpmp_\2_\3_reset
	+:
	call	xpmp_\2_step_\3
	xpmp_\2_\3_reset:	
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


.MACRO INIT_CHANNEL
	ld	a,(hl)
	or	$80				; Set bit 7 to access the 32k bank in M68000 memory
	ld	(xpmp_channel\1.dataPtr+1),a	; Convert from BE to LE
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.dataPtr),a
	inc	hl
	ld	de,xpmp_channel\1.loop1-1
	ld	(xpmp_channel\1.loopPtr),de
.ENDM


.bank 0 
.orga $0000

; Execution starts here when the Z80 is reset. Disable interrupts, set interrupt mode 1 and
; jump to the initialization code.
di
im	1
jp	start


; This code gets called when a VBlank IRQ occurs. Just re-enable interrupts and return.
.org $0038
	ei
	reti


start:
	ld	sp,$1FFE

	ld	hl,(xpmp_song_tbl)	; The song pointer table has been copied to $1E00 by the 68k
	ld	a,($1F00)		; The song number has been stored at $1F00 by the 68k
	call 	xpmp_init

	; Enable interrupts, then enter a loop where we wait for an interrupt (the Z80 only gets
	; VBlank interrupts), call the player update routine and repeat.
	ei
	forever:
		halt
		call	xpmp_update
		jp 	forever

	
	
; Initialize the music player
; HL = pointer to song table, A = song number
xpmp_init:
	ld	b,0
	dec	a
	ld	c,a
	sla	c
	add	a,a
	add	a,a
	add	a,a
	add	a,c
	add	a,a
	ld	c,a		; BC = (song-1) * 20
	add	hl,bc
	
	ld	(xpmp_tempw),hl
	
	; Set the 9 memory bank bits
	ld	hl,($1F01)
	ld	d,8
	set_bank:
		ld	a,0
		rrc	l
		adc	a,0
		ld	($6000),a
		dec	d
		jr	nz,set_bank
	ld	a,0
	rrc	h
	adc	a,0
	ld	($6000),a
		
	; Initialize all the player variables to zero
	ld 	hl,XPMP_RAM_START
	ld 	e,0
	ld 	bc,xpmp_freqChange-XPMP_RAM_START
	xpmp_init_zero:
		ld 	(hl),e
		inc 	hl
		dec 	bc
		ld	a,c
		or	b
		jr 	nz,xpmp_init_zero
	
	ld	hl,(xpmp_tempw)
	
	INIT_CHANNEL 0
	INIT_CHANNEL 1
	INIT_CHANNEL 2
	INIT_CHANNEL 3
	INIT_CHANNEL 4
	INIT_CHANNEL 5
	INIT_CHANNEL 6
	INIT_CHANNEL 7
	INIT_CHANNEL 8
	INIT_CHANNEL 9
	
	; Initialize the delays for all channels to 1
	ld 	a,1
	ld	(xpmp_channel0.delay+1),a
	ld	(xpmp_channel1.delay+1),a
	ld	(xpmp_channel2.delay+1),a
	ld	(xpmp_channel3.delay+1),a
	ld	(xpmp_channel4.delay+1),a
	ld	(xpmp_channel5.delay+1),a
	ld	(xpmp_channel6.delay+1),a
	ld	(xpmp_channel7.delay+1),a
	ld	(xpmp_channel8.delay+1),a
	ld	(xpmp_channel9.delay+1),a
	
	; Channel 3 should generate white noise by default
	ld	a,4
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld	(xpmp_channel3.duty),a
	.ENDIF

	; Turn off DAC, LFO
	ld	b,0
	ld	a,$22
	call	write_fm_low
	ld	a,$27
	call	write_fm_low
	ld	a,$2B
	call	write_fm_low
	ld	a,$90
	call	write_fm_low

	ld	a,$B4
	ld	b,$C0
	call	write_fm_low
	ld	a,$B5
	ld	b,$C0
	call	write_fm_low
	ld	a,$B6
	ld	b,$C0
	call	write_fm_low
	ld	a,$B4
	ld	b,$C0
	call	write_fm_hi
	ld	a,$B5
	ld	b,$C0
	call	write_fm_hi
	ld	a,$B6
	ld	b,$C0
	call	write_fm_hi
	
	; Set TL for all FM channels to min
	ld	ix,XPMP_FM_BUF+1
	ld	(ix+0),$40
	ld	(ix+1),127
	ld	(ix+2),$44
	ld	(ix+3),127
	ld	(ix+4),$48
	ld	(ix+5),127
	ld	(ix+6),$4C
	ld	(ix+7),127
	ld	a,0
	ld	(xpmp_chsel),a
	ld	a,4
	ld	(XPMP_FM_BUF),a
	call	write_fm_buf
	ld	a,1
	ld	(xpmp_chsel),a
	ld	a,4
	ld	(XPMP_FM_BUF),a
	call	write_fm_buf
	ld	a,2
	ld	(xpmp_chsel),a
	ld	a,4
	ld	(XPMP_FM_BUF),a
	call	write_fm_buf
	ld	a,4
	ld	(xpmp_chsel),a
	ld	a,4
	ld	(XPMP_FM_BUF),a
	call	write_fm_buf
	ld	a,5
	ld	(xpmp_chsel),a
	ld	a,4
	ld	(XPMP_FM_BUF),a
	call	write_fm_buf
	ld	a,6
	ld	(xpmp_chsel),a
	ld	a,4
	ld	(XPMP_FM_BUF),a
	call	write_fm_buf
	
	ret


;************************************************************
;                   YM2612 code
;************************************************************

; Writes to part 1 (the first 3 channels) of the YM2612
write_fm_low:
	ld	iy,$4000
-:
	bit	7,(iy+0)	; Wait until the YM2612 is ready
	jr	nz,-
	ld	($4000),a	; Select register
	ld	a,b
	ld	($4001),a	; Write data
	ret


; Writes to part 2 (the last 3 channels) of the YM2612
write_fm_hi:
	ld	iy,$4000
-:
	bit	7,(iy+0)	; Wait until the YM2612 is ready
	jr	nz,-
	ld	($4002),a	
	ld	a,b
	ld	($4003),a
	ret


; Writes to any YM2612 channel (determined by xpmp_chsel).
write_fm:
	push	af
	ld	a,(xpmp_chsel)
	cp	3
	jr	nc,+
	ld	c,a
	pop	af
	or	c
	call	write_fm_low
	ret
+:
	sub	4
	ld	c,a
	pop	af
	or	c
	call	write_fm_hi
	ret


; Writes all commands in the FM command buffer to the YM2612
write_fm_buf:
	ld	a,(xpmp_chsel)
	cp	3
	jr	nc,+
	ld	c,a
	ld	a,(XPMP_FM_BUF)
	ld	b,a

	ld	a,0
	ld	(XPMP_FM_BUF),a
	ld	hl,$4000
	ld	de,XPMP_FM_BUF+1

	wfb_lo_loop:
	ld	a,b
	cp	0
	ret	z
	-:
	bit	7,(hl)
	jr	nz,-
	ld	a,(de)		; Load register selection
	or	c		; OR in the channel bits
	inc	de
	ld	(hl),a		; Select register
	ld	a,(de)
	ld	($4001),a	; Write data
	inc	de
	dec	b
	jp	wfb_lo_loop
+:
	sub	4
	ld	c,a
	ld	a,(XPMP_FM_BUF)
	ld	b,a
	ld	a,0
	ld	(XPMP_FM_BUF),a
	ld	hl,$4002
	ld	de,XPMP_FM_BUF+1
	wfb_hi_loop:
	ld	a,b
	cp	0
	ret	z
	-:
	bit	7,(hl)
	jr	nz,-
	ld	a,(de)
	or	c
	inc	de
	ld	(hl),a
	ld	a,(de)
	ld	($4003),a
	inc	de
	dec	b
	jp	wfb_hi_loop


; Note / rest
xpmp_fm_cmd_00:
xpmp_fm_cmd_60:
	ld	hl,(xpmp_tempw)

	ld	a,c
	cp	CMD_VOLUP
	jr	nz,xpmp_fm_cmd_00_2

	INC_DATAPOS 1
	inc	hl
	ld	b,(hl)				; Get increment
	ld	(ix+16),0			; Turn off volume macro
xpmp_fm_cmd_00_volinc:
	ld	a,1
	ld	(xpmp_volChange),a
	ld 	a,(ix+_FM_OPER)
	cp 	0
	jr 	z,+
	xpmp_fm_cmd_00_volinc_spec:
	ld 	(xpmp_tempv),ix
	ld 	hl,(xpmp_tempv)
	add 	a,_FM_TL-1
	ld 	e,a
	ld 	d,0
	add 	hl,de
	ld	a,b
	add 	a,(hl)
	ld	(hl),a
	ret
	+:
	ld a,1
	call xpmp_fm_cmd_00_volinc_spec
	ld a,2
	call xpmp_fm_cmd_00_volinc_spec
	ld a,3
	call xpmp_fm_cmd_00_volinc_spec
	ld a,4
	call xpmp_fm_cmd_00_volinc_spec
	ret
	
xpmp_fm_cmd_00_2:
	ld	a,(ix+_CHN_NOTE)
	ld	(xpmp_lastNote),a		; Save the previous note
	ld	a,c
	and	$0F
	ld	(ix+_CHN_NOTE),a
	ld	a,c
	and	$F0
	cp	CMD_NOTE2
	jr	z,xpmp_fm_cmd_00_std_delay
	INC_DATAPOS 2
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_fm_cmd_00_short_note
		inc	de
		ld	(ix+_CHN_DATAPOS),e
		ld	(ix+_CHN_DATAPOS+1),d
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
		ld	a,(ix+_CHN_DELAY)	
		add	a,(hl)
		ld	(ix+_CHN_DELAY),a	; Fractional part
		ld	hl,0 
		adc	hl,de
		ld	(ix+_CHN_DELAY+1),l	; Whole part
		ld	(ix+_CHN_DELAY+2),h
		jp 	xpmp_fm_cmd_00_got_delay
	xpmp_fm_cmd_00_short_note:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(ix+_CHN_DELAY)	
	add	a,(hl)
	ld	(ix+_CHN_DELAY),a		; Fractional part
	ld	hl,0 
	adc	hl,de
	ret	z
	ld	(ix+_CHN_DELAY+1),l		; Whole part
	ld	(ix+_CHN_DELAY+2),h
	jp 	xpmp_fm_cmd_00_got_delay
	xpmp_fm_cmd_00_std_delay:
	ld	a,(ix+80)
	ld	b,a
	ld	a,(ix+_CHN_DELAY)
	add	a,b
	ld	(ix+_CHN_DELAY),a
	ld 	l,(ix+81)
	ld	h,(ix+82)
	ld	de,0
	adc	hl,de
	ret	z
	ld	(ix+5),l
	ld	(ix+6),h
	xpmp_fm_cmd_00_got_delay:
	ld	a,2
	ld	(xpmp_freqChange),a
	ld	a,(ix+_CHN_NOTE)
	cp	CMD_REST	
	ret	z				; If this was a rest command we can return now
	cp	CMD_REST2
	ret	z

	.IFNDEF XPMP_VMAC_NOT_USED
	RESET_EFFECT _FM_VMAC,fm,v
	.ENDIF

	.IFNDEF XPMP_ENMAC_NOT_USED
	RESET_EFFECT 20,fm,en
	.ENDIF

	.IFNDEF XPMP_EN2MAC_NOT_USED
	RESET_EFFECT 24,fm,en2
	.ENDIF

	.IFNDEF XPMP_EPMAC_NOT_USED
	RESET_EFFECT 28,fm,ep
	.ENDIF

	RESET_EFFECT 68,fm,al

	RESET_EFFECT 72,fm,fb

	;ld	hl,(xpmp_channel\1.cbEvnote)
	;ld	a,h
	;or	l
	;ret	z
	;jp	(hl)		
	ret


; Set octave
xpmp_fm_cmd_10:
	ld	a,c 
	and	$0F
	dec	a				; Minimum octave is 1
	ld	b,a
	add	a,a
	add	a,a
	add	a,a
	sla	b
	sla	b
	ld	(ix+_FM_OCT8),a			; A = (C & $0F) * 8
	add	a,b				; A = (C & $0F) * 12
	ld	(ix+_CHN_OCTAVE),a
	ret

; Set algorithm	
xpmp_fm_cmd_20:
	ld	a,c
	and	7
	ld	b,a
	ld	a,(ix+10)
	and	$38
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$B0
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ld	a,0
	ld	(ix+68),a		; Disable algorithm macro
	ret

; Set volume (short)
xpmp_fm_cmd_30:
	ret

; Octave up + note	
xpmp_fm_cmd_40:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+_CHN_OCTAVE)
	add	a,12
	ld	(ix+_CHN_OCTAVE),a
	ld	a,(ix+_FM_OCT8)
	add	a,8
	ld	(ix+_FM_OCT8),a
	ld 	a,c
	add 	a,$20
	ld	c,a
	jp	xpmp_fm_cmd_00_2

; Octave down + note
xpmp_fm_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+_CHN_OCTAVE)
	sub	12
	ld	(ix+_CHN_OCTAVE),a
	ld	a,(ix+_FM_OCT8)
	sub	8
	ld	(ix+_FM_OCT8),a
	ld 	a,c
	add 	a,$10
	ld 	c,a
	jp	xpmp_fm_cmd_00_2

;xpmp_fm_cmd_60:
xpmp_fm_cmd_70:
xpmp_fm_cmd_80:
	ret

; Turn off arpeggio macro
xpmp_fm_cmd_90:
	ld	hl,(xpmp_tempw)
	ld	a,c
	cp	CMD_ARPOFF
	jr	z,xpmp_fm_cmd_90_90
	cp	CMD_FBKMAC
	jr	z,xpmp_fm_cmd_90_91
	cp	CMD_JSR
	jp	z,xpmp_fm_cmd_90_jsr
	cp	CMD_RTS
	jr	z,xpmp_fm_cmd_90_rts
	cp	CMD_LEN
	jp	z,xpmp_fm_cmd_90_len
	cp	CMD_WRMEM
	jp	z,xpmp_fm_cmd_90_wrmem
	cp	CMD_WRPORT
	jp	z,xpmp_fm_cmd_90_wrport
	cp	CMD_TRANSP
	jp	z,xpmp_fm_cmd_90_transp
	ret
	
	xpmp_fm_cmd_90_90:
	ld	a,0
	ld	(ix+20),a
	ld	(ix+24),a
	ld	(ix+_CHN_NOTEOFFS),a
	ret

	xpmp_fm_cmd_90_91:
	inc	(ix+_CHN_DATAPOS)
	jr	nz,+
	inc	(ix+_CHN_DATAPOS+1)
	+:
	inc	hl
	ld	(ix+75),1
	ld	a,(hl)
	ld	(ix+72),a
	ret
	xpmp_fm_reset_fb_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,(xpmp_FB_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+74),a
	inc	hl
	ld	a,(hl)
	ld	(ix+73),a
	ld	l,(ix+73)
	ld	h,(ix+74)
	ld	b,(hl)
	ld	a,(ix+10)
	and	7
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$B0
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ld	(ix+75),1
	ret

	; Return from pattern
	xpmp_fm_cmd_90_rts:
	ld	a,(ix+76)
	ld	(ix+_CHN_DATAPTR),a
	ld	a,(ix+77)
	ld	(ix+_CHN_DATAPTR+1),a
	ld	a,(ix+78)
	ld	(ix+_CHN_DATAPOS),a
	ld	a,(ix+79)
	ld	(ix+_CHN_DATAPOS+1),a
	ret
	
	; Jump to pattern
	xpmp_fm_cmd_90_jsr:
	ld	e,(ix+_CHN_DATAPOS)
	ld	d,(ix+_CHN_DATAPOS+1)
	inc	de
	ld	(ix+78),e
	ld	(ix+79),d
	ld	a,(ix+_CHN_DATAPTR)
	ld	(ix+76),a
	ld	a,(ix+_CHN_DATAPTR+1)
	ld	(ix+77),a
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	a,(hl)
	ld	de,(xpmp_pattern_tbl)
	ld	h,0
	add	a,a
	ld	l,a
	add	hl,de
	ld	a,(hl)
	or	$80
	inc	hl
	ld	d,(hl)
	ld	(ix+_CHN_DATAPTR),d
	ld	(ix+_CHN_DATAPTR+1),a
	ld	(ix+_CHN_DATAPOS),$FF
	ld	(ix+_CHN_DATAPOS+1),$FF
	ret
	
	xpmp_fm_cmd_90_len:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 2
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_fm_cmd_90_short_delay
		inc	de
		ld	(ix+_CHN_DATAPOS),e
		ld	(ix+_CHN_DATAPOS+1),d
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
		ld	(ix+80),a	; Fractional part
		ld	(ix+81),e	; Whole part
		ld	(ix+82),d	; ...
		ret
	xpmp_fm_cmd_90_short_delay:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(hl)
	ld	(ix+80),a	; Fractional part
	ld	(ix+81),e	; Whole part
	ld	(ix+82),d
	ret

	xpmp_fm_cmd_90_wrmem:
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)
	ld	(de),a
	-:
	INC_DATAPOS 3
	ret
	xpmp_fm_cmd_90_wrport:
	jr	-		; No ports on this system

	xpmp_fm_cmd_90_transp:
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	a,(hl)
	ld	(ix+_FM_TRANSP),a
	INC_DATAPOS 1
	ret		

; Set mode
xpmp_fm_cmd_A0:
	ret

; Set feedback	
xpmp_fm_cmd_B0:
	ld	a,c
	and	7
	add	a,a
	add	a,a
	add	a,a
	ld	b,a
	ld	a,(ix+10)
	and	7
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$B0
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ld	a,0
	ld	(ix+72),a
	ret

; Set operator	
xpmp_fm_cmd_C0:
	ld	a,c
	and	7
	ld	(ix+_FM_OPER),a
	ret

; Set rate scaling
xpmp_fm_cmd_D0:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 1
	inc	hl
	ld	a,(ix+_FM_OPER)
	cp	0
	jr	z,xpmp_fm_cmd_D0_all
	ld	a,(hl)
	and	3
	rrca
	rrca
	ld	c,a
	ld	(xpmp_tempw),ix
	ld	hl,(xpmp_tempw)
	ld	a,(ix+_FM_OPER)
	add	a,47
	ld	e,a
	ld	d,0
	add	hl,de
	ld	a,(hl)
	and	$1F
	or	c
	ld	(hl),a
	ld	(iy+1),a

	ld	a,(ix+39)
	add	a,a
	add	a,a
	add	a,$4C
	ld	(iy+0),a
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ret
	xpmp_fm_cmd_D0_all:
	ld	a,(hl)
	and	3
	rrca
	rrca
	ld	d,a
	ld	a,(ix+48)
	and	$1F
	or	d
	ld	(ix+48),a
	ld	(iy+1),a
	ld	(iy+0),$50
	ld	a,(ix+49)
	and	$1F
	or	d
	ld	(ix+49),a
	ld	(iy+3),a
	ld	(iy+2),$54
	ld	a,(ix+50)
	and	$1F
	or	d
	ld	(ix+50),a
	ld	(iy+5),a
	ld	(iy+4),$58
	ld	a,(ix+51)
	and	$1F
	or	d
	ld	(ix+51),a
	ld	(iy+7),a
	ld	(iy+6),$5C
	ld	hl,XPMP_FM_BUF
	ld	a,4

	add	a,(hl)
	ld	(hl),a
	ld	de,8
	add	iy,de
	ret

xpmp_fm_cmd_E0:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 1
	ld	a,c
	cp	CMD_ADSR
	jr	z,xpmp_fm_cmd_E0_adsr
	cp	CMD_DETUNE
	jp	z,xpmp_fm_cmd_E0_detune
	cp	CMD_MULT
	jp	z,xpmp_fm_cmd_E0_mult
	cp	CMD_HWAM
	jp	z,xpmp_fm_cmd_E0_am
	cp	CMD_MODMAC
	jp	z,xpmp_fm_cmd_E0_mod
	ret

xpmp_fm_cmd_E0_adsr:
	inc	hl
	ld	a,(hl)
	dec	a
	add	a,a
	ld	hl,(xpmp_ADSR_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	d,a
	inc	hl
	ld	e,(hl)
	ex	de,hl
	
	ld	a,(ix+_FM_OPER)
	cp	0
	jr	z,xpmp_fm_adsr_all
	xpmp_fm_adsr_spec:
	dec	a
	add	a,48
	ld	c,a
	sub	48
	add	a,a
	add	a,a
	add	a,$50
	ld	(iy+0),a
	add	a,$10
	ld	(iy+2),a
	add	a,$10
	ld	(iy+4),a
	add	a,$10
	ld	(iy+6),a
	ex	de,hl
	ld	(xpmp_tempw),ix
	ld	hl,(xpmp_tempw)
	ld	b,0
	add	hl,bc
	ex	de,hl
	ld	a,(de)
	and	$C0
	or	(hl)
	ld	(de),a
	inc	de
	inc	de
	inc	de
	inc	de
	inc	hl
	ld	(iy+1),a
	ld	a,(de)
	and	$80
	or	(hl)
	ld	(de),a
	inc	de
	inc	de
	inc	de
	inc	de
	inc	hl
	ld	(iy+3),a
	;ld	a,(de)
	ld	a,(hl)
	ld	(de),a
	inc	de
	inc	de
	inc	de
	inc	de
	inc	hl
	ld	(iy+5),a
	ld	a,(hl)
	ld	(de),a
	;inc	de
	;inc	hl
	ld	(iy+7),a
	ld	hl,XPMP_FM_BUF
	ld	a,4
	add	a,(hl)
	ld	(hl),a
	ld	de,8
	add	iy,de	
	ret
	xpmp_fm_adsr_all:
	ld	(xpmp_tempv),hl
	ld	a,1
	call	xpmp_fm_adsr_spec
	ld	hl,(xpmp_tempv)	
	ld	a,2
	call	xpmp_fm_adsr_spec
	ld	hl,(xpmp_tempv)	
	ld	a,3
	call	xpmp_fm_adsr_spec
	ld	hl,(xpmp_tempv)	
	ld	a,4
	call	xpmp_fm_adsr_spec
	ret

xpmp_fm_cmd_E0_mult:
	inc	hl
	ld	a,(ix+_FM_OPER)
	cp	0
	jr	z,xpmp_fm_mult_all
	ld	a,(hl)
	and	15
	ld	c,a
	ld	(xpmp_tempw),ix
	ld	hl,(xpmp_tempw)
	ld	a,(ix+_FM_OPER)
	add	a,39
	ld	e,a
	ld	d,0
	add	hl,de
	ld	a,(hl)
	and	$70
	or	c
	ld	(hl),a
	ld	(iy+1),a
	ld	a,(ix+_FM_OPER)
	add	a,a
	add	a,a
	add	a,$2C
	ld	(iy+0),a
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ret
	xpmp_fm_mult_all:
	ld	a,(hl)
	and	15
	ld	d,a
	ld	a,(ix+_FM_REG3X)
	and	$70
	or	d
	ld	(ix+_FM_REG3X),a
	ld	(iy+1),a
	ld	(iy+0),$30
	ld	a,(ix+_FM_REG3X+1)
	and	$70
	or	d
	ld	(ix+_FM_REG3X+1),a
	ld	(iy+3),a
	ld	(iy+2),$34
	ld	a,(ix+_FM_REG3X+2)
	and	$70
	or	d
	ld	(ix+_FM_REG3X+2),a
	ld	(iy+5),a
	ld	(iy+4),$38
	ld	a,(ix+_FM_REG3X+3)
	and	$70
	or	d
	ld	(ix+_FM_REG3X+3),a
	ld	(iy+7),a
	ld	(iy+6),$3C
	ld	hl,XPMP_FM_BUF
	ld	a,4
	add	a,(hl)
	ld	(hl),a
	ld	de,8
	add	iy,de
	ret

xpmp_fm_cmd_E0_detune:
	inc	hl
	ld	a,(ix+_FM_OPER)
	cp	0
	jr	z,xpmp_fm_detune_all
	ld	a,(hl)
	and	7
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	c,a
	ld	(xpmp_tempw),ix
	ld	hl,(xpmp_tempw)
	ld	a,(ix+_FM_OPER)
	add	a,39
	ld	e,a
	ld	d,0
	add	hl,de
	ld	a,(hl)
	and	$0F
	or	c
	ld	(hl),a
	ld	(iy+1),a
	ld	a,(ix+_FM_OPER)
	add	a,a
	add	a,a
	add	a,$2C
	ld	(iy+0),a
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ret
	xpmp_fm_detune_all:
	ld	a,(hl)
	and	7
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	d,a
	ld	a,(ix+_FM_REG3X)
	and	$0F
	or	d
	ld	(ix+_FM_REG3X),a
	ld	(iy+1),a
	ld	(iy+0),$30
	ld	a,(ix+_FM_REG3X+1)
	and	$0F
	or	d
	ld	(ix+_FM_REG3X+1),a
	ld	(iy+3),a
	ld	(iy+2),$34
	ld	a,(ix+_FM_REG3X+2)
	and	$0F
	or	d
	ld	(ix+_FM_REG3X+2),a
	ld	(iy+5),a
	ld	(iy+4),$38
	ld	a,(ix+_FM_REG3X+3)
	and	$0F
	or	d
	ld	(ix+_FM_REG3X+3),a
	ld	(iy+7),a
	ld	(iy+6),$3C
	ld	hl,XPMP_FM_BUF
	ld	a,4
	add	a,(hl)
	ld	(hl),a
	ld	de,8
	add	iy,de
	ret

xpmp_fm_cmd_E0_am:
	inc	hl
	ld	a,(hl)
	rrca
	ld	l,a
	;ex	de,hl
	
	ld	a,(ix+_FM_OPER)
	cp	0
	jr	z,xpmp_fm_am_all
	xpmp_fm_am_spec:
	dec	a
	add	a,52
	ld	c,a
	sub	52
	add	a,a
	add	a,a
	add	a,$60
	ld	(iy+0),a
	ex	de,hl
	ld	(xpmp_tempw),ix
	ld	hl,(xpmp_tempw)
	ld	b,0
	add	hl,bc
	ex	de,hl
	ld	a,(de)
	and	$1F
	or	l
	ld	(de),a
	ld	(iy+1),a
	ld	hl,XPMP_FM_BUF
	inc	(hl)

	inc	iy
	inc	iy
	;ld	a,1
	;add	a,(hl)
	;ld	(hl),a
	;ld	de,8
	;add	iy,de	
	ret
	xpmp_fm_am_all:
	ld	(xpmp_tempv),hl
	ld	a,1
	call	xpmp_fm_am_spec
	ld	hl,(xpmp_tempv)	
	ld	a,2
	call	xpmp_fm_am_spec
	ld	hl,(xpmp_tempv)	
	ld	a,3
	call	xpmp_fm_am_spec
	ld	hl,(xpmp_tempv)	
	ld	a,4
	call	xpmp_fm_am_spec
	ret
	
xpmp_fm_cmd_E0_mod:
	inc	hl
	ld	a,(hl)
	cp	EFFECT_DISABLED
	jr	z,xpmp_fm_cmd_E0_mod_disable
	dec	a
	add	a,a
	ld	hl,(xpmp_MOD_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	d,a
	inc	hl
	ld	e,(hl)
	ex	de,hl
	ld	a,(hl)
	add	a,8
	ld	b,a
	ld	a,$22
	push	iy
	call	write_fm_low
	pop	iy
	inc	hl
	ld	a,(hl)
	ld	(iy+0),$B4
	or	$C0
	ld	(iy+1),a
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ret	
	xpmp_fm_cmd_E0_mod_disable:
	ld	(iy+0),$22
	ld	(iy+1),0
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ret
	
xpmp_fm_cmd_F0:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 1
	ld	a,c
	cp	CMD_VOLSET
	jr	z,xpmp_fm_cmd_F0_volset
	cp	CMD_VOLMAC
	jr	z,xpmp_fm_cmd_F0_VOLMAC
	cp	CMD_SWPMAC
	jp	z,xpmp_fm_cmd_F0_SWPMAC
	cp	CMD_ARPMAC
	jp	z,xpmp_fm_cmd_F0_ARPMAC
	cp	CMD_APMAC2
	jp	z,xpmp_fm_cmd_F0_APMAC2
	cp	CMD_DUTMAC
	jp	z,xpmp_fm_cmd_F0_ALGMAC
	cp	CMD_LOPCNT
	jp	z,xpmp_fm_cmd_F0_LOPCNT
	cp	CMD_DJNZ
	jp	z,xpmp_fm_cmd_F0_DJNZ
	cp	CMD_JMP
	jp	z,xpmp_fm_cmd_F0_JMP
	cp	CMD_J1
	jp	z,xpmp_fm_cmd_F0_J1
	cp	CMD_END
	jr	z,xpmp_fm_cmd_F0_END
	ret

xpmp_fm_cmd_F0_volset:
	inc	hl
	ld	b,(hl)
	ld	a,0
	ld	(ix+_FM_VMAC),a			; Turn off volume macro
xpmp_fm_cmd_F0_volset_2:
	ld	a,1
	ld	(xpmp_volChange),a
	ld 	a,(ix+_FM_OPER)
	cp 	0
	jr 	z,+
	xpmp_fm_cmd_F0_volset_spec:
	ld 	(xpmp_tempv),ix
	ld 	hl,(xpmp_tempv)
	add 	a,_FM_TL-1
	ld 	e,a
	ld 	d,0
	add 	hl,de
	ld 	(hl),b
	ret
	+:
	ld 	a,1
	call 	xpmp_fm_cmd_F0_volset_spec
	ld 	a,2
	call 	xpmp_fm_cmd_F0_volset_spec
	ld 	a,3
	call 	xpmp_fm_cmd_F0_volset_spec
	ld 	a,4
	call 	xpmp_fm_cmd_F0_volset_spec
	ret

	xpmp_fm_cmd_F0_END:
	ld	a,CMD_END
	ld	(ix+_CHN_NOTE),a		; Playback of this channel should end
	ld	a,2
	ld	(xpmp_freqChange),a		; The command-reading loop should exit	
	ret
	
	xpmp_fm_cmd_F0_VOLMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+_FM_VMAC),a
	xpmp_fm_reset_v_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,(xpmp_v_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+18),a
	inc	hl
	ld	a,(hl)
	ld	(ix+17),a
	ld	l,(ix+17)
	ld	h,(ix+18)
	ld 	(ix+19),1 ; macro position
	ld 	b,(hl)
	jr xpmp_fm_cmd_F0_volset_2
	
	; Initialize sweep macro
	xpmp_fm_cmd_F0_SWPMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+28),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_fm_cmd_F0_disable_SWPMAC	
	xpmp_fm_reset_ep_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,(xpmp_EP_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+30),a
	inc	hl
	ld	a,(hl)
	ld	(ix+29),a
	ld	l,(ix+29)
	ld	h,(ix+30)
	ld	(ix+31),1
	ld	(ix+12),0
	ld	a,(hl)
	ld	(ix+11),a
	bit	7,a
	ret	z
	ld	(ix+12),$FF
	ret
	xpmp_fm_cmd_F0_disable_SWPMAC:
	ld	(ix+28),a
	ld	(ix+11),a
	ld	(ix+12),a
	ret
	
	; Jump
	xpmp_fm_cmd_F0_JMP:
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+_CHN_DATAPOS),e
	ld	(ix+_CHN_DATAPOS+1),d
	ret

	; Set loop count
	xpmp_fm_cmd_F0_LOPCNT:
	inc	hl
	ld	a,(hl)
	ld	l,(ix+_FM_LOOPPTR)
	ld	h,(ix+_FM_LOOPPTR+1)
	inc	hl
	ld	(hl),a
	ld	(ix+_FM_LOOPPTR),l
	ld	(ix+_FM_LOOPPTR+1),h
	ret

	; Jump if one
	xpmp_fm_cmd_F0_J1:
	ld	l,(ix+_FM_LOOPPTR)
	ld	h,(ix+_FM_LOOPPTR+1)
	ld	a,(hl)
	cp	1
	jr	nz,xpmp_fm_cmd_F0_J1_N1		; Check if the counter has reached 1
	dec	hl
	ld	(ix+_FM_LOOPPTR),l
	ld	(ix+_FM_LOOPPTR+1),h
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+_CHN_DATAPOS),e
	ld	(ix+_CHN_DATAPOS+1),d
	ret
	xpmp_fm_cmd_F0_J1_N1:
	INC_DATAPOS 1
	ret
	
	; Decrease and jump if not zero
	xpmp_fm_cmd_F0_DJNZ:
	ld	l,(ix+_FM_LOOPPTR)
	ld	h,(ix+_FM_LOOPPTR+1)
	dec	(hl)
	jr	z,xpmp_fm_cmd_F0_DJNZ_Z		; Check if the counter has reached zero
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+_CHN_DATAPOS),e
	ld	(ix+_CHN_DATAPOS+1),d
	ret
	xpmp_fm_cmd_F0_DJNZ_Z:
	dec	hl
	ld	(ix+_FM_LOOPPTR),l
	ld	(ix+_FM_LOOPPTR+1),h
	INC_DATAPOS 1
	ret

	xpmp_fm_cmd_F0_ALGMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+68),a
	xpmp_fm_reset_al_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,(xpmp_dt_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+70),a
	inc	hl
	ld	a,(hl)
	ld	(ix+69),a
	ld	l,(ix+69)
	ld	h,(ix+70)
	ld	b,(hl)
	ld	a,(ix+10)
	and	$38
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$B0
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ld	(ix+71),1
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_fm_cmd_F0_APMAC2:
	inc	hl
	ld	a,(hl)
	ld	(ix+24),a
	xpmp_fm_reset_en2_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,(xpmp_EN_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+26),a
	inc	hl
	ld	a,(hl)
	ld	(ix+25),a
	ld	l,(ix+25)
	ld	h,(ix+26)
	ld	a,(hl)
	ld	(ix+8),a
	ld	a,1
	ld	(ix+27),a
	dec	a
	ld	(ix+20),a
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_fm_cmd_F0_ARPMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+20),a
	xpmp_fm_reset_en_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,(xpmp_EN_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+22),a
	inc	hl
	ld	a,(hl)
	ld	(ix+21),a
	ld	l,(ix+21)
	ld	h,(ix+22)
	ld	a,(hl)
	ld	(ix+8),a
	ld	a,1
	ld	(ix+23),a
	dec	a
	ld	(ix+24),a
	ret
	
	
; Update FM channel
xpmp_update_fm:
	ld	(xpmp_chnum),a
	add	a,a
	ld	e,a
	ld	a,(xpmp_chsel)

	bit	2,a
	jr	z,+
	ld	a,e
	add	a,6
	ld	e,a
	+:
	ld	d,0
	ld	hl,xpmp_fm_channel_ptr_tbl
	add	hl,de
	ld	a,(hl)
	ld	(xpmp_tempw),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_tempw+1),a
	ld	ix,(xpmp_tempw)
	
	ld	a,0
	ld	(XPMP_FM_BUF),a
	ld	iy,XPMP_FM_BUF+1
	
	ld	a,0
	ld	(xpmp_freqChange),a
	ld	(xpmp_volChange),a
	
	ld	a,(ix+_CHN_NOTE)
	cp	CMD_END
	ret	z				; Playback has ended for this channel - all processing should be skipped
	
	ld 	l,(ix+_CHN_DELAY+1)		; Decrement the whole part of the delay and check if it has reached zero
	ld	h,(ix+_CHN_DELAY+2)
	dec	hl
	ld	a,h
	or	l
	jp 	nz,xpmp_update_fm_effects	
	
	; Loop here until a note/rest or END command is read (signaled by xpmp_freqChange == 2)
	xpmp_update_fm_read_cmd:
	ld	l,(ix+_CHN_DATAPTR)
	ld	h,(ix+_CHN_DATAPTR+1)
	ld	e,(ix+_CHN_DATAPOS)
	ld	d,(ix+_CHN_DATAPOS+1)
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
	ld	de,xpmp_fm_jump_tbl	
	add	hl,de
	ld	e,(hl)				; HL = jump_tbl + (command >> 4)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	call	xpmp_call_hl

	INC_DATAPOS 1
	
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,xpmp_update_fm_freq_change
	jp 	xpmp_update_fm_read_cmd
	
	xpmp_update_fm_freq_change:
	call	write_fm_buf
	ld	a,(ix+_CHN_NOTE)
	cp	CMD_REST
	jp	z,xpmp_update_fm_rest
	cp	CMD_REST2
	ret	z
	cp	CMD_END
	jp	z,xpmp_update_fm_rest
	ld	c,a
	
	ld	a,(xpmp_freqChange)
	cp	2
	jr	nz,+
	ld	a,(xpmp_chsel)
	ld	b,a
	ld	a,$28
	call	write_fm_low	; KEY_OFF
	+:
	
	ld	a,(ix+_CHN_NOTEOFFS)
	ld	d,(ix+_FM_TRANSP)
	add	a,d
	add	a,c		; note + noteOffs + transpose
	ld	b,a
	ld	a,(ix+_CHN_OCTAVE)
	add	a,b
	bit	7,a		; negative?
	jr	z,fm_note_lb_ok
	ld	a,0
	jr	fm_note_ok
	fm_note_lb_ok:
	cp	96
	jr	c,fm_note_ok
	ld	a,95
	fm_note_ok:
	
	fm_note_mod_12:
	cp	12
	jr	c,+
	sub	12
	jr	fm_note_mod_12
	+:
	
	ld	hl,xpmp_fm_freq_tbl
	ld	d,0
	add	a,a
	ld	e,a
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	a,(hl)
	or	(ix+38)
	ld	b,a
	ld	a,$A4
	call	write_fm
	ld	a,$A0
	ld	b,e
	call	write_fm
	
	ld	a,(xpmp_chsel)
	or	$F0
	ld	b,a
	ld	a,$28
	call	write_fm_low	; KEY_ON
	
	ld	a,(xpmp_lastNote)
	cp	CMD_REST
	jr	nz,xpmp_update_fm_set_vol2
	jp	xpmp_update_fm_set_vol3

	xpmp_update_fm_set_vol:
	ld	a,(ix+7)
	cp	CMD_REST
	jr	z,xpmp_update_fm_rest
	xpmp_update_fm_set_vol2:
	; Update the volume if it has changed
	call	write_fm_buf
	ld	a,(xpmp_volChange)
	cp	0
	ret	z
	xpmp_update_fm_set_vol3:
	ld	a,(ix+_FM_TL)
	xor	127
	ld	b,a
	ld	a,$40
	call	write_fm

	ld	a,(ix+_FM_TL+1)
	xor	127
	ld	b,a
	ld	a,$44
	call	write_fm

	ld	a,(ix+_FM_TL+2)
	xor	127
	ld	b,a
	ld	a,$48
	call	write_fm
	
	ld	a,(ix+_FM_TL+3)
	xor	127
	ld	b,a
	ld	a,$4C
	call	write_fm
	xpmp_update_fm_no_vol_change:
	ret
	
	; Mute the channel
	xpmp_update_fm_rest:
	call	write_fm_buf
	ld	a,(xpmp_chsel)
	ld	b,a
	ld	a,$28
	call	write_fm_low
	ret

	xpmp_update_fm_effects:
	ld 	(ix+_CHN_DELAY+1),l
	ld	(ix+_CHN_DELAY+2),h

	call	xpmp_fm_step_v_frame
	call	xpmp_fm_step_en_frame
	call	xpmp_fm_step_en2_frame
	call	xpmp_fm_step_al_frame
	call	xpmp_fm_step_fb_frame
	call	xpmp_fm_step_ep_frame
	
	ld	a,(xpmp_freqChange)
	cp	0
	jp	nz,xpmp_update_fm_freq_change
	jp	xpmp_update_fm_set_vol
	ret	


	xpmp_fm_step_v_frame:
	bit 	7,(ix+_FM_VMAC)
	ret	nz
	xpmp_fm_step_v:	
	.IFNDEF XPMP_VMAC_NOT_USED
	; Volume macro
	ld 	a,(ix+_FM_VMAC)
	cp 	EFFECT_DISABLED
	jr 	z,xpmp_update_fm_v_done 
	xpmp_update_fm_v:
	ld 	l,(ix+17)
	ld	h,(ix+18)
	ld	a,1
	ld	(xpmp_volChange),a
	ld 	d,0
	ld 	a,(ix+19)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_fm_v_loop
	ld 	b,a
	inc	de				; Increase the position
	ld	a,e
	ld	(ix+19),a
	call 	xpmp_fm_cmd_F0_volset_2
	jp	xpmp_update_fm_v_done
	xpmp_update_fm_v_loop:
	ld	a,(ix+_FM_VMAC)			; Which volume macro are we using?
	and	$7F
	dec	a
	ld	e,a
	sla	e				; Each pointer is two bytes
	ld	bc,(xpmp_v_mac_loop_tbl)
	ld	hl,(xpmp_vMacPtr)
	ex	de,hl
	inc	de
	add	hl,bc 				; HL = xpmp_vMac_loop_tbl + (vMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80

	ld	(de),a				; Store in xpmp_\1_vMac_ptr
	dec 	de	
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(ix+19),a
	ld	l,(ix+17)
	ld	h,(ix+18)
	ld 	b,(hl)
	call 	xpmp_fm_cmd_F0_volset_2
	xpmp_update_fm_v_done:
	.ENDIF
	ret
	
	xpmp_fm_step_en_frame:
	bit 	7,(ix+20)
	ret	nz
	xpmp_fm_step_en:		
	.IFNDEF XPMP_ENMAC_NOT_USED
	; Cumulative arpeggio
	ld 	a,(ix+20)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_fm_EN_done
	xpmp_update_fm_EN:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	l,(ix+21)
	ld	h,(ix+22)
	ld 	d,0
	ld 	e,(ix+23)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_fm_EN_loop
	ld	b,a
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+23),a
	jp	xpmp_update_fm_EN_done		
	xpmp_update_fm_EN_loop:
	ld	a,(ix+20)			; Which arpeggio macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,(xpmp_enMacPtr)
	ld	bc,(xpmp_EN_mac_loop_tbl)
	ex	de,hl
	inc	de
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80
	ld	(de),a
	dec 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	(ix+23),1			; Reset position
	ld	l,(ix+21)
	ld	h,(ix+22)
	ld	b,(hl)
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Reset note offset
	xpmp_update_fm_EN_done:
	.ENDIF
	ret

	xpmp_fm_step_en2_frame:
	bit 	7,(ix+24)
	ret	nz
	xpmp_fm_step_en2:		
	.IFNDEF XPMP_EN2MAC_NOT_USED
	; Non-cumulative arpeggio
	ld 	a,(ix+24)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_fm_EN2_done
	xpmp_update_fm_EN2:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	l,(ix+25)
	ld	h,(ix+26)
	ld 	d,0
	ld 	e,(ix+27)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_fm_EN2_loop
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+27),a
	jp	xpmp_update_fm_EN2_done		
	xpmp_update_fm_EN2_loop:
	ld	a,(ix+24)			; Which arpeggio macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,(xpmp_en2MacPtr)
	ld	bc,(xpmp_EN_mac_loop_tbl)
	ex	de,hl
	inc	de
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (en2Mac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80
	ld	(de),a
	dec 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	(ix+27),1			; Reset position
	ld	l,(ix+25)
	ld	h,(ix+26)
	ld	a,(hl)
	ld	(ix+8),a			; Reset note offset
	xpmp_update_fm_EN2_done:
	.ENDIF
	ret
	
	xpmp_fm_step_al_frame:
	bit 	7,(ix+68)
	ret	nz
	xpmp_fm_step_al:	
	ld 	a,(ix+68)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_fm_al_done
	xpmp_update_fm_al:
	ld	l,(ix+69)
	ld	h,(ix+70)
	ld 	d,0
	ld 	e,(ix+71)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_fm_al_loop
	ld	b,a
	ld	a,(ix+10)
	and	$38
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$B0
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)	
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+71),a
	jp	xpmp_update_fm_al_done		
	xpmp_update_fm_al_loop:
	ld	a,(ix+68)			; Which algorithm macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,(xpmp_alMacPtr)
	ld	bc,(xpmp_dt_mac_loop_tbl)
	ex	de,hl
	inc	de
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80
	ld	(de),a
	dec 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	(ix+71),1			; Reset position
	ld	l,(ix+69)
	ld	h,(ix+70)
	ld	b,(hl)
	ld	a,(ix+10)
	and	$38
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$B0
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)	
	xpmp_update_fm_al_done:
	ret

	xpmp_fm_step_fb_frame:
	bit 	7,(ix+72)
	ret	nz
	xpmp_fm_step_fb:		
	ld 	a,(ix+72)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_fm_fb_done
	xpmp_update_fm_fb:
	ld	l,(ix+73)
	ld	h,(ix+74)
	ld 	d,0
	ld 	e,(ix+75)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_fm_fb_loop
	ld	b,a
	ld	a,(ix+10)
	and	7
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$B0
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)	
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+75),a
	jp	xpmp_update_fm_fb_done		
	xpmp_update_fm_fb_loop:
	ld	a,(ix+72)			; Which feedback macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,(xpmp_fbMacPtr)
	ld	bc,(xpmp_FB_mac_loop_tbl)
	ex	de,hl
	inc	de
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80
	ld	(de),a
	dec 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	(ix+75),1			; Reset position
	ld	l,(ix+73)
	ld	h,(ix+74)
	ld	b,(hl)
	ld	a,(ix+10)
	and	7
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$B0
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)	
	xpmp_update_fm_fb_done:
	ret

	xpmp_fm_step_ep_frame:
	bit 	7,(ix+28)
	ret	nz
	xpmp_fm_step_ep:		
	.IFNDEF XPMP_EPMAC_NOT_USED
	; Sweep macro
	ld 	a,(ix+28)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_fm_EP_done
	xpmp_update_fm_EP:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	l,(ix+29)
	ld	h,(ix+30)
	ld 	d,0
	ld 	a,(ix+31)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_fm_EP_loop
	ld	b,a
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+31),a
	ld	e,b
	ld	d,0
	bit	7,b
	jr	z,xpmp_update_fm_pos_freq
	ld	d,$FF
	xpmp_update_fm_pos_freq:
	ld	l,(ix+11)
	ld	h,(ix+12)
	add	hl,de
	ld	(ix+11),l
	ld	(ix+12),h
	jp	xpmp_update_fm_EP_done		
	xpmp_update_fm_EP_loop:
	ld	a,(ix+28)			; Which sweep macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,(xpmp_epMacPtr)
	ld	bc,(xpmp_EP_mac_loop_tbl)
	ex	de,hl
	inc	de
	add	hl,bc				; HL = xpmp_EP_mac_loop_tbl + (epMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80
	ld	(de),a
	dec 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	(ix+31),1			; Reset position
	ld	l,(ix+29)
	ld	h,(ix+30)
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_update_fm_pos_freq_2
	ld	d,$FF
	xpmp_update_fm_pos_freq_2:
	ld	l,(ix+11)
	ld	h,(ix+12)
	add	hl,de
	ld	(ix+11),l
	ld	(ix+12),h
	xpmp_update_fm_EP_done:
	.ENDIF
	ret
	
	

;************************************************************
;                     PSG code
;************************************************************
	

; Note / rest
xpmp_tone_cmd_00:
xpmp_tone_cmd_60:
	ld	hl,(xpmp_tempw)

	ld	a,c
	cp	CMD_VOLUP
	jr	nz,xpmp_tone_cmd_00_2
	INC_DATAPOS 1
	ld	a,(ix+_PSG_VOLUME)
	inc	hl
	add	a,(hl)
	ld	(ix+_PSG_VOLUME),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	(ix+_PSG_VMAC),EFFECT_DISABLED	; Volume set overrides volume macros
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
		ld	(ix+_CHN_DATAPOS),e
		ld	(ix+_CHN_DATAPOS+1),d
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
		ld	a,(ix+_CHN_DELAY)	
		add	a,(hl)
		ld	(ix+_CHN_DELAY),a	; Fractional part
		ld	hl,0 
		adc	hl,de
		ld	(ix+_CHN_DELAY+1),l	; Whole part
		ld	(ix+_CHN_DELAY+2),h
		jp 	xpmp_tone_cmd_00_got_delay
	xpmp_tone_cmd_00_short_note:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(ix+_CHN_DELAY)	
	add	a,(hl)
	ld	(ix+_CHN_DELAY),a		; Fractional part
	ld	hl,0 
	adc	hl,de
	ret	z
	ld	(ix+_CHN_DELAY+1),l		; Whole part
	ld	(ix+_CHN_DELAY+2),h
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
	ld	a,(ix+7)
	cp	CMD_REST	
	ret	z				; If this was a rest command we can return now
	cp	CMD_REST2
	ret	z
	.IFNDEF XPMP_VMAC_NOT_USED
	RESET_EFFECT 22,tone,v
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	RESET_EFFECT 26,tone,en
	.ENDIF
	.IFNDEF XPMP_EN2MAC_NOT_USED
	RESET_EFFECT 30,tone,en2
	.ENDIF
	.IFNDEF XPMP_MPMAC_NOT_USED
	RESET_EFFECT 38,tone,mp
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	RESET_EFFECT 34,tone,ep
	.ENDIF
	
	;.IFDEF XPMP_GAME_GEAR
	;ld	a,(xpmp_channel\1.csMac)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_\1_reset_cs_mac
	;.ENDIF	
	
	;ld	hl,(xpmp_channel\1.cbEvnote)
	;ld	a,h
	;or	l
	;ret	z
	;jp	(hl)				; If a callback has been set for EVERY-NOTE we call it now
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
	ld	(ix+_PSG_VOLUME),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	(ix+_PSG_VMAC),EFFECT_DISABLED	; Volume set overrides volume macros
	ret

; Octave up + note	
xpmp_tone_cmd_40:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+9)
	add	a,12
	ld	(ix+9),a
	ld 	a,c
	add 	a,$20
	ld 	c,a
	jp	xpmp_tone_cmd_00_2

; Octave down + note
xpmp_tone_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+9)
	sub	12
	ld	(ix+9),a
	ld 	a,c
	add 	a,$10
	ld 	c,a
	jp	xpmp_tone_cmd_00_2

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
	jp	z,xpmp_fm_cmd_90_wrmem
	cp	CMD_WRPORT
	jp	z,xpmp_fm_cmd_90_wrport
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
	ld	e,(ix+_CHN_DATAPOS)
	ld	d,(ix+_CHN_DATAPOS+1)
	inc	de
	ld	(ix+50),e
	ld	(ix+51),d
	ld	a,(ix+_CHN_DATAPTR)
	ld	(ix+48),a
	ld	a,(ix+_CHN_DATAPTR+1)
	ld	(ix+49),a
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	a,(hl)
	ld	de,(xpmp_pattern_tbl)
	ld	h,0
	add	a,a
	ld	l,a
	add	hl,de
	ld	a,(hl)
	or	$80
	inc	hl
	ld	d,(hl)
	ld	(ix+_CHN_DATAPTR),d
	ld	(ix+_CHN_DATAPTR+1),a
	ld	(ix+_CHN_DATAPOS),$FF
	ld	(ix+_CHN_DATAPOS+1),$FF
	ret
	
	; Return from pattern
	xpmp_tone_cmd_90_rts:
	ld	a,(ix+48)
	ld	(ix+_CHN_DATAPTR),a
	ld	a,(ix+49)
	ld	(ix+_CHN_DATAPTR+1),a
	ld	a,(ix+50)
	ld	(ix+_CHN_DATAPOS),a
	ld	a,(ix+51)
	ld	(ix+_CHN_DATAPOS+1),a
	ret

	xpmp_tone_cmd_90_len:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 2
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_tone_cmd_90_short_delay
		inc	de
		ld	(ix+_CHN_DATAPOS),e
		ld	(ix+_CHN_DATAPOS+1),d
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
	;ld	a,0
	;ld	(xpmp_channel\1.cbEvnote),a
	;ld	(xpmp_channel\1.cbEvnote+1),a
	ret
	
	xpmp_tone_cmd_E0_cbonce:
	;inc	hl
	;ld	a,(hl)
	;ld	de,xpmp_callback_tbl
	;ld	h,0
	;add	a,a
	;ld	l,a
	;add	hl,de
	;ld	e,(hl)
	;inc	hl
	;ld	d,(hl)
	;ex	de,hl
	;jp	(hl)
	ret
	
	; Every note
	xpmp_tone_cmd_E0_cbevnt:
	;inc	hl
	;ld	a,(hl)
	;ld	de,xpmp_callback_tbl
	;ld	h,0
	;add	a,a
	;ld	l,a
	;add	hl,de
	;ld	a,(hl)
	;ld	(xpmp_channel\1.cbEvnote),a
	;inc	hl
	;ld	a,(hl)
	;ld	(xpmp_channel\1.cbEvnote+1),a
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
	ld	(ix+22),a
	xpmp_tone_reset_v_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,(xpmp_v_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+24),a
	inc	hl
	ld	a,(hl)
	ld	(ix+23),a
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
	ld	hl,(xpmp_MP_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+40),a
	inc	hl
	ld	a,(hl)
	ld	(ix+39),a
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
	ld	hl,(xpmp_EP_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+36),a
	inc	hl
	ld	a,(hl)
	ld	(ix+35),a
	ld	l,(ix+35)
	ld	h,(ix+36)
	ld	(ix+37),1
	ld	(ix+17),0
	ld	a,(hl)
	ld	(ix+16),a
	bit	7,a
	ret	z
	ld	(ix+17),$FF
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
	ld	(ix+_CHN_DATAPOS),e
	ld	(ix+_CHN_DATAPOS+1),d
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
	ld	(ix+_CHN_DATAPOS),e
	ld	(ix+_CHN_DATAPOS+1),d
	ret
	xpmp_tone_cmd_F0_DJNZ_Z:
	dec	hl
	ld	(ix+44),l
	ld	(ix+45),h
	INC_DATAPOS 1
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
	ld	hl,(xpmp_EN_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+32),a
	inc	hl
	ld	a,(hl)
	ld	(ix+31),a
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
	
	; Initialize cumulative arpeggio macro
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
	ld	hl,(xpmp_EN_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+28),a
	inc	hl
	ld	a,(hl)
	ld	(ix+27),a
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
	;ld	a,(hl)
	ld	a,0
	;ld	(xpmp_channel\1.csMac),a
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
		ld	(ix+_CHN_DATAPOS),e
		ld	(ix+_CHN_DATAPOS+1),d
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
		ld	a,(ix+_CHN_DELAY)	
		add	a,(hl)
		ld	(ix+_CHN_DELAY),a	; Fractional part
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
	call	xpmp_tone_step_v
	xpmp_noise_v_reset:	
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	ld	a,(ix+26)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_tone_reset_en_mac	; Reset effects as needed..
	jr	xpmp_noise_en_reset
	+:
	call	xpmp_tone_step_en
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
	call	xpmp_tone_step_en2
	xpmp_noise_en2_reset:	
	;ld	a,(ix+30)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_tone_reset_en2_mac
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
	ld 	a,c
	add 	a,$20
	ld 	c,a
	jp	xpmp_tone_cmd_60 ;xpmp_noise_cmd_00_2

; Octave down + note
xpmp_noise_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(xpmp_channel3.octave)
	sub	12
	ld	(xpmp_channel3.octave),a
	ld 	a,c
	add 	a,$10
	ld 	c,a
	jp	xpmp_tone_cmd_60 ;xpmp_noise_cmd_00_2


; Callback
xpmp_noise_cmd_E0:
	ld	hl,(xpmp_tempw)
	INC_DATAPOS 1
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
	INC_DATAPOS 1
	; Initialize volume macro	
	ld	a,c

	.IFNDEF XPMP_VMAC_NOT_USED
	cp	CMD_VOLMAC
	jp	nz,xpmp_tone_cmd_F0_check_JMP
	inc	hl
	ld	a,(hl)
	ld	(ix+22),a
	xpmp_noise_reset_v_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,(xpmp_v_mac_tbl)
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	$80
	ld	(ix+24),a
	inc	hl
	ld	a,(hl)
	ld	(ix+23),a
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
	
	ld	a,(ix+_CHN_NOTE)
	cp	CMD_END
	ret	z				; Playback has ended for this channel - all processing should be skipped
	
	ld 	l,(ix+_CHN_DELAY+1)		; Decrement the whole part of the delay and check if it has reached zero
	ld	h,(ix+_CHN_DELAY+2)
	dec	hl
	ld	a,h
	or	l
	jp 	nz,xpmp_update_psg_effects	
	
	; Loop here until a note/rest or END command is read (signaled by xpmp_freqChange == 2)
	xpmp_update_psg_read_cmd:
	ld	l,(ix+_CHN_DATAPTR)
	ld	h,(ix+_CHN_DATAPTR+1)
	ld	e,(ix+_CHN_DATAPOS)
	ld	d,(ix+_CHN_DATAPOS+1)
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

	INC_DATAPOS 1
	
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
	ld	a,(ix+_CHN_NOTEOFFS)
	ld	d,(ix+_PSG_TRANSP)
	add	a,d
	add	a,b				; note + noteOffs + transpose
	ld	b,a
	ld	a,(xpmp_chnum)
	cp	3
	jr	z,xpmp_update_psg_noise
	ld	a,(ix+_CHN_OCTAVE)
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

	ld	($7F11),a
	ld	a,h
	sla	l		
	rla			
	sla	l
	rla	
	sla	l
	rla	
	sla	l
	rla	
	ld	($7F11),a
	jr	xpmp_update_psg_tone
	xpmp_update_psg_noise:
	ld	a,b
	and	3
	ld	b,a
	ld	a,(xpmp_channel3.duty)
	or	b
	or	$E0
	ld	($7F11),a
	xor	$E0
	ld	($7F11),a
	xpmp_update_psg_tone:
	ld	a,(xpmp_lastNote)
	cp	CMD_REST
	jr	nz,xpmp_update_psg_set_vol2
	jp	xpmp_update_psg_set_vol3

	xpmp_update_psg_set_vol:
	ld	a,(ix+_CHN_NOTE)
	cp	CMD_REST
	jr	z,xpmp_update_psg_rest
	xpmp_update_psg_set_vol2:
	; Update the volume if it has changed
	ld	a,(xpmp_volChange)
	cp	0
	ret	z
	xpmp_update_psg_set_vol3:
	ld	a,(xpmp_chsel)
	or	(ix+_PSG_VOLUME)
	xor	$9F
	ld	($7F11),a
	res	7,a
	ld	($7F11),a
	xpmp_update_psg_no_vol_change:
	ret
	
	; Mute the channel
	xpmp_update_psg_rest:
	ld	a,(xpmp_chsel)
	or	$9F
	ld	($7F11),a
	res	7,a
	ld	($7F11),a
	ret

	xpmp_update_psg_effects:
	ld 	(ix+_CHN_DELAY+1),l
	ld	(ix+_CHN_DELAY+2),h

	call	xpmp_tone_step_v_frame
	call	xpmp_tone_step_en_frame
	call	xpmp_tone_step_en2_frame
	call	xpmp_tone_step_ep_frame
	call	xpmp_tone_step_mp_frame

	xpmp_update_psg_effects_done:
	ld	a,(xpmp_freqChange)
	cp	0
	jp	nz,xpmp_update_psg_freq_change
	jp	xpmp_update_psg_set_vol
	ret	
	
	xpmp_tone_step_v_frame:
	bit 	7,(ix+_PSG_VMAC)
	ret	nz
	xpmp_tone_step_v:	
	.IFNDEF XPMP_VMAC_NOT_USED
	; Volume macro
	ld 	a,(ix+_PSG_VMAC)
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
	ld	a,(ix+_PSG_VMAC)		; Which volume macro are we using?
	and	$7F
	dec	a
	ld	e,a
	sla	e				; Each pointer is two bytes
	ld	bc,(xpmp_v_mac_loop_tbl)
	;ld	hl,(xpmp_vMacPtr)
	ld	l,(ix+23)
	ld	h,(ix+24)
	ex	de,hl
	inc	de
	add	hl,bc 				; HL = xpmp_vMac_loop_tbl + (vMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80
	ld	(de),a				; Store in xpmp_\1_vMac_ptr
	dec 	de	
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

	xpmp_tone_step_en_frame:
	bit 	7,(ix+26)
	ret	nz
	xpmp_tone_step_en:		
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
	ld	bc,(xpmp_EN_mac_loop_tbl)
	ex	de,hl
	inc	de
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80
	ld	(de),a
	dec 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	(ix+29),1			; Reset position
	ld	l,(ix+27)
	ld	h,(ix+28)
	ld	b,(hl)
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Reset note offset
	xpmp_update_psg_EN_done:
	.ENDIF
	ret

	xpmp_tone_step_en2_frame:
	bit 	7,(ix+30)
	ret	nz
	xpmp_tone_step_en2:		
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
	ld	bc,(xpmp_EN_mac_loop_tbl)
	ex	de,hl
	inc	de
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (en2Mac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80
	ld	(de),a
	dec 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	(ix+33),1			; Reset position
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
	xpmp_tone_step_ep_frame:
	bit 	7,(ix+34)
	ret	nz
	xpmp_tone_step_ep:		
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
	ld	bc,(xpmp_EP_mac_loop_tbl)
	ex	de,hl
	inc	de
	add	hl,bc				; HL = xpmp_EP_mac_loop_tbl + (epMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	or	$80
	ld	(de),a
	dec 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	(ix+37),1			; Reset position
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

	xpmp_tone_step_mp_frame:
	bit 	7,(ix+38)
	ret	nz
	xpmp_tone_step_mp:		
	.IFNDEF XPMP_MPMAC_NOT_USED
	; Vibrato
	ld 	a,(ix+38)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_psg_MP_done
	ld	a,(ix+41)
	;dec	a
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
	

	
.MACRO UPDATE_FM
ld	a,\1
ld	(xpmp_chsel),a
ld	a,\2
ld	hl,xpmp_channel\3.vMacPtr
ld	(xpmp_vMacPtr),hl
ld	hl,xpmp_channel\3.enMacPtr
ld	(xpmp_enMacPtr),hl
ld	hl,xpmp_channel\3.en2MacPtr
ld	(xpmp_en2MacPtr),hl
ld	hl,xpmp_channel\3.epMacPtr
ld	(xpmp_epMacPtr),hl
ld	hl,xpmp_channel\3.alMacPtr
ld	(xpmp_alMacPtr),hl
ld	hl,xpmp_channel\3.fbMacPtr
ld	(xpmp_fbMacPtr),hl
call 	xpmp_update_fm
.ENDM

 
xpmp_update:

 UPDATE_FM 0,0,4
 UPDATE_FM 1,1,5
 UPDATE_FM 2,2,6
 UPDATE_FM 4,0,7
 UPDATE_FM 5,1,8
 UPDATE_FM 6,2,9

.IFDEF XPMP_ENABLE_CHANNEL_A
	ld	a,0
	ld	hl,xpmp_tone_jump_tbl
	ld	(xpmp_jump_tbl),hl
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
	ld	hl,xpmp_tone_jump_tbl
	ld	(xpmp_jump_tbl),hl
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
	ld	hl,xpmp_tone_jump_tbl
	ld	(xpmp_jump_tbl),hl
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
	ld	hl,xpmp_noise_jump_tbl
	ld	(xpmp_jump_tbl),hl
	ld	hl,xpmp_channel3.enMacPtr
	ld	(xpmp_enMacPtr),hl
	ld	hl,xpmp_channel3.en2MacPtr
	ld	(xpmp_en2MacPtr),hl
	ld	hl,xpmp_channel3.epMacPtr
	ld	(xpmp_epMacPtr),hl
	call 	xpmp_update_psg
.ENDIF

ret
	


xpmp_channel_ptr_tbl:
.dw xpmp_channel0
.dw xpmp_channel1
.dw xpmp_channel2
.dw xpmp_channel3


xpmp_fm_channel_ptr_tbl:
.dw xpmp_channel4
.dw xpmp_channel5
.dw xpmp_channel6
.dw xpmp_channel7
.dw xpmp_channel8
.dw xpmp_channel9


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
.dw xpmp_noise_cmd_F0


xpmp_fm_jump_tbl:
.dw xpmp_fm_cmd_00
.dw xpmp_fm_cmd_10
.dw xpmp_fm_cmd_20
.dw xpmp_fm_cmd_30
.dw xpmp_fm_cmd_40
.dw xpmp_fm_cmd_50
.dw xpmp_fm_cmd_60
.dw xpmp_fm_cmd_70
.dw xpmp_fm_cmd_80
.dw xpmp_fm_cmd_90
.dw xpmp_fm_cmd_A0
.dw xpmp_fm_cmd_B0
.dw xpmp_fm_cmd_C0
.dw xpmp_fm_cmd_D0
.dw xpmp_fm_cmd_E0
.dw xpmp_fm_cmd_F0



xpmp_fm_freq_tbl:
.dw 649, 688, 729, 772, 818, 867, 918, 973, 1031, 1092, 1157, 1226


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

			


	