..\..\bin\xpmc.exe -gen ..\mml\%1.mml %1.s
m68k-elf-as -m68000 --register-prefix-optional --bitwise-or -o sega_gcc.o sega_gcc.s
m68k-elf-as -m68000 --register-prefix-optional --bitwise-or -o charset.o charset.s
m68k-elf-as -m68000 --register-prefix-optional --bitwise-or -o testgen.o testgen.s
m68k-elf-as -m68000 --register-prefix-optional --bitwise-or -o music.o %1.s
m68k-elf-as -m68000 --register-prefix-optional --bitwise-or -o z80driver_bin.o ..\..\lib\gen\z80driver.bin.s
m68k-elf-as -m68000 --register-prefix-optional --bitwise-or -o xpmp_gen.o ..\..\lib\gen\xpmp_gen.s
m68k-elf-ld -Tmd.ld sega_gcc.o testgen.o xpmp_gen.o z80driver_bin.o charset.o music.o
m68k-elf-objcopy -I elf32-m68k -O binary a.out %1.bin
del %1.s
del sega_gcc.o
del charset.o
del testgen.o
del music.o
del z80driver_bin.o
del xpmp_gen.o
del a.out
