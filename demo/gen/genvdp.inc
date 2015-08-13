##################################################
#                                                #
#        Register and bitmask definitions        #
#                                                #
##################################################

.equ GFXDATA, 		0xc00000
.equ GFXCNTL, 		0xc00004

.equ VDP0_E_HBI, 	0x10
.equ VDP0_E_DISPLAY, 	0x02 
.equ VDP0_PLTT_FULL, 	0x04 

.equ VDP1_SMS_MODE,	0x80
.equ VDP1_E_DISPLAY,	0x40
.equ VDP1_E_VBI,	0x20
.equ VDP1_E_DMA,	0x10
.equ VDP1_NTSC,		0x00
.equ VDP1_PAL,		0x08
.equ VDP1_RESERVED,	0x04

.equ VDP12_SPR_SHADOWS,	0x08
.equ VDP12_SCREEN_V224,	0x00
.equ VDP12_SCREEN_V448,	0x04
.equ VDP12_PROGRESSIVE,	0x00
.equ VDP12_INTERLACED,	0x02
.equ VDP12_SCREEN_H256,	0x00
.equ VDP12_SCREEN_H320,	0x81

.equ VDP16_MAP_V32,	0x00
.equ VDP16_MAP_V64,	0x10
.equ VDP16_MAP_V128,	0x30
.equ VDP16_MAP_H32,	0x00
.equ VDP16_MAP_H64,	0x01
.equ VDP16_MAP_H128,	0x03



##################################################
#                                                #
#                   MACROS                       #
#                                                #
##################################################


/* Write val to VDP register reg */
.macro write_vdp_reg reg val
	move.w #((\reg << 8) + 0x8000 + \val),(a3)
.endm


/* For immediate addresses */
.macro VRAM_ADDR reg adr
	move.l #(((0x4000 + ((\adr) & 0x3fff)) << 16) + ((\adr) >> 14)),\reg
.endm


/* For indirect (variable) addresses.
   Destroys d6-d7. */
.macro VRAM_ADDR_var reg adr
	move.l \adr,d6
	move.l \adr,d7
	and.w #0x3fff,d6
	lsr.w #7,d7
	lsr.w #7,d7
	add.w #0x4000,d6
	lsl.l #7,d6
	lsl.l #7,d6
	lsl.l #2,d6
	or.l d7,d6
	move.l d6,\reg
.endm


.macro CRAM_ADDR reg adr
	move.l	#(((0xc000 + (\adr & 0x3fff)) << 16) + (\adr >> 14)),\reg
.endm


/* For indirect (variable) addresses */
.macro CRAM_ADDR_var reg adr
	move.l \adr,d5
	move.l \adr,d7
	and.w #0x3fff,d5
	lsr.w #7,d7
	lsr.w #7,d7
	add.w #0xc000,d5
	lsl.l #7,d5
	lsl.l #7,d5
	lsl.l #2,d5
	or.l d7,d5
	move.l d5,\reg
.endm


.macro VSCROLL_ADDR reg adr
	move.l	#(((0x4000 + (\adr & 0x3fff)) << 16) + ((\adr >> 14) | 0x10)),\reg
.endm


.macro HSCROLL_ADDR reg adr
	move.l #(((0x4000 + (\adr & 0x3fff)) << 16) + (\adr >> 14)),\reg
.endm


