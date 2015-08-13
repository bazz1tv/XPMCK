#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  FILE *binfile,*hesfile;
  int i,mode,numbytes,size;
  char c, dummy;

  if (argc != 3)
  {
    printf("Usage: bin2hes binfile hesfile\n");
    return 1;
  }

  binfile = fopen(argv[1], "rb");
  hesfile = fopen(argv[2], "wb");
  if ((binfile == NULL) || (hesfile == NULL))
  {
     puts("Unable to open file(s)");
     return 2;
  }

  fseek(binfile, 0, SEEK_END);
  size = ftell(binfile);
  fseek(binfile, 0, SEEK_SET);

  fputs("HESM", hesfile);
  fputc(0, hesfile);
  fputc(0, hesfile);
  fputc(0x00, hesfile);
  fputc(0x40, hesfile);

  fputc(0xFF, hesfile);
  fputc(0xF8, hesfile);
  fputc(0x01, hesfile);
  fputc(0x02, hesfile);
  fputc(0x03, hesfile);
  fputc(0x04, hesfile);
  fputc(0x05, hesfile);
  fputc(0x00, hesfile);

  fputs("DATA", hesfile);

  for (i = 0; i < 0x20; i++) {
	  dummy = fgetc(binfile);
	  size--;
  }

  fputc(size&0xFF, hesfile);
  fputc((size>>8)&0xFF, hesfile);
  fputc((size>>16)&0xFF, hesfile);
  fputc(0x00, hesfile);

  fputc(0x20, hesfile);
  fputc(0x00, hesfile);
  fputc(0x00, hesfile);
  fputc(0x00, hesfile);

  fputc(0x00, hesfile);
  fputc(0x00, hesfile);
  fputc(0x00, hesfile);
  fputc(0x00, hesfile);

  for (i = 0; i < size; i++) {
	fread(&c, 1, 1, binfile);
	fwrite(&c, 1, 1, hesfile);
  }

  fclose(binfile);
  fclose(hesfile);

  return 0;
}


