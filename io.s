loadpat: call @#commonin
         mov #fn,r2
         mov #12,r3
1$:      movb (r2)+,(r0)+
         sob r3,1$

         emt ^O36
         tstb @#io_op+1
         bne ioerrjmp

         mov #16384,r4
         mov (r4)+,r0
         movb r0,@#fcount
         mov (r4)+,@#x0
         mov #toio,@#pageport
         mov (r4)+,r0
         mov @r4,r1
         mov r1,r2
         bis r0,r2
         cmp r2,#512
         bcc 3$

         bit #1,r1
         bne 3$

         call @#showrect
         bcs 3$

         mov #toio,@#pageport
         cmp @#live,@#16384+4
         bne 4$

         cmp @#born,@#16384+6
         beq 5$

4$:      mov @#16384+4,@#live
         mov @#16384+6,@#born
         call @#fillrt
5$:      mov #16384+8,r0
9$:      call @#puttent
         decb @#fcount
         bmi 3$

         mov #io_fn+12,r1
8$:      tstb -(r1)
         beq 8$

         incb @r1
         clrb r1   ;io_op=0x100
         emt ^O36
         tstb @#io_op+1
         bne ioerrjmp

10$:     mov #16384,r0
         br 9$

3$:      return

ioerrjmp: jmp @#ioerror

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

;*end      PLA            ; don't return to dir reading loop
;*         PLA
;*         JMP exit

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

commonin:mov #toio,@#pageport
         mov #io_op,r0
         mov r0,r1
         mov #3,(r0)+
         mov #16384,(r0)+
         clr (r0)+
         movb @#curdev,r2
         add #"A:,r2
         mov r2,(r0)+
exit20:  return

showcomm:tstb @#fn
         beq exit20

         call @#totext
         jsr r3,@#printstr
         .byte 155,0
         call @#commonin
         mov #fn,r2
         mov #12,r3
1$:      movb (r2)+,r4
         movb r4,(r0)+
         cmpb #'.,r4
         bne 5$

         movb #'T,(r0)+
         movb #'X,(r0)+
         movb #'T,(r0)+
         sub #3,r3
         add #3,r2
5$:      sob r3,1$
         call @#showtxt0
         jsr r3,@#printstr
         .byte 155,0
         jmp @#tograph

copyr:   call @#commonin
         mov #"CR,(r0)+
         mov #".T,(r0)+
         mov #"XT,(r0)+
         mov #4,r2
1$:      clr (r0)+
         sob r2,1$

showtxt0:emt ^O36
         tstb @#io_op+1
         bne ioerr1

         mov @#loaded_sz,r2
         mov #16384,r1
2$:      mov #toio,@#pageport
         movb (r1)+,r0
         mov #toandos,@#pageport
         emt ^O16
         push r1
1$:      call @#getkey2
         bne 1$
         mov #1000,r1
3$:      sob r1,3$
         pop r1
         sob r2,2$
         jmp @#getkey

ioerror: tstb @#errst
         beq exit20

ioerr1:  mov #toandos,@#pageport
         jsr r3,@#printstr
         .asciz "IO ERROR"
         .byte 0
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

