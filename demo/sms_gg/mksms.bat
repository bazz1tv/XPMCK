REM Creates Master System ROMs

..\..\bin\xpmc.exe -sms ..\mml\%1.mml smsmusic.asm
wla-z80 -vo testsms.asm testsms.o
wlalink -b testsms.link %1.sms
del smsmusic.asm
del testsms.o