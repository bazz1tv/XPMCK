.memorymap
        defaultslot 0
        slotsize $2000
        slot 0 $0000
        slot 1 $2000
        slot 2 $4000
        slot 3 $6000
        slot 4 $8000
        slot 5 $A000
        slot 6 $C000
        slot 7 $E000
.endme

.rombankmap
        bankstotal 8
        banksize $2000
        banks 8
.endro

.DEFINE TIMER_COUNTER		$0C00
.DEFINE TIMER_CTRL			$0C01

.DEFINE INTERRUPT_CTRL		$1402
.DEFINE INTERRUPT_STATUS	$1403


.macro INCW
	inc	<\1
	bne	+
	inc	<\1+1
	+:
.endm



.org $0000
.dw 0
.bank 0 slot 7
.org $0040
.include "..\..\lib\pce\xpmp_pce.asm"

.bank 0 slot 0
; Interrupt vectors
.org $1FF6

 .dw vdc_irq                    
 .dw vdc_irq                   
 .dw timer_irq               
 .dw vdc_irq               
 .dw start     


 
.bank 1 slot 2
.org $0000


start:
    sei                               
    csh  							; switch the CPU to high speed mode                             
    cld                               
    ldx    #$FF                       
    txs
    stz    $2000                	; clear all the RAM
    tii    $2000,$2001,$1FFF
    
	lda		#1
	sta		xpmp_songNum
	lda		#<xpmp_song_tbl
	sta		xpmp_songTblLo
	lda		#>xpmp_song_tbl
	sta		xpmp_songTblHi
	jsr		xpmp_init

	lda		#139
	sta		xpmp_frameCnt
	
	stz		TIMER_COUNTER
	
	lda		#$FB
	sta		INTERRUPT_CTRL	

	lda		#1
	sta		TIMER_CTRL
	
	cli
play:
	lda		xpmp_frameCnt
	bne		play
	lda		#116		; ~60 Hz
	sta		xpmp_frameCnt
	jsr		xpmp_update
	bra		play
	

timer_irq:
	pha
	phx
	phy
	
	jsr		xpmp_update_dda
	lda		xpmp_channel
	sta.w	$0800				; set channel select back to what it was
	
	stz		INTERRUPT_STATUS	; acknowledge interrupt
	stz		TIMER_CTRL
	stz		TIMER_COUNTER
	lda		#1
	sta		TIMER_CTRL

	dec		xpmp_frameCnt
	
	ply
	plx
	pla
	rti
	
	
vdc_irq:
	rti	
    

; Include the music data 
.include "pcemusic.asm"




