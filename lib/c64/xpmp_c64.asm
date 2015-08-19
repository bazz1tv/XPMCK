; Cross Platform Music Player
; C64 version
; /Mic, 2008-2010


.DEFINE XPMP_ENABLE_CHANNEL_A
.DEFINE XPMP_ENABLE_CHANNEL_B
.DEFINE XPMP_ENABLE_CHANNEL_C

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
.EQU CMD_HWRM	$94
.EQU CMD_PULMAC	$95
.EQU CMD_JSR	$96
.EQU CMD_RTS	$97
.EQU CMD_SYNC	$98
.EQU CMD_LEN	$9A
.EQU CMD_WRMEM  $9B
.EQU CMD_WRPORT $9C
.EQU CMD_TRANSP $9F
.EQU CMD_CBOFF  $E0
.EQU CMD_CBONCE $E1
.EQU CMD_CBEVNT $E2
.EQU CMD_CBEVVC $E3
.EQU CMD_CBEVVM $E4
.EQU CMD_CBEVOC $E5
.EQU CMD_DETUNE $ED
.EQU CMD_ADSR	$EE
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
.EQU xpmp_songTbl	$03
.EQU xpmp_songTblLo 	$03
.EQU xpmp_songTblHi 	$04
.EQU xpmp_songNum 	$05
.EQU xpmp_dataPtr 	$07
.EQU xpmp_dataPtrLo 	$07
.EQU xpmp_dataPtrHi 	$08
.EQU xpmp_tempZp1	$09
.EQU xpmp_tempZp2	$0A
.EQU xpmp_tempZp3	$0B


.STRUCT xpmp_channel_t
dataPtr		dw
dataPos		dw
delay		dw
delayHi		db	; Note delays are 24 bit unsigned fixed point in 16.8 format
note		db	; +7
noteOffs	db
octave		db
duty		db
freq		dw
volume		db	; +13
volOffs		db	
volOffsLatch	db
freqOffs	dw
freqOffsLatch	dw
detune		dw 
vMac		db	; +22
vMacPtr		dw
vMacPos		db
dtMac		db	; +26
dtMacPtr	dw
dtMacPos	db
enMac		db	; +30
enMacPtr	dw
enMacPos	db
pwMac		db	; +34
pwMacPtr	dw
pwMacPos	db
epMac		db	; +38
epMacPtr	dw
epMacPos	db
mpMac		db	; +42
mpMacPtr	dw
mpMacDelay	db
loop1		db	; +46
loop2		db
loopIdx		db
cbEvnote	dw
gate		db	; +51
returnAddr	dw
oldPos		dw
delayLatch	dw
delayLatch2	db
transpose	db
.ENDST


XPMP_VARIABLES:
.DSTRUCT xpmp_channel0,xpmp_channel_t,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.DSTRUCT xpmp_channel1,xpmp_channel_t,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.DSTRUCT xpmp_channel2,xpmp_channel_t,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
xpmp_freqChange:	.db 0
xpmp_volChange: 	.db 0
xpmp_lastNote:		.db 0
xpmp_resfil:		.db 0
xpmp_modevol:		.db 0
xpmp_tempw:		.dw 0
XPMP_VARIABLES_END:


; Add an 8-bit immediate value to a 16-bit variable in memory
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


; Add a 16-bit memory variable to another 16-bit variable
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


; Same as the above, but for zeropage variables
.MACRO ADD_M16_M16_ZP
	lda	\1
	clc
	adc	\2
	sta	\1
	lda	\1+1
	adc	\2+1
	sta	\1+1
.ENDM


; Initialize the music player
; $03..$04 = pointer to song table, $05 = song number
xpmp_init:
	dec	xpmp_songNum
	asl	xpmp_songNum
	clc
	lda	xpmp_songTbl
	adc	xpmp_songNum
	sta	xpmp_songTbl
	lda	xpmp_songTbl+1
	adc	#0
	sta	xpmp_songTbl+1
	
	; Initialize all the player variables to zero
	lda	#0
	ldy	#(XPMP_VARIABLES_END - XPMP_VARIABLES)
	ldx	#0
	xpmp_init_zero:
		sta	XPMP_VARIABLES.w,x
		inx
		dey
		bne	xpmp_init_zero
		
	; Initialize channel data pointers
	.IFDEF XPMP_ENABLE_CHANNEL_A
	ldy	#0
	lda	(xpmp_songTbl),y
	sta	xpmp_channel0.dataPtr.w
	iny
	lda	(xpmp_songTbl),y
	sta	xpmp_channel0.dataPtr.w+1
	.ENDIF	
	.IFDEF XPMP_ENABLE_CHANNEL_B
	ldy	#2
	lda	(xpmp_songTbl),y
	sta	xpmp_channel1.dataPtr.w
	iny
	lda	(xpmp_songTbl),y
	sta	xpmp_channel1.dataPtr.w+1
	.ENDIF	
	.IFDEF XPMP_ENABLE_CHANNEL_C
	ldy	#4
	lda	(xpmp_songTbl),y
	sta	xpmp_channel2.dataPtr.w
	iny
	lda	(xpmp_songTbl),y
	sta	xpmp_channel2.dataPtr.w+1
	.ENDIF	

	; Initialize loop pointers
	lda	#$FF
	.IFDEF XPMP_ENABLE_CHANNEL_A
	sta	xpmp_channel0.loopIdx.w
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_B
	sta	xpmp_channel1.loopIdx.w
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_C
	sta	xpmp_channel2.loopIdx.w
	.ENDIF

	; Initialize the delays for all channels to 1
	lda 	#1
	.IFDEF XPMP_ENABLE_CHANNEL_A
	sta	xpmp_channel0.delay.w+1
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_B
	sta	xpmp_channel1.delay.w+1
	.ENDIF
	.IFDEF XPMP_ENABLE_CHANNEL_C
	sta	xpmp_channel2.delay.w+1
	.ENDIF
	
	lda	#8
	sta	xpmp_modevol.w
	sta	$D418

	lda	#0
	sta	$D402
	sta	$D409
	sta	$D410
	
	rts


.macro XPMP_COMMANDS

; X contains the command byte
; Y contains zero
xpmp_\1_cmd_00:
	txa
	cmp	#CMD_VOLUP
	bne	xpmp_\1_cmd_60
	lda	xpmp_modevol.w
	and	#$F0
	sta	xpmp_modevol.w
	iny
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
	lda	xpmp_channel\1.volume.w
	clc
	adc	(xpmp_dataPtr),y
	sta	xpmp_channel\1.volume.w
	ora	xpmp_modevol.w
	sta	xpmp_modevol.w
	lda	#1
	sta	xpmp_volChange.w		; Volume has changed
	lda	#EFFECT_DISABLED
	sta	xpmp_channel\1.vMac.w		; Volume set overrides volume macros
	rts
	
xpmp_\1_cmd_60:

	lda	xpmp_channel\1.note.w
	sta	xpmp_lastNote.w
	txa
	and	#$0F
	sta	xpmp_channel\1.note.w
	txa
	and	#$F0
	cmp	#CMD_NOTE2
	beq	xpmp_\1_cmd_00_std_delay
	ADD_M16_IMM8 xpmp_channel\1.dataPos,2
	iny
	lda	(xpmp_dataPtr),y
	bpl	xpmp_\1_cmd_00_short_note
		tax
		iny
		ADD_M16_IMM8 xpmp_channel\1.dataPos,1
		txa
		and	#$7F
		lsr	a
		tax
		ror	a
		and	#$80
		ora	(xpmp_dataPtr),y
		pha
		iny
		lda	(xpmp_dataPtr),y
		clc
		adc	xpmp_channel\1.delay.w
		sta	xpmp_channel\1.delay.w		; Fractional part
		pla
		adc	#0
		sta	xpmp_channel\1.delay.w+1
		txa
		adc	#0
		sta	xpmp_channel\1.delay.w+2	; Whole part
		jmp	xpmp_\1_cmd_00_got_delay
	xpmp_\1_cmd_00_short_note:	
	tax
	iny
	lda	(xpmp_dataPtr),y
	clc
	adc	xpmp_channel\1.delay.w
	sta	xpmp_channel\1.delay.w		; Fractional part
	txa
	adc	#0
	beq	xpmp_\1_note_ret
	sta	xpmp_channel\1.delay.w+1
	lda	#0
	adc	#0
	sta	xpmp_channel\1.delay.w+2	; Whole part
	jmp	xpmp_\1_cmd_00_got_delay
	xpmp_\1_cmd_00_std_delay:
	lda	xpmp_channel\1.delay.w
	clc
	adc	xpmp_channel\1.delayLatch.w
	sta	xpmp_channel\1.delay.w
	lda	#0
	adc	xpmp_channel\1.delayLatch.w+1
	sta	xpmp_channel\1.delay.w+1
	lda	#0
	adc	xpmp_channel\1.delayLatch.w+2
	sta	xpmp_channel\1.delay.w+2
	xpmp_\1_cmd_00_got_delay:
	lda	#2
	sta	xpmp_freqChange.w
	lda	xpmp_channel\1.note.w
	cmp	#CMD_REST
	beq	xpmp_\1_note_ret
	cmp	#CMD_REST2
	beq	xpmp_\1_note_ret
	
	.IFNDEF XPMP_DTMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_DM
	lda	xpmp_channel\1.dtMac.w
	bmi	+
	beq	xpmp_\1_dt_reset
	jsr	xpmp_\1_reset_dt_mac		; Reset effects as needed..
	jmp	xpmp_\1_dt_reset
	+:
	jsr	xpmp_\1_step_dt
	xpmp_\1_dt_reset:
	;lda	xpmp_channel\1.dtMac.w
	;beq	+
	;jsr	xpmp_\1_reset_dt_mac
	;+:
	.ENDIF
	.ENDIF
	.IFNDEF XPMP_PWMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_PM
	lda	xpmp_channel\1.pwMac.w
	bmi	+
	beq	xpmp_\1_pw_reset
	jsr	xpmp_\1_reset_pw_mac		; Reset effects as needed..
	jmp	xpmp_\1_pw_reset
	+:
	jsr	xpmp_\1_step_pw
	xpmp_\1_pw_reset:
	;lda	xpmp_channel\1.pwMac.w
	;beq	+
	;jsr	xpmp_\1_reset_pw_mac
	;+:
	.ENDIF
	.ENDIF
	.IFNDEF XPMP_VMAC_NOT_USED
	lda	xpmp_channel\1.vMac.w
	beq	+
	;jsr	xpmp_\1_reset_v_mac
	+:
	.ENDIF
	.IFNDEF XPMP_ENMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN
	lda	xpmp_channel\1.enMac.w
	bmi	+
	beq	xpmp_\1_en_reset
	jsr	xpmp_\1_reset_en_mac		; Reset effects as needed..
	jmp	xpmp_\1_en_reset
	+:
	jsr	xpmp_\1_step_en
	xpmp_\1_en_reset:
	;lda	xpmp_channel\1.enMac.w
	;beq	+
	;jsr	xpmp_\1_reset_en_mac
	;+:
	.ENDIF
	.ENDIF
	.IFNDEF XPMP_MPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_MP
	lda	xpmp_channel\1.mpMac.w
	bmi	+
	beq	xpmp_\1_mp_reset
	jsr	xpmp_\1_reset_mp_mac		; Reset effects as needed..
	jmp	xpmp_\1_mp_reset
	+:
	jsr	xpmp_\1_step_mp
	xpmp_\1_mp_reset:
	;lda	xpmp_channel\1.mpMac.w
	;beq	+
	;jsr	xpmp_\1_reset_mp_mac
	;+:
	.ENDIF
	.ENDIF
	.IFNDEF XPMP_EPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EP
	lda	xpmp_channel\1.epMac.w
	bmi	+
	beq	xpmp_\1_ep_reset
	jsr	xpmp_\1_reset_ep_mac		; Reset effects as needed..
	jmp	xpmp_\1_ep_reset
	+:
	jsr	xpmp_\1_step_ep
	xpmp_\1_ep_reset:
	;lda	xpmp_channel\1.epMac.w
	;beq	+
	;jsr	xpmp_\1_reset_ep_mac
	;+:
	.ENDIF
	.ENDIF
	.IFNDEF XPMP_FTMAC_NOT_USED
	;lda	xpmp_channel\1.ftMac.w
	;beq	+
	;jsr	xpmp_\1_reset_ep_mac
	;+:
	.ENDIF
	xpmp_\1_note_ret:
	rts


; Set octave
xpmp_\1_cmd_10:
	txa
	and	#$0F
	asl	a
	asl	a
	sta	xpmp_channel\1.octave.w
	asl	a
	clc
	adc	xpmp_channel\1.octave.w
	sta	xpmp_channel\1.octave.w
	rts	


; Set waveform	
xpmp_\1_cmd_20:
	lda	xpmp_channel\1.duty.w
	and	#4
	sta	xpmp_channel\1.duty.w
	txa
	and	#3
	tax
	lda	#1
	-:
	cpx	#0
	beq	+
	asl	a
	dex
	jmp	-
	+:
	asl	a
	asl	a
	asl	a
	asl	a
	ora	xpmp_channel\1.duty.w
	sta	xpmp_channel\1.duty.w
	lda	#0
	sta	xpmp_channel\1.dtMac.w
	rts


; Set volume (short)
xpmp_\1_cmd_30:
	lda	xpmp_modevol.w
	and	#$F0
	sta	xpmp_modevol.w
	txa
	and	#$0F
	sta	xpmp_channel\1.volume.w
	ora	xpmp_modevol.w
	sta	xpmp_modevol.w
	lda	#1
	sta	xpmp_volChange.w		; Volume has changed
	lda	#EFFECT_DISABLED
	sta	xpmp_channel\1.vMac.w		; Volume set overrides volume macros
	rts

	
; Octave up + note	
xpmp_\1_cmd_40:
	lda	xpmp_channel\1.octave.w
	clc
	adc	#12
	sta	xpmp_channel\1.octave.w
	txa
	clc
	adc 	#$20
	tax
	jmp	xpmp_\1_cmd_00


; Octave down + note
xpmp_\1_cmd_50:
	lda	xpmp_channel\1.octave.w
	clc
	adc	#$F4
	sta	xpmp_channel\1.octave.w
	txa
	clc
	adc 	#$10
	tax
	jmp	xpmp_\1_cmd_00


; Set pulse width	
xpmp_\1_cmd_70:
	lda	#0
	sta	$D402+\1*7
	sta	xpmp_channel\1.pwMac.w
	txa
	and	#15
	sta	$D403+\1*7
	rts

xpmp_\1_cmd_80:
	rts

	
xpmp_\1_cmd_90:
	txa
	cmp	#CMD_ARPOFF
	bne	+

	; Turn off arpeggio macro
	lda	#EFFECT_DISABLED
	sta	xpmp_channel\1.enMac.w
	sta	xpmp_channel\1.noteOffs.w
	rts

	+:
	cmp	#CMD_FILTER
	bne	+
	
	; Set filter
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
	iny
	lda	xpmp_modevol.w
	and	#15
	sta	xpmp_modevol.w
	lda	(xpmp_dataPtr),y
	beq	filter_off_\1
	asl	a
	tax
	dex
	dex
	lda	xpmp_FT_tbl.w,x
	sta	xpmp_tempZp1
	lda	xpmp_FT_tbl.w+1,x
	sta	xpmp_tempZp2
	ldy	#0
	lda	(xpmp_tempZp1),y
	ora	xpmp_modevol.w
	sta	xpmp_modevol.w
	;sta	$D418
	lda	#1
	sta	xpmp_volChange.w
	iny
	lda	(xpmp_tempZp1),y
	sta	$D415
	iny
	lda	(xpmp_tempZp1),y
	sta	$D416
	lda	xpmp_resfil.w
	and	#7
	sta	xpmp_resfil.w
	iny
	lda	(xpmp_tempZp1),y
	ora	xpmp_resfil.w	
	ora	#1<<\1
	sta	xpmp_resfil.w
	sta	$D417
	rts
	filter_off_\1:
	lda	xpmp_resfil.w
	and	#(~(1<<\1))
	sta	xpmp_resfil.w
	sta	$D417
	rts
	
	+:
	cmp	#CMD_HWRM
	bne	+
	
	; Ring modulation enable
	lda	xpmp_channel\1.duty.w
	and	#$F2
	sta	xpmp_channel\1.duty.w
	iny
	lda	(xpmp_dataPtr),y
	beq	xpmp_\1_ringmod_off
	lda	#4
	ora	xpmp_channel\1.duty.w
	sta	xpmp_channel\1.duty.w
	xpmp_\1_ringmod_off:
	rts

	+:
	cmp	#CMD_SYNC
	bne	+
	
	; Hard sync enable
	lda	xpmp_channel\1.duty.w
	and	#$F4
	sta	xpmp_channel\1.duty.w
	iny
	lda	(xpmp_dataPtr),y
	beq	xpmp_\1_sync_off
	lda	#2
	ora	xpmp_channel\1.duty.w
	sta	xpmp_channel\1.duty.w
	xpmp_\1_sync_off:
	rts
	
	+:
	cmp	#CMD_PULMAC
	bne	+
	
	; Pulse width macro
	.IFNDEF XPMP_PWMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_PM
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.pwMac.w
	beq	xpmp_\1_pulmac_off
	xpmp_\1_reset_pw_mac:
	and	#$7F
	asl	a
	tax
	dex
	dex
	lda	xpmp_PW_mac_tbl.w,x
	sta	xpmp_channel\1.pwMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_PW_mac_tbl.w+1,x
	sta	xpmp_channel\1.pwMacPtr.w+1
	sta	xpmp_tempZp2
	ldx	#0
	lda	(xpmp_tempZp1,x)
	sta	$D403+\1*7
	lda	#1
	sta	xpmp_channel\1.pwMacPos.w
	xpmp_\1_pulmac_off:
	.ENDIF
	.ENDIF
	rts
	
	+:
	cmp	#CMD_JSR
	bne	+
	
	; Jump to pattern
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
	lda	xpmp_channel\1.dataPos.w
	sta	xpmp_channel\1.oldPos.w
	lda	xpmp_channel\1.dataPos.w+1
	sta	xpmp_channel\1.oldPos.w+1
	lda	xpmp_channel\1.dataPtr.w
	sta	xpmp_channel\1.returnAddr.w
	lda	xpmp_channel\1.dataPtr.w+1
	sta	xpmp_channel\1.returnAddr.w+1
	iny
	lda	(xpmp_dataPtr),y
	asl	a
	tax
	lda	xpmp_pattern_tbl.w,x
	sta	xpmp_channel\1.dataPtr.w
	lda	xpmp_pattern_tbl.w+1,x
	sta	xpmp_channel\1.dataPtr.w+1
	lda	#$FF
	sta	xpmp_channel\1.dataPos.w
	sta	xpmp_channel\1.dataPos.w+1
	rts

	+:
	cmp	#CMD_RTS
	bne	+
	
	; Return from a pattern
	lda	xpmp_channel\1.returnAddr.w
	sta	xpmp_channel\1.dataPtr.w
	lda	xpmp_channel\1.returnAddr.w+1
	sta	xpmp_channel\1.dataPtr.w+1
	lda	xpmp_channel\1.oldPos.w
	sta	xpmp_channel\1.dataPos.w
	lda	xpmp_channel\1.oldPos.w+1
	sta	xpmp_channel\1.dataPos.w+1
	rts
	
	+:
	cmp	#CMD_LEN
	bne	+
	
	; Set note length
	ADD_M16_IMM8 xpmp_channel\1.dataPos,2
	iny
	lda	(xpmp_dataPtr),y
	bpl	xpmp_\1_cmd_90_short_delay
		tax
		iny
		ADD_M16_IMM8 xpmp_channel\1.dataPos,1
		txa
		and	#$7F
		lsr	a
		tax
		ror	a
		and	#$80
		ora	(xpmp_dataPtr),y
		sta	xpmp_channel\1.delayLatch.w+1
		iny
		lda	(xpmp_dataPtr),y
		sta	xpmp_channel\1.delayLatch.w		; Fractional part
		txa
		sta	xpmp_channel\1.delayLatch.w+2	; Whole part
		rts
	xpmp_\1_cmd_90_short_delay:
	sta	xpmp_channel\1.delayLatch.w+1
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.delayLatch.w		; Fractional part
	lda	#0
	sta	xpmp_channel\1.delayLatch.w+2	
	rts
	
	+:
	cmp	#CMD_WRMEM
	bne	+
	ADD_M16_IMM8 xpmp_channel\1.dataPos,3
	iny	
	lda	(xpmp_dataPtr),y
	sta	xpmp_tempZp1
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_tempZp2
	iny
	lda	(xpmp_dataPtr),y
	ldy	#0
	sta	(xpmp_tempZp1),y
	rts
	
	+:
	cmp	#CMD_WRPORT
	bne	+
	ADD_M16_IMM8 xpmp_channel\1.dataPos,3
	rts

	+:
	cmp	#CMD_TRANSP
	bne	+
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.transpose.w
	rts
	
	+:
	rts
	
	
xpmp_\1_cmd_A0:
xpmp_\1_cmd_B0:
xpmp_\1_cmd_C0:
xpmp_\1_cmd_D0:
	rts


xpmp_\1_cmd_E0:
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
	txa

	cmp	#CMD_CBOFF
	beq	xpmp_\1_cmd_Ex_cboff
	cmp	#CMD_CBONCE
	beq	xpmp_\1_cmd_Ex_cbonce
	cmp	#CMD_CBEVNT
	beq	xpmp_\1_cmd_Ex_cbevnt
	cmp	#CMD_DETUNE
	beq	xpmp_\1_cmd_Ex_detune
	cmp	#CMD_ADSR
	beq	xpmp_\1_cmd_Ex_adsr
	rts

	xpmp_\1_cmd_Ex_cboff:
	lda	#0
	sta	xpmp_channel\1.cbEvnote.w
	sta	xpmp_channel\1.cbEvnote.w+1
	rts
	
	xpmp_\1_cmd_Ex_cbonce:
	rts
	
	xpmp_\1_cmd_Ex_cbevnt:
	rts
	
	xpmp_\1_cmd_Ex_detune:
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.detune.w
	ldx	#0
	and	#$80
	beq	xpmp_\1_cmd_Ex_detune_pos
	ldx	#$FF
	xpmp_\1_cmd_Ex_detune_pos:
	stx	xpmp_channel\1.detune.w+1
	rts
	
	xpmp_\1_cmd_Ex_adsr:
	iny
	lda	(xpmp_dataPtr),y
	asl	a
	tax
	dex
	dex
	lda	xpmp_ADSR_tbl.w,x
	sta	$D405+\1*7
	lda	xpmp_ADSR_tbl.w+1,x
	sta	$D406+\1*7
	rts

xpmp_\1_cmd_F0:
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
	txa
	
	;cmp	#CMD_VOLSET
	;beq	xpmp_\1_cmd_Fx_volset
	cmp	#CMD_JMP
	beq	xpmp_\1_cmd_Fx_jmp
	cmp	#CMD_DJNZ
	beq	xpmp_\1_cmd_Fx_djnz
	cmp	#CMD_LOPCNT
	beq	xpmp_\1_cmd_Fx_lopcnt
	cmp	#CMD_END
	beq	xpmp_\1_cmd_Fx_end
	cmp	#CMD_J1
	beq	xpmp_\1_cmd_Fx_j1
	cmp	#CMD_VOLMAC
	beq	xpmp_\1_cmd_Fx_volmac
	jmp	Fx_\1_part2

	xpmp_\1_cmd_Fx_volmac:
	rts

	xpmp_\1_cmd_Fx_djnz:
	ldx	xpmp_channel\1.loopIdx.w
	dec	xpmp_channel\1.loop1.w,x
	bne	xpmp_\1_cmd_Fx_jmp
	dec	xpmp_channel\1.loopIdx.w
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
	rts
	
	xpmp_\1_cmd_Fx_lopcnt:
	iny
	lda	(xpmp_dataPtr),y
	inc	xpmp_channel\1.loopIdx.w
	ldx	xpmp_channel\1.loopIdx.w
	sta	xpmp_channel\1.loop1.w,x
	rts

	xpmp_\1_cmd_Fx_jmp:
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.dataPos.w
	iny	
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.dataPos.w+1
	dec	xpmp_channel\1.dataPos.w	; dataPos will be increased after the return, so we decrease it here
	lda	#$FF
	cmp	xpmp_channel\1.dataPos.w
	bne	+
	dec	xpmp_channel\1.dataPos.w+1
	+:
	rts
	
	xpmp_\1_cmd_Fx_end:
	sta	xpmp_channel\1.note.w
	lda	#2
	sta	xpmp_freqChange.w
	rts

	xpmp_\1_cmd_Fx_j1:
	ldx	xpmp_channel\1.loopIdx.w
	lda	xpmp_channel\1.loop1.w,x
	cmp	#1
	bne	+
	dec	xpmp_channel\1.loopIdx.w
	jmp	xpmp_\1_cmd_Fx_jmp
	+:
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
	rts
	
;	xpmp_\1_cmd_Fx_j1:
;	lda	xpmp_channel\1.loopIdx.w
;	cmp	#1
;	bne	+
;	dec	xpmp_channel\1.loopIdx.w
;	jmp	xpmp_\1_cmd_Fx_jmp
;	+:
;	ADD_M16_IMM8 xpmp_channel\1.dataPos,1
;	rts
	
	xpmp_\1_cmd_Fx_dutmac:
	.IFNDEF XPMP_DTMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_DM
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.dtMac.w
	beq	xpmp_\1_dutmac_off
	xpmp_\1_reset_dt_mac:
	and	#$7F
	asl	a
	tax
	dex
	dex
	lda	xpmp_channel\1.duty.w
	and	#4
	sta	xpmp_channel\1.duty.w
	lda	xpmp_dt_mac_tbl.w,x
	sta	xpmp_channel\1.dtMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_dt_mac_tbl.w+1,x
	sta	xpmp_channel\1.dtMacPtr.w+1
	sta	xpmp_tempZp2
	ldx	#0
	lda	(xpmp_tempZp1,x)
	ora	xpmp_channel\1.duty.w
	sta	xpmp_channel\1.duty.w
	lda	#1
	sta	xpmp_channel\1.dtMacPos.w
	xpmp_\1_dutmac_off:
	.ENDIF
	.ENDIF
	rts

	Fx_\1_part2:
	cmp	#CMD_DUTMAC
	beq	xpmp_\1_cmd_Fx_dutmac
	cmp	#CMD_ARPMAC
	beq	xpmp_\1_cmd_Fx_arpmac
	cmp	#CMD_SWPMAC
	beq	xpmp_\1_cmd_Fx_swpmac
	cmp	#CMD_VIBMAC
	beq	xpmp_\1_cmd_Fx_vibmac
	rts
	
	xpmp_\1_cmd_Fx_vibmac:
	.IFNDEF XPMP_MPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_MP
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.mpMac.w
	beq	xpmp_\1_mpmac_off
	xpmp_\1_reset_mp_mac:
	and	#$7F
	asl	a
	tax
	dex
	dex
	lda	xpmp_MP_mac_tbl.w,x
	sta	xpmp_channel\1.mpMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_MP_mac_tbl.w+1,x
	sta	xpmp_channel\1.mpMacPtr.w+1
	sta	xpmp_tempZp2
	ldy	#0
	lda	(xpmp_tempZp1),y
	sta	xpmp_channel\1.mpMacDelay.w
	iny
	iny
	lda	(xpmp_tempZp1),y
	sta	xpmp_channel\1.freqOffsLatch.w
	lda	#0
	sta	xpmp_channel\1.freqOffsLatch.w+1
	ADD_M16_IMM8 xpmp_channel\1.mpMacPtr,1
	rts
	xpmp_\1_mpmac_off:
	sta	xpmp_channel\1.freqOffs.w
	sta	xpmp_channel\1.freqOffs.w+1
	.ENDIF
	.ENDIF
	rts

	xpmp_\1_cmd_Fx_arpmac:
	.IFNDEF XPMP_ENMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.enMac.w
	beq	xpmp_\1_arpmac_off
	xpmp_\1_reset_en_mac:
	and	#$7F
	asl	a
	tax
	dex
	dex
	lda	xpmp_EN_mac_tbl.w,x
	sta	xpmp_channel\1.enMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_EN_mac_tbl.w+1,x
	sta	xpmp_channel\1.enMacPtr.w+1
	sta	xpmp_tempZp2
	ldy	#0
	lda	(xpmp_tempZp1),y
	sta	xpmp_channel\1.noteOffs.w
	lda	#1
	sta	xpmp_channel\1.enMacPos.w
	rts
	xpmp_\1_arpmac_off:
	sta	xpmp_channel\1.noteOffs.w
	.ENDIF
	.ENDIF
	rts
	
	xpmp_\1_cmd_Fx_swpmac:
	.IFNDEF XPMP_EPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EP
	iny
	lda	(xpmp_dataPtr),y
	sta	xpmp_channel\1.epMac.w
	beq	xpmp_\1_epmac_off
	xpmp_\1_reset_ep_mac:
	and	#$7F
	asl	a
	tax
	dex
	dex
	lda	xpmp_EP_mac_tbl.w,x
	sta	xpmp_channel\1.epMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_EP_mac_tbl.w+1,x
	sta	xpmp_channel\1.epMacPtr.w+1
	sta	xpmp_tempZp2
	ldy	#0
	lda	(xpmp_tempZp1),y
	sta	xpmp_channel\1.freqOffs.w
	cmp	#$80
	beq	+
	lda	#$FF
	+:
	sta	xpmp_channel\1.freqOffs.w+1
	lda	#1
	sta	xpmp_channel\1.epMacPos.w
	rts
	xpmp_\1_epmac_off:
	sta	xpmp_channel\1.freqOffs.w
	sta	xpmp_channel\1.freqOffs.w+1
	.ENDIF
	.ENDIF
	rts
	
.ENDM


.MACRO XPMP_UPDATE_FUNC 

xpmp_\1_update:
	lda	#0
	sta	xpmp_freqChange.w
	sta	xpmp_volChange.w

	lda	xpmp_channel\1.note.w
	cmp	#CMD_END
	bne	+
	rts					; Playback has ended for this channel - all processing should be skipped
	+:
	
	dec	xpmp_channel\1.delay.w+1
	lda	#$FF
	cmp	xpmp_channel\1.delay.w+1
	bne	+
	dec	xpmp_channel\1.delay.w+2
	+:
	lda	xpmp_channel\1.delay.w+1
	ora	xpmp_channel\1.delay.w+2
	bne	xpmp_\1_update_effects
	
	jsr	xpmp_\1_read_commands
	rts
	
	xpmp_\1_update_effects:

	jsr	xpmp_\1_step_en_frame
	jsr	xpmp_\1_step_dt_frame
	jsr	xpmp_\1_step_pw_frame
	jsr	xpmp_\1_step_ep_frame
	jsr	xpmp_\1_step_mp_frame

	lda	xpmp_freqChange.w
	bne	xpmp_update_\1_freq_change
	jmp	xpmp_\1_update_set_vol
	rts



xpmp_\1_read_commands:
	lda	xpmp_channel\1.dataPtr.w
	clc
	adc	xpmp_channel\1.dataPos.w
	sta	xpmp_dataPtrLo
	lda	xpmp_channel\1.dataPtr.w+1
	adc	xpmp_channel\1.dataPos.w+1
	sta	xpmp_dataPtrHi
	ldy	#0
	lda	(xpmp_dataPtr),y		; Read the first byte of the command
	sta	xpmp_tempZp3
	lsr	a
	lsr	a
	lsr 	a
	and	#$FE
	tax
	lda	xpmp_\1_jump_tbl.w,x
	sta	xpmp_tempw.w
	lda	xpmp_\1_jump_tbl.w+1,x
	sta	xpmp_tempw.w+1			; Get the command handler address and store it in xpmp_tempw
	lda	xpmp_tempZp3
	tax
	jsr	xpmp_call_indirect		; Jump to the command handler
	ADD_M16_IMM8 xpmp_channel\1.dataPos,1

	lda	xpmp_freqChange.w
	cmp	#2				; Have we read a note/rest/end command?
	bne	xpmp_\1_read_commands
	
	xpmp_update_\1_freq_change:
	lda	xpmp_channel\1.note.w
	cmp	#CMD_REST2
	bne	xpmp_update_\1_check_rest
	jmp	xpmp_\1_rest2
	xpmp_update_\1_check_rest:
	cmp	#CMD_REST
	bne	xpmp_update_\1_check_end
	jmp	xpmp_\1_rest
	xpmp_update_\1_check_end:
	cmp	#CMD_END
	bne	xpmp_update_\1_cmd_ok
	jmp	xpmp_\1_rest
	xpmp_update_\1_cmd_ok:
	lda	xpmp_channel\1.duty.w
	sta	$D404+\1*7
	xpmp_update_\1_freq_change_2:
	lda	xpmp_channel\1.note.w
	clc
	adc	xpmp_channel\1.transpose.w
	clc
	adc	xpmp_channel\1.noteOffs.w
	sta	xpmp_tempZp1
	lda	xpmp_channel\1.octave.w
	adc	xpmp_tempZp1
	asl	a
	tax
	lda	xpmp_freq_tbl.w,x
	sta	xpmp_channel\1.freq.w
	lda	xpmp_freq_tbl.w+1,x
	sta	xpmp_channel\1.freq.w+1
	
	; Add detune and freqOffs
	lda	xpmp_channel\1.detune.w
	sta	xpmp_tempZp1
	lda	xpmp_channel\1.detune.w+1
	sta	xpmp_tempZp2
	ADD_M16_M16 xpmp_tempZp1,xpmp_channel\1.freqOffs
	ADD_M16_M16_ZP xpmp_tempZp1,xpmp_tempZp1
	ADD_M16_M16_ZP xpmp_tempZp1,xpmp_tempZp1
	ADD_M16_M16_ZP xpmp_tempZp1,xpmp_tempZp1
	;ADD_M16_M16_ZP xpmp_tempZp1,xpmp_tempZp1
	ADD_M16_M16 xpmp_channel\1.freq,xpmp_tempZp1
	
	; Clip frequency if out of range
	lda	xpmp_channel\1.freq.w+1
	cmp	#$01
	bcc	xpmp_update_\1_freq_too_low
	beq	xpmp_update_\1_freq_might_be_too_low
	cmp	#$FD
	beq	xpmp_update_\1_freq_might_be_too_high
	bcs	xpmp_update_\1_freq_too_high
	jmp	xpmp_update_\1_freq_ok

	xpmp_update_\1_freq_might_be_too_high:
	lda	xpmp_channel\1.freq.w
	cmp	#$24
	bcc	xpmp_update_\1_freq_ok
	xpmp_update_\1_freq_too_high:
	lda	#$23
	sta	xpmp_channel\1.freq.w
	lda	#$FD
	sta	xpmp_channel\1.freq.w+1
	jmp	xpmp_update_\1_freq_ok

	xpmp_update_\1_freq_might_be_too_low:
	lda	xpmp_channel\1.freq.w+1
	cmp	#$0C
	bcs	xpmp_update_\1_freq_ok
	xpmp_update_\1_freq_too_low:
	lda	#$0C
	sta	xpmp_channel\1.freq.w
	lda	#$01
	sta	xpmp_channel\1.freq.w+1
	
	xpmp_update_\1_freq_ok:
	lda	xpmp_channel\1.freq.w
	sta	$D400+\1*7
	lda	xpmp_channel\1.freq.w+1
	sta	$D401+\1*7
	lda	xpmp_channel\1.duty.w
	ora	#1
	sta	$D404+\1*7
	lda	#1
	sta	xpmp_channel\1.gate.w
	
	lda	xpmp_lastNote.w
	cmp	#CMD_REST
	beq	xpmp_\1_update_set_vol_2
	jmp	xpmp_\1_update_set_vol_3

	; Mute the channel (clear the GATE bit)
	xpmp_\1_rest:
	lda	#0
	sta	$D404+\1*7
	lda	#0
	sta	xpmp_channel\1.gate.w
	xpmp_\1_rest2:
	rts
	
	xpmp_\1_update_set_vol:
	lda	xpmp_channel\1.note.w
	cmp	#CMD_REST
	beq	xpmp_\1_rest
	xpmp_\1_update_set_vol_2:
	; Update the volume if it has changed
	lda	xpmp_volChange.w
	beq	xpmp_update_\1_no_vol_change
	xpmp_\1_update_set_vol_3:
	lda	xpmp_modevol.w
	sta	$D418
	lda	xpmp_channel\1.duty.w
	ora	xpmp_channel\1.gate.w
	sta	$D404+\1*7
	xpmp_update_\1_no_vol_change:
	rts
		

	xpmp_\1_step_en_frame:
	lda 	xpmp_channel\1.enMac.w
	and	#$80
	beq	xpmp_\1_step_en
	rts
	xpmp_\1_step_en:
	.IFNDEF XPMP_ENMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EN
	lda	xpmp_channel\1.enMac.w
	beq	xpmp_update_\1_EN_done
	xpmp_update_\1_EN:
	lda	xpmp_freqChange.w
	cmp	#2
	beq	+
	lda	#1
	sta	xpmp_freqChange.w
	+:
	lda	xpmp_channel\1.enMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_channel\1.enMacPtr.w+1
	sta	xpmp_tempZp2
	ldy	xpmp_channel\1.enMacPos.w
	lda	(xpmp_tempZp1),y
	cmp	#$80
	beq	xpmp_update_\1_EN_loop
	clc
	adc	xpmp_channel\1.noteOffs.w
	sta	xpmp_channel\1.noteOffs.w
	inc	xpmp_channel\1.enMacPos.w
	jmp	xpmp_update_\1_EN_done
	xpmp_update_\1_EN_loop:
	lda	xpmp_channel\1.enMac.w
	and	#$7F
	asl	a
	tax
	dex
	dex
	lda	xpmp_EN_mac_loop_tbl.w,x
	sta	xpmp_channel\1.enMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_EN_mac_loop_tbl.w+1,x
	sta	xpmp_channel\1.enMacPtr.w+1
	sta	xpmp_tempZp2
	lda	#1
	sta	xpmp_channel\1.enMacPos.w
	ldx	#0
	lda	(xpmp_tempZp1,x)
	clc
	adc	xpmp_channel\1.noteOffs.w
	sta	xpmp_channel\1.noteOffs.w
	xpmp_update_\1_EN_done:
	.ENDIF
	.ENDIF
	rts

	xpmp_\1_step_dt_frame:
	lda 	xpmp_channel\1.dtMac.w
	and	#$80
	beq	xpmp_\1_step_dt
	rts
	xpmp_\1_step_dt:
	.IFNDEF XPMP_DTMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_DM
	lda	xpmp_channel\1.dtMac.w
	beq	xpmp_update_\1_DT_done
	xpmp_update_\1_DT:
	lda	xpmp_channel\1.duty.w
	and	#4
	sta	xpmp_channel\1.duty.w
	lda	#1
	sta	xpmp_volChange.w
	lda	xpmp_channel\1.dtMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_channel\1.dtMacPtr.w+1
	sta	xpmp_tempZp2
	ldy	xpmp_channel\1.dtMacPos.w
	lda	(xpmp_tempZp1),y
	beq	xpmp_update_\1_DT_loop
	ora	xpmp_channel\1.duty.w
	sta	xpmp_channel\1.duty.w
	inc	xpmp_channel\1.dtMacPos.w
	jmp	xpmp_update_\1_DT_done
	xpmp_update_\1_DT_loop:
	lda	xpmp_channel\1.dtMac.w
	and	#$7F
	asl	a
	tax
	dex
	dex
	lda	xpmp_dt_mac_loop_tbl.w,x
	sta	xpmp_channel\1.dtMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_dt_mac_loop_tbl.w+1,x
	sta	xpmp_channel\1.dtMacPtr.w+1
	sta	xpmp_tempZp2
	lda	#1
	sta	xpmp_channel\1.dtMacPos.w
	ldx	#0
	lda	(xpmp_tempZp1,x)
	ora	xpmp_channel\1.duty.w
	sta	xpmp_channel\1.duty.w
	xpmp_update_\1_DT_done:
	.ENDIF
	.ENDIF
	rts

	xpmp_\1_step_pw_frame:
	lda 	xpmp_channel\1.pwMac.w
	and	#$80
	beq	xpmp_\1_step_pw
	rts
	xpmp_\1_step_pw:
	.IFNDEF XPMP_PWMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_PM
	lda	xpmp_channel\1.pwMac.w
	beq	xpmp_update_\1_PW_done
	xpmp_update_\1_PW:
	lda	xpmp_channel\1.pwMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_channel\1.pwMacPtr.w+1
	sta	xpmp_tempZp2
	ldy	xpmp_channel\1.pwMacPos.w
	lda	(xpmp_tempZp1),y
	cmp	#$80
	beq	xpmp_update_\1_PW_loop
	sta	$D403+\1*7
	inc	xpmp_channel\1.pwMacPos.w
	jmp	xpmp_update_\1_PW_done
	xpmp_update_\1_PW_loop:
	lda	xpmp_channel\1.pwMac.w
	and	#$7F
	asl	a
	tax
	dex
	dex
	lda	xpmp_PW_mac_loop_tbl.w,x
	sta	xpmp_channel\1.pwMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_PW_mac_loop_tbl.w+1,x
	sta	xpmp_channel\1.pwMacPtr.w+1
	sta	xpmp_tempZp2
	lda	#1
	sta	xpmp_channel\1.pwMacPos.w
	ldx	#0
	lda	(xpmp_tempZp1,x)
	sta	$D403+\1*7
	xpmp_update_\1_PW_done:
	.ENDIF
	.ENDIF
	rts

	xpmp_\1_step_ep_frame:
	lda 	xpmp_channel\1.epMac.w
	and	#$80
	beq	xpmp_\1_step_ep
	rts
	xpmp_\1_step_ep:
	.IFNDEF XPMP_EPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_EP
	lda	xpmp_channel\1.epMac.w
	bne	xpmp_update_\1_EP
	jmp	xpmp_update_\1_EP_done
	xpmp_update_\1_EP:
	lda	xpmp_freqChange.w
	cmp	#2
	beq	+
	lda	#1
	sta	xpmp_freqChange.w
	+:
	lda	xpmp_channel\1.epMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_channel\1.epMacPtr.w+1
	sta	xpmp_tempZp2
	ldy	xpmp_channel\1.epMacPos.w
	lda	(xpmp_tempZp1),y
	cmp	#$80
	beq	xpmp_update_\1_EP_loop
	sta	xpmp_tempZp1
	and	#$80
	beq	+
	lda	#$FF
	+:
	sta	xpmp_tempZp2
	ADD_M16_M16 xpmp_channel\1.freqOffs,xpmp_tempZp1
	inc	xpmp_channel\1.epMacPos.w
	jmp	xpmp_update_\1_EP_done
	xpmp_update_\1_EP_loop:
	lda	xpmp_channel\1.epMac.w
	and	#$7F
	asl	a
	tax
	dex
	dex
	lda	xpmp_EP_mac_loop_tbl.w,x
	sta	xpmp_channel\1.epMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_EP_mac_loop_tbl.w+1,x
	sta	xpmp_channel\1.epMacPtr.w+1
	sta	xpmp_tempZp2
	lda	#1
	sta	xpmp_channel\1.epMacPos.w
	ldx	#0
	lda	(xpmp_tempZp1,x)
	sta	xpmp_tempZp1
	and	#$80
	beq	+
	lda	#$FF
	+:
	sta	xpmp_tempZp2
	ADD_M16_M16 xpmp_channel\1.freqOffs,xpmp_tempZp1
	xpmp_update_\1_EP_done:
	.ENDIF
	.ENDIF
	rts

	xpmp_\1_step_mp_frame:
	lda	xpmp_channel\1.mpMac.w
	and	#$80
	beq	xpmp_\1_step_mp
	rts
	xpmp_\1_step_mp:
	.IFNDEF XPMP_MPMAC_NOT_USED
	.IFDEF XPMP_CHN\1_USES_MP
	; Vibrato
	lda 	xpmp_channel\1.mpMac.w
	beq 	xpmp_update_\1_MP_done
	ldx	xpmp_channel\1.mpMacDelay.w
	cpx	#0	
	bne	xpmp_update_\1_MP_done2
	xpmp_update_\1_MP:
	lda	xpmp_freqChange.w
	cmp	#2
	beq	+
	lda	#1
	sta	xpmp_freqChange.w
	+:
	lda	xpmp_channel\1.mpMacPtr.w
	sta	xpmp_tempZp1
	lda	xpmp_channel\1.mpMacPtr.w+1
	sta	xpmp_tempZp2
	lda	xpmp_channel\1.freqOffsLatch.w
	sta	xpmp_channel\1.freqOffs.w
	eor	#$FF
	clc
	adc	#1
	sta	xpmp_channel\1.freqOffsLatch.w
	lda	xpmp_channel\1.freqOffsLatch.w+1
	sta	xpmp_channel\1.freqOffs.w+1
	eor	#$FF
	adc	#0
	sta	xpmp_channel\1.freqOffsLatch.w+1
	ldy	#0
	lda	(xpmp_tempZp1),y
	tax
	inx
	xpmp_update_\1_MP_done2:
	dex
	stx	xpmp_channel\1.mpMacDelay.w
	xpmp_update_\1_MP_done:
	.ENDIF
	.ENDIF
	rts
	

.ENDM

xpmp_call_indirect:
	jmp	(xpmp_tempw.w)
	

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


xpmp_update:
.IFDEF XPMP_ENABLE_CHANNEL_A
	jsr 	xpmp_0_update
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_B
	jsr 	xpmp_1_update
.ENDIF
.IFDEF XPMP_ENABLE_CHANNEL_C
	jsr 	xpmp_2_update
.ENDIF
	rts


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

 
xpmp_freq_tbl:
.dw $010C,$011C,$012D,$013E,$0151,$0165,$017B,$0191,$01A9,$01C3,$01DD,$01FA
.dw $0218,$0238,$025A,$027D,$02A3,$02CB,$02F6,$0323,$0353,$0386,$03BB,$03F4
.dw $0430,$0470,$04B4,$04FB,$0547,$0597,$05ED,$0647,$06A6,$070C,$0777,$07E9
.dw $0861,$08E1,$0968,$09F7,$0A8F,$0B2F,$0BDA,$0C8E,$0D4D,$0E18,$0EEE,$0FD2
.dw $10C3,$11C2,$12D0,$13EE,$151E,$165F,$17B4,$191D,$1A9B,$1C30,$1DDD,$1FA4
.dw $2186,$2384,$25A1,$27DD,$2A3C,$2CBF,$2F68,$323A,$3537,$3861,$3BBB,$3F48
.dw $430C,$4708,$4B42,$4FBB,$5479,$597F,$5ED1,$6475,$6A6E,$70C2,$7777,$7E91
.dw $8618,$8E11,$9684,$9F77,$A8F3,$B2FF,$BDA3,$C8EA,$D4DC,$E185,$EEEE,$FD23
