..\..\bin\xpmc.exe -v -pce ..\mml\%1.mml pcemusic.asm
wla-huc6280 -o hes.asm sap.o
wlalink -bS sap.link hes.bin
..\..\bin\bin2hes hes.bin %1.hes
REM \pcedev\mednafen-0.8.D-win32\mednafen.exe %1.hes

del sap.o
del hes.bin
del pcemusic.asm
