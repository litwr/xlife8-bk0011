;this program doesn't contain code of the original Xlife
;**it is the conversion from 6502 port for Commodore +4 v4
;**and from z80 port of Amstrad CPC6128 v2
;written by litwr, 2014
;it is under GNU GPL

         .radix 10
         .dsabl gbl

         .include bk0011m.mac
         .include xlife.mac

         .asect
         .=512

start:
         mov #nokbirq,@#kbdstport
         mov #0,@#kbddtport     ;page 1(5) - active video, no timer irq, 0th pal
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
   mov #6,2(r0)
   mov #3,sum(r0)
   mov #1,next(r0)


         jsr pc,@#zerocc
         ;!jsr pc,@#infoout
         ;!jsr pc,@#showrules
         ;!jsr pc,@#crsrset       ;unite with the next!
         ;!jsr pc,@#crsrcalc

mainloop:
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
         ;!jsr pc,@#showscn
         jsr pc,@#cleanup
         br mainloop

         ;;?must be page aligned
vistab:
   .word 0, 1, 4, 5, 16, 17, 20, 21
   .word 64, 65, 68, 69, 80, 81, 84, 85
   .word 256, 257, 260, 261, 272, 273, 276, 277
   .word 320, 321, 324, 325, 336, 337, 340, 341
   .word 1024, 1025, 1028, 1029, 1040, 1041, 1044, 1045
   .word 1088, 1089, 1092, 1093, 1104, 1105, 1108, 1109
   .word 1280, 1281, 1284, 1285, 1296, 1297, 1300, 1301
   .word 1344, 1345, 1348, 1349, 1360, 1361, 1364, 1365
   .word 4096, 4097, 4100, 4101, 4112, 4113, 4116, 4117
   .word 4160, 4161, 4164, 4165, 4176, 4177, 4180, 4181
   .word 4352, 4353, 4356, 4357, 4368, 4369, 4372, 4373
   .word 4416, 4417, 4420, 4421, 4432, 4433, 4436, 4437
   .word 5120, 5121, 5124, 5125, 5136, 5137, 5140, 5141
   .word 5184, 5185, 5188, 5189, 5200, 5201, 5204, 5205
   .word 5376, 5377, 5380, 5381, 5392, 5393, 5396, 5397
   .word 5440, 5441, 5444, 5445, 5456, 5457, 5460, 5461
   .word 16384, 16385, 16388, 16389, 16400, 16401, 16404, 16405
   .word 16448, 16449, 16452, 16453, 16464, 16465, 16468, 16469
   .word 16640, 16641, 16644, 16645, 16656, 16657, 16660, 16661
   .word 16704, 16705, 16708, 16709, 16720, 16721, 16724, 16725
   .word 17408, 17409, 17412, 17413, 17424, 17425, 17428, 17429
   .word 17472, 17473, 17476, 17477, 17488, 17489, 17492, 17493
   .word 17664, 17665, 17668, 17669, 17680, 17681, 17684, 17685
   .word 17728, 17729, 17732, 17733, 17744, 17745, 17748, 17749
   .word 20480, 20481, 20484, 20485, 20496, 20497, 20500, 20501
   .word 20544, 20545, 20548, 20549, 20560, 20561, 20564, 20565
   .word 20736, 20737, 20740, 20741, 20752, 20753, 20756, 20757
   .word 20800, 20801, 20804, 20805, 20816, 20817, 20820, 20821
   .word 21504, 21505, 21508, 21509, 21520, 21521, 21524, 21525
   .word 21568, 21569, 21572, 21573, 21584, 21585, 21588, 21589
   .word 21760, 21761, 21764, 21765, 21776, 21777, 21780, 21781
   .word 21824, 21825, 21828, 21829, 21840, 21841, 21844, 21845

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

gentab:  .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7  ;block 0 - ?page aligned
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7  ;all 7s are free
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 2,2,2,3,2,2,2,2,2,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0  ;last byte is equal to 1st of ttab

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

         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7 ;block 1 = block0 + 256
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 2,2,3,3,2,2,2,2,2,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0  ;last byte is equal to 1st of ctab

ctab:    .byte 0,8,22,36,50,64,72,86,100,114,128,136,150
         .byte 4,18,32,40,54,68,82,96,104,118,132

bittab:  .byte 1,2,4,8,16,32,64,128

         .byte 0,1,0,0,0,0,0,7,7,7   ;free
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7

         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7  ;block 2 = block1 + 256
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 2,2,2,3,2,2,2,2,2,7,7,7,7,7,7,7
         .byte 2,2,2,3,2,2,2,2,2,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0  ;last byte is equal to 1st of vistab

         .byte 0,1,0,0,0,0,0,7,7   ;free   
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,0,1,0,0,0,0,0,7,7,7,7,7,7,7

         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7  ;block 3 = block2 + 256
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 2,2,3,3,2,2,2,2,2,7,7,7,7,7,7,7
         .byte 2,2,3,3,2,2,2,2,2,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0,7,7,7,7,7,7,7
         .byte 0,0,1,1,0,0,0,0,0

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

         ;!.include "interface.s"
         .include tile.s
         .include utils.s
         ;!.include "io.s"
         ;!.include "rules.s"
         ;!.include "ramdisk.s"
         ;!.include "video.s"
         .include tab12.s

;*generate .block
generate:
         ;*#assign16 currp,startp
         mov @#startp,r0           ;currp=r0
;*loop
5$:
         ;*ldy #sum
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
         bic #^B1111111100000000,r1

         ;*beq ldown
         beq 3$

         ;*tax
         ;*ldy #up
         ;*jsr iniadjc
         mov up(r0),r2          ;adjcell=r2, this line replaces iniadjc call!

         ;*clc
         ;*ldy #count+31
         mov #count+30,r4
         add @r2,r4

         ;*jsr fixcnt1e
         jsr pc,@#fixcnt1

         ;*ldy #count+7
         mov #count+6,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

         ;*ldy #count
         mov #count,r4
         add @r0,r4

         ;*jsr fixcnt2
         jsr pc,@#fixcnt2

         ;*jsr chkadd
         jsr pc,@#chkadd

;*ldown:
3$:
         ;*ldy #7
         ;*lda (currp),y
         movb 7(r0),r1            ;top row, later saved at 6502 X
         bic #^B1111111100000000,r1

         ;*beq lleft
         beq 4$

         ;*tax
         ;*ldy #down
         ;*jsr iniadjc
         mov down(r0),r2          ;adjcell=r2

         ;*clc
         ;*ldy #count+3
         mov #count+2,r4
         add @r2,r4

         ;*jsr fixcnt1e
         jsr pc,@#fixcnt1

         ;ldy #count+27
         mov #count+26,r4
         add @r0,r4

         ;jsr fixcnt1
         jsr pc,@#fixcnt1

         ;ldy #count+28
         mov #count+28,r4
         add @r0,r4

         ;jsr fixcnt2
         jsr pc,@#fixcnt2

         ;jsr chkadd
         jsr pc,@#chkadd

;*lleft    ldy #left
4$:
         ;*jsr iniadjc
         mov left(r0),r2          ;adjcell=r2

         ;*ldy #0
         ;*sty t1   ;change indicator
         clr r3

         ;*lda (currp),y
         ;*and #128
         mov @r0,r1               ;2 rows
         tstb r1

         ;*beq ll1
         bpl 6$

         ;*sta t1
         mov r1,r3
 
         ;*ldy #count+3
         ;*#ispyr adjcell
         incb count+3(r2)

         ;*ldy #count+7
         ;*#ispyr adjcell
         incb count+7(r2)

         ;*ldy #ul
         ;*jsr iniadjc2
         mov ul(r0),r5          ;adjcell2=r5

         ;*ldy #count+31
         ;*#ispyr adjcell2
         incb count+31(r5)

         ;*jsr chkadd2
         jsr pc,@#chkadd2

;*ll1      ldy #1
         ;*lda (currp),y
         ;*and #128
6$:      tst r1
         ;*beq ll2
         bpl 7$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+3
         ;*#ispyr adjcell
         incb count+3(r2)

         ;*ldy #count+7
         ;*#ispyr adjcell
         incb count+7(r2)

         ;*ldy #count+11
         ;*#ispyr adjcell
         incb count+11(r2)

;*ll2      ldy #2
         ;*lda (currp),y
         ;*and #128
7$:      mov @2(r0),r1               ;2 rows
         tstb r1

         ;*beq ll3
         bpl 8$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+7
         ;*#ispyr adjcell
         incb count+7(r2)

         ;*ldy #count+11
         ;*#ispyr adjcell
         incb count+11(r2)

         ;*ldy #count+15
         ;*#ispyr adjcell
         incb count+15(r2)

;*ll3      ldy #3
         ;*lda (currp),y
         ;*and #128
8$:      tst r1
         ;*beq ll4
         bpl 9$

         ;*sta t1
         mov r1,r3

         ;ldy #count+11
         ;#ispyr adjcell
         incb count+11(r2)

         ;ldy #count+15
         ;#ispyr adjcell
         incb count+15(r2)

         ;ldy #count+19
         ;#ispyr adjcell
         incb count+19(r2)

;*ll4      ldy #4
         ;*lda (currp),y
         ;*and #128
9$:      mov @4(r0),r1               ;2 rows
         tstb r1

         ;*beq ll5
         bpl 10$

         ;sta t1
         mov r1,r3

         ;ldy #count+15
         ;#ispyr adjcell
         incb count+15(r2)

         ;ldy #count+19
         ;#ispyr adjcell
         incb count+19(r2)

         ;ldy #count+23
         ;#ispyr adjcell
         incb count+23(r2)

;*ll5      ldy #5
         ;*lda (currp),y
         ;*and #128
10$:     tst r1

         ;*beq ll6
         bpl 11$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+19
         ;*#ispyr adjcell
         incb count+19(r2)

         ;*ldy #count+23
         ;*#ispyr adjcell
         incb count+23(r2)

         ;*ldy #count+27
         ;*#ispyr adjcell
         incb count+27(r2)

;*ll6      ldy #6
         ;*lda (currp),y
         ;*and #128
11$:     mov @4(r0),r1               ;2 rows
         tstb r1

         ;*beq ll7
         bpl 12$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+23
         ;*#ispyr adjcell
         incb count+23(r2)

         ;*ldy #count+27
         ;*#ispyr adjcell
         incb count+27(r2)

         ;*ldy #count+31
         ;*#ispyr adjcell
         incb count+31(r2)

;*ll7      ldy #7
         ;*lda (currp),y
         ;*and #128
12$:     tst r1

         ;*beq lexit
         bpl 14$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+27
         ;*#ispyr adjcell
         incb count+27(r2)

         ;*ldy #count+31
         ;*#ispyr adjcell
         incb count+31(r2)

         ;*ldy #dl
         ;*jsr iniadjc2
         mov dl(r0),r5          ;adjcell2=r5

         ;*ldy #count+3
         ;*#ispyr adjcell2
         incb count+3(r5)

         ;*jsr chkadd2
         jsr pc,@#chkadd2

;*lexit    jsr chkaddt
14$:     jsr pc,@#chkaddt

         ;*ldy #right
         ;*jsr iniadjc
         mov right(r0),r2          ;adjcell=r2
         mov #16,r4                ;item to add

         ;*ldy #0
         ;*sty t1   ;change indicator
         clr r3

         ;*lda (currp),y
         mov @r0,r1               ;2 rows

         ;*and #1
         bit #1,r1

         ;*beq lr1
         beq 15$

         ;*sta t1
         mov r1,r3

         ;*ldy #count
         ;*lda #16
         ;*clc
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count(r2)

         ;*lda #16
         ;*ldy #count+4
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+4(r2)

         ;*ldy #ur
         ;*jsr iniadjc2
         mov ur(r0),r5          ;adjcell2=r5

         ;*lda #16
         ;*ldy #count+28
         ;*adc (adjcell2),y
         ;*sta (adjcell2),y
         add r4,count+28(r5)

         ;*jsr chkadd2
         jsr pc,@#chkadd2

;*lr1      ldy #1
         ;*lda (currp),y
         ;*and #1
15$:     bit #^B100000000,r1

         ;*beq lr2
         beq 16$

         ;*sta t1
         mov r1,r3

         ;*ldy #count
         ;*lda #16
         ;*clc
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count(r2)

         ;*lda #16
         ;*ldy #count+4
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+4(r2)

         ;*lda #16
         ;*ldy #count+8
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+8(r2)

;*lr2      ldy #2
         ;*lda (currp),y
16$:     mov 2(r0),r1               ;2 rows
         ;*and #1
         bit #1,r1

         ;*beq lr3
         beq 17$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+4
         ;*lda #16
         ;*clc
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+4(r2)

         ;*lda #16
         ;*ldy #count+8
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+8(r2)

         ;*lda #16
         ;*ldy #count+12
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+12(r2)

;*lr3      ldy #3
         ;*lda (currp),y
         ;*and #1
17$:     bit #^B100000000,r1

         ;*beq lr4
         beq 18$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+8
         ;*lda #16
         ;*clc
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+8(r2)

         ;*lda #16
         ;*ldy #count+12
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+12(r2)

         ;*lda #16
         ;*ldy #count+16
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+16(r2)

;*lr4      ldy #4
         ;*lda (currp),y
18$:     mov 2(r0),r1               ;2 rows
         ;*and #1
         bit #1,r1

         ;*beq lr5
         beq 19$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+12
         ;*lda #16
         ;*clc
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+12(r2)

         ;*lda #16
         ;*ldy #count+16
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+16(r2)

         ;*lda #16
         ;*ldy #count+20
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+20(r2)

;*lr5      ldy #5
         ;*lda (currp),y
         ;*and #1
19$:     bit #^B100000000,r1

         ;beq lr6
         beq 20$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+16
         ;*lda #16
         ;*clc
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+16(r2)

         ;*lda #16
         ;*ldy #count+20
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+20(r2)

         ;*lda #16
         ;*ldy #count+24
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+24(r2)

;*lr6      ldy #6
         ;*lda (currp),y
20$:     mov 6(r0),r1               ;2 rows
         ;*and #1
         bit #1,r1

         ;*beq lr7
         beq 21$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+20
         ;*lda #16
         ;*clc
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+20(r2)

         ;*lda #16
         ;*ldy #count+24
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+24(r2)

         ;*lda #16
         ;*ldy #count+28
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+28(r2)

;*lr7      ldy #7
         ;*lda (currp),y
         ;*and #1
21$:     bit #^B100000000,r1

         ;*beq rexit
         beq 22$

         ;*sta t1
         mov r1,r3

         ;*ldy #count+24
         ;*lda #16
         ;*clc
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+24(r2)

         ;*lda #16
         ;*ldy #count+28
         ;*adc (adjcell),y
         ;*sta (adjcell),y
         add r4,count+28(r2)

         ;*ldy #dr
         ;*jsr iniadjc2
         mov dr(r0),r5          ;adjcell2=r5

         ;*lda #16
         ;*ldy #count
         ;*adc (adjcell2),y
         ;*sta (adjcell2),y
         add r4,count(r5)

         ;*jsr chkadd2
         jsr pc,@#chkadd2

;*rexit    jsr chkaddt
22$:     jsr pc,@#chkaddt

         ;*ldy #6
         ;*lda (currp),y
         bic #^B1111111100000000,r1
 
         ;*beq l2
         beq 23$

         ;*tax
         ;*clc
         ;*ldy #count+23
         mov #count+22,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

         ;*ldy #count+24
         mov #count+24,r4
         add @r0,r4

         ;*jsr fixcnt2
         jsr pc,@#fixcnt2

         ;*ldy #count+31
         mov #count+30,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

;*l2       ldy #5
         ;*lda (currp),y
23$:     movb 5(r0),r1
         bic #^B1111111100000000,r1

         ;*beq l3
         beq 24$

         ;*tax
         ;*clc
         ;*ldy #count+19
         mov #count+18,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

         ;*ldy #count+20
         mov #count+20,r4
         add @r0,r4

         ;*jsr fixcnt2
         jsr pc,@#fixcnt2

         ;*ldy #count+27
         mov #count+26,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

;*l3       ldy #4
         ;*lda (currp),y
24$:     movb 4(r0),r1
         bic #^B1111111100000000,r1

         ;*beq l4
         beq 25$

         ;*tax
         ;*clc
         ;*ldy #count+15
         mov #count+14,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

         ;*ldy #count+16
         mov #count+16,r4
         add @r0,r4

         ;*jsr fixcnt2
         jsr pc,@#fixcnt2

         ;*ldy #count+23
         mov #count+22,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

;*l4       ldy #3
         ;*lda (currp),y
25$:     movb 3(r0),r1
         bic #^B1111111100000000,r1

         ;*beq l5
         beq 26$

         ;*tax
         ;*clc
         ;*ldy #count+11
         mov #count+10,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

         ;*ldy #count+12
         mov #count+12,r4
         add @r0,r4

         ;*jsr fixcnt2
         jsr pc,@#fixcnt2

         ;*ldy #count+19
         mov #count+18,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

;*l5       ldy #2
         ;*lda (currp),y
26$:     movb 2(r0),r1
         bic #^B1111111100000000,r1

         ;*beq l6
         beq 27$

         ;*tax
         ;*clc
         ;*ldy #count+7
         mov #count+6,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

         ;*ldy #count+8
         mov #count+8,r4
         add @r0,r4

         ;*jsr fixcnt2
         jsr pc,@#fixcnt2

         ;*ldy #count+15
         mov #count+14,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

;*l6       ldy #1
         ;*lda (currp),y
27$:     movb 1(r0),r1
         bic #^B1111111100000000,r1

         ;*beq lnext
         beq 28$

         ;*tax
         ;*clc
         ;*ldy #count+3
         mov #count+2,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

         ;*ldy #count+4
         mov #count+4,r4
         add @r0,r4

         ;*jsr fixcnt2
         jsr pc,@#fixcnt2

         ;*ldy #count+11
         mov #count+10,r4
         add @r0,r4

         ;*jsr fixcnt1
         jsr pc,@#fixcnt1

;*lnext    ldy #next
         ;*lda (currp),y
         ;*tax
         ;*iny
         ;*lda (currp),y
28$:     mov next(r0),r0

         ;*bne cont2

         ;cpx #1
         cmp #1,r0

         ;beq stage2
         beq stage2

;*cont2    sta currp+1
         ;*stx currp
         ;*jmp loop
         jmp @#5$

;*stage2   #assign16 currp,startp
         ;*.bend
stage2:  mov @#startp,r0

;*genloop2 ldy #sum
         ;*.block
         ;*lda #0
         ;*sta (currp),y
1$:      
         clrb sum(r0)

         ;*lda pseudoc   ;commented = 5% slower
         tstb @#pseudoc

         ;*beq cont4     ;with no pseudocolor
         beq 2$

         ;ldx #8
         ;lda #0
         ;sta loop8+1
         ;lda #pc
         ;sta mpc+1
;loop8    ldy #0
         ;lda (currp),y
;mpc      ldy #pc
         ;sta (currp),y
         ;inc loop8+1
         ;inc mpc+1
         ;dex
         ;bne loop8

;*cont4    #genmac count,0
2$:      genmac count,0

         ;*#genmac count+4,1
         genmac count+4,1

         ;*#genmac count+8,2
         genmac count+8,2

         ;*#genmac count+12,3
         genmac count+12,3

         ;*#genmac count+16,4
         genmac count+16,4

         ;*#genmac count+20,5
         genmac count+20,5

         ;*#genmac count+24,6
         genmac count+24,6

         ;*#genmac count+28,7
         genmac count+28,7

         ;*ldy #count
         mov #count,r1
         mov #16,r2

         ;*lda #0
;*loop3    sta (currp),y
3$:      clr (r1)+

         ;*iny
         ;*cpy #count+32
         ;*bne loop3
         sob r2,3$

         ;*ldy #next
         ;*lda (currp),y
         ;*tax
         ;*iny
         ;*lda (currp),y
         mov next(r0),r0
         
         ;bne gencont1

         ;*cpx #1
         ;*bne gencont1
         cmp #1,r0
         bne rts2

         jmp @#1$

         ;*.bend

;*rts2     rts
rts2:    rts pc

;*gencont1 sta currp+1
;*         stx currp
;*         jmp genloop2

;*incgen   .block
incgen:
;*          ldy #48
          clr r0
          mov #<gencnt+6>,r1
          movb @r1,r3

;*         #incbcd gencnt+6
          incbcd 1$

;*         sty gencnt+6
          movb r0,@r1

;*         #incbcd gencnt+5
          incbcd 1$

;*         sty gencnt+5
          movb r0,@r1

;*         #incbcd gencnt+4
          incbcd 1$

;*         sty gencnt+4
          movb r0,@r1

;*         #incbcd gencnt+3
          incbcd 1$

;*         sty gencnt+3
          movb r0,@r1

;*         #incbcd gencnt+2
          incbcd 1$

;*         sty gencnt+2
          movb r0,@r1

;*         #incbcd gencnt+1
          incbcd 1$

;*         sty gencnt+1
          movb r0,@r1

;*         #incbcd gencnt
          incbcd 1$

;*         sty gencnt
          movb r0,@r1

;*cont2    rts
;*         .bend
1$:       rts pc

;*cleanup  .block
cleanup:
;*         jsr incgen
         jsr pc,@#incgen

;*         inc clncnt
         incb @#clncnt

;*         lda #15
;*         and clncnt
         bitb #15,@#clncnt

;*         bne rts2
;*         .bend
         bne rts2

;*cleanup0 .block
;*         #assign16 currp,startp
cleanup0: mov @#startp,r0

;*         #zero16 adjcell   ;mark 1st
          clr r2

;*loop     ldy #sum
;*         lda (currp),y
1$:       tstb sum(r0)

;*         beq delel
          beq 2$

;*         ldy #next
;*         lda (currp),y
;*         tax
;*         iny
;*         lda (currp),y
          mov next(r0),r0

;*         bne cont2
;*         cpx #1
;*         bne cont2
          cmp #1,r0
          beq rts2

;*         rts

;*cont2    ldy currp    ;save pointer to previous
;*         sty adjcell
;*         ldy currp+1
;*         sty adjcell+1
         mov r0,r2

;*         sta currp+1
;*         stx currp
;*         jmp loop
         br 1$

;*delel    lda tilecnt
;*         bne l2
;*         dec tilecnt+1
;*l2       dec tilecnt
2$:       dec @#tilecnt

;*         ldy #next
;*         lda (currp),y
;*         sta i1
;*         iny
;*         lda (currp),y
;*         sta i1+1
         mov next(r0),r1

;*         lda #0
;*         sta (currp),y
;*         dey
;*         sta (currp),y
         clr next(r0)

;*         #assign16 currp,i1
         mov r1,r0

;*         lda adjcell
;*         ora adjcell+1
         tst r2

;*         beq del1st
         beq 3$

;*         lda i1
;*         sta (adjcell),y
;*         iny
;*         lda i1+1
;*         sta (adjcell),y
         mov r1,r2

;*         bne loop
;*         lda #1
;*         cmp i1
         cmp #1,r1

;*         bne loop
         bne 1$

;*exit     rts
4$:       rts pc

;*del1st   #assign16 startp,i1
3$:      mov r1,r0

;         lda tilecnt
;         bne loop

;         lda tilecnt+1
         tst @#tilecnt

;         beq exit
         beq 4$

;         jmp loop
;         .bend
         br 1$

startp:   .word 1
tilecnt:  .word 0
viewport: .word 0
crsrtile: .word 0
temp:     .word 0
videobase: .word 16384       ;$4000
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
mode:     .byte 0      ;0-stop, 1-run, 2-hide, 3-exit
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

         . = 15482            ;16384-((20*24+1)*70-32*1024)
tiles:
         .include initiles.s

