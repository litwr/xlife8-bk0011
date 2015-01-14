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
%left GT GE LT LE EQ NE  //> >= < <= == !=
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
     code[progp++] = "CALL @#";
     reallocl[progp] = $3;
     code[progp++] = "";
   }
| RETURN {code[progp++] = "RETURN\n";}
| markop GOTO NUMBER {
      code[progp++] = "JMP @#";
      reallocl[progp] = $3;
      code[progp++] = "";
   }
| CLS {code[progp++] = "MOV #12,R0\nENT ^O16\n";}
| input
| POKE iexpr ',' iexpr {
      code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
   }
| markop END {code[progp++] = "JMP @#finalfinish\n";}
;
assign: markop ivar '=' iexpr {
     code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
  }
| markop svar '=' sexpr {
     code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
  }
| markop MID '(' svar ',' iexpr ',' iexpr ')' '=' sexpr
| markop MID '(' svar ',' iexpr ')' '=' sexpr
;
print: PRINT prlist
| PRINT '#' prlist
;
prlist: prcomma prlist
| prcomma
| prsemicol prlist
| prsemicol
| pexpr prlist
| pexpr {code[progp++] = "MOV #10,R0\nTOSCREEN\nEMT ^O16\nTOSTRINGCO\n";}
;
pexpr: iexpr {
     code[progp++] = "POP R3\nCALL @#todec\nTOSCREEN\nEMT ^O20\nTOSTRINGCO\n";
  }
| sexpr {
     code[progp++] = "POP R1\nCLR R2\nBISB (R1)+,R2\nBEQ " + tostr(locals + 1)
       + "$\n" + tostr(locals) + "$:MOVB (R1)+,R0\nTOSCREEN\nEMT ^O16\nTOSTRINGCO\nSOB R2," 
       + tostr(locals) + "$\n" + tostr(locals + 1) + "$:\n";
     locals += 2;
  }
//| PBLTIN '(' iexpr ')'
;
prsemicol: pexpr ';' {code[progp++] = "MOV #32,R0\nTOSCREEN\nEMT ^O16\nTOSTRINGCO\n";}
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
   code[progp++] = "TOSCREEN\nPOP R1\nMOVB R1,@#^O56\n";
   code[progp++] = "POP R2\nPOP R1\nEMT ^O24\nTOSTRINGCO\n";            //TOSCREEN?
}
| LOCATE iexpr ',' iexpr {
   code[progp++] = "TOSCREEN\nPOP R2\nPOP R1\nEMT ^O24\nTOSTRINGCO\n";   //TOSCREEN?
}
;
markop: {$$ = progp;}
;
var: ivar
| svar
;
ivar: IVAR {
     code[progp++] = "PUSH #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = "\n";
  }
| IVAR '(' iexpr ')' {
     code[progp++] = "POP R3\nASL R3\nADD #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = ",R3\nPUSH R3\n";
  }
;
svar: SVAR {
     code[progp++] = "PUSH #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = "\n";
  }
| SVAR '(' iexpr ')' {
     code[progp++] = "POP R3\nASL R3\nADD #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = ",R3\nPUSH R3\n";
  }
;
iexpr: NUMBER {
     code[progp++] = "PUSH #" + tostr($1) + "\n";
  }
| ivar {
     code[progp++] = "POP R4\nMOV @R4,R4\nPUSH R4\n";
  }
| FRE '(' iexpr ')'
| FRE '(' sexpr ')'
| PEEK '(' iexpr ')' {
     code[progp++] = "POP R4\nCLR R3\nBISB @R4,R3\nPUSH R3\n";
  }
| ASC '(' sexpr ')' {
     code[progp++] = "POP R4\nCLR R3\nBISB (R4)+,R3\nBEQ " + tostr(locals)
        + "$\nCLR R3\nBISB @R4,R3\n" + tostr(locals) + "$:PUSH R3\n";
     locals++;
  }
| LEN '(' sexpr ')' {
     code[progp++] = "POP R4\nCLR R3\nBISB @R4,R3\nPUSH R3\n";
  }
| VAL '(' sexpr ')'
| iexpr '+' iexpr {
     code[progp++] = "POP R3\nPOP R4\nADD R3,R4\nPUSH R4\n";
  }
| iexpr '-' iexpr {
     code[progp++] = "POP R3\nPOP R4\nSUB R4,R3\nPUSH R3\n";
  }
| '-' iexpr %prec NOT {
     code[progp++] = "POP R4\nNEG R4\nPUSH R4\n";
  }
| '(' iexpr ')'
| iexpr GT iexpr {
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBLE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr GE iexpr {
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBLT " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr LT iexpr {
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBGE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr LE iexpr {
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBGT " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr EQ iexpr {
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBNE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr NE iexpr {
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBEQ " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
  }
| iexpr AND iexpr {
     code[progp++] = "POP R3\nPOP R4\nCOM R3\nBIC R3,R4\nPUSH R4\n";
  }
| iexpr OR iexpr {
     code[progp++] = "POP R3\nPOP R4\nBIS R3,R4\nPUSH R4\n";
  }
| sexpr GT sexpr {}
| sexpr GE sexpr {}
| sexpr LT sexpr {}
| sexpr LE sexpr {}
| sexpr EQ sexpr {}
| sexpr NE sexpr {}
;
sexpr: STRING {
     data[stringp++] = ".byte " + tostr($1->name->length());
     if ($1->name->find("\"") == string::npos)
         data[stringp++] = "\n.ascii \"" + *$1->name + "\"\n";
     else {
         int i;
         stringp--;
         for (i = 0; i < $1->name->length() - 1; i++)
            data[stringp] += "," + tostr((int)(*$1->name)[i]);
         data[stringp++] += "," + tostr((int)(*$1->name)[i]) + "\n";
     }
     code[progp++] = "PUSH #";
     reallocs[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = "\n";
  }
| svar {
     code[progp++] = "POP R3\nMOV @R3,R3\nPUSH R3\n";
  }
| MID '(' sexpr ',' iexpr ')'
| MID '(' sexpr ',' iexpr ',' iexpr ')'
| STR '(' iexpr ')'
| INKEY
| STRING '(' iexpr ',' iexpr ')'
| STRING '(' iexpr ',' sexpr ')'
| CHR '(' iexpr ')' {
     code[progp++] = "POP R3\nMOV @#strdcurre,R2\nMOV R2,R5\nMOVB #1,(R2)+\nMOVB R3,(R2)+\nMOV R2,@#strdcurre\nCALL @#gc\nPUSH R5";
  }
| sexpr '+' sexpr {
     code[progp++] = "POP R3\nPOP R4\nMOV @#strdcurre,R2\nMOV R2,R5\n";
     code[progp++] = "CLR R0\nBISB (R4)+,R0\nMOVB R0,(R2)+\nBEQ " + tostr(locals) +"$\n" 
        + tostr(locals + 1) + "$:MOVB (R4)+,(R2)+\nSOB r0," + tostr(locals + 1)
        + "$\n" + tostr(locals)
        + "$:CLR R0\nBISB (R3)+,R0\nMOVB @R5,R4\nADD R0,R4\nMOVB R4,@r5\nTST R0\nBEQ "
        + tostr(locals + 2) +"$\n" 
        + tostr(locals + 3) + "$:MOVB (R3)+,(R2)+\nSOB r0," + tostr(locals + 3)
        + "$\n" + tostr(locals + 2) + "$:MOV R2,@#strdcurre\nCALL @#gc\nPUSH R5\n";
     locals += 4;
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

