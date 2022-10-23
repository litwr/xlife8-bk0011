#include <stdio.h>
int main() {
   unsigned i, n, t[256] = {0};
#if defined(IBMPC)
   for (i = 0; i < 256; i++) {
      if (i & 0x10) t[i] += 1;
      if (i & 0x20) t[i] += 4;
      if (i & 0x40) t[i] += 0x10;
      if (i & 0x80) t[i] += 0x40;
      if (i & 0x1) t[i] += 0x100;
      if (i & 0x2) t[i] += 0x400;
      if (i & 0x4) t[i] += 0x1000;
      if (i & 0x8) t[i] += 0x4000;
   }
   printf("vistab:\n");
   for (i = 0; i < 16; i++) {
      printf("    dw ");
      for (n = 0; n < 15; n++)
          printf("%4xh,", t[i*16 + n]);
      printf("%4xh\n", t[i*16 + n]);
   }
   for (i = 0; i < 256; i++) t[i] = 0;
   for (i = 0; i < 256; i++) {
      if (i & 0x1) {
         t[i]++;
         if ((i & 0x10) == 0) t[i]++;
      }
      if (i & 0x2) {
         t[i] += 4;
         if ((i & 0x20) == 0) t[i] += 4;
      }
      if (i & 0x4) {
         t[i] += 16;
         if ((i & 0x40) == 0) t[i] += 16;
      }
      if (i & 0x8) {
         t[i] += 64;
         if ((i & 0x80) == 0) t[i] += 64;
      }
   }
   printf("vistabpc:\n");
   for (i = 0; i < 16; i++) {
      printf("    db ");
      for (n = 0; n < 15; n++)
          printf("0%xh,", t[i*16 + n]);
      printf("0%xh\n", t[i*16 + n]);
   }
#else
   int off = 128;
   for (i = 0; i < 256; i++) {
      if (i & 0x10) t[i] += 64;
      if (i & 0x20) t[i] += 16;
      if (i & 0x40) t[i] += 4;
      if (i & 0x80) t[i] += 1;
      if (i & 0x1) t[i] += 0x4000;
      if (i & 0x2) t[i] += 0x1000;
      if (i & 0x4) t[i] += 0x400;
      if (i & 0x8) t[i] += 0x100;
   }
   for (i = 0; i < 16; i++) {
      printf("    .word ");
      for (n = 0; n < 15; n++)
          printf("%5d,", t[i*16 + n + off]);
      printf("%5d\n", t[i*16 + n + off]);
      if (i*16 + n == 127) {printf("vistab:\n"); off = -128;}
   }
   for (i = 0; i < 256; i++) t[i] = 0;
   for (i = 0; i < 256; i++) {
      if (i & 0x1) {
         t[i] += 64;
         if ((i & 0x10) == 0) t[i] += 64;
      }
      if (i & 0x2) {
         t[i] += 16;
         if ((i & 0x20) == 0) t[i] += 16;
      }
      if (i & 0x4) {
         t[i] += 4;
         if ((i & 0x40) == 0) t[i] += 4;
      }
      if (i & 0x8) {
         t[i]++;
         if ((i & 0x80) == 0) t[i]++;
      }
   }
   printf("vistabpc:\n");
   for (i = 0; i < 16; i++) {
      printf("    .byte ");
      for (n = 0; n < 15; n++)
          printf("%3d,", t[i*16 + n]);
      printf("%3d\n", t[i*16 + n]);
   }
#endif
   return 0;
}

