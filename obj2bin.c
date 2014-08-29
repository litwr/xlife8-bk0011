#include <stdio.h>
#include <string.h>
#define MAX_PRG_SZ 65536
#define BUF_SZ 128

int main(int argc, char **argv) {
   char buf[BUF_SZ];
   short prg[MAX_PRG_SZ];
   int l, addr, len, len_sum = 0, pc = 2, line = 0, mod;
   if (argc != 1) {
      fputs("Run this program without arguments, e.g., obj2bin <IN >OUT\n", stderr);
      return 1;
   }
   for (;;) {
      fgets(buf, 80, stdin);
      line++; 
      l = sscanf(buf, "TEXT ADDR=%o LEN=%o\n", &addr, &len_sum);
      if (addr%2) {
          fprintf(stderr, "Odd start address\n");
          return 3;
      }
      if (l == 2) break;
   }
   for(;;) {
      fgets(buf, BUF_SZ, stdin);
      line++;
      l = sscanf(buf, " %*o: %o %o %o %o %*s\n", 
               prg + pc, prg + pc + 1, prg + pc + 2, prg + pc + 3);
      if (l == 0) {
         l = sscanf(buf, "TEXT ADDR=%*o LEN=%o\n", &len);
         if (l == 1) {
            len_sum += len;
            continue;
         }
         if (strstr(buf, "RLD")) {
            fgets(buf, BUF_SZ, stdin);
            line++;
            l = sscanf(buf, " Location counter modification %o", &mod);
            if (l == 1) {
               pc = mod/2 + 2 - addr/2;
               continue;
            }
            if (mod%1) goto l1;
         }
         break;
      }
      pc += l;
   }
   prg[0] = addr;
   prg[1] = len_sum;
l1:fprintf(stderr, "@%x %x>=%x lines=%d\n", addr, (pc - 2)*2, len_sum, line);
   if (!strstr(buf, "ENDMOD")) {
      fprintf(stderr, "Possible wrong relocation!\n");
      return 2;
   }
   fwrite(prg, pc, 2, stdout);
   return 0;
}

