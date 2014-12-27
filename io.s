;*readtent .block
;*         ldy #0
;*         sty $b8
;*         lda #8
;*         sta $b9
;*loop     jsr READSS
;*         bne checkst
;*
;*         jsr BASIN
;*         sta ($b8),y
;*
;*         jsr READSS
;*         bne checkst
;*
;*         lda $b9
;*         pha
;*         eor #4
;*         sta $b9
;*         jsr BASIN
;*         sta ($b8),y
;*         pla
;*         sta $b9
;*         inc $b8
;*         bne l1
;*
;*         inc $b9
;*l1       cmp #>(960+(8*256))
;*         bne loop
;*
;*         lda $b8
;*         cmp #<960
;*         bne loop
;*
;*checkst  lda $b9
;*         eor #8
;*         sta $b9
;*         rts
;*         .bend

loadpat:
;*         lda fnlen
;*         ldx #<fn
;*         ldy #>fn
;*         jsr SETNAM
;*         lda #8
;*         jsr io2
;*         jsr OPEN
;*         ldx #8
;*         jsr CHKIN
;*         bcs error
         mov #toio,@#pageport
         mov #io_op,r0
         mov r0,r1
         mov #3,(r0)+
         mov #16384,r4
         mov r4,(r0)+
         clr (r0)+
         mov #fn,r2
         mov #12,r3
1$:      movb (r2)+,(r0)+
         sob r3,1$

         emt ^O36
         tstb @#io_op+1
         bne 11$

;*         ldy #0
;*loop4    jsr READSS
;*         bne checkst
;*
;*         jsr BASIN
;*         cmp #193
;*         bcs eof
;*
;*         sta x0,y     ;geometry
;*         iny
;*         cpy #2
;*         bne loop4
         mov (r4)+,r0
         movb r0,@#fcount
         mov (r4)+,@#x0

;*         ldy #0
;*loop2    jsr READSS
;*         bne checkst
;*
;*         jsr BASIN
;*         sta $fe8,y   ;live/born
;*         iny
;*         cpy #4
;*         bne loop2
;*
;*         lda $fe9
;*         ora $feb
;*         cmp #2
;*         bcs eof
;*
;*         lda $fea
;*         and #1
;*         bne eof
;*
;*         jsr scrblnk
;*         jsr readtent
;*         jsr showrect
;*         bcs eof
         mov (r4)+,r0
         mov (r4)+,r1
         mov r1,r2
         bis r0,r2
         cmp r2,#512
         bcc 3$

         bit #1,r1
         bne 3$

         ;call @#scrblnk
         ;call @#readtent
         ;call @#showrect
         ;bcs 3$

;*         jsr scrblnk
;*         ldy #3
;*loop1    lda live,y
;*         cmp $fe8,y
;*         bne cont1

;*         dey
;*         bpl loop1
         cmp @#live,@#16384+4
         bne 4$

         cmp @#born,@#16384+6
         beq 5$

4$:      mov @#16384+4,@#live
         mov @#16384+6,@#born
         call @#fillrt

;*cont7    jsr puttent
;*         bcc eof
5$:      ;call @#puttent
         ;bcc 3$

;*loop5    ldy #0
;*loop6    jsr READSS
;*         bne checkst
;*
;*         jsr BASIN
;*         sta x0,y   ;x,y - data
;*         iny
;*         cpy #2
;*         bne loop6
;*
;*         jsr putpixel
;*         jmp loop5
         mov #16384+8,r0
9$:      add #16384,@#loaded_sz
6$:      mov (r0)+,r1
         ;push r0
         mov #todata,@#pageport
         call @#putpixel
         mov #toio,@#pageport
         ;pop r0
         cmp r0,@#loaded_sz
         bne 6$

         decb @#fcount
         bmi 3$

         mov #io_fn+12,r1
8$:      tstb -(r1)
         beq 8$

         inc @r1
         emt ^O36
         tstb @#io_op+1
         bne 11$

10$:     mov #16384,r0
         br 9$

11$:     jmp @#ioerror

3$:      mov #todata,@#pageport
         ;call @#tograph
         return     

;*showdir  .block
;*         jsr dirop1
;*         BCS error
;*
;*         LDY #6
;*skip6    JSR getbyte    ; get a byte from dir and ignore it
;*         DEY
;*         BNE skip6
;*
;*         lda #$9c
;*         jsr BSOUT
;*loop1    jsr getbyte
;*         beq cont5
;*
;*         jsr BSOUT
;*         jmp loop1
;*
;*cont5    lda #$d
;*         jsr BSOUT
;*next     LDY #2         ; skip 2 bytes on all other lines
;*skip2    JSR getbyte    ; get a byte from dir and ignore it
;*         DEY
;*         BNE skip2
;*
;*         JSR getbyte    ; get low byte of filesize
;*         sta fileszlo
;*         JSR getbyte    ; get high byte
;*         sta fileszhi
;*         jsr getbyte
;*         cmp #$42
;*         beq prfree
;*
;*         jsr printmi
;*         beq exit
;*
;*         lda #2
;*         sta quotest
;*         LDA #$20       ;print a space first
;*char     cmp #$22       ;quote
;*         bne cont1
;*
;*         dec quotest
;*         beq cont4
;*
;*cont1    ldx quotest
;*         beq cont3
;*
;*         cpx #2
;*         beq cont3
;*
;*cont4    JSR BSOUT
;*cont3    JSR getbyte
;*         BNE char       ; continue until end of line
;*
;*         jsr printsz
;*         JSR STOP       ; RUN/STOP pressed?
;*         BNE next       ; no RUN/STOP -> continue
;*         beq exit
;*
;*error    jsr showds
;*exit     jmp endio
;*
;*getbyte  JSR READSS
;*         BNE end
;*
;*         JMP BASIN
;*
;*end      PLA            ; don't return to dir reading loop
;*         PLA
;*         JMP exit
;*
;*prfree   jsr JPRIMM
;*         .byte 144,0
;*         lda fileszhi
;*         ldx fileszlo
;*         jsr INT2STR
;*         lda #$ff
;*         sta quotest
;*         jsr JPRIMM
;*         .byte 32,0
;*         lda #$42
;*         bne cont4
;*         .bend
;*
;*menucnt  = $ffb
;*quotest  = $ffe
;*fileszhi = $ffd
;*fileszlo = $ffc
;*
;*printmi  .block
;*         lda #28
;*         jsr BSOUT
;*         ldx menucnt
;*         cpx #100
;*         bcs cont
;*
;*         cpx #10
;*         bcs cont2
;*
;*         lda #32
;*         jsr BSOUT
;*cont2    lda #32
;*         jsr BSOUT
;*
;*cont     lda #0
;*         jsr INT2STR
;*         jsr JPRIMM
;*         .byte 144,32,0
;*         inc menucnt
;*         rts
;*         .bend
;*
;*skipln  .block
;*        JSR READSS
;*        BNE end
;*
;*        jsr BASIN
;*        DEY
;*        BNE skipln
;*
;*char    JSR READSS
;*        BNE end
;*
;*        jsr BASIN
;*        BNE char       ; continue until end of line
;*
;*end     rts
;*        .bend
;*
;*printsz .block
;*        lda quotest
;*        bmi exit
;*
;*        jsr JPRIMM
;*        .byte 32,31,0
;*        lda fileszhi
;*        ldx fileszlo
;*        JSR INT2STR
;*        lda #144
;*        jsr BSOUT
;*exit    lda #$d
;*        jmp BSOUT
;*        .bend
;*
;*dirop1   LDA dirnlen
;*         LDX #<dirname
;*         LDY #>dirname
;*         JSR SETNAM
;*         LDA #8
;*         LDY #0         ; secondary address 0 (required for dir reading!)
;*         sty menucnt
;*         jsr io1
;*         jsr OPEN
;*         bcs error1     ; quit if OPEN failed
;*
;*         LDX #8         ; filenumber 8
;*         JSR CHKIN
;*error1   rts
;*
;*findfn   .block         ;fn# is at $14-15
;*         jsr dirop1
;*         BCS error
;*
;*         LDY #6
;*         jsr skipln
;*         bne error
;*
;*         lda $14
;*         beq next
;*
;*loop0    ldy #4
;*         jsr skipln
;*         bne exit
;*
;*         dec $14
;*         bne loop0
;*
;*next     LDY #4
;*skip2    JSR getbyte    ; get a byte from dir and ignore it
;*         DEY
;*         BNE skip2
;*
;*         lda #2
;*         sta quotest
;*char     cmp #$22       ;quote
;*         bne cont1
;*
;*         dec quotest
;*         beq exit
;*         bne cont3
;*
;*cont1    ldx quotest
;*         cpx #2
;*         beq cont3
;*
;*cont4    ldy menucnt
;*         sta fn,y
;*         inc menucnt
;*cont3    JSR getbyte
;*         BNE char       ; continue until end of line
;*         beq exit
;*
;*error    jsr showds
;*exit     lda menucnt
;*         sta fnlen
;*         jmp endio
;*
;*getbyte  JSR READSS
;*         BNE end
;*
;*         JMP BASIN
;*
;*end      PLA            ; don't return to dir reading loop
;*         PLA
;*         JMP exit
;*         .bend
;*
;*savepat  .block
;*sizex    = adjcell2
;*sizey    = adjcell2+1
;*xmin     = i1
;*ymin     = i1+1
;*curx     = adjcell
;*cury     = adjcell+1
;*         lda #8
;*         jsr io2
;*         ldy svfnlen
;*         lda #","
;*         sta svfn+3,y
;*         sta svfn+5,y
;*         lda #"u"
;*         sta svfn+4,y
;*         lda #"w"
;*         sta svfn+6,y
;*         tya
;*         clc
;*         adc #7
;*         ldx #<svfn
;*         ldy #>svfn
;*         jsr SETNAM
;*         jsr OPEN
;*         bcs error
;*
;*         ldx #8
;*         jsr CHOUT    ;open channel for write
;*         bcs error
;*
;*         jsr READSS
;*         bne error
;*
;*         lda sizex
;*         jsr BSOUT
;*         jsr READSS
;*         bne error
;*
;*         lda sizey
;*         jsr BSOUT
;*         ldy #0
;*loop1    jsr READSS
;*         bne error
;*
;*         lda live,y
;*         jsr BSOUT
;*         iny
;*         cpy #4
;*         bne loop1
;*
;*         lda #0
;*         sta curx
;*         sta cury
;*         lda #<tiles ;=0
;*         sta currp
;*         lda #>tiles
;*         sta currp+1
;*loop0    ldy #0
;*loop2    sei
;*         sta $ff3f
;*         lda (currp),y
;*         sta $ff3e
;*         cli
;*         bne cont1
;*
;*loop4    iny
;*         cpy #8
;*         bne loop2
;*
;*         jsr inccurrp
;*         inc curx
;*         ldx curx
;*         cpx #20
;*         bne loop0
;*
;*         ldx #0
;*         stx curx
;*         inc cury
;*         ldy cury
;*         cpy #24
;*         bne loop0
;*         beq eof
;*
;*error    jsr CLRCH
;*         jsr showds
;*eof      jmp endio
;*
;*cont1    ldx #$ff
;*loop3    inx
;*         asl
;*         bcs cont4
;*         beq loop4
;*         bcc loop3
;*
;*cont4    sta i2
;*         stx t1
;*         jsr READSS
;*         bne error
;*
;*         lda curx
;*         asl
;*         asl
;*         asl
;*         adc t1
;*         sec
;*         sbc xmin
;*         jsr BSOUT
;*         jsr READSS
;*         bne error
;*
;*         sty t1
;*         lda cury
;*         asl
;*         asl
;*         asl
;*         adc t1
;*         sec
;*         sbc ymin
;*         jsr BSOUT
;*         lda i2
;*         jmp loop3
;*         .bend
;*
;*showcomm .block
;*         ldx fnlen
;*         bne cont2
;*
;*         rts
;*
;*cont2    lda #"#"
;*         cpx #16
;*         beq cont1
;*
;*         inx
;*cont1    sta fn-1,x
;*         ;lda #","     ;check file type
;*         ;inx
;*         ;sta fn-1,x
;*         ;lda #"s"
;*         ;inx
;*         ;sta fn-1,x
;*         txa
;*         ldx #<fn
;*         ldy #>fn
;*         .bend

;*showtxt  .block
;*         jsr SETNAM
;*         lda #8
;*         jsr io2
;*         jsr OPEN
;*         ldx #8
;*         jsr CHKIN
;*         bcs error
;*
;*         lda #8
;*         jsr set_ntsc
;*         jsr TOCHARSET2  ;to smalls & caps
;*         ;jsr PRIMM
;*         ;db 9,$e,0
;*
;*loop6    jsr READSS
;*         bne checkst
;*
;*         jsr BASIN
;*         bne cont2
;*
;*         JSR STOP       ; RUN/STOP pressed?
;*         beq eof
;*
;*         lda #$d
;*cont2    jsr BSOUT
;*         jmp loop6
;*
;*checkst  cmp #$40
;*         beq eof

copyr:   mov #toio,@#pageport
         mov #io_op,r0
         mov r0,r1
         mov #3,(r0)+
         mov #16384,(r0)+
         clr (r0)+
         mov #"CR,(r0)+
         mov #".T,(r0)+
         mov #"XT,(r0)+
         mov #5,r2
1$:      clr (r0)+
         sob r2,1$

         emt ^O36
         tstb @#io_op+1
         bne ioerr1

         mov @#loaded_sz,r2
         mov #16384,r1
2$:      mov #toio,@#pageport
         movb (r1)+,r0
         mov #toandos,@#pageport
         emt ^O16
         sob r2,2$

         call @#getkey
exit20:  return

ioerror: tstb @#errst
         beq exit20

ioerr1:  jsr r3,@#printstr
         .byte 10
         .asciz "IO ERROR"
         jmp @#getkey

iocf:    mov #io_op,r0    ;IN: R2 - 2/3 - write/read
         mov r0,r1
         mov r2,(r0)+
         mov #palette,(r0)+
         mov #1,(r0)+
         mov #"CO,(r0)+
         mov #"LO,(r0)+
         mov #"RS,(r0)+
         mov #".C,(r0)+
         mov #"FG,(r0)+
         clr @r0
         emt ^O36
         tstb @#io_op+1
         beq exit20

         jmp @#ioerror

