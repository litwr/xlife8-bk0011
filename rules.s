;*;live, born - word
;*;fillrt
;*;setrconst

fillrt1: mov #1,r4
         tstb r3
         beq 1$

2$:      asl r4
         dec r3
         bne 2$

1$:      return

fillrtsl: adc r3
         add r2,r3
         call @#fillrt1    ;sets R3=0
         mov r4,@#temp
;         clr r3
         bisb r1,r3
         return

fillrtsr: adc r3
         call @#fillrt1
         mov r4,@#temp2
         return

fillrt2: bcc 1$

         mov @#live,r4
         bit @#temp,r4
         beq 3$

2$:      asl r0
         bisb r0,gentab(r1)

         asr r0
         bne 3$

1$:      mov @#born,r4
         bit @#temp,r4
         bne 2$

3$:      tst r2
         beq 11$

         mov @#live,r4
         bit r4,@#temp2
         beq 13$

12$:     bisb r0,gentab(r1)
         return 

11$:     mov @#born,r4
         bit @#temp2,r4
         bne 12$
13$:     return

fillrt:  clr r1          ;XR
         mov #todata,@#pageport
1$:      mov #1,r0       ;AC
         clrb gentab(r1)
         mov r1,r2
         bic #65535-1,r2     ;i1
         clr r3
         bisb r1,r3
         asr r3
         asr r3
         asr r3
         asr r3
         asr r3
         clc
         push r3
         call @#fillrtsl
         bic #65535-30,r3
         asr r3
         asr r3
         mfps r5
         call @#fillrtsr
         mtps r5
         call @#fillrt2
         mov #4,r0
         mov r1,r2
         bic #65535-8,r2
         asr r2
         asr r2
         asr r2
         pop r3
         call @#fillrtsl
         bic #65535-16,r3
         aslb r3
         aslb r3
         aslb r3
         aslb r3
         mfps r5
         mov r1,r3
         bic #65535-7,r3
         call @#fillrtsr
         mtps r5
         call @#fillrt2
         mov #16,r0
         mtps r5
         call @#fillrt2
         mov #64,r0
         mov r1,r2
         bic #65535-64,r2
         aslb r2
         aslb r2
         adc r2
         mov r1,r3
         bic #65535-56,r3
         asr r3
         asr r3
         asr r3
         call @#fillrtsl
         aslb r3
         mfps r5
         mov r1,r3
         bic #65535-7,r3
         call @#fillrtsr
         mtps r5
         call @#fillrt2
         incb r1
         movb r1,r1
         bne 1$
         return   ;ZF=1 required for loadpat

setrconst:    ;IN: R4 - string, R3 - end of string, R5 - live/born
          clr @r5
2$:       cmp r4,r3
          bpl exit5

          movb (r4)+,r0
          mov #1,r1
          sub #'0,r0
          beq 11$

1$:       asl r1
          sob r0,1$

11$:      bis r1,@r5
          br 2$

showrules2:
        mov #stringbuf,r3
        mov r3,r4
        mov #1,r1
        clr r2
1$:     bit r1,@#live
        beq 2$

        call @#20$
2$:     inc r2
        asl r1
        bpl 1$

        movb #'/,(r4)+
        mov #1,r1
        clr r2
4$:     bit r1,@#born
        beq 5$

        call @#20$
5$:     inc r2
        asl r1
        bpl 4$

        clrb @r4
        sub r3,r4
        mov #32,r1
        sub r4,r1
        asr r1
        mov #19,r2
        jmp @#showptxt

20$:    mov r2,r0
        add #'0,r0
        movb r0,(r4)+
exit5:  return

