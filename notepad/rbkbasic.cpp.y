%{
#include <cctype>
#include "rbkbasic.h"
map<int, Symbol*> realloca, reallocs;
map<string, Symbol> names, strings;
map<int, int> reallocl, labels;
int argcount;
string code[100000], data[100000];
%}
%union {
  Symbol *sym;
  int num;
}
%token <sym> SVAR IVAR STR STRING CHR INKEY MID
%token <num> NUMBER ASC CLS ELSE FRE GOSUB GOTO LEN PRINT NEXT TO
%token <num> FOR IF INPUT LOCATE PEEK POKE RETURN STEP VAL THEN POS END
%token <num> CLOSE OUTPUT BEOF OPEN FIND
%type <sym> ivar svar
%type <num> markop then
%left OR
%left AND
%left GT GE LT LE '=' NE  //> >= < <= = !=
%left '+' '-'
%left NOT
%%
prog: operlist {relocate(); throw 1;}
;
operlist: markop 
//| oper '\n' operlist  //immediate mode
| NUMBER {
    code[progp++] = tostr(locals) + "$:\n";
    labels[$1] = locals++;
  } oper '\n' operlist
| NUMBER '\n' operlist
;
oper: assign
| print
| for
| if
| locate
| open
| CLOSE {
     asmcomm("CLOSE");
     code[progp++] = "CMPB #2,@#io_op\n";
     code[progp++] = "BNE " + tostr(locals) + "$\n";
     code[progp++] = "MOV @#filepos,@#io_len\n";
     code[progp++] = "CALL @#emt36\n";
     code[progp++] = tostr(locals++) + "$:CLR @#filepos\n";
}
| GOSUB NUMBER {
     asmcomm("GOSUB NUMBER");
     code[progp++] = "CALL @#";
     reallocl[progp] = $2;
     code[progp++] = "";
}
| RETURN {asmcomm("RETURN"); code[progp++] = "RETURN\n";}
| GOTO NUMBER {
      asmcomm("GOTU NUMBER");
      code[progp++] = "JMP @#";
      reallocl[progp] = $2;
      code[progp++] = "";
   }
| CLS {asmcomm("CLS"); code[progp++] = "MOV #12,R0\nCALL @#charout\n";}
| input {argcount = 0;}
| POKE iexpr ',' iexpr {
      asmcomm("POKE i,i");
      code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
   }
| END {code[progp++] = "JMP @#finalfinish\n";}
;
assign: ivar '=' iexpr {
     asmcomm("ivar ASSIGN i");
     code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
  }
| svar '=' svar {
     asmcomm("svar ASSIGN s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_ASSIGN_s\n";
  }
| svar '=' sexpr {
     asmcomm("svar ASSIGN s");
     code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
  }
| MID '(' svar ',' iexpr ',' iexpr ')' '=' sexpr {
     asmcomm("MID$(s,i,i,s)");
     code[progp++] = "POP R1\nPOP R2\nPOP R3\nPOP R4\nCALL @#midS_s_i_i_s\n";
  }
| MID '(' svar ',' iexpr ')' '=' sexpr {
     asmcomm("MID$(s,i,s)");
     code[progp++] = "POP R1\nPOP R3\nPOP R4\nCALL @#midS_s_i_s\n";
  }
;
print: PRINT prlist
| PRINT '#' prlist
;
prlist: prcomma prlist
| prcomma
| prsemicol prlist
| prsemicol
| pexpr prlist
| pexpr {code[progp++] = "MOV #10,R0\nCALL @#charout\n";}
;
pexpr: iexpr {
     code[progp++] = "POP R3\nCALL @#todec\nCALL @#stringout\n";
}
| sexpr {
     code[progp++] = "POP R1\nCLR R2\nBISB (R1)+,R2\nBEQ " + tostr(locals + 1)
       + "$\n" + tostr(locals) + "$:MOVB (R1)+,R0\nCALL @#charout\nSOB R2," 
       + tostr(locals) + "$\n" + tostr(locals + 1) + "$:\n";
     locals += 2;
}
//| PBLTIN '(' iexpr ')'
;
prsemicol: pexpr ';' {code[progp++] = "MOV #32,R0\nCALL @#charout\n";}
;
prcomma: pexpr ','
;
input: INPUT varlist
| INPUT '#' varlist {
     asmcomm("INPUT#");
     code[progp++] = "PUSH #" + tostr(argcount*4 + 4) + "\nCALL @#doinputf\n";
     code[progp++] = "ADD #" + tostr(argcount*4 + 2) + ",SP\n";
}
| INPUT STRING ';' varlist
;
varlist: svar {argcount++; code[progp++] = "PUSH #strfromfile\n";}
| svar {argcount++; code[progp++] = "PUSH #strfromfile\n";} ',' varlist
| ivar
| ivar ',' varlist
;
for: markop FOR IVAR '=' iexpr {
     asmcomm("FOR");
     code[progp++] = "POP R3\nMOV R3,@#";
     realloca[progp] = $3;
     code[progp++] = tostr($3->addr);
     code[progp++] = "\n";
  } TO iexpr step '\n' {
     asmcomm("TO of FOR");
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1] = locals++;
  } operlist next {
     asmcomm("NEXT of FOR");
     code[progp++] = "MOVB #6,R3\n";   //BGT = 6
     code[progp++] = "TST @SP\n";
     code[progp++] = "BPL " + tostr(locals) + "$\n";
     code[progp++] = "DEC R3\n";   //BLT = 5
     code[progp++] = tostr(locals++) + "$:MOVB R3,@#";
     code[progp++] = tostr(locals) + "$+1\n";
     code[progp++] = "ADD @SP,@#";
     realloca[progp] = $3;
     code[progp++] = tostr($3->addr);
     code[progp++] = "\nCMP @#";
     realloca[progp] = $3;
     code[progp++] = tostr($3->addr);
     code[progp++] = ",2(SP)\n";
     code[progp++] = tostr(locals++) + "$:BGE ";
     code[progp++] = tostr(locals) + "$\nJMP @#";
     reallocl[progp] = -$1;
     code[progp++] = "";
     code[progp++] = tostr(locals++) + "$:ADD #4,SP\n";
  }
;
next: NEXT IVAR
| NEXT
;
step: {code[progp++] = "PUSH #1\n";}
| STEP iexpr
;
if: markop IF iexpr then thenoper {
     asmcomm("IF THEN thenoper");
     asmcomm("IF");
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$4] = locals++;
   }
| markop IF iexpr then thenoper ELSE {
     asmcomm("IF THEN thenoper ELSE");
     code[progp++] = "BR ";
     reallocl[progp] = -$1;
     code[progp++] = "";
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$4] = locals++;
   } elseoper {
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1] = locals++;
   }
| markop IF iexpr GOTO NUMBER {
     asmcomm("IF GOTO NUMBER");
     code[progp++] = "POP R3\nTST R3\n";
     code[progp++] = "BEQ ";
     reallocl[progp] = -$1;
     code[progp++] = "";
     code[progp++] = "JMP @#";
     reallocl[progp] = $5;
     code[progp++] = "";
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1] = locals++;
   }
| markop IF iexpr GOTO NUMBER ELSE {
     asmcomm("IF GOTO NUMBER ELSE");
     code[progp++] = "POP R3\nTST R3\n";
     code[progp++] = "BEQ ";
     reallocl[progp] = -$1;
     code[progp++] = "";
     code[progp++] = "JMP @#";
     reallocl[progp] = $5;
     code[progp++] = "";
     code[progp++] = "BR ";
     reallocl[progp] = -$1 - 10000;
     code[progp++] = "";
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1] = locals++;
   } elseoper {
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1 - 10000] = locals++;
   }
;
then: THEN {
     asmcomm("then");
     code[progp++] = "POP R3\nTST R3\n";
     code[progp++] = "BEQ ";
     reallocl[progp] = -$1;
     code[progp++] = "";
   }
;
thenoper: oper
| NUMBER {
     asmcomm("then NUMBER");
     code[progp++] = "JMP @#";
     reallocl[progp] = $1;
     code[progp++] = "";
}
;
elseoper: oper
| NUMBER {
     asmcomm("else NUMBER");
     code[progp++] = "JMP @#";
     reallocl[progp] = $1;
     code[progp++] = "";
}
;
locate: LOCATE iexpr ',' iexpr ',' iexpr {
   asmcomm("LOCATE i,i,i");
   code[progp++] = "POP R1\nMOVB R1,@#^O56\n";
   code[progp++] = "POP R2\nPOP R1\nCALL @#setcrsr\n";
}
| LOCATE iexpr ',' iexpr {
   asmcomm("LOCATE i,i");
   code[progp++] = "POP R2\nPOP R1\nCALL @#setcrsr\n";
}
;
open: OPEN sexpr {
   asmcomm("OPEN s");
   code[progp++] = "POP R3\nCALL @#openread\nCALL @#emt36\nADD #16384,@#loaded_sz\n";
}
| OPEN sexpr FOR INPUT {
   asmcomm("OPEN s FOR INPUT");
   code[progp++] = "POP R3\nCALL @#openread\nCALL @#emt36\nADD #16384,@#loaded_sz\n";
}
| OPEN sexpr FOR OUTPUT {
   asmcomm("OPEN s FOR OUTPUT");
   code[progp++] = "POP R3\nCALL @#openwrite\n";
}
;
markop: {$$ = progp;}
;
ivar: IVAR {
     asmcomm("IVAR");
     code[progp++] = "PUSH #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = "\n";
}
| IVAR '(' iexpr ')' {
     asmcomm("IVAR(i)");
     code[progp++] = "POP R3\nASL R3\nADD #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = ",R3\nPUSH R3\n";
}
;
svar: SVAR {
     asmcomm("SVAR");
     code[progp++] = "PUSH #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = "\n";
}
| SVAR '(' iexpr ')' {
     asmcomm("SVAR(i)");
     code[progp++] = "POP R3\nASL R3\nADD #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = ",R3\nPUSH R3\n";
}
;
iexpr: NUMBER {
     asmcomm("NUMBER");
     code[progp++] = "PUSH #" + tostr($1) + "\n";
}
| ivar {
     asmcomm("ivar");
     code[progp++] = "POP R4\nMOV @R4,R4\nPUSH R4\n";
}
| FRE {
     asmcomm("FRE");
     code[progp++] = "MOV #strdmax,R3\nSUB @#strdcurre,R3\nPUSH R3\n";
}
| PEEK '(' iexpr ')' {
     asmcomm("PEEK(i)");
     code[progp++] = "POP R4\nCLR R3\nBISB @R4,R3\nPUSH R3\n";
}
| ASC '(' sexpr ')' {
     asmcomm("ASC(s)");
     code[progp++] = "POP R4\nCLR R3\nBISB (R4)+,R3\nBEQ " + tostr(locals)
        + "$\nCLR R3\nBISB @R4,R3\n" + tostr(locals) + "$:PUSH R3\n";
     locals++;
}
| LEN '(' sexpr ')' {
     asmcomm("LEN(s)");
     code[progp++] = "POP R4\nCLR R3\nBISB @R4,R3\nPUSH R3\n";
}
| VAL '(' sexpr ')'
| BEOF {
     asmcomm("EOF");
     code[progp++] = "CLR R0\n";
     code[progp++] = "CMP @#filepos,@#loaded_sz\n";
     code[progp++] = "BCS " + tostr(locals) + "$\n";
     code[progp++] = "DEC R0\n";
     code[progp++] = tostr(locals++) + "$:PUSH R0\n";
}
| iexpr '+' iexpr {
     asmcomm("i + i");
     code[progp++] = "POP R3\nPOP R4\nADD R3,R4\nPUSH R4\n";
}
| iexpr '-' iexpr {
     asmcomm("i - i");
     code[progp++] = "POP R3\nPOP R4\nSUB R3,R4\nPUSH R4\n";
}
| '-' iexpr %prec NOT {
     asmcomm("-i");
     code[progp++] = "POP R4\nNEG R4\nPUSH R4\n";
}
| '(' iexpr ')'
| iexpr GT iexpr {
     asmcomm("i > i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBGE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr GE iexpr {
     asmcomm("i >= i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBLT " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr LT iexpr {
     asmcomm("i < i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBGE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr LE iexpr {
     asmcomm("i <= i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBGT " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr '=' iexpr {
     asmcomm("i EQ i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBNE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr NE iexpr {
     asmcomm("i <> i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBEQ " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr AND iexpr {
     asmcomm("i AND i");
     code[progp++] = "POP R3\nPOP R4\nCOM R3\nBIC R3,R4\nPUSH R4\n";
  }
| iexpr OR iexpr {
     asmcomm("i OR i");
     code[progp++] = "POP R3\nPOP R4\nBIS R3,R4\nPUSH R4\n";
  }
| sexpr GT sexpr {
     asmcomm("s>s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_GT_s\nPUSH R5\n";
  }
| sexpr GE sexpr {
     asmcomm("s>=s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_GE_S\nPUSH R5\n";
  }
| sexpr LT sexpr {
     asmcomm("s<s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_LT_s\nPUSH R5\n";
  }
| sexpr LE sexpr {
     asmcomm("s<=s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_LE_s\nPUSH R5\n";
  }
| sexpr '=' sexpr {
     asmcomm("s=s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_EQ_s\nPUSH R5\n";
  }
| sexpr NE sexpr {
     asmcomm("s<>s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_NE_s\nPUSH R5\n";
  }
;
sexpr: STRING {
     asmcomm("s");
     if ($1->used == 0) {
        $1->used++;
        data[stringp++] = ".byte " + tostr($1->name->length());
        data[stringp++] = "\n.ascii \"" + *$1->name + "\"\n";
     }
     code[progp++] = "PUSH #";
     reallocs[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = "\n";
  }
| svar {
     asmcomm("sv");
     code[progp++] = "POP R3\nPUSH @R3\n";
  }
| MID '(' sexpr ',' iexpr ')' {
     asmcomm("mid$(s,i)");
     code[progp++] = "POP R4\nPOP R2\nCALL @#midS_s_i\nPUSH R5\n";
  }
| MID '(' sexpr ',' iexpr ',' iexpr ')' {
     asmcomm("mid$(s,i,i)");
     code[progp++] = "POP R3\nPOP R4\nPOP R2\nCALL @#midS_s_i_i\nPUSH R5\n";
   }
| STR '(' iexpr ')' {
     asmcomm("str$(i)");
     code[progp++] = "POP R3\nCALL @#strS_i\nPUSH R5\n";
   }
| INKEY
| STRING '(' iexpr ',' iexpr ')' {
     asmcomm("string$(i,i)");
     code[progp++] = "POP R3\nPOP R4\nCALL @#stringS_i_i\nPUSH R5\n";
   }
| STRING '(' iexpr ',' sexpr ')' {
     asmcomm("string$(i,s)");
     code[progp++] = "POP R3\nPOP R4\nCALL @#stringS_i_S\nPUSH R5\n";
   }
| CHR '(' iexpr ')' {
     asmcomm("chr$(i)");
     code[progp++] = "POP R3\nMOV @#strdcurre,R2\nMOV R2,R5\nMOVB #1,(R2)+\n";
     code[progp++] = "MOVB R3,(R2)+\nMOV R2,@#strdcurre\nCALL @#gc\nPUSH R5\n";
  }
| sexpr '+' sexpr {
     asmcomm("s+s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_PLUS_s\nPUSH R5\n";
  }
;
%%
int lineno = 1;

#include "lex.yy.c"

int yyerror(const string &s) {
   ostringstream oss;
   oss << s << " in " << lineno << endl;
   throw oss.str();
}

main () {
   try {
      initcode();
      yyparse();
   }
   catch (string s) {
      cerr << s << endl;
   }
   catch (int) {
      printcode();
   }
}

