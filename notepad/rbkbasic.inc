key2irq:   mov @#kbddtport,@#kbdbuf
           beq 0$

           bisb #128,@#kbdbuf
0$:        rti

keyirq:    mov @#kbddtport,@#kbdbuf
           rti

commonfromdata:
     MOV @#datapos,R3
     CLR R4
     BISB @R3,R4
     INC R4
     ADD R4,@#datapos
     RETURN

intfromdata:
     CALL @#commonfromdata
     MOV @#strdcurre,R2
     MOV R2,R4
     CLR R0
     BISB (R3)+,R0
     MOVB R0,(R2)+
     BEQ 0$

1$:  MOVB (R3)+,(R2)+
     SOB R0,1$

0$:  PUSH R5
     CALL @#str2dec
     MOV R3,@(SP)+
     RETURN

getkey2: movb @#kbdbuf,r0
         beq exit16

kbddelay:mov #20000,r1
1$:      bit #64,@#pageport
         bne 2$

         sob r1,1$
         mov #2000,@#kbddelay+2
         br 3$

2$:      clr @#kbdbuf
         mov #20000,@#kbddelay+2
3$:      return

tobin:     .word 10000,1000,100,10,1
todec:    mov #stringbuf,r5  ;IN: r3 to decimal
          tst r3
          bpl todec0

          movb #'-,(r5)+
          neg r3
todec0:   mov r5,r1
          movb #'0,r2
          mov #tobin,r4
7$:       mov (r4)+,r0
          movb r2,@r5
          clrb 1(r5)
5$:       incb @r5
          sub r0,r3
          bcc 5$

          add r0,r3
          decb @r5
          cmpb r2,@r5
          bne 4$

          cmp r1,r5
          bne 4$

          dec r5
4$:       inc r5
          cmp r0,#1
          bne 7$

          mov #stringbuf,r1
exit16:   return

dogetf:
     MOV @#strdcurre,R2
     MOV R2,@R5
     INC R2
     MOV @#filepos,R4
     CLR R3
     CMP R4,@#loaded_sz
     BCC strfromfile0

     TOIO
     MOVB (R4)+,R1
     TOMAIN
     MOVB R1,(R2)+
     INC R3
     BR strfromfile0

commonfromkbd:
     MOV #'?,R0
     CALL @#charout
     MOV #32,R0
     CALL @#charout
     MOV @#strdcurre,R2
     MOV R2,@R5
     INC R2
     CLR R3
2$:  CMP R3,#255
     BEQ 4$

3$:  CALL @#getkey2
     TSTB R0
     BEQ 3$

     CMPB #10,R0
     BEQ 4$

     MOVB R0,(R2)+
     CMPB #24,R0  ;zaboy/backspace
     BEQ 5$
 
     CMPB R0,#32
     BCC 1$

     DEC R2
     BR 3$

5$:  SUB #2,R2
     SUB #2,R3
1$:  CALL @#charout
     INC R3
     BR 2$

4$:  MOV #10,R0
     JMP @#charout

intfromkbd:
     CALL @#commonfromkbd
intfromkbd0:
     MOV @#strdcurre,R4
     MOVB R3,@R4
     PUSH R5
     CALL @#str2dec
     POP R5
     MOV R3,@R5
     RETURN

strfromkbd:
     CALL @#commonfromkbd
     BR strfromfile1

commonfromfile:
     MOV @#strdcurre,R2
     MOV R2,@R5
     INC R2
     MOV @#filepos,R4
     CLR R3
2$:  CMP R3,#255
     BEQ exit16

     CMP R4,@#loaded_sz
     BCC exit16

     TOIO
     MOVB (R4)+,R1
     TOMAIN
     CMPB #10,R1
     BEQ exit16

     MOVB R1,(R2)+
     INC R3
     BR 2$

intfromfile:
     CALL @#commonfromfile
     MOV R4,@#filepos
     BR intfromkbd0

strfromfile:
     CALL @#commonfromfile
strfromfile0:
     MOV R4,@#filepos
strfromfile1:
     MOVB R3,@0(R5)
     MOV @R5,R5
     BR stringS_i_i0

doinput:
     MOV 2(SP),R0
     ADD SP,R0
2$:  MOV -(R0),R5   ;param
     MOV -(R0),R4   ;subr for param
     CMP R0,SP
     BEQ exit22

     PUSH R0
     CALL @R4
     POP R0
     BR 2$

exit22:
     RETURN

inkeyS:
     CALL @#getkey2
     MOV #strestatic,R5
     TSTB R0
     BEQ exit22

     MOV @#strdcurre,R2
     MOV R2,R5
     MOVB #1,(R2)+
     MOVB R0,(R2)+
     BR stringS_i_i0

strfromdata:
     CALL @#commonfromdata
     MOV R5,R4

s_ASSIGN_s:
     MOV @#strdcurre,R2
     MOV R2,@R4
     CLR R0
     BISB (R3)+,R0
     MOVB R0,(R2)+
     BR s_PLUS_s0

s_PLUS_s:
     MOV @#strdcurre,R2
     MOV R2,R5
     CLR R0
     BISB (R4)+,R0
     MOVB R0,(R2)+
     BEQ 0$ 

1$:  MOVB (R4)+,(R2)+
     SOB R0,1$

0$:  CLR R0
     BISB (R3)+,R0
     MOVB @R5,R4
     ADD R0,R4
     MOVB R4,@R5
     TST R0
s_PLUS_s0:
     BEQ stringS_i_i0

2$:  MOVB (R3)+,(R2)+
     SOB R0,2$
     BR stringS_i_i0

stringS_i_s:
     MOVB 1(R3),R3

stringS_i_i:
     MOV @#strdcurre,R2
     MOV R2,R5
     MOVB R4,(R2)+
     BEQ stringS_i_i0

stringS_i_i1:
     MOVB R3,(R2)+
     SOB R4,stringS_i_i1

stringS_i_i0:
     MOV R2,@#strdcurre
     BR gc

strS_i:
     CALL @#todec
     MOV @#strdcurre,R3
     MOV R3,R5
     INC R3
     CMPB #'-,@R1
     BEQ 0$

     MOVB #32,-(R1)
0$:  MOVB (R1)+,R0
     BEQ 1$

     MOVB R0,(R3)+
     BR 0$

1$:  MOV R3,@#strdcurre
     SUB R5,R3
     DEC R3
     MOVB R3,@R5
     ;JMP @#gc    ;gc is the next!

.include notepad/gc.s

midS_s_i:
     MOV @#strdcurre,R1
     MOV R1,R5
     CLR R0
     BISB @R2,R0
     SUB R4,R0
     BPL 1$
     CLRB (R1)+
     BR midS_s_i0

1$:  INC R1
     ADD R4,R2
3$:  MOVB (R2)+,(R1)+
     DEC R0
     BPL 3$

midS_s_i1:
     MOV R1,R3
     SUB R5,R3
     DEC R3
     MOVB R3,@R5
midS_s_i0:
     MOV R1,@#strdcurre
     BR gc

midS_s_i_i:
     MOV @#strdcurre,R1
     MOV R1,R5
     CLR R0
     BISB @R2,R0
     SUB R4,R0
     BPL 0$

2$:  CLRB (R1)+
     BR midS_s_i0

0$:  TST R3
     BLE 2$

     INC R1
     ADD R4,R2
3$:  DEC R3
     BMI midS_s_i1

     MOVB (R2)+,(R1)+
     DEC R0
     BPL 3$
     BR midS_s_i1

s_LE_s:
     CLR R5
     MOVB (R3)+,R2
     MOVB (R4)+,R1
1$:  DECB R1
     BMI s_GE_s0

     DECB R2
     BMI s_GE_s1

     CMPB (R3)+,(R4)+
     BEQ 1$
     BCC s_GE_s0
     RETURN

s_LT_s:
     CLR R5
     MOVB (R3)+,R2
     MOVB (R4)+,R1
1$:  DECB R2
     BMI s_GE_s1

     DECB R1
     BMI s_GE_s0

     CMPB (R3)+,(R4)+
     BEQ 1$
     BCC s_GE_s0
     RETURN

s_GE_s:
     CLR R5
     MOVB (R3)+,R2
     MOVB (R4)+,R1
1$:  DECB R2
     BMI s_GE_s0

     DECB R1
     BMI s_GE_s1

     CMPB (R4)+,(R3)+
     BCS s_GE_s1
     BEQ 1$

s_GE_s0:
     COM R5
s_GE_s1:
     RETURN

s_GT_s:
     CLR R5
     MOVB (R3)+,R2
     MOVB (R4)+,R1
1$:  DECB R1
     BMI s_GE_s1

     DECB R2
     BMI s_GE_s0

     CMPB (R4)+,(R3)+
     BEQ 1$
     BCC s_GE_s0
     RETURN

s_NE_s:
     MOV #65535,R5
     BR s_EQ_s0

s_EQ_s:
     CLR R5
s_EQ_s0:
     MOVB (R3)+,R2
     CMPB R2,(R4)+
     BNE s_GE_s1

     TST R2
     BEQ s_GE_s0

1$:  CMPB (R3)+,(R4)+
     BNE s_GE_s1
     SOB R2,1$
     BR s_GE_s0

midS_s_i_s:
     MOV #256,R2

midS_s_i_i_s:
     TST R3
     BLE 1$

     MOV @R4,R4
     CLR R0
     BISB @R4,R0
     CMP R0,R3
     BCS 1$

     ADD R3,R4
     SUB R3,R0
     CLR R3
     BISB (R1)+,R3
     BEQ 1$

2$:  MOVB (R1)+,(R4)+
     DEC R0
     BMI 1$

     DEC R2
     BEQ 1$
     SOB R3,2$

1$:  RETURN

openwrite:
     MOV #16384,@#eolpos
openwrite0:
     MOV #2,R1
     BR openread0

openread:
     MOV #3,R1
openread0:
     MOV #16384,R5
     TST @#filepos
     BNE exit20

     MOV R5,@#filepos
     MOV #io_op,R4
     MOV R1,(R4)+
     CLR R2
     BISB (R3)+,R2
     MOV R5,(R4)+
     MOV #12,R1
     CLR (R4)+
0$:  MOVB (R3)+,(R4)+
     DEC R1
     BEQ 1$
     SOB R2,0$

1$:  ADD #4,R1
2$:  CLRB (R4)+
     SOB R1,2$

exit20:
     RETURN

emt36: TOIO
     MOV #io_OP,R1
     EMT ^O36
     BR charout0

charout: TOSCREEN
     EMT ^O16
charout0:
     TOMAIN
charout1:
     RETURN

nstringout:
     CMPB #'-,@R1
     BEQ stringout

     MOVB #32,-(R1)
stringout:
     TOSCREEN
     EMT ^O20
     BR charout0

togglecrsr:
     MOV #154,R0
     TST @#cursorst
     BNE 1$

     TST R3
     BEQ charout1
     BR 2$

1$:  TST R3
     BNE charout1

2$:  COM @#cursorst
     BR charout

setcrsr:
     TOSCREEN
     EMT ^O24
     BR charout0

getcrsr:
     TOSCREEN
     EMT ^O26
     BR charout0

fnstringout:
     CMPB #'-,@R1
     BEQ 1$

     MOVB #32,-(R1)
1$:  MOVB (R1)+,R0
     BEQ charout0

     PUSH #1$
fcharout:
     MOV @#filepos,R2
     CMPB #10,R0
     BNE 1$

     MOV R2,@#eolpos
1$:  CMP R2,#32768
     BCC 0$

     TOIO
     MOVB R0,(R2)+
0$:  MOV R2,@#filepos
fcharout0:
     BR charout0

cat:     mov #11,r0
         mov #stringbuf,r5
30$:     movb #32,(r5)+
         sob r0,30$
         
         clr r2     ;in: r4 - ptr to mask
         bisb (r4)+,r2
         beq charout1

         push r4
         mov r2,r3
32$:     cmpb #'.,(r4)+
         beq 31$
         sob r3,32$

31$:     pop r4
         mov r2,r0
         sub r3,r0
         beq charout1

         cmp r0,#8
         bcc charout1

         mov #stringbuf,r5
         mov r0,r1
2$:      cmpb #'*,@r4
         beq 35$

         movb (r4)+,(r5)+
         sob r1,2$

         mov #8,r1
         sub r0,r1
         beq 38$

5$:      movb #32,(r5)+
         sob r1,5$
         br 38$

35$:     inc r4
         sub #9,r0
         neg r0
41$:     movb #'?,(r5)+
         sob r0,41$

38$:     inc r4
         dec r3
         ble showdir

         cmpb #3,r3
         bcc 43$

         mov #3,r3
43$:     cmpb #'*,@r4
         beq 42$

         movb (r4)+,(r5)+
         sob r3,43$
         br showdir

42$:     sub #4,r3
         neg r3
44$:     movb #'?,(r5)+
         sob r3,44$

showdir: TOSCREEN
         mov @#andos_init,r1    ;linker!
         call @r1
         clr r0
1$:      mov #stringbuf,r3
         mov @#andos_diren2,r1  ;linker!
         call @r1
         beq fcharout0

         mov #11,r2
         mov r4,r1
3$:      cmpb @r3,(r1)+
         beq 2$

         cmpb #'?,@r3
         bne 1$

2$:      inc r3
         sob r2,3$

         mov #stringbuf+11,r3
         mov #11,r2
         mov r4,r1
4$:      movb (r1)+,(r3)+
         cmp #4,r2
         bne 7$

         movb #'.,(r3)+
7$:      sob r2,4$

         mov #32,r1
         movb r1,(r3)+
         movb r1,(r3)+
         movb r1,(r3)+
         movb r1,(r3)+
         mov #stringbuf+11,r1
         mov #16,r2
         emt ^O20
         br 1$

str2dec: clr r1           ;IN: R4; OUT: R3
         bisb (r4)+,r1
11$:     dec r1
         cmpb (r4)+,#32
         beq 11$

         dec r4
         inc r1
         clr r3
         clr r5
         cmpb #'-,@r4
         bne 1$

         inc r5
         dec r1
         inc r4
1$:      cmp #5,r1
         bcs 5$

         dec r1
         beq 2$

         cmpb #'0,(r4)+
         beq 1$

         dec r4
2$:      mov r1,r2
         sub #4,r2
         neg r2
         asl r2
6$:      mov tobin(r2),r0
         cmpb #'0-1,@r4
         bcc 8$

         cmpb #'9,@r4
         bcs 8$

4$:      cmpb #'0,@r4
         beq 3$

         add r0,r3
         decb @r4
         br 4$ 

3$:      cmp #8,r2
         beq 5$

7$:      add #2,r2
         inc r4
         br 6$

8$:      clr r3
         return

5$:      tst r5
         beq 10$

         neg r3
10$:     return

hexconv: ADD #48,R4
         CMPB #'9,R4
         BCC 1$

         ADD #7,R4
1$:      MOVB R4,(R2)+
         RETURN

hex2dec: CLR R3
         BISB @R4,R3
         ADD R3,R4
         MOV #1,R0
         CLR R1
3$:      MOVB @R4,R2
         DEC R4
         SUB #'0,R2
         CMP R2,#10
         BCS 0$

         SUB #7,R2
         CMP R2,#16
         BCS 0$

         SUB #32,R2
0$:      BIS R2,R2
         BEQ 1$

2$:      ADD R0,R1
         SOB R2,2$

1$:      ASL R0
         ASL R0
         ASL R0
         ASL R0
         DEC R3
         BNE 3$
         RETURN

mul16:   CLR R5     ;R1*R2->R0, does not change R3,R4
         TST R1
         BPL 1$

         NEG R1
         COM R5
1$:      TST R2
         BPL 2$

         NEG R2
         COM R5
2$:      CLR R0      ;clear CF
         ROR R2
         BCC 3$

         MOV R1,R0
3$:      ASL R1
         BEQ 7$

         ASR R2
         BCC 4$

         ADD R1,R0
4$:      TST R2
         BNE 3$
 
7$:      TST R5
         BEQ 5$

         NEG R0
5$:      RETURN

power16: MOV #1,R1  ;R4^R3->R1
         TST R3
         BEQ 1$

2$:      MOV R4,R2
         CALL @#mul16
         MOV R0,R1
         DEC R3
         BNE 2$
1$:      RETURN

div16:   CLR R5     ;R2/R1->R4:R2
         CLR R4
         TST R1
         BEQ 8$     ;division by zero is ignored
         BPL 1$

         NEG R1
         COM R5
1$:      TST R2
         BPL 2$

         NEG R2
         COM R5
2$:      PUSH R1     ;handles -32768
         MOV #1,R3
         CMP R2,R1
         BCS 3$

4$:      MOV R2,R0
         SUB R1,R0
         CMP R0,R1
         BLOS 5$

         ASL R3
         ASL R1
         BR 4$

5$:      ADD R3,R4
         MOV R0,R2
6$:      ASR R1
         ASR R3
         BEQ 3$

         CMP R2,R1
         BCS 6$

         ADD R3,R4
         SUB R1,R2
         BNE 6$

3$:      CMP R2,(SP)+    ;handles -32768
         BNE 7$

         INC R4
         CLR R2
7$:      TST R5
         BEQ 8$

         NEG R4
         NEG R2
8$:      RETURN

strdstart: .word strsdyn
strdcurre: .word strsdyn
filepos:   .word 0
eolpos:    .word 0
kbdbuf:    .word 0
datapos:   .word datastart
cursorst:  .word 65535
strdmax:   .word 48*1024-256
lib_end:

