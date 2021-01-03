#include <stdio.h>
int main() {
   FILE *f = fopen("xlife.bin", "r");
   char b[48644];
   fread(b, 48644, 1, f);
   fclose(f);

   f = fopen("xlife1.com", "w");
   fwrite(b + 4, 32768 - 512, 1, f);
   fclose(f);

   f = fopen("xlife2.com", "w");
   fwrite(b + 4 + 32768 - 512, 16384, 1, f);
   fclose(f);
}

