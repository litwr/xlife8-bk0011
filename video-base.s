initxt:   mov #toandos,@#pageport
          clr r1
          mov #18,r2
          emt ^O24
          jsr r3,@#printstr
          .byte 147,'G,0,0

          mov #18,r1
          emt ^O24
          jsr r3,@#printstr
          .byte '%,32,32,32,32,32,'X,32,32,32,'Y,145,0,0

          mov #65535,r2
          mov #20,r3
          mov #16384+12+64,r1
          mov #16384+12+<64*194>,r0
1$:       mov r2,(r1)+
          mov r2,(r0)+
          sob r3,1$

          mov #194,r3
          mov #16384+11+64,r1
2$:       movb #192,@r1
          movb #3,41(r1)
          add #64,r1
          sob r3,2$
          jmp @#gexit3

totext:    call @#clrscn
           mov #toandos,@#pageport
           return

tograph:   jsr r3,@#printstr
           .byte 145,0
           mov #10,r0
1$:        cmp #^O1330,@#yshift
           beq 2$

           emt ^O16
           br 1$

2$:        jsr r3,@#printstr
           .byte 12,0
tograph0:  call @#clrscn
           call @#initxt
           call @#showscn
           call @#showmode
           call @#showtopology
           call @#showrules2
           jmp @#xyout

printstr:  movb (r3)+,r0  ;use: r0, r1
           beq 2$

           cmp #9,r0
           bne 3$

           mov #9,r1
           mov #32,r0
1$:        emt ^O16
           sob r1,1$

3$:        emt ^O16
           br printstr

2$:        inc r3
           bic #1,r3
           rts r3

digiout:        ;in: r1 - length, r2 - scrpos, r0 - data
1$:      movb (r0)+,r3
         asl r3
         asl r3
         asl r3
         asl r3
         mov digifont+2(r3),64(r2)
         mov digifont+4(r3),128(r2)
         mov digifont+6(r3),192(r2)
         mov digifont+8(r3),256(r2)
         mov digifont+10(r3),320(r2)
         mov digifont+12(r3),384(r2)
         mov digifont(r3),(r2)+
         sob r1,1$
         return

