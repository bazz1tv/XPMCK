# NOTE: bin folder must have been created

all: bin/xpmc bin/amsdoshd bin/bin2hes bin/bin2s bin/bin2sap bin/stripfile

bin/xpmc: src/*.e src/xpmc.exw
	euc src/xpmc.exw -o bin/xpmc
bin/amsdoshd: src/amsdoshd/main.c
	gcc src/amsdoshd/main.c -o bin/amsdoshd
bin/bin2hes: src/bin2hes/main.cpp
	g++ src/bin2hes/main.cpp -o bin/bin2hes
bin/bin2s: src/bin2s/main.cpp
	g++ src/bin2s/main.cpp -o bin/bin2s
bin/bin2sap: src/bin2sap/main.c
	gcc src/bin2sap/main.c -o bin/bin2sap
bin/stripfile: src/stripfile/main.c
	gcc src/stripfile/main.c -o bin/stripfile
