# NOTE: bin folder must have been created

CC = gcc
CPP = g++

progs = bin/xpmc bin/amsdoshd bin/bin2hes bin/bin2s bin/bin2sap bin/stripfile

all: $(progs)

bin/xpmc: src/*.e src/xpmc.exw
	euc src/xpmc.exw -o bin/xpmc
bin/amsdoshd: src/amsdoshd/main.c
	$(CC) src/amsdoshd/main.c -o bin/amsdoshd
bin/bin2hes: src/bin2hes/main.c
	$(CC) src/bin2hes/main.c -o bin/bin2hes
bin/bin2s: src/bin2s/main.cpp
	$(CPP) src/bin2s/main.cpp -o bin/bin2s
bin/bin2sap: src/bin2sap/main.c
	$(CC) src/bin2sap/main.c -o bin/bin2sap
bin/stripfile: src/stripfile/main.c
	$(CC) src/stripfile/main.c -o bin/stripfile

clean:
	rm -f $(progs)
