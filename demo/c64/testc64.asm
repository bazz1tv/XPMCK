; Test program for the Cross Platform Music Player
; C64 version
; /Mic, 2008
;
; The relevant parts here are the calls to xpmp_init and xpmp_update.
;
; Build with WLA-DX:
;  wla-6510 -o testc64.asm
;  wlalink -b testc64.link testc64.prg
;
; Run with:
;  LOAD"TESTC64.PRG",8,1
;  SYS4096

.memorymap
	defaultslot 0

	slotsize $7000
	slot 0 $0FFE 
.endme

.rombanksize $7000
.rombanks 1

.equ screen_ptr $03
.equ colour_ptr $05

.orga $0FFE
.dw $1000	; Load address

sei

ldx	#$FF
txs

; Disable CIA IRQs
lda	#$7F
sta	$DC0D
sta	$DD0D
lda	$DC0D
lda	$DD0D

; Generate VIC-II IRQ on scanline 0
lda	#$01
sta	$D01A
lda	#0
sta	$D012
lda	$D011
and	#$7F
sta	$D011

; Make RAM visible in the entire 6510 memory space, except D000-DFFF, which holds MMIO
lda	#$35
sta	$01

; Set IRQ vector
lda	#<irq_handler
sta	$FFFE
sta	$0314
lda	#>irq_handler
sta	$FFFF
sta	$0315

; Set lower case mode
lda	#23
sta	$D018	

; Clear the screen and color map (at least the first 19 rows)
lda	#$00
sta	screen_ptr
lda	#$04
sta	screen_ptr+1
lda	#$00
sta	colour_ptr
lda	#$D8
sta	colour_ptr+1
ldx	#3
ldy	#0
clear_screen1:
	lda	#32
	sta	(screen_ptr),y
	lda	#0
	sta	(colour_ptr),y
	iny
	bne	clear_screen1
	inc	screen_ptr+1
	inc	colour_ptr+1
	dex
	bne	clear_screen1

; Put the string "MUSIC TEST" at position 15,10
lda	#$9F
sta	screen_ptr
lda	#$05
sta	screen_ptr+1	; $059F = 1024 + 10*40 + 15
lda	#$9F
sta	colour_ptr
lda	#$D9
sta	colour_ptr+1	; $D99F = 55296 + 10*40 + 15
ldx	#0
ldy	#0
puts:
	lda	string.w,x
	beq	puts_done
	sta	(screen_ptr),y
	lda	#7
	sta	(colour_ptr),y
	iny
	inx
	jmp	puts
puts_done:

; Play the first song
lda	#1
sta	xpmp_songNum
lda	#<xpmp_song_tbl
sta	xpmp_songTblLo
lda	#>xpmp_song_tbl
sta	xpmp_songTblHi
jsr	xpmp_init

cli

; Loop forever and wait for raster IRQs
forever:
;	jsr	xpmp_update
;	nop
;	nop
;	nop
;	nop
	jmp 	forever

.dw xpmp_channel0

irq_handler:
	pha
	txa
	pha
	tya
	pha
	
	; Update the music player
	jsr xpmp_update

	; Reset the IRQ scanline number
	lda	#0
	sta	$D012
	
	; Clear the interrupt condition
	lda	#$FF
	sta	$D019
	
	pla
	tay
	pla
	tax
	pla
	
	rti
	
           
string: .db "MUSIC TEST",0

; Include the music data and the player
.include "c64music.asm"
.include "..\..\lib\c64\xpmp_c64.asm"



