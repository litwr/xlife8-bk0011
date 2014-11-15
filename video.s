printstr:  mov #toandos,@#pageport
1$:        movb (r3)+,r0
           beq 2$

           cmp #9,r0
           bne 3$

           mov #spaces10,r1
           mov #10,r2
           emt #^O20
           br 1$

3$:        emt #^O16
           br 1$

2$:        inc r3
           bic #1,r3
           mov #todata,@#pageport
           rts r3

spaces10:  .ascii "          "

;printhex .macro
;         and #$7f       ;print hex number in AC
;         pha
;         lsr
;         lsr
;         lsr
;         lsr
;         eor #$30
;         jsr BSOUT
;         pla
;         and #$f
;         eor #$30
;         cmp #"9"+1
;         bcc l1
;
;         adc #6     ;CY=1
;l1       jsr BSOUT
;         .endm

;totext   sta $ff3e
;totext0  lda #$88
;         jsr set_ntsc
;         lda #8
;         sta $ff14
;         lda #$1b
;         sta $ff06
;         lda #$c4
;         sta $ff12
;         lda #$71
;         sta $ff15
;         jmp savebl

;tograph  lda zoom
;         beq tographx
;
;         jsr restbl
;         lda livcellc
;         ldy #0
;s1loop   sta $800,y
;         sta $900,y
;         sta $a00,y
;         sta $ac0,y
;         iny
;         bne s1loop
;
;         sei
;         sta $ff3f
;         lda #<irq210x
;         sta $fffe
;         cli
;         bne totext0
;
;tographx jsr tograph0
;         jmp restbl
;
;showbench
;         .block
;         jsr JPRIMM
;         .byte 147
;         .text "time:"
;         .byte $d
;         .null "speed:"
;         rts
;         .bend
;
;scrbench = $c17
;insteps  .block
;         jsr JPRIMM
;         .byte 144,147
;         .null "number of generations: "
;loop3    ldy #0
;         sty $ff0c
;loop1    tya
;         clc
;         adc #<scrbench
;         sta $ff0d
;         jsr getkey
;         cmp #$d
;         beq cont1
;
;         cmp #$14
;         beq cont2
;
;         cmp #$1b
;         beq exit
;
;         cmp #$30
;         bcc loop1
;
;         cmp #$3a
;         bcs loop1
;
;         cpy #7
;         beq loop1
;
;         sta scrbench,y  ;temp area
;         iny
;         bne loop1
;
;cont1    jsr curoff
;         tya
;         bne cont3
;
;exit     rts        ;return yr=len, zf=1
;
;cont3    ldx #6
;         sty temp
;         dey
;loop2    lda scrbench,y
;         sta bencnt,x
;         dex
;         dey
;         bpl loop2
;
;         ldy temp
;         rts      ;no zf!
;
;cont2    dey
;         bmi loop3
;
;         lda #$20     ;space
;         sta scrbench,y
;         bne loop1
;         .bend
;
;scrborn = $d1f
;inborn  .block
;         jsr JPRIMM
;         .byte 147,30
;         .text "the rules are defined by "
;         .byte 31
;         .text "born"
;         .byte 30
;         .text " and "
;         .byte 31
;         .text "stay"
;         .byte 30
;         .text " values.  for example, "
;         .byte $9c
;         .text "conways's life"
;         .byte 30
;         .text " has born=3 and stay=23, "
;         .byte $9c
;         .text "seeds"
;         .byte 30
;         .text " - born=2 and empty stay, "
;         .byte $9c
;         .text "highlife"
;         .byte 30
;         .text " - born=36 and stay=23, "
;         .byte $9c
;         .text "life without death"
;         .byte 30
;         .text " - born=3 and stay=012345678, ..."
;         .byte 144,$d,$d
;         .null "born = "
;loop3    ldy #1
;         sty $ff0c
;         dey
;loop1    tya
;         clc
;         adc #<scrborn
;         sta $ff0d
;         jsr getkey
;         cmp #$d
;         beq cont1
;
;         cmp #$14   ;backspace
;         beq cont2
;
;         cmp #27    ;esc
;         beq cont1
;
;         cmp #$31   ;1
;         bcc loop1
;
;         cmp #$39   ;9
;         bcs loop1
;
;         ldx #0
;loop4    cmp scrborn,x
;         beq loop1
;
;         stx t1
;         inx
;         cpy t1
;         bne loop4
;
;         sta scrborn,y  ;temp area
;         iny
;         bne loop1
;
;cont1    tax
;         jmp curoff   ;return yr=len
;
;cont2    dey
;         bmi loop3
;
;         lda #$20     ;space
;         sta scrborn,y
;         bne loop1
;         .bend
;
;scrstay = $d47
;instay  .block
;         jsr JPRIMM
;         .byte $d
;         .null "stay = "
;loop3    ldy #1
;         sty $ff0c
;         dey
;loop1    tya
;         clc
;         adc #<scrstay
;         sta $ff0d
;         jsr getkey
;         cmp #$d
;         beq cont1
;
;         cmp #$14   ;backspace
;         beq cont2
;
;         cmp #$30   ;0
;         bcc loop1
;
;         cmp #$39   ;9
;         bcs loop1
;
;         ldx #0
;loop4    cmp scrstay,x
;         beq loop1
;
;         stx t1
;         inx
;         cpy t1
;         bne loop4
;
;         sta scrstay,y  ;temp area
;         iny
;         bne loop1
;
;cont1    jmp curoff   ;return yr=len
;
;cont2    dey
;         bmi loop3
;
;         lda #$20     ;space
;         sta scrstay,y
;         bne loop1
;         .bend
;
;indens   .block
;         jsr JPRIMM
;         .byte 144,147
;         .text "select density or press "
;         .byte 28
;         .text "esc"
;         .byte 144
;         .text " to exit"
;         .byte $d,28,"0",30
;         .text " - 12.5%"
;         .byte $d,28,"1",30
;         .text " - 28%"
;         .byte $d,28,"2",30
;         .text " - 42%"
;         .byte $d,28,"3",30
;         .text " - 54%"
;         .byte $d,28,"4",30
;         .text " - 64%"
;         .byte $d,28,"5",30
;         .text " - 73%"
;         .byte $d,28,"6",30
;         .text " - 81%"
;         .byte $d,28,"7",30
;         .text " - 88.5%"
;         .byte $d,28,"8",30
;         .text " - 95%"
;         .byte $d,28,"9",30
;         .text " - 100%"
;         .byte 144,0
;loop1    jsr getkey
;         cmp #$1b
;         beq exit
;
;         cmp #$30
;         bcc loop1
;
;         cmp #$40
;         bcs loop1
;
;         eor #$30
;         adc #1
;         sta density
;exit     rts
;         .bend

help:    mov @#yscroll,@#yshift    
         ;jsr r3,@#printstr
         ;.byte 155,0
         call @#clrscn
         jsr r3,@#printstr
         .ascii "    "
         .byte 146,159
         .ascii "*** XLIFE COMMANDS ***"
         .byte 159,155,10,9,156,'!,156
         .ascii " randomize screen"
         .byte 10,9,137,156,'%,156
         .ascii " set random density - default=42%"
         .byte 10,9,156,'+,156,'/,156,'-,156
         .ascii " zoom in/out"
         .byte 10,9,156,'.,156,'/,156,'H,156
         .ascii " center/home cursor"
         .byte 10,9,156,'?,156
         .ascii " show this help"
         .byte 10,9,156,'B,156
         .ascii " benchmark"
         .byte 10,9,156,'C,156
         .ascii " clear screen"
         .byte 10,9,156,'E,156
         .ascii " toggle pseudocolor mode"
         .byte 10,9,156,'g,156
         .ascii " toggle run/stop mode"
         .byte 10,9,156,'h,156
         .ascii " toggle hide mode - about 20% faster"
         .byte 10,9,156,'l,156
         .ascii " load and transform file"
         .byte 10,9,156,'L,156
         .ascii " reload pattern"
         .byte 10,9,156,'o,156
         .ascii " one step"
         .byte 10,9,156,'Q,156
         .ascii " quit"
         .byte 10,9,156,'R,156
         .ascii " set the rules"
         .byte 10,9,156,"S",156
         .ascii " save"
         .byte 10,9,156,"t",156
         .ascii " toggle plain/torus topology"
         .byte 10,9,156,"v",156
         .ascii " show some info"
         .byte 10,9,156,"V",156
         .ascii " show comments to the pattern"
         .byte 10,9,156,"X",156,"/",156,"Z",156
         .ascii " reload/set&save palette"
         .byte 10,10,159
         .ascii "Use "
         .byte 159,156
         .ascii "cursor keys "
         .byte 156,159
         .ascii "to set the position and "
         .byte 159,156
         .ascii "space key"
         .byte 156,159
         .ascii " to toggle the current cell. "
         .ascii "Use "
         .byte 159,156
         .ascii "shift"
         .byte 156,159
         .ascii " to speed up the movement"
         .byte 159,0 ;word align
         mov @#yshift,@#yscroll
         add #14,@#yshift
         call @#getkey
         jsr r3,@#printstr
         .byte 12,155,0,0
         mov #^O1330,@#yshift
         jmp @#clrscn

;setcolor .block
;         ldy bordertc
;         lda topology
;         beq cont
;
;         ldy borderpc
;cont     sty $ff19
;         lda livcellc
;         tax
;         asl
;         asl
;         asl
;         asl
;         sta t1
;         lda newcellc
;         pha
;         and #$f
;         ora t1
;         sta i1        ;colors
;         pla
;         asl
;         asl
;         asl
;         asl
;         sta t1
;         txa
;         lsr
;         lsr
;         lsr
;         lsr
;         ora t1
;         sta i2       ;lums
;
;         ldy #0
;loop     lda i1
;         sta $1c00,y
;         sta $1d00,y
;         sta $1e00,y
;         sta $1ec0,y
;         lda i2
;         sta $1800,y
;         sta $1900,y
;         sta $1a00,y
;         sta $1ac0,y
;         iny
;         bne loop
;         rts        ;ZF=1
;         .bend

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

xyout:   mov #tovideo,@#pageport
         mov #xcrsr,r0
         mov #3,r1
         mov #<statusline*64+16384+50>,r2
         call @#digiout

         mov #ycrsr,r0
         mov #3,r1
         mov #<statusline*64+16384+58>,r2
         call @#digiout
         mov #todata,@#pageport
         return

infoout: mov #tovideo,@#pageport    ;must be before showtinfo
         mov #gencnt,r0
         mov #7,r1
         mov #<statusline*64+16384+2>,r2
         call @#digiout

         mov #cellcnt,r0
         mov #5,r1
         mov #<statusline*64+16384+18>,r2
         call @#digiout

;showtinfo  proc          ;must be after infoout
;           local cont1,cont2
;           ld hl,(tilecnt)
;           srl h
;           rr l
;           srl h
;           rr l
;           ld a,l
;           cp 120
;           jr nz,cont1
showtinfo:  mov #tinfo,r0
            mov @#tilecnt,r3
            asr r3
            asr r3
            cmp r3,#120
            bne 1$

;           ld a,1
;           ld (tinfo),a
;           ld hl,0
;           ld (tinfo+1),hl
;           jp cont2
            mov #1,@r0
            clrb 2(r0)
            br 2$

;cont1      ld hl,$0a0a
;           ld (tinfo),hl
;           ld h,high(ttab)
;           add a,low(ttab)
;           ld l,a
;           ld a,(hl)
;           and $f
;           ld (tinfo+2),a
;           ld a,(hl)
;           and $f0
;           rrca
;           rrca
;           rrca
;           rrca
;           jr z,cont2
1$:         mov #2570,@r0
            movb ttab(r3),r1
            mov r1,r2
            bic #^B11110000,r1
            movb r1,2(r0)
            asr r2
            asr r2
            asr r2
            asr r2
            beq 2$
            
;           ld (tinfo+1),a
            movb r2,1(r0)

;cont2      ld b,3
;           ld hl,tinfo
;           ld de,$c79e
;           jp digiout
;           endp
2$:         mov #3,r1
            mov #<statusline*64+16384+30>,r2
            call @#digiout
            mov #todata,@#pageport
            return

calcx:       ;$80 -> 0, $40 -> 1, ...
;         ldx #$ff
;cl2      inx
;         asl
;         bcc cl2
;
;         txa
;         rts
         bic #^B1111111100000000,r1
         add #65280,r1    ;$ff00, IN: R1, OUT: R1
1$:      add #256,r1
         aslb r1
         bcc 1$

         swab r1
         movb r1,r1
         return

crsrpg:
         clrb @#i1
         push r0
         mov #85,r0
         xor r0,63(r1)
         xor r0,127(r1)
         xor r0,191(r1)
         xor r0,255(r1)
         xor r0,319(r1)
         xor r0,-1(r1)
         movb r0,383(r1)
         movb r0,-65(r1)
         pop r0
         return

showscnzp:
;loop3    ld iyl,5
3$:      add #5*256,r2   ;IY -> R2

;loop4    ld a,(crsrtile)
;         cp ixl
;         jp nz,cont4
4$:      clr @#200$+2
         movb #8,@#temp+1

         cmp r0,@#crsrtile
         bne 2$

         incb @#i1
2$:      mov @#200$+2,r4
         asl r4
         asl r4
         add #count0,r4
         add r0,r4
         mov (r4)+,r5
         bic #^B1110011100111111,r5
         mov r5,r3
         swab r3
         aslb r3
         bis r3,r5
         mov @r4,r3
         bic #^B1111110011100111,r3
         mov r3,r4
         asrb r3
         swab r4
         bis r5,r4
         movb r3,r3
         bisb r4,r3
         swab r3
200$:    movb 8(r0),r4
         bisb r4,r3
         inc @#200$+2
         mov #8,r5     ;B -> R5 low
         mov #tovideo,@#pageport

1$:      tstb r3
         bpl 11$

         mov #84,r4
         tst r3         ;pseudocolor  
         bmi 112$
         
         mov #68,r4
112$:    movb r4,64(r1)   ;new cell char
         movb r4,128(r1)  
         movb r4,192(r1)
         movb r4,256(r1)
         movb #16,320(r1)
         movb #16,(r1)+
16$:     asl  r3
         tstb @#i1
         beq 15$

         cmpb @#temp+1,@#i1+1
         bne 15$

         cmpb @#temp,r5
         bne 15$

         call @#crsrpg
15$:     sob r5,1$

         mov #todata,@#pageport
         add #8*64-8,r1
         decb @#temp+1
         bne 2$

         sub #64*64-8,r1
         add #tilesize,r0
         sub #256,r2
         bpl 4$

         decb r2
         bne 30$

         return

30$:     add #tilesize*15,r0
         add #64*64-40,r1
         br 3$

11$:     tstb (r1)+     ;is it an empty cell?
         beq 16$

         clrb 63(r1)
         clrb 127(r1)
         clrb 191(r1)
         clrb 255(r1)
         clrb 319(r1)
         clrb -1(r1)
         br 16$

showscnz:
         mov @#viewport,r0
         clrb @#i1

;         ld a,(crsrbyte)
;         ld b,a
;         ld a,8
;         sub b
;         ld (i1+1),a
         mov #8,r1
         movb @#crsrbyte,r2
         sub r2,r1
         movb r1,@#i1+1

;         ld a,(crsrbit)
;         call calcx
;         ld a,8
;         sub b
;         ld (temp),a
         movb @#crsrbit,r1
         call @#calcx
         mov #8,r2
         sub r1,r2
         movb r2,@#temp

;         ld hl,$c800
;         ld iyh,3
         mov #16384+64+12,r1
         mov #65280+3,r2    ;65280=$ff03
         tstb @#pseudoc
         beq 3$
         jmp @#showscnzp

;loop3    ld iyl,5
3$:       add #5*256,r2   ;IY -> R2

;loop4    ld a,(crsrtile)
;         cp ixl
;         jp nz,cont4
;         ld a,(crsrtile+1)
;         cp ixh
;         jr nz,cont4

4$:      
;cont4    ld d,8
          mov #8,r3    ;D -> R3

         cmp r0,@#crsrtile
         bne 2$

         incb @#i1
2$:      movb (r0)+,r4
         mov #8,r5     ;B -> R5
         mov #tovideo,@#pageport
1$:      aslb r4
         bcc 11$

         movb #84,64(r1)
         movb #84,128(r1)  ;live cell char
         movb #84,192(r1)
         movb #84,256(r1)
         movb #16,320(r1)
         movb #16,(r1)+
16$:     tstb @#i1
         beq 15$

         cmpb r3,@#i1+1
         bne 15$

         cmpb @#temp,r5
         bne 15$

         call @#crsrpg
15$:     sob r5,1$

         mov #todata,@#pageport
         add #8*64-8,r1
         sob r3,2$

         sub #64*64-8,r1
         add #tilesize-8,r0
         sub #256,r2
         bpl 4$

         decb r2
         bne 30$

         return

30$:     add #tilesize*15,r0
         add #64*64-40,r1
         br 3$

11$:     tstb (r1)+     ;is it an empty cell?
         beq 16$

         clrb 63(r1)
         clrb 127(r1)
         clrb 191(r1)
         clrb 255(r1)
         clrb 319(r1)
         clrb -1(r1)
         br 16$

gexit:   jmp @#crsrset

showscn: call @#infoout
         tstb @#zoom
         bne showscnz

         tst @#tilecnt
         beq gexit

         tstb @#pseudoc
         beq showscn2
         br  showscnp

;showscn0 lda zoom
;         beq rts1

;         lda tilecnt
;         bne xcont2

;         lda tilecnt+1
;         bne xcont2
;         rts

showscn2: mov @#startp,r0
1$:       mov video(r0),r5
          mov @r0,r1
          mov 2(r0),r2
          mov 4(r0),r3
          mov 6(r0),@#temp
          mov #tovideo,@#pageport

          movb r1,r4        ;word output!
          asl r4
          mov vistab(r4),@r5
          swab r1
          movb r1,r1
          asl r1
          mov vistab(r1),64(r5)

          movb r2,r4
          asl r4
          mov vistab(r4),128(r5)
          swab r2
          movb r2,r2
          asl r2
          mov vistab(r2),192(r5)

          movb r3,r4
          asl r4
          mov vistab(r4),256(r5)
          swab r3
          movb r3,r3
          asl r3
          mov vistab(r3),320(r5)

          mov @#temp,r2
          movb r2,r4
          asl r4
          mov vistab(r4),384(r5)
          swab r2
          movb r2,r2
          asl r2
          mov vistab(r2),448(r5)

          mov #todata,@#pageport
          mov next(r0),r0
          cmp #1,r0
          bne 1$

;*         jmp crsrset
          jmp @#crsrset

;showscnp .block    ;uses: 7(vidmacp), i1(2), adjcell(2), adjcell2(2), temp(2)
;         #assign16 currp,startp
;loop     ldy #video
;         lda (currp),y
;         sta i1
;         eor #8
;         sta temp
;         iny
;         lda (currp),y
;         sta i1+1
;         sta temp+1
;         ldy #0
;         clc
;         lda currp
;         adc #count0
;         sta adjcell
;         lda currp+1
;         adc #0
;         sta adjcell+1
;         #vidmacp
;         iny
;         #vidmacp
;         iny
;         #vidmacp
;         iny
;         #vidmacp
;         iny
;         #vidmacp
;         iny
;         #vidmacp
;         iny
;         #vidmacp
;         iny
;         #vidmacp
;         ldy #next+1
;         lda (currp),y
;         bne cont
;         jmp crsrset

;cont     tax
;         dey
;         lda (currp),y
;         sta currp
;         stx currp+1
;         jmp loop
;         .bend
showscnp: mov @#startp,r0
1$:       mov video(r0),r5
          mov @r0,r1
          bne 3$

          mov #tovideo,@#pageport
          clr @r5
          clr 64(r5)
          mov #todata,@#pageport
          br 4$

3$:       vidmacp count0,0
          swab r1
          bne 5$

          mov #tovideo,@#pageport
          clr 64(r5)
          mov #todata,@#pageport
          br 4$

5$:       vidmacp count1,64
4$:       mov 2(r0),r1
          bne 7$

          mov #tovideo,@#pageport
          clr 128(r5)
          clr 192(r5)
          mov #todata,@#pageport
          br 6$

7$:       vidmacp count2,128
          swab r1
          bne 8$

          mov #tovideo,@#pageport
          clr 192(r5)
          mov #todata,@#pageport
          br 6$

8$:       vidmacp count3,192
6$:       mov 4(r0),r1
          bne 10$

          mov #tovideo,@#pageport
          clr 256(r5)
          clr 320(r5)
          mov #todata,@#pageport
          br 11$

10$:      vidmacp count4,256
          swab r1
          bne 12$

          mov #tovideo,@#pageport
          clr 320(r5)
          mov #todata,@#pageport
          br 11$

12$:      vidmacp count5,320
11$:      mov 6(r0),r1
          bne 14$

          mov #tovideo,@#pageport
          clr 384(r5)
          clr 448(r5)
          mov #todata,@#pageport
          br 15$

14$:      vidmacp count6,384
          swab r1
          bne 16$

          mov #tovideo,@#pageport
          clr 448(r5)
          mov #todata,@#pageport
          br 15$

16$:      vidmacp count7,448
15$:      mov next(r0),r0
          cmp #1,r0
          beq 2$

          jmp @#1$

;*         jmp crsrset
2$:       jmp @#crsrset
          

clrscn:   mov #tovideo,@#pageport
          mov #16384,r0
          mov #8192,r1
1$:       clr (r0)+
          sob r1,1$          
          mov #todata,@#pageport
          return

;xclrscn  .block
;         lda tilecnt
;         bne cont1
;
;         lda tilecnt+1
;         bne cont1
;
;         rts
;
;cont1    #assign16 currp,startp
;loop     ldy #sum
;         lda (currp),y
;         beq lnext
;
;         ldy #video
;         lda (currp),y
;         sta i1
;         iny
;         lda (currp),y
;         sta i1+1
;         lda #0
;         tay
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         lda #8
;         eor i1
;         sta i1
;         ldy #0
;         tya
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;         iny
;         sta (i1),y
;lnext    ldy #next
;         lda (currp),y
;         tax
;         iny
;         lda (currp),y
;         bne cont
;
;         cpx #1
;         bne cont
;
;         rts
;
;cont     sta currp+1
;         stx currp
;         jmp loop
;         .bend
;
;savebl   .block
;         ldy #39
;loop     lda $fc0,y
;         sta $1fc0,y
;         dey
;         bpl loop
;         rts            ;YR=255 - Y must be not equal to 0
;         .bend
;
;restbl   .block
;         ldy #39
;loop     lda $1fc0,y
;         sta $fc0,y
;         lda #0
;         sta $bc0,y
;         dey
;         bpl loop
;
;         rts
;         .bend

;loadmenu .block
;scrfn    = $c00+123
;         jsr JPRIMM
;         .byte 147,30
;         .text "input filename, an empty string means toshow directory. press "
;         .byte 28
;         .text "run/stop"
;         .byte 30
;         .text " to use ramdisk, "
;         .byte 28
;         .text "*"
;         .byte 30
;         .text " to change unit, "
;         .byte 28
;         .text "esc"
;         .byte 30
;         .text " to exit"
;         .byte $d,144
;         .null "u0 "
;         lda curdev
;         eor #$30
;         sta scrfn-2
;loop3    ldy #0
;         sty $ff0c
;loop1    tya
;         clc
;         adc #<scrfn
;         sta $ff0d
;         jsr getkey
;         cmp #27
;         bne cont7
;
;exit     jsr curoff
;         lda #0
;         rts
;
;cont7    cmp #"*"
;         bne cont11
;
;         lda curdev
;         eor #1
;         sta curdev
;         eor #$30
;         sta scrfn-2
;         bne loop1
;
;cont11   cmp #$d
;         beq cont1
;
;         cmp #$14   ;backspace
;         beq cont2
;
;         cmp #3     ;run/stop
;         bne cont8
;
;         jsr curoff
;         jsr ramdisk
;         jmp exit
;
;cont8    cmp #32
;         bcc loop1
;
;         cpy #16    ;fn length limit
;         beq loop1
;
;         ldx #0
;         stx fnlen
;         sta fn,y
;loop8    jsr BSOUT
;         iny
;         bpl loop1
;
;cont1    tya
;         beq menu2
;
;         sty fnlen
;         jmp curoff
;
;cont2    dey
;         bmi loop3
;
;         dey
;         jmp loop8
;
;menu2    jsr setdirmsk
;         cpx #27
;         beq repeat
;
;         jsr JPRIMM
;         .byte 147,30
;         .text "use "
;         .byte 28
;         .text "run/stop"
;         .byte 30
;         .text " and "
;         .byte 28
;         .text "cbm key"
;         .byte 30
;         .text " as usual"
;         .byte $d,0
;         jsr showdir
;         lda $c00
;         cmp #$15
;         bne cont10
;
;         jsr JPRIMM
;         .byte 19,27,"d",0
;cont10   jsr JPRIMM
;         .byte 19,27,"w",30
;msglen  = 20
;         .text "enter file# or "
;         .byte 28,"e","s","c",30,":"," ",144,0
;loop3a   ldy #0
;         sty $ff0c
;loop1a   tya
;         clc
;         adc #msglen
;         sta $ff0d
;         jsr getkey
;         cmp #27
;         bne cont7a
;
;repeat   jsr curoff
;         jmp loadmenu
;
;cont7a   cmp #$d
;         beq cont1a
;
;         cmp #$14   ;backspace
;         beq cont2a
;
;         cpy #3     ;#fn limit
;         beq loop1a
;
;         cmp #$30
;         bcc loop1a
;
;         cmp #$3a
;         bcs loop1a
;
;loop8a   jsr BSOUT
;         iny
;         bpl loop1a
;
;cont1a   tya
;         beq loop1a
;
;         pha     ;save y
;         lda #msglen
;         sta $3b
;         lda #0
;         sta $c00+msglen,y
;         lda #$71     ;white = invisible cursor
;         sta $800+msglen,y
;         lda #$c
;         sta $3c
;         lda $c00+msglen
;         clc
;         jsr STR2INT
;         lda $15
;         bne l1
;
;         jsr findfn
;l1       pla
;         tay
;         lda #32
;         sta $c00+msglen,y
;         lda fnlen
;         sta $800+msglen,y
;         beq loop1a
;         jmp curoff
;
;cont2a   dey
;         bmi loop3a
;
;         dey
;         jmp loop8a
;         .bend
;
;getsvfn  .block
;scrfn    = $c00+43
;         jsr JPRIMM
;         .byte 147,30
;         .text "enter filename ("
;         .byte 28
;         .text "esc"
;         .byte 30
;         .text " - exit, "
;         .byte 28, "*", 30
;         .text " - unit)"
;         .byte 144,$d
;         .null "u0 "
;         lda curdev
;         eor #$30
;         sta scrfn-2
;loop3    ldy #0
;         sty $ff0c
;loop1    tya
;         clc
;         adc #<scrfn
;         sta $ff0d
;         jsr getkey
;         cmp #27
;         bne cont7
;
;         jsr curoff
;         ldy #0
;         sta svfnlen
;         rts
;
;cont7    cmp #"*"
;         bne cont11
;
;         lda curdev
;         eor #1
;         sta curdev
;         eor #$30
;         sta scrfn-2
;         bne loop1
;
;cont11   cmp #$d
;         beq cont1
;
;         cmp #$14   ;backspace
;         beq cont2
;
;         cmp #32
;         bcc loop1
;
;         cpy #16    ;fn length limit
;         beq loop1
;
;         sta svfn+3,y
;loop8    jsr BSOUT
;         iny
;         bpl loop1
;
;cont1    sty svfnlen
;         jmp curoff
;
;cont2    dey
;         bmi loop3
;
;         dey
;         jmp loop8
;         .bend
;
;showrect .block
;;uses:
;         jsr restbl
;         clc
;         ldy #0
;         ldx #24
;         jsr PLOT        ;set position for the text
;         jsr JPRIMM
;         .byte 30
;         .text "move, "
;         .byte 28,"r",30
;         .text "otate, "
;         .byte 28,"f",30
;         .text "lip, "
;         .byte 28
;         .text "enter"
;         .byte 30
;         .text ", "
;         .byte 28
;         .text "esc"
;         .byte 144,0
;         lda #0
;         sta xdir
;         sta ydir
;         sta xchgdir
;         jsr tograph0
;         jsr showscn0
;loop0    jsr drawrect
;         jsr showtent
;         jsr crsrset0
;loop1    jsr getkey
;         cmp #$9d   ;cursor left
;         beq lselect
;
;         cmp #$1d   ;cursor right
;         beq lselect
;
;         cmp #$91   ;cursor up
;         beq lselect
;
;         cmp #$11   ;cursor down
;         beq lselect
;
;         cmp #"."   ;to center
;         beq lselect
;
;         cmp #19    ;to home
;         beq lselect
;
;         cmp #"R"-"A"+$41
;         bne cont1
;
;         jsr clrrect
;         lda xchgdir
;         eor #1
;         sta xchgdir
;         ldx xdir
;         lda ydir
;         eor #1
;         sta xdir
;         stx ydir
;         bpl loop0
;
;cont1    cmp #"F"-"A"+$41
;         bne cont2
;
;         jsr clrrect
;         lda xdir
;         eor #1
;         sta xdir
;         bpl loop0
;
;cont2    cmp #$d
;         beq finish
;
;         cmp #$1b
;         beq finish0
;
;         bne loop1
;
;lselect  pha
;         jsr clrrect
;         pla
;         jsr dispat0
;         jmp loop0
;
;finish   clc
;finish0  php
;         jsr clrrect
;         jsr restbl
;         jsr totext
;         plp
;         rts
;         .bend
;
;xchgxy   .block
;         lda xchgdir
;         beq exit
;
;         lda x0
;         ldx y0
;         sta y0
;         stx x0
;exit     rts
;         .bend
;
;drawrect .block
;;uses: adjcell:2, adjcell2:2, currp:2, t1, t2, t3, i1:2, $fd
;;calls: pixel11
;x8pos    = currp
;x8poscp  = $a7
;x8bit    = currp+1
;y8pos    = t1
;y8poscp  = $a8
;y8byte   = $fd                ;connected to seti1
;rectulx  = adjcell2
;rectuly  = adjcell2+1
;xcut     = t3
;ycut     = t2
;         jsr xchgxy
;         lda crsrbyte
;         sta y8byte
;         lda crsrbit
;         sta x8bit
;         ldx #8
;loop1    dex
;         lsr
;         bcc loop1
;
;         sta xcut        ;0 -> xcut
;         sta ycut
;         stx m1+1
;         lda crsrx
;         lsr
;         asl
;         asl
;         asl
;m1       adc #0
;         sta rectulx
;         ldx xdir
;         beq cont4
;
;         sec
;         sbc x0
;         bcs cont2
;
;         eor #$ff
;         beq cont10
;
;         inc xcut
;cont10   lda rectulx
;         adc #1
;         bcc cont7
;
;cont4    adc x0
;         bcs cont5
;
;         cmp #161
;         bcc cont2
;
;cont5    lda #160
;         inc xcut
;cont2    sec
;         sbc rectulx
;         bcs cont7
;
;         eor #$ff
;         adc #1
;cont7    sta x8pos
;         sta x8poscp
;         lda crsry
;         asl
;         asl
;         asl
;         adc crsrbyte
;         sta rectuly
;         ldx ydir
;         beq cont3
;
;         sec
;         sbc y0
;         bcs cont1
;
;         eor #$ff
;         beq cont12
;
;         inc ycut
;cont12   lda rectuly
;         adc #1
;         bcc cont8
;
;cont3    adc y0
;         bcs cont6
;
;         cmp #193
;         bcc cont1
;
;cont6    lda #192
;         inc ycut
;cont1    sec
;         sbc rectuly
;         bcs cont8
;
;         eor #$ff
;         adc #1
;cont8    sta y8pos
;         sta y8poscp
;         #assign16 adjcell,crsrtile
;         jsr ymove
;         lda ycut
;         bne cont11
;
;         jsr xmove
;cont11   lda x8poscp
;         sta x8pos
;         lda y8poscp
;         sta y8pos
;         lda crsrbyte
;         sta y8byte
;         lda crsrbit
;         sta x8bit
;         #assign16 adjcell,crsrtile
;         jsr xmove
;         lda xcut
;         bne exit
;
;ymove    lda ydir
;         bne loopup
;
;loopdn   jsr drrect1
;loop10   jsr pixel11
;         iny
;         dec y8pos
;         beq exit
;
;         sty y8byte
;         cpy #8
;         bne loop10
;
;         ldy #down
;         jsr nextcell
;         lda #0
;         sta y8byte
;         bpl loopdn
;
;loopup   jsr drrect1
;loop11   jsr pixel11
;         dec y8pos
;         beq exit
;
;         dey
;         sty y8byte
;         bpl loop11
;
;         ldy #up
;         jsr nextcell
;         lda #7
;         sta y8byte
;         bpl loopup
;
;exit     rts
;
;xmove    lda xdir
;         bne looplt
;
;looprt   jsr drrect1
;loop12   jsr pixel11
;         dec x8pos
;         beq exit
;
;         lda x8bit
;         lsr
;         bcs nextrt
;
;         sta x8bit
;         txa
;         lsr
;         tax
;         lda x8bit
;         cmp #8
;         bne loop12
;
;         lda #8
;         tax
;         eor i1
;         sta i1
;         bne loop12
;
;nextrt   ldy #right
;         jsr nextcell
;         lda #$80
;         sta x8bit
;         bne looprt
;
;looplt   jsr drrect1
;loop15   jsr pixel11
;         dec x8pos
;         beq exit
;
;         lda x8bit
;         asl
;         bcs nextlt
;
;         sta x8bit
;         txa
;         asl
;         tax
;         lda x8bit
;         cmp #16
;         bne loop15
;
;         ldx #1
;         lda i1
;         sbc #8
;         sta i1
;         bcs loop15
;
;nextlt   ldy #left
;         jsr nextcell
;         lda #1
;         sta x8bit
;         bne looplt
;
;drrect1  jsr seti1
;         lda x8bit
;         and #$f
;         beq cont14
;         jmp xcont4
;
;cont14   lda x8bit
;         jmp xcont3
;         .bend

;clrrect  .block   ;in: x8poscp, y8poscp
;;uses: adjcell:2, adjcell2:2, currp:2, i1:2, i2, t1, t2, t3, 7, $fd
;x8pos    = t3
;x8poscp  = $a7
;x8bit    = $9b
;y8pos    = $9c
;y8poscp  = $a8
;y8byte   = $fd   ;connected to seti1
;rectulx  = adjcell2
;rectuly  = adjcell2+1
;         jsr xchgxy
;         lda y8poscp
;         sta y8pos
;         lda crsrbyte
;         sta y8byte
;         lda crsrbit
;         sta x8bit
;         jsr calcx
;         and #3
;         ldx xdir
;         beq cl3
;
;         sbc #4
;         eor #$ff
;cl3      clc
;         adc x8poscp
;         sta x8pos
;         sta x8poscp
;
;         #assign16 adjcell,crsrtile
;         lda ydir
;         bne loopup
;
;loopdn   jsr xclrect
;         beq exit
;
;         inc y8byte
;         lda y8byte
;         cmp #8
;         bne loopdn
;
;         ldy #down
;         jsr nextcell
;         lda #0
;         sta y8byte
;         bpl loopdn
;
;loopup   jsr xclrect
;         beq exit
;
;         dec y8byte
;         bpl loopup
;
;         ldy #up
;         jsr nextcell
;         lda #7
;         sta y8byte
;         bpl loopup
;
;xclrect  lda adjcell
;         pha
;         lda adjcell+1
;         pha
;         jsr xmove
;         pla
;         sta adjcell+1
;         pla
;         sta adjcell
;         lda x8poscp
;         sta x8pos
;         lda crsrbit
;         sta x8bit
;         dec y8pos
;exit     rts
;
;xmove    lda xdir
;         bne looplt
;
;looprt   jsr clrect1
;loop12   jsr clrect3
;         jsr clrect2
;         sec
;         lda x8pos
;         sbc #4
;         sta x8pos
;         beq exit
;         bcc exit
;
;         lda x8bit
;         lsr
;         lsr
;         lsr
;         lsr
;         beq nextrt
;
;         sta x8bit
;         bne loop12
;
;nextrt   ldy #right
;         jsr nextcell
;         lda #$80
;         sta x8bit
;         bne looprt
;
;looplt   jsr clrect1
;loop15   jsr clrect3
;         jsr clrect2
;         lda x8pos
;         sec
;         sbc #4
;         sta x8pos
;         bcc exit
;         beq exit
;
;         lda x8bit
;         asl
;         asl
;         asl
;         asl
;         beq nextlt
;
;         sta x8bit
;         jsr clrect4
;         jmp loop15
; 
;nextlt   ldy #left
;         jsr nextcell
;         lda #1
;         sta x8bit
;         bne looplt
;
;clrect3  lda x8bit
;         and #$f0
;         bne cont1a
;
;clrect4  lda #8
;         eor i1
;         sta i1
;cont1a   rts
;
;clrect1  #assign16 currp,adjcell
;         jmp seti1
;
;clrect2  lda x8bit
;         and #$f0
;         beq cont1
;
;         lda pseudoc
;         bne cont2
;
;         #vidmac1
;         rts
;
;cont2    lda #pc
;         clc
;         adc y8byte
;         sta t1
;         #vidmac1p
;         rts
;
;cont1    lda pseudoc
;         bne cont3
;
;         #vidmac2
;         rts
;
;cont3    lda #pc
;         clc
;         adc y8byte
;         sta t1
;         lda (currp),y
;         sty 7
;         sta i2
;         ldy t1
;         lda (currp),y
;         tay
;         and i2
;         ldx 7
;         sta pctemp1,x   ;old
;         tya
;         ldy y8byte
;         .bend
;
;         jmp xcont7
;
;seti1    .block
;y8byte   = $fd
;         ldy #video
;         lda (adjcell),y
;         sta i1
;         iny
;         lda (adjcell),y
;         sta i1+1
;         ldy y8byte
;         rts
;         .bend
;
;crsrset1 .block
;         ldy #video
;         lda (crsrtile),y
;         sta i1
;         iny
;         lda (crsrtile),y
;         sta i1+1
;         ldx crsrc
;         ldy crsrbyte
;         lda (crsrtile),y
;         and crsrbit
;         bne cont3
;
;         ldx crsrocc
;cont3    stx $ff16
;         lda crsrbit
;         and #$f
;         bne xcont4
;
;         lda crsrbit
;         .bend
;
;xcont3   lsr
;         lsr
;         lsr
;         lsr
;         bpl xcont1
;
;xcont4   tax
;         lda #8
;         eor i1
;         sta i1
;         txa
;xcont1   tax
;         rts
;
;pixel11  lda vistab,x
;         asl
;         ora vistab,x
;         ora (i1),y
;         sta (i1),y
;         rts
;
;crsrset0 jsr crsrset1
;         lda vistab,x
;         asl
;         eor (i1),y
;         sta (i1),y
;         rts
;
;setdirmsk
;         .block
;         jsr JPRIMM
;         .byte 147
;msglen   = 40
;         .text "set directory mask ("
;         .byte 28
;         .text "enter"
;         .byte 30
;         .text " = *)"
;         .byte $d,144,0
;loop3    ldy #0
;         sty $ff0c
;loop1    tya
;         clc
;         adc #<msglen
;         sta $ff0d
;         jsr getkey
;         cmp #$d
;         beq cont1
;
;         tax
;         cmp #27
;         beq cont4
;
;         cmp #$14    ;backspace
;         beq cont2
;
;         cmp #32
;         bcc loop1
;
;         cpy #16     ;max mask length
;         beq loop1
;
;         sta dirname+3,y
;loop8    jsr BSOUT
;         iny
;         bpl loop1
;
;cont1    tya
;         bne cont3
;
;         lda #"*"
;         sta dirname+3
;         iny
;cont3    lda #"="
;         tax
;         sta dirname+3,y
;         lda #"u"
;         sta dirname+4,y
;         tya
;         adc #4   ;+CY=1
;         sta dirnlen
;cont4    jmp curoff
;
;cont2    dey
;         bmi loop3
;
;         dey
;         bcs loop8
;         .bend

setviewport:
          mov @#crsrtile,@#viewport
          return

;         ld hl,(crsrtile)
;         ld (viewport),hl
;         ld ix,vptilecx
;;*         ldx #2
;;*         stx vptilecx
;;*         dex
;;*         stx vptilecy
;         ld a,2
;         ld (vptilecx),a
;         dec a
;         ld (vptilecy),a
;;*         lda $fe5
;;*         ora $fe6
;;*         eor #$30
;;*         bne cont1
;         ld hl,(ycrsr)
;         ld a,l
;         or h
;         jr nz,cont1
 
;;*         lda $fe7
;;*         cmp #$38
;;*         bcs cont1
;         ld a,(ycrsr+2)
;         cp 8
;         jr nc,cont1

;;*         dec vptilecy
;         dec (ix+1)
;;*         lda viewport          ;up
;;*         adc #<tilesize*20     ;CY=0
;;*         sta viewport
;;*         lda viewport+1
;;*         adc #>tilesize*20
;;*         sta viewport+1
;;*         bne cont2
;         ld hl,(viewport)      ;up
;         ld de,tilesize*20
;         add hl,de
;         ld (viewport),hl
;         jr cont2

;;*cont1    lda $fe5
;;*         cmp #$31
;;*         bne cont2
;cont1    ld a,(ycrsr)
;         dec a
;         jr nz,cont2

;;*         lda $fe6
;;*         cmp #$38
;;*         bcc cont2
;;*         bne cont4
;         ld a,(ycrsr+1)
;         cp 8
;         jr c,cont2
;         jr nz,cont4

;;*         lda $fe7
;;*         cmp #$34
;;*         bcc cont2
;         ld a,(ycrsr+2)
;         cp 4
;         jr c,cont2

;;*cont4    inc vptilecy
;;*         lda viewport          ;down
;;*         sbc #<tilesize*20     ;CY=1
;;*         sta viewport
;;*         lda viewport+1
;;*         sbc #>tilesize*20
;;*         sta viewport+1
;cont4    inc (ix+1)
;         ld hl,(viewport)      ;down
;         ld de,(~(tilesize*20))+1
;         add hl,de
;         ld (viewport),hl

;;*cont2    lda $fe0
;;*         ora $fe1
;;*         eor #$30
;;*         bne cont3
;cont2    ld hl,(xcrsr)
;         ld a,l
;         or h
;         jr nz,cont3

;;*         lda $fe2
;;*         cmp #$38
;;*         bcs cont3
;         ld a,(xcrsr+2)
;         cp 8
;         jr nc,cont3

;;*         dec vptilecx
;;*         dec vptilecx
;         dec (ix)
;         dec (ix)
;;*         lda viewport          ;left2
;;*         adc #<tilesize*2      ;CY=0
;;*         sta viewport
;;*         lda viewport+1
;;*         adc #>tilesize*2
;;*         sta viewport+1
;;*         bne cont5
;         ld hl,(viewport)      ;left2
;         ld de,tilesize*2
;         add hl,de
;         ld (viewport),hl
;         jr cont5

;;*cont3    lda $fe0
;;*         eor #$30
;;*         bne cont6
;cont3    ld a,(xcrsr)
;         or a
;         jr nz,cont6

;;*         lda $fe1
;;*         cmp #$31
;;*         bcc cont7
;;*         bne cont6
;         ld a,(xcrsr+1)
;         cp 1
;         jr c,cont7
;         jr nz,cont6

;;*         lda $fe2
;;*         cmp #$36
;;*         bcs cont6
;         ld a,(xcrsr+2)
;         cp 6
;         jr nc,cont6

;;*cont7    dec vptilecx
;cont7    dec (ix)
;;*         lda viewport          ;left1
;;*         adc #<tilesize        ;CY=0
;;*         sta viewport
;;*         lda viewport+1
;;*         adc #>tilesize
;;*         sta viewport+1
;;*         bne cont5
;         ld hl,(viewport)      ;left1
;         ld de,tilesize
;         add hl,de
;         ld (viewport),hl
;         jr cont5

;;*cont6    lda $fe0
;;*         cmp #$31
;;*         bne cont8
;cont6    ld a,(xcrsr)
;         dec a
;         jr nz,cont8

;;*         lda $fe1
;;*         cmp #$35
;;*         bne cont8
;         ld a,(xcrsr+1)
;         cp 5
;         jr nz,cont8

;;*         lda $fe2
;;*         cmp #$32
;;*         bcc cont8
;         ld a,(xcrsr+2)
;         cp 2
;         jr c,cont8

;;*         inc vptilecx
;;*         inc vptilecx
;         inc (ix)
;         inc (ix)
;;*         lda viewport          ;right2
;;*         sbc #<tilesize*2      ;CY=1
;;*         sta viewport
;;*         lda viewport+1
;;*         sbc #>tilesize*2
;;*         sta viewport+1
;;*         bne cont5
;         ld hl,(viewport)      ;right2
;         ld de,(~(tilesize*2))+1
;         add hl,de
;         ld (viewport),hl
;         jr cont5

;;*cont8    lda $fe0
;;*         cmp #$31
;;*         bne cont5
;cont8    ld a,(xcrsr)
;         dec a
;         jr nz,cont5

;;*         lda $fe1
;;*         cmp #$34
;;*         bcc cont5
;;*         bne cont10
;         ld a,(xcrsr+1)
;         cp 4
;         jr c,cont5
;         jr nz,cont10

;;*         lda $fe2
;;*         cmp #$34
;;*         bcc cont5
;         ld a,(xcrsr+2)
;         cp 4
;         jr c,cont5

;;*cont10   inc vptilecx
;cont10   inc (ix)
;;*         lda viewport          ;right1
;;*         sbc #<tilesize        ;CY=1
;;*         sta viewport
;;*         lda viewport+1
;;*         sbc #>tilesize
;;*         sta viewport+1
;         ld hl,(viewport)      ;right1
;         ld de,(~tilesize)+1
;         add hl,de
;         ld (viewport),hl

;;*cont5    ldy #ul
;;*         lda (viewport),y
;;*         tax
;;*         iny
;;*         lda (viewport),y
;;*         sta viewport+1
;;*         stx viewport
;cont5    ld iy,(viewport)
;         ld hl,fixvp
;         call calllo
;         ld (viewport),hl
;         ld b,3
;loop12   sla (ix)
;         sla (ix+1)
;         djnz loop12

;         ld a,(crsrbyte)
;         add a,(ix+1)
;         ld (ix+1),a
;         ld a,(crsrbit)
;         call calcx
;         add a,(ix)
;         ld (ix),a
;         ret


;;crsrset  jsr crsrset1
crsrset: return
;         lda zoom
;         bne gexit2

;         jmp pixel11

;crsrcalc .block      ;its call should be after crsrset!
;         lda i1+1    ;start of coorditates calculation
;         sec
;         sbc #$20
;         sta i1+1
;         lsr i1+1
;         ror i1
;         lsr i1+1
;         ror i1
;         lsr i1+1
;         ror i1
;         ldy #0
;cont7    sec
;         lda i1
;         sbc #$28
;         tax
;         lda i1+1
;         sbc #0
;         bmi cont6
;
;         sta i1+1
;         stx i1
;         iny
;         bne cont7
;
;cont6    sty crsry
;         lda ctab,y
;         sed
;         clc
;         adc crsrbyte
;         sta t1
;         ldx #$30
;         bcs l2
;
;         cpy #$d
;         bcc l1
;
;l2       inx
;l1       stx ycrsr
;         lda t1
;         and #$f
;         eor #$30
;         sta ycrsr+2
;         lda t1
;         lsr
;         lsr
;         lsr
;         lsr
;         eor #$30
;         sta ycrsr+1
;         ldx #8
;         lda crsrbit
;cont8    dex
;         lsr
;         bcc cont8
;
;         lda i1
;         sta crsrx
;         lsr
;         tay
;         txa
;         clc
;         adc ctab,y
;         sta t1
;         ldx #$30
;         bcs l4
;
;         cpy #$d
;         bcc l3
;
;l4       inx
;l3       stx xcrsr
;         lda t1
;         and #$f
;         eor #$30
;         sta xcrsr+2
;         lda t1
;         lsr
;         lsr
;         lsr
;         lsr
;         eor #$30
;         sta xcrsr+1
;         cld
;         lda zoom
;         bne l8
;
;         rts
;
;l8       ldy #up
;         ldx #7
;         lda vptilecy
;         bmi cont3
;
;         ldy #down
;         cmp #24
;         bcc cont4
;
;         ldx #16
;cont3    stx vptilecy
;         bne cont1
;
;cont4    ldy #left
;         lda vptilecx
;         bmi cont5
;
;         ldy #right
;         cmp #40
;         bcc cont2
;
;         ldx #32
;cont5    stx vptilecx
;cont1    lda (viewport),y
;         tax
;         iny
;         lda (viewport),y
;         sta viewport+1
;         sta adjcell+1
;         stx viewport
;         stx adjcell
;         ldy #down
;         jsr nextcell
;         dey
;         jsr nextcell
;         lda #4
;         sta i2
;loopx    ldy #right
;         jsr nextcell
;         dec i2
;         bne loopx
;
;         lda viewport
;         clc
;         adc #<44*tilesize
;         tax
;         lda viewport+1
;         adc #>44*tilesize
;         cmp adjcell+1
;         bne l7
;
;         cpx adjcell
;         beq cont0
;
;l7       jsr setviewport
;cont0    jsr showscnpg
;cont2    lda #0
;         sta t1
;         lda vptilecy
;         asl
;         asl
;         adc vptilecy
;         asl
;         asl
;         rol t1
;         asl
;         rol t1
;         adc vptilecx
;         sta $ff0d
;         lda t1
;         adc #0
;         sta $ff0c
;exit     rts
;         .bend
;
;infov    .block
;         jsr JPRIMM
;         .byte 147,144,0
;
;         lda fnlen
;         beq cont1
;
;         jsr JPRIMM
;         .null "last loaded filename: "
;
;         ldy #0
;loop1    lda fn,y
;         jsr BSOUT
;         iny
;         cpy fnlen
;         bne loop1
;
;cont1    sei
;         sta $ff3f
;         jsr boxsz
;         sta $ff3e
;         cli
;         beq cont2
;
;xmin     = i1
;ymin     = i1+1
;xmax     = adjcell
;ymax     = adjcell+1
;sizex    = adjcell2
;sizey    = adjcell2+1
;         jsr JPRIMM
;         .byte $d
;         .null "active pattern size: "
;
;         lda #0
;         ldx sizex
;         jsr INT2STR
;         lda #"x"
;         jsr BSOUT
;         lda #0
;
;         ldx sizey
;         jsr INT2STR
;         jsr JPRIMM
;         .byte $d
;         .null "box life bounds: "
;
;         lda #0
;         ldx xmin
;         jsr INT2STR
;         jsr JPRIMM
;         .null "<=x<="
;
;         lda #0
;         ldx xmax
;         jsr INT2STR
;         lda #" "
;         jsr BSOUT
;         lda #0
;         ldx ymin
;         jsr INT2STR
;         jsr JPRIMM
;         .null "<=y<="
;
;         lda #0
;         ldx ymax
;         jsr INT2STR
;cont2    jsr JPRIMM
;         .byte $d
;         .null "rules: "
;         jsr showrules2
;         jmp getkey
;         .bend
;
;chgclrs1 ldx i1
;         inx
;         stx i1
;         lda borderpc,x
;         #printhex
;         jsr JPRIMM
;         .null "): "
;         rts
;
;chgclrs2 asl
;         asl
;         asl
;         asl
;         sta t1
;         tya
;         and #$f
;         ora t1
;         ldx i1
;         sta borderpc,x
;         rts
;
;chgcolors             ;t1,i1
;         .block
;curpos1  = 183
;curpos2  = 223
;curpos3  = 272
;curpos4  = 313
;curpos5  = 340
;curpos6  = 379
;curpos7  = 426
;curpos8  = 464
;curpos9  = 508
;         ldx #$ff
;         stx i1
;         jsr JPRIMM
;         .byte 147,30
;         .text "press "
;         .byte 28
;         .text "enter"
;         .byte 30
;         .text " to use default color or input hexadecimal number of color. the"
;         .text " firstdigit of this number means luminance andthe second - color."
;         .byte $d,144
;         .null "the plain border ("
;         jsr chgclrs1
;         lda #>curpos1
;         ldy #<curpos1
;         jsr inputhex
;         beq cont1
;
;         lda 3072+curpos1
;         ldy 3073+curpos1
;         jsr chgclrs2
;cont1    jsr JPRIMM
;         .byte $d
;         .null "the torus border ("
;         jsr chgclrs1
;         lda #>curpos2
;         ldy #<curpos2
;         jsr inputhex
;         beq cont2
;
;         lda 3072+curpos2
;         ldy 3073+curpos2
;         jsr chgclrs2
;cont2    jsr JPRIMM
;         .byte $d
;         .null "the cursor over live cell ("
;         jsr chgclrs1
;         lda #>curpos3
;         ldy #<curpos3
;         jsr inputhex
;         beq cont3
;
;         lda 3072+curpos3
;         ldy 3073+curpos3
;         jsr chgclrs2
;cont3    jsr JPRIMM
;         .byte $d
;         .null "the cursor over empty cell ("
;         jsr chgclrs1
;         lda #>curpos4
;         ldy #<curpos4
;         jsr inputhex
;         beq cont4
;
;         lda 3072+curpos4
;         ldy 3073+curpos4
;         jsr chgclrs2
;cont4    jsr JPRIMM
;         .byte $d
;         .null "the live cell ("
;         jsr chgclrs1
;         lda #>curpos5
;         ldy #<curpos5
;         jsr inputhex
;         beq cont5
;
;         lda 3072+curpos5
;         ldy 3073+curpos5
;         jsr chgclrs2
;cont5    jsr JPRIMM
;         .byte $d
;         .null "the new cell ("
;         jsr chgclrs1
;         lda #>curpos6
;         ldy #<curpos6
;         jsr inputhex
;         beq cont6
;
;         lda 3072+curpos6
;         ldy 3073+curpos6
;         jsr chgclrs2
;cont6    jsr JPRIMM
;         .byte $d
;         .null "the edit background ("
;         jsr chgclrs1
;         lda #>curpos7
;         ldy #<curpos7
;         jsr inputhex
;         beq cont7
;
;         lda 3072+curpos7
;         ldy 3073+curpos7
;         jsr chgclrs2
;cont7    jsr JPRIMM
;         .byte $d
;         .null "the go background ("
;         jsr chgclrs1
;         lda #>curpos8
;         ldy #<curpos8
;         jsr inputhex
;         beq cont8
;
;         lda 3072+curpos8
;         ldy 3073+curpos8
;         jsr chgclrs2
;cont8    jsr JPRIMM
;         .byte $d
;         .null "the status background ("
;         jsr chgclrs1
;         lda #>curpos9
;         ldy #<curpos9
;         jsr inputhex
;         beq cont9
;
;         lda 3072+curpos9
;         ldy 3073+curpos9
;         jsr chgclrs2
;cont9    jsr curoff
;         jsr JPRIMM
;         .byte $d
;         .null "to save this config?"
;loop     jsr getkey
;         cmp #"n"
;         beq exit
;
;         cmp #"y"
;         bne loop
;
;         jsr savecf
;exit     rts
;         .bend
;
;putpixel2 .block 
;         tax
;         jsr seti1
;         txa
;         and #$f
;         beq l1
;
;         tax
;         lda i1
;         eor #8
;         sta i1
;         bne l2
;
;l1       txa
;         lsr
;         lsr
;         lsr
;         lsr
;         tax
;l2       lda vistab,x
;         sta t2
;         asl
;         sta t3
;         ora t2
;         eor #$ff
;         and (i1),y
;         ora t3
;         sta (i1),y
;         rts
;         .bend
;
;showtent .block   ;used: 
;         lda x0
;         pha
;         lda y0
;         pha
;         lda #0
;         sta $14
;         sta $15
;         sta ppmode
;loop     lda $15
;         cmp $b9
;         bne l1
;
;         ldx $14
;         cpx $b8
;         beq exit
;
;l1       eor #8
;         sta $15
;         ldx #0
;         lda ($14,x)
;         sta x0
;         lda $15
;         eor #4
;         sta $15
;         lda ($14,x)
;         sta y0
;         ora x0
;         beq l3
;
;         jsr putpixel
;l3       lda $15
;         eor #$c
;         sta $15
;         inc $14
;         bne loop
;
;         inc $15
;         bne loop

;exit     pla
;         sta y0
;         pla
;         sta x0
;         inc ppmode
;         rts
;         .bend

showtopology:
         mov #27,r1
         mov #2,r2
         mov #msgtore,r3
         tstb @#topology
         beq showptxt

         mov #msgplan,r3
         br showptxt

showmode:
         mov #0,r1
         mov #2,r2
         mov #msgstop,r3
         movb @#mode,r0
         beq showptxt

         mov #msgrun,r3
         dec r0
         beq showptxt
         
         mov #msghide,r3

showptxt:     ;IN: R1 - X, R2 - Y, R3 - msg
         mov #toandos,@#pageport
         emt #^O24
         mov r3,r1
spt1:    mov #255,r2
         emt #^O20
         mov #todata,@#pageport
         return

showtxt:     ;IN: R1 - msg
         mov #toandos,@#pageport
         br spt1

