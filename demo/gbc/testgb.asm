; Test program for the Cross Platform Music Player
; Gameboy version
; /Mic, 2008
;
; The relevant parts here are the calls to xpmp_init and xpmp_update.
;
; Build with WLA-DX:
;  wla-gb -o testgb.asm testgb.o
;  wlalink -b testgb.link testgb.gb

.MEMORYMAP
	DEFAULTSLOT 1
	SLOTSIZE $4000
	SLOT 0 $0000
	SLOT 1 $4000
.ENDME

.ROMBANKSIZE $4000
.ROMBANKS 2

.ROMDMG
.CARTRIDGETYPE 0
.COMPUTEGBCHECKSUM
.COMPUTEGBCOMPLEMENTCHECK
.EMPTYFILL 0
.INCLUDE "nintendo_logo.i"
.INCLUDE "cgb_hardware.i"


; RAM variables
.ENUM $C000
bgpal 		db
scanline 	db
init_done	db
.ENDE


.BANK 0 SLOT 0

.orga $00
nop

.orga $40				;vbi.
jp	irq_vbi
.orga $48				;lcd stat.
jp	irq_lcd
.orga $50				;timer.
jp	irq_tim
.orga $58				;serial.
jp	irq_ser
.orga $60				;high to low.
jp	irq_htl

.orga $100
nop
jp	main


.orga $150
main:
	di
	ld	sp,$fffe

	ld	a,0
	ld	(init_done),a
	
	; Turn on the screen and BG
	ld	a,$81
	ldh	(R_LCDC),a

	; Enable vblank IRQs
	ld	a,$10			
	ldh	(R_STAT),a
	ld	a,1
	ldh	(R_IE),a
	
	ei

	forever:
		halt
		call	xpmp_update
		jr forever
	

; Print a string on the nametable at $9800	
; HL=string, C=column, B=row	(c=0..31, r=0..23)
print_bg:
	push 	hl
	ld 	de,0
	ld 	hl,$9800
	or 	d		; Just to clear the CF

	; Multiply b by 32 and shift the overflowing bits into d
	sla 	b
	rl 	d
	sla 	b
	rl 	d
	sla 	b
	rl 	d
	sla 	b
	rl 	d
	sla 	b
	rl 	d

	add 	hl,de
	ld 	a,b
	ld 	b,0
	add 	hl,bc
	ld 	c,a
	add 	hl,bc
	pop 	bc
	push	hl
	pop	de
	print_bg_loop:
		ld 	a,(bc)		; Get one byte from the string
		cp 	0
		ret 	z
		inc	bc
		ld 	hl,char_set	
		add	l
		ld	l,a
		ld	a,0
		adc	h
		ld	h,a
		ld 	a,(hl)		; ASCII -> tile number
		sub	128		; The nametable at $9800 is signed
		ld	(de),a
		inc	de
		jp 	print_bg_loop
	

init:
	ld	a,1
	ld	(init_done),a

	; Disable the screen
	ld	a,$00
	ldh	(R_LCDC),a

	ld	a,$E4
	ld	(bgpal),a
	ldh	(R_BGP),a
	
	; Clear the nametable at $9800
	ld 	hl,$9800
	ld	de,$400
	ld	a,-128
	clear_nt:
		ldi	(hl),a
		dec	e
		jr	nz,clear_nt
		dec	d
		jr	nz,clear_nt
		
	; Copy pattern data to VRAM
	ld	hl,$8800
	ld 	de,pattern_data 	; Pointer to pattern_data
	ld 	bc,$800			; 72 tiles * 16 byte
	copy_pat:
		ld 	a,(de)
		inc	de
		ldi	(hl),a
		dec 	c
		jr 	nz,copy_pat
		dec 	b
		jr 	nz,copy_pat
		
	ld	hl,string1
	ld	b,4
	ld	c,5
	call	print_bg

	; Initialize the music player
	ld 	hl,xpmp_song_tbl
	ld 	a,1			; Play the first song
	call 	xpmp_init
	
	; Turn on the screen and BG
	ld	a,$81
	ldh	(R_LCDC),a

	ret


metronome:
	ld	a,(bgpal)
	xor	$80
	ld	(bgpal),a
	ret
	
irq_vbi:
	ld	a,(init_done)
	cp	0
	jr	nz,not_first_vbi
	call	init
	reti
	not_first_vbi:
	ld	a,(bgpal)
	ldh	(R_BGP),a
	reti
	
irq_lcd:
irq_tim:
irq_ser:
irq_htl:
	reti


; Include the music player and music data	
.include "gbmusic.asm"
.include "..\..\lib\gbc\xpmp_gbc.asm"

pattern_data:
        .incbin "serif_gb.pat"
char_set:
	.incbin "serif8.set"

string1:
	.db "Music test"
	.db 0
	
	
.bank 1
	.db 0

.orga $7fff
	.db 0	