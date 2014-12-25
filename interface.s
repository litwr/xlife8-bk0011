getkey:  movb @#kbdbuf,r0
         beq getkey

         clrb @#kbdbuf
exit11:  return

dispatcher:
         movb @#kbdbuf,r0
         beq exit11

         mov #12000,r1
1$:      bit #64,@#pageport
         bne 2$

         sob r1,1$
         br dispat0

2$:      clrb @#kbdbuf
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

         tstb @#topology
         beq 84$

         call @#torus
         clrb @#topology
         br 86$

84$:     call @#plain
         incb @#topology
86$:     jmp @#showtopology

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

7$:      cmpb #'?,r0
         bne 8$

         cmpb #2,@#mode
         beq 8$

         jmp @#help

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

11$:     cmpb #'!,r0
         bne 12$

         call @#random
         jmp @#showscn

12$:     cmpb #'%,r0
         bne 14$

         cmpb #2,@#mode
         beq 14$
         jmp @#indens

14$:     cmpb #'B,r0
         beq 159$
         jmp @#15$

159$:    call @#insteps
         mov @#temp2,r0
         beq 142$

         mov r0,@#temp
         clr @#lowbench
         clr @#highbench
         mov #benchirq,@#^O100
         mov #todata,@#pageport
         mov @#timerport2,@#saved
146$:    tst @#tilecnt
         bne 147$

         call @#incgen
         br 148$

147$:    call @#generate
         call @#cleanup
148$:    dec @#temp
         bne 146$

         mov #toandos,@#pageport
         mov #crsrirq,@#^O100
         call @#benchirq0
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

142$:    call @#getkey
         call @#tograph
         call @#zerocc
         jmp @#calccells

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
         mov #6,r0
         mov r1,r5
75$:     cmp r5,#4295
         bcs 154$

         ror r5
         asr r4
         ror r3
         dec r0
         br 75$

154$:    clr r2
157$:    asl r1
         rol r2
         sob r0,157$

         call @#mul5
         call @#mul5
         call @#mul5
156$:    tst r4     ;sets CY=0
         beq 155$

         ror r2
         ror r1
         asr r4
         ror r3
         br 156$

155$:    call @#mul5
         call @#mul5
         call @#mul5
         mov r3,r0     ;r2:r1/r0 in decimal
         clr r3
         clr r4
183$:    sub r0,r2
         bcs 182$

         inc r4
         br 183$

182$:    add r0,r2
153$:    sub r0,r1
         sbc r2
         bcs 150$

         add #1,r3
         adc r4
         br 153$

150$:    clc
         ror r0
         add r0,r1
         bcc 152$
 
         add #1,r3
         adc r4
152$:    call @#todec
         call @#showbline2
         br 142$

15$:     cmpb #'R,r0
         bne 16$

         call @#totext
         call @#inborn
         cmpb #9,r5
         beq 200$

         mov #born,r5
         call @#setrconst
         call @#instay
         mov #live,r5
         call @#setrconst

         call @#fillrt
200$:    call @#tograph
;*         jsr calccells    ;for load sequence
;*         jsr crsrset      ;showscn also calls crsrset! but crsrset is fast now...
;*         jmp crsrcalc
         return

16$:     cmpb #25,r0    ;cursor right
         bne 160$

;*         jsr crsrclr
;*         ldy #right
         call @#crsrclr
         mov #crsrbit,r4
         mov #right,r1

;*         jsr shift
;*         bcc cright
         call @#shift
         beq 80$

;*         lda vptilecx
;*         adc #7
;*         jmp qleft
         add #8,@#vptilecx
         br 273$

;*cright   inc vptilecx
;*         lda crsrbit
;*         cmp #1
;*         beq cxright

;*         lsr crsrbit
;*         jmp cont17u
80$:     incb @#vptilecx
         movb @r4,r0
         cmpb r0,#1
         beq 71$

         rorb @#crsrbit    ;CY=0 by CMPB
         br 273$

;*cxright  lda #$80
;*         bne cm6
71$:    mov #128,r0
        br 72$

160$:    cmpb #8,r0   ;cursor left
         bne 161$

;*         jsr crsrclr
;*         ldy #left
         call @#crsrclr
         mov #crsrbit,r4
         mov #left,r1

;*         jsr shift
;*         bcc cleft
         call @#shift
         beq 81$

;*         lda vptilecx
;*         sbc #8
;*qleft    sta vptilecx
;*         jmp cont17u
         movb @#vptilecx,r0
         sub #8,r0
         movb r0,@#vptilecx
273$:    br 270$

;*cleft    dec vptilecx
;*         lda crsrbit
;*         cmp #$80
;*         beq cxleft

;*         asl crsrbit
;*         jmp cont17u
81$:     decb @#vptilecx
         movb @r4,r0
         cmpb #128,r0
         beq 76$

         aslb @#crsrbit
         br 270$

;*cxleft   lda #1
76$:     mov #1,r0

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
72$:     mov @#crsrtile,r2
         add r1,r2
         cmp @r2,#plainbox
         bne 73$

;*         ldx i2
;*         lda crsrbit,x
;*         sta t1
;*         bcs cm5
         movb @r4,r0
         br 74$
         
;*cm4      sta crsrtile+1
;*         stx crsrtile
;*cm5      lda t1
;*         ldx i2
;*         sta crsrbit,x
;*         jmp cont17u
73$:     mov @r2,@#crsrtile
74$:     movb r0,@r4
         br 270$

161$:    cmpb #26,r0   ;cursor up
         bne 162$

;*         jsr crsrclr
;*         ldy #up
         call @#crsrclr
         mov #crsrbyte,r4
         mov #up,r1

;*         jsr shift
;*         bcc cup
         call @#shift
         beq 82$

;*         lda vptilecy
;*         sbc #8
;*qup      sta vptilecy
;*         jmp cont17u
         sub #8*256,@#vptilecx
         br 270$

;*cup      dec vptilecy
;*         lda crsrbyte
;*         beq cxup
82$:     decb @#vptilecy
         tstb @r4
         beq 77$

;*         dec crsrbyte
;*         jmp cont17u
         decb @r4
         br 270$

;*cxup     lda #7
;*cm3      ldx #1
;*         bpl cm1
77$:     mov #7,r0
         br 72$

162$:    cmpb #27,r0   ;cursor down
         bne 17$

;*         jsr crsrclr
;*         ldy #down
         call @#crsrclr
         mov #crsrbyte,r4
         mov #down,r1

;*         jsr shift
;*         bcc cdown
         call @#shift
         beq 83$

;*         lda vptilecy
;*         adc #7
;*         bcc qup
         add #8*256,@#vptilecx
         br 270$

;*cdown    inc vptilecy
;*         lda crsrbyte
;*         cmp #7
;*         beq cxdown
83$:     incb @#vptilecy
         cmpb #7,@r4
         beq 78$

;*         inc crsrbyte
;*         bne cont17u
         incb @r4
         br 270$

;*cxdown   lda #0
;*         beq cm3
78$:     clr r0
         br 72$

17$:     cmpb #32,r0   ;space
         bne 170$

;*         #assign16 adjcell,crsrtile
         mov @#crsrtile,r2
         movb r0,sum(r2)        ;always writes no-zero value

;*         jsr chkadd
         call @#chkadd

;*         ldy crsrbyte
         movb @#crsrbyte,r0

;*         lda (crsrtile),y
         add r2,r0

;*         eor crsrbit
;*         sta (crsrtile),y
         movb @#crsrbit,r1
         movb @r0,r2
         xor r1,r2
         movb r2,@r0

;*         ldy #sum
;*         and crsrbit
;*         beq lsp1
         bitb r1,r2
         beq 79$
         
;*         jsr inctsum
;*lsp2     sta (crsrtile),y  ;always writes no-zero value, so must be AC != 0
         mov #1,r2
         call @#inctsum

;*         lda zoom
;*         beq lsp3
;*
;*         jsr showscnz
;*lsp3     jsr infoout
;*         jmp cont17u
         call @#infoout
         br 270$

;*lsp1     jsr dectsum
;*         bne lsp2
79$:     call @#zerocc      ;instead of dectsum
         call @#calccells
         br 270$

170$:    cmpb #'.,r0
         bne 171$

;*         jsr crsrclr
         call @#crsrclr

;*         lda #<tiles+(tilesize*249)
;*         sta crsrtile
;*         lda #>tiles+(tilesize*249)
;*         sta crsrtile+1
         mov #tiles+<tilesize*249>,@#crsrtile

;*         lda #1
;*         sta crsrbyte
         mov #1,r1
         movb r1,@#crsrbyte
;*cont17t  sta crsrbit
;*         jsr cont17u
272$:    movb r1,@#crsrbit
         call @#270$

;*         lda zoom
;*         beq exit0
         tstb @#zoom
         beq 100$

;*         jsr setviewport
;*         jsr showscnz
         call @#setviewport
         call @#showscnz

;*cont17u  jsr crsrset
;*         jmp crsrcalc
270$:    call @#crsrset
         jmp @#crsrcalc

171$:    cmpb #12,r0      ;home
         bne 172$

;*         jsr crsrclr
         call @#crsrclr

;*         lda #<tiles
;*         sta crsrtile
;*         lda #>tiles
;*         sta crsrtile+1
         mov #tiles,@#crsrtile

;*         lda #0
;*         sta crsrbyte
         clrb @#crsrbyte

;*         lda #$80
;*         bne cont17t
         mov #128,r1
         br 272$

172$:    cmpb #'l,r0
         bne 173$

;*         lda zoom
;*         pha
;*         beq nozoom1
         movb @#zoom,r0
         push r0
         beq 301$

;*         jsr zoomout
         clrb @#zoom
         
;*nozoom1  jsr totext
;*         jsr loadmenu
;*         beq exitload
301$:    ;call @#totext
         ;call @#loadmenu
         ;beq 302$

;*cont17w  jsr loadpat
;*         jsr scrnorm
303$:    call @#loadpat
         ;call @#scrnorm

;*exitload jsr finish
;*         pla
;*         bne zoomin
302$:    ;call @#finish
         pop r0
         movb r0,@#zoom
         jmp @#showscn

;*exit0    rts


173$:     cmpb #'L,r0
         bne 174$

;*         lda fnlen
;*         bne cont17v

;*         rts
100$:    return

;*cont17v  lda zoom
;*         pha
;*         beq nozoom3

;*         jsr zoomout
;*nozoom3  jsr totext
;*         lda #147
;*         jsr BSOUT
;*         jsr curoff
;*         jmp cont17w

174$:    cmpb #'+,r0
         bne 175$

;*zoomin   jsr crsrclr
;*         jsr savebl     ;sets YR to 255
;*         sty zoom
;*         jsr xclrscn
;*         jsr setviewport
;*         jmp finish
         tstb @#zoom
         bne 100$

         call @#clrscn
         incb @#zoom
         call @#setviewport
271$:    jmp @#tograph0

175$:    cmpb #'-,r0
         bne 176$

         tstb @#zoom
         beq 100$

         clrb @#zoom
         br 271$

176$:    cmpb #'V,r0
         bne 177$

;*         jsr totext
;*         jsr JPRIMM
;*         .byte 144,147,0
;*
;*         jsr curoff
;*         jsr showcomm
;*         jmp finish


177$:    cmpb #'v,r0
         bne 178$

;*         jsr totext
;*         jsr curoff
;*         jsr infov
;*         jmp finish

178$:    cmpb #'Z,r0
         bne 179$

         call @#totext
         call @#chgcolors
220$:    jmp @#tograph

179$:    cmpb #'X,r0
         bne 18$

         call @#totext
         call @#setpalette
         br 220$

18$:     cmpb #'S,r0
         bne 20$

;*         jsr boxsz
;*         beq cont20
;*
;*         jsr totext
;*         jsr getsvfn
;*         beq exitsave

;*         jsr savepat
;*exitsave jmp finish

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
shift:   tstb @#kbdbuf+1
         beq 20$

         mov @#crsrtile,r0
         add r1,r0
         cmp #plainbox,@r0
         beq 20$

         mov @r0,@#crsrtile
20$:     return

