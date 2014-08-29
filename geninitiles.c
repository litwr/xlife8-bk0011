#include <stdio.h>
#define TS 70

main() {
   int i, x, y, tiles = 15482, cur, video = 4;
   unsigned short b[TS/2] = {0};
   for (y = 0; y < 20; y++, video += 40)
       for (x = 0; x < 24; x++, video++) {
          cur = tiles + (y*24 + x)*TS;
          b[4] = cur - TS;
          b[5] = cur - TS*25;
          b[6] = cur - TS*24;
          b[7] = cur - TS*23;
          b[8] = cur + TS;
          b[9] = cur + TS*25;
          b[10] = cur + TS*24;
          b[11] = cur + TS*23;
          if (y == 0) {
             b[5] = cur + TS*(24*19 - 1);
             b[6] = cur + TS*24*19;
             b[7] = cur + TS*(24*19 + 1);
             if (x == 0) {
                b[4] = cur + TS*23;
                b[5] = cur + TS*(20*24 - 1);
                b[11] = cur + TS*(24*2 - 1);
             } 
             else if (x == 23) {
                b[7] = cur + TS*(18*24 + 1);
                b[8] = cur - TS*23;
                b[9] = cur + TS;
             }
          }
          else if (y == 19) {
             b[9] = cur - TS*(24*19 - 1);
             b[10] = cur - TS*24*19;
             b[11] = cur - TS*(24*19 + 1);
             if (x == 0) {
                b[4] = cur + TS*23;
                b[5] = cur - TS;
                b[11] = cur - TS*(18*24 + 1);
             } 
             else if (x == 23) {
                b[7] = cur - TS*(2*24-1);
                b[8] = cur - TS*23;
                b[9] = tiles;
             }
          }
          else if (x == 0) {
             b[4] = cur + TS*23;
             b[5] = cur - TS;
             b[11] = cur + TS*(24*2 - 1);
          }
          else if (x == 23) {
             b[7] = cur - TS*(24*2 - 1);
             b[8] = cur - TS*23;
             b[9] = cur + TS;
          }
          b[29] = video;
          printf("    .word ");
          for (i = 0; i < 9; i++) printf("%o, ", b[i]);
          printf("%o\n    .word ", b[i]);
          for (i = 10; i < 19; i++) printf("%o, ", b[i]);
          printf("%o\n    .word ", b[i]);
          for (i = 20; i < 29; i++) printf("%o, ", b[i]);
          printf("%o\n    .word ", b[i]);
          for (i = 30; i < 34; i++) printf("%o, ", b[i]);
          printf("%o\n", b[i]);
      }
}

