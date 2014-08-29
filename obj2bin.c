#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
   char buf[80];
   int n, l, d[4], addr, len;
   if (argc != 1) return 1;
   for (;;) {
      fgets(buf, 80, stdin); 
      l = sscanf(buf, "TEXT ADDR=%o LEN=%o\n", &addr, &len);
      if (l == 2) break;
   }
   //addr += 01000;
   fwrite(&addr, 2, 1, stdout);
   fwrite(&len, 2, 1, stdout);
   for(;;) {
      fgets(buf, 80, stdin);
      l = sscanf(buf, " %*d: %o %o %o %o %*s\n", d, d+1, d+2, d+3);
      if (l == 0) break;
      n = 0;
      while (n < l)
        fwrite(&d[n++], 2, 1, stdout);
   }
   return 0;
}

