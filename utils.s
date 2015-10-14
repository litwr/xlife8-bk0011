;calcspd
;zerocnt
;zerocc
;todec
;incben
;mul5

zerocc:   inibcd cellcnt,4
          return

zerogc:   inibcd gencnt,6
          return

mul5:     mov r1,r0  ;r2:r1*5
          mov r2,r5
          asl r1
          rol r2
          asl r1
          rol r2
          add r0,r1
          adc r2
          add r5,r2
          return

incben:   movb -(r1),r5
          inc r5
          cmp #'0+10,r5
          bne 1$

          movb #'0,@r1
          br incben

1$:       movb r5,@r1
          return

todec:    mov r3,-(sp)  ;r4:r3/10 in decimal
          mov r4,-(sp)
          mov #stringbuf,r1
          mov #10,r2
1$:       movb #'0,(r1)+
          sob r2,1$

          mov #10000,r0
          sub #4,r1
          mov r1,r2
5$:       sub r0,r3
          sbc r4
          bcs 6$

          call @#incben
          mov r2,r1
          br 5$

6$:       add r0,r3
          adc r4
          mov #10,r0
          add #3,r1

          mov r1,r2
2$:       sub r0,r3
          bcs 3$

          call @#incben
          mov r2,r1
          br 2$

3$:       add r0,r3
          add #'0,r3
          movb r3,@r1
4$:       mov (sp)+,r4
          mov (sp)+,r3
          return

boxsz:   mov #192,@#boxsz_ymin
         mov #160,@#boxsz_xmin
         clr r3                ;boxsz_ymax
         clr r5                ;boxsz_xmax
         clr @#boxsz_curx
         clr @#boxsz_cury
         mov #tiles,r4
         clr @#lowbench         ;binary cell count
0$:      push r5
         mov #8,r5
         clr r2
9$:      clr r0
         bisb (r4)+,r0
         movb tab3(r0),r1
         add r1,@#lowbench
         bis r0,r2
         sob r5,9$
         pop r5
         sub #8,r4
         tst r2
         beq 17$

         push r2
         clr r1
         dec r1
2$:      inc r1
         aslb r2
         bcc 2$

;         sty t1
;         lda curx
         mov @#boxsz_curx,r2

;         asl
;         asl
;         asl
         asl r2
         asl r2
         asl r2

;         tax
;         adc t1
         mov r2,r0
         add r2,r1

;         cmp xmin
;         bcs cont2
         cmp r1,@#boxsz_xmin
         bcc 12$

;         sta xmin
         mov r1,@#boxsz_xmin

;cont2    pla
;         ldy #8
;loop3    lsr
;         dey
;         bcc loop3
12$:     pop r2
         mov #8,r1
3$:      dec r1
         asr r2
         bcc 3$

;         sty t1
;         txa
;         clc
;         adc t1
         add r0,r1

;         cmp xmax
;         bcc cont3
        cmp r1,r5
        bcs 13$

;         sta xmax
        mov r1,r5

;cont3    ldy #0
;loop4    lda (currp),y
;         bne cont4

;         iny
;         bpl loop4
13$:     mov r4,r1
4$:      tstb (r1)+
         beq 4$

         sub r4,r1
         dec r1

;cont4    sty t1
;         lda cury
;         asl
;         asl
;         asl
;         tax
;         adc t1
;         cmp ymin
;         bcs cont5
         mov @#boxsz_cury,r2
         asl r2
         asl r2
         asl r2
         mov r2,r0
         add r1,r2
         cmp r2,@#boxsz_ymin
         bcc 15$

;         sta ymin
         mov r2,@#boxsz_ymin

;cont5    ldy #7
;loop5    lda (currp),y
;         bne cont6

;         dey
;         bpl loop5
15$:     mov r4,r1
         add #8,r1
5$:      tstb -(r1)
         beq 5$

         sub r4,r1
         add r0,r1
         cmp r1,r3
         bcs 17$

         mov r1,r3
17$:     add #tilesize,r4
         inc @#boxsz_curx
         cmp #hormax,@#boxsz_curx
         bne 0$

         clr @#boxsz_curx
         inc @#boxsz_cury
         cmp #vermax,@#boxsz_cury
         bne 0$

;         sty cury
;         jmp loop0

;cont1    lda ymax
;         sbc ymin
;         adc #0
;         sta cury
;         sec
;         lda xmax
;         sbc xmin
;         adc #0
;         sta curx
;         lda xmax
;         ora ymax
;         ora tiles
;         rts
         mov r3,r0
         sub @#boxsz_ymin,r0
         inc r0
         mov r0,@#boxsz_cury
         mov r5,r4
         sub @#boxsz_xmin,r4
         inc r4       ;returns xsize
         mov r4,@#boxsz_curx
         mov @#tiles,r1
         bis r3,r1
         return

rndbyte: push r0   ;IN: R2
         push r1
         push r4
         push r5
         clr r5
         movb @#density,r4
2$:      clr r1
         mov @#timerport2,r0
         xor r0,@#temp
         ror r0    ;uses CY=0 set by clr
         rol r1
         asr r0
         rol r1
         movb 32768(r0),r0
         add @#temp,r0
         asr r0
         rol r1
         bisb bittab(r1),r5
         sob r4,2$

         bisb r5,(r2)+
         pop r5
         pop r4
         pop r1
         pop r0
         return
