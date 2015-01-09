;this program doesn't contain code of the original Xlife
;**it is the conversion from 6502 port for Commodore +4
;**and from z80 port for Amstrad CPC6128
;written by litwr, 2014
;it is under GNU GPL

;Xlife loader

         .radix 10
         .dsabl gbl

         .include bk0011m.mac

         .asect
         .=512

start:   mov #start,sp
         mov #^B11110000000000,@#pageport  ;open pages 3 and 4 (AnDOS)
         mov #io_op,r1
         mov r1,r0
         mov #data,r2
         mov #11,r3
1$:      mov (r2)+,(r0)+
         sob r3,1$
         
         emt ^O36     ;load XLIFE2.COM
         tstb @#io_op+1
         beq 2$

         halt
2$:      mov #start,@#io_start 
         decb @#io_fn+5

         mov #^B10110000000000,@#pageport  ;open pages 2 and 4 (AnDOS)
         push sp
         jmp @#^O120002  ;load XLIFE1.COM

data:    .word 3,16384,0
         .ascii "XLIFE2.COM"
         .word 0,0,0
         .end

