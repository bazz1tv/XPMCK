..\..\bin\xpmc.exe -c64 ..\mml\%1.mml c64music.asm 
wla-6510 -o psid.asm psid.o
wlalink -b psid.link psid.bin
wla-6510 -o -DXPMP_MAKE_SID c64music.asm psid.o
wlalink -vb psid.link %1.sid
del psid.o
del psid.bin
del c64music.asm

