            .radix 10
            .dsabl gbl
            .asect
            .=512

            .include bk0011m.mac

text:       mov #keyirq,@#^O60
            mov #keyirq,@#^O274
            mov #inittxt,r1
            mov #initxt2-inittxt,r2
            emt ^O20
            clr r1
6$:         movb title(r1),r0
            beq 5$

            emt ^O22
            inc r1
            br 6$

5$:         call @#getkey
            bic #160,r0     ;$a0
            cmpb #'C,r0
            bne 4$

            incb @#palette
            bicb #240,@#palette
            movb @#palette,r2
            swab r2
            asl r2
            bis #16384,r2
            mov r2,@#kbddtport
            br 5$

4$:         mov #inittxt,r1
            mov #palette-initxt2,r2
            emt ^O20

            mov #manend-mantext,r2
            mov #mantext,r3
2$:         movb (r3)+,r0
            emt ^O16
1$:         call @#getkey2
            bne 1$

8$:         mov #800,r1
3$:         sob r1,3$
            sob r2,2$

            call @#getkey
            jmp @#^O160000

getkey:     movb @#kbdbuf,r0    ;waitkey
            beq getkey

            clrb @#kbdbuf
            return

getkey2:    movb @#kbdbuf,r0
            beq exit11

kbddelay:   mov #20000,r1
1$:         bit #64,@#pageport
            bne 2$

            sob r1,1$
            mov #2000,@#kbddelay+2
            br exit11

2$:         clrb @#kbdbuf
            mov #20000,@#kbddelay+2
exit11:     return

keyirq:     mov @#kbddtport,@#kbdbuf
            rti

kbdbuf:     .word 0
title:      .ascii "Xlife(6)                                                Xlife(6)"
            .byte 0
inittxt:    .byte 154,12
            .ascii "C-key selects color, another key begins to show the manpage."
initxt2:    .byte 154,12
palette:    .byte 0
mantext:
            .include manpage.s
manend:
            .end
