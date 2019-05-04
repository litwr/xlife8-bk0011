insteps: call @#totext
         jsr r3,@#printstr
         .byte 154,0
38$:     jsr r3,@#printstr
         .byte 12,146
         .ascii "NUMBER OF GENERATIONS: "
         .byte 147,0,0

3$:      mov #stringbuf,r2
         clr r1
         clr @#temp2
1$:      call @#getkey
         cmpb #10,r0
         beq 11$

         cmpb #3,r0    ;KT (esc)
         bne 16$

20$:     jsr r3,@#printstr
         .byte 154,0
         return

16$:     cmpb #24,r0    ;backspace=zaboy
         beq 12$

         cmpb r0,#'0+10
         bcc 1$

         cmpb r0,#'0
         bcs 1$

         cmpb #5,r1
         beq 1$

         inc r1
         emt ^O16
         sub #'0,r0
         movb r0,(r2)+
         br 1$

12$:     dec r2
         dec r1
         bmi 3$

         mov #24,r0
         emt ^O16
         br 1$

11$:     tst r1
         beq 20$

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
         cmpb #10,r0
         beq 11$

         cmpb #24,r0    ;backspace=zaboy
         beq 12$

         cmp #'0,r5
         beq 40$

         cmpb #3,r0    ;kt/esc
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
         .byte 24,0
         br 1$

inborn:  jsr r3,@#printstr
         .byte 154
         .byte 147
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
         .byte 0,0

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
         .byte 146
         .ascii "SELECT DENSITY OR PRESS "
         .byte 145
         .ascii "KT"
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
         .asciz " - 100%"
         .byte 0
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

inmode:  jsr r3,@#printstr
         .byte 10,10,146
         .ascii "SELECT BENCHMARK MODE"
         .byte 10,32,145,'0,146
         .ascii " - CALCULATIONS"
         .byte 10,32,145,'1,146
         .ascii " - VIDEO"
         .byte 10,32,145,'2,146
         .asciz " - BOTH"
         ;.byte 0
1$:      call @#getkey
         cmpb r0,#'0
         bcs 1$

         cmpb r0,#'3
         bcc 1$

         sub #'1,r0
         return

help:    call @#totext
         add #14,@#yshift
         jsr r3,@#printstr
         .ascii "    "
         .byte 146,159
         .ascii "*** XLIFE COMMANDS ***"
         .byte 159,155,10,9,156,'!,156
         .ascii " randomize screen"
         .byte 10,9,156,'%,156
         .ascii " set random density - default=42%"
         .byte 10,9,156,'+,156,'/,156,'-,156
         .ascii " zoom in/out"
         .byte 10,9,156,'.,156,'/,156,'C,226,'P,156
         .ascii " center/home the cursor"
         .byte 10,9,156,'?,156
         .ascii " show this help"
         .byte 10,9,156,'B,156
         .ascii " benchmark"
         .byte 10,9,156,'C,156
         .ascii " clear screen"
         .byte 10,9,156,'E,156
         .ascii " toggle the pseudocolor mode"
         .byte 10,9,156,'g,156
         .ascii " - the run/stop mode"
         .byte 10,9,156,'h,156
         .ascii " - the hiding (fastest) mode"
         .byte 10,9,156,'l,156
         .ascii " load and transform a pattern"
         .byte 10,9,156,'L,156
         .ascii " reload a pattern"
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
         .ascii " show comments to a pattern"
         .byte 10,9,156,"X",156,"/",156,"Z",156
         .ascii " reload/set&save a palette"
         .byte 10,10,159
         .ascii "Use "
         .byte 159,156
         .ascii "cursor keys"
         .byte 156,159
         .ascii " to set a position and a "
         .byte 159,156
         .ascii "space key"
         .byte 156,159
         .ascii " to toggle the current cell. "
         .ascii "Use "
         .byte 159,156
         .ascii "AP2"
         .byte 156,159
         .ascii " to speed up the movement"
         .byte 159,0,0
         call @#getkey
         jsr r3,@#printstr
         .byte 155,0
         mov #^O1330,@#yshift
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

calcx:   movb @#crsrbit,r1  ;$80 -> 0, $40 -> 1, ...
         bis #65280,r1      ;$ff00, IN: R1, OUT: R1
1$:      add #256,r1
         aslb r1
         bcc 1$

         swab r1
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
          jmp @#crsrset

showscnp: mov @#startp,r0
1$:       call @#showscnp1
          mov next(r0),r0
          cmp #1,r0
          bne 1$
          jmp @#crsrset

showscnp1:mov video(r0),r5
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
          return

14$:      vidmacp count6,384
          swab r1
          bne 16$

          mov #tovideo,@#pageport
          clr 448(r5)
          mov #todata,@#pageport
          return

16$:      vidmacp count7,448
          return

clrscn:   mov #toandos,@#pageport
          mov #16384,r0
          mov #8192,r1
1$:       clr (r0)+
          sob r1,1$
          jmp @#gexit3   ;???

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


chgdrv:  movb @#andos_disk,r0
         bicb #252,r0
         inc r0
         movb r0,@#andos_disk
         movb r0,@#andos_curdsk
         mov r2,r3
         clr r1
         mov r4,r2
         emt ^O24
         add #'A-1,r0
         emt ^O16
         mov r3,r1
         add #2,r1
         emt ^O24
         mov r3,r2
         return

loadmenu:call @#totext
         movb @#andos_disk,r0
         add #'A-1,r0
         movb r0,@#80$+2
         jsr r3,@#printstr
         .byte 12,146
         .ascii "INPUT FILENAME, AN EMPTY STRING MEANS TO SHOW DIRECTORY. PRESS "
         .byte 145
         .ascii "TAB"
         .byte 146
         .ascii " TO USE RAMDISK, "
         .byte 145,'*,146
         .ascii " TO CHANGE DRIVE, "
         .byte 145
         .ascii "KT"
         .byte 146
         .ascii " TO EXIT"
80$:     .byte 10,147,'A,':,154,0   ;toggles cursor!

3$:      mov #fn,r5
         clr r2
1$:      call @#getkey
         cmpb r0,#10
         beq 11$

         cmpb r0,#24   ;zaboy/backspace
         beq 12$

         cmpb r0,#3   ;kt/esc
         bne 17$

100$:    movb r0,r4
101$:    jsr r3,@#printstr
         .byte 154,0
200$:    mtps r4
         return

17$:     cmpb r0,#'*
         bne 21$

         mov #4,r4
         call @#chgdrv
         br 1$

21$:     cmpb #9,r0    ;TAB
         bne 18$

         jsr r3,@#printstr
         .byte 154,0

         call @#ramdisk
         mov #toandos,@#pageport
         mov #1,r4
         br 200$

;cont8    and $7f
;         cp 33
;         jr c,loop1
18$:     cmpb r0,#'!
         bcs 1$

         cmpb r0,#126
         bcc 1$

         mov #nofnchar+1,r3   ;allows ?-char
5$:      cmpb r0,(r3)+
         beq 1$

         cmpb r0,#'a
         bcs 6$

         cmpb r0,#'z+1
         bcc 6$

         sub #'a-'A,r0
6$:      tstb @r3
         bne 5$

         cmp r2,#8
         bcc 1$

         movb r0,(r5)+
         inc r2
         emt ^O16
14$:     br 1$

;cont1    call TXT_REMOVE_CURSOR     ;cursor off
;         ld a,c
;         or a
;         jr z,menu2
11$:     tst r2
         beq menu2

         movb #'.,(r5)+
         movb #'8,(r5)+
         movb #'L,(r5)+
         movb #'0,(r5)+
         clr r4
42$:     cmp r5,#density
         beq 101$

         clrb (r5)+
         br 42$

;cont2    dec de
;         dec c
;         jp m,loop3
;
;         call TXT_REMOVE_CURSOR
;         call printn
;         db 8,32,8,"$"
;         jr cont4
12$:     dec r5
         dec r2
         bmi 3$

         jsr r3,@#printstr
         .byte 24,0
         br 14$

menu2:   call @#setdirmsk
         cmpb #3,r0   ;kt/esc
         beq 100$

;;*         .text "run/stop"
;;*         .byte 30
;;*         .text " and "
;;*         .byte 28
;;*         .text "cbm key"
;;*         .byte 30
;;*         .text " as usual"
;;*         .byte $d,0

         call @#showdir
         swab r5
6$:      clr r1
         clr r2
         emt ^O24
         jsr r3,@#printstr
         .byte 153,146
         .ascii "ENTER FILE# OR "
         .byte 145,'K,'T,146,':,32,147,0,0

3$:      mov #stringbuf+1,r3
         mov r3,r4
         clr r2
1$:      call @#getkey
         cmpb #3,r0     ;kt/esc
         bne 17$

100$:    mov #154,r0
         emt ^O16
         call @#galign
         jmp @#loadmenu

17$:     cmpb #10,r0
         beq 11$

         cmpb #24,r0   ;backspace
         beq 12$

         cmpb r0,#'0
         bcs 1$

         cmpb #'9,r0
         bcs 1$

         cmp #2,r2
         beq 1$

         movb r0,(r3)+
         inc r2
         emt ^O16
         br 1$

11$:     tst r2
         beq 3$

         swab @r4
         dec r2
         bne 21$

         movb #'0,@r4
         swab @r4
21$:     cmp @r4,r5
         bcc 6$

         call @#findfn
         mov #154,r0
         emt ^O16
         clc
         return

12$:     dec r3
         dec r2
         bmi 3$

         mov #24,r0
         emt ^O16
         br 1$

getsvfn: call @#totext
         movb @#andos_disk,r0
         add #'A-1,r0
         movb r0,@#80$
         jsr r3,@#printstr
         .byte 12,146
         .ascii "Enter filename ("
         .byte 145
         .ascii "KT"
         .byte 146
         .ascii " - exit, "
         .byte 145, '*, 146
         .ascii " - drive)"
         .byte 147,10
80$:     .byte 'A,':,154,0,0

3$:      mov #svfn,r5
         clr r2
1$:      call @#getkey
         cmpb r0,#10
         beq 11$

         cmpb r0,#24  ;backspace
         beq 12$

         cmpb r0,#3   ;kt
         bne 17$

100$:    movb r0,r4
101$:    jsr r3,@#printstr
         .byte 154,0
         mtps r4
         return

17$:     cmpb r0,#'*
         bne 18$

         mov #2,r4
         call @#chgdrv
         br 1$

18$:     cmpb r0,#'!
         bcs 1$

         cmpb r0,#126
         bcc 1$

         mov #nofnchar,r3
5$:      cmpb r0,(r3)+
         beq 1$

         cmpb r0,#'a
         bcs 6$

         cmpb r0,#'z+1
         bcc 6$

         sub #'a-'A,r0
6$:      tstb @r3
         bne 5$

         cmp r2,#8
         bcc 1$

         movb r0,(r5)+
         inc r2
         emt ^O16
14$:     br 1$

11$:     tst r2
         beq 100$

         movb #'.,(r5)+
         movb #'8,(r5)+
         movb #'L,(r5)+
         movb #'0,(r5)+
         clr r4
42$:     cmp r5,#msghide
         beq 101$

         clrb (r5)+
         br 42$

12$:     dec r5
         dec r2
         bmi 3$

         jsr r3,@#printstr
         .byte 24,0
         br 14$

showrect: mov #toandos,@#pageport
         clr r1
         mov #19,r2
         emt ^O24

         jsr r3,@#printstr
         .byte 153,146
         .ascii "MOVE, "
         .byte 145,'R,146
         .ascii "OTATE, "
         .byte 145,'F,146
         .ascii "LIP, "
         .byte 145
         .ascii "ENTER"
         .byte 146,',,32,145
         .asciz "KT"
         .byte 0

         clr @#xdir
         clrb @#xchgdir
10$:     call @#drawrect
         call @#showtent
11$:     call @#crsrflash
         call @#getkey2
         cmpb #8,r0    ;cursor left
         beq 100$

         cmpb #25,r0  ;cursor right
         beq 100$

         cmpb #26,r0   ;cursor up
         beq 100$

         cmpb #27,r0   ;cursor down
         beq 100$

         cmpb #'.,r0     ;to center
         beq 100$

         cmpb #12,r0     ;to home
         beq 100$

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
         call @#clrrect
         comb @#xchgdir
         swab @#xdir
         comb @#xdir
         br 10$

1$:      cmpb #'f,r0
         bne 2$

;         jsr clrrect
;         lda xdir
;         eor #1
;         sta xdir
;         bpl loop0
         call @#clrrect
         comb @#xdir
         br 10$

2$:      cmpb #10,r0
         beq exit7

         cmpb #3,r0      ;kt/esc
         sec
         beq exit7
         br 11$

;lselect  pha
;         jsr clrrect
;         pla
;         jsr dispat0
;         jmp loop0
100$:    push r0
         call @#clrrect
         pop r0
         call @#dispat0
         br 10$

xchgxy:  tstb @#xchgdir
         beq exit7

         swab @#x0
exit7:   return


drawrect: call @#xchgxy
         clr @#xcut       ;0 -> xcut,ycut
         movb @#crsrbyte,@#y8byte
         call @#calcx
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

         movb @#crsrbit,r0
         call @#ymove
         tstb @#ycut
         bne 11$

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

loopdn:  call @#drrect1
10$:     call @#pixel11p
         decb r4
         beq exitdrawrect

         incb @#y8byte
         cmpb #8,@#y8byte
         bne loopdn

         mov down(r5),r5
         clrb @#y8byte
         br loopdn

loopup:  call @#drrect1
11$:     call @#pixel11p
         decb r4
         beq exitdrawrect

         decb @#y8byte
         bpl loopup

         mov up(r5),r5
         movb #7,@#y8byte
         br loopup

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
         swab r2
         asr r2
         asr r2
         add r2,r1
exitdrawrect: return

;cont14   lda x8bit
;         jmp xcont3

clrrect:  ;in: x8poscp, y8poscp
         call @#xchgxy
         call @#calcx
         tstb @#xdir
         beq 3$

         sub #8,r1
         comb r1
3$:      add @#x8poscp,r1
         clc
         rorb r1
         asrb r1
         asrb r1
         movb r1,r3
         inc r3
         movb r3,@#x8poscp
         movb @#y8poscp,r4
         movb @#crsrbyte,@#y8byte
         tstb @#pseudoc
         bne clrectpc

         mov @#crsrtile,r5
         tstb @#ydir
         bne loopup2

loopdn2: call @#xclrect2
         beq exitclrect2

         incb @#y8byte
         cmpb #8,@#y8byte
         bne loopdn2

         mov down(r5),r5
         clrb @#y8byte
         br loopdn2

loopup2: call @#xclrect2
         beq exitclrect2

         decb @#y8byte
         bpl loopup2

         mov up(r5),r5
         movb #7,@#y8byte
         br loopup2

xclrect2: push r5
         tstb @#xdir
         bne 2$

1$:      call @#clrect12
         mov right(r5),r5
         sob r3,1$
         br 3$

2$:      call @#clrect12
         mov left(r5),r5
         sob r3,2$

3$:      pop r5
         movb @#x8poscp,r3
         decb r4
exitclrect2: return

clrect12:movb @#y8byte,r1
         mov r1,r2
         swab r1
         asr r1
         asr r1
         add video(r5),r1
         add r5,r2
         movb @r2,r2
         asl r2
         mov #tovideo,@#pageport
         mov vistab(r2),@r1
         jmp @#gexit3

clrectpc:movb @#crsrbyte,r4
         tstb @#ydir
         beq 3$

         sub #8,r4
         comb r4
3$:      movb @#y8poscp,r0
         add r0,r4
         clc
         rorb r4
         asrb r4
         asrb r4
         inc r4
         mov @#crsrtile,r0
         tstb @#ydir
         bne loopuppc

loopdnpc: call @#xclrectpc
         beq exitclrectpc

         mov down(r0),r0
         br loopdnpc

loopuppc: call @#xclrectpc
         beq exitclrectpc

         mov up(r0),r0
         br loopuppc

xclrectpc: push r0
         tstb @#xdir
         bne 2$

1$:      call @#clrect1pc
         mov right(r0),r0
         sob r3,1$
         br 3$

2$:      call @#clrect1pc
         mov left(r0),r0
         sob r3,2$
3$:      pop r0
         movb @#x8poscp,r3
         decb r4
exitclrectpc: return

clrect1pc: push r3
         push r4
         call @#showscnp1
         pop r4
         pop r3
         return

crsrset1:
         mov @#crsrtile,r0     ;sets r0,r1
         movb @#crsrbyte,r1
         swab r1
         asr r1
         asr r1
         add video(r0),r1
         movb @#crsrbit,r0
         return

setdirmsk: jsr r3,@#printstr
         .byte 12,146
         .ascii "SET DIRECTORY MASK ("
         .byte 145
         .ascii "ENTER"
         .byte 146
         .ascii " = *). WILDCARDS USAGE IS THE SAME AS AT IBM PC DOS: "
         .byte 147,0

3$:      mov #stringbuf,r5
         clr r2
1$:      call @#getkey
         cmp #10,r0
         beq 11$

         cmp #24,r0    ;backspace
         beq 12$

         cmp #3,r0     ;kt/esc
         beq 13$

         cmpb r0,#'!
         bcs 1$

         cmpb r0,#126
         bcc 1$

         mov #nofnchar + 1,r3
50$:     cmpb r0,(r3)+
         beq 1$

         cmpb r0,#'a
         bcs 6$

         cmpb r0,#'z+1
         bcc 6$

         sub #'a-'A,r0
6$:      tstb @r3
         bne 50$

         cmp r2,#8    ;fn length limit
         bcc 1$

         movb r0,(r5)+
         inc r2
         emt ^O16
         br 1$

11$:     mov #svfn,r4
         mov r2,r3
         beq 16$

         mov #stringbuf,r5
2$:      cmpb #'*,@r5
         beq 16$

         movb (r5)+,(r4)+
         sob r3,2$

         mov #8,r0
         sub r2,r0
         beq 13$

         mov r0,r3
         movb #32,r0
         br 5$

16$:     mov #8,r0
         sub r2,r0
         add r3,r0
         mov r0,r3
         mov #'?,r0
5$:      movb r0,(r4)+
         sob r3,5$

13$:     return

12$:     dec r5
         dec r2
         bmi 3$

         jsr r3,@#printstr
         .byte 24,0
         br 1$

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

        decb @#vptilecy
        add #tilesize*hormax,@r3  ;up
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

        incb @#vptilecy     ;down
        sub #tilesize*hormax,@r3

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
         bis r2,@r1
gexit3:  mov #todata,@#pageport
gexit2:  return

pixel11p:push r0
         call @#pixel11
         pop r0
         return

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
         mov vistab(r2),r2
5$:      movb @#crsrbit,r3   ;this overcomplicated code is required by cursor flash action
         asl r3
         mov vistab(r3),r3
         mov r3,r4
         asl r4
         bis r4,r3
         mov @r1,r4
         bic r3,r4
         com r3
         bic r3,r2
         bis r2,r4
         mov r4,@r1
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
         call @#8$
         br 5$

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
         call @#8$
         swab r2
         br 5$

1$:      clrb @#crsrpgmk
         call @#showscnz
         incb @#crsrpgmk
         ;mov @#crsrtile,r0   ;do not remove! ???
         return

8$:      bisb r4,r2
         bic #^B1111111100000000,r2
         mov #tovideo,@#pageport
         movb vistabpc(r2),r2
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
        mov @r1,r3
        mov r3,@#viewport
        mov dr(r3),r1
        mov dr(r1),r1
        mov right(r1),r1
        mov right(r1),r1

        add #44*tilesize,r3
        cmp r1,r3
        beq 30$

        call @#setviewport
30$:    jmp @#showscnz

outdec:  clr r4            ;in: r3
         call @#todec
         mov #stringbuf+7,r1
         mov #3,r2
2$:      cmpb #'0,(r1)+
         bne 1$
         sob r2,2$

         inc r2
1$:      dec r1
         emt ^O20
         return

infov:   call @#totext
         mov #146,r0
         emt ^O16
         mov #fn,r3
         tstb @r3
         beq 11$

         jsr r3,@#printstr
         .asciz "Last loaded filename: "
         .byte 0

1$:      movb (r3)+,r0
         emt ^O16
         cmpb #'.,@r3
         bne 1$

11$:     mov #todata,@#pageport
         call @#boxsz
         mov #toandos,@#pageport
         bis r5,r1  ;r5 = boxsz_ymax, this instruction is part of boxsz - but MOV changes ZF
         beq 12$

         jsr r3,@#printstr
         .byte 10
         .asciz "Active pattern size: "
         .byte 0

         push r3
         push r5
         mov r4,r3
         call @#outdec
         mov #'x,r0
         emt ^O16
         mov @#boxsz_cury,r3
         call @#outdec
         jsr r3,@#printstr
         .byte 10
         .ascii "Box life bounds:"
         .byte 10,32,0

         mov @#boxsz_xmin,r3
         call @#outdec
         jsr r3,@#printstr
         .asciz "<=x<="

         pop r3
         call @#outdec

         mov #32,r0
         emt ^O16
         mov @#boxsz_ymin,r3
         call @#outdec
         jsr r3,@#printstr
         .asciz "<=y<="
         pop r3
         call @#outdec
12$:     call @#getkey
         jmp @#tograph

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
         .byte 24,0
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
         mov video(r2),r2
         asl r4
         mov vistab(r4),r4
         swab r3
         asr r3
         asr r3
         add r3,r2
;22$:     cmp r2,#16384
;         bcs 22$

;         cmp r2,#32768
;         bcc 22$

         mov #tovideo,@#pageport
         bic r4,@r2
         asl r4
         bis r4,@r2
         jmp @#gexit3

showtent:mov #toio,@#pageport
         mov #16384+8,r0
         mov @#loaded_sz,r5
         sub #8,r5
         cmp r5,#2560
         bcs 2$

         mov #2560,r5
2$:      asr r5

;         lda x0
;         pha
;         lda y0
;         pha
;         lda #0
;         sta $14
;         sta $15
;         sta ppmode
         push @#x0
         clrb @#ppmode

;loop     lda $15
;         cmp $b9
;         bne l1

;         ldx $14
;         cpx $b8
;         beq exit

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
1$:      mov #toio,@#pageport
         mov (r0)+,@#x0

;         jsr putpixel
         mov #todata,@#pageport
         call @#putpixel

;l3       lda $15
;         eor #$c
;         sta $15
;         inc $14
;         bne loop
;
;         inc $15
;         bne loop
         sob r5,1$

;exit     pla
;         sta y0
;         pla
;         sta x0
;         inc ppmode
;         rts
         pop @#x0
         incb @#ppmode
         return

setpalette:
         mov #3,r2
         call @#iocf
         movb @#palette,r2
         swab r2
         asl r2
         mov r2,@#kbddtport   ;sets also active video page and enables raster interrupt
exit55:  return

crsrclr2: mov #135,@#crsrflash    ;135 = $87 = return
          tstb @#zoom
          bne exit55

          jmp @#crsrclr

crsrset2: mov #135,@#crsrflash    ;135 = $87 = return
          jmp @#crsrset

showtopology:
         mov #27,r1
         mov #2,r2
         mov #msgtore,r3
         tstb @#topology
         beq showptxt

         mov #msgplan,r3
         br showptxt

showmode:
         clr r1
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
         emt ^O24
         mov r3,r1
spt1:    clr r2
         emt ^O20
         jmp @#gexit3

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

