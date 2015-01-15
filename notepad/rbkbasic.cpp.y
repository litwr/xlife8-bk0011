%{
#include <cctype>
#include "rbkbasic.h"
map<int, Symbol*> realloca, reallocs;
map<string, Symbol> names, strings;
map<int, int> reallocl, labels;
string code[100000], data[100000];
%}
%union {
  Symbol *sym;
  int num;
}
%token <sym> SVAR IVAR STR STRING CHR INKEY MID 
%token <num> NUMBER ASC CLS ELSE FRE GOSUB GOTO LEN PRINT NEXT TO
%token <num> FOR IF INPUT LOCATE PEEK POKE RETURN STEP VAL THEN POS END
%type <sym> var ivar svar
%type <num> oper operlist assign print for if locate input markop then
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
| markop GOSUB NUMBER {
     asmcomm("GOSUB NUMBER");
     code[progp++] = "CALL @#";
     reallocl[progp] = $3;
     code[progp++] = "";
   }
| RETURN {asmcomm("RETURN"); code[progp++] = "RETURN\n";}
| markop GOTO NUMBER {
      asmcomm("GOTU NUMBER");
      code[progp++] = "JMP @#";
      reallocl[progp] = $3;
      code[progp++] = "";
   }
| CLS {asmcomm("CLS"); code[progp++] = "MOV #12,R0\nCALL @#charout\n";}
| input
| POKE iexpr ',' iexpr {
      asmcomm("POKE i,i");
      code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
   }
| markop END {code[progp++] = "JMP @#finalfinish\n";}
;
assign: markop ivar '=' iexpr {
     asmcomm("ivar ASSIGN i");
     code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
  }
| markop svar '=' sexpr {
     asmcomm("svar ASSIGN s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_ASSIGN_s\n";
  }
| markop MID '(' svar ',' iexpr ',' iexpr ')' '=' sexpr {
     asmcomm("MID$(s,i,i)");
     code[progp++] = "POP R1\nPOP R2\nPOP R3\nPOP R4\nCALL @#midS_s_i_i_s\n";
  }
| markop MID '(' svar ',' iexpr ')' '=' sexpr {
     asmcomm("MID$(s,i)");
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
     code[progp++] = "POP R3\nCALL @#todec\nCALL @#strout\n";
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
| INPUT '#' varlist
| INPUT sexpr ';' varlist
;
varlist: var
| var ',' varlist
;
for: markop FOR IVAR '=' iexpr {
     asmcomm("FOR");
     code[progp++] = "POP R3\nMOV R3,@#";
     realloca[progp] = $3;
     code[progp++] = tostr($3->addr);
     code[progp++] = "\n";
  } TO iexpr step '\n' {
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1] = locals++;
  } operlist next {
     code[progp++] = "MOVB #7,R3\n";   //BLE
     code[progp++] = "TST @SP\n";
     code[progp++] = "BPL " + tostr(locals) + "$\n";
     code[progp++] = "MOVB #4,R3\n";   //BGE
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
     reallocl[progp] = -$1;
     code[progp++] = "";
     code[progp++] = "ADD #4,SP\n";
  }
;
next: NEXT IVAR
| NEXT
;
step: {code[progp++] = "PUSH #1\n";}
| STEP iexpr
;
if: markop IF iexpr then thenoper {
     asmcomm("IF");
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$4] = locals++;
   }
| markop IF iexpr then thenoper ELSE {
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
     code[progp++] = "POP R3\nTST R3\n";
     code[progp++] = "BEQ ";
     reallocl[progp] = -$1;
     code[progp++] = "";
     code[progp++] = "JMP @#";
     reallocl[progp] = $5;
     code[progp++] = "";
     code[progp++] = "BR ";
     reallocl[progp] = -$1 - 100000;
     code[progp++] = "";
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1] = locals++;
   } elseoper {
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1 - 100000] = locals++;
   }
;
then: THEN {
     code[progp++] = "POP R3\nTST R3\n";
     code[progp++] = "BEQ ";
     reallocl[progp] = -$1;
     code[progp++] = "";
   }
;
thenoper: oper
| NUMBER {
     code[progp++] = "JMP @#";
     reallocl[progp] = $1;
     code[progp++] = "";
   }
;
elseoper: oper
| NUMBER {
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
markop: {$$ = progp;}
;
var: ivar
| svar
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
| FRE '(' iexpr ')'
| FRE '(' sexpr ')'
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
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBLE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr GE iexpr {
     asmcomm("i >= i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBLT " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr LT iexpr {
     asmcomm("i < i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBGE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr LE iexpr {
     asmcomm("i <= i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBGT " + tostr(locals)
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
     code[progp++] = "POP R3\nMOV @R3,R3\nPUSH R3\n";
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
     code[progp++] = "POP R3\nMOV @#strdcurre,R2\nMOV R2,R5\nMOVB #1,(R2)+\nMOVB R3,(R2)+\nMOV R2,@#strdcurre\nCALL @#gc\nPUSH R5\n";
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

