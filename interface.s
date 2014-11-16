getkey:  movb @#kbdstport,r0
         bpl getkey

         mov @#kbddtport,r0
         return

dispatcher:
         movb @#kbdstport,r0
         bmi 1$

         return

1$:      mov @#kbddtport,r0

dispat0: cmpb #'g,r0
         bne 3$

         tstb @#mode
         beq 2$

53$:     decb @#mode
         beq 40$

         call @#initxt
         call @#showtopology
         call @#xyout
         br 40$

2$:      incb @#mode
40$:     jmp @#showmode

3$:      cmpb #'Q,r0
         bne 5$

         movb #3,@#mode
101$:    return

5$:      cmpb #'h,r0
         bne 4$

         cmpb #2,@#mode
         beq 53$

         movb #2,@#mode
         call @#clrscn
         jmp @#showmode

4$:      cmpb #'T,r0
         bne 6$

;*         #chgtopology

6$:      cmpb #'o,r0
         bne 7$

         tstb @#mode
         bne 101$

         tst @#tilecnt
         bne 108$

         call @#incgen
         br 202$

108$:    call @#zerocc
         call @#generate
         call @#showscn
         jmp @#cleanup

;*cont7    cmp #"?"
;*         bne cont8
7$:      cmpb #'?,r0
         bne 8$

         cmpb #2,@#mode
         beq 8$

;*         jsr totext
;*         jsr curoff
         jmp @#help
         ;br 200$ ;finish

8$:      cmpb #'C,r0
         bne 10$

         tst @#tilecnt
         bne 201$

         call @#zerogc
202$:    jmp @#infoout

201$:    jmp @#clear

10$:     cmpb #'E,r0
         bne 11$

         decb @#pseudoc
         beq 111$

         movb #1,@#pseudoc
111$:    jmp @#showscn

;*cont11   cmp #"!"
;*         bne cont12
11$:     cmpb #'!,r0
         bne 12$

;*         jsr random
;*         jmp showscn

;*cont12   cmp #"%"
;*         bne cont14
12$:     cmpb #'%,r0
         bne 14$

           cmpb #2,@#mode
           beq 14$

         jmp @#indens

;*cont14   cmp #"B"-"A"+$c1
;*         bne cont15
14$:     cmpb #'B,r0
         beq 159$
         jmp @#15$

159$:
;*         jsr zerocnt
         call @#insteps
         mov @#temp2,r0
         beq 142$

         mov r0,@#temp
         clr @#lowbench
         clr @#highbench
         mov #benchirq,@#^O100
         mov #todata,@#pageport
         mov @#timerport2,@#saved
         clr @#kbddtport    ;use saved palette!!!, start raster interrupt
146$:    tst @#tilecnt
         bne 147$

         call @#incgen
         br 148$

142$:    call @#getkey
         call @#zerocc
;*         jsr calccells
         jmp @#tograph

147$:    call @#generate
         call @#cleanup
148$:    dec @#temp
         bne 146$

         mov #^O102,@#^O100
         mov #^B100000000000000,@#kbddtport   ;use saved palette!!!, stop raster interrupt
         call @#benchirq0
         mov #toandos,@#pageport
         mov @#lowbench,r0
         mov @#highbench,r1
         asl r0
         rol r1
         asl r0
         rol r1
         mov #125*256,r2
         clr r3
         clr r4
143$:    sub r2,r0
         sbc r1
         bcs 141$

         add #256,r3
         adc r4
         br 143$

141$:    add r2,r0
         adc r1
         swab r2
144$:    sub r2,r0
         sbc r1
         bcs 145$

         add #1,r3
         adc r4
         br 144$

145$:    add #62,r0
         adc r3
         adc r4             ;r4:r3 - time in ms
         call @#todec
         call @#showbline1
         mov @#temp2,r1
         clr r2
         mov #6,r0
157$:    asl r1
         rol r2
         sob r0,157$
         call @#mul5
         call @#mul5
         call @#mul5
156$:    tst r4
         beq 155$

         ror r4
         ror r3
         clc
         ror r2
         ror r1
         br 156$

155$:    call @#mul5
         call @#mul5
         call @#mul5
         mov r3,r0     ;r2:r1/r0 in decimal
         mov r1,r3
         mov r2,r4
         mov #stringbuf,r1
         mov #10,r2
149$:    movb #'0,(r1)+
         sob r2,149$

         mov r1,r2
153$:    sub r0,r3
         sbc r4
         bcs 150$

         call @#incben
         mov r2,r1
         br 153$

150$:    clc
         ror r0
         add r0,r3
         bcc 152$
 
         call @#incben
152$:    call @#showbline2
         br 142$

;*bexit    jsr exitbench
;*         jsr showbench
;*         jsr calcspd
;*qbexit   jsr tograph
;*         jsr zerocc
;*         jsr calccells
;*         ;lda #0
;*         ;sta mode
;*         jmp showscn
;*
;*cont15   cmp #"R"-"A"+$c1
;*         bne cont16
15$:     cmpb #'R,r0
         bne 16$

;*         jsr totext
;*         jsr inborn
;*         cpx #27
;*         beq finish
;*
;*         ldx #2
;*         jsr setrconst
;*         jsr instay
;*         ldx #0
;*         jsr setrconst
;*         jsr fillrt
200$:    ;jsr tograph
;*         jsr calccells    ;for load sequence
         ;call @#clrscn
         ;call @#initxt
         ;call @#showscn
         ;call @#showmode
         ;call @#showtopology
         ;call @#xyout
;*         jsr crsrset      ;showscn also calls crsrset! but crsrset is fast now...
;*         jmp crsrcalc
         return
;*cont16   cmp #$1d   ;cursor right
;*         bne cont16x
16$:     cmpb #25,r0
         bne 160$

;*         jsr crsrclr
;*         ldy #right
;*         jsr shift
;*         bcc cright
;*
;*         lda vptilecx
;*         adc #7
;*         jmp qleft
;*
;*cright   inc vptilecx
;*         lda crsrbit
;*         cmp #1
;*         beq cxright
;*
;*         lsr crsrbit
;*         jmp cont17u
;*
;*cxright  lda #$80
;*         bne cm6
;*
;*cont16x  cmp #$9d   ;cursor left
;*         bne cont16b
160$:    cmpb #8,r0
         bne 161$

;*         jsr crsrclr
;*         ldy #left
;*         jsr shift
;*         bcc cleft
;*
;*         lda vptilecx
;*         sbc #8
;*qleft    sta vptilecx
;*         jmp cont17u
;*
;*cleft    dec vptilecx
;*         lda crsrbit
;*         cmp #$80
;*         beq cxleft
;*
;*         asl crsrbit
;*         jmp cont17u
;*
;*cxleft   lda #1
;*cm6      ldx #0
;*cm1      sta t1
;*         stx i2
;*         lda (crsrtile),y
;*         tax
;*         iny
;*         lda (crsrtile),y
;*         cmp #>plainbox
;*         bne cm4
;*
;*         cpx #<plainbox
;*         bne cm4
;*
;*         ldx i2
;*         lda crsrbit,x
;*         sta t1
;*         bcs cm5
;*
;*cm4      sta crsrtile+1
;*         stx crsrtile
;*cm5      lda t1
;*         ldx i2
;*         sta crsrbit,x
;*         jmp cont17u
;*
;*cont16b  cmp #$91   ;cursor up
;*         bne cont16c
161$:    cmpb #26,r0
         bne 162$

;*         jsr crsrclr
;*         ldy #up
;*         jsr shift
;*         bcc cup
;*
;*         lda vptilecy
;*         sbc #8
;*qup      sta vptilecy
;*         jmp cont17u
;*
;*cup      dec vptilecy
;*         lda crsrbyte
;*         beq cxup
;*
;*         dec crsrbyte
;*         jmp cont17u
;*
;*cxup     lda #7
;*cm3      ldx #1
;*         bpl cm1
;*
;*cont16c  cmp #$11   ;cursor down
;*         bne cont17
162$:     cmpb #27,r0
         bne 17$

;*         jsr crsrclr
;*         ldy #down
;*         jsr shift
;*         bcc cdown
;*
;*         lda vptilecy
;*         adc #7
;*         bcc qup
;*
;*cdown    inc vptilecy
;*         lda crsrbyte
;*         cmp #7
;*         beq cxdown
;*
;*         inc crsrbyte
;*         bne cont17u
;*
;*cxdown   lda #0
;*         beq cm3
;*
;*cont17   cmp #$20   ;space
;*         bne cont17c
17$:     cmpb #32,r0
         bne 170$

;*         #assign16 adjcell,crsrtile
;*         jsr chkadd
;*         ldy crsrbyte
;*         lda (crsrtile),y
;*         eor crsrbit
;*         sta (crsrtile),y
;*         ldy #sum
;*         and crsrbit
;*         beq lsp1
;*
;*         jsr inctsum
;*lsp2     sta (crsrtile),y  ;always writes no-zero value, so must be AC != 0
;*         lda zoom
;*         beq lsp3
;*
;*         jsr showscnz
;*lsp3     jsr infoout
;*         jmp cont17u
;*
;*lsp1     jsr dectsum
;*         bne lsp2
;*
;*cont17c  cmp #"."
;*         bne cont17f
170$:    cmpb #'.,r0
         bne 171$

;*         jsr crsrclr
;*         lda #<tiles+(tilesize*249)
;*         sta crsrtile
;*         lda #>tiles+(tilesize*249)
;*         sta crsrtile+1
;*         lda #1
;*         sta crsrbyte
;*cont17t  sta crsrbit
;*         jsr cont17u
;*         lda zoom
;*         beq exit0
;*
;*         jsr setviewport
;*         jsr showscnz
;*cont17u  jsr crsrset
;*         jmp crsrcalc
;*
;*cont17f  cmp #19        ;home
;*         bne cont17a
171$:    cmpb #12,r0
         bne 172$

;*         jsr crsrclr
;*         lda #<tiles
;*         sta crsrtile
;*         lda #>tiles
;*         sta crsrtile+1
;*         lda #0
;*         sta crsrbyte
;*         lda #$80
;*         bne cont17t
;*
;*cont17a  cmp #"L"-"A"+$41
;*         bne cont17b
172$:    cmpb #'l,r0
         bne 173$

;*         lda zoom
;*         pha
;*         beq nozoom1
;*
;*         jsr zoomout
;*nozoom1  jsr totext
;*         jsr loadmenu
;*         beq exitload
;*
;*cont17w  jsr loadpat
;*         jsr scrnorm
;*exitload jsr finish
;*         pla
;*         bne zoomin
;*
;*exit0    rts
;*
;*cont17b  cmp #"L"-"A"+$c1
;*         bne cont17d
173$:     cmpb #'L,r0
         bne 174$

;*         lda fnlen
;*         bne cont17v
;*
;*         rts
;*
;*cont17v  lda zoom
;*         pha
;*         beq nozoom3
;*
;*         jsr zoomout
;*nozoom3  jsr totext
;*         lda #147
;*         jsr BSOUT
;*         jsr curoff
;*         jmp cont17w
;*
;*cont17d  cmp #"+"
;*         bne cont17e
174$:    cmpb #'+,r0
         bne 175$

;*zoomin   jsr crsrclr
;*         jsr savebl     ;sets YR to 255
;*         sty zoom
;*         jsr xclrscn
;*         jsr setviewport
;*         jmp finish
;*
;*cont17e  cmp #"-"
;*         bne cont17g
175$:    cmpb #'-,r0
         bne 176$

;*zoomout  lda #0
;*         sta zoom
;*         jsr savebl
;*         jmp finish
;*
;*cont17g  cmp #"V"-"A"+$c1
;*         bne cont17h
176$:    cmpb #'V,r0
         bne 177$

;*         jsr totext
;*         jsr JPRIMM
;*         .byte 144,147,0
;*
;*         jsr curoff
;*         jsr showcomm
;*         jmp finish
;*
;*cont17h  cmp #"V"-"A"+$41
;*         bne cont17i
177$:    cmpb #'v,r0
         bne 178$

;*         jsr totext
;*         jsr curoff
;*         jsr infov
;*         jmp finish
;*
;*cont17i  cmp #"Z"-"A"+$c1
;*         bne cont17j
178$:    cmpb #'Z,r0
         bne 179$

;*         jsr totext
;*         jsr chgcolors
;*l2       jsr setcolor
;*         jmp finish
;*
;*cont17j  cmp #"X"-"A"+$c1
;*         bne cont18
179$:    cmpb #'X,r0
         bne 18$

;*         jsr totext
;*         jsr loadcf
;*         bcc l2
;*
;*         jsr showds
;*         bne l2
;*
;*cont18   cmp #"S"-"A"+$c1
;*         bne cont20
18$:     cmpb #'S,r0
         bne 20$

;*         jsr boxsz
;*         beq cont20
;*
;*         jsr totext
;*         jsr getsvfn
;*         beq exitsave
;*
;*         jsr savepat
;*exitsave jmp finish
;*
;*cont20   clc
;*         rts
20$:     return

;*shift    lda $543   ;shift st
;*         beq cont20
;*
;*         lda (crsrtile),y
;*         tax
;*         iny
;*         lda (crsrtile),y
;*         dey
;*         cmp #>plainbox
;*         bne cm4x
;*
;*         cpx #<plainbox
;*         beq cont20
;*
;*cm4x     sta crsrtile+1
;*         stx crsrtile
;*         sec
;*         rts
;*         .bend

;*setbench .block
;*         jsr restbl
;*         lda mode
;*         sta temp+1
;*         lda #2
;*         sta mode
;*         lda #$b
;*         sta $ff06
;*         sei
;*         sta $ff3f
;*         lda #<irqbench
;*         sta $fffe
;*         ldx #<8850  ;0.01 sec
;*         ldy #>8850
;*         lda ntscmask
;*         beq cont1
;*
;*         ldx #<8940
;*         ldy #>8940
;*cont1    stx $ff00
;*         sty $ff01
;*         lda #$a8
;*         sta $ff0a
;*         cli
;*         rts         
;*         .bend
;*
;*exitbench
;*         .block
;*         jsr savebl
;*         lda #$1b
;*         sta $ff06
;*         lda #$a2
;*         sta $ff0a
;*         sta $ff3e
;*         lda temp+1
;*         sta mode
;*         rts         
;*         .bend
;*
;*zerocnt  .block
;*;prepares/zeros benchmark counters
;*         lda #$30
;*         ldy #5
;*loop1    sta irqcnt,y
;*         sta bencnt,y
;*         dey
;*         bpl loop1
;*
;*         sta irqcnt+7
;*         sta irqcnt+8
;*         sta bencnt+6
;*         rts
;*         .bend
;*
