..\..\bin\xpmc.exe -clv ..\mml\%1.mml clvmusic.asm
wla-z80 -vo testclv.asm testclv.o
wlalink -b testclv.link %1.rom
del clvmusic.asm
del testclv.o