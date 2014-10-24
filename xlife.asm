;this program doesn't contain code of the original Xlife
;**it is the conversion from 6502 port for Commodore +4 v4
;**and from z80 port for Amstrad CPC6128 v2
;written by litwr, 2014
;it is under GNU GPL

         .radix 10
         .dsabl gbl

         .include bk0011m.mac
         .include xlife.mac

         .asect
         .=768

start:
         mov #nokbirq,@#kbdstport
         mov #^O40000,@#kbddtport     ;page 1(5) - active video, no timer irq, 0th pal
         mov #todata,@#pageport
         ;;lda 174     ;current device #
         ;;bne nochg

         ;;lda curdev
;;nochg:
         ;;sta curdev
         ;!jsr pc,@#loadcf
         ;!jsr pc,@#copyr
         ;!jsr pc,@#help
         ;;lda #147
         ;;jsr BSOUT
         ;;jsr TOCHARSET1   ;to caps & graphs
         ;;#iniram
         ;!jsr pc,@setcolor
         ;;lda #"G"-"A"+1
         ;;sta 4032
         ;;lda #"%"
         ;;sta 4050
         ;;lda #"X"-"A"+1
         ;;sta 4063
         ;;lda #"Y"-"A"+1
         ;;sta 4068

         ;*lda #<tiles
         ;*sta crsrtile
         ;*lda #>tiles
         ;*sta crsrtile+1
         mov #tiles,@#crsrtile

   mov #tiles,r0
   mov r0,@#startp
   movb #3,0(r0) ;4
   movb #6,1(r0) ;3
   movb #2,2(r0) ;6
   mov #3,sum(r0)
   mov #1,next(r0)
   mov #1,@#tilecnt

         jsr pc,@#infoout
         ;!jsr pc,@#showrules
         ;!jsr pc,@#crsrset       ;unite with the next!
         ;!jsr pc,@#crsrcalc

mainloop:
         ;;jsr pc,@#waitkbd
         ;!jsr pc,@#dispatcher
         movb @#mode,r0
         beq mainloop

         cmpb #3,r0
         bne 3$

         ;*jmp WARMRESTART
         halt

3$:      tst @#tilecnt
         bne 4$

         clrb @#mode
         br mainloop

4$:      cmpb #2,r0
         bne 5$

         jsr pc,@#generate     ;hide
         jsr pc,@#cleanup
         br mainloop

5$:      jsr pc,@#zerocc
         jsr pc,@#generate
         jsr pc,@#showscn
         jsr pc,@#cleanup
         br mainloop

        .include vistab.s

vistabpc:
   .byte 0, 2, 8, 10, 32, 34, 40, 42, 128, 130, 136, 138, 160, 162, 168, 170
   .byte 0, 1, 8, 9, 32, 33, 40, 41, 128, 129, 136, 137, 160, 161, 168, 169
   .byte 0, 2, 4, 6, 32, 34, 36, 38, 128, 130, 132, 134, 160, 162, 164, 166
   .byte 0, 1, 4, 5, 32, 33, 36, 37, 128, 129, 132, 133, 160, 161, 164, 165
   .byte 0, 2, 8, 10, 16, 18, 24, 26, 128, 130, 136, 138, 144, 146, 152, 154
   .byte 0, 1, 8, 9, 16, 17, 24, 25, 128, 129, 136, 137, 144, 145, 152, 153
   .byte 0, 2, 4, 6, 16, 18, 20, 22, 128, 130, 132, 134, 144, 146, 148, 150
   .byte 0, 1, 4, 5, 16, 17, 20, 21, 128, 129, 132, 133, 144, 145, 148, 149
   .byte 0, 2, 8, 10, 32, 34, 40, 42, 64, 66, 72, 74, 96, 98, 104, 106
   .byte 0, 1, 8, 9, 32, 33, 40, 41, 64, 65, 72, 73, 96, 97, 104, 105
   .byte 0, 2, 4, 6, 32, 34, 36, 38, 64, 66, 68, 70, 96, 98, 100, 102
   .byte 0, 1, 4, 5, 32, 33, 36, 37, 64, 65, 68, 69, 96, 97, 100, 101
   .byte 0, 2, 8, 10, 16, 18, 24, 26, 64, 66, 72, 74, 80, 82, 88, 90
   .byte 0, 1, 8, 9, 16, 17, 24, 25, 64, 65, 72, 73, 80, 81, 88, 89
   .byte 0, 2, 4, 6, 16, 18, 20, 22, 64, 66, 68, 70, 80, 82, 84, 86
   .byte 0, 1, 4, 5, 16, 17, 20, 21, 64, 65, 68, 69, 80, 81, 84, 85

         .include gentab.s

tab3:    .byte 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4
         .byte 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
         .byte 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
         .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
         .byte 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
         .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
         .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
         .byte 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7
         .byte 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
         .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
         .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
         .byte 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7
         .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
         .byte 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7
         .byte 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7
         .byte 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8

ttab:    .byte 0,1,2,3,3,4,5,6,7,8,8,9,16,17,18,19,19,20
         .byte 21,22,23,24,24,25,32,33,34,35,35,36
         .byte 37,38,39,40,40,41,48,49,50,51,51,52
         .byte 53,54,55,56,56,57,64,65,66,67,67,68
         .byte 69,70,71,72,72,73,80,81,82,83,83,84
         .byte 85,86,87,88,88,89,96,97,98,99,99,100
         .byte 101,102,103,104,104,105,112,113,114,115,115,116
         .byte 117,118,119,120,120,121,128,129,130,131,131,132
         .byte 133,134,135,136,136,137,144,145,146,147,147,148
         .byte 149,150,151,152,152,153

ctab:    .byte 0,8,22,36,50,64,72,86,100,114,128,136,150
         .byte 4,18,32,40,54,68,82,96,104,118,132

bittab:  .byte 1,2,4,8,16,32,64,128

digifont:   ;8th columns are free
;      .byte 28,34,50,42,38,34,28, 0 
;      .byte  8,12, 8, 8, 8, 8,28, 0
;      .byte 28,34,16, 8, 4, 2,62, 0
;      .byte 62,32,16,28,32,34,28, 0
;      .byte 16,24,20,18,62,16,16, 0  ;4
;      .byte 62, 2,30,32,32,34,28, 0
;      .byte 24, 4, 2,30,34,34,28, 0
;      .byte 62,32,16, 8, 4, 4, 4, 0  ;7
;      .byte 28,34,34,28,34,34,28, 0
;      .byte 28,34,34,60,32,16,12, 0
;      .byte  0, 0, 0, 0, 0, 0, 0, 0   ;space
      .word  672,2056,2568,2184,2088,2056, 672, 0
      .word  128, 160, 128, 128, 128, 128, 672, 0
      .word  672,2056, 512, 128,  32,   8,2720, 0
      .word 2720,2048, 512, 672,2048,2056, 672, 0
      .word  512, 640, 544, 520,2720, 512, 512, 0
      .word 2720,   8, 680,2048,2048,2056, 672, 0
      .word  640,  32,   8, 680,2056,2056, 672, 0
      .word 2720,2048, 512, 128,  32,  32,  32, 0
      .word  672,2056,2056, 672,2056,2056, 672, 0
      .word  672,2056,2056,2720,2048, 512, 160, 0
      .word  0, 0, 0, 0, 0, 0, 0, 0   ;space

         .even
         ;!.include "interface.s"
         .include tile.s
         .include utils.s
         ;!.include "io.s"
         ;!.include "rules.s"
         ;!.include "ramdisk.s"
         .include video.s
         .include tab12.s

generate:
         mov @#startp,r0           ;currp=r0
;*loop3
         mov #^B0011111100111111,r3
         mov #^B1100111111001111,r4
         mov #^B1111001111110011,r5
30$:     setcount 0,count0
         setcount 2,count2
         setcount 4,count4
         setcount 6,count6

         mov next(r0),r0
         cmp #1,r0
         beq 31$
         jmp @#30$

31$:     mov @#startp,r0
;*loop
5$:         ;*ldy #sum
         ;*lda (currp),y
         tstb sum(r0)

         ;*bne cont3
         bne 1$

         ;*jmp lnext
         jmp @#28$

;*cont3
1$:
         ;*ldy #0		;up
         ;*lda (currp),y
         movb @r0,r1            ;top row, later saved at 6502 X

         ;*beq ldown
         beq 3$

         ;*tax
         ;*ldy #up
         ;*jsr iniadjc
         mov up(r0),r2       ;adjcell=r2, this line replaces iniadjc call!

         ;*clc
         ;*ldy #count7+3
         ;*jsr fixcnt1e
         asl r1
         mov tab1213(r1),r3
         mov tab1011(r1),r4
         add r3,count7+2(r2)
         add r4,count7(r2)

         ;*ldy #count1+3
         ;*jsr fixcnt1
         add r3,count1+2(r0)
         add r4,count1(r0)

         ;*ldy #count
         ;*jsr fixcnt2
         add tab2223(r1),count0+2(r0)
         add tab2021(r1),count0(r0)

         ;*jsr chkadd
         jsr pc,@#chkadd

;*ldown:
3$:
         ;*ldy #7
         ;*lda (currp),y
         movb 7(r0),r1            ;top row, later saved at 6502 X

         ;*beq lleft
         beq 4$

         ;*tax
         ;*ldy #down
         ;*jsr iniadjc
         mov down(r0),r2          ;adjcell=r2

         ;*clc
         ;*ldy #count0+3
         ;*jsr fixcnt1e
         asl r1
         mov tab1213(r1),r3
         mov tab1011(r1),r4
         add r3,count0+2(r2)
         add r4,count0(r2)

         ;ldy #count6+3
         ;jsr fixcnt1
         add r3,count6+2(r0)
         add r4,count6(r0)

         ;ldy #count7
         ;jsr fixcnt2
         add tab2223(r1),count7+2(r0)
         add tab2021(r1),count7(r0)

         ;jsr chkadd
         jsr pc,@#chkadd

;*lleft    ldy #left
4$:
         ;*jsr iniadjc
         mov left(r0),r2          ;adjcell=r2
         mov #1024,r4             ;item to add

         clr r3     ;change indicator
         mov @r0,r1               ;2 rows
         bpl 6$

         mov r1,r3
         add r4,count0+2(r2)
         add r4,count1+2(r2)
         add r4,count2+2(r2)
6$:      tstb r1
         bpl 7$

         mov r1,r3
         add r4,count0+2(r2)
         add r4,count1+2(r2)
         mov ul(r0),r5          ;adjcell2=r5
         add r4,count7+2(r5)
         jsr pc,@#chkadd2         
7$:      mov 2(r0),r1               ;2 rows
         bpl 8$

         mov r1,r3
         add r4,count2+2(r2)
         add r4,count3+2(r2)
         add r4,count4+2(r2)
8$:      tstb r1
         bpl 9$

         mov r1,r3
         add r4,count1+2(r2)
         add r4,count2+2(r2)
         add r4,count3+2(r2)         
9$:      mov 4(r0),r1               ;2 rows
         bpl 10$

         mov r1,r3
         add r4,count4+2(r2)
         add r4,count5+2(r2)
         add r4,count6+2(r2)
10$:     tstb r1
         bpl 11$

         mov r1,r3
         add r4,count3+2(r2)
         add r4,count4+2(r2)
         add r4,count5+2(r2)
11$:     mov 6(r0),r1               ;2 rows
         bpl 12$

         mov r1,r3
         add r4,count6+2(r2)
         add r4,count7+2(r2)
         mov dl(r0),r5          ;adjcell2=r5
         add r4,count0+2(r5)
         jsr pc,@#chkadd2
12$:     tstb r1
         bpl 14$

         mov r1,r3
         add r4,count5+2(r2)
         add r4,count6+2(r2)
         add r4,count7+2(r2)

;*lexit    jsr chkaddt
14$:     jsr pc,@#chkaddt

         ;*ldy #right
         ;*jsr iniadjc
         mov right(r0),r2          ;adjcell=r2
         mov #8,r4                ;item to add

         ;*ldy #0
         ;*sty t1   ;change indicator
         clr r3

         ;*lda (currp),y
         mov @r0,r1               ;2 rows

         ;*and #1
         asr r1

         ;*beq lr1
         bcc 15$

         ;*sta t1
         adc r3

         mov ur(r0),r5          ;adjcell2=r5
         add r4,count7(r5)
         add r4,count0(r2)
         add r4,count1(r2)

         ;*jsr chkadd2
         jsr pc,@#chkadd2

;*lr1      ldy #1
         ;*lda (currp),y
         ;*and #1
         ;*beq lr2
15$:     tstb r1
         bpl 16$

         ;*sta t1
         mov r1,r3
         add r4,count0(r2)
         add r4,count1(r2)
         add r4,count2(r2)

;*lr2      ldy #2
         ;*lda (currp),y
16$:     mov 2(r0),r1               ;2 rows

         ;*and #1
         asr r1

         ;*beq lr3
         bcc 17$

         ;*sta t1
         adc r3
         add r4,count1(r2)
         add r4,count2(r2)
         add r4,count3(r2)

;*lr3      ldy #3
         ;*lda (currp),y
         ;*and #1
17$:     tstb r1

         ;*beq lr4
         bpl 18$

         ;*sta t1
         mov r1,r3
         add r4,count2(r2)
         add r4,count3(r2)
         add r4,count4(r2)

;*lr4      ldy #4
         ;*lda (currp),y
18$:     mov 4(r0),r1               ;2 rows
         ;*and #1
         asr r1

         ;*beq lr5
         bcc 19$

         ;*sta t1
         adc r3
         add r4,count3(r2)
         add r4,count4(r2)
         add r4,count5(r2)

;*lr5      ldy #5
         ;*lda (currp),y
         ;*and #1
19$:     tstb r1

         ;beq lr6
         bpl 20$

         ;*sta t1
         mov r1,r3
         add r4,count4(r2)
         add r4,count5(r2)
         add r4,count6(r2)

;*lr6      ldy #6
         ;*lda (currp),y
20$:     mov 6(r0),r1               ;2 rows
         ;*and #1
         asr r1

         ;*beq lr7
         bcc 21$

         ;*sta t1
         adc r3
         add r4,count5(r2)
         add r4,count6(r2)
         add r4,count7(r2)

;*lr7      ldy #7
         ;*lda (currp),y
         ;*and #1
21$:     tstb r1

         ;*beq rexit
         bpl 22$

         ;*sta t1
         mov r1,r3
         add r4,count6(r2)
         add r4,count7(r2)
         mov dr(r0),r5          ;adjcell2=r5
         add r4,count0(r5)

         ;*jsr chkadd2
         jsr pc,@#chkadd2

;*rexit    jsr chkaddt
22$:     jsr pc,@#chkaddt

         ;*ldy #6
         ;*lda (currp),y
         ;*beq l2
         movb 6(r0),r1
         beq 23$

         asl r1
         mov tab1213(r1),r3
         mov tab1011(r1),r4
         add r3,count7+2(r0)
         add r4,count7(r0)
         add r3,count5+2(r0)
         add r4,count5(r0)
         add tab2223(r1),count6+2(r0)
         add tab2021(r1),count6(r0)

;*l2       ldy #5
         ;*lda (currp),y
         ;*beq l3
23$:     movb 5(r0),r1  ;2 bytes
         beq 24$

         asl r1
         mov tab1213(r1),r3
         mov tab1011(r1),r4
         add r3,count6+2(r0)
         add r4,count6(r0)
         add r3,count4+2(r0)
         add r4,count4(r0)
         add tab2223(r1),count5+2(r0)
         add tab2021(r1),count5(r0)

;*l3       ldy #4
         ;*lda (currp),y
         ;*beq l4
24$:     movb 4(r0),r1
         beq 25$

         asl r1
         mov tab1213(r1),r3
         mov tab1011(r1),r4
         add r3,count5+2(r0)
         add r4,count5(r0)
         add r3,count3+2(r0)
         add r4,count3(r0)
         add tab2223(r1),count4+2(r0)
         add tab2021(r1),count4(r0)

;*l4       ldy #3
         ;*lda (currp),y
         ;*beq l5
25$:     movb 3(r0),r1
         beq 26$

         asl r1
         mov tab1213(r1),r3
         mov tab1011(r1),r4
         add r3,count4+2(r0)
         add r4,count4(r0)
         add r3,count2+2(r0)
         add r4,count2(r0)
         add tab2223(r1),count3+2(r0)
         add tab2021(r1),count3(r0)

;*l5       ldy #2
         ;*lda (currp),y
         ;*beq l6
26$:     movb 2(r0),r1
         beq 27$

         asl r1
         mov tab1213(r1),r3
         mov tab1011(r1),r4
         add r3,count3+2(r0)
         add r4,count3(r0)
         add r3,count1+2(r0)
         add r4,count1(r0)
         add tab2223(r1),count2+2(r0)
         add tab2021(r1),count2(r0)

;*l6       ldy #1
         ;*lda (currp),y
         ;*beq lnext
27$:     movb 1(r0),r1
         beq 28$

         asl r1
         mov tab1213(r1),r3
         mov tab1011(r1),r4
         add r3,count2+2(r0)
         add r4,count2(r0)
         add r3,count0+2(r0)
         add r4,count0(r0)
         add tab2223(r1),count1+2(r0)
         add tab2021(r1),count1(r0)

;*lnext    ldy #next
         ;*lda (currp),y
         ;*tax
         ;*iny
         ;*lda (currp),y
28$:     mov next(r0),r0
         cmp #1,r0
         beq stage2
         jmp @#5$

stage2:  mov @#startp,r0

;*genloop2 ldy #sum
         ;*.block
         ;*lda #0
         ;*sta (currp),y
1$:      
         clrb sum(r0)
         genmac count0,0
         genmac count1,1
         genmac count2,2
         genmac count3,3
         genmac count4,4
         genmac count5,5
         genmac count6,6
         genmac count7,7

         mov next(r0),r0
         cmp #1,r0
         beq incgen
         jmp @#1$

incgen:   mov #<gencnt+6>,r1
          movb @r1,r3
          incbcd rts2
          incbcd rts2
          incbcd rts2
          incbcd rts2
          incbcd rts2
          incbcd rts2
          incbcd rts2
rts2:     rts pc

cleanup:  incb @#clncnt
          bitb #15,@#clncnt
          bne rts2

cleanup0: mov @#startp,r0
          clr r2        ;mark 1st
1$:       tstb sum(r0)

;*         beq delel
          beq 2$

          mov r0,r2     ;save pointer to previous
          mov next(r0),r0

          cmp #1,r0
          bne 1$

          rts pc

;*delel    lda tilecnt
;*         bne l2
;*         dec tilecnt+1
;*l2       dec tilecnt
2$:       dec @#tilecnt

          mov #count0,r1
          add r0,r1
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+
          clr (r1)+

          mov next(r0),r1
          clr next(r0)
          mov r1,r0
          tst r2

;*         beq del1st
          beq 3$

;*         lda i1
;*         sta (adjcell),y
;*         iny
;*         lda i1+1
;*         sta (adjcell),y
         mov r1,next(r2)
         dec r1

;*         bne loop
         bne 1$

;*exit     rts
4$:       rts pc

;*del1st   #assign16 startp,i1
3$:      mov r1,@#startp

;         lda tilecnt
;         bne loop

;         lda tilecnt+1
         tst @#tilecnt

;         beq exit
         beq 4$

;         jmp loop
;         .bend
         br 1$

waitkbd: mov @#kbdstport,r0
         tstb r0
         bpl waitkbd

         mov @#kbddtport,r0
         rts pc

startp:   .word 1
tilecnt:  .word 0
viewport: .word 0
crsrtile: .word 0
temp:     .word 0
cellcnt:  .byte 0,0,0,0,0
gencnt:   .byte 0,0,0,0,0,0,0
xcrsr:    .byte 0,0,0
ycrsr:    .byte 0,0,0
;;tinfo     .byte 0,0,0
xdir:     .byte 0      ;linear transformation
ydir:     .byte 0
x0:       .byte 0
y0:       .byte 0
xchgdir:  .byte 0
clncnt:   .byte 0
pseudoc:  .byte 0
mode:     .byte 1      ;0-stop, 1-run, 2-hide, 3-exit
crsrbit:  .byte 128    ;x bit position
crsrbyte: .byte 0      ;y%8
crsrx:    .byte 0      ;x/4 -  not at pseudographics
crsry:    .byte 0      ;y/8
zoom:     .byte 0
fnlen:    .byte 0
;;fn:       .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dirnlen:  .byte 0
;;dirname  .TEXT "0:"      ;filename used to access directory
;;         .repeat 17,0
;;cfnlen   = live-cfn-3
;;cfn      .text "@0:colors-cf"
live:     .byte 12,0
born:     .byte 8,0
density:  .byte 3
;;eval1    .byte 196,"("              ;str$(ddddddd/dddddd.dd)
;;bencnt   .byte 0,0,0,0,0,0,0,173
;;irqcnt   .byte 0,0,0,0,0,0,".", 0,0,")",0
vptilecx: .byte 0
vptilecy: .byte 0
;;borderpc .byte 40    ;plain
;;bordertc .byte 69    ;torus
palette:  .byte 0
topology: .byte 0      ;0 - torus
copyleft: .ascii /cr.txt/
ppmode:   .byte 1    ;putpixel mode: 0 - tentative, 1 - active
;;curdev   .byte 8
;;svfnlen  .byte 0
;;svfn     .text "@0:"
;;         .repeat 20,0

         . = 19330           ;16384-((20*24+1)*62-32*1024)
tiles:
         .include initiles.s

         .end
