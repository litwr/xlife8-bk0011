clear:    call @#zerocc
          call @#zerogc
          mov @#startp,r0
10$:      tstb sum(r0)
          beq 11$

          clrb sum(r0)
          clr @r0
          clr 2(r0)
          clr 4(r0)
          clr 6(r0)
11$:      mov next(r0),r0
          cmp r0,#1
          bne 10$

          call @#showscn
          call @#cleanup0
          jmp @#infoout

;*chkaddt  lda t1
chkaddt: tst r3
         ;*beq exit2
         beq exit2

;*chkadd   ldy #next
         ;*lda (adjcell),y
         ;*iny
         ;*ora (adjcell),y
chkadd:  tst next(r2)
         bne exit2

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
exit2:   return

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
         return

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

torus:
;         jsr totiles     ;top border
;         ldx #hormax
         mov #tiles,r0
         mov #hormax,r1

;l5       ldy #ul
;         lda i1
;         clc
;         adc #<(hormax*(vermax-1)-1)*tilesize
;         sta (i1),y
;         lda i1+1
;         adc #>(hormax*(vermax-1)-1)*tilesize
;         iny
;         sta (i1),y
5$:      mov r0,r2
         add #<hormax*<vermax-1>-1>*tilesize,r2
         mov r2,ul(r0)

;         lda i1
;         adc #<hormax*(vermax-1)*tilesize
;         iny		;up
;         sta (i1),y
;         lda i1+1
;         adc #>hormax*(vermax-1)*tilesize
;         iny
;         sta (i1),y
         mov r0,r2
         add #hormax*<vermax-1>*tilesize,r2
         mov r2,up(r0)

;         lda i1
;         adc #<(hormax*(vermax-1)+1)*tilesize
;         iny		;ur
;         sta (i1),y
;         lda i1+1
;         adc #>(hormax*(vermax-1)+1)*tilesize
;         iny
;         sta (i1),y
         mov r0,r2
         add #<hormax*<vermax-1>+1>*tilesize,r2
         mov r2,ur(r0)

;         jsr inctiles
;         dex
;         bne l5
         add #tilesize,r0
         sob r1,5$

;         lda #<tiles+((vermax-1)*hormax*tilesize)  ;bottom border
;         sta i1
;         lda #>tiles+((vermax-1)*hormax*tilesize)
;         sta i1+1
;         ldx #hormax
         mov #tiles+<<vermax-1>*hormax*tilesize>,r0
         mov #hormax,r1

;l4       ldy #dr
;         lda i1
;         sec
;         sbc #<((vermax-1)*hormax-1)*tilesize
;         sta (i1),y
;         lda i1+1
;         sbc #>((vermax-1)*hormax-1)*tilesize
;         iny
;         sta (i1),y
4$:      mov r0,r2
         sub #<<vermax-1>*hormax-1>*tilesize,r2
         mov r2,dr(r0)

;         lda i1
;         sbc #<(vermax-1)*hormax*tilesize
;         iny		;down
;         sta (i1),y
;         lda i1+1
;         sbc #>(vermax-1)*hormax*tilesize
;         iny
;         sta (i1),y
         mov r0,r2
         sub #<vermax-1>*hormax*tilesize,r2
         mov r2,down(r0)

;         lda i1
;         sbc #<((vermax-1)*hormax+1)*tilesize
;         iny		;dl
;         sta (i1),y
;         lda i1+1
;         sbc #>((vermax-1)*hormax+1)*tilesize
;         iny
;         sta (i1),y
         mov r0,r2
         sub #<<vermax-1>*hormax+1>*tilesize,r2
         mov r2,dl(r0)

;         jsr inctiles
;         dex
;         bne l4
         add #tilesize,r0
         sob r1,4$

;         jsr totiles    ;left border
;         ldx #vermax
         mov #tiles,r0
         mov #vermax,r1

;l3       ldy #left
;         lda i1
;         clc
;         adc #<(hormax-1)*tilesize
;         sta (i1),y
;         lda i1+1
;         adc #>(hormax-1)*tilesize
;         iny
;         sta (i1),y
3$:      mov r0,r2
         add #<hormax-1>*tilesize,r2
         mov r2,left(r0)

;         lda i1
;         sec
;         sbc #<tilesize
;         iny		;ul
;         sta (i1),y
;         lda i1+1
;         sbc #>tilesize
;         iny
;         sta (i1),y
         mov r0,r2
         sub #tilesize,r2
         mov r2,ul(r0)

;         lda i1
;         clc
;         adc #<(2*hormax-1)*tilesize
;         ldy #dl
;         sta (i1),y
;         lda i1+1
;         adc #>(2*hormax-1)*tilesize
;         iny
;         sta (i1),y
         mov r0,r2
         add #<2*hormax-1>*tilesize,r2
         mov r2,dl(r0)

;         lda i1
;         adc #<tilesize*hormax
;         sta i1
;         lda i1+1
;         adc #>tilesize*hormax
;         sta i1+1
;         dex
;         bne l3
         add #hormax*tilesize,r0
         sob r1,3$

;         lda #<tiles+((hormax-1)*tilesize)  ;right border
;         sta i1
;         lda #>tiles+((hormax-1)*tilesize)
;         sta i1+1
;         ldx #vermax
         mov #tiles+<<hormax-1>*tilesize>,r0
         mov #vermax,r1

;l2       ldy #ur
;         lda i1
;         sec
;         sbc #<(2*hormax-1)*tilesize
;         sta (i1),y
;         lda i1+1
;         sbc #>(2*hormax-1)*tilesize
;         iny
;         sta (i1),y
2$:      mov r0,r2
         sub #<2*hormax-1>*tilesize,r2
         mov r2,ur(r0)

;         lda i1
;         sec
;         sbc #<(hormax-1)*tilesize
;         iny		;right
;         sta (i1),y
;         lda i1+1
;         sbc #>(hormax-1)*tilesize
;         iny
;         sta (i1),y
         mov r0,r2
         sub #<hormax-1>*tilesize,r2
         mov r2,right(r0)

;         lda i1
;         clc
;         adc #<tilesize
;         iny		;dr
;         sta (i1),y
;         lda i1+1
;         adc #>tilesize
;         iny
;         sta (i1),y
         mov r0,r2
         add #tilesize,r2
         mov r2,dr(r0)

;         lda i1
;         adc #<tilesize*hormax
;         sta i1
;         lda i1+1
;         adc #>tilesize*hormax
;         sta i1+1
         add #hormax*tilesize,r0

;         dex
;         bne l2
         sob r1,2$

;         ldy #ul    ;top left corner
;         lda #<tiles + ((hormax*vermax-1)*tilesize)
;         sta tiles,y
;         lda #>tiles + ((hormax*vermax-1)*tilesize)
;         iny
;         sta tiles,y
         mov #tiles + <<hormax*vermax-1>*tilesize>,@#tiles+ul

;         ldy #ur    ;top right corner
;         lda #<tiles+(hormax*(vermax-1)*tilesize)
;         sta tiles+((hormax-1)*tilesize),y
;         lda #>tiles+(hormax*(vermax-1)*tilesize)
;         iny
;         sta tiles+((hormax-1)*tilesize),y
         mov #tiles + <<hormax*<vermax-1>>*tilesize>,@#tiles+ur+<<hormax-1>*tilesize>

;         ldy #dl   ;bottom left corner
;         lda #<tiles+((hormax-1)*tilesize)
;         sta tiles+(hormax*(vermax-1)*tilesize),y
;         lda #>tiles+((hormax-1)*tilesize)
;         iny
;         sta tiles+(hormax*(vermax-1)*tilesize),y
         mov #tiles+<<hormax-1>*tilesize>,@#tiles+dl+<hormax*<vermax-1>*tilesize>

;         ldy #dr   ;bottom right corner
;         lda #<tiles
;         sta tiles+((vermax*hormax-1)*tilesize),y
;         lda #>tiles
;         iny
;         sta tiles+((vermax*hormax-1)*tilesize),y
         mov #tiles,@#tiles+dr+<<vermax*hormax-1>*tilesize>

;         rts
         return

plain:
;         jsr totiles     ;top border
;         ldx #hormax
         mov #tiles,r0
         mov #hormax,r1
         mov #plainbox,r2

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
5$:      mov r2,ul(r0)
         mov r2,up(r0)
         mov r2,ur(r0)
         add #tilesize,r0
         sob r1,5$
         
;         lda #<tiles+((vermax-1)*hormax*tilesize)  ;bottom border
;         sta i1
;         lda #>tiles+((vermax-1)*hormax*tilesize)
;         sta i1+1
;         ldx #hormax
         mov #tiles+<<vermax-1>*hormax*tilesize>,r0
         mov #hormax,r1

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
4$:      mov r2,dr(r0)
         mov r2,down(r0)
         mov r2,dl(r0)
         add #tilesize,r0
         sob r1,4$

;         jsr totiles    ;left border
;         ldx #vermax
         mov #tiles,r0
         mov #vermax,r1

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
3$:      mov r2,left(r0)
         mov r2,ul(r0)
         mov r2,dl(r0)
         add #tilesize*hormax,r0
         sob r1,3$

;         lda #<tiles+((hormax-1)*tilesize)  ;right border
;         sta i1
;         lda #>tiles+((hormax-1)*tilesize)
;         sta i1+1
;         ldx #vermax
         mov #tiles+<<hormax-1>*tilesize>,r0
         mov #vermax,r1

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
2$:      mov r2,ur(r0)
         mov r2,right(r0)
         mov r2,dr(r0)
         add #tilesize*hormax,r0
         sob r1,2$

;         rts
         return

random:
;uses: adjcell:2 - r2, i1:2 - r3/r5, i2 - r4, t1 - r1
         clr r1   ;dir: 0 - left, 1 - right
         mov #tiles+<<hormax*4+3>*tilesize>,r2
         mov #16,r3    ;ver rnd max
         mov #right,r5
         mov #14,r4    ;hor rnd max

;cont3    ldy #sum
;         sta (adjcell),y
;         lda #8
;         sta t3
23$:     mov #1,sum(r2)
         mov #8,r0

;loop1    jsr rndbyte
;         dec t3
;         bne loop1
1$:      call @#rndbyte
         sob r0,1$
         sub #8,r2

;         jsr chkadd
;         dec i2
;         beq cont2
        call @#chkadd
        dec r4
        beq 22$

;         ldy i1+1
;cont4    lda (adjcell),y
;         tax
;         iny
;         lda (adjcell),y
;         stx adjcell
;         sta adjcell+1
;         bne cont3
         add r5,r2
24$:     mov @r2,r2
         br 23$

;cont2    dec i1
;         beq cont5
22$:     dec r3
         beq calccells

         mov #14,r4   ;hor rnd max
         mov #left,r5
         mov #1,r0
         xor r0,r1
         bne 21$

;         ldy #right
;cont1    sty i1+1
;         ldy #down
;         bne cont4
         mov #right,r5
21$:     add #down,r2
         br 24$

calccells:
         call @#zerocc
         tst @#tilecnt
         bne 12$
         return

12$:     mov @#startp,r0
2$:      mov #8,r5
         clr r4
4$:      clr r1
         bisb (r0)+,r1
         beq 5$

         movb tab3(r1),r2
         inc r4
         call @#inctsum
5$:      sob r5,4$
         movb r4,sum-8(r0)
         mov next-8(r0),r0
         cmp #1,r0
         bne 2$
         jmp @#infoout

inctsum:            ;in: r2
         cellsum 1$
1$:      return

putpixel:     ;IN: x0,y0; USE: R1, R2, R3, R4; DON'T USE: R0,R5
;x8pos    = adjcell2 = R1 low
;y8pos    = t1  = R3 low
;         jsr xchgxy
         call @#xchgxy
         mov @#x0,r4
         call @#calcx

;         stx m1+1
;         lda crsrx
;         lsr
;         asl
;         asl
;         asl
;m1       adc #0
;         ldx xdir
;         beq cont4
         movb r4,r2
         bisb @#crsrx,r1
         tstb @#xdir
         beq 4$

;         sec
;         sbc x0
;         bcc exit
;         bcs cont2
         cmpb r1,r2
         bcs 100$

         sub r2,r1
         br 2$

;cont4    adc x0
;         bcs exit
4$:      add r2,r1
         cmpb r1,r2
         bcs 100$

;         cmp #160
;         bcs exit
         cmpb r1,#160
         bcc 100$

;cont2    sta x8pos
;         lda crsry
;         asl
;         asl
;         asl
;         adc crsrbyte
;         ldx ydir
;         beq cont3
2$:      movb @#crsry,r3
         add @#crsrbyte,r3
         mov r4,r2
         swab r2
         tstb @#ydir
         beq 3$

;         sec
;         sbc y0
;         bcc exit
;         bcs cont1
         cmpb r3,r2
         bcs 100$

         sub r2,r3
         br 1$

;cont3    adc y0
;         bcs exit

;         cmp #192
;         bcc cont1
3$:      add r2,r3
         cmpb r3,r2
         bcs 100$

         cmpb r3,#192
         bcs 1$

;exit     rts
100$:    return

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
1$:      mov #65280,r2
         movb @#crsry,r4
         bic r2,r3
         bic r2,r4
         sub r4,r3

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
         movb @#crsrx,r4
         bic r2,r1
         bic r2,r4
         sub r4,r1

;         #assign16 adjcell,crsrtile
         mov @#crsrtile,r2     ;r2 for chkadd

;         sta $ff3f
;         lda y8pos
;loop2    bmi cup
;         bne cdown
22$:     bit #65528,r3
         bmi 12$
         bne 11$

;         lda x8pos
;loop3    bmi cleft
;         bne cright
23$:     bit #65528,r1
         bmi 13$
         bne 10$

;         lda #7
;         sec
;         sbc x8bit
;         tay
;         lda bittab,y
;         ldy ppmode
;         bne putpixel3
;         jmp putpixel2
         mov #7,r4
         sub r1,r4
         ;bic #65528,r4
         movb bittab(r4),r4
         ;bic #65528,r3
         tstb @#ppmode
         bne putpixel3
         jmp @#putpixel2

;cright   ldy #right     ;y=0, x=/=0
;         jsr nextcell
;         dec x8pos
;         bpl loop3
10$:     mov right(r2),r2
         sub #8,r1
         br 23$

;cdown    ldy #down      ;y=/=0
;         jsr nextcell
;         dec y8pos
;         bpl loop2
11$:     mov down(r2),r2
         sub #8,r3
         br 22$

;cup      ldy #up       ;y=/=0
;         jsr nextcell
;         inc y8pos
;         jmp loop2
12$:     mov up(r2),r2
         add #8,r3
         br 22$

;cleft    ldy #left      ;y=0, x=/=0
;         jsr nextcell
;         inc x8pos
;         jmp loop3
13$:     mov left(r2),r2
         add #8,r1
         br 23$

putpixel3:       ;IN: r2,r3,r4
;         ldy y8byte
;         ora (adjcell),y
;         sta (adjcell),y
         add r2,r3
         bisb r4,@r3
 
;         jsr chkadd	;uses adjcell!
;         sta $ff3e
;         rts
         jmp @#chkadd

