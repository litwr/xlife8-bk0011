#include <stdio.h>
main() {
   FILE *f = fopen("xlife.bin", "r");
   char b[48644];
   fread(b, 48644, 1, f);
   fclose(f);

   f = fopen("xlife1.com", "w");
   //*((short*)&b[2]) = 32768 - 768;
   fwrite(b + 4, 32768 - 768, 1, f);
   fclose(f);

   f = fopen("xlife2.com", "w");
   //*((short*)&b[16384 - 768]) = *((short*)&b[16384 - 768 + 2]) = 16384;
   fwrite(b + 4 + 32768 - 768, 16384, 1, f);
   fclose(f);
}

