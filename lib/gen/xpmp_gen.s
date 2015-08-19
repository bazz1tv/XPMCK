# Cross Platform Music Player
# Genesis version
# /Mic, 2008

.text
.globl xpmp_init
.globl xpmp_update

.macro store_table_adr_in_z80_ram tbladr
	move.l	#\tbladr,d2
	move.l	d2,d3
	lsr.l	#8,d3
	and.b	#0x7F,d3
	or.b	#0x80,d3
	move.b	d2,(a1)+
	move.b	d3,(a1)+
.endm

xpmp_init:
	movem.l	a0/a1/d1/d2/d3,-(a7)

	/* BUS REQ ON, BUS RESET OFF */
        move.w  #0x100,0xA11100
        move.w  #0x100,0xA11200

_xpmp_init_wait:
	btst	#8,0xA11100
	bne	_xpmp_init_wait
	
	/* Copy sound driver */
        lea     z80driver_bin,a0
        lea     0xA00000,a1
        move.l  #(z80driver_bin_end-1),d0
        move.l  #z80driver_bin,d1
        sub.l   d1,d0
_xpmp_init_copy_driver:
        move.b  (a0)+,(a1)+
	dbra	d0,_xpmp_init_copy_driver
	
	/* Copy effect tables */

	move.l	#0xA01E40,a1
	store_table_adr_in_z80_ram xpmp_dt_mac_tbl
	store_table_adr_in_z80_ram xpmp_dt_mac_loop_tbl
	store_table_adr_in_z80_ram xpmp_v_mac_tbl
	store_table_adr_in_z80_ram xpmp_v_mac_loop_tbl
	store_table_adr_in_z80_ram xpmp_EP_mac_tbl
	store_table_adr_in_z80_ram xpmp_EP_mac_loop_tbl
	store_table_adr_in_z80_ram xpmp_EN_mac_tbl
	store_table_adr_in_z80_ram xpmp_EN_mac_loop_tbl
	store_table_adr_in_z80_ram xpmp_MP_mac_tbl
	store_table_adr_in_z80_ram xpmp_ADSR_tbl
	store_table_adr_in_z80_ram xpmp_MOD_tbl
	store_table_adr_in_z80_ram xpmp_pattern_tbl
	store_table_adr_in_z80_ram xpmp_FB_mac_tbl
	store_table_adr_in_z80_ram xpmp_FB_mac_loop_tbl
	store_table_adr_in_z80_ram xpmp_song_tbl
	
	/* Put song number at 0x1F00 in Z80 RAM */
	move.l	28(a7),d0	
	move.b	d0,0xA01F00

	/* Put the high 9 bits of the song table address at 0x1F01 in Z80 RAM */
	move.l	24(a7),d0
	move.l	d0,d1
	lsr.l	#8,d0
	lsr.l	#7,d0
	move.b	d0,0xA01F01
	lsr.w	#8,d0
	move.b	d0,0xA01F02

	/* BUS RESET ON, BUS REQ OFF, BUS RESET OFF */
        move.w  #0x0,0xA11200
	nop
	nop
	nop
	nop
        move.w  #0x0,0xA11100
	nop
	nop
	nop
	nop
        move.w  #0x100,0xA11200

	movem.l	(a7)+,a0/a1/d1/d2/d3

	rts
	


xpmp_update:
	rts


# Copy effect address table from M68000 ROM to Z80 RAM.
# Addresses are converted to little-endian.
#
# IN:
#	a0:	M68000 source address
#	a1:	Z80 destination address (in M68000 memory space)
#	d0:	Max number of words to copy
#
xpmp_copy_table:
	move.l	#0,d1
_xpmpct_loop:
	cmp.l	d1,d0
	beq	_xpmpct_end
	move.b	(a0),d2
	or.b	1(a0),d2

	cmp.w	#0,d2

	beq	_xpmpct_end
	move.b	(a0)+,d3
	and.b	#0x7F,d3
	or.b	#0x80,d3
	move.b	(a0)+,d2
	move.b	d2,(a1)+
	move.b	d3,(a1)+
	addq.l	#1,d1
	bra	_xpmpct_loop
_xpmpct_end:
	rts




	