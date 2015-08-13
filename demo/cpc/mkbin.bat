..\..\bin\xpmc.exe -cpc ..\mml\%1.mml cpcmusic.asm
wla-z80 -vo testcpc.asm testcpc.o
wlalink -b testcpc.link %1.raw
..\..\bin\amsdoshd 16384 16384 %1.raw %1.bin
del testcpc.o
del %1.raw
del cpcmusic.asm