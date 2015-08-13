#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  FILE *binfile,*headerfile,*sapfile;
  int mode,numbytes,size;
  char c, dummy;
  
  if (argc != 4)
  {
    printf("Usage: bin2sap binfile headerfile sapfile\n");
    return 1;
  }

  binfile = fopen(argv[1], "rb");
  headerfile = fopen(argv[2], "rb");
  sapfile = fopen(argv[3], "wb");
  if ((binfile == NULL) || (headerfile == NULL) || (sapfile == NULL))
  {
     puts("Unable to open file(s)");
     return 2;
  }

  fseek(binfile, 0, SEEK_END);
  size = ftell(binfile);
  fseek(binfile, 0, SEEK_SET);

  while ((fread(&c, 1, 1, headerfile) != 0))
  {
    fwrite(&c, 1, 1, sapfile);
  }
  fclose(headerfile);

  fputc(0xFF, sapfile);
  fputc(0xFF, sapfile);
  fputc(0x00, sapfile);
  fputc(0x20, sapfile);
  fputc((0x2000 + size - 1)&0xFF, sapfile);
  fputc((0x2000 + size - 1)>>8, sapfile);

  while ((fread(&c, 1, 1, binfile) != 0))
  {
    fwrite(&c, 1, 1, sapfile);
  }
  fclose(binfile);

  fclose(sapfile);

  return 0;
}