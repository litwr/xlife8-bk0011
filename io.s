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
         bcc exitio

         bit #1,r1
         bne exitio

         call @#showrect
         bcs exitio

         mov #toio,@#pageport
         cmp @#live,@#16384+4
         bne 4$

         cmp @#born,@#16384+6
         beq 5$

4$:      mov @#16384+4,@#live
         mov @#16384+6,@#born
         mov #todata,@#pageport
         call @#fillrt
5$:      mov #16384+8,r0
9$:      call @#puttent
         decb @#fcount
         bmi exitio

         mov #io_fn+14,r1
8$:      tstb -(r1)
         beq 8$

         incb @r1
         clrb r1   ;io_op=0x100
         mov #toio,@#pageport
         emt ^O36
         tstb @#io_op+1
         bne ioerrjmp

10$:     mov #16384,r0
         br 9$

exitio:  return

ioerrjmp: jmp @#ioerror

showdir: jsr r3,@#printstr
         .byte 12,10,0,0

         mov @#andos_init,r1
         call @r1
         mov #"00,r5
         clr r0
1$:      mov #svfn,r3
         mov @#andos_diren2,r1
         call @r1
         beq exitio

         cmp #"8L,8(r4)
         bne 1$

         cmpb #'0,10(r4)
         bne 1$

         mov #8,r2
         mov r4,r1
3$:      cmpb @r3,(r1)+
         beq 2$

         cmpb #'?,@r3
         bne 1$

2$:      inc r3
         sob r2,3$

         mov #stringbuf,r3
         movb #145,(r3)+
         mov r5,(r3)+
         mov #32*256+146,(r3)+
         mov #8,r2
         mov r4,r1
4$:      movb (r1)+,(r3)+
         sob r2,4$

         mov #147*256+32,r2
         mov r2,(r3)+
         add #256,r5
         cmp r5,#<'9+1>*256
         bcs 15$

         add #246*256+1,r5
15$:     mov 28(r4),r1
         cmp #16384,r1
         beq 16$

         bit #^B1111111111,r1
         beq 17$

         add #^B10000000000,r1
17$:     swab r1
         asrb r1
         asrb r1
         cmpb r1,#10
         bcc 20$

         add #'0,r1
         movb r1,(r3)+
         movb r2,(r3)+
         br 23$

20$:     add #'0-10,r1
         movb #'1,(r3)+
         movb r1,(r3)+
23$:     movb r2,(r3)+
         br 21$

16$:     mov #"16,(r3)+
         movb #'+,(r3)+
21$:     bit #256,r5
         bne 22$

         mov #10,r2
22$:     movb r2,(r3)+
         mov #stringbuf,r1
         mov #19,r2
         emt ^O20
         br 1$

findfn:  mov @#andos_init,r1
         call @r1
         mov @#stringbuf+1,r5
         sub #48*256+48,r5
         clr r0
1$:      mov #svfn,r3
         mov @#andos_diren2,r1
         call @r1
         beq exitio

         cmp #"8L,8(r4)
         bne 1$

         cmpb #'0,10(r4)
         bne 1$

         mov #8,r2
         mov r4,r1
3$:      cmpb @r3,(r1)+
         beq 2$

         cmpb #'?,@r3
         bne 1$

2$:      inc r3
         sob r2,3$

         tst r5
         beq 5$

         sub #256,r5
         bpl 1$

         add #2559,r5   ;$9ff
         br 1$

5$:      mov #fn,r5
         mov #8,r2
8$:      movb (r4)+,r1
         cmpb r1,#32
         beq 7$

         movb r1,(r5)+
         sob r2,8$

7$:      movb #'.,(r5)+
         movb #'8,(r5)+
         movb #'L,(r5)+
         movb #'0,(r5)+
         tst r2
         beq 11$

6$:      clrb (r5)+
         sob r2,6$
11$:     return

savepat: call @#commonin
         dec @#io_op
         mov #svfn,r2
         mov #12,r3
1$:      movb (r2)+,(r0)+
         sob r3,1$

         mov #16384,r2
         mov @#lowbench,r0
         asl r0
         add #7,r0
         rol r0
         rol r0
         rol r0
         bic #65532,r0
         mov r0,(r2)+         ;number of blocks
         movb @#boxsz_curx,(r2)+    ;sizex
         movb @#boxsz_cury,(r2)+    ;sizey
         mov @#live,(r2)+
         mov @#born,(r2)+
         mov #tiles,r4
         clr @#boxsz_curx
         clr @#boxsz_cury
         mov #4,@#io_len
0$:      mov #8,r5
2$:      mov #todata,@#pageport
         movb (r4)+,r0
         bne 11$
4$:      sob r5,2$

         add #tilesize-8,r4
         inc @#boxsz_curx
         cmp #hormax,@#boxsz_curx
         bne 0$

         clr @#boxsz_curx
         inc @#boxsz_cury
         cmp #vermax,@#boxsz_cury
         bne 0$
         br 20$

11$:     mov #65535,r1
3$:      inc r1
         aslb r0
         bcs 14$
         beq 4$
         br 3$

14$:     mov @#boxsz_curx,r3
         asl r3
         asl r3
         asl r3
         add r1,r3
         sub @#boxsz_xmin,r3
         mov #toio,@#pageport
         movb r3,(r2)+
         mov @#boxsz_cury,r3
         asl r3
         asl r3
         asl r3
         add #8,r3
         sub r5,r3
         sub @#boxsz_ymin,r3
         movb r3,(r2)+
         inc @#io_len
         cmp #8192,@#io_len
         bne 3$

20$:     asl @#io_len
         beq exit20

21$:     push r1
         mov #io_op,r1
         mov #toio,@#pageport
         emt ^O36
         pop r1
         clr @#io_len
         tstb @#io_op+1
         bne ioerr1   ;????

         cmp #plainbox,r4
         beq exit20

         mov #io_fn+14,r3
25$:     tstb -(r3)
         beq 25$
         incb @r3
         mov #16384,r2
         br 3$

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

