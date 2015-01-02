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

;boxsz    .block
;xmin     = i1
;ymin     = i1+1
;xmax     = adjcell
;ymax     = adjcell+1
;curx     = adjcell2
;cury     = adjcell2+1
;         lda #192
;         sta ymin
;         lda #160
;         sta xmin
;         lda #0
;         sta xmax
;         sta ymax
;         sta curx
;         sta cury
;         lda #<tiles ;=0
;         sta currp
;         lda #>tiles
;         sta currp+1
;loop0    lda #0
;         ldy #7
;loop1    ora (currp),y
;         dey
;         bpl loop1

;         ora #0
;         beq cont7

;         pha
;loop2    asl
;         iny
;         bcc loop2

;         sty t1
;         lda curx
;         asl
;         asl
;         asl
;         tax
;         adc t1
;         cmp xmin
;         bcs cont2

;         sta xmin
;cont2    pla
;         ldy #8
;loop3    lsr
;         dey
;         bcc loop3

;         sty t1
;         txa
;         clc
;         adc t1
;         cmp xmax
;         bcc cont3

;         sta xmax
;cont3    ldy #0
;loop4    lda (currp),y
;         bne cont4

;         iny
;         bpl loop4

;cont4    sty t1
;         lda cury
;         asl
;         asl
;         asl
;         tax
;         adc t1
;         cmp ymin
;         bcs cont5

;         sta ymin
;cont5    ldy #7
;loop5    lda (currp),y
;         bne cont6

;         dey
;         bpl loop5

;cont6    sty t1
;         txa
;         clc
;         adc t1
;         cmp ymax
;         bcc cont7

;         sta ymax
;cont7    jsr inccurrp
;         ldx curx
;         inx
;         cpx #20
;         beq cont8

;         stx curx
;         bne loop0

;cont8    ldx #0
;         stx curx
;         ldy cury
;         iny
;         cpy #24
;         beq cont1

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
;         .bend

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
