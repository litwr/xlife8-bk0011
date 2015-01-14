tobin:     .word 10000,1000,100,10,1
todec:    mov #stringbuf,r2  ;IN: r3 to decimal, no negative numbers support
          mov #tobin,r4
1$:       mov (r4)+,r0
          movb #'0,@r2
5$:       incb @r2
          sub r0,r3
          bcc 5$

          add r0,r3
          decb (r2)+
          cmp r0,#1
          bne 1$

          mov #stringbuf,r1
3$:       cmpb @r1,#'0
          bne 2$

          cmp r1,#stringbuf+4
          beq 2$

          inc r1
          br 3$

2$:       movb #5,r2
          return

gc:       cmp #strdmax,@#strdcurre
          bcc exitgc

          mov #32768,r0        ;end of tree pointer
          mov @#strsstatic,r1
4$:       mov r1,(r0)+
          clr (r0)+
          clr (r0)+
3$:       cmp @#strestatic,r1
          beq 1$
         
          inc r1
          inc r1
          cmp @r1,@#strdstart
          bcs 3$

          mov #32768,r2     ;pointer to the root
5$:       mov r2,r3
          cmp @r1,@r2
          bcc 2$

          add #2,r3      ;@r1 < @r2
6$:       mov @r3,r2
          bne 5$

          mov r0,@r3
          br 4$

2$:       add #4,r3      ;@r1 > @r2
          br 6$

1$:       mov sp,@#savesp
          mov #49152,sp
          mov @#strdstart,r1
          push #32768
          call @#treesurvey
          mov r1,@#strdcurre
          mov @#savesp,sp
exitgc:   return

treesurvey: pop r2
          beq exitgc

          push 2(r2)
          call @#treesurvey
          mov @r2,r0
          mov r1,@r2
          clr r3
          bisb @r0,r3
          inc r3
2$:       movb (r0)+,(r1)+
          sob r3,2$

          push 4(r2)
          br treesurvey

strdstart: .word 16385
strdcurre: .word 16385
lib_end:

