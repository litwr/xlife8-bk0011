insteps: call @#totext
         jsr r3,@#printstr
         .byte 154,0
38$:     jsr r3,@#printstr
         .byte 12,146
         .ascii "NUMBER OF GENERATIONS: "
         .byte 0
;         call TXT_PLACE_CURSOR
3$:      mov #stringbuf,r2
;         ld c,0
         clr r1
         clr @#temp
1$:      call @#getkey
;         cp $d
         cmpb #10,r0
;         jr z,cont1
         beq 11$

;         cp $fc       ;esc
;         ret z
         cmpb #9,r0    ;tab
         bne 16$

20$:     jsr r3,@#printstr
         .byte 154,0
         return

;         cp $7f       ;backspace
;         jr z,cont2
16$:     cmpb #24,r0    ;backspace=zaboy
         beq 12$

;         cp $3a
;         jr nc,loop1
         cmpb r0,#'0+10
         bcc 1$

;         cp "0"
;         jr c,loop1
         cmpb r0,#'0
         bcs 1$

;         ld b,a
;         ld a,5
;         cp c
;         ld a,b
;         jr z,loop1
         cmpb #5,r1
         beq 1$

;         ld (de),a
;         inc de
;         inc c
         inc r1
;         ld b,a
;         call TXT_REMOVE_CURSOR
;         ld a,b
;         call TXT_OUTPUT
         emt ^O16
         sub #'0,r0
         movb r0,(r2)+
;cont4    call TXT_PLACE_CURSOR
;         jr loop1
         br 1$

;cont2    dec de
;         dec c
;         jp m,loop3
12$:     dec r2
         dec r1
         bmi 3$

;         call TXT_REMOVE_CURSOR
;         call printn
;         db 8,32,8,"$"
;         jr cont4
         jsr r3,@#printstr
         .byte 8,32,8,0
         br 1$

;cont1    call TXT_REMOVE_CURSOR
11$:      tst r1
          beq 20$

;         ld l,e
;         ld h,d
;         ld a,c
;         or a
;         ret z

;         ld bc,(~stringbuf)+1
;         add hl,bc
;         ret    ;hl - buffer length, de - buffer end
         sub r1,r2          ;convert to binary
         clr r4
         dec r1
         asl r1
33$:     movb (r2)+,r3
         beq 34$

         mov tobin(r1),r0
32$:     add r0,r4
         bcs 38$        ;65535=max
         sob r3,32$

34$:     sub #2,r1
         bpl 33$

         mov r4,@#temp2
         br 20$

bornstay:
         mov #stringbuf,r4
3$:      mov r4,r3
1$:      call @#getkey

;         cmp #$d
;         beq cont1
         cmpb #10,r0
         beq 11$

;         cmp #$14   ;backspace
;         beq cont2
         cmpb #24,r0    ;backspace=zaboy
         beq 12$

         cmp #'0,r5
         beq 40$

;         cmp #27    ;esc
;         beq cont1
         cmpb #9,r0    ;tab
         beq 11$

40$:     cmpb r0,r5
         bcs 1$

         cmpb r0,#'9
         bcc 1$

         mov r4,r2
4$:      cmp r2,r3
         beq 5$

         cmpb (r2)+,r0
         beq 1$
         br 4$

5$:      movb r0,(r3)+
         emt ^O16
         br 1$

11$:     mov r0,r5
         jsr r3,@#printstr
         .byte 154,0

         return

12$:     dec r3
         cmp r3,r4
         bmi 3$

         jsr r3,@#printstr
         .byte 8,32,8,0
         br 1$

inborn:  jsr r3,@#printstr
         .byte 154
         .byte 12,147
         .ascii "THE RULES ARE DEFINED BY "
         .byte 156,
         .ascii "BORN"
         .byte 156
         .ascii " AND "
         .byte 156
         .ascii "STAY"
         .byte 156
         .ascii " VALUES.  FOR EXAMPLE, "
         .byte 159
         .ascii "CONWAYS'S LIFE"
         .byte 159
         .ascii " HAS BORN=3 AND STAY=23, "
         .byte 159
         .ascii "SEEDS"
         .byte 159
         .ascii " - BORN=2 AND EMPTY STAY, "
         .byte 159
         .ascii "HIGHLIFE"
         .byte 159
         .ascii " - BORN=36 AND STAY=23, "
         .byte 159
         .ascii "LIFE WITHOUT DEATH"
         .byte 159
         .ascii " - BORN=3 AND STAY=012345678, ..."
         .byte 146,10,10
         .ascii "BORN = "
         .byte 0

         mov #'1,r5
         jmp @#bornstay

instay:  jsr r3,@#printstr
         .byte 154,10
         .ascii "STAY = "
         .byte 0

         mov #'0,r5
         jmp @#bornstay

indens:  call @#totext
         jsr r3,@#printstr
         .byte 12,146
         .ascii "SELECT DENSITY OR PRESS "
         .byte 145
         .ascii "TAB"
         .byte 146
         .ascii " TO EXIT"
         .byte 10,9,145,'0,147
         .ascii " - 12.5%"
         .byte 10,9,145,'1,147
         .ascii " - 28%"
         .byte 10,9,145,'2,147
         .ascii " - 42%"
         .byte 10,9,145,'3,147
         .ascii " - 54%"
         .byte 10,9,145,'4,147
         .ascii " - 64%"
         .byte 10,9,145,'5,147
         .ascii " - 73%"
         .byte 10,9,145,'6,147
         .ascii " - 81%"
         .byte 10,9,145,'7,147
         .ascii " - 88.5%"
         .byte 10,9,145,'8,147
         .ascii " - 95%"
         .byte 10,9,145,'9,147
         .ascii " - 100%"
         .byte 0,0
1$:      call @#getkey
         cmpb #9,r0
         beq 2$

         cmpb r0,#'0
         bcs 1$

         cmpb r0,#'0+10
         bcc 1$

         sub #'0-1,r0
         movb r0,@#density
2$:      jmp @#tograph

help:    call @#totext
         jsr r3,@#printstr
         .byte 12
         .ascii "    "
         .byte 146,159
         .ascii "*** XLIFE COMMANDS ***"
         .byte 159,155,10,9,156,'!,156
         .ascii " randomize screen"
         .byte 10,9,137,156,'%,156
         .ascii " set random density - default=42%"
         .byte 10,9,156,'+,156,'/,156,'-,156
         .ascii " zoom in/out"
         .byte 10,9,156,'.,156,'/,156,'C,226,'P,156
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
         .ascii "cursor keys"
         .byte 156,159
         .ascii " to set the position and "
         .byte 159,156
         .ascii "space key"
         .byte 156,159
         .ascii " to toggle the current cell. "
         .ascii "Use "
         .byte 159,156
         .ascii "AP2"
         .byte 156,159
         .ascii " to speed up the movement"
         .byte 159,0,0 ;word align
         mov @#yshift,@#yscroll
         add #14,@#yshift
         call @#getkey
         jsr r3,@#printstr
         .byte 155,0
         jmp @#tograph

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
            cmp #120,r3   ;sets CY=0
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
1$:         mov #2570,@r0      ;$a0a
            movb ttab(r3),r1
            mov r1,r2
            bic #^B11110000,r1
            movb r1,2(r0)
            rorb r2   ;uses CY=0
            asrb r2
            asrb r2
            asrb r2
            beq 2$
            
;           ld (tinfo+1),a
            movb r2,1(r0)

;cont2      ld b,3
;           ld hl,tinfo
;           ld de,$c79e
;           jp digiout
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

crsrpg:  clrb @#i1
         tstb @#crsrpgmk
         beq 1$

         push r0
         push r1
         mov #85,r0
         movb r0,383(r1)
         movb r0,-65(r1)
         bit #1,r1
         bne 2$

         dec r1
         swab r0
2$:      xor r0,63(r1)
         xor r0,127(r1)
         xor r0,191(r1)
         xor r0,255(r1)
         xor r0,319(r1)
         xor r0,-1(r1)
         pop r1
         pop r0
         return

1$:      clrb 383(r1)
         clrb -65(r1)
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
         mov #videostart+64,r1
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

gexit:    jmp @#crsrset

showscn:  call @#infoout
          tstb @#zoom
          bne showscnz

          tst @#tilecnt
          beq gexit

          tstb @#pseudoc
          beq showscn2
          br  showscnp

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
;         .ascii "input filename, an empty string means toshow directory. press "
;         .byte 28
;         .ascii "run/stop"
;         .byte 30
;         .ascii " to use ramdisk, "
;         .byte 28
;         .ascii "*"
;         .byte 30
;         .ascii " to change unit, "
;         .byte 28
;         .ascii "esc"
;         .byte 30
;         .ascii " to exit"
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
;         .ascii "use "
;         .byte 28
;         .ascii "run/stop"
;         .byte 30
;         .ascii " and "
;         .byte 28
;         .ascii "cbm key"
;         .byte 30
;         .ascii " as usual"
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
;         .ascii "enter file# or "
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
;         .ascii "enter filename ("
;         .byte 28
;         .ascii "esc"
;         .byte 30
;         .ascii " - exit, "
;         .byte 28, "*", 30
;         .ascii " - unit)"
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

showrect:
;         clc
;         ldy #0
;         ldx #24
;         jsr PLOT        ;set position for the text
         mov #toandos,@#pageport
         clr r1
         mov #19,r2
         emt ^O24

;         jsr JPRIMM
;         .byte 30
;         .ascii "move, "
;         .byte 28,"r",30
;         .ascii "otate, "
;         .byte 28,"f",30
;         .ascii "lip, "
;         .byte 28
;         .ascii "enter"
;         .byte 30
;         .ascii ", "
;         .byte 28
;         .ascii "esc"
;         .byte 144,0
         jsr r3,@#printstr
         .byte 153,146
         .ascii "MOVE, "
         .byte 145,'R,146
         .ascii "OTATE, "
         .byte 145,'F,146
         .ascii "LIP, "
         .byte 145
         .ascii "ENTER"
         .byte 146, ',,32,145
         .ascii "TAB"
         .byte 0
       
;         lda #0
;         sta xdir
;         sta ydir
;         sta xchgdir
         clr @#xdir
         clrb @#xchgdir

;         jsr tograph0
;         jsr showscn0
;loop0    jsr drawrect
;         jsr showtent
;         jsr crsrset0
10$:     call @#drawrect
         ;call @#showtent
         ;call @#crsrset0

;loop1    jsr getkey
11$:     call @#getkey

;         cmp #$9d   ;cursor left
;         beq lselect
         cmpb #8,r0
         beq 100$

;         cmp #$1d   ;cursor right
;         beq lselect
         cmpb #25,r0
         beq 100$

;         cmp #$91   ;cursor up
;         beq lselect
         cmpb #26,r0
         beq 100$

;         cmp #$11   ;cursor down
;         beq lselect
         cmpb #27,r0
         beq 100$

;         cmp #"."   ;to center
;         beq lselect
         cmpb #'.,r0
         beq 100$

;         cmp #19    ;to home
;         beq lselect
         cmpb #12,r0
         beq 100$

;         cmp #"R"-"A"+$41
;         bne cont1
         cmpb #'r,r0
         bne 1$

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
         ;call @#clrrect
         comb @#xchgdir
         swab @#xdir
         comb @#xdir
         br 10$

;cont1    cmp #"F"-"A"+$41
;         bne cont2
1$:      cmpb #'f,r0
         bne 2$

;         jsr clrrect
;         lda xdir
;         eor #1
;         sta xdir
;         bpl loop0
         ;call @#clrrect
         comb @#xdir
         br 10$

;cont2    cmp #$d
;         beq finish
2$:      cmpb #10,r0
         beq 110$

;         cmp #$1b
;         beq finish0

;         bne loop1
         br 11$

;lselect  pha
;         jsr clrrect
;         pla
;         jsr dispat0
;         jmp loop0
100$:    push r0
         ;call @#clrrect
         pop r0
         call @#dispat0
         br 10$

110$:
;finish   clc
;finish0  php
;         jsr clrrect
;         jsr restbl
;         jsr totext
;         plp
;         rts
         return

xchgxy:  tstb @#xchgdir
         beq 1$

         swab r1
1$:      return


drawrect:
;;calls: pixel11p
xcut      = temp2
ycut      = temp2+1
x8poscp   = temp
y8poscp   = temp+1
x8bit     = i1
y8byte    = saved
;         jsr xchgxy
         call @#xchgxy

;         lda crsrbyte
;         sta y8byte
;         lda crsrbit
;         sta x8bit
;         jsr calcx
;         lda #0
;         sta xcut        ;0 -> xcut
;         sta ycut
;         stx m1+1
         clr @#xcut
         movb @#crsrbyte,@#y8byte
         movb @#crsrbit,r1
         call @#calcx

;         lda crsrx
;         lsr
;         asl
;         asl
;         asl
;m1       adc #0
;         sta rectulx
;         ldx xdir
;         beq cont4
         bis @#crsrx,r1
         mov r1,r3   ;r1 - rectulx
         tstb @#xdir
         beq 4$

;         sec
;         sbc x0
;         bcs cont2
         sub @#x0,r3
         cmpb r1,r3
         bcc 2$
 
;         eor #$ff
;         beq cont10
         comb r3
         beq 10$ 

;         inc xcut
;cont10   lda rectulx
;         adc #1
;         bcc cont7
         incb @#xcut
10$:     mov r1,r3
         inc r3
         br 7$

;cont4    adc x0
;         bcs cont5
4$:      add @#x0,r3
         cmpb r3,r1
         bcs 5$

;         cmp #161
;         bcc cont2
         cmpb r3,#161
         bcs 2$

;cont5    lda #160
;         inc xcut
5$:      mov #160,r3
         incb @#xcut

;cont2    sec
;         sbc rectulx
;         bcs cont7
2$:      mov r3,r0
         sub r1,r3
         cmpb r0,r3
         bcc 7$

;         eor #$ff
;         adc #1
         neg r3

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
7$:      movb r3,@#x8poscp
         movb @#crsry,r4
         bisb @#crsrbyte,r4
         mov r4,r1
         movb @#y0,r0
         tstb @#ydir
         beq 3$
         
;         sec
;         sbc y0
;         bcs cont1
         mov r4,r5
         sub r0,r4
         cmp r5,r4
         bcc 1$

;         eor #$ff
;         beq cont12
         comb r4
         beq 12$

;         inc ycut
;cont12   lda rectuly
;         adc #1
;         bcc cont8
         incb @#ycut
12$:     mov r1,r4
         inc r4
         br 8$

;cont3    adc y0
;         bcs cont6
3$:      add r0,r4
         cmpb r4,r0
         bcs 6$

;         cmp #193
;         bcc cont1
         cmpb r4,#193
         bcs 1$

;cont6    lda #192
;         inc ycut
6$:      mov #192,r4
         incb @#ycut

;cont1    sec
;         sbc rectuly
;         bcs cont8
1$:      mov r4,r0
         sub r1,r4
         cmpb r0,r4
         bcc 8$
 
;         eor #$ff
;         adc #1
         neg r4

;cont8    sta y8pos
;         sta y8poscp
8$:      movb r4,@#y8poscp

;         #assign16 adjcell,crsrtile
         mov @#crsrtile,r5
         mov #todata,@#pageport

;         jsr ymove
;         lda ycut
;         bne cont11
         movb @#crsrbit,r0
         call @#ymove
         tstb @#ycut
         bne 11$

;         jsr xmove
;cont11   lda x8poscp
;         sta x8pos
;         lda y8poscp
;         sta y8pos
;         lda crsrbyte
;         sta y8byte
;         lda crsrbit
;         sta x8bit
         call @#xmove
11$:     movb @#x8poscp,r3
         movb @#y8poscp,r4
         movb @#crsrbyte,@#y8byte
         movb @#crsrbit,r0

;         #assign16 adjcell,crsrtile
;         jsr xmove
;         lda xcut
;         bne exit
         mov @#crsrtile,r5
         call @#xmove
         tstb @#xcut
         bne exitdrawrect

;ymove    lda ydir
;         bne loopup
ymove:   tstb @#ydir
         bne loopup

;loopdn   jsr drrect1
;loop10   jsr pixel11
;         iny
;         dec y8pos
;         beq exit
loopdn:  call @#drrect1
10$:     call @#pixel11p
         decb r4
         beq exitdrawrect

;         sty y8byte
;         cpy #8
;         bne loop10
         incb @#y8byte
         cmpb #8,@#y8byte
         bne loopdn

;         ldy #down
;         jsr nextcell
;         lda #0
;         sta y8byte
;         bpl loopdn
         mov down(r5),r5
         clrb @#y8byte
         br loopdn

;loopup   jsr drrect1
;loop11   jsr pixel11
;         dec y8pos
;         beq exit
loopup:  call @#drrect1
11$:     call @#pixel11p
         decb r4
         beq exitdrawrect

;         dey
;         sty y8byte
;         bpl loop11
         decb @#y8byte
         bpl loopup

;         ldy #up
;         jsr nextcell
;         lda #7
;         sta y8byte
;         bpl loopup
         mov up(r5),r5
         movb #7,@#y8byte
         br loopup

;exit     rts
exitdrawrect: return

;xmove    lda xdir
;         bne looplt
xmove:   tstb @#xdir
         bne looplt

;looprt   jsr drrect1
looprt:  call @#drrect1

;loop12   jsr pixel11
;         dec x8pos
;         beq exit
12$:     call @#pixel11p
         decb r3
         beq exitdrawrect

;         lda x8bit
;         lsr
;         bcs nextrt
         bic #65280,r0
         asr r0
         bcc 12$

;         sta x8bit
;         txa
;         lsr
;         tax
;         lda x8bit
;         cmp #8
;         bne loop12
         
;         lda #8
;         tax
;         eor i1
;         sta i1
;         bne loop12

;nextrt   ldy #right
;         jsr nextcell
;         lda #$80
;         sta x8bit
;         bne looprt
         mov right(r5),r5
         movb #128,r0
         br looprt

;looplt   jsr drrect1
;loop15   jsr pixel11
;         dec x8pos
;         beq exit
looplt:  call @#drrect1
15$:     call @#pixel11p
         decb r3
         beq exitdrawrect

;         lda x8bit
;         asl
;         bcs nextlt
         aslb r0
         movb r0,r0
         bcc 15$

;         sta x8bit
;         txa
;         asl
;         tax
;         lda x8bit
;         cmp #16
;         bne loop15

;         ldx #1
;         lda i1
;         sbc #8
;         sta i1
;         bcs loop15

;nextlt   ldy #left
;         jsr nextcell
;         lda #1
;         sta x8bit
;         bne looplt
         mov left(r5),r5
         mov #1,r0
         br looplt

;drrect1  jsr seti1
;         lda x8bit
;         and #$f
;         beq cont14
;         jmp xcont4
drrect1: mov video(r5),r1
         movb @#y8byte,r2
         asr r2
         rorb r2
         rorb r2
         rorb r2
         asl r2
         add r2,r1
         return

;cont14   lda x8bit
;         jmp xcont3

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

crsrset1:
         mov @#crsrtile,r0     ;sets r0,r1
         movb @#crsrbyte,r1
         swab r1
         asr r1
         asr r1
         add video(r0),r1
         movb @#crsrbit,r0
         return

;crsrset0 jsr crsrset1
;         lda vistab,x
;         asl
;         eor (i1),y
;         sta (i1),y
;         rts

;setdirmsk
;         .block
;         jsr JPRIMM
;         .byte 147
;msglen   = 40
;         .ascii "set directory mask ("
;         .byte 28
;         .ascii "enter"
;         .byte 30
;         .ascii " = *)"
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
;         ld hl,(crsrtile)
;         ld (viewport),hl
;         ld ix,vptilecx
        mov #viewport,r3
        mov @#crsrtile,@r3
        mov #vptilecx,r0
        movb @#crsry,r1

;         ld a,2
;         ld (vptilecx),a
;         dec a
;         ld (vptilecy),a
        mov #258,@r0      ;$102

;         ld hl,(ycrsr)
;         ld a,l
;         or h
;         jr nz,cont1
 
;         ld a,(ycrsr+2)
;         cp 8
;         jr nc,cont1
        cmpb r1,#8
        bcc 1$

;         dec (ix+1)
        decb @#vptilecy

;         ld hl,(viewport)      ;up
;         ld de,tilesize*20
;         add hl,de
;         ld (viewport),hl
;         jr cont2
        add #tilesize*20,@r3
        br 2$

;cont1    ld a,(ycrsr)
;         dec a
;         jr nz,cont2

;         ld a,(ycrsr+1)
;         cp 8
;         jr c,cont2
;         jr nz,cont4

;         ld a,(ycrsr+2)
;         cp 4
;         jr c,cont2
1$:     cmpb r1,#184
        bcs 2$

;cont4    inc (ix+1)
;         ld hl,(viewport)      ;down
;         ld de,(~(tilesize*20))+1
;         add hl,de
;         ld (viewport),hl
        incb @#vptilecy
        sub #tilesize*20,@r3

;cont2    ld hl,(xcrsr)
;         ld a,l
;         or h
;         jr nz,cont3

;         ld a,(xcrsr+2)
;         cp 8
;         jr nc,cont3
2$:     movb @#crsrx,r1
        cmpb r1,#8
        bcc 3$

;         dec (ix)
;         dec (ix)
;         ld hl,(viewport)      ;left2
;         ld de,tilesize*2
;         add hl,de
;         ld (viewport),hl
;         jr cont5
        decb @r0
        decb @r0
        add #tilesize*2,@r3
        br 5$

;cont3    ld a,(xcrsr)
;         or a
;         jr nz,cont6

;         ld a,(xcrsr+1)
;         cp 1
;         jr c,cont7
;         jr nz,cont6

;         ld a,(xcrsr+2)
;         cp 6
;         jr nc,cont6
3$:     cmpb r1,#16
        bcc 6$

;cont7    dec (ix)
;         ld hl,(viewport)      ;left1
;         ld de,tilesize
;         add hl,de
;         ld (viewport),hl
;         jr cont5
        decb @r0
        add #tilesize,@r3
        br 5$

;cont6    ld a,(xcrsr)
;         dec a
;         jr nz,cont8

;         ld a,(xcrsr+1)
;         cp 5
;         jr nz,cont8

;         ld a,(xcrsr+2)
;         cp 2
;         jr c,cont8
6$:     cmpb r1,#152
        bcs 8$

;         inc (ix)
;         inc (ix)
;         ld hl,(viewport)      ;right2
;         ld de,(~(tilesize*2))+1
;         add hl,de
;         ld (viewport),hl
;         jr cont5
        incb @r0
        incb @r0
        sub #tilesize*2,@r3
        br 5$

;cont8    ld a,(xcrsr)
;         dec a
;         jr nz,cont5

;         ld a,(xcrsr+1)
;         cp 4
;         jr c,cont5
;         jr nz,cont10

;         ld a,(xcrsr+2)
;         cp 4
;         jr c,cont5
8$:     cmpb r1,#144
        bcs 5$

;cont10   inc (ix)
;         ld hl,(viewport)      ;right1
;         ld de,(~tilesize)+1
;         add hl,de
;         ld (viewport),hl
        incb @r0
        sub #tilesize,@r3

;cont5    ld iy,(viewport)
;         ld hl,fixvp
;         call calllo
;         ld (viewport),hl
5$:     mov @r3,r4
        mov ul(r4),r4
        mov left(r4),@r3

;         ld b,3
;loop12   sla (ix)
;         sla (ix+1)
;         djnz loop12
        asl @r0
        asl @r0
        asl @r0

;         ld a,(crsrbyte)
;         add a,(ix+1)
;         ld (ix+1),a
        movb @#crsrbyte,r1
        swab r1
        add r1,@r0    ;vptilecy

;         ld a,(crsrbit)
;         call calcx
;         add a,(ix)
;         ld (ix),a
;         ret
        movb @#crsrbit,r1
        call @#calcx
        add r1,@r0
        return

crsrset: call @#crsrset1
         tstb @#zoom
         bne gexit2

pixel11: mov #tovideo,@#pageport   ;it should be after crsrset, IN: r0 - crsrbit, r1 - addr of video tile line
         asl r0
         mov vistab(r0),r2
         mov r2,r0
         asl r2
         bis r0,r2
         mov r1,@#crsraddr
         mov @r1,@#crsrdata
         mov r2,@#crsrmask
gexit4:  bis r2,@r1
gexit3:  mov #todata,@#pageport
gexit2:  return

pixel11p:mov #tovideo,@#pageport   ;IN: r0 - crsrbit, r1 - addr of video tile line
         push r0
         asl r0
         mov vistab(r0),r2
         mov r2,r0
         asl r2
         bis r0,r2
         pop r0
         br gexit4

crsrclr: tstb @#zoom
         bne 1$

         mov @#crsrtile,r0
         movb @#crsrbyte,r1
         mov r1,r2
         add r0,r2
         movb @r2,r2
         swab r1
         asr r1
         asr r1
         add video(r0),r1
         tstb @#pseudoc
         bne 2$

         mov #tovideo,@#pageport
         asl r2
         mov vistab(r2),@r1
         br gexit3

2$:      movb @#crsrbyte,r3
         asl r3
         asl r3
         add r0,r3
         bitb #15,@#crsrbit
         bne 3$

         mov count0(r3),r3
         bic #^B1110011100111111,r3
         mov r3,r4
         swab r4
         aslb r4   ;sets CY=0
         bis r3,r4
         rorb r2    ;uses CY=0
         asrb r2
         asrb r2
         asrb r2
4$:      bisb r4,r2
         bic #^B1111111100000000,r2
         mov #tovideo,@#pageport
         movb vistabpc(r2),@r1
         br gexit3

3$:      inc r1
         mov count0+2(r3),r3
         bic #^B1111110011100111,r3
         asl r3
         asl r3
         asl r3
         mov r3,r4
         swab r4
         asl r4
         bis r3,r4
         bic #^B1111111111110000,r2
         br 4$

1$:      clrb @#crsrpgmk
         call @#showscnz
         incb @#crsrpgmk
         ;mov @#crsrtile,r0   ;do not remove! ???
         return

crsrcalc:
        mov @#crsrtile,r0
        mov video(r0),r0     ;start of coorditates calculation
        sub #videostart,r0
        asl r0
        asl r0
        mov r0,@#crsrx
        clr r1
        movb @#crsrbit,r2
10$:    aslb r2
        bcs 8$

        inc r1
        br 10$

8$:     add r1,r0
        clr r1
        cmpb r0,#100
        bcs 1$

        inc r1
        sub #100,r0
1$:     movb r1,@#xcrsr
        clr r1
3$:     cmpb r0,#10
        bcs 2$

        inc r1
        sub #10,r0
        br 3$

2$:     movb r1,@#xcrsr+1
        movb r0,@#xcrsr+2
        swab r0
        movb @#crsrbyte,r2
        add r2,r0
        clr r1
        cmpb r0,#100
        bcs 5$

        inc r1
        sub #100,r0
5$:     movb r1,@#ycrsr
        clr r1
7$:     cmpb r0,#10
        bcs 6$

        inc r1
        sub #10,r0
        br 7$

6$:     movb r1,@#ycrsr+1
        movb r0,@#ycrsr+2
        call @#xyout

        tstb @#zoom
        bne 18$

        return

18$:    mov #up,r1
        movb @#vptilecy,r3
        add #8,r3
        movb @#vptilecy,r2
        bmi 33$

        mov #down,r1
        sub #16,r3
        cmpb r2,#24
        bcs 34$

33$:    movb r3,@#vptilecy
        br 31$

34$:    mov #left,r1
        movb @#vptilecx,r3
        add #8,r3
        movb @#vptilecx,r2
        bmi 35$
 
        mov #right,r1
        sub #16,r3
        cmpb r2,#40
        bcs 30$

35$:    movb r3,@#vptilecx
31$:    add @#viewport,r1
        
;         sta viewport+1
;         sta adjcell+1
;         stx viewport
;         stx adjcell
        mov @r1,r3
        mov r3,@#viewport

;         ldy #down
;         jsr nextcell
;         dey
;         jsr nextcell
        mov dr(r3),r1
        mov dr(r1),r1

;         lda #4
;         sta i2
;loopx    ldy #right
;         jsr nextcell
;         dec i2
;         bne loopx
        mov right(r1),r1
        mov right(r1),r1

;         lda viewport
;         clc
;         adc #<44*tilesize
;         tax
;         lda viewport+1
;         adc #>44*tilesize
;         cmp adjcell+1
;         bne l7

;         cpx adjcell
;         beq cont0
        add #44*tilesize,r3
        cmp r1,r3
        beq 30$

;l7       jsr setviewport
        call @#setviewport

;cont0    jsr showscnz
30$:    jmp @#showscnz

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

chgcolors:
        movb @#palette,r0
        movb #'1,r1
        sub #10,r0
        bpl 14$

        movb #146,r1
        add #10,r0
14$:    add #'0,r0
        movb r1,@#88$
        movb r0,@#88$+1
        jsr r3,@#printstr
        .byte 154,0
2$:     jsr r3,@#printstr
        .byte 12,146
        .ascii "PRESS "
        .byte 145
        .ascii "ENTER"
        .byte 146
        .ascii " TO USE DEFAULT PALETTE OR INPUT DECIMAL NUMBER OF PALETTE ("
88$:    .ascii "  ): "
        .byte 147,0

3$:      mov #stringbuf,r2
         clr r1
1$:      call @#getkey
         cmpb #10,r0
         beq 11$

         cmpb #24,r0    ;backspace=zaboy
         beq 12$

         cmpb r0,#'0+10
         bcc 1$

         cmpb r0,#'0
         bcs 1$

         cmpb #2,r1
         beq 1$

         inc r1
         emt ^O16
         sub #'0,r0
         movb r0,(r2)+
         br 1$

12$:     dec r2
         dec r1
         bmi 3$

         jsr r3,@#printstr
         .byte 8,32,8,0
         br 1$

11$:      tst r1
          beq 20$

          dec r1
          beq 16$

          movb -(r2),r0
          movb -(r2),r1
          mov #10,r2
          cmpb r1,#1
          beq 4$
          bcc 2$

          clr r2
4$:       add r0,r2
          cmp r2,#16
          bcc 2$

24$:     movb r2,@#palette
         swab r2
         asl r2
         mov r2,@#kbddtport
20$:     jsr r3,@#printstr
         .byte 10
         .asciz "TO SAVE THIS CONFIG?"

8$:      call @#getkey
         bis #32,r0
         cmp r0,#'n
         beq 7$

         cmp r0,#'y
         bne 8$

;         jsr savecf
         mov #2,r2
         call @#iocf
7$:      jsr r3,@#printstr
         .byte 154,0
         
         return
          
16$:     movb -(r2),r2
         br 24$

putpixel2:
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
         return

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

setpalette:
         mov #3,r2
         call @#iocf
         movb @#palette,r2
         swab r2
         asl r2
         mov r2,@#kbddtport   ;sets also active video page and enables raster interrupt
         return

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
         ;mov @#yscroll,@#yshift 
         emt ^O24
         mov r3,r1
spt1:    clr r2
         emt ^O20
         ;mov @#yshift,@#yscroll
         ;mov #^O1330,@#yshift
         mov #todata,@#pageport
         return

showtxt:     ;IN: R1 - msg
         mov #toandos,@#pageport
         br spt1

shownum: mov #stringbuf,r0
         mov r0,r2
         mov #stringbuf+10,r1
2$:      cmpb #'0,(r0)+
         bne 1$

         cmp r2,r0
         bne 2$

1$:      dec r0
5$:      cmpb #'0,-(r1)
         bne 4$

         cmp r0,r1
         bne 5$

4$:      cmp r0,#stringbuf+7
         bcs 3$

         mov r0,r5
         sub #stringbuf+7,r5
         sub r5,r0
8$:      movb #'.,(r2)+
7$:      movb (r0)+,(r2)+
         cmp r1,r0
         bcc 7$

         mov #stringbuf,r1
         sub r1,r2
         emt ^O20
         return

3$:      movb (r0)+,(r2)+
         cmp r0,#stringbuf+7
         beq 8$
         br 3$

showbline1:
         jsr r3,@#printstr
         .byte 12
         .asciz "TIME: "
         br shownum

showbline2:
         jsr r3,@#printstr
         .byte 's,10
         .asciz "SPEED: "
         br shownum

