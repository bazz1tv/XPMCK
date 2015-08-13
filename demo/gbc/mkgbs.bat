..\..\bin\xpmc.exe -gbc ..\mml\%1.mml gbmusic.asm
wla-gb -o gbs.asm gbs.o
wlalink -b gbs.link gbs.bin
wla-gb -o -DXPMP_MAKE_GBS gbmusic.asm gbs.o
wlalink -vb gbs.link %1.gbs
del gbs.o
del gbs.bin
del gbmusic.asm

