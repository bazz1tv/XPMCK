; Cross Platform Music Player
; KSS/CPC/Spectrum version
; /Mic, 2009-2010


; Define the starting address of XPMP's RAM chunk 
.IFNDEF XPMP_RAM_START
.DEFINE XPMP_RAM_START $C000
.ENDIF

; The FM command buffer has the following structure:
;  nCommandsInBuffer command command command ...
;
; Each command is two bytes. The first byte contains
; the register to write to, the second byte contains
; the value to write.
.DEFINE XPMP_FM_BUF 		$E000

.DEFINE XPMP_SN_PORT $7F
.DEFINE XPMP_AY_ADDR $A0
.DEFINE XPMP_AY_DATA $A1
.DEFINE XPMP_FMUNIT_ADDR $F0
.DEFINE XPMP_FMUNIT_DATA $F1

.IFDEF XPMP_USES_SN76489
.DEFINE XPMP_ENABLE_CHANNEL_A
.DEFINE XPMP_ENABLE_CHANNEL_B
.DEFINE XPMP_ENABLE_CHANNEL_C
.DEFINE XPMP_ENABLE_CHANNEL_D
.ENDIF
.IFDEF XPMP_USES_AY
.DEFINE XPMP_ENABLE_CHANNEL_E
.DEFINE XPMP_ENABLE_CHANNEL_F
.DEFINE XPMP_ENABLE_CHANNEL_G
.ENDIF
.IFDEF XPMP_USES_SCC
.DEFINE XPMP_ENABLE_CHANNEL_H
.DEFINE XPMP_ENABLE_CHANNEL_I
.DEFINE XPMP_ENABLE_CHANNEL_J
.DEFINE XPMP_ENABLE_CHANNEL_K
.DEFINE XPMP_ENABLE_CHANNEL_L
.ENDIF
.IFDEF XPMP_USES_FMUNIT
.DEFINE XPMP_ENABLE_CHANNEL_M
.DEFINE XPMP_ENABLE_CHANNEL_N
.DEFINE XPMP_ENABLE_CHANNEL_O
.DEFINE XPMP_ENABLE_CHANNEL_P
.DEFINE XPMP_ENABLE_CHANNEL_Q
.DEFINE XPMP_ENABLE_CHANNEL_R
.DEFINE XPMP_ENABLE_CHANNEL_S
.DEFINE XPMP_ENABLE_CHANNEL_T
.ENDIF

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
.EQU CMD_HWES	$98
.EQU CMD_HWNS	$99
.EQU CMD_LEN	$9A
.EQU CMD_WAVMAC $9E
.EQU CMD_TRANSP $9F
.EQU CMD_MODE   $A0
.EQU CMD_OPER   $C0
.EQU CMD_RSCALE $D0
.EQU CMD_CBOFF  $E0
.EQU CMD_CBONCE $E1
.EQU CMD_CBEVNT $E2
.EQU CMD_CBEVVC $E3
.EQU CMD_CBEVVM $E4
.EQU CMD_CBEVOC $E5
.EQU CMD_HWTE	$E8
.EQU CMD_HWAM   $EA
.EQU CMD_MODMAC $EB
.EQU CMD_LDWAVE $EC
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
.EQU EFFECT_LOOP $80


; 60 bytes
.STRUCT xpmp_channel_t
dataPtr		dw
dataPos		dw
delay		dw
delayHi		db	;+6
note		db	;+7
noteOffs	db
octave		db	;+9
duty		db
freq		dw
volume		db	;+13
volOffs		db
enven		db	;+15	on/off setting
freqOffs	dw	;+16
freqOffsLatch	dw
detune		dw 
vMac		db	;+22
vMacPtr		dw
vMacPos		db
enMac		db	;+26
enMacPtr	dw
enMacPos	db
en2Mac		db	;+30
en2MacPtr	dw
en2MacPos	db
epMac		db	;+34
epMacPtr	dw
epMacPos	db
mpMac		db	;+38
mpMacPtr	dw
mpMacDelay	db
loop1		db	;+42
loop2		db
loopPtr		dw	;+44
cbEvnote	dw	;+46
returnAddr	dw	;+48
oldPos		dw	;+50
delayLatch	dw	;+52
delayLatch2	db	;+54
csMac		db	;+55
csMacPtr	dw	;+56
csMacPos	db	;+58
transpose	db	;+59
.ENDST


; 65 bytes
.STRUCT xpmp_scc_channel_t
dataPtr		dw
dataPos		dw
delay		dw
delayHi		db	;+6
note		db	;+7
noteOffs	db
octave		db	;+9
duty		db
freq		dw
volume		db	;+13
volOffs		db
enven		db	;+15	on/off setting
freqOffs	dw	;+16
freqOffsLatch	dw
detune		dw 
vMac		db	;+22
vMacPtr		dw
vMacPos		db
enMac		db	;+26
enMacPtr	dw
enMacPos	db
en2Mac		db	;+30
en2MacPtr	dw
en2MacPos	db
epMac		db	;+34
epMacPtr	dw
epMacPos	db
mpMac		db	;+38
mpMacPtr	dw
mpMacDelay	db
loop1		db	;+42
loop2		db
loopPtr		dw	;+44
cbEvnote	dw	;+46
returnAddr	dw	;+48
oldPos		dw	;+50
delayLatch	dw	;+52
delayLatch2	db	;+54
csMac		db	;+55
csMacPtr	dw	;+56
csMacPos	db	;+58
wtMac		db	;+59
wtMacPtr	dw	;+60
wtMacPos	db	;+62
wtMacDelay	db	;+63
transpose	db	;+64
.ENDST


.EQU _FM_DATAPOS 2
.EQU _FM_NOTE 7
.EQU _FM_VOLUME 15

; For YM2151 channels
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
reg_mod		db	; 40
reg_d_1		db 	; 41
reg_d_2		db	; 42
reg_d_3		db	; 43
reg_d_4		db	; 44
reg_tl_1	db	; 45
reg_tl_2	db	; 46
reg_tl_3	db	; 47
reg_tl_4	db	; 48
reg_att_1	db	; 49
reg_att_2	db	; 50
reg_att_3	db	; 51
reg_att_4	db	; 52
reg_dec1_1	db	; 53
reg_dec1_2	db	; 54
reg_dec1_3	db	; 55
reg_dec1_4	db	; 56
reg_dec2_1	db	; 57
reg_dec2_2	db	; 58
reg_dec2_3	db	; 59
reg_dec2_4	db	; 60
reg_sus_1	db	; 61
reg_sus_2	db	; 62
reg_sus_3	db	; 63
reg_sus_4	db	; 64
dummy1		dw	; 65
mode		db	; 67
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
transpose	db	; 83
.ENDST



.ENUM XPMP_RAM_START
xpmp_channel0	INSTANCEOF xpmp_channel_t	; SN76489
xpmp_channel1 	INSTANCEOF xpmp_channel_t
xpmp_channel2 	INSTANCEOF xpmp_channel_t
xpmp_channel3 	INSTANCEOF xpmp_channel_t
xpmp_channel4 	INSTANCEOF xpmp_channel_t	; AY3-8910
xpmp_channel5 	INSTANCEOF xpmp_channel_t
xpmp_channel6 	INSTANCEOF xpmp_channel_t
xpmp_channel7 	INSTANCEOF xpmp_scc_channel_t	; Konami SCC
xpmp_channel8 	INSTANCEOF xpmp_scc_channel_t
xpmp_channel9 	INSTANCEOF xpmp_scc_channel_t
xpmp_channel10 	INSTANCEOF xpmp_scc_channel_t
xpmp_channel11 	INSTANCEOF xpmp_scc_channel_t
xpmp_channel12 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel13 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel14 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel15 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel16 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel17 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel18 	INSTANCEOF xpmp_fm_channel_t
xpmp_channel19 	INSTANCEOF xpmp_fm_channel_t
xpmp_freqChange	db
xpmp_volChange 	db
xpmp_lastNote	db
xpmp_pan	db
xpmp_chnum	db
xpmp_ayen	db
xpmp_tempv	dw
xpmp_tempw	dw
.ENDE


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


.IFDEF XPMP_USES_FMUNIT

write_ym2151:
	out	(XPMP_FMUNIT_ADDR),a
	ld	a,b
	out	(XPMP_FMUNIT_DATA),a
	ret

write_ym2151_allops:
	ld	d,a
	add	a,32
	ld	e,a
	-:
	ld	a,d
	out	(XPMP_FMUNIT_ADDR),a
	add	a,8
	ld	d,a
	ld	a,b
	out	(XPMP_FMUNIT_DATA),a
	ld	a,d
	cp	e
	jr	nz,-
	ret


; Writes all commands in the FM command buffer to the YM2151
write_ym_buf:
	ld	a,(xpmp_chnum)
	ld	c,a
	ld	a,(XPMP_FM_BUF)
	ld	b,a

	ld	a,0
	ld	(XPMP_FM_BUF),a
	ld	de,XPMP_FM_BUF+1

	wyb_loop:
	ld	a,b
	cp	0
	ret	z
	;-:
	;in	a,($F2)
	;bit	7,a
	;jr	nz,-
	ld	a,(de)
	or	c				; OR in the channel bits
	inc	de
	out	(XPMP_FMUNIT_ADDR),a		; Select register
	ld	a,(de)
	out	(XPMP_FMUNIT_DATA),a		; Write data
	inc	de
	dec	b
	jp	wyb_loop
	
	
.ENDIF


.MACRO WRITE_YM2151
	ld	a,\1
	ld	b,\2
	call	write_ym2151
.ENDM


.MACRO WRITE_YM2151_ALLOPS
	ld	a,\1
	ld	b,\2
	call	write_ym2151_allops
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


; Initialize the music player
; HL = pointer to song table, A = song number
xpmp_init:
	ld	b,0
	dec	a
	ld	c,a
	sla	c
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

	.IFDEF XPMP_CPC
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_E,4
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_F,5
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_G,6
	

	.ELSE
	; Initialize channel data pointers
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ld	a,(hl)
	ld	(xpmp_channel0.dataPtr),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ld	a,(hl)
	ld	(xpmp_channel0.dataPtr+1),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ld	a,(hl)
	ld	(xpmp_channel1.dataPtr),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ld	a,(hl)
	ld	(xpmp_channel1.dataPtr+1),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ld	a,(hl)
	ld	(xpmp_channel2.dataPtr),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ld	a,(hl)
	ld	(xpmp_channel2.dataPtr+1),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld	a,(hl)
	ld	(xpmp_channel3.dataPtr),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld	a,(hl)
	ld	(xpmp_channel3.dataPtr+1),a
	.ENDIF
	inc	hl

	.IFDEF XPMP_ENABLE_CHANNEL_E
	ld	a,(hl)
	ld	(xpmp_channel4.dataPtr),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_E
	ld	a,(hl)
	ld	(xpmp_channel4.dataPtr+1),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_F
	ld	a,(hl)
	ld	(xpmp_channel5.dataPtr),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_F
	ld	a,(hl)
	ld	(xpmp_channel5.dataPtr+1),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_G
	ld	a,(hl)
	ld	(xpmp_channel6.dataPtr),a
	.ENDIF
	inc	hl
	.IFDEF XPMP_ENABLE_CHANNEL_G
	ld	a,(hl)
	ld	(xpmp_channel6.dataPtr+1),a
	.ENDIF
	inc	hl

	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_H,7
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_I,8
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_J,9
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_K,10
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_L,11

	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_M,12
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_N,13
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_O,14
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_P,15
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_Q,16
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_R,17
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_S,18
	INIT_DATA_PTR XPMP_ENABLE_CHANNEL_T,19
	
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ld	hl,xpmp_channel0.loop1-1
	ld	(xpmp_channel0.loopPtr),hl
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ld	hl,xpmp_channel1.loop1-1
	ld	(xpmp_channel1.loopPtr),hl
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ld	hl,xpmp_channel2.loop1-1
	ld	(xpmp_channel2.loopPtr),hl
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld	hl,xpmp_channel3.loop1-1
	ld	(xpmp_channel3.loopPtr),hl
	.ENDIF

	.IFDEF XPMP_ENABLE_CHANNEL_E
	ld	hl,xpmp_channel4.loop1-1
	ld	(xpmp_channel4.loopPtr),hl
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_F
	ld	hl,xpmp_channel5.loop1-1
	ld	(xpmp_channel5.loopPtr),hl
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_G
	ld	hl,xpmp_channel6.loop1-1
	ld	(xpmp_channel6.loopPtr),hl
	.ENDIF
	
	
	; Initialize the delays for all channels to 1
	ld 	a,1
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ld	(xpmp_channel0.delay+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ld	(xpmp_channel1.delay+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ld	(xpmp_channel2.delay+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld	(xpmp_channel3.delay+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_E
	ld	(xpmp_channel4.delay+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_F
	ld	(xpmp_channel5.delay+1),a
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_G
	ld	(xpmp_channel6.delay+1),a
	.ENDIF
	
	; Generate white noise by default
	ld	a,4
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ld	(xpmp_channel3.duty),a
	.ENDIF
	

	.IFDEF XPMP_USES_SCC
	ld	a,$3F
	ld	($9000),a
	ld	a,0
	ld	($988A),a
	ld	($988B),a
	ld	($988C),a
	ld	($988D),a
	ld	($988E),a
	ld	a,$1F
	ld	($988F),a
	.ENDIF
	
	.IFDEF XPMP_USES_FMUNIT
	; Turn on left and right output for all channels
	WRITE_YM2151 $08,0
	WRITE_YM2151 $08,1
	WRITE_YM2151 $08,2
	WRITE_YM2151 $08,3
	WRITE_YM2151 $08,4
	WRITE_YM2151 $08,5
	WRITE_YM2151 $08,6
	WRITE_YM2151 $08,7
	
	WRITE_YM2151 $20,$C0
	WRITE_YM2151 $21,$C0
	WRITE_YM2151 $22,$C0
	WRITE_YM2151 $23,$C0
	WRITE_YM2151 $24,$C0
	WRITE_YM2151 $25,$C0
	WRITE_YM2151 $26,$C0
	WRITE_YM2151 $27,$C0
	
	WRITE_YM2151_ALLOPS $40,127
	WRITE_YM2151_ALLOPS $41,127
	WRITE_YM2151_ALLOPS $42,127
	WRITE_YM2151_ALLOPS $43,127
	WRITE_YM2151_ALLOPS $44,127
	WRITE_YM2151_ALLOPS $45,127
	WRITE_YM2151_ALLOPS $46,127
	WRITE_YM2151_ALLOPS $47,127

	WRITE_YM2151 $18,$00
	WRITE_YM2151 $1B,$00  ;$C0
	.ENDIF
	.ENDIF ; XPMP_CPC
	
	ld	a,$FF
	ld	(xpmp_pan),a
	
	ld	a,$FF
	ld	(xpmp_ayen),a
	
	ret


.macro XPMP_COMMANDS

; Note / rest
xpmp_\1_cmd_00:
xpmp_\1_cmd_60:
	ld	hl,(xpmp_tempw)

	ld	a,c
	cp	CMD_VOLUP
	jr	nz,xpmp_\1_cmd_00_2

	ld	a,(xpmp_channel\1.dataPos)
	add	a,1
	ld	(xpmp_channel\1.dataPos),a
	ld	a,(xpmp_channel\1.dataPos+1)
	adc	a,0
	ld	(xpmp_channel\1.dataPos+1),a
	ld	a,(xpmp_channel\1.volume)
	inc	hl
	add	a,(hl)
	ld	(xpmp_channel\1.volume),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	a,EFFECT_DISABLED
	ld	(xpmp_channel\1.vMac),a		; Volume set overrides volume macros
	ret
	
xpmp_\1_cmd_00_2:
	ld	a,(xpmp_channel\1.note)
	ld	(xpmp_lastNote),a
	ld	a,c
	and	$0F
	ld	(xpmp_channel\1.note),a
	ld	a,c
	and	$F0
	cp	CMD_NOTE2
	jr	z,xpmp_\1_cmd_00_std_delay
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	inc	de
	ld	(xpmp_channel\1.dataPos),de
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_\1_cmd_00_short_note
		inc	de
		ld	(xpmp_channel\1.dataPos),de
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
		ld	a,(xpmp_channel\1.delay)	
		add	a,(hl)
		ld	(xpmp_channel\1.delay),a	; Fractional part
		ld	hl,0 
		adc	hl,de
		ld	(xpmp_channel\1.delay+1),hl	; Whole part
		jp 	xpmp_\1_cmd_00_got_delay
	xpmp_\1_cmd_00_short_note:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(xpmp_channel\1.delay)	
	add	a,(hl)
	ld	(xpmp_channel\1.delay),a	; Fractional part
	ld	hl,0 
	adc	hl,de
	ret	z
	ld	(xpmp_channel\1.delay+1),hl	; Whole part
	jp 	xpmp_\1_cmd_00_got_delay
	xpmp_\1_cmd_00_std_delay:		; Use delay set by last CMD_LEN
	ld	a,(xpmp_channel\1.delayLatch)
	ld	b,a
	ld	a,(xpmp_channel\1.delay)
	add	a,b
	ld	(xpmp_channel\1.delay),a
	ld 	hl,(xpmp_channel\1.delayLatch+1)
	ld	de,0
	adc	hl,de
	ret	z
	ld	(xpmp_channel\1.delay+1),hl
	xpmp_\1_cmd_00_got_delay:
	ld	a,2
	ld	(xpmp_freqChange),a
	;xpmp_\1_cmd_00_zero_delay:
	ld	a,(xpmp_channel\1.note)
	cp	CMD_REST	
	ret	z				; If this was a rest command we can return now
	cp	CMD_REST2
	ret	z
	.IFNDEF XPMP_VMAC_NOT_USED
	ld	a,(xpmp_channel\1.vMac)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_\1_reset_v_mac		; Reset effects as needed..
	jr	xpmp_\1_v_reset
	+:
	call	xpmp_\1_step_v
	xpmp_\1_v_reset:
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN
	ld	a,(xpmp_channel\1.enMac)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_\1_reset_en_mac		; Reset effects as needed..
	jr	xpmp_\1_en_reset
	+:
	call	xpmp_\1_step_en
	xpmp_\1_en_reset:
	.ENDIF
	.ENDIF
	.IFNDEF XPMP_EN2MAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN2
	ld	a,(xpmp_channel\1.en2Mac)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_\1_reset_en2_mac	; Reset effects as needed..
	jr	xpmp_\1_en2_reset
	+:
	call	xpmp_\1_step_en2
	xpmp_\1_en2_reset:
	.ENDIF
	.ENDIF
	.IF \1 < 3
	.IFNDEF XPMP_MPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_MP
	ld	a,(xpmp_channel\1.mpMac)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_\1_reset_mp_mac		; Reset effects as needed..
	jr	xpmp_\1_mp_reset
	+:
	call	xpmp_\1_step_mp
	xpmp_\1_mp_reset:
	.ENDIF
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EP
	ld	a,(xpmp_channel\1.epMac)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_\1_reset_ep_mac		; Reset effects as needed..
	jr	xpmp_\1_ep_reset
	+:
	call	xpmp_\1_step_ep
	xpmp_\1_ep_reset:
	.ENDIF
	.ENDIF
	.ENDIF
	ld	a,(xpmp_channel\1.csMac)
	bit	7,a
	jr	nz,+
	cp	EFFECT_DISABLED
	call	nz,xpmp_\1_reset_cs_mac		; Reset effects as needed..
	jr	xpmp_\1_cs_reset
	+:
	call	xpmp_\1_step_cs
	xpmp_\1_cs_reset:

	ld	hl,(xpmp_channel\1.cbEvnote)
	ld	a,h
	or	l
	ret	z
	jp	(hl)				; If a callback has been set for EVERY-NOTE we call it now

; Set octave
xpmp_\1_cmd_10:
	;ld	hl,(xpmp_tempw)
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
	ld	(xpmp_channel\1.octave),a
	ret
	
xpmp_\1_cmd_20:
	.IF \1 == 3
	ld	hl,(xpmp_tempw)
	ld	a,c
	and	1
	xor	1
	add	a,a
	add	a,a
	ld	(xpmp_channel\1.duty),a
	.ENDIF
	ret

; Set volume (short)
xpmp_\1_cmd_30:
	;ld	hl,(xpmp_tempw)
	ld	a,c
	and	$0F
	ld	(xpmp_channel\1.volume),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	a,EFFECT_DISABLED
	ld	(xpmp_channel\1.vMac),a		; Volume set overrides volume macros
	ret

; Octave up + note	
xpmp_\1_cmd_40:
	ld	hl,(xpmp_tempw)
	ld	a,(xpmp_channel\1.octave)
	add	a,12
	ld	(xpmp_channel\1.octave),a
	ld 	a,c
	add 	a,$20
	ld 	c,a
	jp	xpmp_\1_cmd_00_2

; Octave down + note
xpmp_\1_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(xpmp_channel\1.octave)
	sub	12
	ld	(xpmp_channel\1.octave),a
	ld 	a,c
	add 	a,$10
	ld 	c,a
	jp	xpmp_\1_cmd_00_2

xpmp_\1_cmd_70:
xpmp_\1_cmd_80:
	ret

; Turn off arpeggio macro
xpmp_\1_cmd_90:
	ld	a,c
	cp	CMD_JSR
	jr	z,xpmp_\1_cmd_90_jsr
	cp	CMD_RTS
	jr	z,xpmp_\1_cmd_90_rts
	cp	CMD_LEN
	jr	z,xpmp_\1_cmd_90_len
	cp	CMD_TRANSP
	jp	z,xpmp_\1_cmd_90_transp
	
	ld	hl,(xpmp_tempw)
	ld	a,0
	ld	(xpmp_channel\1.enMac),a
	ld	(xpmp_channel\1.en2Mac),a
	ld	(xpmp_channel\1.noteOffs),a
	ret

	xpmp_\1_cmd_90_jsr:
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	(xpmp_channel\1.oldPos),de
	ld	de,(xpmp_channel\1.dataPtr)
	ld	(xpmp_channel\1.returnAddr),de
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
	ld	(xpmp_channel\1.dataPtr),de
	ld	a,$FF
	ld	(xpmp_channel\1.dataPos),a
	ld	(xpmp_channel\1.dataPos+1),a
	ret
	
	xpmp_\1_cmd_90_rts:
	ld	de,(xpmp_channel\1.returnAddr)
	ld	(xpmp_channel\1.dataPtr),de
	ld	de,(xpmp_channel\1.oldPos)
	ld	(xpmp_channel\1.dataPos),de
	ret
	
	xpmp_\1_cmd_90_len:
	ld	hl,(xpmp_tempw)
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	inc	de
	ld	(xpmp_channel\1.dataPos),de
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_\1_cmd_90_short_delay
		inc	de
		ld	(xpmp_channel\1.dataPos),de
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
		;ld	a,(xpmp_channel\1.delayLatch)	
		;add	a,(hl)
		ld	a,(hl)
		ld	(xpmp_channel\1.delayLatch),a		; Fractional part
		;ld	hl,0 
		;adc	hl,de
		ld	(xpmp_channel\1.delayLatch+1),de	; Whole part
		ret
	xpmp_\1_cmd_90_short_delay:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.delayLatch),a		; Fractional part
	ld	(xpmp_channel\1.delayLatch+1),de	; Whole part
	ret

	xpmp_\1_cmd_90_transp:
	ld	hl,(xpmp_tempw)
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	(xpmp_channel\1.dataPos),de
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.transpose),a
	ret
	
xpmp_\1_cmd_A0:
xpmp_\1_cmd_B0:
xpmp_\1_cmd_C0:
xpmp_\1_cmd_D0:
	ret

; Callback
xpmp_\1_cmd_E0:
	ld	hl,(xpmp_tempw)
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	(xpmp_channel\1.dataPos),de
	ld	a,c
	cp	CMD_CBOFF
	jr	z,xpmp_\1_cmd_E0_cboff
	cp	CMD_CBONCE
	jr	z,xpmp_\1_cmd_E0_cbonce
	cp	CMD_CBEVNT
	jr	z,xpmp_\1_cmd_E0_cbevnt
	.IF \1 < 3
	cp	CMD_DETUNE
	jr	z,xpmp_\1_cmd_E0_detune
	.ENDIF
	ret
	
	xpmp_\1_cmd_E0_cboff:
	ld	a,0
	ld	(xpmp_channel\1.cbEvnote),a
	ld	(xpmp_channel\1.cbEvnote+1),a
	ret
	
	xpmp_\1_cmd_E0_cbonce:
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
	
	; Every note
	xpmp_\1_cmd_E0_cbevnt:
	inc	hl
	ld	a,(hl)
	ld	de,xpmp_callback_tbl
	ld	h,0
	add	a,a
	ld	l,a
	add	hl,de
	ld	a,(hl)
	ld	(xpmp_channel\1.cbEvnote),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.cbEvnote+1),a
	ret

	.IF \1 < 3
	xpmp_\1_cmd_E0_detune:
	inc	hl
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_\1_cmd_E0_detune_pos
	ld	d,$FF
	xpmp_\1_cmd_E0_detune_pos:
	ld	(xpmp_channel\1.detune),de
	ret
	.ENDIF
	
xpmp_\1_cmd_F0:
	ld	hl,(xpmp_tempw)
	; Initialize volume macro	
	ld	a,c

	.IFNDEF XPMP_VMAC_NOT_USED
	cp	CMD_VOLMAC
	.IF \1 < 3
	jr	nz,xpmp_\1_cmd_F0_check_VIBMAC
	.ELSE
	jr	nz,xpmp_\1_cmd_F0_check_JMP
	.ENDIF
	inc	hl
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	a,(hl)
	ld	(xpmp_channel\1.vMac),a
	ld	(xpmp_channel\1.dataPos),de
	xpmp_\1_reset_v_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_v_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(xpmp_channel\1.vMacPtr),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.vMacPtr+1),a
	ld	hl,(xpmp_channel\1.vMacPtr)
	ld	a,(hl)
	ld	(xpmp_channel\1.volume),a
	ld	a,1
	ld	(xpmp_volChange),a	
	ld	a,1
	ld	(xpmp_channel\1.vMacPos),a
	ret
	.ENDIF
	
	.IF \1 < 3
	xpmp_\1_cmd_F0_check_VIBMAC:
	.IFNDEF XPMP_MPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_MP
	; Initialize vibrato macro
	cp	CMD_VIBMAC
	jr	nz,xpmp_\1_cmd_F0_check_SWPMAC
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	(xpmp_channel\1.dataPos),de	
	inc	hl
	ld	a,(hl)
	cp	EFFECT_DISABLED
	jr	z,xpmp_\1_cmd_F0_disable_VIBMAC
	ld	(xpmp_channel\1.mpMac),a
	xpmp_\1_reset_mp_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_MP_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	ld	(xpmp_channel\1.mpMacPtr),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.mpMacPtr+1),a
	ld	hl,(xpmp_channel\1.mpMacPtr)
	ld	a,(hl)
	ld	(xpmp_channel\1.mpMacDelay),a
	inc	hl
	ld	(xpmp_channel\1.mpMacPtr),hl
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.freqOffsLatch),a
	ld	a,0
	ld	(xpmp_channel\1.freqOffsLatch+1),a
	ld	(xpmp_channel\1.freqOffs),a
	ld	(xpmp_channel\1.freqOffs+1),a
	ret
	xpmp_\1_cmd_F0_disable_VIBMAC:
	ld	(xpmp_channel\1.mpMac),a
	ld	(xpmp_channel\1.freqOffs),a
	ld	(xpmp_channel\1.freqOffs+1),a
	ret
	.ENDIF
	.ENDIF
	
	; Initialize sweep macro
	xpmp_\1_cmd_F0_check_SWPMAC:
	.IFNDEF XPMP_EPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EP
	cp	CMD_SWPMAC
	jr	nz,xpmp_\1_cmd_F0_check_JMP
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	(xpmp_channel\1.dataPos),de	
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.epMac),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_\1_cmd_F0_disable_SWPMAC	
	xpmp_\1_reset_ep_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_EP_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(xpmp_channel\1.epMacPtr),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.epMacPtr+1),a
	ld	hl,(xpmp_channel\1.epMacPtr)
	ld	a,1
	ld	(xpmp_channel\1.epMacPos),a
	dec	a
	ld	(xpmp_channel\1.freqOffs+1),a
	ld	a,(hl)
	ld	(xpmp_channel\1.freqOffs),a
	bit	7,a
	ret	z
	ld	a,$FF
	ld	(xpmp_channel\1.freqOffs+1),a
	ret
	xpmp_\1_cmd_F0_disable_SWPMAC:
	ld	(xpmp_channel\1.epMac),a
	ld	(xpmp_channel\1.freqOffs),a
	ld	(xpmp_channel\1.freqOffs+1),a
	ret
	.ENDIF
	.ENDIF
	.ENDIF
	
	; Jump
	xpmp_\1_cmd_F0_check_JMP:
	cp	CMD_JMP
	jr	nz,xpmp_\1_cmd_F0_check_LOPCNT
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(xpmp_channel\1.dataPos),de
	ret

	; Set loop count
	xpmp_\1_cmd_F0_check_LOPCNT:
	cp	CMD_LOPCNT
	jr	nz,xpmp_\1_cmd_F0_check_DJNZ
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	(xpmp_channel\1.dataPos),de	
	inc	hl
	ld	a,(hl)
	ld	hl,(xpmp_channel\1.loopPtr)
	inc	hl
	ld	(hl),a
	ld	(xpmp_channel\1.loopPtr),hl
	ret

	; Decrease and jump if not zero
	xpmp_\1_cmd_F0_check_DJNZ:
	cp	CMD_DJNZ
	jr	nz,xpmp_\1_cmd_F0_check_APMAC2
	ld	hl,(xpmp_channel\1.loopPtr)
	dec	(hl)
	jr	z,xpmp_\1_cmd_F0_DJNZ_Z		; Check if the counter has reached zero
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(xpmp_channel\1.dataPos),de
	ret
	xpmp_\1_cmd_F0_DJNZ_Z:
	dec	hl
	ld	(xpmp_channel\1.loopPtr),hl
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	inc	de
	ld	(xpmp_channel\1.dataPos),de	
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_\1_cmd_F0_check_APMAC2:
	.IFNDEF XPMP_EN2MAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN2
	cp	CMD_APMAC2
	jr	nz,xpmp_\1_cmd_F0_check_ARPMAC
	inc	hl
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	a,(hl)
	ld	(xpmp_channel\1.en2Mac),a
	ld	(xpmp_channel\1.dataPos),de
	xpmp_\1_reset_en2_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_EN_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(xpmp_channel\1.en2MacPtr),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.en2MacPtr+1),a
	ld	hl,(xpmp_channel\1.en2MacPtr)
	ld	a,(hl)
	ld	(xpmp_channel\1.noteOffs),a
	ld	a,1
	ld	(xpmp_channel\1.en2MacPos),a
	dec	a
	ld	(xpmp_channel\1.enMac),a
	ret
	.ENDIF
	.ENDIF
	
	; Initialize non-cumulative arpeggio macro
	xpmp_\1_cmd_F0_check_ARPMAC:
	.IFNDEF XPMP_ENMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN
	cp	CMD_ARPMAC
	jr	nz,xpmp_\1_cmd_F0_check_PANMAC
	inc	hl
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	a,(hl)
	ld	(xpmp_channel\1.enMac),a
	ld	(xpmp_channel\1.dataPos),de
	xpmp_\1_reset_en_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_EN_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(xpmp_channel\1.enMacPtr),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.enMacPtr+1),a
	ld	hl,(xpmp_channel\1.enMacPtr)
	ld	a,(hl)
	ld	(xpmp_channel\1.noteOffs),a
	ld	a,1
	ld	(xpmp_channel\1.enMacPos),a
	dec	a
	ld	(xpmp_channel\1.en2Mac),a
	ret
	.ENDIF
	.ENDIF
	
	xpmp_\1_cmd_F0_check_PANMAC:
	cp	CMD_PANMAC
	jr	nz,xpmp_\1_cmd_F0_check_J1
	inc	hl
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	(xpmp_channel\1.dataPos),de
	ld	a,(hl)
	ld	(xpmp_channel\1.csMac),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_\1_cs_off
	xpmp_\1_reset_cs_mac:
	and	$7F
	dec	a
	add	a,a
	ld	hl,xpmp_CS_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(xpmp_channel\1.csMacPtr),a
	inc	hl
	ld	a,(hl)
	ld	(xpmp_channel\1.csMacPtr+1),a
	ld	hl,(xpmp_channel\1.csMacPtr)
	ld	a,1
	ld	(xpmp_channel\1.csMacPos),a
	ld	a,(hl)
	xpmp_\1_write_pan:
	bit	7,a
	jr	z,xpmp_\1_reset_cs_pos
	ld	a,(xpmp_pan)
	res	\1,a
	set	4+\1,a
	ld	(xpmp_pan),a
	out	($06),a
	ret
	xpmp_\1_reset_cs_pos:
	cp	0
	jr	nz,xpmp_\1_reset_cs_right
	xpmp_\1_cs_off:
	ld	a,(xpmp_pan)
	or	$11<<\1
	ld	(xpmp_pan),a
	out	($06),a
	ret
	xpmp_\1_reset_cs_right:
	ld	a,(xpmp_pan)
	res	4+\1,a
	set	\1,a
	ld	(xpmp_pan),a
	out	($06),a
	ret

	; Jump if one
	xpmp_\1_cmd_F0_check_J1:
	cp	CMD_J1
	jr	nz,xpmp_\1_cmd_F0_check_END
	ld	hl,(xpmp_channel\1.loopPtr)
	ld	a,(hl)
	cp	1
	jr	nz,xpmp_\1_cmd_F0_J1_N1		; Check if the counter has reached 1
	dec	hl
	ld	(xpmp_channel\1.loopPtr),hl
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(xpmp_channel\1.dataPos),de
	ret
	xpmp_\1_cmd_F0_J1_N1:
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	inc	de
	ld	(xpmp_channel\1.dataPos),de	
	
	xpmp_\1_cmd_F0_check_END:
	cp	CMD_END
	jr	nz,xpmp_\1_cmd_F0_not_found
	ld	a,CMD_END
	ld	(xpmp_channel\1.note),a		; Playback of this channel should end
	ld	a,2
	ld	(xpmp_freqChange),a		; The command-reading loop should exit	
	ret

	xpmp_\1_cmd_F0_not_found:
	ld	de,(xpmp_channel\1.dataPos)
	inc	de
	ld	(xpmp_channel\1.dataPos),de	
	
	ret
.endm	


xpmp_call_hl:
	jp (hl)
	


.MACRO XPMP_UPDATE_FUNC 

xpmp_\1_update:
	ld	a,0
	ld	(xpmp_freqChange),a
	ld	(xpmp_volChange),a
	
	ld	a,(xpmp_channel\1.note)
	cp	CMD_END
	ret	z				; Playback has ended for this channel - all processing should be skipped
	
	ld 	hl,(xpmp_channel\1.delay+1)	; Decrement the whole part of the delay and check if it has reached zero
	dec	hl
	ld	a,h
	or	l
	jp 	nz,xpmp_\1_update_effects	
	
	; Loop here until a note/rest or END command is read (signaled by xpmp_freqChange == 2)
	xpmp_\1_update_read_cmd:
	ld	hl,(xpmp_channel\1.dataPtr)
	ld 	de,(xpmp_channel\1.dataPos)
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
	ld	de,xpmp_\1_jump_tbl	
	add	hl,de
	ld	e,(hl)				; HL = jump_tbl + (command >> 4)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	call	xpmp_call_hl

	ld	hl,(xpmp_channel\1.dataPos)
	inc	hl
	ld	(xpmp_channel\1.dataPos),hl

	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,xpmp_update_\1_freq_change
	jp 	xpmp_\1_update_read_cmd
	
	xpmp_update_\1_freq_change:	
	ld	a,(xpmp_channel\1.note)
	cp	CMD_REST
	jp	z,xpmp_\1_rest
	cp	CMD_REST2
	ret	z
	cp	CMD_END
	jp	z,xpmp_\1_rest
	ld	b,a
	ld	a,(xpmp_channel\1.noteOffs)
	ld	d,a
	ld	a,(xpmp_channel\1.transpose)
	add	a,d
	add	a,b
	.IF \1 < 3
	ld	b,a
	ld	a,(xpmp_channel\1.octave)
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
	ld	de,(xpmp_channel\1.freqOffs)
	and	a
	sbc	hl,de
	ld	de,(xpmp_channel\1.detune)
	and	a
	sbc	hl,de
	JL_IMM16 $03EF,xpmp_updqte_\1_lb_ok
	ld	hl,(xpmp_freq_tbl+18)
	jp	xpmp_update_\1_freq_ok
	xpmp_updqte_\1_lb_ok:
	JGE_IMM16 $001C,xpmp_update_\1_freq_ok
	ld	hl,$001C
	xpmp_update_\1_freq_ok:
	ld	a,l
	and	$0F
	or	\1<<5|$80
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
	.ELSE
	and	3
	ld	b,a
	ld	a,(xpmp_channel3.duty)
	or	b
	or	$E0
	out	(XPMP_SN_PORT),a
	xor	$E0
	out	(XPMP_SN_PORT),a
	.ENDIF
	ld	a,(xpmp_lastNote)
	cp	CMD_REST
	jr	nz,xpmp_\1_update_set_vol2
	jp	xpmp_\1_update_set_vol3

	xpmp_\1_update_set_vol:
	ld	a,(xpmp_channel\1.note)
	cp	CMD_REST
	jr	z,xpmp_\1_rest
	xpmp_\1_update_set_vol2:
	; Update the volume if it has changed
	ld	a,(xpmp_volChange)
	cp	0
	ret	z
	xpmp_\1_update_set_vol3:
	ld	a,(xpmp_channel\1.volume)
	;ld	b,a
	;ld	a,(xpmp_channel\1.volOffs)
	;add	a,b
	;ld	b,a
	;and	$F0
	;jr	z,xpmp_\1_vol_ok
	;bit	7,a
	;jr	z,xpmp_\1_vol_too_large
	;ld	b,$00
	;jp	xpmp_\1_vol_ok
	;xpmp_\1_vol_too_large:
	;ld	b,$0F
	;xpmp_\1_vol_ok:
	;ld	a,b
	xor	$9F|(\1<<5)
	out	(XPMP_SN_PORT),a
	res	7,a
	out	(XPMP_SN_PORT),a
	xpmp_update_\1_no_vol_change:
	ret
	
	; Mute the channel
	xpmp_\1_rest:
	ld	a,$9F|(\1<<5)
	out	(XPMP_SN_PORT),a
	res	7,a
	out	(XPMP_SN_PORT),a
	ret

	xpmp_\1_update_effects:
	ld 	(xpmp_channel\1.delay+1),hl

	call	xpmp_\1_step_v_frame
	call	xpmp_\1_step_en_frame
	call	xpmp_\1_step_en2_frame
	call	xpmp_\1_step_ep_frame
	call	xpmp_\1_step_mp_frame
	call	xpmp_\1_step_cs_frame

	ld	a,(xpmp_freqChange)
	cp	0
	jp	nz,xpmp_update_\1_freq_change
	jp	xpmp_\1_update_set_vol
	ret
	
	xpmp_\1_step_v_frame:
	ld 	a,(xpmp_channel\1.vMac)
	bit	7,a
	ret	nz
	xpmp_\1_step_v:
	.IFNDEF XPMP_VMAC_NOT_USED
	; Volume macro
	ld 	a,(xpmp_channel\1.vMac)
	cp 	EFFECT_DISABLED
	jr 	z,xpmp_update_\1_v_done 
	xpmp_update_\1_v:
	ld 	hl,(xpmp_channel\1.vMacPtr)
	ld	a,1
	ld	(xpmp_volChange),a
	ld 	d,0
	ld 	a,(xpmp_channel\1.vMacPos)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_\1_v_loop
	ld	(xpmp_channel\1.volume),a 	; Set a new volume
	inc	de				; Increase the position
	ld	a,e
	ld	(xpmp_channel\1.vMacPos),a
	jp	xpmp_update_\1_v_done
	xpmp_update_\1_v_loop:
	ld	a,(xpmp_channel\1.vMac)		; Which volume macro are we using?
	and	$7F
	dec	a
	ld	e,a
	sla	e				; Each pointer is two bytes
	ld	bc,xpmp_v_mac_loop_tbl
	ld	hl,xpmp_channel\1.vMacPtr
	ex	de,hl
	add	hl,bc 				; HL = xpmp_vMac_loop_tbl + (vMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a				; Store in xpmp_\1_vMac_ptr
	inc 	de	
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(xpmp_channel\1.vMacPos),a
	ld	hl,(xpmp_channel\1.vMacPtr)
	ld	a,(hl)
	ld	(xpmp_channel\1.volume),a
	xpmp_update_\1_v_done:
	.ENDIF
	ret

	xpmp_\1_step_en_frame:
	ld 	a,(xpmp_channel\1.enMac)
	bit	7,a
	ret	nz
	xpmp_\1_step_en:
	.IFNDEF XPMP_ENMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN
	; Cumulative arpeggio
	ld 	a,(xpmp_channel\1.enMac)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_\1_EN_done
	xpmp_update_\1_EN:
	ld	a,(xpmp_freqChange)
	cp	2
	jr	z,+
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	+:
	ld	hl,(xpmp_channel\1.enMacPtr)
	ld 	d,0
	ld 	a,(xpmp_channel\1.enMacPos)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_\1_EN_loop
	ld	b,a
	ld	a,(xpmp_channel\1.noteOffs)
	add	a,b
	ld	(xpmp_channel\1.noteOffs),a	; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(xpmp_channel\1.enMacPos),a
	jp	xpmp_update_\1_EN_done		
	xpmp_update_\1_EN_loop:
	ld	a,(xpmp_channel\1.enMac)	; Which arpeggio macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,xpmp_channel\1.enMacPtr
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
	ld	(xpmp_channel\1.enMacPos),a	; Reset position
	ld	hl,(xpmp_channel\1.enMacPtr)
	ld	b,(hl)
	ld	a,(xpmp_channel\1.noteOffs)
	add	a,b
	ld	(xpmp_channel\1.noteOffs),a	; Reset note offset
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
	ld	hl,(xpmp_channel\1.en2MacPtr)
	ld 	d,0
	ld 	a,(xpmp_channel\1.en2MacPos)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
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
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,xpmp_channel\1.en2MacPtr
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
	ld	(xpmp_channel\1.en2MacPos),a	; Reset position
	ld	hl,(xpmp_channel\1.en2MacPtr)
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
	.IF \1 < 3
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
	ld	hl,(xpmp_channel\1.epMacPtr)
	ld 	d,0
	ld 	a,(xpmp_channel\1.epMacPos)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
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
	ld	hl,(xpmp_channel\1.freqOffs)
	add	hl,de
	ld	(xpmp_channel\1.freqOffs),hl
	jp	xpmp_update_\1_EP_done		
	xpmp_update_\1_EP_loop:
	ld	a,(xpmp_channel\1.epMac)	; Which sweep macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,xpmp_channel\1.epMacPtr
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
	ld	(xpmp_channel\1.epMacPos),a	; Reset position
	ld	hl,(xpmp_channel\1.epMacPtr)
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_update_\1_pos_freq_2
	ld	d,$FF
	xpmp_update_\1_pos_freq_2:
	ld	hl,(xpmp_channel\1.freqOffs)
	add	hl,de
	ld	(xpmp_channel\1.freqOffs),hl
	xpmp_update_\1_EP_done:
	.ENDIF
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
	ld	hl,(xpmp_channel\1.mpMacPtr)
	ld	de,(xpmp_channel\1.freqOffsLatch) ; Load the volume offset from the latch, then negate the latch
	ld	(xpmp_channel\1.freqOffs),de
	and	a				; Clear carry
	ld 	a,(hl)				; Reload the vibrato delay
	ld	hl,0
	sbc	hl,de
	ld	(xpmp_channel\1.freqOffsLatch),hl
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
	ld	hl,(xpmp_channel\1.csMacPtr)
	ld 	d,0
	ld 	a,(xpmp_channel\1.csMacPos)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
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
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	hl,xpmp_channel\1.csMacPtr
	ld	bc,xpmp_CS_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_CS_mac_loop_tbl + (csMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a
	inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(xpmp_channel\1.csMacPos),a	; Reset position
	ld	hl,(xpmp_channel\1.csMacPtr)
	ld	b,(hl)
	xpmp_update_\1_CS_do_write:
	ld	a,b
	call	xpmp_\1_write_pan
	xpmp_update_\1_CS_done:
	ret
	
 .ENDM


;######################################################################################################################


.IFDEF XPMP_USES_AY

; Note / rest
xpmp_ay_cmd_00:
xpmp_ay_cmd_60:
	ld	hl,(xpmp_tempw)

	ld	a,c
	cp	CMD_VOLUP
	jr	nz,xpmp_ay_cmd_00_2
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	ld	a,(ix+13)
	inc	hl
	add	a,(hl)
	ld	(ix+13),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	a,EFFECT_DISABLED
	ld	(ix+22),a			; Volume set overrides volume macros
	ret
	
xpmp_ay_cmd_00_2:
	ld	a,(ix+7)
	ld	(xpmp_lastNote),a
	ld	a,c
	and	$0F
	ld	(ix+7),a
	ld	a,c
	and	$F0
	cp	CMD_NOTE2
	jr	z,xpmp_ay_cmd_00_std_delay	
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_ay_cmd_00_short_note
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
		jp 	xpmp_ay_cmd_00_got_delay
	xpmp_ay_cmd_00_short_note:
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
	jp 	xpmp_ay_cmd_00_got_delay
	xpmp_ay_cmd_00_std_delay:		; Use delay set by last CMD_LEN
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
	xpmp_ay_cmd_00_got_delay:
	ld	a,2
	ld	(xpmp_freqChange),a
	ld	a,(ix+7)
	cp	CMD_REST	
	ret	z				; If this was a rest command we can return now
	cp	CMD_REST2
	ret	z
	.IFNDEF XPMP_VMAC_NOT_USED
	;ld	a,(ix+22)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_ay_reset_v_mac	; Reset effects as needed..
	RESET_EFFECT 22,ay,v
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	;ld	a,(ix+26)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_ay_reset_en_mac
	RESET_EFFECT 26,ay,en
	.ENDIF
	.IFNDEF XPMP_EN2MAC_NOT_USED
	;ld	a,(ix+30)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_ay_reset_en2_mac
	RESET_EFFECT 30,ay,en2
	.ENDIF
	.IFNDEF XPMP_MPMAC_NOT_USED
	;ld	a,(ix+38)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_ay_reset_mp_mac
	RESET_EFFECT 38,ay,mp
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	;ld	a,(ix+34)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_ay_reset_ep_mac
	RESET_EFFECT 34,ay,ep
	.ENDIF
	ret
	
; Set octave
xpmp_ay_cmd_10:
	ld	a,c 
	and	$0F
	ld	b,a
	add	a,a
	add	a,a
	sla	b
	sla	b
	sla	b
	add	a,b				; A = (C & $0F) * 12
	ld	(ix+9),a
	ret
	
xpmp_ay_cmd_20:
	ld	a,c
	and	1
	ld	b,a
	ld	a,c
	and	2
	sla	a
	sla	a
	or	b				; Tone/noise enable flags
	ld	b,a
	ld	d,$84
	rrc	b
	ld	a,(xpmp_chnum)
	inc	a
	xpmp_ay_cmd_20_shift:			; Shift left by the channel number
	rlc	b
	rlc	d
	dec	a
	jr	nz,xpmp_ay_cmd_20_shift
	ld	a,d
	ld	d,a
	ld	a,(xpmp_ayen)
	or	d				; Clear the tone/noise enable flags for this channel
	ld	d,a
	ld	a,b
	xor	$FF
	and	d
	ld	(xpmp_ayen),a
	.IFDEF XPMP_CPC
	push	bc
	ld	c,7
	ld	a,(xpmp_ayen)
	call	write_ay_cpc
	pop	bc
	.ELSE
	.IFDEF XPMP_ZXS
	push	bc
	ld	c,7
	ld	a,(xpmp_ayen)
	call	write_ay_zxs
	pop	bc
	.ELSE
	ld	a,7
	out	(XPMP_AY_ADDR),a
	ld	a,(xpmp_ayen)
	out	(XPMP_AY_DATA),a
	.ENDIF
	.ENDIF
	ld	a,c
	srl	a
	and	2
	ld	b,a
	srl	b
	or	b
	sla	a
	sla	a
	sla	a
	sla	a
	ld	(ix+15),a			; envelope on/off
	ret

; Set volume (short)
xpmp_ay_cmd_30:
	ld	a,c
	and	$0F
	ld	(ix+13),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	a,EFFECT_DISABLED
	ld	(ix+22),a			; Volume set overrides volume macros
	ret

; Octave up + note	
xpmp_ay_cmd_40:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+9)
	add	a,12
	ld	(ix+9),a
	ld 	a,c
	add 	a,$20
	ld 	c,a
	jp	xpmp_ay_cmd_00_2

; Octave down + note
xpmp_ay_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+9)
	sub	12
	ld	(ix+9),a
	ld 	a,c
	add 	a,$10
	ld 	c,a
	jp	xpmp_ay_cmd_00_2

xpmp_ay_cmd_70:
xpmp_ay_cmd_80:
	ret

; Turn off arpeggio macro
xpmp_ay_cmd_90:
	ld	a,c
	cp	CMD_JSR
	jr	z,xpmp_ay_cmd_90_jsr
	cp	CMD_RTS
	jr	z,xpmp_ay_cmd_90_rts
	cp	CMD_LEN
	jr	z,xpmp_ay_cmd_90_len
	cp	CMD_HWES
	jp	z,xpmp_ay_cmd_90_hwes
	cp	CMD_HWNS
	jp	z,xpmp_ay_cmd_90_hwns
	cp	CMD_TRANSP
	jp	z,xpmp_ay_cmd_90_transp
	
	ld	hl,(xpmp_tempw)
	ld	a,0
	ld	(ix+26),a
	ld	(ix+30),a
	ld	(ix+8),a
	ret

	; Jump to pattern
	xpmp_ay_cmd_90_jsr:
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
	xpmp_ay_cmd_90_rts:
	ld	a,(ix+48)
	ld	(ix+0),a
	ld	a,(ix+49)
	ld	(ix+1),a
	ld	a,(ix+50)
	ld	(ix+2),a
	ld	a,(ix+51)
	ld	(ix+3),a
	ret

	xpmp_ay_cmd_90_len:
	ld	hl,(xpmp_tempw)
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_ay_cmd_90_short_delay
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
	xpmp_ay_cmd_90_short_delay:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(hl)
	ld	(ix+52),a	; Fractional part
	ld	(ix+53),e	; Whole part
	ld	(ix+54),d	; ...
	ret

	; Envelope speed
	xpmp_ay_cmd_90_hwes:
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d
	inc	hl
	.IFDEF XPMP_CPC
	ld	c,11
	ld	a,(hl)
	call	write_ay_cpc
	inc	hl
	ld	c,12
	ld	a,(hl)
	call	write_ay_cpc
	.ELSE
	.IFDEF XPMP_ZXS
	ld	c,11
	ld	a,(hl)
	call	write_ay_zxs
	inc	hl
	ld	c,12
	ld	a,(hl)
	call	write_ay_zxs
	.ELSE
	ld	a,11
	out	(XPMP_AY_ADDR),a
	ld	a,(hl)
	out	(XPMP_AY_DATA),a
	inc	hl
	ld	a,12
	out	(XPMP_AY_ADDR),a
	ld	a,(hl)
	out	(XPMP_AY_DATA),a
	.ENDIF
	.ENDIF
	ret

	; Noise speed (inverted period)
	xpmp_ay_cmd_90_hwns:
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d	
	inc	hl
	.IFDEF XPMP_CPC
	ld	c,6
	ld	a,(hl)
	call	write_ay_cpc
	.ELSE
	.IFDEF XPMP_ZXS
	ld	c,6
	ld	a,(hl)
	call	write_ay_zxs
	.ELSE
	ld	a,6
	out	(XPMP_AY_ADDR),a
	ld	a,(hl)
	out	(XPMP_AY_DATA),a
	.ENDIF
	.ENDIF
	ret

	xpmp_ay_cmd_90_transp:
	ld	hl,(xpmp_tempw)
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d
	inc	hl
	ld	a,(hl)
	ld	(ix+59),a
	ret

xpmp_ay_cmd_A0:
xpmp_ay_cmd_B0:
xpmp_ay_cmd_C0:
xpmp_ay_cmd_D0:
	ret
	

; Callback
xpmp_ay_cmd_E0:
	ld	hl,(xpmp_tempw)
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	ld	a,c
	cp	CMD_CBOFF
	jr	z,xpmp_ay_cmd_E0_cboff
	cp	CMD_CBONCE
	jr	z,xpmp_ay_cmd_E0_cbonce
	cp	CMD_CBEVNT
	jr	z,xpmp_ay_cmd_E0_cbevnt
	cp	CMD_DETUNE
	jr	z,xpmp_ay_cmd_E0_detune
	cp	CMD_HWTE
	jr	z,xpmp_ay_cmd_E0_hwte
	ret
	
	xpmp_ay_cmd_E0_cboff:
	ret
	
	xpmp_ay_cmd_E0_cbonce:
	ret
	
	; Every note
	xpmp_ay_cmd_E0_cbevnt:
	ret

	xpmp_ay_cmd_E0_detune:
	inc	hl
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_ay_cmd_E0_detune_pos
	ld	d,$FF
	xpmp_ay_cmd_E0_detune_pos:
	ld	(ix+20),e
	ld	(ix+21),d
	ret

	; Envelope shape
	xpmp_ay_cmd_E0_hwte:
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d	
	inc	hl
	.IFDEF XPMP_CPC
	ld	c,13
	ld	a,(hl)
	ld	(ix+14),a
	call	write_ay_cpc
	.ELSE
	.IFDEF XPMP_ZXS
	ld	c,13
	ld	a,(hl)
	ld	(ix+14),a
	call	write_ay_zxs
	.ELSE
	ld	a,13
	out	(XPMP_AY_ADDR),a
	ld	a,(hl)
	ld	(ix+14),a
	out	(XPMP_AY_DATA),a
	.ENDIF
	.ENDIF
	ret
	
xpmp_ay_cmd_F0:
	ld	hl,(xpmp_tempw)
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	; Initialize volume macro	
	ld	a,c

	.IFNDEF XPMP_VMAC_NOT_USED
	cp	CMD_VOLMAC
	jr	nz,xpmp_ay_cmd_F0_check_VIBMAC
	inc	hl
	ld	a,(hl)
	ld	(ix+22),a
	xpmp_ay_reset_v_mac:
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
	xpmp_ay_cmd_F0_check_VIBMAC:
	.IFNDEF XPMP_MPMAC_NOT_USED
	; Initialize vibrato macro
	cp	CMD_VIBMAC
	jr	nz,xpmp_ay_cmd_F0_check_SWPMAC
	inc	hl
	ld	a,(hl)
	cp	EFFECT_DISABLED
	jr	z,xpmp_ay_cmd_F0_disable_VIBMAC
	ld	(ix+38),a
	xpmp_ay_reset_mp_mac:
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
	xpmp_ay_cmd_F0_disable_VIBMAC:
	ld	(ix+38),a
	ld	(ix+16),a
	ld	(ix+17),a
	ret
	.ENDIF
	
	; Initialize sweep macro
	xpmp_ay_cmd_F0_check_SWPMAC:
	.IFNDEF XPMP_EPMAC_NOT_USED
	cp	CMD_SWPMAC
	jr	nz,xpmp_ay_cmd_F0_check_JMP
	inc	hl
	ld	a,(hl)
	ld	(ix+34),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_ay_cmd_F0_disable_SWPMAC	
	xpmp_ay_reset_ep_mac:
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
	xpmp_ay_cmd_F0_disable_SWPMAC:
	ld	(ix+34),a
	ld	(ix+16),a
	ld	(ix+17),a
	ret
	.ENDIF
	
	; Jump
	xpmp_ay_cmd_F0_check_JMP:
	cp	CMD_JMP
	jr	nz,xpmp_ay_cmd_F0_check_LOPCNT
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+2),e
	ld	(ix+3),d
	ret

	; Set loop count
	xpmp_ay_cmd_F0_check_LOPCNT:
	cp	CMD_LOPCNT
	jr	nz,xpmp_ay_cmd_F0_check_DJNZ
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
	xpmp_ay_cmd_F0_check_DJNZ:
	cp	CMD_DJNZ
	jr	nz,xpmp_ay_cmd_F0_check_APMAC2
	ld	l,(ix+44)
	ld	h,(ix+45)
	dec	(hl)
	jr	z,xpmp_ay_cmd_F0_DJNZ_Z	; Check if the counter has reached zero
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+2),e
	ld	(ix+3),d
	ret
	xpmp_ay_cmd_F0_DJNZ_Z:
	dec	hl
	ld	(ix+44),l
	ld	(ix+45),h
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_ay_cmd_F0_check_APMAC2:
	.IFNDEF XPMP_EN2MAC_NOT_USED
	cp	CMD_APMAC2
	jr	nz,xpmp_ay_cmd_F0_check_ARPMAC
	inc	hl
	ld	a,(hl)
	ld	(ix+30),a
	xpmp_ay_reset_en2_mac:
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
	xpmp_ay_cmd_F0_check_ARPMAC:
	.IFNDEF XPMP_ENMAC_NOT_USED
	cp	CMD_ARPMAC
	jr	nz,xpmp_ay_cmd_F0_check_PANMAC
	inc	hl
	ld	a,(hl)
	ld	(ix+26),a
	xpmp_ay_reset_en_mac:
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
	
	xpmp_ay_cmd_F0_check_PANMAC:
	cp	CMD_PANMAC
	jr	nz,xpmp_ay_cmd_F0_check_J1
	inc	hl
	;ld	a,(hl)
	ld	a,0
	;ld	(xpmp_channel\1.csMac),a
	ret

	; Jump if one
	xpmp_ay_cmd_F0_check_J1:
	cp	CMD_J1
	jr	nz,xpmp_ay_cmd_F0_check_END
	ld	l,(ix+44)
	ld	h,(ix+45)
	ld	a,(hl)
	cp	1
	jr	nz,xpmp_ay_cmd_F0_J1_N1		; Check if the counter has reached 1
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
	xpmp_ay_cmd_F0_J1_N1:
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	ret
	
	xpmp_ay_cmd_F0_check_END:
	cp	CMD_END
	jr	nz,xpmp_ay_cmd_F0_not_found
	ld	a,CMD_END
	ld	(ix+7),a			; Playback of this channel should end
	ld	a,2
	ld	(xpmp_freqChange),a		; The command-reading loop should exit	
	ret

	xpmp_ay_cmd_F0_not_found:
	ret
	

; C=reg, A=data
write_ay_cpc:
	ld b,$f4
	out (c),c
	ld bc,$f6c0
	out (c),c
	ld bc,$f600
	out (c),c
	ld b,$f4
	out (c),a
	ld bc,$f680
	out (c),c
	ld bc,$f600
	out (c),c
	ret


; C=reg, A=data
write_ay_zxs:
	ld e,c
	ld bc,$fffd
	out (c),e
	ld bc,$bffd
	out (c),a
	ret
	
	
xpmp_update_ay:
	ld	(xpmp_chnum),a
	add	a,a
	ld	e,a
	ld	d,0
	ld	hl,xpmp_ay_channel_ptr_tbl
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
	
	ld	a,(ix+7)
	cp	CMD_END
	ret	z				; Playback has ended for this channel - all processing should be skipped
	
	ld 	l,(ix+5)			; Decrement the whole part of the delay and check if it has reached zero
	ld	h,(ix+6)
	dec	hl
	ld	a,h
	or	l
	jp 	nz,xpmp_update_ay_effects	
	
	; Loop here until a note/rest or END command is read (signaled by xpmp_freqChange == 2)
	xpmp_update_ay_read_cmd:
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
	ld	de,xpmp_ay_jump_tbl	
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
	jr	z,xpmp_update_ay_freq_change
	jp 	xpmp_update_ay_read_cmd
	
	xpmp_update_ay_freq_change:
	ld	a,(ix+7)
	cp	CMD_REST
	jp	z,xpmp_update_ay_rest
	cp	CMD_REST2
	ret	z
	cp	CMD_END
	jp	z,xpmp_update_ay_rest
	ld	b,a
	ld	a,(ix+8)	; noteOffs
	ld	d,(ix+59)	; transpose
	add	a,d
	add	a,b
	ld	b,a
	ld	a,(ix+9)
	add	a,b
	ld	hl,ay_freq_tbl
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
	JL_IMM16 $0FFF,xpmp_update_ay_lb_ok
	ld	hl,(ay_freq_tbl+18)
	jp	xpmp_update_ay_freq_ok
	xpmp_update_ay_lb_ok:
	JGE_IMM16 $001C,xpmp_update_ay_freq_ok
	ld	hl,$001C
	xpmp_update_ay_freq_ok:
	ex	de,hl
	ld	a,(xpmp_chnum)
	add	a,a
	.IFDEF XPMP_CPC
	ld	c,a
	push	bc
	ld	a,e
	call	write_ay_cpc
	pop 	bc
	inc	c
	ld	a,d
	call	write_ay_cpc
	.ELSE
	.IFDEF XPMP_ZXS
	ld	c,a
	push	bc
	ld	a,e
	call	write_ay_zxs
	pop 	bc
	inc	c
	ld	a,d
	call	write_ay_zxs
	.ELSE
	out	(XPMP_AY_ADDR),a
	ld	b,a
	ld	a,e
	out	(XPMP_AY_DATA),a
	ld	a,b
	inc	a
	out	(XPMP_AY_ADDR),a
	ld	a,d
	out	(XPMP_AY_DATA),a
	.ENDIF
	.ENDIF
	
	; Restart envelope generator
	.IFDEF XPMP_CPC
	ld	c,13
	ld	a,(ix+14)
	call	write_ay_cpc
	.ELSE
	.IFDEF XPMP_ZXS
	ld	c,13
	ld	a,(ix+14)
	call	write_ay_zxs
	.ELSE
	ld	a,13
	out	(XPMP_AY_ADDR),a
	ld	a,(ix+14)
	out	(XPMP_AY_DATA),a
	.ENDIF
	.ENDIF
	
	ld	a,(xpmp_lastNote)
	cp	CMD_REST
	jr	nz,xpmp_update_ay_set_vol2
	jp	xpmp_update_ay_set_vol3

	xpmp_update_ay_set_vol:
	ld	a,(ix+7)
	cp	CMD_REST
	jr	z,xpmp_update_ay_rest
	xpmp_update_ay_set_vol2:
	; Update the volume if it has changed
	ld	a,(xpmp_volChange)
	cp	0
	ret	z
	xpmp_update_ay_set_vol3:
	ld	a,(xpmp_chnum)
	.IFDEF XPMP_CPC
	add	a,8
	ld	c,a
	ld	a,(ix+13)
	or	(ix+15)
	call	write_ay_cpc
	.ELSE
	.IFDEF XPMP_ZXS
	add	a,8
	ld	c,a
	ld	a,(ix+13)
	or	(ix+15)
	call	write_ay_zxs
	.ELSE
	add	a,8
	out	(XPMP_AY_ADDR),a
	ld	a,(ix+13)		; volume
	or	(ix+15)			; envelope on/off
	out	(XPMP_AY_DATA),a
	.ENDIF
	.ENDIF
	xpmp_update_ay_no_vol_change:
	ret
	
	; Mute the channel
	xpmp_update_ay_rest:
	ld	a,(xpmp_chnum)
	.IFDEF XPMP_CPC
	add	a,8
	ld	c,a
	ld	a,(ix+15)
	call	write_ay_cpc
	.ELSE
	.IFDEF XPMP_ZXS
	add	a,8
	ld	c,a
	ld	a,(ix+15)
	call	write_ay_zxs
	.ELSE
	add	a,8
	out	(XPMP_AY_ADDR),a
	ld	a,(ix+15)		; envelope on/off
	out	(XPMP_AY_DATA),a
	.ENDIF
	.ENDIF
	ret
	
	xpmp_update_ay_effects:
	ld 	(ix+5),l
	ld	(ix+6),h

	call	xpmp_ay_step_v_frame
	call	xpmp_ay_step_en_frame
	call	xpmp_ay_step_en2_frame
	call	xpmp_ay_step_ep_frame
	call	xpmp_ay_step_mp_frame

	xpmp_update_ay_effects_done:
	ld	a,(xpmp_freqChange)
	cp	0
	jp	nz,xpmp_update_ay_freq_change
	jp	xpmp_update_ay_set_vol
	ret	


	xpmp_ay_step_v_frame:
	bit 	7,(ix+22)
	ret	nz
	xpmp_ay_step_v:		
	.IFNDEF XPMP_VMAC_NOT_USED
	; Volume macro
	ld 	a,(ix+22)
	cp 	EFFECT_DISABLED
	jr 	z,xpmp_update_ay_v_done 
	xpmp_update_ay_v:
	ld 	l,(ix+23)
	ld	h,(ix+24)
	ld	a,1
	ld	(xpmp_volChange),a
	ld 	d,0
	ld 	a,(ix+25)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ay_v_loop
	ld	(ix+13),a		 	; Set a new volume
	inc	de				; Increase the position
	ld	a,e
	ld	(ix+25),a
	jp	xpmp_update_ay_v_done
	xpmp_update_ay_v_loop:
	ld	a,(ix+22)			; Which volume macro are we using?
	dec	a
	ld	e,a
	sla	e				; Each pointer is two bytes
	ld	bc,xpmp_v_mac_loop_tbl
	ex	de,hl
	add	hl,bc 				; HL = xpmp_vMac_loop_tbl + (vMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+23),a			; Store in xpmp_\1_vMac_ptr
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+24),a
	ld	a,1
	ld	(ix+25),a
	ld	l,(ix+23)
	ld	h,(ix+24)
	ld	a,(hl)
	ld	(ix+13),a
	xpmp_update_ay_v_done:
	.ENDIF
	ret

	xpmp_ay_step_en_frame:
	bit 	7,(ix+26)
	ret	nz
	xpmp_ay_step_en:		
	.IFNDEF XPMP_ENMAC_NOT_USED
	; Cumulative arpeggio
	ld 	a,(ix+26)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ay_EN_done
	xpmp_update_ay_EN:
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
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ay_EN_loop
	ld	b,a
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+29),a
	jp	xpmp_update_ay_EN_done		
	xpmp_update_ay_EN_loop:
	ld	a,(ix+26)			; Which arpeggio macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	bc,xpmp_EN_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+27),a
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+28),a
	ld	a,1
	ld	(ix+29),a			; Reset position
	ld	l,(ix+27)
	ld	h,(ix+28)
	ld	b,(hl)
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Reset note offset
	xpmp_update_ay_EN_done:
	.ENDIF
	ret

	xpmp_ay_step_en2_frame:
	bit 	7,(ix+30)
	ret	nz
	xpmp_ay_step_en2:		
	.IFNDEF XPMP_EN2MAC_NOT_USED
	; Non-cumulative arpeggio
	ld 	a,(ix+30)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ay_EN2_done
	xpmp_update_ay_EN2:
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
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ay_EN2_loop
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+33),a
	jp	xpmp_update_ay_EN2_done		
	xpmp_update_ay_EN2_loop:
	ld	a,(ix+30)			; Which arpeggio macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	bc,xpmp_EN_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (en2Mac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+31),a
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+32),a
	ld	a,1
	ld	(ix+33),a			; Reset position
	ld	l,(ix+31)
	ld	h,(ix+32)
	ld	a,(hl)
	ld	(ix+8),a			; Reset note offset
	xpmp_update_ay_EN2_done:
	.ENDIF
	ret
	
	;ld	a,(xpmp_chnum)
	;cp	3
	;jp	z,xpmp_update_ay_effects_done
	xpmp_ay_step_ep_frame:
	bit 	7,(ix+34)
	ret	nz
	xpmp_ay_step_ep:		
	.IFNDEF XPMP_EPMAC_NOT_USED
	; Sweep macro
	ld 	a,(ix+34)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ay_EP_done
	xpmp_update_ay_EP:
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
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ay_EP_loop
	ld	b,a
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+37),a
	ld	e,b
	ld	d,0
	bit	7,b
	jr	z,xpmp_update_ay_pos_freq
	ld	d,$FF
	xpmp_update_ay_pos_freq:
	ld	l,(ix+16)
	ld	h,(ix+17)
	add	hl,de
	ld	(ix+16),l
	ld	(ix+17),h
	jp	xpmp_update_ay_EP_done		
	xpmp_update_ay_EP_loop:
	ld	a,(ix+34)			; Which sweep macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	bc,xpmp_EP_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EP_mac_loop_tbl + (epMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+35),a
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+36),a
	ld	a,1
	ld	(ix+37),a			; Reset position
	ld	l,(ix+35)
	ld	h,(ix+36)
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_update_ay_pos_freq_2
	ld	d,$FF
	xpmp_update_ay_pos_freq_2:
	ld	l,(ix+16)
	ld	h,(ix+17)
	add	hl,de
	ld	(ix+16),l
	ld	(ix+17),h
	xpmp_update_ay_EP_done:
	.ENDIF
	ret

	xpmp_ay_step_mp_frame:
	bit 	7,(ix+38)
	ret	nz
	xpmp_ay_step_mp:		
	.IFNDEF XPMP_MPMAC_NOT_USED
	; Vibrato
	ld 	a,(ix+38)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ay_MP_done
	ld	a,(ix+41)
	cp	0
	jr 	nz,xpmp_update_ay_MP_done2
	xpmp_update_ay_MP:
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
	ld	e,(ix+19)
	ld	(ix+17),e
	and	a				; Clear carry
	ld 	a,(hl)				; Reload the vibrato delay
	ld	hl,0
	sbc	hl,de
	ld	(ix+18),l
	ld	(ix+19),h
	inc	a
	xpmp_update_ay_MP_done2:
	dec	a
	ld	(ix+41),a
	xpmp_update_ay_MP_done:
	.ENDIF
	ret
	
.ENDIF


;######################################################################################################################

.IFDEF XPMP_USES_SCC

; Note / rest
xpmp_scc_cmd_00:
xpmp_scc_cmd_60:
	ld	hl,(xpmp_tempw)

	ld	a,c
	cp	CMD_VOLUP
	jr	nz,xpmp_scc_cmd_00_2
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	ld	a,(ix+13)
	inc	hl
	add	a,(hl)
	ld	(ix+13),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	a,EFFECT_DISABLED
	ld	(ix+22),a			; Volume set overrides volume macros
	ret
	
xpmp_scc_cmd_00_2:
	ld	a,(ix+7)
	ld	(xpmp_lastNote),a
	ld	a,c
	and	$0F
	ld	(ix+7),a
	ld	a,c
	and	$F0
	cp	CMD_NOTE2
	jr	z,xpmp_scc_cmd_00_std_delay	
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_scc_cmd_00_short_note
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
		jp 	xpmp_scc_cmd_00_got_delay
	xpmp_scc_cmd_00_short_note:
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
	jp 	xpmp_scc_cmd_00_got_delay
	xpmp_scc_cmd_00_std_delay:		; Use delay set by last CMD_LEN
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
	xpmp_scc_cmd_00_got_delay:
	ld	a,2
	ld	(xpmp_freqChange),a
	ld	a,(ix+7)
	cp	CMD_REST	
	ret	z				; If this was a rest command we can return now
	cp	CMD_REST2
	ret	z
	.IFNDEF XPMP_VMAC_NOT_USED
	;ld	a,(ix+22)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_scc_reset_v_mac	; Reset effects as needed..
	RESET_EFFECT 22,scc,v
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	;ld	a,(ix+26)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_scc_reset_en_mac
	RESET_EFFECT 26,scc,en
	.ENDIF
	.IFNDEF XPMP_EN2MAC_NOT_USED
	;ld	a,(ix+30)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_scc_reset_en2_mac
	RESET_EFFECT 30,scc,en2
	.ENDIF
	.IFNDEF XPMP_MPMAC_NOT_USED
	;ld	a,(ix+38)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_scc_reset_mp_mac
	RESET_EFFECT 38,scc,mp
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	;ld	a,(ix+34)
	;cp	EFFECT_DISABLED
	;call	nz,xpmp_scc_reset_ep_mac
	RESET_EFFECT 34,scc,ep
	.ENDIF
	ret
	
; Set octave
xpmp_scc_cmd_10:
	ld	a,c 
	and	$0F
	ld	b,a
	add	a,a
	add	a,a
	sla	b
	sla	b
	sla	b
	add	a,b				; A = (C & $0F) * 12
	ld	(ix+9),a
	ret
	
xpmp_scc_cmd_20:
	ret

; Set volume (short)
xpmp_scc_cmd_30:
	ld	a,c
	and	$0F
	ld	(ix+13),a
	ld	a,1
	ld	(xpmp_volChange),a		; Volume has changed
	ld	a,EFFECT_DISABLED
	ld	(ix+22),a			; Volume set overrides volume macros
	ret

; Octave up + note	
xpmp_scc_cmd_40:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+9)
	add	a,12
	ld	(ix+9),a
	ld a,c
	add a,$20
	ld c,a
	jp	xpmp_scc_cmd_00_2

; Octave down + note
xpmp_scc_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+9)
	sub	12
	ld	(ix+9),a
	ld a,c
	add a,$10
	ld c,a
	jp	xpmp_scc_cmd_00_2

xpmp_scc_cmd_70:
xpmp_scc_cmd_80:
	ret

; Turn off arpeggio macro
xpmp_scc_cmd_90:
	ld	a,c
	cp	CMD_JSR
	jr	z,xpmp_scc_cmd_90_jsr
	cp	CMD_RTS
	jr	z,xpmp_scc_cmd_90_rts
	cp	CMD_LEN
	jr	z,xpmp_scc_cmd_90_len
	cp	CMD_WAVMAC
	jp	z,xpmp_scc_cmd_90_wavmac
	cp	CMD_TRANSP
	jp	z,xpmp_scc_cmd_90_transp
	
	ld	hl,(xpmp_tempw)
	ld	a,0
	ld	(ix+26),a
	ld	(ix+30),a
	ld	(ix+8),a
	ret

	; Jump to pattern
	xpmp_scc_cmd_90_jsr:
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
	xpmp_scc_cmd_90_rts:
	ld	a,(ix+48)
	ld	(ix+0),a
	ld	a,(ix+49)
	ld	(ix+1),a
	ld	a,(ix+50)
	ld	(ix+2),a
	ld	a,(ix+51)
	ld	(ix+3),a
	ret

	xpmp_scc_cmd_90_len:
	ld	hl,(xpmp_tempw)
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_scc_cmd_90_short_delay
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
	xpmp_scc_cmd_90_short_delay:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(hl)
	ld	(ix+52),a	; Fractional part
	ld	(ix+53),e	; Whole part
	ld	(ix+54),d	; ...
	ret

	xpmp_scc_cmd_90_wavmac:
	ld	hl,(xpmp_tempw)
	inc	hl
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	ld	a,(hl)
	ld	(ix+59),a
	xpmp_scc_reset_wt_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_WT_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+60),a
	ld	e,a
	inc	hl
	ld	a,(hl)
	ld	(ix+61),a
	ld	d,a
	ld	a,(de)
	ld	b,a
	inc	de
	ld	a,(de)
	ld	(ix+63),a
	ld	a,b
	call	xpmp_scc_load_wave
	ld	a,2
	ld	(ix+62),2
	ret

	xpmp_scc_cmd_90_transp:
	ld	hl,(xpmp_tempw)
	inc	hl
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	ld	a,(hl)
	ld	(ix+64),a	; transpose
	ret
	
xpmp_scc_cmd_A0:
xpmp_scc_cmd_B0:
xpmp_scc_cmd_C0:
xpmp_scc_cmd_D0:
	ret

; Callback
xpmp_scc_cmd_E0:
	ld	hl,(xpmp_tempw)
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	ld	a,c
	cp	CMD_CBOFF
	jr	z,xpmp_scc_cmd_E0_cboff
	cp	CMD_CBONCE
	jr	z,xpmp_scc_cmd_E0_cbonce
	cp	CMD_CBEVNT
	jr	z,xpmp_scc_cmd_E0_cbevnt
	cp	CMD_DETUNE
	jr	z,xpmp_scc_cmd_E0_detune
	cp	CMD_LDWAVE
	jr	z,xpmp_scc_cmd_E0_ldwave
	ret
	
	xpmp_scc_cmd_E0_cboff:
	ret
	
	xpmp_scc_cmd_E0_cbonce:
	ret
	
	; Every note
	xpmp_scc_cmd_E0_cbevnt:
	ret

	xpmp_scc_cmd_E0_detune:
	inc	hl
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_scc_cmd_E0_detune_pos
	ld	d,$FF
	xpmp_scc_cmd_E0_detune_pos:
	ld	(ix+20),e
	ld	(ix+21),d
	ret

	; Load waveform
	xpmp_scc_cmd_E0_ldwave:
	ld	a,EFFECT_DISABLED
	ld	(ix+59),a
	inc	hl
	ld	a,(hl)
	xpmp_scc_load_wave:
	dec	a
	ld	e,a
	ld	d,0
	sla	e
	rl	d
	sla	e
	rl	d
	sla	e
	rl	d
	sla	e
	rl	d
	sla	e
	rl	d
	ld 	hl,xpmp_waveform_data
	add	hl,de
	ld	a,(xpmp_chnum)
	cp	4
	jr	nz,+
	dec	a	; The fifth channel uses the same waveform as the fourth
	+:
	sla	a
	sla	a
	sla	a
	sla	a
	sla	a
	ld	e,a
	ld	d,$98
	ld	bc,32
	ldir
	ret
	
	
xpmp_scc_cmd_F0:
	ld	hl,(xpmp_tempw)
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	; Initialize volume macro	
	ld	a,c

	.IFNDEF XPMP_VMAC_NOT_USED
	cp	CMD_VOLMAC
	jr	nz,xpmp_scc_cmd_F0_check_VIBMAC
	inc	hl
	ld	a,(hl)
	ld	(ix+22),a
	xpmp_scc_reset_v_mac:
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
	xpmp_scc_cmd_F0_check_VIBMAC:
	.IFNDEF XPMP_MPMAC_NOT_USED
	; Initialize vibrato macro
	cp	CMD_VIBMAC
	jr	nz,xpmp_scc_cmd_F0_check_SWPMAC
	inc	hl
	ld	a,(hl)
	cp	EFFECT_DISABLED
	jr	z,xpmp_scc_cmd_F0_disable_VIBMAC
	ld	(ix+38),a
	xpmp_scc_reset_mp_mac:
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
	xpmp_scc_cmd_F0_disable_VIBMAC:
	ld	(ix+38),a
	ld	(ix+16),a
	ld	(ix+17),a
	ret
	.ENDIF
	
	; Initialize sweep macro
	xpmp_scc_cmd_F0_check_SWPMAC:
	.IFNDEF XPMP_EPMAC_NOT_USED
	cp	CMD_SWPMAC
	jr	nz,xpmp_scc_cmd_F0_check_JMP
	inc	hl
	ld	a,(hl)
	ld	(ix+34),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_scc_cmd_F0_disable_SWPMAC	
	xpmp_scc_reset_ep_mac:
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
	xpmp_scc_cmd_F0_disable_SWPMAC:
	ld	(ix+34),a
	ld	(ix+16),a
	ld	(ix+17),a
	ret
	.ENDIF
	
	; Jump
	xpmp_scc_cmd_F0_check_JMP:
	cp	CMD_JMP
	jr	nz,xpmp_scc_cmd_F0_check_LOPCNT
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+2),e
	ld	(ix+3),d
	ret

	; Set loop count
	xpmp_scc_cmd_F0_check_LOPCNT:
	cp	CMD_LOPCNT
	jr	nz,xpmp_scc_cmd_F0_check_DJNZ
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
	xpmp_scc_cmd_F0_check_DJNZ:
	cp	CMD_DJNZ
	jr	nz,xpmp_scc_cmd_F0_check_APMAC2
	ld	l,(ix+44)
	ld	h,(ix+45)
	dec	(hl)
	jr	z,xpmp_scc_cmd_F0_DJNZ_Z	; Check if the counter has reached zero
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+2),e
	ld	(ix+3),d
	ret
	xpmp_scc_cmd_F0_DJNZ_Z:
	dec	hl
	ld	(ix+44),l
	ld	(ix+45),h
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_scc_cmd_F0_check_APMAC2:
	.IFNDEF XPMP_EN2MAC_NOT_USED
	cp	CMD_APMAC2
	jr	nz,xpmp_scc_cmd_F0_check_ARPMAC
	inc	hl
	ld	a,(hl)
	ld	(ix+30),a
	xpmp_scc_reset_en2_mac:
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
	xpmp_scc_cmd_F0_check_ARPMAC:
	.IFNDEF XPMP_ENMAC_NOT_USED
	cp	CMD_ARPMAC
	jr	nz,xpmp_scc_cmd_F0_check_PANMAC
	inc	hl
	ld	a,(hl)
	ld	(ix+26),a
	xpmp_scc_reset_en_mac:
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

	xpmp_scc_cmd_F0_check_PANMAC:
	cp	CMD_PANMAC
	jr	nz,xpmp_scc_cmd_F0_check_J1
	inc	hl
	ld	a,0
	ret

	; Jump if one
	xpmp_scc_cmd_F0_check_J1:
	cp	CMD_J1
	jr	nz,xpmp_scc_cmd_F0_check_END
	ld	l,(ix+44)
	ld	h,(ix+45)
	ld	a,(hl)
	cp	1
	jr	nz,xpmp_scc_cmd_F0_J1_N1	; Check if the counter has reached 1
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
	xpmp_scc_cmd_F0_J1_N1:
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:	
	ret
	
	xpmp_scc_cmd_F0_check_END:
	cp	CMD_END
	jr	nz,xpmp_scc_cmd_F0_not_found
	ld	a,CMD_END
	ld	(ix+7),a			; Playback of this channel should end
	ld	a,2
	ld	(xpmp_freqChange),a		; The command-reading loop should exit	
	ret

	xpmp_scc_cmd_F0_not_found:
	ret
	
	

xpmp_update_scc:
	ld	(xpmp_chnum),a
	add	a,a
	ld	e,a
	ld	d,0
	ld	hl,xpmp_scc_channel_ptr_tbl
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
	
	ld	a,(ix+7)
	cp	CMD_END
	ret	z				; Playback has ended for this channel - all processing should be skipped
	
	ld 	l,(ix+5)			; Decrement the whole part of the delay and check if it has reached zero
	ld	h,(ix+6)
	dec	hl
	ld	a,h
	or	l
	jp 	nz,xpmp_update_scc_effects	
	
	; Loop here until a note/rest or END command is read (signaled by xpmp_freqChange == 2)
	xpmp_update_scc_read_cmd:
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
	ld	de,xpmp_scc_jump_tbl	
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
	jr	z,xpmp_update_scc_freq_change
	jp 	xpmp_update_scc_read_cmd
	
	xpmp_update_scc_freq_change:
	;ret
	ld	a,(ix+7)
	cp	CMD_REST
	jp	z,xpmp_update_scc_rest
	cp	CMD_REST2
	ret	z
	cp	CMD_END
	jp	z,xpmp_update_scc_rest
	ld	b,a
	ld	a,(ix+8)	; noteOffs
	ld	d,(ix+64)	; transpose
	add	a,d
	add	a,b
	ld	b,(ix+9)	; octave
	add	a,b
	ld	hl,ay_freq_tbl
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
	JL_IMM16 $0FFF,xpmp_update_scc_lb_ok
	ld	hl,(ay_freq_tbl+18)
	jp	xpmp_update_scc_freq_ok
	xpmp_update_scc_lb_ok:
	JGE_IMM16 $001C,xpmp_update_scc_freq_ok
	ld	hl,$001C
	xpmp_update_scc_freq_ok:
	ex	de,hl
	ld	a,(xpmp_chnum)
	add	a,a
	or	$80
	ld	l,a
	ld	h,$98
	ld	(hl),e
	inc 	hl
	ld	(hl),d
	
	ld	a,(xpmp_lastNote)
	cp	CMD_REST
	jr	nz,xpmp_update_scc_set_vol2
	jp	xpmp_update_scc_set_vol3

	xpmp_update_scc_set_vol:
	ld	a,(ix+7)
	cp	CMD_REST
	jr	z,xpmp_update_scc_rest
	xpmp_update_scc_set_vol2:
	; Update the volume if it has changed
	ld	a,(xpmp_volChange)
	cp	0
	ret	z
	xpmp_update_scc_set_vol3:
	ld	a,(xpmp_chnum)
	add	a,$8A
	ld	l,a
	ld	h,$98
	ld	a,(ix+13)
	ld	(hl),a
	xpmp_update_scc_no_vol_change:
	ret
	
	; Mute the channel
	xpmp_update_scc_rest:
	ld	a,(xpmp_chnum)
	add	a,$8A
	ld	l,a
	ld	h,$98
	ld	a,0
	ld	(hl),a
	ret
	
	xpmp_update_scc_effects:
	ld 	(ix+5),l
	ld	(ix+6),h

	call	xpmp_scc_step_v_frame
	call	xpmp_scc_step_wt_frame
	call	xpmp_scc_step_en_frame
	call	xpmp_scc_step_en2_frame
	call	xpmp_scc_step_ep_frame
	call	xpmp_scc_step_mp_frame

	xpmp_update_scc_effects_done:
	ld	a,(xpmp_freqChange)
	cp	0
	jp	nz,xpmp_update_scc_freq_change
	jp	xpmp_update_scc_set_vol
	ret	

	xpmp_scc_step_v_frame:
	bit 	7,(ix+22)
	ret	nz
	xpmp_scc_step_v:		
	.IFNDEF XPMP_VMAC_NOT_USED
	; Volume macro
	ld 	a,(ix+22)
	cp 	EFFECT_DISABLED
	jr 	z,xpmp_update_scc_v_done 
	xpmp_update_scc_v:
	ld 	l,(ix+23)
	ld	h,(ix+24)
	ld	a,1
	ld	(xpmp_volChange),a
	ld 	d,0
	ld 	a,(ix+25)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_scc_v_loop
	ld	(ix+13),a		 	; Set a new volume
	inc	de				; Increase the position
	ld	a,e
	ld	(ix+25),a
	jp	xpmp_update_scc_v_done
	xpmp_update_scc_v_loop:
	ld	a,(ix+22)			; Which volume macro are we using?
	and	$7F
	dec	a
	ld	e,a
	sla	e				; Each pointer is two bytes
	ld	bc,xpmp_v_mac_loop_tbl
	ex	de,hl
	add	hl,bc 				; HL = xpmp_vMac_loop_tbl + (vMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+23),a			; Store in xpmp_\1_vMac_ptr
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+24),a
	ld	a,1
	ld	(ix+25),a
	ld	l,(ix+23)
	ld	h,(ix+24)
	ld	a,(hl)
	ld	(ix+13),a
	xpmp_update_scc_v_done:
	.ENDIF
	ret

	xpmp_scc_step_wt_frame:
	bit 	7,(ix+59)
	ret	nz
	xpmp_scc_step_wt:		
	ld 	a,(ix+59)
	cp 	EFFECT_DISABLED
	jr 	z,xpmp_update_scc_wt_done 
	ld	a,(ix+63)
	cp	$80
	jr 	z,xpmp_update_scc_wt_done2 
	dec	a
	jr 	nz,xpmp_update_scc_wt_done2 
	xpmp_update_scc_wt:
	ld 	a,(ix+60)
	ld	l,a
	ld	a,(ix+61)
	ld	h,a
	ld 	d,0
	ld 	a,(ix+62)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_scc_wt_loop
	ld	b,a
	inc	de				; Increase the position
	inc	de
	inc	hl
	ld	a,(hl)
	ld	(ix+63),a
	ld	a,e
	ld	(ix+62),a
	ld	a,b
	call	xpmp_scc_load_wave
	jp	xpmp_update_scc_wt_done
	xpmp_update_scc_wt_loop:
	ld	a,(ix+59)			; Which WT macro are we using?
	and	$7F
	dec	a
	add	a,a
	ld	l,a
	ld	h,0				
	ld	bc,xpmp_WT_mac_loop_tbl
	;ld	de,xpmp_channel\1.dtMacPtr
	add	hl,bc 				; HL = xpmp_dtMac_loop_tbl + (dtMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+60),a			; Store in xpmp_\1_dtMac_ptr
	;inc 	de	
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+61),a
	ld	a,2
	ld	(ix+62),a
	ld	a,(ix+60)
	ld	l,a
	ld	a,(ix+61)
	ld	h,a
	ld	a,(hl)
	ld	b,a
	inc	hl
	ld	a,(hl)
	ld	(ix+63),a
	ld	a,b
	call	xpmp_scc_load_wave
	jr	xpmp_update_scc_wt_done
	xpmp_update_scc_wt_done2:
	ld	(ix+63),a
	xpmp_update_scc_wt_done:
	ret	

	xpmp_scc_step_en_frame:
	bit 	7,(ix+26)
	ret	nz
	xpmp_scc_step_en:		
	.IFNDEF XPMP_ENMAC_NOT_USED
	; Cumulative arpeggio
	ld 	a,(ix+26)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_scc_EN_done
	xpmp_update_scc_EN:
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
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_scc_EN_loop
	ld	b,a
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+29),a
	jp	xpmp_update_scc_EN_done		
	xpmp_update_scc_EN_loop:
	ld	a,(ix+26)			; Which arpeggio macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	bc,xpmp_EN_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+27),a
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+28),a
	ld	a,1
	ld	(ix+29),a			; Reset position
	ld	l,(ix+27)
	ld	h,(ix+28)
	ld	b,(hl)
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Reset note offset
	xpmp_update_scc_EN_done:
	.ENDIF
	ret

	xpmp_scc_step_en2_frame:
	bit 	7,(ix+30)
	ret	nz
	xpmp_scc_step_en2:		
	.IFNDEF XPMP_EN2MAC_NOT_USED
	; Non-cumulative arpeggio
	ld 	a,(ix+30)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_scc_EN2_done
	xpmp_update_scc_EN2:
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
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_scc_EN2_loop
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+33),a
	jp	xpmp_update_scc_EN2_done		
	xpmp_update_scc_EN2_loop:
	ld	a,(ix+30)			; Which arpeggio macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	bc,xpmp_EN_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (en2Mac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+31),a
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+32),a
	ld	a,1
	ld	(ix+33),a			; Reset position
	ld	l,(ix+31)
	ld	h,(ix+32)
	ld	a,(hl)
	ld	(ix+8),a			; Reset note offset
	xpmp_update_scc_EN2_done:
	.ENDIF
	ret
	
	;ld	a,(xpmp_chnum)
	;cp	3
	;jp	z,xpmp_update_scc_effects_done
	xpmp_scc_step_ep_frame:
	bit 	7,(ix+34)
	ret	nz
	xpmp_scc_step_ep:		
	.IFNDEF XPMP_EPMAC_NOT_USED
	; Sweep macro
	ld 	a,(ix+34)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_scc_EP_done
	xpmp_update_scc_EP:
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
	cp 	EFFECT_LOOP			; If we read a value of 128 we should loop
	jr 	z,xpmp_update_scc_EP_loop
	ld	b,a
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+37),a
	ld	e,b
	ld	d,0
	bit	7,b
	jr	z,xpmp_update_scc_pos_freq
	ld	d,$FF
	xpmp_update_scc_pos_freq:
	ld	l,(ix+16)
	ld	h,(ix+17)
	add	hl,de
	ld	(ix+16),l
	ld	(ix+17),h
	jp	xpmp_update_scc_EP_done		
	xpmp_update_scc_EP_loop:
	ld	a,(ix+34)			; Which sweep macro are we using?
	and	$7F
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	ld	bc,xpmp_EP_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EP_mac_loop_tbl + (epMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(ix+35),a
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(ix+36),a
	ld	a,1
	ld	(ix+37),a			; Reset position
	ld	l,(ix+35)
	ld	h,(ix+36)
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_update_scc_pos_freq_2
	ld	d,$FF
	xpmp_update_scc_pos_freq_2:
	ld	l,(ix+16)
	ld	h,(ix+17)
	add	hl,de
	ld	(ix+16),l
	ld	(ix+17),h
	xpmp_update_scc_EP_done:
	.ENDIF
	ret

	xpmp_scc_step_mp_frame:
	bit 	7,(ix+38)
	ret	nz
	xpmp_scc_step_mp:		
	.IFNDEF XPMP_MPMAC_NOT_USED
	; Vibrato
	ld 	a,(ix+38)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_scc_MP_done
	ld	a,(ix+41)
	cp	0
	jr 	nz,xpmp_update_scc_MP_done2
	xpmp_update_scc_MP:
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
	ld	e,(ix+19)
	ld	(ix+17),e
	and	a				; Clear carry
	ld 	a,(hl)				; Reload the vibrato delay
	ld	hl,0
	sbc	hl,de
	ld	(ix+18),l
	ld	(ix+19),h
	inc	a
	xpmp_update_scc_MP_done2:
	dec	a
	ld	(ix+41),a
	xpmp_update_scc_MP_done:
	.ENDIF
	ret
	
.ENDIF


;######################################################################################################################

.IFDEF XPMP_USES_FMUNIT

; Note / rest
xpmp_ym_cmd_00:
xpmp_ym_cmd_60:
	ld	hl,(xpmp_tempw)
xpmp_ym_cmd_00_2:
	ld	a,(ix+7)
	ld	(xpmp_lastNote),a		; Save the previous note
	ld	a,c
	and	$0F
	ld	(ix+7),a
	ld	a,c
	and	$F0
	cp	CMD_NOTE2
	jr	z,xpmp_ym_cmd_00_std_delay	
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_ym_cmd_00_short_note
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
		ld	(ix+4),a			; Fractional part
		ld	hl,0 
		adc	hl,de
		ld	(ix+5),l			; Whole part
		ld	(ix+6),h
		jp 	xpmp_ym_cmd_00_got_delay
	xpmp_ym_cmd_00_short_note:
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
	jp 	xpmp_ym_cmd_00_got_delay
	xpmp_ym_cmd_00_std_delay:
	ld	a,(ix+80)
	ld	b,a
	ld	a,(ix+4)
	add	a,b
	ld	(ix+4),a
	ld 	l,(ix+81)
	ld	h,(ix+82)
	ld	de,0
	adc	hl,de
	ret	z
	ld	(ix+5),l
	ld	(ix+6),h
	xpmp_ym_cmd_00_got_delay:
	ld	a,2
	ld	(xpmp_freqChange),a
	ld	a,(ix+7)
	cp	CMD_REST	
	ret	z				; If this was a rest command we can return now
	cp	CMD_REST2
	ret	z
	.IFNDEF XPMP_VMAC_NOT_USED
	ld	a,(ix+16)
	cp	EFFECT_DISABLED
	call	nz,xpmp_ym_reset_v_mac		; Reset effects as needed..
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	ld	a,(ix+20)
	cp	EFFECT_DISABLED
	call	nz,xpmp_ym_reset_en_mac
	.ENDIF
	.IFNDEF XPMP_EN2MAC_NOT_USED
	ld	a,(ix+24)
	cp	EFFECT_DISABLED
	call	nz,xpmp_ym_reset_en2_mac
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	ld	a,(ix+28)
	cp	EFFECT_DISABLED
	call	nz,xpmp_ym_reset_ep_mac
	.ENDIF
	ld	a,(ix+68)
	cp	EFFECT_DISABLED
	call	nz,xpmp_ym_reset_al_mac
	ld	a,(ix+72)
	cp	EFFECT_DISABLED
	call	nz,xpmp_ym_reset_fb_mac
	ret

; Set octave
xpmp_ym_cmd_10:
	ld	a,c 
	and	$0F
	;inc	a
	dec	a				; Minimum octave is 1
	ld	(ix+38),a
	ld	b,a
	add	a,a
	add	a,a
	add	a,a
	;add	a,a
	sla	b
	sla	b
	;ld	(ix+38),a			; A = (C & $0F) * 16
	add	a,b				; A = (C & $0F) * 12
	ld	(ix+9),a
	ret

; Set algorithm	
xpmp_ym_cmd_20:
	ld	a,c
	and	7
	ld	b,a
	ld	a,(ix+10)
	and	$F8
	or	b
	or	$C0
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$20
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ld	a,0
	ld	(ix+68),a		; Disable algorithm macro
	ret

; Set volume (short)
xpmp_ym_cmd_30:
	ret


; Octave up + note	
xpmp_ym_cmd_40:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+9)
	add	a,12
	ld	(ix+9),a
	ld	a,(ix+38)
	inc	a
	ld	(ix+38),a
	ld a,c
	add a,$20
	ld c,a
	jp	xpmp_ym_cmd_00_2

; Octave down + note
xpmp_ym_cmd_50:
	ld	hl,(xpmp_tempw)
	ld	a,(ix+9)
	sub	12
	ld	(ix+9),a
	ld	a,(ix+38)
	dec	a
	ld	(ix+38),a
	ld a,c
	add a,$10
	ld c,a
	jp	xpmp_ym_cmd_00_2

xpmp_ym_cmd_70:
xpmp_ym_cmd_80:
	ret

; Turn off arpeggio macro
xpmp_ym_cmd_90:
	ld	hl,(xpmp_tempw)
	ld	a,c
	cp	CMD_ARPOFF
	jr	z,xpmp_ym_cmd_90_90
	cp	CMD_FBKMAC
	jr	z,xpmp_ym_cmd_90_91
	cp	CMD_JSR
	jr	z,xpmp_ym_cmd_90_jsr
	cp	CMD_RTS
	jr	z,xpmp_ym_cmd_90_rts
	cp	CMD_LEN
	jp	z,xpmp_ym_cmd_90_len
	ret
	
	xpmp_ym_cmd_90_90:
	ld	a,0
	ld	(ix+20),a
	ld	(ix+24),a
	ld	(ix+8),a
	ret

	xpmp_ym_cmd_90_91:
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	inc	hl
	ld	(ix+75),1
	ld	a,(hl)
	ld	(ix+72),a
	ret
	xpmp_ym_reset_fb_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_FB_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+73),a
	inc	hl
	ld	a,(hl)
	ld	(ix+74),a
	ld	l,(ix+73)
	ld	h,(ix+74)
	ld	b,(hl)
	ld	a,(ix+10)
	and	$C7
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$20
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ld	(ix+75),1
	ret

	; Return from pattern
	xpmp_ym_cmd_90_rts:
	ld	a,(ix+76)
	ld	(ix+0),a
	ld	a,(ix+77)
	ld	(ix+1),a
	ld	a,(ix+78)
	ld	(ix+2),a
	ld	a,(ix+79)
	ld	(ix+3),a
	ret
	
	; Jump to pattern
	xpmp_ym_cmd_90_jsr:
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	ld	(ix+78),e
	ld	(ix+79),d
	ld	a,(ix+0)
	ld	(ix+76),a
	ld	a,(ix+1)
	ld	(ix+77),a
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
	
	xpmp_ym_cmd_90_len:
	ld	hl,(xpmp_tempw)
	ld	e,(ix+2)
	ld	d,(ix+3)
	inc	de
	inc	de
	ld	(ix+2),e
	ld	(ix+3),d
	inc	hl
	ld	a,(hl)
	bit	7,a
	jr	z,xpmp_ym_cmd_90_short_delay
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
		ld	(ix+80),a	; Fractional part
		ld	(ix+81),e	; Whole part
		ld	(ix+82),d	; ...
		ret
	xpmp_ym_cmd_90_short_delay:
	ld	d,0
	ld	e,a
	inc	hl
	ld	a,(hl)
	ld	(ix+80),a	; Fractional part
	ld	(ix+81),e	; Whole part
	ld	(ix+82),d
	ret


; Set mode
xpmp_ym_cmd_A0:
	ld	a,c
	and	$0F
	ld	(ix+67),a
	ld 	a,(xpmp_chnum)
	cp	7
	jr	nz,+
	ld	a,(ix+67)
	cp	0
	jr	nz,+
	WRITE_YM2151 $0F,0
	+:
	ret
	

; Set feedback	
xpmp_ym_cmd_B0:
	ld	a,c
	and	7
	add	a,a
	add	a,a
	add	a,a
	ld	b,a
	ld	a,(ix+10)
	and	$C7
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$20
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ld	a,0
	ld	(ix+72),a
	ret

; Set operator	
xpmp_ym_cmd_C0:
	ld	a,c
	and	7
	ld	(ix+39),a
	ret


; Set rate scaling
xpmp_ym_cmd_D0:
	ld	hl,(xpmp_tempw)
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	inc	hl
	ld	a,(ix+39)
	cp	0
	jr	z,xpmp_ym_cmd_D0_all
	ld	a,(hl)
	and	3
	rrca
	rrca
	ld	c,a
	ld	(xpmp_tempw),ix
	ld	hl,(xpmp_tempw)
	ld	a,(ix+39)
	add	a,48
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
	add	a,a
	add	a,$78
	ld	(iy+0),a
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ret
	xpmp_ym_cmd_D0_all:
	ld	a,(hl)
	and	3
	rrca
	rrca
	ld	d,a
	ld	a,(ix+49)
	and	$1F
	or	d
	ld	(ix+49),a
	ld	(iy+1),a
	ld	(iy+0),$80
	ld	a,(ix+50)
	and	$1F
	or	d
	ld	(ix+50),a
	ld	(iy+3),a
	ld	(iy+2),$88
	ld	a,(ix+51)
	and	$1F
	or	d
	ld	(ix+51),a
	ld	(iy+5),a
	ld	(iy+4),$90
	ld	a,(ix+52)
	and	$1F
	or	d
	ld	(ix+52),a
	ld	(iy+7),a
	ld	(iy+6),$98
	ld	hl,XPMP_FM_BUF
	ld	a,4

	add	a,(hl)
	ld	(hl),a
	ld	de,8
	add	iy,de
	ret

xpmp_ym_cmd_E0:
	ld	hl,(xpmp_tempw)
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	ld	a,c
	cp	CMD_ADSR
	jr	z,xpmp_ym_cmd_E0_adsr
	cp	CMD_DETUNE
	jp	z,xpmp_ym_cmd_E0_detune
	cp	CMD_MULT
	jp	z,xpmp_ym_cmd_E0_mult
	cp	CMD_HWAM
	jp	z,xpmp_ym_cmd_E0_am
	cp	CMD_MODMAC
	jp	z,xpmp_ym_cmd_E0_mod
	ret

xpmp_ym_cmd_E0_adsr:
	inc	hl
	ld	a,(hl)
	dec	a
	add	a,a
	ld	hl,xpmp_ADSR_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	
	ld	a,(ix+39)
	cp	0
	jr	z,xpmp_ym_adsr_all
	xpmp_ym_adsr_spec:
	dec	a
	add	a,49
	ld	c,a
	sub	49
	add	a,a
	add	a,a
	add	a,a
	add	a,$80
	ld	(iy+0),a
	add	a,$20
	ld	(iy+2),a
	add	a,$20
	ld	(iy+4),a
	add	a,$20
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
	ld	(iy+7),a
	ld	a,(XPMP_FM_BUF)
	add	a,4
	ld	(XPMP_FM_BUF),a
	ld	de,8
	add	iy,de	
	ret
	xpmp_ym_adsr_all:
	ld	(xpmp_tempv),hl
	ld	a,1
	call	xpmp_ym_adsr_spec
	ld	hl,(xpmp_tempv)	
	ld	a,2
	call	xpmp_ym_adsr_spec
	ld	hl,(xpmp_tempv)	
	ld	a,3
	call	xpmp_ym_adsr_spec
	ld	hl,(xpmp_tempv)	
	ld	a,4
	call	xpmp_ym_adsr_spec
	ret

xpmp_ym_cmd_E0_mult:
	inc	hl
	ld	a,(ix+39)
	cp	0
	jr	z,xpmp_ym_mult_all
	ld	a,(hl)
	and	15
	ld	c,a
	ld	(xpmp_tempw),ix
	ld	hl,(xpmp_tempw)
	ld	a,(ix+39)
	add	a,40
	ld	e,a
	ld	d,0
	add	hl,de
	ld	a,(hl)
	and	$70
	or	c
	ld	(hl),a
	ld	(iy+1),a
	ld	a,(ix+39)
	add	a,a
	add	a,a
	add	a,a
	add	a,$38
	ld	(iy+0),a
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ret
	xpmp_ym_mult_all:
	ld	a,(hl)
	and	15
	ld	d,a
	ld	a,(ix+41)
	and	$70
	or	d
	ld	(ix+41),a
	ld	(iy+1),a
	ld	(iy+0),$40
	ld	a,(ix+42)
	and	$70
	or	d
	ld	(ix+42),a
	ld	(iy+3),a
	ld	(iy+2),$48
	ld	a,(ix+43)
	and	$70
	or	d
	ld	(ix+43),a
	ld	(iy+5),a
	ld	(iy+4),$50
	ld	a,(ix+44)
	and	$70
	or	d
	ld	(ix+44),a
	ld	(iy+7),a
	ld	(iy+6),$58
	ld	hl,XPMP_FM_BUF
	ld	a,4
	add	a,(hl)
	ld	(hl),a
	ld	de,8
	add	iy,de
	ret

xpmp_ym_cmd_E0_detune:
	inc	hl
	ld	a,(ix+39)
	cp	0
	jr	z,xpmp_ym_detune_all
	ld	a,(hl)
	and	7
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	c,a
	ld	(xpmp_tempw),ix
	ld	hl,(xpmp_tempw)
	ld	a,(ix+39)
	add	a,40
	ld	e,a
	ld	d,0
	add	hl,de
	ld	a,(hl)
	and	$0F
	or	c
	ld	(hl),a
	ld	(iy+1),a
	ld	a,(ix+39)
	add	a,a
	add	a,a
	add	a,a
	add	a,$38
	ld	(iy+0),a
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ret
	xpmp_ym_detune_all:
	ld	a,(hl)
	and	7
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	d,a
	ld	a,(ix+41)
	and	$0F
	or	d
	ld	(ix+41),a
	ld	(iy+1),a
	ld	(iy+0),$40
	ld	a,(ix+42)
	and	$0F
	or	d
	ld	(ix+42),a
	ld	(iy+3),a
	ld	(iy+2),$48
	ld	a,(ix+43)
	and	$0F
	or	d
	ld	(ix+43),a
	ld	(iy+5),a
	ld	(iy+4),$50
	ld	a,(ix+44)
	and	$0F
	or	d
	ld	(ix+44),a
	ld	(iy+7),a
	ld	(iy+6),$58
	ld	hl,XPMP_FM_BUF
	ld	a,4
	add	a,(hl)
	ld	(hl),a
	ld	de,8
	add	iy,de
	ret

; TODO
xpmp_ym_cmd_E0_am:
	inc	hl
	ld	a,(hl)
	rrca
	ld	l,a
	
	ld	a,(ix+39)
	cp	0
	jr	z,xpmp_ym_am_all
	xpmp_ym_am_spec:
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
	;inc	(hl)
	;inc	iy
	;inc	iy
	ret
	xpmp_ym_am_all:
	ld	(xpmp_tempv),hl
	ld	a,1
	call	xpmp_ym_am_spec
	ld	hl,(xpmp_tempv)	
	ld	a,2
	call	xpmp_ym_am_spec
	ld	hl,(xpmp_tempv)	
	ld	a,3
	call	xpmp_ym_am_spec
	ld	hl,(xpmp_tempv)	
	ld	a,4
	call	xpmp_ym_am_spec
	ret
	
; TODO
xpmp_ym_cmd_E0_mod:
	inc	hl
	ld	a,(hl)
	cp	EFFECT_DISABLED
	jr	z,xpmp_ym_cmd_E0_mod_disable
	dec	a
	add	a,a
	ld	hl,xpmp_MOD_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	a,(hl)
	add	a,8
	ld	b,a
	;ld	a,$22
	;push	iy
	;call	write_fm_low
	;pop	iy
	inc	hl
	ld	a,(hl)
	ld	(iy+0),$B4
	or	$C0
	ld	(iy+1),a
	;inc	iy
	;inc	iy
	ld	hl,XPMP_FM_BUF
	;inc	(hl)
	ret	
	xpmp_ym_cmd_E0_mod_disable:
	WRITE_YM2151 $18,0
	ret
	
	
xpmp_ym_cmd_F0:
	ld	hl,(xpmp_tempw)
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	ld	a,c
	cp	CMD_VOLSET
	jr	z,xpmp_ym_cmd_F0_volset
	cp	CMD_VOLMAC
	jr	z,xpmp_ym_cmd_F0_VOLMAC
	cp	CMD_SWPMAC
	jr	z,xpmp_ym_cmd_F0_SWPMAC
	cp	CMD_ARPMAC
	jp	z,xpmp_ym_cmd_F0_ARPMAC
	cp	CMD_APMAC2
	jp	z,xpmp_ym_cmd_F0_APMAC2
	cp	CMD_DUTMAC
	jp	z,xpmp_ym_cmd_F0_ALGMAC
	cp	CMD_LOPCNT
	jp	z,xpmp_ym_cmd_F0_LOPCNT
	cp	CMD_DJNZ
	jp	z,xpmp_ym_cmd_F0_DJNZ
	cp	CMD_JMP
	jp	z,xpmp_ym_cmd_F0_JMP
	cp	CMD_END
	jr	z,xpmp_ym_cmd_F0_END
	ret

xpmp_ym_cmd_F0_volset:
	inc	hl
	ld	a,(hl)
	ld	(ix+15),a
	ld	a,0
	ld	(ix+16),a			; Turn off volume macro
	ld	a,1
	ld	(xpmp_volChange),a
	ret

	xpmp_ym_cmd_F0_END:
	ld	a,CMD_END
	ld	(ix+7),a			; Playback of this channel should end
	ld	a,2
	ld	(xpmp_freqChange),a		; The command-reading loop should exit	
	ret
	
	xpmp_ym_cmd_F0_VOLMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+16),a
	xpmp_ym_reset_v_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_v_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+17),a
	inc	hl
	ld	a,(hl)
	ld	(ix+18),a
	ld	l,(ix+17)
	ld	h,(ix+18)
	ld	a,(hl)
	ld	(ix+15),a
	ld	a,1
	ld	(xpmp_volChange),a	
	ld	(ix+19),1
	ret
	
	; Initialize sweep macro
	xpmp_ym_cmd_F0_SWPMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+28),a
	cp	EFFECT_DISABLED
	jr	z,xpmp_ym_cmd_F0_disable_SWPMAC	
	xpmp_ym_reset_ep_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_EP_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+29),a
	inc	hl
	ld	a,(hl)
	ld	(ix+30),a
	ld	l,(ix+29)
	ld	h,(ix+30)
	ld	a,1
	ld	(ix+31),a
	dec	a
	ld	(ix+12),a
	ld	a,(hl)
	ld	(ix+11),a
	bit	7,a
	ret	z
	ld	a,$FF
	ld	(ix+12),a
	ret
	xpmp_ym_cmd_F0_disable_SWPMAC:
	ld	(ix+28),a
	ld	(ix+11),a
	ld	(ix+12),a
	ret
	
	; Jump
	xpmp_ym_cmd_F0_JMP:
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+2),e
	ld	(ix+3),d
	ret

	; Set loop count
	xpmp_ym_cmd_F0_LOPCNT:
	inc	hl
	ld	a,(hl)
	ld	l,(ix+34)
	ld	h,(ix+35)
	inc	hl
	ld	(hl),a
	ld	(ix+34),l
	ld	(ix+35),h
	ret

	; Decrease and jump if not zero
	xpmp_ym_cmd_F0_DJNZ:
	ld	l,(ix+34)
	ld	h,(ix+35)
	dec	(hl)
	jr	z,xpmp_ym_cmd_F0_DJNZ_Z		; Check if the counter has reached zero
	ld	hl,(xpmp_tempw)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de				; dataPos will be increased after the return, so we decrease it here
	ld	(ix+2),e
	ld	(ix+3),d
	ret
	xpmp_ym_cmd_F0_DJNZ_Z:
	dec	hl
	ld	(ix+34),l
	ld	(ix+35),h
	inc	(ix+2)
	jr	nz,+
	inc	(ix+3)
	+:
	ret

	xpmp_ym_cmd_F0_ALGMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+68),a
	xpmp_ym_reset_al_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_dt_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+69),a
	inc	hl
	ld	a,(hl)
	ld	(ix+70),a
	ld	l,(ix+69)
	ld	h,(ix+70)
	ld	b,(hl)
	ld	a,(ix+10)
	and	$F8
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$20
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)
	ld	(ix+71),1
	ret
	
	; Initialize non-cumulative arpeggio macro
	xpmp_ym_cmd_F0_APMAC2:
	inc	hl
	ld	a,(hl)
	ld	(ix+24),a
	xpmp_ym_reset_en2_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_EN_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+25),a
	inc	hl
	ld	a,(hl)
	ld	(ix+26),a
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
	xpmp_ym_cmd_F0_ARPMAC:
	inc	hl
	ld	a,(hl)
	ld	(ix+20),a
	xpmp_ym_reset_en_mac:
	dec	a
	add	a,a
	ld	hl,xpmp_EN_mac_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)	
	ld	(ix+21),a
	inc	hl
	ld	a,(hl)
	ld	(ix+22),a
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
xpmp_update_ym:
	ld	(xpmp_chnum),a
	add	a,a
	ld	e,a

	ld	d,0
	ld	hl,xpmp_ym_channel_ptr_tbl
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
	
	ld	a,(ix+7)
	cp	CMD_END
	ret	z				; Playback has ended for this channel - all processing should be skipped
	
	ld 	l,(ix+5)			; Decrement the whole part of the delay and check if it has reached zero
	ld	h,(ix+6)
	dec	hl
	ld	a,h
	or	l
	jp 	nz,xpmp_update_ym_effects	
	
	; Loop here until a note/rest or END command is read (signaled by xpmp_freqChange == 2)
	xpmp_update_ym_read_cmd:
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
	ld	de,xpmp_ym_jump_tbl	
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
	jr	z,xpmp_update_ym_freq_change
	jp 	xpmp_update_ym_read_cmd
	
	xpmp_update_ym_freq_change:
	call	write_ym_buf
	ld	a,(ix+7)
	cp	CMD_REST
	jp	z,xpmp_update_ym_rest
	cp	CMD_REST2
	ret	z
	cp	CMD_END
	jp	z,xpmp_update_ym_rest
	ld	c,a
	
	ld	a,(xpmp_freqChange)
	cp	2
	;jr	nz,+
	ld	a,(xpmp_chnum)
	ld	b,a
	ld	a,$08
	call	write_ym2151	; KEY_OFF
	;+:

;jr ym_note_ok	
	ld	a,(ix+8)
	add	a,c
	ld	b,a
	ld	a,(ix+9)
	add	a,b
	bit	7,a
	jr	z,ym_note_lb_ok
	ld	a,0
	ld	b,0
	jr	ym_note_ok2
	ym_note_lb_ok:
	cp	96
	jr	c,ym_note_ok
	ld	a,11
	ld	b,$70
	jr	ym_note_ok2
	ym_note_ok:
	ld	a,(ix+7)
	add	a,c
	ld	b,(ix+38)
	sla	b
	sla	b
	sla	b
	sla	b
	ld	b,$50
	ym_note_ok2:
	
	ld	hl,ym2151_freq_tbl
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	or	b
	ld	b,a
	ld	a,(xpmp_chnum)
	cp	7
	jr	nz,xpmp_update_ym_melody
	ld	a,b
	and	$1F
	or	$80
	ld	b,a
	ld	a,$2F
	call	write_ym2151
	jr	+
	xpmp_update_ym_melody:
;	ld	a,b
;ld	b,$50
	;ld	a,(xpmp_chnum)
	or	$28
	call	write_ym2151
	+:
	
	ld	a,(xpmp_chnum)
	or	$E8
	ld	b,a
	ld	a,$08
	;call	write_ym2151	; KEY_ON
	
	ld	a,(xpmp_lastNote)
	cp	CMD_REST
	jr	nz,xpmp_update_ym_set_vol2
	jp	xpmp_update_ym_set_vol3

	xpmp_update_ym_set_vol:
	ld	a,(ix+7)
	cp	CMD_REST
	jr	z,xpmp_update_ym_rest
	xpmp_update_ym_set_vol2:
	; Update the volume if it has changed
	call	write_ym_buf
	ld	a,(xpmp_volChange)
	cp	0
	ret	z
	xpmp_update_ym_set_vol3:
	ld	a,(ix+15)
	xor	127
	ld	b,a
	ld	a,(xpmp_chnum)
	or	$60
	call	write_ym2151
	ld	a,(xpmp_chnum)
	or	$68
	call	write_ym2151
	ld	a,(xpmp_chnum)
	or	$70
	call	write_ym2151
	ld	a,(xpmp_chnum)
	or	$78
	call	write_ym2151
 WRITE_YM2151 $60,0
 WRITE_YM2151 $68,0
 WRITE_YM2151 $70,0
 WRITE_YM2151 $78,0
	xpmp_update_ym_no_vol_change:
	ret
	
	; Mute the channel
	xpmp_update_ym_rest:
	call	write_ym_buf
	ld	a,(xpmp_chnum)
	ld	b,a
	ld	a,$08
	;call	write_ym2151
	ret

	xpmp_update_ym_effects:
	ld 	(ix+5),l
	ld	(ix+6),h

	.IFNDEF XPMP_VMAC_NOT_USED
	; Volume macro
	ld 	a,(ix+16)
	cp 	EFFECT_DISABLED
	jr 	z,xpmp_update_ym_v_done 
	xpmp_update_ym_v:
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
	jr 	z,xpmp_update_ym_v_loop
	ld	(ix+15),a		 	; Set a new volume
	inc	de				; Increase the position
	ld	a,e
	ld	(ix+19),a
	jp	xpmp_update_ym_v_done
	xpmp_update_ym_v_loop:
	ld	a,(ix+16)			; Which volume macro are we using?
	dec	a
	ld	e,a
	sla	e				; Each pointer is two bytes
	ld	bc,xpmp_v_mac_loop_tbl
	ld	l,(ix+17)
	ld	h,(ix+18)
	ex	de,hl
	add	hl,bc 				; HL = xpmp_vMac_loop_tbl + (vMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a				; Store in xpmp_\1_vMac_ptr
	inc 	de	
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(ix+19),a
	ld	l,(ix+17)
	ld	h,(ix+18)
	ld	a,(hl)
	ld	(ix+15),a
	xpmp_update_ym_v_done:
	.ENDIF
	
	.IFNDEF XPMP_ENMAC_NOT_USED
	; Cumulative arpeggio
	ld 	a,(ix+20)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ym_EN_done
	xpmp_update_ym_EN:
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	ld	l,(ix+21)
	ld	h,(ix+22)
	ld 	d,0
	ld 	e,(ix+23)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ym_EN_loop
	ld	b,a
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+23),a
	jp	xpmp_update_ym_EN_done		
	xpmp_update_ym_EN_loop:
	ld	a,(ix+20)			; Which arpeggio macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	;ld	hl,(xpmp_enMacPtr)
	ld	l,(ix+21)
	ld	h,(ix+22)
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
	ld	(ix+23),a			; Reset position
	ld	l,(ix+21)
	ld	h,(ix+22)
	ld	b,(hl)
	ld	a,(ix+8)
	add	a,b
	ld	(ix+8),a			; Reset note offset
	xpmp_update_ym_EN_done:
	.ENDIF
	
	.IFNDEF XPMP_EN2MAC_NOT_USED
	; Non-cumulative arpeggio
	ld 	a,(ix+24)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ym_EN2_done
	xpmp_update_ym_EN2:
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	ld	l,(ix+25)
	ld	h,(ix+26)
	ld 	d,0
	ld 	e,(ix+27)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ym_EN2_loop
	ld	(ix+8),a			; Number of semitones to offset the current note by
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+27),a
	jp	xpmp_update_ym_EN2_done		
	xpmp_update_ym_EN2_loop:
	ld	a,(ix+24)			; Which arpeggio macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	;ld	hl,(xpmp_en2MacPtr)
	ld	l,(ix+25)
	ld	h,(ix+26)
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
	ld	(ix+27),a			; Reset position
	ld	l,(ix+25)
	ld	h,(ix+26)
	ld	a,(hl)
	ld	(ix+8),a			; Reset note offset
	xpmp_update_ym_EN2_done:
	.ENDIF

	ld 	a,(ix+68)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ym_al_done
	xpmp_update_ym_al:
	ld	l,(ix+69)
	ld	h,(ix+70)
	ld 	d,0
	ld 	e,(ix+71)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ym_al_loop
	ld	b,a
	ld	a,(ix+10)
	and	$F8
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$20
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)	
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+71),a
	jp	xpmp_update_ym_al_done		
	xpmp_update_ym_al_loop:
	ld	a,(ix+68)			; Which arpeggio macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	;ld	hl,(xpmp_alMacPtr)
	ld	l,(ix+69)
	ld	h,(ix+70)
	ld	bc,xpmp_dt_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a
	inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(ix+71),a			; Reset position
	ld	l,(ix+69)
	ld	h,(ix+70)
	ld	b,(hl)
	ld	a,(ix+10)
	and	$F8
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$20
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)	
	xpmp_update_ym_al_done:

	ld 	a,(ix+72)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ym_fb_done
	xpmp_update_ym_fb:
	ld	l,(ix+73)
	ld	h,(ix+74)
	ld 	d,0
	ld 	e,(ix+75)
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ym_fb_loop
	ld	b,a
	ld	a,(ix+10)
	and	$C7
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$20
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)	
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+75),a
	jp	xpmp_update_ym_fb_done		
	xpmp_update_ym_fb_loop:
	ld	a,(ix+72)			; Which arpeggio macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	;ld	hl,(xpmp_fbMacPtr)
	ld	l,(ix+73)
	ld	h,(ix+74)
	ld	bc,xpmp_FB_mac_loop_tbl
	ex	de,hl
	add	hl,bc				; HL = xpmp_EN_mac_loop_tbl + (enMac - 1)*2
	ld	a,(hl)				; Read low byte of pointer
	ld	(de),a
	inc 	de
	inc	hl
	ld	a,(hl)				; Read high byte of pointer
	ld	(de),a
	ld	a,1
	ld	(ix+75),a			; Reset position
	ld	l,(ix+73)
	ld	h,(ix+74)
	ld	b,(hl)
	ld	a,(ix+10)
	and	$C7
	or	b
	ld	(ix+10),a
	ld	(iy+1),a
	ld	(iy+0),$20
	inc	iy
	inc	iy
	ld	hl,XPMP_FM_BUF
	inc	(hl)	
	xpmp_update_ym_fb_done:
	
	.IFNDEF XPMP_EPMAC_NOT_USED
	; Sweep macro
	ld 	a,(ix+28)
	cp	EFFECT_DISABLED
	jr 	z,xpmp_update_ym_EP_done
	xpmp_update_ym_EP:
	ld	a,1
	ld	(xpmp_freqChange),a		; Frequency has changed, but we haven't read a new note/rest yet
	ld	l,(ix+29)
	ld	h,(ix+30)
	ld 	d,0
	ld 	a,(ix+31)
	ld 	e,a
	add 	hl,de				; Add macro position to pointer
	ld 	a,(hl)
	cp 	128				; If we read a value of 128 we should loop
	jr 	z,xpmp_update_ym_EP_loop
	ld	b,a
	inc	de				; Increase the position
	ld	a,e				
	ld	(ix+31),a
	ld	e,b
	ld	d,0
	bit	7,b
	jr	z,xpmp_update_ym_pos_freq
	ld	d,$FF
	xpmp_update_ym_pos_freq:
	ld	l,(ix+11)
	ld	h,(ix+12)
	add	hl,de
	ld	(ix+11),l
	ld	(ix+12),h
	jp	xpmp_update_ym_EP_done		
	xpmp_update_ym_EP_loop:
	ld	a,(ix+28)			; Which sweep macro are we using?
	dec	a
	add	a,a				; Each pointer is two bytes
	ld	e,a
	;ld	hl,(xpmp_epMacPtr)
	ld	l,(ix+29)
	ld	h,(ix+30)
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
	ld	(ix+31),a			; Reset position
	ld	l,(ix+29)
	ld	h,(ix+30)
	ld	e,(hl)
	ld	d,0
	bit	7,e
	jr	z,xpmp_update_ym_pos_freq_2
	ld	d,$FF
	xpmp_update_ym_pos_freq_2:
	ld	l,(ix+11)
	ld	h,(ix+12)
	add	hl,de
	ld	(ix+11),l
	ld	(ix+12),h
	xpmp_update_ym_EP_done:
	.ENDIF
	
	ld	a,(xpmp_freqChange)
	cp	0
	jp	nz,xpmp_update_ym_freq_change
	jp	xpmp_update_ym_set_vol

	ret	
	
	
.ENDIF

	

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
.IFDEF XPMP_ENABLE_CHANNEL_E
	ld	a,0
	call 	xpmp_update_ay
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_F
	ld	a,1
	call 	xpmp_update_ay
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_G
	ld	a,2
	call 	xpmp_update_ay
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_H
	ld	a,0
	call 	xpmp_update_scc
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_I
	ld	a,1
	call 	xpmp_update_scc
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_J
	ld	a,2
	call 	xpmp_update_scc
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_K
	ld	a,3
	call 	xpmp_update_scc
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_L
	ld	a,4
	call 	xpmp_update_scc
.ENDIF

.IFDEF XPMP_ENABLE_CHANNEL_M
	ld	a,0
	call 	xpmp_update_ym
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_N
	ld	a,1
	call 	xpmp_update_ym
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_O
	ld	a,2
;	call 	xpmp_update_ym
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_P
	ld	a,3
;	call 	xpmp_update_ym
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_Q
	ld	a,4
;	call 	xpmp_update_ym
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_R
	ld	a,5
;	call 	xpmp_update_ym
.ENDIF

ret
	

.IFDEF XPMP_USES_AY
xpmp_ay_channel_ptr_tbl:
.dw xpmp_channel4
.dw xpmp_channel5
.dw xpmp_channel6

xpmp_ay_jump_tbl:
.dw xpmp_ay_cmd_00
.dw xpmp_ay_cmd_10
.dw xpmp_ay_cmd_20
.dw xpmp_ay_cmd_30
.dw xpmp_ay_cmd_40
.dw xpmp_ay_cmd_50
.dw xpmp_ay_cmd_60
.dw xpmp_ay_cmd_70
.dw xpmp_ay_cmd_80
.dw xpmp_ay_cmd_90
.dw xpmp_ay_cmd_A0
.dw xpmp_ay_cmd_B0
.dw xpmp_ay_cmd_C0
.dw xpmp_ay_cmd_D0
.dw xpmp_ay_cmd_E0
.dw xpmp_ay_cmd_F0
.ENDIF


; Konami SCC
.IFDEF XPMP_USES_SCC
xpmp_scc_channel_ptr_tbl:
.dw xpmp_channel7
.dw xpmp_channel8
.dw xpmp_channel9
.dw xpmp_channel10
.dw xpmp_channel11

xpmp_scc_jump_tbl:
.dw xpmp_scc_cmd_00
.dw xpmp_scc_cmd_10
.dw xpmp_scc_cmd_20
.dw xpmp_scc_cmd_30
.dw xpmp_scc_cmd_40
.dw xpmp_scc_cmd_50
.dw xpmp_scc_cmd_60
.dw xpmp_scc_cmd_70
.dw xpmp_scc_cmd_80
.dw xpmp_scc_cmd_90
.dw xpmp_scc_cmd_A0
.dw xpmp_scc_cmd_B0
.dw xpmp_scc_cmd_C0
.dw xpmp_scc_cmd_D0
.dw xpmp_scc_cmd_E0
.dw xpmp_scc_cmd_F0
.ENDIF


; YM2151 (FMUNIT)
.IFDEF XPMP_USES_FMUNIT
xpmp_ym_channel_ptr_tbl:
.dw xpmp_channel12
.dw xpmp_channel13
.dw xpmp_channel14
.dw xpmp_channel15
.dw xpmp_channel16
.dw xpmp_channel17
.dw xpmp_channel18
.dw xpmp_channel19

xpmp_ym_jump_tbl:
.dw xpmp_ym_cmd_00
.dw xpmp_ym_cmd_10
.dw xpmp_ym_cmd_20
.dw xpmp_ym_cmd_30
.dw xpmp_ym_cmd_40
.dw xpmp_ym_cmd_50
.dw xpmp_ym_cmd_60
.dw xpmp_ym_cmd_70
.dw xpmp_ym_cmd_80
.dw xpmp_ym_cmd_90
.dw xpmp_ym_cmd_A0
.dw xpmp_ym_cmd_B0
.dw xpmp_ym_cmd_C0
.dw xpmp_ym_cmd_D0
.dw xpmp_ym_cmd_E0
.dw xpmp_ym_cmd_F0
.ENDIF


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


; For AY3-8910 and Konami SCC
ay_freq_tbl:
;.IFDEF XPMP_CPC
;.dw 3420,3228,3047,2876,2714,2562,2418,2282,2154,2033,1919,1811
;.dw 1710,1614,1523,1438,1357,1281,1209,1141,1077,1016,959,905
;.dw 855,807,761,719,678,640,604,570,538,508,479,452
;.dw 427,403,380,359,339,320,302,285,269,254,239,226
;.dw 213,201,190,179,169,160,151,142,134,127,119,113
;.dw 106,100,95,89,84,80,75,71,67,63,59,56
;.dw 53,50,47,44,42,40,37,35,33,31,29,28
;.dw 26,25,23,22,21,20,18,17,16,15,14,14
;.ELSE
.dw 6840, 6457, 6094, 5752, 5429, 5124, 4837, 4565, 4309, 4067, 3839, 3623 
.dw 3420, 3228, 3047, 2876, 2714, 2562, 2418, 2282, 2154, 2033, 1919, 1811 
.dw 1710, 1614, 1523, 1438, 1357, 1281, 1209, 1141, 1077, 1016, 959, 905 
.dw 855, 807, 761, 719, 678, 640, 604, 570, 538, 508, 479, 452 
.dw 427, 403, 380, 359, 339, 320, 302, 285, 269, 254, 239, 226 
.dw 213, 201, 190, 179, 169, 160, 151, 142, 134, 127, 119, 113 
.dw 106, 100, 95, 89, 84, 80, 75, 71, 67, 63, 59, 56 
.dw 53,   50, 47, 44, 42, 40, 37, 35, 33, 31, 29, 28 
;.ENDIF

.IFDEF XPMP_USES_FMUNIT
ym2151_freq_tbl:
.db 14,0,1,2,4,5,6,8,9,10,12,13
.ENDIF


.IFDEF XPMP_USES_SN76489
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
.ENDIF
			


	