# NOTE: bin folder must have been created

all: bin/xpmc bin/amsdoshd bin/bin2hes bin/bin2s bin/bin2sap bin/stripfile

bin/xpmc: src/*
	euc src/xpmc.exw -o bin/xpmc
bin/amsdoshd:
	gcc src/amsdoshd/main.c -o bin/amsdoshd
bin/bin2hes:
	g++ src/bin2hes/main.cpp -o bin/bin2hes
bin/bin2s:
	g++ src/bin2s/main.cpp -o bin/bin2s
bin/bin2sap:
	gcc src/bin2sap/main.c -o bin/bin2sap
bin/stripfile:
	gcc src/stripfile/main.c -o bin/stripfile
