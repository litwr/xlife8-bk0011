;*;live, born - word
;*;fillrt
;*;setrconst

fillrt1:
;*         tay
;*         php
;*         lda #1
;*         plp
;*         beq l1
         mov #1,r4
         tstb r3
         beq 1$

;*l2       asl
;*         dey
;*         bne l2
2$:      asl r4
         dec r3
         bne 2$

;*l1       rts
1$:      return

fillrtsl:
;*         adc i1
         adc r3
         add r2,r3

;*         jsr fillrt1
         call @#fillrt1

;*         sta adjcell
;*         lda #0
;*         rol
;*         sta adjcell+1
         mov r4,@#temp

;*         txa
;*         rts
         mov r1,r3
         bic #65535-255,r3
         return


fillrtsr:
;*         adc #0
;*         jsr fillrt1
         adc r3
         call @#fillrt1

;*         sta adjcell2
;*         lda #0
;*         rol
;*         sta adjcell2+1
;*         rts
         mov r4,@#temp2
         return


fillrt2:
;*         bcc l1
         bcc 1$

;*         lda live
;*         and adjcell
;*         bne l2

;*         lda live+1
;*         and adjcell+1
;*         beq l3
         mov @#live,r4
         bit @#temp,r4
         beq 3$

;*l2       asl t1
;*         lda gentab,x
;*         ora t1
;*         sta gentab,x
2$:      asl r0
         bisb r0,gentab(r1)

;*         lsr t1
;*         bne l3
         asr r0
         bne 3$

;*l1       lda born
;*         and adjcell
;*         bne l2
;*
;*         lda born+1
;*         and adjcell+1
;*         bne l2
1$:      mov @#born,r4
         bit @#temp,r4
         bne 2$

;*         lda i1  ;test r
;*         beq l1
3$:      tst r2
         beq 11$

;*         lda live
;*         and adjcell2
;*         bne l2
;*         lda live+1
;*         and adjcell2+1
;*         beq l3
         mov @#live,r4
         bit r4,@#temp2
         beq 13$

;*l2       lda gentab,x
;*         ora t1
;*         sta gentab,x
;*         rts
12$:     bisb r0,gentab(r1)
         return 

;*l1       lda born
;*         and adjcell2
;*         bne l2
;*
;*         lda born+1
;*         and adjcell2+1
;*         bne l2
11$:     mov @#born,r4
         bit @#temp2,r4
         bne 12$

;*         rts
13$:     return

fillrt:
;*         ldx #0
;*l0       lda #1
;*         sta t1
         clr r1          ;XR
1$:      mov #1,r0       ;AC

;*         lda #0
;*         sta gentab,x
         clrb gentab(r1)

;*         txa
;*         and #1
;*         sta i1  ;r - see gengentab.c
         mov r1,r2
         bic #65535-1,r2     ;i1

;*         txa
;*         lsr
;*         lsr
;*         lsr
;*         lsr
;*         lsr
         mov r1,r3
         bic #65535-255,r3
         asr r3
         asr r3
         asr r3
         asr r3
         asr r3

;*         pha
;*         clc
;*         jsr fillrtsl
         clc
         push r3
         call @#fillrtsl

;*         and #$1e
;*         lsr
;*         lsr
         bic #65535-30,r3
         asr r3
         asr r3

;*         php
;*         jsr fillrtsr
;*         plp
;*         jsr fillrt2
         mfps r5
         call @#fillrtsr
         mtps r5
         call @#fillrt2

;*         lda #4
;*         sta t1
         mov #4,r0

;*         txa
;*         and #8
;*         lsr
;*         lsr
;*         lsr
;*         sta i1 ;r
         mov r1,r2
         bic #65535-8,r2
         asr r2
         asr r2
         asr r2

;*         pla
;*         jsr fillrtsl
         pop r3
         call @#fillrtsl

;*         and #$10
;*         asl
;*         asl
;*         asl
         bic #65535-16,r3
         aslb r3
         aslb r3
         aslb r3

;*         ;sta i1+1
;*         asl
;*         php
         aslb r3
         mfps r5

;*         txa
;*         and #7
         mov r1,r3
         bic #65535-7,r3

;*         jsr fillrtsr
         call @#fillrtsr

;*         plp
;*         php
;*         jsr fillrt2
         mtps r5
         call @#fillrt2

;*         lda #16
;*         sta t1
;*         plp
;*         jsr fillrt2
         mov #16,r0
         mtps r5
         call @#fillrt2

;*         lda #64
;*         sta t1
         mov #64,r0

;*         txa
;*         and #$40
;*         asl
;*         asl
;*         adc #0
;*         sta i1
         mov r1,r2
         bic #65535-64,r2
         aslb r2
         aslb r2
         adc r2

;*         txa
;*         and #$38
;*         lsr
;*         lsr
;*         lsr
;*         jsr fillrtsl
         mov r1,r3
         bic #65535-56,r3
         asr r3
         asr r3
         asr r3
         call @#fillrtsl

;*         asl
;*         php
;*         txa
;*         and #7
;*         jsr fillrtsr
         aslb r3
         mfps r5
         mov r1,r3
         bic #65535-7,r3
         call @#fillrtsr

;*         plp
;*         jsr fillrt2
         mtps r5
         call @#fillrt2

;*         inx
;*         bne l0
         incb r1
         movb r1,r1
         bne 1$

;*         rts       ;ZF=1 required for loadpat
         return


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
