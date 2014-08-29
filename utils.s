;calcspd
;zerocnt
;zerocc

;*zerocc   #inibcd cellcnt,4
;*         rts
zerocc:   inibcd cellcnt,4
          rts pc

;calcspd .block
;        lda #<eval1
;        sta $3b
;        lda #>eval1
;        sta $3c
;        jsr EVALEXPR	;eval expression
;        ldy #0
;loop1   lda irqcnt,y
;        cmp #$30
;        bne cont1

;        iny
;        bne loop1

;cont1   ldx #0
;loop2   lda irqcnt,y
;        sta $c06,x
;        inx
;        iny
;        cpy #9
;        bne loop2

;        lda #"S"-"A"+$81
;        sta $c06,x
;        ldy #0
;loop3   lda $100,y
;        beq exit

;        sta $c2f,y
;        iny
;        bne loop3

;exit    lda $37
;        sta $33
;        lda $38
;        sta $34
;        lda #$19
;        sta $16
;        jmp getkey
;        .bend

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

;rndbyte  .block
;         lda #8
;         sec
;         sbc t3
;         sta t2
;         lda density
;         sta adjcell2
;loop1    lda $ff1e
;         lsr
;         lsr
;         sta x0
;         lda $ff02
;         asl
;         asl
;         eor adjcell2+1
;         eor x0
;         sta adjcell2+1
;         lsr adjcell2+1
;         and #7
;         tax
;         lda bittab,x
;         sta x0

;         ldy t2
;         ora (adjcell),y
;         tax
;         sta (adjcell),y
;         lda tab3,x
;         ldy #sum
;         adc (adjcell),y
;         sta (adjcell),y
;         dec adjcell2
;         bne loop1

;         rts
;         .bend

