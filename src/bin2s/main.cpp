#define _CRT_SECURE_NO_DEPRECATE

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>
using namespace std;


enum { MODE_BYTE,
       MODE_WORD,
	   MODE_DWORD };

enum { MODE_LE,
	   MODE_BE };

enum { MODE_WLADX,
	   MODE_GAS };

enum { SET_SIZE = 0,
	   SET_ENDIANNESS,
	   SET_ASSEMBLER };

typedef struct 
{
	const char *lpszOption;
	const int idx;
	const int setting;
} option_t;

const option_t OPTIONS[7] = 
{
	{"-byte",  SET_SIZE,       MODE_BYTE},
	{"-short", SET_SIZE,       MODE_WORD},
	{"-long",  SET_SIZE,       MODE_DWORD},
	{"-le",    SET_ENDIANNESS, MODE_LE},
	{"-be",    SET_ENDIANNESS, MODE_BE},
	{"-wla",   SET_ASSEMBLER,  MODE_WLADX},
	{"-gas",   SET_ASSEMBLER,  MODE_GAS}
};

int main(int argc, char *argv[])
{
	int i, inSize, labelStart;
	int options[3] = {MODE_BYTE, MODE_LE, MODE_GAS};
	FILE *inFile, *outFile;
	string *outFileName, *labelName;
	char *lbl;
	char c;

	for (i = 1; i < argc; i++)
	{
		for (int j = 0; j < 7; j++)
		{
			if (strcmp(argv[i], OPTIONS[j].lpszOption) == 0)
			{
				options[OPTIONS[j].idx] = OPTIONS[j].setting;
				break;
			}
		}
	}

	inFile = fopen(argv[argc - 1], "rb");
	fseek(inFile, 0, SEEK_END);
	inSize = ftell(inFile);
	fseek(inFile, 0, SEEK_SET);

	outFileName = new string(argv[argc - 1]);
	labelName = new string(argv[argc - 1]);
	
	for (labelStart = labelName->length() - 1; labelStart >= 0; labelStart--)
	{
		if ((*labelName)[labelStart] == '\\') break;
	}
	labelStart = (labelStart < 0) ? 0 : labelStart;

	for (i = labelStart; i < labelName->length(); i++)
	{
		if ((*labelName)[i] == '.') (*labelName)[i] = '_';
	}

	if (options[SET_ASSEMBLER] == MODE_GAS)
	{
		outFileName->append(".s");
		outFile = fopen(outFileName->data(), "wb");

		lbl = (char *)(labelName->data()) + labelStart;
		fprintf(outFile, ".text\n.globl %s\n.globl %s_end\n\n%s:", lbl, lbl, lbl);

		if (options[SET_SIZE] == MODE_BYTE)
		{
			for (i = 0; i < inSize; i++)
			{
				c = fgetc(inFile);
				if (!(i & 15))
				{
					fprintf(outFile, "\ndc.b 0x%02x", c & 0xff);
				}
				else
				{
					fprintf(outFile, ",0x%02x", c & 0xff);
				}
			}
		}

		fprintf(outFile, "\n%s_end:\n", lbl);
	}
	else
	{
		outFileName->append(".asm");
		outFile = fopen(outFileName->data(), "wb");
	}

	fclose(inFile);
	fclose(outFile);
	delete outFileName;

	return 0;
}