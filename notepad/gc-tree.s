;much faster but requires one additional page of memory
          .macro TOGC
          mov #^B010111100000000,@#pageport        ;open pages 2 (maybe any, 5 for the better gc) and 7 (2nd scrbuf)
          .endm

gc:       cmp #strdmax,@#strdcurre      ;R2 instead of @#strdcurre - requires check
          bcc exitgc

          mov #32768,r0        ;end of tree pointer
          mov #strsstatic,r1
          mov r5,@#strestatic-2
4$:       cmp #strestatic,r1
          beq 1$

          mov r1,r3
          cmp (r1)+,@#strdstart
          bcs 4$

          TOGC
          mov r3,(r0)+
          clr (r0)+
          clr (r0)+
          TOMAIN
          cmp #strestatic,r1
          beq 1$

          cmp @r1,@#strdstart
          bcs 4$

          mov #32768,r2     ;pointer to the root
5$:       mov r2,r3
          TOGC
          mov @r2,r4
          TOMAIN
          cmp @r1,@r4
          bcc 2$

          add #2,r3      ;@r1 < @@r2, left
6$:       TOGC
          mov @r3,r2
          bne 5$

          mov r0,@r3
          TOMAIN
          br 4$

2$:       add #4,r3      ;@r1 > @@r2, right
          br 6$

1$:       mov sp,@#savesp
          mtps #128
          mov #49152,sp
          mov @#strdstart,r1
          TOGC
          push #7$
          push #32768
          br treesurvey

7$:       TOMAIN
          mov @#savesp,sp
          mtps #0
          mov r1,@#strdcurre
          mov @#strestatic-2,r5
exitgc:   return

treesurvey: pop r2
          beq exitgc

          push r2
          push #1$
          push 2(r2)
          br treesurvey

1$:       pop r2
          mov @r2,r4
          TOMAIN
          mov @r4,r0
          mov r1,@r4
          clr r3
          bisb @r0,r3
          inc r3
2$:       movb (r0)+,(r1)+
          sob r3,2$

          TOGC
          push 4(r2)
          br treesurvey

