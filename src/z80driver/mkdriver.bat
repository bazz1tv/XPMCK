wla-z80 -vo z80driver.asm z80driver.o
wlalink -vb z80driver.link z80driver.bin
..\..\bin\bin2s.exe z80driver.bin
del z80driver.bin
del z80driver.o
echo You need to copy z80driver.bin.s to \lib\gen
