; Cross Platform Music Player
; PC-Engine/TurboGrafx version
; /Mic, 2011


.IFNDEF XPMP_RAM_START
.DEFINE XPMP_RAM_START $3000
.ENDIF

.IFNDEF XPMP_ZP_BASE
.DEFINE XPMP_ZP_BASE $20
.ENDIF

.IFNDEF XPMP_IO_BASE
.DEFINE XPMP_IO_BASE $0000
.ENDIF

.define XPMP_PSG_CHANNEL_SELECT		XPMP_IO_BASE+$0800
.define XPMP_PSG_GLOBAL_BALANCE		XPMP_IO_BASE+$0801
.define XPMP_PSG_FREQ_FINE			XPMP_IO_BASE+$0802
.define XPMP_PSG_FREQ_COARSE		XPMP_IO_BASE+$0803
.define XPMP_PSG_CHANNEL_CTRL		XPMP_IO_BASE+$0804
.define XPMP_PSG_CHANNEL_BALANCE	XPMP_IO_BASE+$0805
.define XPMP_PSG_CHANNEL_WAVE		XPMP_IO_BASE+$0806
.define XPMP_PSG_NOISE_CTRL			XPMP_IO_BASE+$0807
.define XPMP_PSG_LFO_FREQ			XPMP_IO_BASE+$0808
.define XPMP_PSG_LFO_CTRL			XPMP_IO_BASE+$0809

.define XPMP_TIMER_COUNTER			XPMP_IO_BASE+$0C00
.define XPMP_TIMER_CTRL				XPMP_IO_BASE+$0C01

.define XPMP_INTERRUPT_CTRL			XPMP_IO_BASE+$1402
.define XPMP_INTERRUPT_STATUS		XPMP_IO_BASE+$1403


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
.EQU CMD_MODMAC $EB
.EQU CMD_LDWAVE $EC
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

.ENUM XPMP_ZP_BASE
xpmp_songTblLo	ds 1
xpmp_songTblHi	ds 1
xpmp_songNum	ds 1
xpmp_indPtr		ds 2
xpmp_dataPtr	ds 2
xpmp_channel	ds 1
xpmp_command	ds 1
xpmp_tempZp1	ds 1
xpmp_tempZp2	ds 1
xpmp_tempZp3	ds 1
xpmp_tempZp4	ds 1
xpmp_ddaPtr		ds 3
xpmp_ddaEnable	ds 1
xpmp_frameCnt	ds 1
.ENDE

.ENUM XPMP_RAM_START
dataPtr		ds 12
dataPos		ds 12
delay		ds 12
delayHi		ds 12
note		ds 12
noteOffs	ds 12
octave		ds 12
duty		ds 12
freq		ds 12
volume		ds 12
volOffs		ds 12
volOffsLatch ds 12
freqOffs	ds 12
freqOffsLatch	ds 12
detune		ds 12
vMac		ds 12
vMacPtr		ds 12
vMacPos		ds 12
dtMac		ds 12
dtMacPtr	ds 12
dtMacPos	ds 12
csMac		ds 12
csMacPtr	ds 12
csMacPos	ds 12
enMac		ds 12
enMacPtr	ds 12
enMacPos	ds 12
epMac		ds 12
epMacPtr	ds 12
epMacPos	ds 12
mpMac		ds 12
mpMacPtr	ds 12
mpMacDelay	ds 12
loop1		ds 12
loop2		ds 12
loopIdx		ds 12
cbEvnote	ds 12
returnAddr	ds 12
oldPos		ds 12
delayLatch	ds 12
delayLatchHi	ds 12
transpose	ds 12

xpmp_freqChange	db
xpmp_volChange 	db 
xpmp_lastNote	db 
xpmp_tempw		dw
XPMP_RAM_END	ds 1
.ENDE


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
	lda		xpmp_songTblLo
	adc		xpmp_songNum
	sta		xpmp_songTblLo
	lda		xpmp_songTblHi	
	adc		#0
	sta		xpmp_songTblHi
	
	; Clear RAM
	stz		XPMP_RAM_START
	tii		XPMP_RAM_START,XPMP_RAM_START+1,XPMP_RAM_END-XPMP_RAM_START

    lda		#$FF
    sta		XPMP_PSG_GLOBAL_BALANCE
    lda		#$00 ;$80
    sta		XPMP_PSG_LFO_CTRL			; LFO off

	; Turn all channels off
	cla
	ldx		#$FF
-:
    sta		XPMP_PSG_CHANNEL_SELECT
    stz		XPMP_PSG_CHANNEL_CTRL
    stz		XPMP_PSG_NOISE_CTRL
    stx.w	XPMP_PSG_CHANNEL_BALANCE
	ina
	cmp		#6
	bne		-
	
	; Initialize channel data pointers
	ldy		#0
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+0
	iny
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+1+0

	ldy		#2
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+2
	iny	
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+1+2

	ldy		#4
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+4
	iny
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+1+4

	ldy		#6
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+6
	iny
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+1+6

	ldy		#8
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+8
	iny
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+1+8
	
	ldy		#10
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+10
	iny
	lda		(xpmp_songTblLo),y
	sta		dataPtr.w+1+10
	
	; Initialize loop pointers
	lda		#$FF
	sta		loopIdx.w+0
	sta		loopIdx.w+2
	sta		loopIdx.w+4
	sta		loopIdx.w+6
	sta		loopIdx.w+8
	sta		loopIdx.w+10

	; Channel balance
	sta		volume.w+1+0
	sta		volume.w+1+2
	sta		volume.w+1+4
	sta		volume.w+1+6
	sta		volume.w+1+8
	sta		volume.w+1+10
	
	stz		<xpmp_ddaEnable
	
	; Initialize the delays for all channels to 1
	lda 	#1
	sta		delayHi.w+0
	sta		delayHi.w+2
	sta		delayHi.w+4
	sta		delayHi.w+6
	sta		delayHi.w+8
	sta		delayHi.w+10

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
	bra		+
	
	xpmp_note_ret:
	rts
	+:
	.IFNDEF XPMP_DTMAC_NOT_USED
	lda		dtMac.w,x
	beq		+
	bmi		++
	jsr		xpmp_reset_dt_mac
	bra		+
	++:
	jsr		xpmp_step_dt
	+:
	.ENDIF
	.IFNDEF XPMP_VMAC_NOT_USED
	lda		vMac.w,x
	beq		+
	bmi		++
	jsr		xpmp_reset_v_mac
	bra		+
	++:
	jsr		xpmp_step_v
	+:
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	lda		enMac.w,x
	beq		+
	bmi		++
	stz 	noteOffs.w,x
	jsr		xpmp_reset_en_mac
	bra		+
	++:
	jsr		xpmp_step_en
	+:
	.ENDIF
	.IFNDEF XPMP_MPMAC_NOT_USED
	lda		mpMac.w,x
	beq		+
	bmi		++
	jsr		xpmp_reset_mp_mac
	bra		+
	++:
	jsr		xpmp_step_mp
	+:
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	lda		epMac.w,x
	beq		+
	bmi		++
	jsr		xpmp_reset_ep_mac
	bra		+
	++:
	jsr		xpmp_step_ep
	+:
	.ENDIF
	lda		csMac.w,x
	beq		+
	bmi		++
	jsr		xpmp_reset_cs_mac
	bra		+
	++:
	jsr		xpmp_step_cs
	+:
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
	stz		dtMac.w,x
	lda		<xpmp_command
	and		#15
xpmp_new_duty:
	cmp		duty.w,x
	beq		+
	sta		duty.w,x
	cpx		#4*2
	bcc		+
	cmp		#0
	bne		++
	stz.w	XPMP_PSG_NOISE_CTRL
++:
	lda		#1
	sta		xpmp_freqChange.w
+:	
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
	

; Mode	
xpmp_cmd_A0:
	cpx		#3*2
	bne		+
	lda		#1
	sta		xpmp_volChange
	lda		<xpmp_command
	and		#15
	cmp		#2
	bne		disable_dda
	lda		#$40
	sta		<xpmp_ddaEnable
	rts
disable_dda:
	stz		<xpmp_ddaEnable
+:
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
	cmp		#CMD_MODMAC
	beq		xpmp_cmd_Ex_modmac
	cmp		#CMD_LDWAVE
	beq		xpmp_cmd_Ex_ldwave
	rts

	xpmp_cmd_Ex_cboff:
	stz		cbEvnote.w,x
	stz		cbEvnote.w+1,x
	rts
	
	xpmp_cmd_Ex_cbonce:
	rts
	
	xpmp_cmd_Ex_cbevnt:
	rts
	
	xpmp_cmd_Ex_detune:
	iny
	lda		(<xpmp_dataPtr),y
	sta		detune.w,x
	cly
	and		#$80
	beq		xpmp_cmd_Ex_detune_pos
	ldy		#$FF
	xpmp_cmd_Ex_detune_pos:
	tya
	sta		detune.w+1,x
	rts

	xpmp_cmd_Ex_modmac:
	iny
	lda		(<xpmp_dataPtr),y
	beq		xpmp_modmac_off
	and		#$3F
	asl		a
	tay
	dey
	dey
	lda		xpmp_MOD_tbl.w,y
	sta		<xpmp_tempZp1
	lda		xpmp_MOD_tbl.w+1,y
	sta		<xpmp_tempZp2
	cly
	lda		(<xpmp_tempZp1),y
	sta.w	XPMP_PSG_LFO_FREQ
	iny
	lda		(<xpmp_tempZp1),y
	and		#3
;ora #$80
	sta.w	XPMP_PSG_LFO_CTRL
	rts
	xpmp_modmac_off:
	lda		#$00 ;80
	sta.w	XPMP_PSG_LFO_CTRL
	rts	

	xpmp_cmd_Ex_ldwave:
	iny
	lda		(<xpmp_dataPtr),y
	dea
	sta		<xpmp_indPtr
	stz		<xpmp_indPtr+1
	asl		<xpmp_indPtr
	rol		<xpmp_indPtr+1
	asl		<xpmp_indPtr
	rol		<xpmp_indPtr+1
	asl		<xpmp_indPtr
	rol		<xpmp_indPtr+1
	asl		<xpmp_indPtr
	rol		<xpmp_indPtr+1
	asl		<xpmp_indPtr
	rol		<xpmp_indPtr+1
	lda		<xpmp_indPtr
	clc
	adc		#<xpmp_waveform_data
	sta		<xpmp_indPtr
	lda		<xpmp_indPtr+1
	adc		#>xpmp_waveform_data
	sta		<xpmp_indPtr+1
    lda		#$40
    sta.w	XPMP_PSG_CHANNEL_CTRL	; reset waveform position
    stz.w	XPMP_PSG_CHANNEL_CTRL	; set waveform write mode
    cly
	-:
   	lda		(<xpmp_indPtr),y
   	sta.w	XPMP_PSG_CHANNEL_WAVE
   	iny
   	cpy		#32
   	bne		-
   	lda		volume.w,x
   	ora		#$80
   	sta.w	XPMP_PSG_CHANNEL_CTRL
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
	;lda		loopIdx.w,x
	;cmp		#1
	;bne		+
	;dec		loopIdx.w,x
	;jmp		xpmp_cmd_Fx_jmp
	;+:
	;ADD_DATAPOS 1
	;rts
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
	;dec		loopIdx.w,x
	ADD_DATAPOS 1
	rts
	
	xpmp_cmd_Fx_volmac:
	.IFNDEF XPMP_VMAC_NOT_USED
	iny
	lda		(<xpmp_dataPtr),y
	sta		vMac.w,x
	beq		xpmp_vmac_off
	xpmp_reset_v_mac:
	sta		<xpmp_tempZp1
	and		#$3F
	asl		a
	tay
	dey
	dey
	bit		<xpmp_tempZp1
	bvs		+ ;bcs 	+
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
	lda		(<xpmp_tempZp1)
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
	sta		<xpmp_tempZp1
	and		#$3F
	asl		a
	tay
	dey
	dey
	lda		xpmp_dt_mac_tbl.w,y
	sta		dtMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_dt_mac_tbl.w+1,y
	sta		dtMacPtr.w+1,x
	sta		<xpmp_tempZp2
	lda		(<xpmp_tempZp1)
	jsr		xpmp_new_duty
	lda		#1
	sta		dtMacPos.w,x
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
	and		#$7F
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
	lda		(<xpmp_tempZp1)
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
	jmp		Fx_part3	
	
	xpmp_cmd_Fx_vibmac:
	.IFNDEF XPMP_MPMAC_NOT_USED
	iny
	lda		(<xpmp_dataPtr),y
	sta		mpMac.w,x
	beq		xpmp_mpmac_off
	xpmp_reset_mp_mac:
	and		#$7F
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
	cly
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
	stz 	noteOffs.w,x
	lda		(<xpmp_dataPtr),y
	sta		enMac.w,x
	beq		xpmp_arpmac_off
	xpmp_reset_en_mac:
	sta		<xpmp_tempZp1
	and		#$3F
	asl		a
	tay
	dey
	dey
	bit		<xpmp_tempZp1
	bvs		+ ;bcs 	+
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
	lda		(<xpmp_tempZp1)
	clc
	adc 	noteOffs.w,x
	sta		noteOffs.w,x
	lda		#1
	sta		enMacPos.w,x
	rts
	xpmp_arpmac_off:
	rts

	Fx_part3:
	cmp		#CMD_PANMAC
	beq		xpmp_cmd_Fx_panmac
	cmp		#CMD_VOLSET
	beq		xpmp_cmd_Fx_volset
	rts

	xpmp_cmd_Fx_volset:
	iny
	lda		(<xpmp_dataPtr),y
	and		#31
	sta		volume.w,x
	lda		#1
	sta		xpmp_volChange.w
	stz		vMac.w,x
	rts
	
	xpmp_cmd_Fx_panmac:
	iny
	lda		(<xpmp_dataPtr),y
	sta		csMac.w,x
	beq		xpmp_csmac_off
	xpmp_reset_cs_mac:
	sta		<xpmp_tempZp1
	and		#$3F
	asl		a
	tay
	dey
	dey
	bit		<xpmp_tempZp1
	bvs		+  ;bcs 	+
	lda		xpmp_CS_mac_tbl.w,y
	sta		csMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_CS_mac_tbl.w+1,y
	jmp 	++
+:
	lda		xpmp_CS_mac_loop_tbl.w,y
	sta		csMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		xpmp_CS_mac_loop_tbl.w+1,y
++:
	sta		csMacPtr.w+1,x
	sta		<xpmp_tempZp2
	lda		(<xpmp_tempZp1)
	sta		volume.w+1,x
	sta.w	XPMP_PSG_CHANNEL_BALANCE
	lda		#1
	sta		csMacPos.w,x
	rts
	xpmp_csmac_off:
	lda		#$FF
	sta.w	XPMP_PSG_CHANNEL_BALANCE
	rts
	

xpmp_update_:
	sta		<xpmp_channel
	sta.w	XPMP_PSG_CHANNEL_SELECT
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
	jsr		xpmp_step_v_frame
	jsr		xpmp_step_cs_frame
	jsr		xpmp_step_en_frame
	jsr		xpmp_step_dt_frame
	jsr		xpmp_step_ep_frame
	jsr		xpmp_step_mp_frame

	lda		xpmp_freqChange.w
	beq		+
	jmp		xpmp_update_freq_change
	+:
	jmp		xpmp_update_set_vol
	
	xpmp_step_v_frame:
	lda		vMac.w,x
	bpl		xpmp_step_v
	rts
	xpmp_step_v:
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
	ora 	#$40
	jsr 	xpmp_reset_v_mac
	xpmp_update_v_done:
	.ENDIF
	rts
	
	xpmp_step_cs_frame:
	lda		csMac.w,x
	bpl		xpmp_step_cs
	rts
	xpmp_step_cs:
	lda		csMac.w,x
	beq		xpmp_update_cs_done
	xpmp_update_cs:
	lda		csMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		csMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		csMacPos.w,x
	lda		(<xpmp_tempZp1),y
	cmp		#$00 ;80
	beq		xpmp_update_cs_loop
	sta		volume.w+1,x
	sta.w	XPMP_PSG_CHANNEL_BALANCE
	inc		csMacPos.w,x
	jmp		xpmp_update_cs_done
	xpmp_update_cs_loop:
	lda		csMac.w,x
	ora 	#$40
	jsr 	xpmp_reset_cs_mac
	xpmp_update_cs_done:
	rts
	
	xpmp_step_en_frame:
	lda		enMac.w,x
	bpl		xpmp_step_en
	rts
	xpmp_step_en:
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
	ora 	#$40
	jsr 	xpmp_reset_en_mac
	xpmp_update_EN_done:
	.ENDIF
	rts
	
	xpmp_step_dt_frame:
	lda		dtMac.w,x
	bpl		xpmp_step_dt
	rts
	xpmp_step_dt:
	.IFNDEF XPMP_DTMAC_NOT_USED
	lda		dtMac.w,x
	beq		xpmp_update_DT_done
	xpmp_update_DT:
	;lda		#1
	;sta		xpmp_freqChange.w
	lda		dtMacPtr.w,x
	sta		<xpmp_tempZp1
	lda		dtMacPtr.w+1,x
	sta		<xpmp_tempZp2
	ldy		dtMacPos.w,x
	lda		(<xpmp_tempZp1),y
	cmp		#$80
	beq		xpmp_update_DT_loop
	jsr		xpmp_new_duty
	inc		dtMacPos.w,x
	jmp		xpmp_update_DT_done
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
	lda		(<xpmp_tempZp1)
	jsr		xpmp_new_duty
	xpmp_update_DT_done:
	.ENDIF
	rts
	
	xpmp_step_ep_frame:
	lda		epMac.w,x
	bpl		xpmp_step_ep
	rts
	xpmp_step_ep:
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
	rts
	
	xpmp_step_mp_frame:
	lda		mpMac.w,x
	bpl		xpmp_step_mp
	rts
	xpmp_step_mp:
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
	rts
	
	
	

xpmp_read_commands:
	lda		<xpmp_channel
	asl		a
	tax
	lda		dataPtr.w,x
	clc
	adc		dataPos.w,x
	sta		<xpmp_dataPtr
	lda		dataPtr.w+1,x
	adc		dataPos.w+1,x
	sta		<xpmp_dataPtr+1
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
	lda		note.w,x
	clc
	adc		noteOffs.w,x
	sta		<xpmp_tempZp1
	lda		octave.w,x
	adc		<xpmp_tempZp1
	asl		a
	tay

	cpx		#3*2
	bne		+
	lda		<xpmp_ddaEnable
	beq		+
	jmp		xpmp_start_dda
+:
	cpx		#4*2
	bcc		+
	lda		duty.w,x
	beq		+
	tya
	lsr		a
	tay
	lda 	xpmp_noise_tbl.w,y
	sta		freq.w,x
	stz		freq.w+1,x
	bra		xpmp_update_got_freq
+:
	lda 	xpmp_freq_tbl.w,y
	sta		freq.w,x
	lda 	xpmp_freq_tbl.w+1,y
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
	cpx		#4*2
	bcc		+
	lda		duty.w,x
	beq		+
	lda		freq.w,x
	ora		#$80
	sta.w	XPMP_PSG_NOISE_CTRL
	bra		++
+:
	lda		freq.w,x
	sta.w	XPMP_PSG_FREQ_FINE
	lda		freq.w+1,x
	sta.w	XPMP_PSG_FREQ_COARSE
++:	
	lda		xpmp_lastNote.w
	cmp		#CMD_REST
	bne		xpmp_update_set_vol_2
	jmp		xpmp_update_set_vol_3

	; Mute the channel 
	xpmp_rest:
	stz.w	XPMP_PSG_CHANNEL_CTRL
	stz.w	XPMP_PSG_NOISE_CTRL
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
	ora		#$80
	sta.w	XPMP_PSG_CHANNEL_CTRL
	xpmp_update_no_vol_change:
	rts


xpmp_start_dda:
	tya
	clc
	adc		#24
	asl		a
sta xpmp_tempZp4
	tay
	lda		xpmp_pcm_table.w,y
	sta		<xpmp_ddaPtr
	lda		xpmp_pcm_table.w+1,y
	sta		<xpmp_ddaPtr+1
	lda		xpmp_pcm_table.w+2,y
	sta		<xpmp_ddaPtr+2
	tam		#$40
	lda		#$DF
	sta.w	XPMP_PSG_CHANNEL_CTRL
	rts


xpmp_update_dda:
	lda		<xpmp_ddaEnable
	bne		+
	rts
+:
	lda		#3
	sta.w	XPMP_PSG_CHANNEL_SELECT
	lda		(<xpmp_ddaPtr)
	bpl		+
	lda		#0
	;sta.w	XPMP_PSG_CHANNEL_CTRL
	rts
+:
	sta.w	XPMP_PSG_CHANNEL_WAVE
	inc		<xpmp_ddaPtr
	bne		+
	inc		<xpmp_ddaPtr+1
	bne		+
	inc		<xpmp_ddaPtr+2
	lda		<xpmp_ddaPtr+2
	tam		#$40
	stz		<xpmp_ddaPtr
	lda		#$C0
	sta		<xpmp_ddaPtr+1
+:
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
	lda		#4
	jsr		xpmp_update_
	lda		#5
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
xpmp_freq_tbl:
.dw $0D5D,$0C9D,$0BE8,$0B3D,$0A9B,$0A03,$0973,$08EB,$086B,$07F2,$0780,$0714
.dw $06AE,$064E,$05F4,$059E,$054E,$0501,$04B9,$0476,$0436,$03F9,$03C0,$038A
.dw $0357,$0327,$02FA,$02CF,$02A7,$0281,$025D,$023B,$021B,$01FD,$01E0,$01C5
.dw $01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0,$00E3
.dw $00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097,$008F,$0087,$007F,$0078,$0071
.dw $006B,$0065,$005F,$005A,$0055,$0050,$004C,$0047,$0043,$0040,$003C,$0039
.dw $0035,$0032,$0030,$002D,$002A,$0028,$0026,$0024,$0022,$0020,$001E,$001C
.dw $001B,$0019,$0018,$0016,$0015,$0014,$0013,$0012,$0011,$0010,$000F,$000E
.dw $000D,$000D,$000C,$000B,$000B,$000A,$0009,$0009,$0008,$0008,$0007,$0007
.dw $0007,$0006,$0006,$0006,$0005,$0005,$0005,$0004,$0004,$0004,$0004,$0004
.dw $0003,$0003,$0003,$0003,$0003,$0003,$0002,$0002,$0002,$0002,$0002,$0002
.dw $0002,$0002,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001

xpmp_noise_tbl:
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$03
.db $04,$06,$07,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11
.db $12,$12,$13,$14,$14,$15,$16,$16,$17,$17,$18,$18
.db $18,$19,$19,$19,$1A,$1A,$1A,$1B,$1B,$1B,$1B,$1B
.db $1C,$1C,$1C,$1C,$1C,$1C,$1D,$1D,$1D,$1D,$1D,$1D
.db $1D,$1D,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1F,$1F,$1F





