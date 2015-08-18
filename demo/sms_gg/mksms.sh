#!/bin/bash
#test_sms.sh
# Creates Master System ROMs

#xpmc -sms $1.mml $1.asm
#wla-z80 -vo $1.asm $1.o
#echo "[objects]" > $1.link
#echo "$1.asm"
#wlalink -b $1.link $1.sms
#rm $1.o

xpmc -sms ~/Tracking/mml/bazz_n00b9.mml smsmusic.asm
wla-z80 -vo testsms.asm testsms.o
wlalink -bS testsms.link bazz8.sms