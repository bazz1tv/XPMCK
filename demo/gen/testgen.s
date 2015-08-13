# Test program for the Cross Platform Music Player
# Genesis version
# /Mic, 2008
#
# The relevant parts here are the calls to xpmp_init and xpmp_update.
#
# Build with m68k-*-as: (* = coff or elf)
#  m68k-*-as -m68000 --register-prefix-optional --bitwise-or -o sega_gcc.o sega_gcc.s
#  m68k-*-as -m68000 --register-prefix-optional --bitwise-or -o impact8_pat.o impact8.pat.s
#  m68k-*-as -m68000 --register-prefix-optional --bitwise-or -o testgen.o testgen.s
#  m68k-*-ld -Tmd.ld sega_gcc.o testgen.o impact8_pat.o
#  m68k-*-objcopy -I *-m68k -O binary a.out testgen.bin


.text
.globl main


.include "genvdp.inc"


.macro PUTSXY immstr x y
	lea	1$,a1
	move.l	\x,d0
	move.l	\y,d1
	jsr	puts
	bra 2$
1$:	.ascii "\immstr"
	dc.b 0
	.even
2$:
.endm


##################################################
#                                                #
#               MAIN PROGRAM                     #
#                                                #
##################################################
 
main:
	
	/* Initialize VDP */
	jsr 		init_gfx

	/* Wait a few frames */	
	jsr		wait_vsync
	jsr		wait_vsync
	jsr		wait_vsync
	
	/* Load font tiles */
	move.l		#0x0000,a3
	move.l 		#charset,a4
	move.l		#64,d4
	jsr		load_tiles
	move.l		#0x0800,a3
	move.l 		#(charset+0x0c00),a4
	move.l		#32,d4
	jsr		load_tiles

	/* Set the first two colors of palette 0 */
	move.l		#0x0000,a3
	move.l 		#palette,a4
	move.l		#2,d4
	jsr		load_colors

	jsr		wait_vsync

	/* Clear map A */
	move.l		#0xe000,a0
	moveq.l		#0,d0
	jsr		clear_map
	
	jsr		wait_vsync

	/* Clear map B */
	move.l		#0xc000,a0
	moveq.l		#0,d0
	jsr		clear_map
	
	jsr		wait_vsync

	/* Print some text on Map A */
	PUTSXY		"Music test",#11,#10

	
	/* Clear sprite data */
	move.l 		#GFXCNTL,a3
	VRAM_ADDR 	d0,0xfc00
	move.l 		d0,(a3)
	move.l 		#GFXDATA,a3
	moveq.l		#0,d0	
	move.l		#19,d1
clear_sprites:
	move.w		d0,(a5)+
	dbra 		d1,clear_sprites

	/* Play the first song */
	move.l		#1,-(a7)
	move.l		#xpmp_song_tbl,-(a7)
	jsr		xpmp_init	
	addq.l		#8,a7		/* Pop arguments */
	
/* Main loop */

forever:
	jsr		wait_vsync

	jsr		xpmp_update
	
	bra 		forever
	


#################################################
#                                               #
#         Initialize VDP registers              #
#                                               #
#################################################

init_gfx:
	move.l 		#GFXCNTL,a3
	write_vdp_reg 	0,(VDP0_E_HBI + VDP0_E_DISPLAY + VDP0_PLTT_FULL)
	write_vdp_reg 	1,(VDP1_E_VBI + VDP1_E_DISPLAY + VDP1_E_DMA + VDP1_NTSC + VDP1_RESERVED)
	write_vdp_reg 	2,(0xe000 >> 10)	/* Screen map A adress */
	write_vdp_reg 	3,(0xe000 >> 10)	/* Window address */
	write_vdp_reg 	4,(0xc000 >> 13)	/* Screen map B address */
	write_vdp_reg 	5,(0xfc00 >>  9)	/* Sprite address */
	write_vdp_reg 	6,0	
	write_vdp_reg	7,0			/* Border color */
	write_vdp_reg	8,1			/* Unused (?) */
	write_vdp_reg	9,1			/* Unused (?) */
	write_vdp_reg	10,1			/* Lines per hblank interrupt */
	write_vdp_reg	11,4			/* 2-cell vertical scrolling */
	write_vdp_reg	12,(VDP12_SCREEN_V224 + VDP12_SCREEN_H256 + VDP12_PROGRESSIVE)
	write_vdp_reg	13,(0x6000 >> 10)	/* Horizontal scroll address */
	write_vdp_reg	15,2
	write_vdp_reg	16,(VDP16_MAP_V32 + VDP16_MAP_H32)
	write_vdp_reg	17,0
	write_vdp_reg	18,0xff
	rts



#################################################
#                                               #
#        Put a string on screen map A           #
#                                               #
# Parameters:                                   #
#  a1: String pointer (ASCIIZ)                  # 
#  d0: X coordinate                             #
#  d1: Y coordinate                             #
#                                               #
#################################################

puts:
	lsl.l		#6,d1
	add.l		d0,d1
	add.l		d0,d1
	add.l		#0xe000,d1
	VRAM_ADDR_var	d0,d1
	move.l 		#GFXCNTL,a4
	move.l		d0,(a4)
	move.l 		#GFXDATA,a4
	moveq.l		#0,d0
_puts:
	move.b		(a1)+,d0
	beq		_puts_done
	sub.b		#32,d0
	move.w		d0,(a4)
	bra		_puts
_puts_done:
	rts

	

#################################################
#                                               #
#        Load tile data from ROM                #
#                                               #
# Parameters:                                   #
#  a3: VRAM base                                # 
#  a4: pattern address                          #
#  d4: number of tiles to load                  #
#                                               #
#################################################

load_tiles:
	move.l 		#GFXCNTL,a2
	VRAM_ADDR_var 	d0,a3
	move.l 		d0,(a2)
	lsl		#3,d4
	
	move.l 		#GFXDATA,a3
	subq.w 		#1,d4		/* DBRA stops at -1, so subtract 1 from the counter first */
_copy_tile_data:
	move.l 		(a4)+,(a3)
	dbra 		d4,_copy_tile_data
	rts


#################################################
#                                               #
#        Clear one of the screen maps           #
#                                               #
# Parameters:                                   #
#  a0: Map address                              # 
#  d0: Data to write to each map entry          #
#                                               #
#################################################

clear_map:
	move.l 		#GFXCNTL,a4
	VRAM_ADDR_var	d1,a0
	move.l 		d1,(a4)
	move.l 		#GFXDATA,a3
	move.w		#1023,d1	/* Loop counter */
_clear_map_loop:
	move.w		d0,(a3)
	move.w		d0,(a3)
	dbra		d1,_clear_map_loop
	rts
	

#################################################
#                                               #
#        Load color data from ROM               #
#                                               #
# Parameters:                                   #
#  a3: CRAM base                                # 
#  a4: color list address                       #
#  d4: number of colors to load                 #
#                                               #
#################################################

load_colors:
	move.l 		#GFXCNTL,a2
	CRAM_ADDR_var 	d0,a3
	move.l 		d0,(a2)

	move.l 		#GFXDATA,a3
	subq.w		#1,d4
_copy_color_data:
	move.w		(a4)+,(a3)
	dbra		d4,_copy_color_data

	rts


	
#################################################
#                                               #
#       Wait for next VBlank interrupt          #
#                                               #
#################################################

wait_vsync:
	movea.l		#vtimer,a0
	move.l		(a0),a1
_wait_change:
	cmp.l		(a0),a1
	beq		_wait_change
	rts


#################################################
#                                               #
#                 ROM DATA                      #
#                                               #
#################################################


palette:
	dc.w 0x0400,0x0ecc
	


#################################################
#                                               #
#                 RAM DATA                      #
#                                               #
#################################################

.bss
.globl htimer
.globl vtimer
.globl rand_num
htimer:		.long 0
vtimer:		.long 0
rand_num:	.long 0
temp:		.long 0
counter1:	.long 0
counter2:	.long 0

.end






