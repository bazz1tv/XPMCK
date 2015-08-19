; Test program for the Cross Platform Music Player
; ColecoVision version
; /Mic, 2009
;
; The relevant parts here are the calls to xpmp_init and xpmp_update.
;
; Build with WLA-DX:
;  wla-z80 -o testclv.asm testclv.o
;  wlalink -b testclv.link testclv.rom

.DEFINE XPMP_RAM_START $7180

; BIOS function
.EQU READ_REGISTER $1FDC


.memorymap
	defaultslot 0

	slotsize $8000
	slot 0 $0000
	slot 1 $8000
.endme

.rombanksize $8000
.rombanks 1


.bank 0 slot 1
.orga $8000

.include "clvvdp.inc"


header:
.db $55,$AA
.dw $0000,$0000,$0000,$0000
.dw main
jp irq_handler
jp irq_handler
jp irq_handler
jp irq_handler
jp irq_handler
jp irq_handler
jp irq_handler
jp nmi_handler


main:
	di

	; Set nametable base address to $0400, pattern base to $0000, color table base to $1000
	VDP_SETREG 2,1
	VDP_SETREG 3,$40
	VDP_SETREG 4,0
	

	; Copy pattern data to VRAM
	VDP_SETVRAMADR 0
	ld 	hl,pattern_data 	; Pointer to pattern_data
	ld	c,VDP_DATA
	ld	b,0
	otir			

	; Initialize the color table
	VDP_SETVRAMADR $1000
	ld	a,$F1
	ld	b,32
	-:
		out	(VDP_DATA),a
		dec	b
		jr	nz,-
	
	; Clear the nametable
	VDP_SETVRAMADR $0400
	ld	c,24
	ld	a,31		; Tile 31 in the font is blank
	-:
		ld	b,32
	--:
		out	(VDP_DATA),a
		dec	b
		jr	nz,--
		dec	c
		jr	nz,-
		
	; Print some text
	ld 	hl,string1 
	ld 	c,11
	ld 	b,4
	call 	print_bg

	; Disable blanking, set screen mode 0, 16kB VRAM, enable video IRQs
	VDP_SETREG 0,$00 
	VDP_SETREG 1,$E0

	; Black background color, white foreground color
	VDP_SETREG 7,$F1
	
	
	; Initialize the music player
	ld 	hl,xpmp_song_tbl
	ld 	a,1			; Play the first song
	call 	xpmp_init
	
	ei				; Enable interrupts

	forever:
		jp 	forever		


metronome:
	ret
	
	
; hl=string, c=column, b=row	(col=0..31, row=0..23)
print_bg:
	push 	hl
	ld 	de,0
	ld 	hl,$0400
	or 	d		; Just to clear the CF

	; Multiply b by 32 and shift the overflowing bits into d
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
		cp	32
		jr	z,+
		sub	65
		jr	++
		+:
		dec	a
		++:
		out 	(VDP_DATA),a
		jp 	print_bg_loop
	

nmi_handler:
	call	xpmp_update
	
	call	READ_REGISTER
	
	retn
	
	
irq_handler:
	reti

	
; Include the song data
.include "clvmusic.asm"	

; Include the music player
.include "..\..\lib\sms_gg\xpmp_sms.asm"

	
pattern_data:
	.incbin "clvfont.pat"

string1:	
	.db "MUSIC TEST"
	.db 0


; Padding
.orga $FFFE
.dw 0
