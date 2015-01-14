tobin:     .word 10000,1000,100,10,1
todec:    mov #stringbuf,r1  ;IN: r3 to decimal, no negative numbers support
          mov r1,r5
          movb #'0,r2
          mov #tobin,r4
          tst r3
          bpl 1$

          movb #'-,(r1)+
          inc r5
          neg r3
1$:       mov (r4)+,r0
          movb r2,@r1
          clrb 1(r1)
5$:       incb @r1
          sub r0,r3
          bcc 5$

          add r0,r3
          decb @r1
          cmpb r2,@r1
          bne 4$

          cmp r5,r1
          bne 4$

          dec r1         
4$:       inc r1
          cmp r0,#1
          bne 1$

          mov #stringbuf,r1
          return   ;high(r2)=0, r2 should be set to >4

gc:       cmp #strdmax,@#strdcurre
          bcc exitgc

          mov #32768,r0        ;end of tree pointer
          mov #strsstatic,r1
          mov r5,@#strestatic-2
4$:       cmp #strestatic,r1
          beq 1$
          
          mov r1,r3
          cmp (r1)+,@#strdstart   ;+1?
          bcs 4$

          mov r3,(r0)+
          clr (r0)+
          clr (r0)+
          cmp #strestatic,r1
          beq 1$

          mov #32768,r2     ;pointer to the root
5$:       mov r2,r3
          cmp @r1,@0(r2)
          bcc 2$

          add #2,r3      ;@r1 < @r2, left
6$:       mov @r3,r2
          bne 5$

          mov r0,@r3
          br 4$

2$:       add #4,r3      ;@r1 > @r2, right
          br 6$

1$:       mov sp,@#savesp
          mov #49152,sp
          mov @#strdstart,r1
          push #7$
          push #32768
          br treesurvey

7$:       mov r1,@#strdcurre
          mov @#savesp,sp
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
          mov @r4,r0
          mov r1,@r4
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

