gc:       cmp #strdmax,@#strdcurre      ;R2 instead of @#strdcurre - requires check
          bcc exitgc

gc0:      mov @#strdstart,r3
          mov r5,@#strestatic-2
7$:       mov #strsstatic,r1
          clr r0
3$:       cmp #strestatic,r1
          beq 8$

          mov @r1,r4
          cmp r4,r3
          bne 1$

          clr r2
          bisb @r4,r2
          add r2,r3
          inc r3
4$:       add #2,r1
          br 3$

1$:       bcs 4$

          tst r0
          bne 5$

          mov r1,r0
          br 4$

5$:       cmp @r0,r4
          bcs 4$

          mov r1,r0
          br 4$

8$:       tst r0
          beq 2$
          
          mov r3,r4
          mov @r0,r5
          mov r4,@r0
          clr r2
          bisb (r5)+,r2
          movb r2,(r4)+
          beq 4$

6$:       movb (r5)+,(r4)+
          sob r2,6$
          mov r4,r3
          br 7$
          
2$:       mov r3,@#strdcurre
          mov @#strestatic-2,r5
exitgc:   return

