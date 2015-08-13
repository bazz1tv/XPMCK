..\..\bin\xpmc.exe -kss ..\mml\%1.mml kssmusic.asm
wla-z80 -vo testkss.asm testkss.o
wlalink -b testkss.link kss.bin
wla-z80 -vo -DXPMP_MAKE_KSS kssmusic.asm testkss.o
wlalink -b testkss.link %1.kss
del testkss.o
del kss.bin
del kssmusic.asm
