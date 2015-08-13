REM Creates GameGear ROMs

..\..\bin\xpmc.exe -sgg ..\mml\%1.mml ggmusic.asm
wla-z80 -vo testgg.asm testgg.o
wlalink -b testgg.link %1.gg
del ggmusic.asm
del testgg.o