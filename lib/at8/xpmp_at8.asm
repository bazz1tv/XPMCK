; Cross Platform Music Player
; Atari 8-bit version
; /Mic, 2011


.EQU XPMP_AUDF1 	$D200
.EQU XPMP_AUDC1 	$D201
.EQU XPMP_AUDIOCTL 	$D208


.DEFINE XPMP_ENABLE_CHANNEL_A
.DEFINE XPMP_ENABLE_CHANNEL_B
.DEFINE XPMP_ENABLE_CHANNEL_C
.DEFINE XPMP_ENABLE_CHANNEL_D

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
.EQU CMD_PULSE	$70
.EQU CMD_ARPOFF $90
.EQU CMD_FILTER $93
.EQU CMD_PULMAC	$95
.EQU CMD_JSR	$96
.EQU CMD_RTS	$97
.EQU CMD_LEN	$9A
.EQU CMD_WRMEM  $9B
.EQU CMD_WRPORT $9C
.EQU CMD_CBOFF  $E0
.EQU CMD_CBONCE $E1
.EQU CMD_CBEVNT $E2
.EQU CMD_CBEVVC $E3
.EQU CMD_CBEVVM $E4
.EQU CMD_CBEVOC $E5
.EQU CMD_DETUNE $ED
.EQU CMD_MULT	$EF
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

; Zeropage RAM addresses used by the player
.EQU xpmp_songTbl	$83
.EQU xpmp_songTblLo $83
.EQU xpmp_songTblHi $84
.EQU xpmp_songNum 	$85
.EQU xpmp_dataPtr 	$87
.EQU xpmp_dataPtrLo $87
.EQU xpmp_dataPtrHi $88
.EQU xpmp_tempZp1	$89
.EQU xpmp_tempZp2	$8A
.EQU xpmp_tempZp3	$8B
.EQU xpmp_effPtr	$8C
.EQU xpmp_command	$8E
.EQU xpmp_channel	$8F





XPMP_VARIABLES:
dataPtr		.dw 0,0,0,0
dataPos		.dw 0,0,0,0
delay		.dw 0,0,0,0
delayHi		.dw 0,0,0,0	; Note delays are 24 bit unsigned fixed point in 16.8 format
note		.dw 0,0,0,0
noteOffs	.dw 0,0,0,0
octave		.dw 0,0,0,0
freq		.dw 0,0,0,0
volume		.dw 0,0,0,0
volOffs		.dw 0,0,0,0
volOffsLatch	.dw 0,0,0,0
freqOffs	.dw 0,0,0,0
freqOffsLatch	.dw 0,0,0,0
detune		.dw 0,0,0,0
vMac		.dw 0,0,0,0
vMacPtr		.dw 0,0,0,0
vMacPos		.dw 0,0,0,0
dtMac		.dw 0,0,0,0
dtMacPtr	.dw 0,0,0,0
dtMacPos	.dw 0,0,0,0
enMac		.dw 0,0,0,0
enMacPtr	.dw 0,0,0,0
enMacPos	.dw 0,0,0,0
epMac		.dw 0,0,0,0
epMacPtr	.dw 0,0,0,0
epMacPos	.dw 0,0,0,0
mpMac		.dw 0,0,0,0
mpMacPtr	.dw 0,0,0,0
mpMacDelay	.dw 0,0,0,0
loop1		.dw 0,0,0,0
loop2		.dw 0,0,0,0
loopIdx		.dw 0,0,0,0
cbEvnote	.dw 0,0,0,0
returnAddr	.dw 0,0,0,0
oldPos		.dw 0,0,0,0
delayLatch	.dw 0,0,0,0
delayLatchHi .dw 0,0,0,0
audc		.dw 0,0,0,0
mode		.dw 0,0,0,0


xpmp_freqChange:	.db 0
xpmp_volChange: 	.db 0
xpmp_lastNote:		.db 0
xpmp_audioctl:		.db 0
xpmp_tempw:		.dw 0
XPMP_VARIABLES_END:


.MACRO ADD_M16_IMM8
	.16bit
	lda	\1
	clc
	adc	#\2
	sta	\1
	lda	\1+1
	adc	#0
	sta	\1+1
	.8bit
.ENDM

.MACRO ADD_M16_M16
	.16bit
	lda	\1
	clc
	adc	\2
	sta	\1
	lda	\1+1
	adc	\2+1
	sta	\1+1
	.8bit
.ENDM

.MACRO ADD_M16_M16_ZP
	lda	\1
	clc
	adc	\2
	sta	\1
	lda	\1+1
	adc	\2+1
	sta	\1+1
.ENDM

.MACRO ADD_DATAPOS
	lda		dataPos.w,x
	clc
	adc		#\1
	sta		dataPos.w,x
	lda		dataPos.w+1,x
	adc		#0
	sta		dataPos.w+1,x
.ENDM

.MACRO ADD_M16_ABSX 
	lda		\1
	clc
	adc.w	\2,x
	sta		\1
	lda		\1+1
	adc.w	\2+1,x
	sta		\1+1
.ENDM

.MACRO ADD_ABSX_IMM8 
	lda.w	\1,x
	clc
	adc		#\2
	sta.w	\1,x
	lda.w	\1+1,x
	adc		#0
	sta.w	\1+1,x
.ENDM

.MACRO ADD_ABSX_M16 
	lda.w	\1,x
	clc
	adc		\2
	sta.w	\1,x
	lda.w	\1+1,x
	adc		\2+1
	sta.w	\1+1,x
.ENDM

.MACRO SUB_ABSX_M16 
	lda.w	\1,x
	sec
	sbc		\2
	sta.w	\1,x
	lda.w	\1+1,x
	sbc		\2+1
	sta.w	\1+1,x
.ENDM


; Initialize the music player
; $03..$04 = pointer to song table, $05 = song number
xpmp_init:
	dec		xpmp_songNum
	asl		xpmp_songNum
	clc
	lda		xpmp_songTbl
	adc		xpmp_songNum
	sta		xpmp_songTbl
	lda		xpmp_songTbl+1
	adc		#0
	sta		xpmp_songTbl+1
	
	; Initialize all the player variables to zero
	lda		#<XPMP_VARIABLES
	sta		<xpmp_dataPtr
	lda		#>XPMP_VARIABLES
	sta		<xpmp_dataPtr+1
	lda		#0
	ldy		#0
	ldx		#>(XPMP_VARIABLES_END - XPMP_VARIABLES)
	beq		+
	-:
	sta		(<xpmp_dataPtr),y
	iny
	bne		-
	inc		<xpmp_dataPtr+1
	dex
	bne		-
+:
	ldx		#<(XPMP_VARIABLES_END - XPMP_VARIABLES)
	-:
	sta		(<xpmp_dataPtr),y
	iny
	dex
	bne		-
	
	; Initialize channel data pointers
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ldy		#0
	lda		(xpmp_songTbl),y
	sta		dataPtr.w+0
	iny
	lda		(xpmp_songTbl),y
	sta		dataPtr.w+1+0
	.ENDIF	
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ldy		#2
	lda		(xpmp_songTbl),y
	sta		dataPtr.w+2
	iny	
	lda		(xpmp_songTbl),y
	sta		dataPtr.w+1+2
	.ENDIF	
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ldy		#4
	lda		(xpmp_songTbl),y
	sta		dataPtr.w+4
	iny
	lda		(xpmp_songTbl),y
	sta		dataPtr.w+1+4
	.ENDIF	
	.IFDEF XPMP_ENABLE_CHANNEL_D
	ldy		#6
	lda		(xpmp_songTbl),y
	sta		dataPtr.w+6
	iny
	lda		(xpmp_songTbl),y
	sta		dataPtr.w+1+6
	.ENDIF	

	; Initialize loop pointers
	lda	#$FF
	.IFDEF XPMP_ENABLE_CHANNEL_A
	sta	loopIdx.w+0
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_B
	sta	loopIdx.w+2
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_C
	sta	loopIdx.w+4
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_D
	sta	loopIdx.w+6
	.ENDIF

	; Initialize the delays for all channels to 1
	lda 	#1
	sta	delayHi.w+0
	sta	delayHi.w+2
	sta	delayHi.w+4
	sta	delayHi.w+6

	; Set 64 kHz clocks for all channels
	lda 	#2
	sta		mode.w+0
	sta		mode.w+2
	sta		mode.w+4
	sta		mode.w+6
	
	; Clear all sound registers
	lda		#0
	sta		$D200
	sta		$D201
	sta		$D202
	sta		$D203
	sta		$D204
	sta		$D205
	sta		$D206
	sta		$D207
	sta		$D208
	
	rts


; xpmp_command contains the command byte
; X contains channel# * 2
; Y contains zero
xpmp_cmd_00:
	lda		<xpmp_command
	cmp		#CMD_VOLUP
	bne		xpmp_cmd_60
	iny
	ADD_DATAPOS 1
	lda		volume.w,x
	clc
	adc		(<xpmp_dataPtr),y
	sta		volume.w,x
	lda		#1
	sta		xpmp_volChange.w	; Volume has changed
	lda		#EFFECT_DISABLED
	sta		vMac.w,x			; Volume set overrides volume macros
	rts
	
xpmp_cmd_60:
	lda		note.w,x
	sta		xpmp_lastNote.w
	lda		<xpmp_command
	and		#$0F
	sta		note.w,x
	lda		<xpmp_command
	and		#$F0
	cmp		#CMD_NOTE2
	beq		xpmp_cmd_00_std_delay
	ADD_DATAPOS 2
	iny
	lda		(<xpmp_dataPtr),y
	bpl		xpmp_cmd_00_short_note
		sta		<xpmp_tempZp1
		iny
		ADD_DATAPOS 1
		lda		<xpmp_tempZp1
		and		#$7F
		lsr		a
		sta		<xpmp_tempZp1
		ror		a
		and		#$80
		ora		(<xpmp_dataPtr),y
		pha
		iny
		lda		(<xpmp_dataPtr),y
		clc
		adc		delay.w,x
		sta		delay.w,x		; Fractional part
		pla
		adc		#0
		sta		delayHi.w,x
		lda		<xpmp_tempZp1
		adc		#0
		sta		delayHi.w+1,x	; Whole part
		jmp		xpmp_cmd_00_got_delay
	xpmp_cmd_00_short_note:	
	sta		<xpmp_tempZp1 ;tax
	iny
	lda		(<xpmp_dataPtr),y
	clc
	adc		delay.w,x
	sta		delay.w,x		; Fractional part
	lda		<xpmp_tempZp1 ;txa
	adc		#0
	beq		xpmp_note_ret
	sta		delayHi.w,x
	lda		#0
	adc		#0
	sta		delayHi.w+1,x	; Whole part
	jmp		xpmp_cmd_00_got_delay
	xpmp_cmd_00_std_delay:
	lda		delay.w,x
	clc
	adc		delayLatch.w,x
	sta		delay.w,x
	lda		#0
	adc		delayLatchHi.w,x
	sta		delayHi.w,x
	lda		#0
	adc		delayLatchHi.w+1,x
	sta		delayHi.w+1,x
	xpmp_cmd_00_got_delay:
	lda		#2
	sta		xpmp_freqChange.w
	lda		note.w,x
	cmp		#CMD_REST
	beq		xpmp_note_ret
	cmp		#CMD_REST2
	beq		xpmp_note_ret
	
	.IFNDEF XPMP_DTMAC_NOT_USED
	lda		dtMac.w,x
	beq		+
	jsr		xpmp_reset_dt_mac
	+:
	.ENDIF
	.IFNDEF XPMP_VMAC_NOT_USED
	lda		vMac.w,x
	beq		+
	jsr		xpmp_reset_v_mac
	+:
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	lda		enMac.w,x
	beq		+
	lda 	#0
	sta 	noteOffs.w,x
	lda		enMac.w,x
	jsr		xpmp_reset_en_mac
	+:
	.ENDIF
	.IFNDEF XPMP_MPMAC_NOT_USED
	lda		mpMac.w,x
	beq		+
	jsr		xpmp_reset_mp_mac
	+:
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	lda		epMac.w,x
	beq		+
	jsr		xpmp_reset_ep_mac
	+:
	.ENDIF
	xpmp_note_ret:
	rts


; Set octave
xpmp_cmd_10:
	dec		<xpmp_command
	lda		<xpmp_command
	and		#$0F
	asl		a
	asl		a
	sta		octave.w,x
	asl		a
	clc
	adc		octave.w,x
	sta		octave.w,x		; Multiplied by 12
	rts	


; Set distortion	
xpmp_cmd_20:
	lda		audc.w,x
	and		#$1F
	sta		audc.w,x
	lda		#0
	sta		dtMac.w,x
	lda		<xpmp_command
xpmp_cmd_20_set_audc:	
	and		#7
	asl		a
	asl		a
	asl		a
	asl		a
	asl		a
	ora		audc.w,x
	sta		audc.w,x
	rts


; Set volume (short)
xpmp_cmd_30:
	lda		<xpmp_command
	and		#$0F
	sta		volume.w,x
	lda		#1
	sta		xpmp_volChange.w	; Volume has changed
	lda		#EFFECT_DISABLED
	sta		vMac.w,x			; Volume set overrides volume macros
	rts

	
; Octave up + note	
xpmp_cmd_40:
	lda		octave.w,x
	clc
	adc		#12
	sta		octave.w,x
	lda		<xpmp_command
	clc
	adc 	#$20
	sta		<xpmp_command
	jmp		xpmp_cmd_60


; Octave down + note
xpmp_cmd_50:
	lda		octave.w,x
	clc
	adc		#$F4
	sta		octave.w,x
	lda		<xpmp_command
	clc
	adc 	#$10
	sta		<xpmp_command
	jmp		xpmp_cmd_60


xpmp_cmd_70:
xpmp_cmd_80:
	rts

	
xpmp_cmd_90:
	lda		<xpmp_command
	cmp		#CMD_ARPOFF
	bne		+

	; Turn off arpeggio macro
	lda		#EFFECT_DISABLED
	sta		enMac.w,x
	sta		noteOffs.w,x
	rts

	+:
	cmp		#CMD_FILTER
	bne		+
	; Set filter
	ADD_DATAPOS 1
	iny
	lda		(<xpmp_dataPtr),y
	sta		<xpmp_tempZp1
	cpx		#0*2
	bne		++
	; channel A
	lda		xpmp_audioctl.w
	and		#$FB
	sta		xpmp_audioctl.w
	jmp		+++
++:
	cpx		#1*2
	bne		+++
	; channel B
	lda		xpmp_audioctl.w
	and		#$FD
	sta		xpmp_audioctl.w
+++:
	lda		<xpmp_tempZp1
	beq		filter_set
	cpx		#0*2
	bne		++
	; channel A
	lda		#4
	ora		xpmp_audioctl.w
	sta		xpmp_audioctl.w
	jmp		+++
++:
	cpx		#1*2
	bne		+++
	; channel B
	lda		#2
	ora		xpmp_audioctl.w
	sta		xpmp_audioctl.w
+++:
filter_set:
	cpx		#2*2
	bcs		++
	lda		xpmp_audioctl.w
	sta		XPMP_AUDIOCTL
++:
	rts

	
	+:
	cmp		#CMD_JSR
	bne		+
	; Jump to pattern
	ADD_DATAPOS 1
	lda		dataPos.w,x
	sta		oldPos.w,x
	lda		dataPos.w+1,x
	sta		oldPos.w+1,x
	lda		dataPtr.w,x
	sta		returnAddr.w,x
	lda		dataPtr.w+1,x
	sta		returnAddr.w+1,x
	iny
	lda		(<xpmp_dataPtr),y
	asl		a
	tay
	lda		xpmp_pattern_tbl.w,y
	sta		dataPtr.w,x
	lda		xpmp_pattern_tbl.w+1,y
	sta		dataPtr.w+1,x
	lda		#$FF
	sta		dataPos.w,x
	sta		dataPos.w+1,x
	rts

	+:
	cmp		#CMD_RTS
	bne		+
	; Return from a pattern
	lda		returnAddr.w,x
	sta		dataPtr.w,x
	lda		returnAddr.w+1,x
	sta		dataPtr.w+1,x
	lda		oldPos.w,x
	sta		dataPos.w,x
	lda		oldPos.w+1,x
	sta		dataPos.w+1,x
	rts
	
	+:
	cmp		#CMD_LEN
	bne		+
	; Set note length
	ADD_DATAPOS 2
	iny
	lda		(<xpmp_dataPtr),y
	bpl		xpmp_cmd_90_short_delay
		sta		<xpmp_tempZp1
		iny
		ADD_DATAPOS 1
		lda		<xpmp_tempZp1
		and		#$7F
		lsr		a
		sta		<xpmp_tempZp1
		ror		a
		and		#$80
		ora		(<xpmp_dataPtr),y
		sta		delayLatchHi.w,x
		iny
		lda		(<xpmp_dataPtr),y
		sta		delayLatch.w,x		; Fractional part
		lda		<xpmp_tempZp1
		sta		delayLatchHi.w+1,x		; Whole part
		rts
	xpmp_cmd_90_short_delay:
	sta		delayLatchHi.w,x
	iny
	lda		(<xpmp_dataPtr),y
	sta		delayLatch.w,x		; Fractional part
	lda		#0
	sta		delayLatchHi.w+1,x	
	rts
	
	+:
	cmp		#CMD_WRMEM
	bne		+
	ADD_DATAPOS 3
	iny	
	lda		(<xpmp_dataPtr),y
	sta		<xpmp_tempZp1
	iny
	lda		(<xpmp_dataPtr),y
	sta		<xpmp_tempZp2
	iny
	lda		(<xpmp_dataPtr),y
	ldy		#0
	sta		(<xpmp_tempZp1),y
	rts
	
	; No ports for you. NEXT!
	+:
	cmp		#CMD_WRPORT
	bne		+
	ADD_DATAPOS 3
	rts
	
	
	+:
	rts
	

xpmp_mode_masks:
.db $10,$EF
.db $08,$F7

; Mode	
xpmp_cmd_A0:
	lda		<xpmp_command
	and		#15
	ldy		#0
	cpx		#2*2
	bcc		+
	ldy		#2		; channel C or D
+:
	cmp		#1
	bne		+
	asl		a
	asl		a
	ora		mode.w,x
	sta		mode.w,x
	lda		xpmp_audioctl.w
	ora		xpmp_mode_masks.w,y			; Combine channels x & x+1
	sta		xpmp_audioctl.w
	sta		XPMP_AUDIOCTL
	rts
	+:
	lda		mode.w,x
	and		#3
	sta		mode.w,x
	lda		xpmp_audioctl.w
	and		xpmp_mode_masks.w+1,y		; Break connection between channel x & x+1
	sta		xpmp_audioctl.w
	sta		XPMP_AUDIOCTL
	rts

	
xpmp_cmd_B0:
xpmp_cmd_C0:
xpmp_cmd_D0:
	rts


xpmp_cmd_E0:
	ADD_DATAPOS 1
	lda		<xpmp_command

	cmp		#CMD_CBOFF
	beq		xpmp_cmd_Ex_cboff
	cmp		#CMD_CBONCE
	beq		xpmp_cmd_Ex_cbonce
	cmp		#CMD_CBEVNT
	beq		xpmp_cmd_Ex_cbevnt
	cmp		#CMD_DETUNE
	beq		xpmp_cmd_Ex_detune
	cmp		#CMD_MULT
	beq		xpmp_cmd_Ex_mult
	rts

	xpmp_cmd_Ex_cboff:
	lda		#0
	sta		cbEvnote.w,x
	sta		cbEvnote.w+1,x
	rts
	
	xpmp_cmd_Ex_cbonce:
	rts
	
	xpmp_cmd_Ex_cbevnt:
	rts
	
	xpmp_cmd_Ex_detune:
	iny
	lda		(<xpmp_dataPtr),y
	sta		detune.w,x
	ldy		#0
	and		#$80
	beq		xpmp_cmd_Ex_detune_pos
	ldy		#$FF
	xpmp_cmd_Ex_detune_pos:
	tya
	sta		detune.w+1,x
	rts
	
	xpmp_cmd_Ex_mult:
	iny
	lda		(<xpmp_dataPtr),y
	and		#3
	sta		xpmp_tempw.w
	lda		mode.w,x
	and 	#4
	ora		xpmp_tempw.w
	sta		mode.w,x
	and		#3
	cmp		#1
	bne		+
	; 15 kHz
	lda		xpmp_audioctl.w
	cpx		#2*2	;.IF \1 < 2
	bcs		++
	; channel A or B
	and		#$BF
	jmp		+++
++:
	; channel C or D
	and		#$DF
+++:
	ora		#1
	sta		xpmp_audioctl.w
	sta		XPMP_AUDIOCTL
	rts
	+:
	cmp		#3
	bne		+
	; CPU clock
	cpx		#2*2
	bcs		++
	; channel A or B
	lda		xpmp_audioctl.w
	ora		#$40
	sta		xpmp_audioctl.w
	sta		XPMP_AUDIOCTL
	jmp		+++
++:
	; channel C or D
	lda		xpmp_audioctl.w
	ora		#$20
	sta		xpmp_audioctl.w
	sta		XPMP_AUDIOCTL
+++:
	rts
	+:
	; 64 kHz
	lda		xpmp_audioctl.w
	and		#$FE
	cpx		#2*2
	bcs		+
	; channel A or B
	and		#$BF
	jmp		++
+:
	; channel C or D
	and		#$DF
++:
	sta		xpmp_audioctl.w
	sta		XPMP_AUDIOCTL
	rts
	
	
xpmp_cmd_F0:
	ADD_DATAPOS 1
	lda		<xpmp_command
	
	cmp		#CMD_JMP
	beq		xpmp_cmd_Fx_jmp
	cmp		#CMD_DJNZ
	beq		xpmp_cmd_Fx_djnz
	cmp		#CMD_LOPCNT
	beq		xpmp_cmd_Fx_lopcnt
	cmp		#CMD_END
	beq		xpmp_cmd_Fx_end
	cmp		#CMD_J1
	beq		xpmp_cmd_Fx_j1
	jmp		Fx_part2

	xpmp_cmd_Fx_djnz:
	stx		<xpmp_tempZp1
	lda		loopIdx.w,x
	clc
	adc		<xpmp_tempZp1
	tax
	dec		loop1.w,x
	bne		xpmp_cmd_Fx_jmp
	ldx		<xpmp_tempZp1
	dec		loopIdx.w,x
	ADD_DATAPOS 1
	rts
	
	xpmp_cmd_Fx_lopcnt:
	iny
	lda		(<xpmp_dataPtr),y
	sta		<xpmp_tempZp1
	inc		loopIdx.w,x
	txa
	clc
	adc		loopIdx.w,x
	tay
	lda		<xpmp_tempZp1
	sta		loop1.w,y
	rts

	xpmp_cmd_Fx_end:
	sta		note.w,x
	lda		#2
	sta		xpmp_freqChange.w
	rts

	xpmp_cmd_Fx_jmp:
	lda		<xpmp_channel
	asl		a
	tax
	iny
	lda		(<xpmp_dataPtr),y
	sta		dataPos.w,x
	iny	
	lda		(<xpmp_dataPtr),y
	sta		dataPos.w+1,x
	dec		dataPos.w,x		; dataPos will be increased after the return, so we decrease it here
	lda		#$FF
	cmp		dataPos.w,x
	bne		+
	dec		dataPos.w+1,x
	+:
	rts

	xpmp_cmd_Fx_j1:
	stx		<xpmp_tempZp1
	lda		loopIdx.w,x
	clc
	adc		<xpmp_tempZp1
	tax
	lda		loop1.w,x
	cmp		#1
	bne		+
	ldx		<xpmp_tempZp1
	dec		loopIdx.w,x	
	jmp		xpmp_cmd_Fx_jmp
	+:
	ldx		<xpmp_tempZp1
	ADD_DATAPOS 1
	rts

	xpmp_cmd_Fx_volmac:
	.IFNDEF XPMP_VMAC_NOT_USED
	iny
	lda		(<xpmp_dataPtr),y
	sta		vMac.w,x
	beq		xpmp_vmac_off
	xpmp_reset_v_mac:
	asl		a
	tay
	dey
	dey
	bcs 	+
	lda		xpmp_v_mac_tbl.w,y
	sta		vMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_v_mac_tbl.w+1,y
	jmp 	++
+:
	lda		xpmp_v_mac_loop_tbl.w,y
	sta		vMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_v_mac_loop_tbl.w+1,y
++:
	sta		vMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		#0
	lda		(<xpmp_tempZp1),y
	sta		volume.w,x
	lda		#1
	sta		vMacPos.w,x
	rts
	xpmp_vmac_off:
	.ENDIF
	rts
	
	xpmp_cmd_Fx_dutmac:
	.IFNDEF XPMP_DTMAC_NOT_USED
	iny
	lda		(<xpmp_dataPtr),y
	sta		dtMac.w,x
	beq		xpmp_dutmac_off
	xpmp_reset_dt_mac:
	asl		a
	tay
	dey
	dey
	lda		audc.w,x
	and		#$1F
	sta		audc.w,x
	lda		xpmp_dt_mac_tbl.w,y
	sta		dtMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_dt_mac_tbl.w+1,y
	sta		dtMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		#0
	lda		#1
	sta		dtMacPos.w,x
	lda		(<xpmp_tempZp1),y
	jsr		xpmp_cmd_20_set_audc
	;and 	#7
	;asl		a
	;asl		a
	;asl		a
	;asl		a
	;asl		a
	;ora		audc.w,x
	;sta		audc.w,x
	xpmp_dutmac_off:
	.ENDIF
	rts

	xpmp_cmd_Fx_swpmac:
	.IFNDEF XPMP_EPMAC_NOT_USED
	iny
	lda		(<xpmp_dataPtr),y
	sta		epMac.w,x
	beq		xpmp_epmac_off
	xpmp_reset_ep_mac:
	asl		a
	tay
	dey
	dey
	lda		xpmp_EP_mac_tbl.w,y
	sta		epMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_EP_mac_tbl.w+1,y
	sta		epMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		#0
	lda		(<xpmp_tempZp1),y
	sta		freqOffs.w,x
	cmp		#$80
	beq		+
	lda		#$FF
	+:
	sta		freqOffs.w+1,x
	lda		#1
	sta		epMacPos.w,x
	rts
	xpmp_epmac_off:
	sta		freqOffs.w,x
	sta		freqOffs.w+1,x
	.ENDIF
	rts

	xpmp_cmd_Fx_volmac_:
	jmp		xpmp_cmd_Fx_volmac

	Fx_part2:
	cmp		#CMD_DUTMAC
	beq		xpmp_cmd_Fx_dutmac
	cmp		#CMD_VOLMAC
	beq		xpmp_cmd_Fx_volmac_
	cmp		#CMD_VIBMAC
	beq		xpmp_cmd_Fx_vibmac
	cmp		#CMD_ARPMAC
	beq		xpmp_cmd_Fx_arpmac
	cmp		#CMD_SWPMAC
	beq		xpmp_cmd_Fx_swpmac
	rts	
	
	xpmp_cmd_Fx_vibmac:
	.IFNDEF XPMP_MPMAC_NOT_USED
	iny
	lda		(<xpmp_dataPtr),y
	sta		mpMac.w,x
	beq		xpmp_mpmac_off
	xpmp_reset_mp_mac:
	asl		a
	tay
	dey
	dey
	lda		xpmp_MP_mac_tbl.w,y
	sta		mpMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_MP_mac_tbl.w+1,y
	sta		mpMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		#0
	lda		(<xpmp_tempZp1),y
	sta		mpMacDelay.w,x
	iny
	iny
	lda		(<xpmp_tempZp1),y
	sta		freqOffsLatch.w,x
	lda		#0
	sta		freqOffsLatch.w+1,x
	ADD_ABSX_IMM8 mpMacPtr,1
	rts
	xpmp_mpmac_off:
	sta		freqOffs.w,x
	sta		freqOffs.w+1,x
	.ENDIF
	rts

	xpmp_cmd_Fx_arpmac:
	iny
	lda 	#0
	sta 	noteOffs.w,x
	lda		(<xpmp_dataPtr),y
	sta		enMac.w,x
	beq		xpmp_arpmac_off
	xpmp_reset_en_mac:
	asl		a
	tay
	dey
	dey
	bcs 	+
	lda		xpmp_EN_mac_tbl.w,y
	sta		enMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_EN_mac_tbl.w+1,y
	jmp 	++
+:
	lda		xpmp_EN_mac_loop_tbl.w,y
	sta		enMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_EN_mac_loop_tbl.w+1,y
++:
	sta		enMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		#0
	lda		(<xpmp_tempZp1),y
	clc
	adc 	noteOffs.w,x
	sta		noteOffs.w,x
	lda		#1
	sta		enMacPos.w,x
	rts
	xpmp_arpmac_off:
	rts
	


xpmp_update_:
	sta		<xpmp_channel
	asl		a
	tax
	
	lda		#0
	sta		xpmp_freqChange.w
	sta		xpmp_volChange.w

	lda		note.w,x
	cmp		#CMD_END
	bne		+
	rts					; Playback has ended for this channel - all processing should be skipped
	+:
	
	dec		delayHi.w,x
	lda		#$FF
	cmp		delayHi.w,x
	bne		+
	dec		delayHi.w+1,x
	+:
	lda		delayHi.w,x
	ora		delayHi.w+1,x
	bne		xpmp_update_effects
	
	jsr		xpmp_read_commands
	rts
	
	xpmp_update_effects:
	.IFNDEF XPMP_VMAC_NOT_USED
	lda		vMac.w,x
	beq		xpmp_update_v_done
	xpmp_update_v:
	lda		#1
	sta		xpmp_volChange.w
	lda		vMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		vMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		vMacPos.w,x
	lda		(<xpmp_tempZp1),y
	cmp		#$80
	beq		xpmp_update_v_loop
	sta		volume.w,x
	inc		vMacPos.w,x
	jmp		xpmp_update_v_done
	xpmp_update_v_loop:
	lda		vMac.w,x
	ora 	#$80
	jsr 	xpmp_reset_v_mac
	xpmp_update_v_done:
	.ENDIF
	
	.IFNDEF XPMP_ENMAC_NOT_USED
	lda		enMac.w,x
	beq		xpmp_update_EN_done
	xpmp_update_EN:
	lda		#1
	sta		xpmp_freqChange.w
	lda		enMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		enMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		enMacPos.w,x
	lda		(<xpmp_tempZp1),y
	cmp		#$80
	beq		xpmp_update_EN_loop
	clc
	adc		noteOffs.w,x
	sta		noteOffs.w,x
	inc		enMacPos.w,x
	jmp		xpmp_update_EN_done
	xpmp_update_EN_loop:
	lda		enMac.w,x
	ora 	#$80
	jsr 	xpmp_reset_en_mac
	xpmp_update_EN_done:
	.ENDIF

	.IFNDEF XPMP_DTMAC_NOT_USED
	lda		dtMac.w,x
	beq		xpmp_update_DT_done
	xpmp_update_DT:
	lda		audc.w,x
	and		#$1F
	sta		audc.w,x
	lda		#1
	sta		xpmp_volChange.w
	lda		dtMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		dtMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		dtMacPos.w,x
	lda		(xpmp_tempZp1),y
	cmp		#$80
	beq		xpmp_update_DT_loop
	inc		dtMacPos.w,x
	;and		#7
	;asl		a
	;asl		a
	;asl		a
	;asl		a
	;asl		a
	;ora		audc.w,x
	;sta		audc.w,x
	jmp		xpmp_update_DT_set_audc ;xpmp_update_DT_done
	xpmp_update_DT_loop:
	lda		dtMac.w,x
	asl		a
	tay
	dey
	dey
	lda		xpmp_dt_mac_loop_tbl.w,y
	sta		dtMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_dt_mac_loop_tbl.w+1,y
	sta		dtMacPtr.w+1,x
	sta		<xpmp_tempZp2
	lda		#1
	sta		dtMacPos.w,x
	ldy		#0
	lda		(<xpmp_tempZp1),y
	xpmp_update_DT_set_audc:
	;and		#7
	;asl		a
	;asl		a
	;asl		a
	;asl		a
	;asl		a
	;ora		audc.w,x
	;sta		audc.w,x
	jsr		xpmp_cmd_20_set_audc
	xpmp_update_DT_done:
	.ENDIF

	
	.IFNDEF XPMP_EPMAC_NOT_USED
	lda		epMac.w,x
	beq		xpmp_update_EP_done
	xpmp_update_EP:
	lda		#1
	sta		xpmp_freqChange.w
	lda		epMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		epMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		epMacPos.w,x
	lda		(<xpmp_tempZp1),y
	cmp		#$80
	beq		xpmp_update_EP_loop
	sta		<xpmp_tempZp1
	and		#$80
	beq		+
	lda		#$FF
	+:
	sta		xpmp_tempZp2
	ADD_ABSX_M16 freqOffs,xpmp_tempZp1
	inc		epMacPos.w,x
	jmp		xpmp_update_EP_done
	xpmp_update_EP_loop:
	lda		epMac.w,x
	asl		a
	tay
	dey
	dey
	lda		xpmp_EP_mac_loop_tbl.w,y
	sta		epMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_EP_mac_loop_tbl.w+1,y
	sta		epMacPtr.w+1,x
	sta		<xpmp_tempZp2
	lda		#1
	sta		epMacPos.w,x
	ldy		#0
	lda		(<xpmp_tempZp1),y
	sta		<xpmp_tempZp1
	and		#$80
	beq		+
	lda		#$FF
	+:
	sta		<xpmp_tempZp2
	ADD_ABSX_M16 freqOffs,xpmp_tempZp1
	xpmp_update_EP_done:
	.ENDIF
	
	.IFNDEF XPMP_MPMAC_NOT_USED
	; Vibrato
	lda 	mpMac.w,x
	beq 	xpmp_update_MP_done
	lda		mpMacDelay.w,x
	sec
	sbc		#1
	bne		xpmp_update_MP_done2
	xpmp_update_MP:
	lda		#1
	sta		xpmp_freqChange.w		; Frequency has changed
	lda		mpMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		mpMacPtr.w+1,x
	sta		<xpmp_tempZp2
	lda		freqOffsLatch.w,x
	sta		freqOffs.w,x
	eor		#$FF
	clc
	adc		#1
	sta		freqOffsLatch.w,x
	lda		freqOffsLatch.w+1,x
	sta		freqOffs.w+1,x
	eor		#$FF
	adc		#0
	sta		freqOffsLatch.w+1,x
	ldy		#0
	lda		(<xpmp_tempZp1),y
	xpmp_update_MP_done2:
	sta		mpMacDelay.w,x
	xpmp_update_MP_done:
	.ENDIF
	
	lda		xpmp_freqChange.w
	bne		xpmp_update_freq_change
	jmp		xpmp_update_set_vol
	
	rts
	

xpmp_read_commands:
	lda		<xpmp_channel
	asl		a
	tax
	lda		dataPtr.w,x
	clc
	adc		dataPos.w,x
	sta		<xpmp_dataPtrLo
	lda		dataPtr.w+1,x
	adc		dataPos.w+1,x
	sta		<xpmp_dataPtrHi
	ldy		#0
	lda		(<xpmp_dataPtr),y		; Read the first byte of the command
	sta		<xpmp_command
	lsr		a
	lsr		a
	lsr 	a
	and		#$FE
	tax	
	lda		xpmp_jump_tbl.w,x
	sta		xpmp_tempw.w
	lda		xpmp_jump_tbl.w+1,x
	sta		xpmp_tempw.w+1			; Get the command handler address and store it in xpmp_tempw
	lda		<xpmp_channel
	asl		a
	tax
	jsr		xpmp_call_indirect		; Jump to the command handler
	ADD_DATAPOS 1

	lda		xpmp_freqChange.w
	cmp		#2				; Have we read a note/rest/end command?
	bne		xpmp_read_commands
	
	xpmp_update_freq_change:
	lda		<xpmp_channel
	asl		a
	tax	
	lda		note.w,x
	cmp		#CMD_REST2
	bne		xpmp_update_check_rest
	jmp		xpmp_rest2
	xpmp_update_check_rest:
	cmp		#CMD_REST
	bne		xpmp_update_check_end
	jmp		xpmp_rest
	xpmp_update_check_end:
	cmp		#CMD_END
	bne		xpmp_update_cmd_ok
	jmp		xpmp_rest
	xpmp_update_cmd_ok:

	xpmp_update_freq_change_2:
	;lda		note.w,x
	clc
	adc		noteOffs.w,x
	sta		<xpmp_tempZp1
	lda		octave.w,x
	adc		<xpmp_tempZp1
	asl		a
	tay
	
	lda 	mode.w,x
	cpx		#0*2
	beq		++
	cpx		#2*2
	beq		++
	; channel B or D
	cmp 	#7
	bne 	+
	lda 	xpmp_freq_tbl_cpu.w+1,y
	sec 
	sbc 	#3
	sta		freq+1.w,x
	lda 	xpmp_freq_tbl_cpu.w,y
	sbc 	#0
	sta		freq.w,x
	jmp 	xpmp_update_got_freq
	+:
	cmp 	#3
	bne 	+
	lda 	xpmp_freq_tbl_cpu.w,y
	sta		freq.w,x
	lda 	xpmp_freq_tbl_cpu.w+1,y
	sta		freq.w+1,x
	jmp 	xpmp_update_got_freq
	+:
++:
	tya
	lsr		a
	tay
	lda 	mode.w,x
	cmp 	#1
	bne 	+
	lda 	xpmp_freq_tbl_15khz.w,y
	sta		freq.w,x
	lda 	#0
	sta		freq.w+1,x
	jmp 	xpmp_update_got_freq
+:
	lda 	xpmp_freq_tbl_64khz.w,y
	sta		freq.w,x
	lda 	#0
	sta		freq.w+1,x

xpmp_update_got_freq:
	; Add detune and freqOffs
	lda		detune.w,x
	sta		<xpmp_tempZp1
	lda		detune.w+1,x
	sta		<xpmp_tempZp2
	ADD_M16_ABSX xpmp_tempZp1,freqOffs
	ADD_M16_M16_ZP xpmp_tempZp1,xpmp_tempZp1
	SUB_ABSX_M16 freq,xpmp_tempZp1
	
jmp xpmp_update_freq_ok

	; Clip frequency if out of range
	lda		freq.w+1
	bmi		xpmp_update_freq_too_low
	;beq		xpmp_update_\1_freq_might_be_too_low
	cmp		#$FD
	beq		xpmp_update_freq_might_be_too_high
	bcs		xpmp_update_freq_too_high
	jmp		xpmp_update_freq_ok

	xpmp_update_freq_might_be_too_high:
	;lda		xpmp_channel\1.freq.w
	;cmp		#$24
	;bcc		xpmp_update_\1_freq_ok
	xpmp_update_freq_too_high:
	;lda		#$23
	;sta		xpmp_channel.freq.w
	;lda		#$FD
	;sta		xpmp_channel.freq.w+1
	;jmp		xpmp_update_freq_ok

	xpmp_update_freq_might_be_too_low:
	;lda		xpmp_channel\1.freq.w+1
	;cmp		#$0C
	;bcs		xpmp_update_\1_freq_ok
	xpmp_update_freq_too_low:
	;lda		#$0C
	;sta		xpmp_channel\1.freq.w
	;lda		#$01
	;sta		xpmp_channel\1.freq.w+1
	
	xpmp_update_freq_ok:
	lda		freq.w,x
	sta.w	XPMP_AUDF1,x
	cpx		#1*2
	bne		+
	lda		mode.w,x
	and		#4
	beq		+
	lda		freq.w+1,x
	sta.w	XPMP_AUDF1		; set freq for chn A
	+:
	cpx		#3*2
	bne		+
	lda		mode.w,x
	and		#4
	beq		+
	lda		freq.w+1,x
	sta.w	XPMP_AUDF1+4	; set freq for chn C
	+:
	
	lda		xpmp_lastNote.w
	cmp		#CMD_REST
	bne		xpmp_update_set_vol_2
	jmp		xpmp_update_set_vol_3

	; Mute the channel 
	xpmp_rest:
	lda		#0
	sta.w	XPMP_AUDC1,x
	xpmp_rest2:
	rts
	
	xpmp_update_set_vol:
	lda		note.w,x
	cmp		#CMD_REST
	beq		xpmp_rest
	xpmp_update_set_vol_2:
	; Update the volume if it has changed
	lda		xpmp_volChange.w
	beq		xpmp_update_no_vol_change
	xpmp_update_set_vol_3:
	lda		volume.w,x
	ora		audc.w,x
	sta.w	XPMP_AUDC1,x
	xpmp_update_no_vol_change:
	rts
		

xpmp_call_indirect:
	jmp		(xpmp_tempw.w)
	


xpmp_update:
	lda		#0
	jsr		xpmp_update_
	lda		#1
	jsr		xpmp_update_
	lda		#2
	jsr		xpmp_update_
	lda		#3
	jsr		xpmp_update_
	rts
	

xpmp_jump_tbl:
.dw xpmp_cmd_00
.dw xpmp_cmd_10
.dw xpmp_cmd_20
.dw xpmp_cmd_30
.dw xpmp_cmd_40
.dw xpmp_cmd_50
.dw xpmp_cmd_60
.dw xpmp_cmd_70
.dw xpmp_cmd_80
.dw xpmp_cmd_90
.dw xpmp_cmd_A0
.dw xpmp_cmd_B0
.dw xpmp_cmd_C0
.dw xpmp_cmd_D0
.dw xpmp_cmd_E0
.dw xpmp_cmd_F0


; Octaves 1-12
xpmp_freq_tbl_15khz:
.db $00EF,$00E2,$00D5,$00C9,$00BE,$00B3,$00A9,$009F,$0096,$008E,$0086,$007E	; Lowest playable note is C1
.db $0077,$0070,$006A,$0064,$005E,$0059,$0054,$004F,$004B,$0046,$0042,$003F
.db $003B,$0038,$0034,$0031,$002F,$002C,$0029,$0027,$0025,$0023,$0021,$001F
.db $001D,$001B,$001A,$0018,$0017,$0015,$0014,$0013,$0012,$0011,$0010,$000F
.db $000E,$000D,$000C,$000C,$000B,$000A,$000A,$0009,$0008,$0008,$0007,$0007	; Highest sane note is D5
.db $0007,$0006,$0006,$0005,$0005,$0005,$0004,$0004,$0004,$0003,$0003,$0003
.db $0003,$0003,$0002,$0002,$0002,$0002,$0002,$0002,$0001,$0001,$0001,$0001
.db $0001,$0001,$0001,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	; Highest playable note is A#9
.db $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$FF
;.dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
;.dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
;.dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

xpmp_freq_tbl_64khz:
;.dw $03D0,$0399,$0366,$0335,$0307,$02DB,$02B2,$028B,$0267,$0244,$0223,$0205
;.dw $01E8,$01CC,$01B2,$019A,$0183,$016D,$0159,$0145,$0133,$0122,$0111,$0102
 .db $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
 .db $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
.db $00F3,$00E6,$00D9,$00CC,$00C1,$00B6,$00AC,$00A2,$0099,$0090,$0088,$0080	; Lowest playable note is C3
.db $0079,$0072,$006C,$0066,$0060,$005B,$0055,$0051,$004C,$0048,$0044,$0040
.db $003C,$0039,$0035,$0032,$002F,$002D,$002A,$0028,$0025,$0023,$0021,$001F
.db $001E,$001C,$001A,$0019,$0017,$0016,$0015,$0013,$0012,$0011,$0010,$000F
.db $000E,$000D,$000D,$000C,$000B,$000A,$000A,$0009,$0009,$0008,$0008,$0007	; Highest sane note is F7
.db $0007,$0006,$0006,$0005,$0005,$0005,$0004,$0004,$0004,$0004,$0003,$0003
.db $0003,$0003,$0002,$0002,$0002,$0002,$0002,$0002,$0001,$0001,$0001,$0001
.db $0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000	; Highest playable note is B11
.db $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;.dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

xpmp_freq_tbl_cpu:
.dw $E669,$F463,$585E,$0C59,$0D54,$554F,$E14A,$AD46,$B542,$F63E,$6D3B,$1738	; Lowest playable note is C1 (16-bit channels)
.dw $F134,$F831,$2A2F,$842C,$042A,$A827,$6E25,$5423,$5821,$791F,$B51D,$0A1C
.dw $771A,$FA18,$9317,$4016,$0015,$D213,$B512,$A811,$AA10,$BB0F,$D80E,$030E
.dw $390D,$7B0C,$C80B,$1E0B,$7E0A,$E709,$5909,$D208,$5308,$DB07,$6A07,$FF06
.dw $9B06,$3C06,$E205,$8D05,$3D05,$F204,$AA04,$6704,$2804,$EC03,$B303,$7E03
.dw $4B03,$1C03,$EF02,$C502,$9D02,$7702,$5302,$3202,$1202,$F401,$D801,$BD01
.dw $A401,$8C01,$7501,$6001,$4C01,$3901,$2801,$1701,$0701,$F800,$EA00,$DC00	; Lowest playable note is A7 (8-bit channels)
.dw $D000,$C400,$B900,$AE00,$A400,$9B00,$9200,$8900,$8100,$7A00,$7300,$6C00
.dw $6600,$6000,$5A00,$5500,$5000,$4B00,$4700,$4300,$3F00,$3B00,$3700,$3400
.dw $3100,$2E00,$2B00,$2900,$2600,$2400,$2100,$1F00,$1D00,$1B00,$1A00,$1800
.dw $1600,$1500,$1400,$1200,$1100,$1000,$0F00,$0E00,$0D00,$0C00,$0B00,$0A00
.dw $0900,$0800,$0800,$0700,$0700,$0600,$0500,$0500,$0400,$0400,$0300,$0300	; Highest sane note is C#12. Highest playable note is B12





