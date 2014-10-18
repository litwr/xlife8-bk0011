#include <stdio.h>
#include <string.h>
int off = 128;
int main() {
   unsigned i, n, t[256] = {0};
   for (i = 0; i < 256; i++) {
      if (i & 0x80) t[i] += 64;
      if (i & 0x40) t[i] += 16;
      if (i & 0x20) t[i] += 4;
      if (i & 0x10) t[i] += 1;
      if (i & 0x8) t[i] += 0x4000;
      if (i & 0x4) t[i] += 0x1000;
      if (i & 0x2) t[i] += 0x400;
      if (i & 0x1) t[i] += 0x100;
   }
   for (i = 0; i < 16; i++) {
      printf("    %s ", ".word");
      for (n = 0; n < 15; n++)
          printf("%3d,", t[i*16 + n + off]);
      printf("%3d\n", t[i*16 + n + off]);
      if (i*16 + n == 127) {printf("vistab:\n"); off = -128;}
   }
   return 0;
}

