; Test program for the Cross Platform Music Player
; SMS version
; /Mic, 2008
;
; The relevant parts here are the calls to xpmp_init and xpmp_update.
;
; Build with WLA-DX:
;  wla-z80 -o test.asm test.o
;  wlalink -b test.link test.sms

.DEFINE XPMP_RAM_START $D000

.ENUM $C000
text_color db
.ENDE

.memorymap
	defaultslot 0

	slotsize $8000
	slot 0 0
.endme

.rombanksize $8000
.rombanks 1


.bank 0 
.orga $0000

.include "smsvdp.inc"

di
im 	1
ld 	sp,$dff0			; Set stack pointer
jp 	main


; IRQ handler
.orga $0038
	jp 	irq_handler


; NMI handler	
.orga $0066
	retn


main:
	; Reset scrolling
	VDP_SETREG 8,0
	VDP_SETREG 9,0

	; Set nametable base address to $1800
	VDP_SETREG 2,4
	
	ld 	a,0
	ld 	(text_color),a
	
	; Set bg color 1 to blue
	VDP_SETCRAMADR $01
	ld 	a,$30			
	out 	($BE),a

	; Clear the nametable
	VDP_SETVRAMADR $1800
	ld	de,$800	
	ld	a,0
	clear_nt:
		out	(VDP_DATA),a
		out	(VDP_DATA),a
		dec	e
		jr	nz,clear_nt
		dec d
		jr	nz,clear_nt
		
	; Copy pattern data to VRAM
	VDP_SETVRAMADR 0
	ld 	hl,pattern_data 	; Pointer to pattern_data
	ld	c,VDP_DATA
	ld	d,9			; Copy 9*256 = 2304 bytes = 72 tiles
	copy_pat:
		ld	b,0
		otir			
		dec	d
		jr	nz,copy_pat
		
	; Print some text
	ld 	hl,string1 
	ld 	c,10
	ld 	b,4
	call 	print_bg

	; Set the line counter reload value to 0
	VDP_SETREG 10,0

	; Enable the screen (mode 4 / 224 lines), vblank irqs
	VDP_SETREG 0,$C6  
	VDP_SETREG 1,$70

	; Initialize the music player
	ld 	hl,xpmp_song_tbl
	ld 	a,1			; Play the first song
	call 	xpmp_init
	
	ei				; Enable interrupts

	forever:
		call	xpmp_update
		halt			; Sit and wait for interrupts
		jp 	forever		


; Example of a simple callback. Changes the text color every time it's called.
metronome:
	ld 	a,(text_color)
	inc 	a
	and 	3
	ld 	(text_color),a
	ret
	
	
; hl=string, c=column, b=row	(c=0..31, r=0..23)
print_bg:
	push 	hl
	ld 	de,0
	ld 	hl,$1800
	or 	d		; Just to clear the CF

	; Multiply b by 64 and shift the overflowing bits into d
	sll 	b
	rl 	d
	sll 	b
	rl 	d
	sll 	b
	rl 	d
	sll 	b
	rl 	d
	sll 	b
	rl 	d
	sll 	b
	rl 	d

	sll 	c
	add 	hl,de
	ld 	a,b
	ld 	b,0
	add 	hl,bc
	ld 	c,a
	add 	hl,bc
	ld 	a,l
	out 	(VDP_CTRL),a
	ld 	a,h
	xor 	$40
	out 	(VDP_CTRL),a
	pop 	bc
	ld 	d,0
	print_bg_loop:
		ld 	a,(bc)
		cp 	0
		ret	z

		inc	bc
		ld 	e,a
		ld 	hl,char_set 
		add 	hl,de
		ld 	a,(hl)
		out 	(VDP_DATA),a
		ld 	a,d
		out 	(VDP_DATA),a
		jp 	print_bg_loop


irq_handler:
	push 	af
	push 	bc
	push 	de
	push 	hl
	
	; Check if the vblank bit is set
	in 	a,(VDP_CTRL)
	bit 	7,a
	jr 	z,irq_handler_done

	; Update the text color
	ld 	a,$01
	out 	(VDP_CTRL),a
	ld 	a,$C0
	out 	(VDP_CTRL),a
	ld 	a,(text_color)
	ld 	hl,colors
	ld 	e,a
	ld 	d,0
	add 	hl,de
	ld 	a,(hl)
	out 	(VDP_DATA),a
	
	irq_handler_done:
	pop	hl
	pop	de
	pop	bc
	pop	af
	ei
	reti

	
; Include the song data
.include "smsmusic.asm"	

; Include the music player
.include "..\..\lib\sms_gg\xpmp_sms.asm"

	
pattern_data:
	.incbin "serif8.pat"

char_set:
	.incbin "serif8.set"

string1:	
	.db "Music test"
	.db 0

rom_title:
	.db "XPMP"
	.db 0

colors:
	.db $03,$0C,$30,$0F
	
	
.orga $7fe0
.db "SDSC"
.db $00			; Major ver
.db $01			; Minor ver
.db $20			; Day
.db $06			; Month
.db $08, $20		; Year

.orga $7fec
.dw rom_title
.db $FF,$FF		; Release notes pointer


.orga $7ff0

.SMSTAG
