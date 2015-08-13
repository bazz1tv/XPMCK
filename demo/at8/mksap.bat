..\..\bin\xpmc -v -at8 ..\mml\%1.mml at8music.asm
wla-6502 -o sap.asm sap.o
wlalink -b sap.link sap.bin
..\..\bin\bin2sap sap.bin sapheader.txt %1.sap
del sap.o
del sap.bin
del sapheader.txt
del at8music.asm
