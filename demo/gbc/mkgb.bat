..\..\bin\xpmc -gbc ..\mml\%1.mml gbmusic.asm
wla-gb -o testgb.asm testgb.o
wlalink -b testgb.link %1.gb
del testgb.o
del gbmusic.asm
