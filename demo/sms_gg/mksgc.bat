REM Creates .SGC files (Kevin Horton's SMS/GG/CLV music rip format)

..\..\bin\xpmc.exe -v -sgg ..\mml\%1.mml sgcmusic.asm
wla-z80 -vo sgc.asm sgc.o
wlalink -b sgc.link sgc.bin
wla-z80 -o -DXPMP_MAKE_SGC sgcmusic.asm sgc.o
wlalink -b sgc.link %1.sgc
del sgc.o
del sgc.bin
del sgcmusic.asm
