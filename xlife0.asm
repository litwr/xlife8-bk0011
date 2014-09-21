;this program doesn't contain code of the original Xlife
;**it is the conversion from 6502 port for Commodore +4
;**and from z80 port for Amstrad CPC6128
;written by litwr, 2014
;it is under GNU GPL

;Xlife loader

         .radix 10
         .dsabl gbl

         .asect
         .=512

stack:   .blkw 128

start:   mov #^B10110000000000,@#^O177716
         mov #data,r1
         emt #^O36     ;load XLIFE2.COM

         mov #start,@#<data+2> 
         decb @#<fn+5>

         mov #^B11110000000000,@#^O177716
         mov #start,sp
         mov sp,-(sp)
         mov #data,r1
         jmp @#^O120002  ;load XLIFE1.COM
         nop
         nop
         nop

data:    .word 3
         .word 16384
         .word 0
fn:      .asciz /XLIFE2.COM/
         .byte 0,0,0,0,0
fa:      .word 0
         .word 0
         .blkb 16

         .end

