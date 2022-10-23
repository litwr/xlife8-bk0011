maketent:   ;in: r0
         mov (r0)+,r1
         mov r1,@#loaded_sz
         sub #8,r1
         asr r1
         mov #16384+8,r2
1$:      mov (r0)+,r3
         mov #toio,@#pageport
         mov r3,(r2)+
         mov #todata,@#pageport
         sob r1,1$
exitram: return

ramdisk: jsr r3,@#printstr
         .byte 12,146
         .ascii "ENTER FILE# OR HIT "
         .byte 145
         .ascii "KT"
         .byte 10,'0,147
         .ascii " GLIDER GUN"
         .byte 10,145,'1,147
         .ascii " SMALL FISH"
         .byte 10,145,'2,147
         .ascii " HEAVYWEIGHT SPACESHIP"
         .byte 10,145,'3,147
         .ascii " R-PENTOMINO"
         .byte 10,145,'4,147
         .ascii " BUNNIES"
         .byte 10,145,'5,147
         .ascii " LIDKA"
         .byte 10,145,'6,147
         .ascii " BIG GLIDER"
         .byte 10,145,'7,147
         .ascii " BI-GUN"
         .byte 10,145,'8,147
         .ascii " ACORN"
         .byte 10,145,'9,147
         .asciz " SWITCH ENGINE PUFFER"
         .byte 0

1$:      call @#getkey
         cmpb #3,r0    ;kt/esc
         beq exitram

         cmpb r0,#'0
         bcs 1$

         cmpb #'9,r0
         bcs 1$

         sub #'0,r0
         asl r0
         mov #todata,@#pageport
         mov ramptrs(r0),r0
         mov (r0)+,@#x0   ;geometry
         call @#maketent
         call @#tograph
         call @#showrect
         bcs exitram

         mov #16384+8,r0
puttent: add #16384,@#loaded_sz
6$:      mov #toio,@#pageport
         mov (r0)+,@#x0
         mov #todata,@#pageport
         call @#putpixel
         cmp r0,@#loaded_sz
         bne 6$
         return

