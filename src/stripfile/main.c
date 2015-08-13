// Strip the first/last n bytes from a file
// Mic, 2008

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  FILE *fp,*fp2;
  int mode,numbytes,size;
  char dummy;
  
  if (argc != 5)
  {
    printf("Usage: stripfile -first|-last numbytes input output\n");
    return 1;
  }
  if (strcmp(argv[1], "-first") == 0)
  {
     mode = 0;
  }
  else if (strcmp(argv[1], "-last") == 0)
  {
     mode = 1;
  }
  else
  {
    printf("Usage: stripfile -first|-last numbytes input output\n");
    return 1;
  }

  fp = fopen(argv[3], "rb");
  fp2 = fopen(argv[4], "wb");
  if ((fp == NULL) || (fp2 == NULL))
  {
     puts("Unable to open file(s)");
     return 2;
  }

  fseek(fp, 0, SEEK_END);
  size = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  numbytes = atoi(argv[2]);
  if (numbytes < 1 || numbytes >= size)
  {
     printf("numbytes must be positive and less than the input file size\n");
     return 1;
  }

  size -= numbytes;
  if (mode == 0)
  {
     fseek(fp, numbytes, SEEK_SET);            
  }
  while ((fread(&dummy, 1, 1, fp) != 0) && (size--))
  {
    fwrite(&dummy, 1, 1, fp2);
  }
  
  fclose(fp);
  fclose(fp2);

  return 0;
}
