// Add an AMSDOS header to a binary
// Mic, 2009

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
  FILE *fp,*fp2;
  int size,loadaddr,execaddr,i;
  unsigned int checksum;
  char dummy;
  char header[128];
  char *cp;
  
  if (argc != 5)
  {
    printf("Usage: amsdoshd loadaddress execaddress input output\n");
    return 1;
  }
  loadaddr = atoi(argv[1]);
  execaddr = atoi(argv[2]);

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

  for (i=0; i<128; i++) header[i] = 0;

  cp = strstr(argv[3], ".");
  for (i=0; i<8; i++)
  {
	  if (i<strlen(argv[3]))
	  {
		  if ((cp==NULL)||(argv[3]+i<cp))
		  {
			  header[1+i] = argv[3][i];
			  if ((header[1+i]>='a')&&(header[1+i]<='z')) header[1+i] -= ' ';
			  continue;
		  }
	  }
	  header[1+i] = ' ';
  }
  header[9] = 'B'; header[10] = 'I'; header[11] = 'N';

  header[18] = 2;
  header[21] = loadaddr&0xff; header[22] = loadaddr>>8;
  header[26] = execaddr&0xff; header[27] = execaddr>>8;
  header[24] = header[64] = size&0xff; header[25] = header[65] = size>>8;

  checksum = 0;
  for (i=0; i<67; i++)
	  checksum += (unsigned char)header[i];

  header[67] = checksum&0xff; header[68] = checksum>>8;

  fwrite(header, 1, 128, fp2);

  while ((fread(&dummy, 1, 1, fp) != 0) && (size--))
  {
    fwrite(&dummy, 1, 1, fp2);
  }
  
  fclose(fp);
  fclose(fp2);

  return 0;
}
