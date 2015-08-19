*-------------------------------------------------------
*
*       Sega startup code for the GNU Assembler
*       Translated from:
*       Sega startup code for the Sozobon C compiler
*       Written by Paul W. Lee
*       Modified from Charles Coty's code
*
*-------------------------------------------------------

        dc.l 0x0,0x200
        dc.l INT,INT,INT,INT,INT,INT,INT
        dc.l INT,INT,INT,INT,INT,INT,INT,INT
        dc.l INT,INT,INT,INT,INT,INT,INT,INT
        dc.l INT,INT,INT,HBL,INT,VBL,INT,INT
        dc.l INT,INT,INT,INT,INT,INT,INT,INT
        dc.l INT,INT,INT,INT,INT,INT,INT,INT
        dc.l INT,INT,INT,INT,INT,INT,INT,INT
        dc.l INT,INT,INT,INT,INT,INT,INT
        .ascii "SEGA GENESIS (C) 2004 FVRING    "
        .ascii "Test                                            "
        .ascii "Demo                                            "
        .ascii "GM 00000000-00"
        .byte 0xa5,0xfb
        .ascii "JD              "
        .byte 0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00
        .byte 0x00,0xff,0x00,0x00,0xff,0xff,0xff,0xff
        .ascii "               "
        .ascii "                        "
        .ascii "                         "
        .ascii "JUE             "
*debugee:
*        bra     debugee
        tst.l   0xa10008
	bne     SkipJoyDetect                               
        tst.w   0xa1000c
SkipJoyDetect:
	bne     SkipSetup
        lea     Table,%a5                       
        movem.w (%a5)+,%d5-%d7
        movem.l (%a5)+,%a0-%a4                       
* Check Version Number                      
        move.b  -0x10ff(%a1),%d0
        andi.b  #0x0f,%d0                             
	beq     WrongVersion                                   
* Sega Security Code (SEGA)   
        move.l  #0x53454741,0x2f00(%a1)
WrongVersion:
        move.w  (%a4),%d0
        moveq   #0x00,%d0                                
        movea.l %d0,%a6                                  
        move    %a6,%usp
* Set VDP registers
        moveq   #0x17,%d1
FillLoop:                           
        move.b  (%a5)+,%d5
        move.w  %d5,(%a4)                              
        add.w   %d7,%d5                                 
        dbra    %d1,FillLoop                           
        move.l  (%a5)+,(%a4)                            
        move.w  %d0,(%a3)                                 
        move.w  %d7,(%a1)                                 
        move.w  %d7,(%a2)                                 
L0250:
        btst    %d0,(%a1)
	bne     L0250                                   
* Put initial values into a00000                
        moveq   #0x25,%d2
Filla:                                 
        move.b  (%a5)+,(%a0)+
        dbra    %d2,Filla
        move.w  %d0,(%a2)                                 
        move.w  %d0,(%a1)                                 
        move.w  %d7,(%a2)                                 
L0262:
        move.l  %d0,-(%a6)
        dbra    %d6,L0262                            
        move.l  (%a5)+,(%a4)                              
        move.l  (%a5)+,(%a4)                              
* Put initial values into c00000                  
        moveq   #0x1f,%d3
Filc0:                             
        move.l  %d0,(%a3)
        dbra    %d3,Filc0
        move.l  (%a5)+,(%a4)                              
* Put initial values into c00000                 
        moveq   #0x13,%d4
Fillc1:                            
        move.l  %d0,(%a3)
        dbra    %d4,Fillc1
* Put initial values into c00011                 
        moveq   #0x03,%d5
Fillc2:                            
        move.b  (%a5)+,0x0011(%a3)        
        dbra    %d5,Fillc2                            
        move.w  %d0,(%a2)                                 
        movem.l (%a6),%d0-%d7/%a0-%a6                    
        move    #0x2700,%sr                           
SkipSetup:
	bra     Continue
Table:
        dc.w    0x8000, 0x3fff, 0x0100, 0x00a0, 0x0000, 0x00a1, 0x1100, 0x00a1
        dc.w    0x1200, 0x00c0, 0x0000, 0x00c0, 0x0004, 0x0414, 0x302c, 0x0754
        dc.w    0x0000, 0x0000, 0x0000, 0x812b, 0x0001, 0x0100, 0x00ff, 0xff00                                   
        dc.w    0x0080, 0x4000, 0x0080, 0xaf01, 0xd91f, 0x1127, 0x0021, 0x2600
        dc.w    0xf977, 0xedb0, 0xdde1, 0xfde1, 0xed47, 0xed4f, 0xd1e1, 0xf108                                   
        dc.w    0xd9c1, 0xd1e1, 0xf1f9, 0xf3ed, 0x5636, 0xe9e9, 0x8104, 0x8f01                
        dc.w    0xc000, 0x0000, 0x4000, 0x0010, 0x9fbf, 0xdfff                                

Continue:
        tst.w    0x00C00004

* set stack pointer
*        clr.l   %a7
        move.w   #0,%a7

* user mode
        move.w  #0x2300,%sr

* clear Genesis RAM
        lea     0xff0000,%a0
        moveq   #0,%d0
clrram: move.w  #0,(%a0)+
        subq.w  #2,%d0
	bne     clrram

*----------------------------------------------------------        
*
*       Load driver into the Z80 memory
*
*----------------------------------------------------------        

* halt the Z80
        move.w  #0x100,0xa11100
* reset it
        move.w  #0x100,0xa11200

        lea     Z80Driver,%a0
        lea     0xa00000,%a1
        move.l  #Z80DriverEnd,%d0
        move.l  #Z80Driver,%d1
        sub.l   %d1,%d0
Z80loop:
        move.b  (%a0)+,(%a1)+
        subq.w  #1,%d0
	bne     Z80loop

* enable the Z80
        move.w  #0x0,0xa11100

*----------------------------------------------------------        
        jmp      main

INT:    
	rte

HBL:
        addq.l   #1,htimer 
	rte

VBL:
        addq.l   #1,vtimer 
	rte

*------------------------------------------------
*
*       Get a random number.  This routine
*       was found in TOS.
*
*       Output
*       ------
*       d0 = random number
*
*------------------------------------------------

        .globl  random

random:
                move.l      rand_num,%d0
                tst.l       %d0
                bne         .L1
                moveq       #16,%d1
                lsl.l       %d1,%d0
                or.l        htimer,%d0
                move.l      %d0,rand_num
.L1:
                move.l      #-1153374675,-(%sp)
                move.l      rand_num,-(%sp)
                bsr         lmul
                addq.w      #8,%sp
                addq.l      #1,%d0
                move.l      %d0,rand_num

                lsr.l       #8,%d0
                and.l       #16777215,%d0
                rts


*------------------------------------------------
*
* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
*
* Permission is granted to anyone to use this software for any purpose
* on any computer system, and to redistribute it freely, with the
* following restrictions:
* 1) No charge may be made other than reasonable charges for reproduction.
* 2) Modified versions must be clearly marked as such.
* 3) The authors are not responsible for any harmful consequences
*    of using this software, even if they result from defects in it.
*
*------------------------------------------------

ldiv:
        move.l  4(%a7),%d0
	bpl     ld1
        neg.l   %d0
ld1:
        move.l  8(%a7),%d1
	bpl     ld2
        neg.l   %d1
        eor.b   #0x80,4(%a7)
ld2:
	bsr     i_ldiv          /* d0 = d0/d1 */
        tst.b   4(%a7)
	bpl     ld3
        neg.l   %d0
ld3:
	rts

lmul:
        move.l  4(%a7),%d0
	bpl     lm1
        neg.l   %d0
lm1:
        move.l  8(%a7),%d1
	bpl     lm2
        neg.l   %d1
        eor.b   #0x80,4(%a7)
lm2:
	bsr     i_lmul          /* d0 = d0*d1 */
        tst.b   4(%a7)
	bpl     lm3
        neg.l   %d0
lm3:
	rts

lrem:
        move.l  4(%a7),%d0
	bpl     lr1
        neg.l   %d0
lr1:
        move.l  8(%a7),%d1
	bpl     lr2
        neg.l   %d1
lr2:
	bsr     i_ldiv          /* d1 = d0%d1 */
        move.l  %d1,%d0
        tst.b   4(%a7)
	bpl     lr3
        neg.l   %d0
lr3:
	rts

ldivu:
        move.l  4(%a7),%d0
        move.l  8(%a7),%d1
	bsr     i_ldiv
	rts

lmulu:
        move.l  4(%a7),%d0
        move.l  8(%a7),%d1
	bsr     i_lmul
	rts

lremu:
        move.l  4(%a7),%d0
        move.l  8(%a7),%d1
	bsr     i_ldiv
        move.l  %d1,%d0
	rts
*
* A in d0, B in d1, return A*B in d0
*
i_lmul:
        move.l  %d3,%a2           /* save d3 */
        move.w  %d1,%d2
        mulu    %d0,%d2           /* d2 = Al * Bl */

        move.l  %d1,%d3
        swap    %d3
        mulu    %d0,%d3           /* d3 = Al * Bh */

        swap    %d0
        mulu    %d1,%d0           /* d0 = Ah * Bl */

        add.l   %d3,%d0           /* d0 = (Ah*Bl + Al*Bh) */
        swap    %d0
        clr.w   %d0              /* d0 = (Ah*Bl + Al*Bh) << 16 */

        add.l   %d2,%d0           /* d0 = A*B */
        move.l  %a2,%d3           /* restore d3 */
	rts
*
*A in d0, B in d1, return A/B in d0, A%B in d1
*
i_ldiv:
        tst.l   %d1
	bne     nz1

*       divide by zero
*       divu    #0,%d0           /* cause trap */
        move.l  #0x80000000,%d0
        move.l  %d0,%d1
	rts
nz1:
        move.l  %d3,%a2           /* save d3 */
        cmp.l   %d1,%d0
	bhi     norm
	beq     is1
*       A<B, so ret 0, rem A
        move.l  %d0,%d1
        clr.l   %d0
        move.l  %a2,%d3           /* restore d3 */
	rts
*       A==B, so ret 1, rem 0
is1:
        moveq.l #1,%d0
        clr.l   %d1
        move.l  %a2,%d3           /* restore d3 */
	rts
*       A>B and B is not 0
norm:
        cmp.l   #1,%d1
	bne     not1
*       B==1, so ret A, rem 0
        clr.l   %d1
        move.l  %a2,%d3           /* restore d3 */
	rts
*  check for A short (implies B short also)
not1:
        cmp.l   #0xffff,%d0
	bhi     slow
*  A short and B short -- use 'divu'
        divu    %d1,%d0           /* d0 = REM:ANS */
        swap    %d0              /* d0 = ANS:REM */
        clr.l   %d1
        move.w  %d0,%d1           /* d1 = REM */
        clr.w   %d0
        swap    %d0
        move.l  %a2,%d3           /* restore d3 */
	rts
* check for B short
slow:
        cmp.l   #0xffff,%d1
	bhi     slower
* A long and B short -- use special stuff from gnu
        move.l  %d0,%d2
        clr.w   %d2
        swap    %d2
        divu    %d1,%d2           /* d2 = REM:ANS of Ahi/B */
        clr.l   %d3
        move.w  %d2,%d3           /* d3 = Ahi/B */
        swap    %d3

        move.w  %d0,%d2           /* d2 = REM << 16 + Alo */
        divu    %d1,%d2           /* d2 = REM:ANS of stuff/B */

        move.l  %d2,%d1
        clr.w   %d1
        swap    %d1              /* d1 = REM */

        clr.l   %d0
        move.w  %d2,%d0
        add.l   %d3,%d0           /* d0 = ANS */
        move.l  %a2,%d3           /* restore d3 */
	rts
*       A>B, B > 1
slower:
        move.l  #1,%d2
        clr.l   %d3
moreadj:
        cmp.l   %d0,%d1
	bhs     adj
        add.l   %d2,%d2
        add.l   %d1,%d1
	bpl     moreadj
* we shifted B until its >A or sign bit set
* we shifted #1 (d2) along with it
adj:
        cmp.l   %d0,%d1
	bhi     ltuns
        or.l    %d2,%d3
        sub.l   %d1,%d0
ltuns:
        lsr.l   #1,%d1
        lsr.l   #1,%d2
	bne     adj
* d3=answer, d0=rem
        move.l  %d0,%d1
        move.l  %d3,%d0
        move.l  %a2,%d3           /* restore d3 */
	rts
*----------------------------------------------------------        
*
*       Z80 Sound Driver
*
*----------------------------------------------------------        
Z80Driver:
          dc.b  0xc3,0x46,0x00,0x00,0x00,0x00,0x00,0x00
          dc.b  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
          dc.b  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
          dc.b  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
          dc.b  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
          dc.b  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
          dc.b  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
          dc.b  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
          dc.b  0x00,0x00,0x00,0x00,0x00,0x00,0xf3,0xed
          dc.b  0x56,0x31,0x00,0x20,0x3a,0x39,0x00,0xb7
          dc.b  0xca,0x4c,0x00,0x21,0x3a,0x00,0x11,0x40
          dc.b  0x00,0x01,0x06,0x00,0xed,0xb0,0x3e,0x00
          dc.b  0x32,0x39,0x00,0x3e,0xb4,0x32,0x02,0x40
          dc.b  0x3e,0xc0,0x32,0x03,0x40,0x3e,0x2b,0x32
          dc.b  0x00,0x40,0x3e,0x80,0x32,0x01,0x40,0x3a
          dc.b  0x43,0x00,0x4f,0x3a,0x44,0x00,0x47,0x3e
          dc.b  0x06,0x3d,0xc2,0x81,0x00,0x21,0x00,0x60
          dc.b  0x3a,0x41,0x00,0x07,0x77,0x3a,0x42,0x00
          dc.b  0x77,0x0f,0x77,0x0f,0x77,0x0f,0x77,0x0f
          dc.b  0x77,0x0f,0x77,0x0f,0x77,0x0f,0x77,0x3a
          dc.b  0x40,0x00,0x6f,0x3a,0x41,0x00,0xf6,0x80
          dc.b  0x67,0x3e,0x2a,0x32,0x00,0x40,0x7e,0x32
          dc.b  0x01,0x40,0x21,0x40,0x00,0x7e,0xc6,0x01
          dc.b  0x77,0x23,0x7e,0xce,0x00,0x77,0x23,0x7e
          dc.b  0xce,0x00,0x77,0x3a,0x39,0x00,0xb7,0xc2
          dc.b  0x4c,0x00,0x0b,0x78,0xb1,0xc2,0x7f,0x00
          dc.b  0x3a,0x45,0x00,0xb7,0xca,0x4c,0x00,0x3d
          dc.b  0x3a,0x45,0x00,0x06,0xff,0x0e,0xff,0xc3
          dc.b  0x7f,0x00
Z80DriverEnd:


