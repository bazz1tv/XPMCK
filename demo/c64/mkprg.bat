..\..\bin\xpmc.exe -c64 ..\mml\%1.mml c64music.asm
wla-6510 -o testc64.asm testc64.o
wlalink -vb testc64.link %1.prg
del testc64.o
del c64music.asm
