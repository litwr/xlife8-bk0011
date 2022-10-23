COLORS:    .word 0,-1,43690,21845,0

kbdbuf     = key2irq + 4
key2irq:   mov @#kbddtport,#0
           beq 0$

           bisb #128,@#kbdbuf
0$:        rti

keyirq:    mov @#kbddtport,@#kbdbuf
           rti

.if df opt_instr
instr:    DEC R2
          CLR R0
          CLR R5
          BISB (R4)+,R5
          SUB R2,R5
          BLOS 0$

          MOV R4,R1
          ADD R2,R4
          CLR R2
          BISB (R3)+,R2
          SUB R2,R5
2$:       TST R5
          BMI 0$

          CMPB @R3,(R4)+
          BEQ 1$

4$:       DEC R5
          BR 2$

1$:       PUSH R2
          PUSH R3
          PUSH R4
          DEC R2
          BEQ 6$

5$:       INC R3
          CMPB @R3,(R4)+
          BNE 3$

          DEC R2
          BNE 5$

6$:       MOV @SP,R0
          SUB R1,R0
          ADD #6,SP
0$:       RETURN

3$:       POP R4
          POP R3
          POP R2
          BR 4$
.endc

.if df opt_intfromdata ! opt_strfromdata
datapos = . + 2
commonfromdata:
     MOV #datastart,R3
     CLR R4
     BISB @R3,R4
     INC R4
     ADD R4,@#datapos
     RETURN
.endc

.if df opt_intfromdata
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
.endc

.if df opt_intfromkbd ! opt_strfromkbd ! opt_inkeyS
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
.endc

tobin:     .word 10000,1000,100,10,1

.if df opt_nstringout ! opt_fnstringout ! opt_strS_i
todec:    mov #stringbuf,r5  ;IN: r3 to decimal
          tst r3
          bpl todec0

          movb #'-,(r5)+
          neg r3
.endc

.if df opt_nstringout ! opt_fnstringout ! opt_todec0 ! opt_strS_i
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
.endc
exit16:   return

.if df opt_dogetf
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
.endc

.if df opt_intfromkbd ! opt_strfromkbd
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
.endc

.if df opt_intfromkbd
intfromkbd:
     CALL @#commonfromkbd
.endc

.if df opt_intfromkbd ! opt_intfromfile
intfromkbd0:
     MOV @#strdcurre,R4
     MOVB R3,@R4
     PUSH R5
     CALL @#str2dec
     MOV R3,@(SP)+
     RETURN
.endc

.if df opt_strfromkbd
strfromkbd:
     CALL @#commonfromkbd
     BR strfromfile1
.endc

.if df opt_intfromfile ! opt_strfromfile
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
.endc

.if df opt_intfromfile
intfromfile:
     CALL @#commonfromfile
     MOV R4,@#filepos
     BR intfromkbd0
.endc

.if df opt_strfromfile
strfromfile:
     CALL @#commonfromfile
.endc

.if df opt_strfromfile ! opt_dogetf
strfromfile0:
     MOV R4,@#filepos
.endc

.if df opt_strfromfile ! opt_strfromkbd ! opt_dogetf
strfromfile1:
     MOVB R3,@0(R5)
     MOV @R5,R5
     BR stringS_i_i0
.endc

.if df opt_strfromfile ! opt_strfromkbd ! opt_strfromdata ! opt_intfromfile ! opt_intfromkbd ! opt_intfromdata
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
.endc

exit22:
     RETURN

.if df opt_inkeyS
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
.endc

.if df opt_strfromdata
strfromdata:
     CALL @#commonfromdata
     MOV R5,R4
.endc

.if df opt_strfromkbd
     NOP
.endc

.if df opt_strfromdata ! opt_string ! opt_strfromfile ! opt_strfromkbd ! opt_dogetf ! opt_inkeyS
s_ASSIGN_s:
     MOV @#strdcurre,R2
     CLR R5
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
.endc

.if df opt_strS_i
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
.endc

.if df opt_gc
.include gc.s
.endc

.if df opt_midS_s_i ! opt_midS_s_i_i
midS_s_i:
     MOV @#strdcurre,R1
     MOV R1,R5
     CLR R0
     BISB @R2,R0
     SUB R4,R0
     BMI midS_s_i_i0

     INC R1
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
     BPL midS_s_i_i1

midS_s_i_i0:
     CLRB (R1)+
     BR midS_s_i0

midS_s_i_i1:
     TST R3
     BLE midS_s_i_i0

     INC R1
     ADD R4,R2
3$:  DEC R3
     BMI midS_s_i1

     MOVB (R2)+,(R1)+
     DEC R0
     BPL 3$
     BR midS_s_i1
.endc

.if df opt_s_LE_s
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
.endc

.if df opt_s_LT_s
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
.endc

.if df opt_s_GE_s ! opt_s_LE_s ! opt_s_GT_s ! opt_s_LT_s ! opt_s_EQ_s ! opt_s_NE_s
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
.endc

.if df opt_s_GT_s
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
.endc

.if df opt_s_NE_s
s_NE_s:
     MOV #65535,R5
     BR s_EQ_s0
.endc

.if df opt_s_EQ_s ! opt_s_NE_s
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
.endc

.if df opt_midS_s_i_s ! opt_midS_s_i_i_s
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
.endc

eolpos = openwrite + 4
openwrite:
     MOV #16384,#0
.if df opt_openwrite
openwrite0:
     MOV #2,R1
     BR openread0
.endc

.if df opt_openread ! opt_openwrite
openread:
     MOV #3,R1
openread0:
     MOV #16384,R5
     TST @#filepos
     BNE 3$

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

3$:  RETURN
.endc

.if df opt_emt36
emt36: TOIO
     MOV #io_OP,R1
     EMT ^O36
     BR charout0
.endc

charout: TOSCREEN
     EMT ^O16
charout0:
     TOMAIN
charout1:
     RETURN

xstringout:    ;IN: R1
     CLR R3
     BISB (R1)+,R3
     BEQ 0$

1$:  MOVB (R1)+,R0
     CALL @#charout
     SOB R3,1$
0$:  RETURN

.if df opt_nstringout
nstringout:
     CALL @#todec
     CMPB #'-,@R1
     BEQ 1$

     MOVB #32,-(R1)
1$:  TOSCREEN
     EMT ^O20
     BR charout0
.endc

.if df opt_togglecrsr
togglecrsr:
     MOV #154,R0
cursorst = . + 2
     TST #65535
     BNE 1$

     TST R3
     BEQ charout1
     BR 2$

1$:  TST R3
     BNE charout1

2$:  COM @#cursorst
     BR charout
.endc

.if df opt_setcrsr
setcrsr:
     TOSCREEN
     EMT ^O24
     BR charout0
.endc

.if df opt_getcrsr
getcrsr:
     TOSCREEN
     EMT ^O26
     BR charout0
.endc

.if df opt_fnstringout
fnstringout:
     CALL @#todec
     CMPB #'-,@R1
     BEQ 1$

     MOVB #32,-(R1)
1$:  MOVB (R1)+,R0
     BEQ charout0

     PUSH #1$
.endc

filepos = . + 2
fcharout:
     MOV #0,R2

.if df opt_fcharout ! opt_fnstringout
     CMPB #10,R0
     BNE 1$

     MOV R2,@#eolpos
1$:  CMP R2,#32768
     BCC 0$

     TOIO
     MOVB R0,(R2)+
0$:  MOV R2,@#filepos
.endc

fcharout0:
     BR charout0

.if df opt_cat
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
         ;mov @#andos_init,r1    ;linker! absence of @addr support eats 2 bytes!
         ;call @r1
         call @andos_init
         clr r0
1$:      mov #stringbuf,r3
         ;mov @#andos_diren2,r1  ;linker! absence of @addr support eats 2 bytes!
         ;call @r1
         call @andos_diren2
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
.endc

.if df opt_str2dec ! opt_intfromfile ! opt_intfromkbd ! opt_intfromdata
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
.endc

.if df opt_binconv
binmain: MOV @#strdcurre,R2
         MOV r2,R5
         INC R2
         CLR R1
         MOV #15,R0
1$:      CLR R4
         ASL R3
         ADC R4
         CALL @#octdigit
         SOB R0,1$

         ASL R3
         ADC R4
         CALL @#octdigit0
         BR exitstr
.endc

.if df opt_hexconv
hexdigit:BNE hexdigit0

         TST R1
         BEQ hexdigit1:

hexdigit0:
         ADD #48,R4
         INC R1
         CMPB #'9,R4
         BCC 1$

         ADD #7,R4
1$:      MOVB R4,(R2)+
hexdigit1:
         RETURN               ;CARRY=0

hexmain: MOV @#strdcurre,R2
         MOV r2,R5
         INC R2
         CLR R1     ;length
         MOV R3,R4
         CLC
         SWAB R4
         RORB R4
         ASRB R4
         ASRB R4
         ASRB R4
         CALL @#hexdigit
         MOV R3,R4
         SWAB R4
         BICB #240,R4
         CALL @#hexdigit
         MOV R3,R4
         RORB R4
         ASRB R4
         ASRB R4
         ASRB R4
         CALL @#hexdigit
         BICB #240,R3
         MOV R3,R4
         CALL @#hexdigit0
.endc

.if df opt_exitstring
exitstr:
         MOVB R1,@R5
exitstr0:
         MOV R2,@#strdcurre
         JMP @#gc
.endc

.if df opt_octconv ! opt_binconv
octdigit:BNE octdigit0

         TST R1
         BEQ octdigit1:

octdigit0:
         ADD #48,R4
         INC R1
         MOVB R4,(R2)+
octdigit1:
         CLR R4
         RETURN
.endc

.if df opt_octconv
octmain: MOV @#strdcurre,R2
         MOV r2,R5
         INC R2
         CLR R1
         CLR R4
         ASL R3
         ROL R4
         CALL @#octdigit
         MOV #4,R0
1$:      ASL R3
         ROL R4
         ASL R3
         ROL R4
         ASL R3
         ROL R4
         CALL @#octdigit
         SOB R0,1$

         ASL R3
         ROL R4
         ASL R3
         ROL R4
         ASL R3
         ROL R4
         CALL @#octdigit0
         BR exitstr
.endc

.if df opt_hex2dec
hex2dec: CLR R3           ;in: R4
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
.endc

.if df opt_mul16 ! opt_power16
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
.endc

.if df opt_power16
power16: MOV #1,R1  ;R4^R3->R1
         TST R3
         BEQ 1$

2$:      MOV R4,R2
         CALL @#mul16
         MOV R0,R1
         DEC R3
         BNE 2$
1$:      RETURN
.endc

.if df opt_div16
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
.endc

baseptr:   .word 0       ;base pointer for FN
strdstart: .word strsdyn
strdcurre: .word strsdyn
strdmax:   .word 48*1024-256

