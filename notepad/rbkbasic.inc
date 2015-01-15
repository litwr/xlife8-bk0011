tobin:     .word 10000,1000,100,10,1
todec:    mov #stringbuf,r1  ;IN: r3 to decimal, no negative numbers support
          mov r1,r5
          movb #'0,r2
          mov #tobin,r4
          tst r3
          bpl 1$

          movb #'-,(r1)+
          inc r5
          neg r3
1$:       mov (r4)+,r0
          movb r2,@r1
          clrb 1(r1)
5$:       incb @r1
          sub r0,r3
          bcc 5$

          add r0,r3
          decb @r1
          cmpb r2,@r1
          bne 4$

          cmp r5,r1
          bne 4$

          dec r1         
4$:       inc r1
          cmp r0,#1
          bne 1$

          mov #stringbuf,r1
          return

s_ASSIGN_s:
     MOV @#strdcurre,R2
     MOV R2,@R4
     CLR R0
     BISB (R3)+,R0
     MOVB R0,(R2)+
     TST R0
     BEQ 1$

2$:  MOVB (R3)+,(R2)+
     SOB R0,2$

     MOV R2,@#strdcurre
1$:  CLR R5
     BR gc

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
     MOVB R4,@r5
     TST R0
     BEQ stringS_i_i0

3$:  MOVB (R3)+,(R2)+
     SOB R0,3$
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

gc:       cmp #strdmax,@#strdcurre
          bcc exitgc

          mov #32768,r0        ;end of tree pointer
          mov #strsstatic,r1
          mov r5,@#strestatic-2
4$:       cmp #strestatic,r1
          beq 1$
          
          mov r1,r3
          cmp (r1)+,@#strdstart   ;+1?
          bcs 4$

          mov r3,(r0)+
          clr (r0)+
          clr (r0)+
          cmp #strestatic,r1
          beq 1$

          cmp @r1,@#strdstart   ;+1?
          bcs 4$

          mov #32768,r2     ;pointer to the root
5$:       mov r2,r3
          cmp @r1,@0(r2)
          bcc 2$

          add #2,r3      ;@r1 < @@r2, left
6$:       mov @r3,r2
          bne 5$

          mov r0,@r3
          br 4$

2$:       add #4,r3      ;@r1 > @@r2, right
          br 6$

1$:       mov sp,@#savesp
          mov #49152,sp
          mov @#strdstart,r1
          push #7$
          push #32768
          br treesurvey

7$:       mov r1,@#strdcurre
          mov @#savesp,sp
          mov @#strestatic-2,r5
exitgc:   return

treesurvey: pop r2
          beq exitgc

          push r2
          push #1$
          push 2(r2)
          br treesurvey

1$:       pop r2
          mov @r2,r4
          mov @r4,r0
          mov r1,@r4
          clr r3
          bisb @r0,r3
          inc r3
2$:       movb (r0)+,(r1)+
          sob r3,2$

          push 4(r2)
          br treesurvey

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
     ADD R4,R2\n";
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

     DEC R3
     BNE 2$

1$:  RETURN

charout: TOSCREEN
     EMT ^O16
     TOSTRINGCO
     RETURN

stringout:
     TOSCREEN
     EMT ^O20
     TOSTRINGCO
     RETURN

setcrsr:
     TOSCREEN
     EMT ^O24
     TOSTRINGCO
     RETUERN

strdstart: .word 16385
strdcurre: .word 16385
lib_end:

