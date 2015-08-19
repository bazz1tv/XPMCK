; Written by XPMC at 14:05:59 on Friday June 24, 2011.

.DEFINE XPMP_GAME_GEAR
.IFDEF XPMP_MAKE_SGC

.MEMORYMAP
	DEFAULTSLOT 1
	SLOTSIZE $4000
	SLOT 0 $0000
	SLOT 1 $4000
.ENDME

.ROMBANKSIZE $4000
.ROMBANKS 2
.BANK 0 SLOT 0
.ORGA $00

.db "SGC"
.db $1A
.db 1		; Version
.db 0
.db 0, 0
.dw $0400	; Load address
.dw $0400	; Init address
.dw $0408	; Play address
.dw $dff0	; Stack pointer
.dw 0		; Reserved
.dw $040C	; RST 08
.dw $040C	; RST 10
.dw $040C	; RST 18
.dw $040C	; RST 20
.dw $040C	; RST 28
.dw $040C	; RST 30
.dw $040C	; RST 38
.db 0, 0, 1, 2	; Mapper setting (none)
.db 0		; Start song
.db 1		; Number of songs
.db 0, 0	; Sound effects (none)
.db 1		; System type
.dw 0,0,0,0,0,0,0,0,0,0,0 ; Reserved
.db 0
.db "GameGear Panning Test", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.db "Unknown", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.db "mic", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.INCBIN "sgc.bin"

.ELSE

.DEFINE XPMP_VMAC_NOT_USED
.DEFINE XPMP_EPMAC_NOT_USED
.DEFINE XPMP_MPMAC_NOT_USED
.DEFINE XPMP_ENMAC_NOT_USED
.DEFINE XPMP_EN2MAC_NOT_USED
xpmp_dt_mac_tbl:
xpmp_dt_mac_loop_tbl:

xpmp_v_mac_tbl:
xpmp_v_mac_loop_tbl:

xpmp_VS_mac_tbl:
xpmp_VS_mac_loop_tbl:

xpmp_EP_mac_tbl:
xpmp_EP_mac_loop_tbl:

xpmp_EN_mac_tbl:
xpmp_EN_mac_loop_tbl:

xpmp_MP_mac_tbl:

xpmp_CS_mac_0:
xpmp_CS_mac_0_loop:
.db $F0, $80
xpmp_CS_mac_1:
xpmp_CS_mac_1_loop:
.db $10, $80
xpmp_CS_mac_tbl:
.dw xpmp_CS_mac_0
.dw xpmp_CS_mac_1
xpmp_CS_mac_loop_tbl:
.dw xpmp_CS_mac_0_loop
.dw xpmp_CS_mac_1_loop

xpmp_ADSR_tbl:

xpmp_callback_tbl:


xpmp_pattern_tbl:

xpmp_s1_channel_A:
.db $9A,$1C,$C8,$3C,$F4,$01,$13,$60,$62,$64,$65,$F9,$07,$00
xpmp_s1_channel_B:
.db $9A,$1C,$C8,$3C,$F4,$02,$15,$6C,$60,$62,$64,$65,$F9,$08,$00
xpmp_s1_channel_C:
.db $FF
xpmp_s1_channel_D:
.db $FF

xpmp_song_tbl:
.dw xpmp_s1_channel_A
.dw xpmp_s1_channel_B
.dw xpmp_s1_channel_C
.dw xpmp_s1_channel_D
.ENDIF