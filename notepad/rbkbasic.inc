tobin:     .word 10000,1000,100,10,1
stringbuf: .byte 0,0,0,0,0,0
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

lib_end:


