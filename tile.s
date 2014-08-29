;clear    .block
;         jsr zerocc
;         #inibcd gencnt,6
;         #assign16 currp,startp
;loop     ldy #sum
;         lda (currp),y
;         beq lnext

;         lda #0
;         sta (currp),y
;         ldy #7
;loop0    sta (currp),y
;         dey
;         bpl loop0

;         ldy #pc
;loop1    sta (currp),y
;         iny
;         cpy #pc+8
;         bne loop1

;lnext    ldy #next
;         lda (currp),y
;         tax
;         iny
;         lda (currp),y
;         bne cont1

;         cpx #1
;         beq cont2

;cont1    sta currp+1
;         stx currp
;         jmp loop

;cont2    jsr showscn
;         jsr cleanup0
;         jmp infoout
;         .bend

fixcnt2:
         ;*lda tab20,x
         ;*adc (currp),y
         ;*sta (currp),y
         ;*lda tab21,x
         ;*iny
         ;*adc (currp),y
         ;*sta (currp),y
         movb tab20(r1),r3
         movb tab21(r1),r5
         swab r3
         add r5,r3
         add r3,(r4)+

         ;*lda tab22,x
         ;*iny
         ;*adc (currp),y
         ;*sta (currp),y 
         ;*lda tab23,x
         ;*iny
         ;*adc (currp),y
         ;*sta (currp),y
         movb tab22(r1),r3
         movb tab23(r1),r5
         swab r3
         add r5,r3
         add r3,@r4

         ;*rts
         rts pc

fixcnt1: 
         ;*lda tab13,x
         ;*adc (currp),y
         ;*sta (currp),y
         ;*lda tab12,x
         ;*dey
         ;*adc (currp),y
         ;*sta (currp),y
         movb tab13(r1),r3
         movb tab12(r1),r5
         swab r3
         add r5,r3
         add r3,@r4

         ;*lda tab11,x
         ;*dey
         ;*adc (currp),y
         ;*sta (currp),y
         ;*lda tab10,x
         ;*dey
         ;*adc (currp),y
         ;*sta (currp),y
         movb tab11(r1),r3
         movb tab10(r1),r5
         swab r3
         add r5,r3
         add r3,-(r4)

         ;*rts
         rts pc

;*chkaddt  lda t1
chkaddt: tst r3
         ;*beq exit2
         beq exit2

;*chkadd   ldy #next
         ;*lda (adjcell),y
         ;*iny
         ;*ora (adjcell),y
chkadd:  tst next(r2)

         ;*bne exit2
         bne exit2

;*addnode  .block
addnode:                  ;in: R2
         ;*dey
         ;*lda startp
         ;*sta (adjcell),y
         ;*iny
         ;*lda startp+1
         ;*sta (adjcell),y
         mov @#startp,next(r2)

         ;*#assign16 startp,adjcell
         mov r2,@#startp

         ;*inc tilecnt
         ;*bne exit2

         ;*inc tilecnt+1
         inc @#tilecnt

         ;*.bend

;*exit2    rts
exit2:   rts pc

;*chkadd2  ldy #next
         ;*lda (adjcell2),y
         ;*iny
         ;*ora (adjcell2),y
chkadd2: tst next(r5)

         ;*beq addnode2
         bne exit2

         ;*rts

;*addnode2 .block
addnode2:                 ;in: R5
         ;*dey
         ;*lda startp
         ;*sta (adjcell2),y
         ;*iny
         ;*lda startp+1
         ;*sta (adjcell2),y
         mov @#startp,next(r5)

         ;*#assign16 startp,adjcell2
         mov r5,@#startp

         ;*inc tilecnt
         ;*bne exit

         ;*inc tilecnt+1
         inc @#tilecnt

;*exit     rts
         rts pc

         ;*.bend

;inctiles .block
;         clc
;         lda i1
;         adc #tilesize
;         sta i1
;         bcc l1

;         inc i1+1
;l1       rts
;         .bend

;torus    .block
;         jsr totiles     ;top border
;         ldx #hormax
;l5       ldy #ul
;         lda i1
;         clc
;         adc #<(hormax*(vermax-1)-1)*tilesize
;         sta (i1),y
;         lda i1+1
;         adc #>(hormax*(vermax-1)-1)*tilesize
;         iny
;         sta (i1),y
;         lda i1
;         adc #<hormax*(vermax-1)*tilesize
;         iny		;up
;         sta (i1),y
;         lda i1+1
;         adc #>hormax*(vermax-1)*tilesize
;         iny
;         sta (i1),y
;         lda i1
;         adc #<(hormax*(vermax-1)+1)*tilesize
;         iny		;ur
;         sta (i1),y
;         lda i1+1
;         adc #>(hormax*(vermax-1)+1)*tilesize
;         iny
;         sta (i1),y
;         jsr inctiles
;         dex
;         bne l5

;         lda #<tiles+((vermax-1)*hormax*tilesize)  ;bottom border
;         sta i1
;         lda #>tiles+((vermax-1)*hormax*tilesize)
;         sta i1+1
;         ldx #hormax
;l4       ldy #dr
;         lda i1
;         sec
;         sbc #<((vermax-1)*hormax-1)*tilesize
;         sta (i1),y
;         lda i1+1
;         sbc #>((vermax-1)*hormax-1)*tilesize
;         iny
;         sta (i1),y       
;         lda i1
;         sbc #<(vermax-1)*hormax*tilesize
;         iny		;down
;         sta (i1),y
;         lda i1+1
;         sbc #>(vermax-1)*hormax*tilesize
;         iny
;         sta (i1),y    
;         lda i1
;         sbc #<((vermax-1)*hormax+1)*tilesize
;         iny		;dl
;         sta (i1),y
;         lda i1+1
;         sbc #>((vermax-1)*hormax+1)*tilesize
;         iny
;         sta (i1),y
;         jsr inctiles
;         dex
;         bne l4

;         jsr totiles    ;left border
;         ldx #vermax
;l3       ldy #left
;         lda i1
;         clc
;         adc #<(hormax-1)*tilesize
;         sta (i1),y
;         lda i1+1
;         adc #>(hormax-1)*tilesize
;         iny
;         sta (i1),y
;         lda i1
;         sec
;         sbc #<tilesize
;         iny		;ul
;         sta (i1),y
;         lda i1+1
;         sbc #>tilesize
;         iny
;         sta (i1),y
;         lda i1
;         clc
;         adc #<(2*hormax-1)*tilesize
;         ldy #dl
;         sta (i1),y
;         lda i1+1
;         adc #>(2*hormax-1)*tilesize
;         iny
;         sta (i1),y
;         lda i1
;         adc #<tilesize*hormax
;         sta i1
;         lda i1+1
;         adc #>tilesize*hormax
;         sta i1+1
;         dex
;         bne l3

;         lda #<tiles+((hormax-1)*tilesize)  ;right border
;         sta i1
;         lda #>tiles+((hormax-1)*tilesize)
;         sta i1+1
;         ldx #vermax
;l2       ldy #ur
;         lda i1
;         sec
;         sbc #<(2*hormax-1)*tilesize
;         sta (i1),y
;         lda i1+1
;         sbc #>(2*hormax-1)*tilesize
;         iny
;         sta (i1),y
;         lda i1
;         sec
;         sbc #<(hormax-1)*tilesize
;         iny		;right
;         sta (i1),y
;         lda i1+1
;         sbc #>(hormax-1)*tilesize
;         iny
;         sta (i1),y
;         lda i1
;         clc
;         adc #<tilesize
;         iny		;dr
;         sta (i1),y
;         lda i1+1
;         adc #>tilesize
;         iny
;         sta (i1),y
;         lda i1
;         adc #<tilesize*hormax
;         sta i1
;         lda i1+1
;         adc #>tilesize*hormax
;         sta i1+1
;         dex
;         bne l2

;         ldy #ul    ;top left corner
;         lda #<tiles + ((hormax*vermax-1)*tilesize)
;         sta tiles,y
;         lda #>tiles + ((hormax*vermax-1)*tilesize)
;         iny
;         sta tiles,y

;         ldy #ur    ;top right corner
;         lda #<tiles+(hormax*(vermax-1)*tilesize)
;         sta tiles+((hormax-1)*tilesize),y
;         lda #>tiles+(hormax*(vermax-1)*tilesize)
;         iny
;         sta tiles+((hormax-1)*tilesize),y

;         ldy #dl   ;bottom left corner
;         lda #<tiles+((hormax-1)*tilesize)
;         sta tiles+(hormax*(vermax-1)*tilesize),y
;         lda #>tiles+((hormax-1)*tilesize)
;         iny
;         sta tiles+(hormax*(vermax-1)*tilesize),y

;         ldy #dr   ;bottom right corner
;         lda #<tiles
;         sta tiles+((vermax*hormax-1)*tilesize),y
;         lda #>tiles
;         iny
;         sta tiles+((vermax*hormax-1)*tilesize),y
;         rts
;         .bend

;plain    .block
;         jsr totiles     ;top border
;         ldx #hormax
;l5       ldy #ul
;         lda #<plainbox
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         lda #<plainbox
;         iny		;up
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         lda #<plainbox
;         iny		;ur
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         jsr inctiles
;         dex
;         bne l5

;         lda #<tiles+((vermax-1)*hormax*tilesize)  ;bottom border
;         sta i1
;         lda #>tiles+((vermax-1)*hormax*tilesize)
;         sta i1+1
;         ldx #hormax
;l4       ldy #dr
;         lda #<plainbox
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         lda #<plainbox
;         iny		;down
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y    
;         lda #<plainbox
;         iny		;dl
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         jsr inctiles
;         dex
;         bne l4

;         jsr totiles    ;left border
;         ldx #vermax
;l3       ldy #left
;         lda #<plainbox
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         lda #<plainbox
;         iny		;ul
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         lda #<plainbox
;         ldy #dl
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         lda i1
;         adc #<tilesize*hormax
;         sta i1
;         lda i1+1
;         adc #>tilesize*hormax
;         sta i1+1
;         dex
;         bne l3

;         lda #<tiles+((hormax-1)*tilesize)  ;right border
;         sta i1
;         lda #>tiles+((hormax-1)*tilesize)
;         sta i1+1
;         ldx #vermax
;l2       ldy #ur
;         lda #<plainbox
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         lda #<plainbox
;         iny		;right
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         lda #<plainbox
;         iny		;dr
;         sta (i1),y
;         lda #>plainbox
;         iny
;         sta (i1),y
;         lda i1
;         adc #<tilesize*hormax
;         sta i1
;         lda i1+1
;         adc #>tilesize*hormax
;         sta i1+1
;         dex
;         bne l2

;         rts
;         .bend

;random   .block
;uses: adjcell:2, adjcell2:2, i1:2, i2, t1, t2, t3, x0
;         lda #0     ;dir: 0 - left, 1 - right
;         sta t1
;         lda #<tiles+((hormax*4+3)*tilesize)  ;start random area
;         sta adjcell
;         lda #>tiles+((hormax*4+3)*tilesize)
;         sta adjcell+1
;         lda #right
;         sta i1+1
;         lda #14    ;hor rnd max
;         sta i2
;         lda #16    ;ver rnd max
;         sta i1
;cont3    ldy #sum
;         sta (adjcell),y
;         lda #8
;         sta t3
;loop1    jsr rndbyte
;         dec t3
;         bne loop1

;         jsr chkadd
;         dec i2
;         beq cont2

;         ldy i1+1
;cont4    lda (adjcell),y
;         tax
;         iny
;         lda (adjcell),y
;         stx adjcell
;         sta adjcell+1
;         bne cont3

;cont2    dec i1
;         beq cont5

;         lda #14    ;hor rnd max
;         sta i2
;         lda t1
;         ldy #left
;         eor #1
;         sta t1
;         bne cont1

;         ldy #right
;cont1    sty i1+1
;         ldy #down
;         bne cont4

;cont5
;         .bend

;calccells
;         .block
;         lda tilecnt
;         bne cont2

;         lda tilecnt+1
;         bne cont2

;         rts
;cont2
;         jsr zerocc
;         #assign16 currp,startp
;loop2    ldy #sum
;         lda #0
;         sta (currp),y
;         ldy #0
;loop4    lda (currp),y
;         tax
;         lda tab3,x
;         pha
;         sty t1
;         ldy #sum
;         clc
;         adc (currp),y
;         sta (currp),y
;         pla
;         jsr inctsum
;         ldy t1
;         iny
;         cpy #8
;         bne loop4

;         ldy #next
;         lda (currp),y
;         tax
;         iny
;         lda (currp),y
;         bne cont1

;         cpx #1
;         bne cont1

;         jmp infoout

;cont1    sta currp+1
;         stx currp
;         jmp loop2
;         .bend

;inctsum  ;in: AC, CY
;         #cellsum
;         rts

;dectsum  .block
;         ldx #4
;loop     dec cellcnt,x
;         lda cellcnt,x
;         cmp #$2f
;         bne exit

;         lda #$39
;         sta cellcnt,x
;         dex
;         bpl loop

;exit     rts         ;ZF=0
;         .bend

;putpixel .block
;uses: adjcell:2, adjcell2:2, t1, t2, $fd
;x8pos    = adjcell2
;x8bit    = adjcell2+1
;y8pos    = t1
;y8byte   = $fd    ;connected to seti1
;         jsr xchgxy
;         ldx #8
;         lda crsrbit
;loop1    dex
;         lsr
;         bcc loop1

;         stx m1+1
;         lda crsrx
;         lsr
;         asl
;         asl
;         asl
;m1       adc #0
;         ldx xdir
;         beq cont4

;         sec
;         sbc x0
;         bcc exit
;         bcs cont2

;cont4    adc x0
;         bcs exit

;         cmp #160
;         bcs exit

;cont2    sta x8pos
;         lda crsry
;         asl
;         asl
;         asl
;         adc crsrbyte
;         ldx ydir
;         beq cont3

;         sec
;         sbc y0
;         bcc exit
;         bcs cont1

;cont3    adc y0
;         bcs exit

;         cmp #192
;         bcc cont1

;exit     rts

;cont1    sta y8pos
;         and #7
;         sta y8byte
;         lda y8pos
;         lsr
;         lsr
;         lsr
;         sec
;         sbc crsry
;         sta y8pos
;         lda x8pos
;         and #7
;         sta x8bit
;         lda crsrx
;         lsr
;         sta t2
;         lda x8pos
;         lsr
;         lsr
;         lsr
;         sec
;         sbc t2
;         sta x8pos
;         #assign16 adjcell,crsrtile
;         ;sei
;         sta $ff3f
;         lda y8pos
;loop2    bmi cup
;         bne cdown

;         lda x8pos
;loop3    bmi cleft
;         bne cright

;         lda #7
;         sec
;         sbc x8bit
;         tay
;         lda bittab,y
;         ldy ppmode
;         bne putpixel3
;         jmp putpixel2

;cright   ldy #right     ;y=0, x=/=0
;         jsr nextcell
;         dec x8pos
;         bpl loop3

;cdown    ldy #down      ;y=/=0
;         jsr nextcell
;         dec y8pos
;         bpl loop2

;cup      ldy #up       ;y=/=0
;         jsr nextcell
;         inc y8pos
;         jmp loop2

;cleft    ldy #left      ;y=0, x=/=0
;         jsr nextcell
;         inc x8pos
;         jmp loop3
;         .bend

;putpixel3 .block 
;y8byte   = $fd      ;connected to seti1, putpixel
;         ldy y8byte
;         ora (adjcell),y
;         sta (adjcell),y
;         jsr chkadd	;uses adjcell!
;         sta $ff3e
;         ;cli
;         rts
;         .bend

;nextcell lda (adjcell),y
;         tax
;         iny
;         lda (adjcell),y
;         sta adjcell+1
;         stx adjcell
;         rts    ;ZF=0

