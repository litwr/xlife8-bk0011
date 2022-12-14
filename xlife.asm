;this program doesn't contain code of the original Xlife
;**it is the conversion from 6502 port for Commodore +4 v4
;**and from z80 port for Amstrad CPC6128 v2
;written by litwr, 2014-15
;it is under GNU GPL

         .radix 10
         .dsabl gbl

         .include bk0011m.mac
         .include xlife.mac

         .asect
         .=512

start:   MOV #240*256+240,@#^O120140   ;allows a fast rewrite of a file
         mov #128,@#^O102
         mov #keyirq,@#^O60
         mov #key2irq,@#^O274
         mov @#4,@#saveesc+4
         mov #emptyirq,@#4            ;block HALT-instruction/STOP-key interrupt - it is for buggy emus
         mov #^B0001000010000000,@#pageport ;block STOP-key interrupt
         call @#copyr
         mov #^B10010,@#timerport3    ;start timer, 32 microsec interval
         jsr r3,@#printstr
         .byte 155,154,0,0   ;cursor off, 32 chars

         mov #emptyirq,@#^O100         ;empty timer irq
         mov #3,r2
         call @#setpalette         ;inits also timer interrupt, sets active video page
         incb @#errst
         call @#tograph
         ;call @#calccells
         ;call @#infoout
         mov #crsrirq,@#^O100
         call @#help

crsrflash2: call @#crsrflash
mainloop: call @#dispatcher
         movb @#mode,r0
         beq crsrflash2

         cmpb #3,r0
saveesc: bne 3$        ;this label is used to point to the first argument of the next instruction

         mov #0,@#4    ;restore HALT-instruction/STOP-key interrupt
         ;halt    ;directly to ANDOS?
         jmp @#^O160000

3$:      tst @#tilecnt
         bne 4$

         clrb @#mode
         call @#incgen
         call @#initxt
         call @#showtopology
         call @#xyout
         call @#showscn
         call @#showmode
         br crsrflash2

4$:      cmpb #2,r0
         bne 5$

         call @#generate     ;hide
         call @#cleanup
         br mainloop

5$:      call @#zerocc
         call @#generate
         call @#showscn
         call @#cleanup
         br crsrflash2

         .include vistab.s

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

         .include io.s
         .include ramdisk.s
         .include video-base.s
         .include video.s
         .include utils.s

waitkbd: mov @#kbdstport,r0
         tstb r0
         bpl waitkbd

         mov @#kbddtport,r0
         return

startp:   .word 1
tilecnt:  .word 0
viewport: .word 0
crsrtile: .word tiles
temp:     .word 0
temp2:    .word 0
kbdbuf:   .word 0
saved:    .word 0
lowbench: .word 0
highbench: .word 0
tobin:    .word 1,10,100,1000,10000
live:     .word 12
born:     .word 8

x0:       .byte 0   ;word aligned
y0:       .byte 0
crsrbyte: .byte 0      ;y%8  word aligned
crsrbit:  .byte 128    ;x bit position
i1:       .byte 0,0
cellcnt:  .byte 0,0,0,0,0
gencnt:   .byte 0,0,0,0,0,0,0
crsrx:    .byte 0      ;[x/8]*8, word aligned!
crsry:    .byte 0      ;[y/8]*8
vptilecx: .byte 0      ;word aligned!
vptilecy: .byte 0
xcrsr:    .byte 0,0,0
ycrsr:    .byte 0,0,0
tinfo:    .byte 0,0,0  ;even alignment for BK!
xchgdir:  .byte 0
xdir:     .byte 0      ;linear transformation, word aligned
ydir:     .byte 0
clncnt:   .byte 0
palette:  .byte 0      ;not word aligned???
pseudoc:  .byte 0
mode:     .byte 0      ;0-stop, 1-run, 2-hide, 3-exit
zoom:     .byte 0
fn:       .byte 0,0,0,0,0,0,0,0,0,0,0,0
density:  .byte 3         ;must follow fn
;;dirname  .TEXT "0:"      ;filename used to access directory
fcount:   .byte 0      ;number of file parts
topology: .byte 0      ;0 - torus
crsrticks: .byte 0
;copyleft: .ascii "CR.TXT"
errst:    .byte 0   ;0 - do not print i/o-errors message, 1 - print
ppmode:   .byte 1    ;putpixel mode: 0 - tentative, 1 - active
crsrpgmk: .byte 1   ;0 - do not draw cursor during showscnz, 1 - draw
svfn:     .byte 0,0,0,0,0,0,0,0,0,0,0,0
msghide:  .asciz "HIDE"  ;must follow svfn
msgtore:  .asciz "TORUS"
msgplan:  .asciz "PLAIN"
msgrun:   .asciz "RUN "
msgstop:  .asciz "STOP"
nofnchar: .asciz "?%(),./:;<=>[\]|"   ;? - must be the first

          .odd
stringbuf: .blkb 19       ;it must be at odd addr!

          .include interface.s

benchirq0: mov @#saved,r0
           mov @#timerport2,r1
           mov r1,@#saved
           sub r1,r0
           add r0,@#lowbench
           adc @#highbench
           return

benchirq:  push r0
           push r1
           call @#benchirq0
           pop r1
           pop r0
           rti

crsrflash: return
           nop

crsrirq:   cmp @#plainbox+left,#plainbox   ;test memory bank
           bne emptyirq

           incb @#crsrticks
           bitb #15,@#crsrticks
           bne emptyirq

           mov #95,@#crsrflash     ;95 = $5f = jmp@#
           mov #crsrset2,@#crsrflash+2
           bitb #16,@#crsrticks
           beq emptyirq

           mov #crsrclr2,@#crsrflash+2
emptyirq:  rti

key2irq:   mov @#kbddtport,@#kbdbuf
           incb @#kbdbuf+1
           rti

keyirq:    mov @#kbddtport,@#kbdbuf
           rti

         .include rules.s
         .include tile.s

generate:
         mov @#startp,r0           ;currp=r0
;*loop3
         mov #^B0011111100111111,r3
         mov #^B1100111111001111,r4
         mov #^B1111001111110011,r5
30$:     setcount 0
         setcount 2
         setcount 4
         setcount 6

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
         call @#chkadd

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
         call @#chkadd

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
         call @#chkadd2
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
         call @#chkadd2
12$:     tstb r1
         bpl 14$

         mov r1,r3
         add r4,count5+2(r2)
         add r4,count6+2(r2)
         add r4,count7+2(r2)

;*lexit    jsr chkaddt
14$:     call @#chkaddt

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
         call @#chkadd2

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
         call @#chkadd2

;*rexit    jsr chkaddt
22$:     call @#chkaddt

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
23$:     movb 5(r0),r1
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
         ;*lda #0
         ;*sta (currp),y
1$:
         clrb sum(r0)
         genmac 0
         genmac 1
         genmac 2
         genmac 3
         genmac 4
         genmac 5
         genmac 6
         genmac 7
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
rts2:     return

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

          return

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
4$:       return

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

         .include tab12.s
         .include gentab.s
         .include ramdata.s

         . = 19330           ;16384-((20*24+1)*62-32*1024)
tiles:
         .include initiles.s

         .end
