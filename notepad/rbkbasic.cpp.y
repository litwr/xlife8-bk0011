%{
#include <cctype>
#include "rbkbasic.h"
map<int, Symbol*> realloca, reallocs;
map<string, Symbol> names, strings;
map<int, int> reallocl, labels;
int argcount, datalines_count;
string code[100000], data[100000], datalines[10000];
%}
%union {
  Symbol *sym;
  int num;
}
%token <sym> SVAR IVAR STRINGTYPE DATAOPER
%token <num> NUMBER ASC CLS ELSE FRE GOSUB GOTO LEN PRINT NEXT TO STRING
%token <num> FOR IF INPUT LOCATE PEEK POKE RETURN STEP VAL THEN POS END
%token <num> CLOSE OUTPUT BEOF OPEN FIND GET LET LABEL ABS SGN CSRLIN
%token <num> UINT ON STR CHR INKEY MID HEX BIN CLEAR BLOAD BSAVE DEF
%token <num> USR SPC TAB AT INP OUT XOR READ
%type <num> markop then
%left OR XOR
%left AND
%left '=' GT GE LT LE NE
%left '+' '-'
%left '*' '\\' MOD
%right '^'
%left NOT
%%
prog: linenumber operlist {throw 1;}
;
operlist: oper {asmcomm("oper");}
| oper operend operlist {asmcomm("oper operend operlist");}
;
linenumber: LABEL {
    asmcomm("NUMBER");
    code[progp++] = tostr(locals) + "$:\n";
cerr << "label " << $1 << ' ' << locals << endl;
    labels[$1] = locals++;
} 
;
operend: linenumber {asmcomm("linenumber");}
| ':'
;
oper: 
| LET assign
| assign
| print
| for
| if
| locate
| open
| bload
| bsave
| DATAOPER {
    char *p = (char*)$1, *q;
    for (;*p != 0;) {
       while (*p == ' ' || *p == '\t') p++;
       if (*p == '"') {
          q = strchr(++p, '"');
          datalines[datalines_count++].assign(p, q - p);
          p = q + 1;
          while (*p == ' ' || *p == '\t' || *p == ',') p++;
       }
       else
          if (q = strchr(p, ',')) {
             datalines[datalines_count++].assign(p, q - p);
             p = q + 1;
          }
          else {
             datalines[datalines_count++] = p;
             break;
          }
    }
}
| DEF USR '=' iexpr {
     asmcomm("oper -> DEF USR0 = i");
     code[progp++] = "POP @#512+" + tostr(2*$2) + "\n";
}
| CLOSE {
     asmcomm("oper -> CLOSE");
     code[progp++] = "CMPB #2,@#io_op\n";
     code[progp++] = "BNE " + tostr(locals) + "$\n";
     code[progp++] = "MOV @#filepos,R2\nSUB #16384,R2\nMOV R2,@#io_len\n";
     code[progp++] = "CALL @#emt36\n";
     code[progp++] = tostr(locals++) + "$:CLR @#filepos\n";
}
| GOSUB NUMBER {
     asmcomm("oper -> GOSUB NUMBER");
     code[progp++] = "CALL @#";
     reallocl[progp] = $2;
     code[progp++] = "";
}
| RETURN {asmcomm("oper -> RETURN"); code[progp++] = "RETURN\n";}
| GOTO NUMBER {
      asmcomm("oper -> GOTO NUMBER");
      code[progp++] = "JMP @#";
      reallocl[progp] = $2;
      code[progp++] = "";
}
| ON iexpr GOTO {
      asmcomm("oper -> ON i GOTO");
      code[progp++] = tostr(locals + 1) + "$:\n";
      code[progp++] = "BR " + tostr(locals) + "$\n";
} labellist {
      code[progp++] = tostr(locals) + "$:\n";
      code[progp++] = "POP R3\n";
      code[progp++] = "BLE " + tostr(locals + 2) + "$\n";
      code[progp++] = "ASL R3\n";
      code[progp++] = "CMP R3,#" + tostr(locals) + "$-" + tostr(locals + 1) + "$\n";
      code[progp++] = "BCC " + tostr(locals + 2) + "$\n";
      code[progp++] = "JMP @" + tostr(locals + 1) + "$(R3)\n";
      code[progp++] = tostr(locals + 2) + "$:\n";
      locals += 3;
}
| ON iexpr GOSUB {
      asmcomm("oper -> ON i GOSUB");
      argcount = 0;
      code[progp++] = tostr(locals + 1) + "$:\n";
      code[progp++] = "BR " + tostr(locals) + "$\n";
} labellist {
      code[progp++] = tostr(locals) + "$:\n";
      code[progp++] = "POP R3\n";
      code[progp++] = "BLE " + tostr(locals + 2) + "$\n";
      code[progp++] = "ASL R3\n";
      code[progp++] = "CMP R3,#" + tostr(locals) + "$-" + tostr(locals + 1) + "$\n";
      code[progp++] = "BCC " + tostr(locals + 2) + "$\n";
      code[progp++] = "CALL @" + tostr(locals + 1) + "$(R3)\n";
      code[progp++] = tostr(locals + 2) + "$:\n";
      locals += 3;
}
| CLS {asmcomm("oper -> CLS"); code[progp++] = "MOV #12,R0\nCALL @#charout\n";}
| CLEAR iexpr ',' iexpr {
      asmcomm("oper -> CLEAR i,i");
      code[progp++] = "CLR R5\nCALL @#gc\nPOP R1\nPOP R2\nSUB #256,R1\nMOV R1,@#strdmax\n";
}
| input {argcount = 0;}
| read {argcount = 0;}
| GET '#' svar {
      asmcomm("oper -> GET# s");
      code[progp++] = "POP R5\nCALL @#dogetf\n";
}
| FIND sexpr {
      asmcomm("oper -> FIND s");
      code[progp++] = "POP R4\nCALL @#cat\n";
}
| POKE iexpr ',' iexpr {
      asmcomm("oper -> POKE i,i");
      code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
}
| OUT iexpr ',' iexpr ',' iexpr {
      asmcomm("oper -> OUT i,i,i");
      code[progp++] = "POP R3\nPOP R2\nPOP R4\nCOM R2\nBIC R2,R3\nBIS @R4,R3\nMOV R3,@R4\n";
}
| END {code[progp++] = "JMP @#finalfinish\n";}
;
labellist: lablistel
| lablistel ',' labellist
;
lablistel: NUMBER {code[progp++] = ".WORD "; reallocl[progp] = $1; code[progp++] = "";}
;
assign: ivar '=' iexpr {
     asmcomm("ivar ASSIGN i");
     code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
}
| svar '=' svar {
     asmcomm("svar ASSIGN svar");
     code[progp++] = "POP R3\nPOP R4\nMOV @R3,R3\nCALL @#s_ASSIGN_s\n";
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
print: PRINT printnl
| PRINT prdelim prlist {asmcomm("PRINT prdelim prlist");}
| PRINT '#' fprintnl
| PRINT '#' prdelim fprlist
;
prlist: sexpr ',' printstring print2tab prlist
| sexpr prempty printstring prlist
| sexpr printstring printnl
| sexpr ',' printstring print2tab
| sexpr ';' printstring
| iexpr ',' printint print2tab prlist
| iexpr prempty printint printspc prlist
| iexpr printint printnl
| iexpr ',' printint print2tab
| iexpr ';' printint printspc
| pexpr ',' print2tab prlist
| pexpr prempty prlist
| pexpr printnl
| pexpr ',' print2tab
| pexpr ';'
;
pexpr: SPC '(' iexpr ')' {
      code[progp++] = "POP R3\nMOV #32,R0\n";
      code[progp++] = tostr(locals) + "$:CALL @#charout\nSOB R3," + tostr(locals) + "$\n";
      locals++;
}
| TAB '(' iexpr ')' {
      code[progp++] = "POP R3\nCALL @#getcrsr\nSUB R1,R3\nBLOS " + tostr(locals + 1) + "$\nMOV #32,R0\n";
      code[progp++] = tostr(locals) + "$:CALL @#charout\nSOB R3," + tostr(locals) + "$\n" + tostr(locals + 1) + "$:\n";
      locals += 2;
}
| AT '(' iexpr ',' iexpr ')' {
      code[progp++] = "POP R2\nPOP R1\nCALL @#setcrsr\n";
}
;
prempty:
| ';'
;
prdelim: prempty
| ','
;
printnl: {code[progp++] = "MOV #10,R0\nCALL @#charout\n";}
;
printspc: {code[progp++] = "MOV #32,R0\nCALL @#charout\n";}
;
printint: {
     code[progp++] = "POP R3\nCALL @#todec\nCALL @#nstringout\n";
}
;
print2tab: {
     code[progp++] = "CALL @#getcrsr\nMOV #16,R2\nSUB R1,R2\nBIC #65520,R2\nMOVB #32,R0\n";
     code[progp++] = tostr(locals) + "$:CALL @#charout\nSOB R2," + tostr(locals) + "$\n";
     locals++;
}
;
printstring: {
     code[progp++] = "POP R1\nCLR R3\nBISB (R1)+,R3\nBEQ " + tostr(locals + 1)
       + "$\n" + tostr(locals) + "$:MOVB (R1)+,R0\nCALL @#charout\nSOB R3," 
       + tostr(locals) + "$\n" + tostr(locals + 1) + "$:\n";
     locals += 2;
}
;
fprlist: sexpr ',' fprintstring fprint2tab fprlist
| sexpr prempty fprintstring fprlist
| sexpr fprintstring fprintnl
| sexpr ',' fprintstring fprint2tab
| sexpr ';' fprintstring
| iexpr ',' fprintint fprint2tab fprlist
| iexpr prempty fprintint fprintspc fprlist
| iexpr fprintint fprintnl
| iexpr ',' fprintint fprint2tab
| iexpr ';' fprintint fprintspc
| fpexpr ',' fprint2tab fprlist
| fpexpr prempty fprlist
| fpexpr fprintnl
| fpexpr ',' fprint2tab
| fpexpr ';'
;
fpexpr: SPC '(' iexpr ')' {
      code[progp++] = "POP R3\nMOV #32,R0\n";
      code[progp++] = tostr(locals) + "$:CALL @#fcharout\nSOB R3," + tostr(locals) + "$\n";
      locals++;
}
| TAB '(' iexpr ')' {
      code[progp++] = "POP R3\nADD @#eolpos,R3\nSUB @#filepos,R3\nBLOS " + tostr(locals + 1) + "$\nMOV #32,R0\n";
      code[progp++] = tostr(locals) + "$:CALL @#fcharout\nSOB R3," + tostr(locals) + "$\n" + tostr(locals + 1) + "$:\n";
      locals += 2;
}
;
fprintnl: {
     code[progp++] = "MOV #10,R0\nCALL @#fcharout\n";
}
;
fprintint: {
     code[progp++] = "POP R3\nCALL @#todec\nCALL @#fnstringout\n";
}
;
fprintspc: {
     code[progp++] = "MOV #32,R0\nCALL @#fcharout\n";
}
;
fprint2tab: {
     code[progp++] = "MOV @#filepos,R1\nSUB @#eolpos,R1\nMOV R1,R2\nBIC #15,R1\nADD #16,R1\nSUB R2,R1\n";
     code[progp++] = "BLOS " + tostr(locals) + "$\n";
     code[progp++] = "MOV #32,R0\n" + tostr(locals + 1) + "$:CALL @#fcharout\nSOB R1," + tostr(locals + 1) + "$:\n";
     code[progp++] = tostr(locals) + "$:\n";
     locals += 2;
}
;
fprintstring: {
     code[progp++] = "POP R1\nCLR R3\nBISB (R1)+,R3\nBEQ " + tostr(locals + 1)
       + "$\n" + tostr(locals) + "$:MOVB (R1)+,R0\nCALL @#fcharout\nSOB R3," 
       + tostr(locals) + "$\n" + tostr(locals + 1) + "$:\n";
     locals += 2;
}
;
read: READ varlistd {
     asmcomm("read -> READ varlist");
     code[progp++] = "PUSH #" + tostr(argcount*4 + 4) + "\nCALL @#doinput\n";
     code[progp++] = "ADD #" + tostr(argcount*4 + 2) + ",SP\n";
}
;
input: INPUT '#' varlistf {
     asmcomm("input -> INPUT# varlist");
     code[progp++] = "PUSH #" + tostr(argcount*4 + 4) + "\nCALL @#doinput\n";
     code[progp++] = "ADD #" + tostr(argcount*4 + 2) + ",SP\n";
}
| INPUT varlist {
     asmcomm("input -> INPUT varlist");
     code[progp++] = "MOV SP,R3\nCALL @#togglecrsr\n";
     code[progp++] = "PUSH #" + tostr(argcount*4 + 4) + "\nCALL @#doinput\n";
     code[progp++] = "ADD #" + tostr(argcount*4 + 2) + ",SP\n";
}
| INPUT sexpr ';' {
     asmcomm("input -> INPUT s; varlist");
     code[progp++] = "POP R1\nCLR R2\nBISB (R1)+,R2\nCALL @#stringout\n";
} varlist {
     code[progp++] = "MOV SP,R3\nCALL @#togglecrsr\n";
     code[progp++] = "PUSH #" + tostr(argcount*4 + 4) + "\nCALL @#doinput\n";
     code[progp++] = "ADD #" + tostr(argcount*4 + 2) + ",SP\n";
}
;
varlistf: svarf 
| svarf ',' varlistf
| ivarf
| ivarf ',' varlistf
;
svarf: svar {argcount++; code[progp++] = "PUSH #strfromfile\n";}
;
ivarf: ivar {argcount++; code[progp++] = "PUSH #intfromfile\n";}
;
varlist: svark
| svark ',' varlist
| ivark
| ivark ',' varlist
;
svark: svar {argcount++; code[progp++] = "PUSH #strfromkbd\n";}
;
ivark: ivar {argcount++; code[progp++] = "PUSH #intfromkbd\n";}
;
varlistd: svard
| svard ',' varlistd
| ivard
| ivard ',' varlistd
;
svard: svar {argcount++; code[progp++] = "PUSH #strfromdata\n";}
;
ivard: ivar {argcount++; code[progp++] = "PUSH #intfromdata\n";}
;
bload: BLOAD sexpr ',' IVAR ',' iexpr {
     if (*$4->name != "R" && *$4->name != "r") throw "error in BLOAD";
     asmcomm("oper -> BLOAD s,IVAR,i");
     code[progp++] = "POP R5\nPOP R3\nPUSH R5\nCALL @#openread\n";
     code[progp++] = "CALL @#emt36\nPOP R5\nMOV R5,@#" + tostr(locals + 1) + "$+2\n";
     code[progp++] = "MOV #16384,R1\nMOV @#loaded_sz,R2\n";
     code[progp++] = tostr(locals) + "$:TOIO\nMOVB (R1)+,R0\nTOMAIN\nMOVB R0,(R5)+\nSOB R2," + tostr(locals) + "$\n";
     code[progp++] = "CLR @#filepos\n";
     code[progp++] = tostr(locals + 1) + "$:CALL @#0\n";
     locals += 2;
}
| BLOAD sexpr ',' ',' iexpr {
     asmcomm("oper -> BLOAD s,,i");
     code[progp++] = "POP R5\nPOP R3\nPUSH R5\nCALL @#openread\n";
     code[progp++] = "CALL @#emt36\nPOP R5\n";
     code[progp++] = "MOV #16384,R1\nMOV @#loaded_sz,R2\n";
     code[progp++] = tostr(locals) + "$:TOIO\nMOVB (R1)+,R0\nTOMAIN\nMOVB R0,(R5)+\nSOB R2," + tostr(locals) + "$\n";
     code[progp++] = "CLR @#filepos\n";
     locals++;
}
;
bsave: BSAVE sexpr ',' iexpr ',' iexpr {
     asmcomm("oper -> BSAVE s,i,i");
     code[progp++] = "POP R5\nPOP R4\nPOP R3\nPUSH R5\nPUSH R4\nCALL @#openwrite0\n";
     code[progp++] = "POP R4\nPOP R2\nSUB R4,R2\nMOV #16384,R1\nMOV R2,@#io_len\n";
     code[progp++] = tostr(locals) + "$:MOVB (R4)+,R0\nTOIO\nMOVB R0,(R1)+\nTOMAIN\nSOB R2," + tostr(locals) + "$\n";
     code[progp++] = "CALL @#emt36\nCLR @#filepos\n";
     locals++;
}
;
for: markop FOR IVAR '=' iexpr {
     asmcomm("oper -> FOR IVAR = i TO iexpr ...");
     code[progp++] = "POP R3\nMOV R3,@#";
     realloca[progp] = $3;
     code[progp++] = tostr($3->addr);
     code[progp++] = "\n";
} TO iexpr step operend {
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
thenoper: ioperlist
| NUMBER {
     asmcomm("then NUMBER");
     code[progp++] = "JMP @#";
     reallocl[progp] = $1;
     code[progp++] = "";
}
;
elseoper: ioperlist
| NUMBER {
     asmcomm("else NUMBER");
     code[progp++] = "JMP @#";
     reallocl[progp] = $1;
     code[progp++] = "";
}
;
ioperlist: oper
| oper ':' ioperlist
;
locate: LOCATE iexpr ',' iexpr ',' iexpr {
   asmcomm("LOCATE i,i,i");
   code[progp++] = "POP R3\nPOP R2\nPOP R1\n";
   code[progp++] = "CALL @#togglecrsr\nCALL @#setcrsr\n";
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
     asmcomm("i -> NUMBER");
     code[progp++] = "PUSH #" + tostr($1) + "\n";
}
| ivar {
     asmcomm("i -> ivar");
     code[progp++] = "POP R4\nMOV @R4,R4\nPUSH R4\n";
}
| FRE {
     asmcomm("i -> FRE");
     code[progp++] = "MOV @#strdmax,R3\nSUB @#strdcurre,R3\nPUSH R3\n";
}
| FRE '(' iexpr ')' {
     asmcomm("i -> FRE(i)");
     code[progp++] = "POP R3\nMOV @#strdmax,R3\nSUB @#strdcurre,R3\nPUSH R3\n";
}
| FRE '(' sexpr ')' {
     asmcomm("i -> FRE(s)");
     code[progp++] = "POP R5\nCLR R5\nCALL @#gc0\nMOV @#strdmax,R3\nSUB @#strdcurre,R3\nPUSH R3\n";
}
| PEEK '(' iexpr ')' {
     asmcomm("i -> PEEK(i)");
     code[progp++] = "POP R4\nMOV @R4,R3\nPUSH R3\n";
}
| INP '(' iexpr ',' iexpr ')' {
     asmcomm("i -> INP(i,i)");
     code[progp++] = "POP R5\nPOP R4\nMOV @R4,R3\nCOM R5\nBIC R5,R3\nPUSH R3\n";
}
| ABS '(' iexpr ')' {
     asmcomm("i -> ABS(i)");
     code[progp++] = "POP R4\nBPL " + tostr(locals) + "$\nNEG R4\n";
     code[progp++] = tostr(locals++) + "$:PUSH R4\n";
}
| SGN '(' iexpr ')' {
     asmcomm("i -> SGN(i)");
     code[progp++] = "CLR R3\nPOP R4\nBEQ " + tostr(locals) + "$\nBMI " + tostr(locals + 1) + "$\n";
     code[progp++] = "INC R3\nBR " + tostr(locals) + "$\n" + tostr(locals + 1) + "$:DEC R3\n";
     code[progp++] = tostr(locals) + "$:PUSH R3\n";
     locals += 2;
}
| CSRLIN {
     asmcomm("i -> CSRLIN");
     code[progp++] = "CALL @#getcrsr\nPUSH R2\n";
}
| POS {
    asmcomm("i -> POS");
    code[progp++] = "CALL @#getcrsr\nPUSH R1\n";
}
| ASC '(' sexpr ')' {
     asmcomm("i -> ASC(s)");
     code[progp++] = "POP R4\nCLR R3\nBISB (R4)+,R3\nBEQ " + tostr(locals)
        + "$\nCLR R3\nBISB @R4,R3\n" + tostr(locals) + "$:PUSH R3\n";
     locals++;
}
| LEN '(' sexpr ')' {
     asmcomm("i -> LEN(s)");
     code[progp++] = "POP R4\nCLR R3\nBISB @R4,R3\nPUSH R3\n";
}
| VAL '(' sexpr ')' {
     asmcomm("i -> VAL(s)");
     code[progp++] = "POP R4\nCALL @#str2dec\nPUSH R3\n";
}
| BEOF {
     asmcomm("i -> EOF");
     code[progp++] = "CLR R0\n";
     code[progp++] = "CMP @#filepos,@#loaded_sz\n";
     code[progp++] = "BCS " + tostr(locals) + "$\n";
     code[progp++] = "DEC R0\n";
     code[progp++] = tostr(locals++) + "$:PUSH R0\n";
}
| iexpr '*' iexpr {
     asmcomm("i -> i*i");
     code[progp++] = "POP R1\nPOP R2\nCALL @#mul16\nPUSH R0\n";
}
| iexpr '\\' iexpr {
     asmcomm("i -> i\\i");
     code[progp++] = "POP R1\nPOP R2\nCALL @#div16\nPUSH R4\n";
}
| iexpr MOD iexpr {
     asmcomm("i -> i MOD i");
     code[progp++] = "POP R1\nPOP R2\nCALL @#div16\nPUSH R2\n";
}
| iexpr '^' iexpr {
     asmcomm("i -> i^i");
     code[progp++] = "POP R3\nPOP R4\nCALL @#power16\nPUSH R1\n";
}
| iexpr '+' iexpr {
     asmcomm("i -> i + i");
     code[progp++] = "POP R3\nPOP R4\nADD R3,R4\nPUSH R4\n";
}
| iexpr '-' iexpr {
     asmcomm("i -> i - i");
     code[progp++] = "POP R3\nPOP R4\nSUB R3,R4\nPUSH R4\n";
}
| '-' iexpr %prec NOT {
     asmcomm("i -> -i");
     code[progp++] = "POP R4\nNEG R4\nPUSH R4\n";
}
| '(' iexpr ')'
| iexpr GT iexpr {
     asmcomm("i -> i>i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBLE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr GE iexpr {
     asmcomm("i -> i>=i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBLT " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr LT iexpr {
     asmcomm("i -> i<i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBGE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr LE iexpr {
     asmcomm("i -> i<=i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBGT " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr '=' iexpr {
     asmcomm("i -> i EQ i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBNE " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr NE iexpr {
     asmcomm("i -> i<>i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBEQ " + tostr(locals)
        + "$\nINC R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr AND iexpr {
     asmcomm("i -> i AND i");
     code[progp++] = "POP R3\nPOP R4\nCOM R3\nBIC R3,R4\nPUSH R4\n";
}
| iexpr OR iexpr {
     asmcomm("i -> i OR i");
     code[progp++] = "POP R3\nPOP R4\nBIS R3,R4\nPUSH R4\n";
}
| iexpr XOR iexpr {
     asmcomm("i -> i XOR i");
     code[progp++] = "POP R3\nPOP R4\nXOR R3,R4\nPUSH R4\n";
}
| NOT iexpr {
     asmcomm("i -> NOT i");
     code[progp++] = "POP R3\nCOM R3\nPUSH R3\n";
}
| USR '(' iexpr ')' {
     asmcomm("i -> USR(i)");
     code[progp++] = "POP R5\nMOV @#512+" + tostr($1*2) + ",R1\nCALL @R1\nPUSH R5\n";  //linker!
}
| sexpr GT sexpr {
     asmcomm("i -> s>s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_GT_s\nPUSH R5\n";
}
| sexpr GE sexpr {
     asmcomm("i -> s>=s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_GE_S\nPUSH R5\n";
}
| sexpr LT sexpr {
     asmcomm("i -> s<s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_LT_s\nPUSH R5\n";
  }
| sexpr LE sexpr {
     asmcomm("i -> s<=s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_LE_s\nPUSH R5\n";
  }
| sexpr '=' sexpr {
     asmcomm("i -> s=s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_EQ_s\nPUSH R5\n";
  }
| sexpr NE sexpr {
     asmcomm("i -> s<>s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_NE_s\nPUSH R5\n";
  }
;
sexpr: STRINGTYPE {
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
     asmcomm("s -> sv");
     code[progp++] = "POP R3\nPUSH @R3\n";
}
| MID '(' sexpr ',' iexpr ')' {
     asmcomm("s -> mid$(s,i)");
     code[progp++] = "POP R4\nPOP R2\nCALL @#midS_s_i\nPUSH R5\n";
}
| MID '(' sexpr ',' iexpr ',' iexpr ')' {
     asmcomm("s -> mid$(s,i,i)");
     code[progp++] = "POP R3\nPOP R4\nPOP R2\nCALL @#midS_s_i_i\nPUSH R5\n";
}
| STR '(' iexpr ')' {
     asmcomm("s -> str$(i)");
     code[progp++] = "POP R3\nCALL @#strS_i\nPUSH R5\n";
}
| INKEY {
     asmcomm("s -> inkey$");
     code[progp++] = "CALL @#inkeyS\nPUSH R5\n";
}
| STRING '(' iexpr ',' iexpr ')' {
     asmcomm("s -> string$(i,i)");
     code[progp++] = "POP R3\nPOP R4\nCALL @#stringS_i_i\nPUSH R5\n";
}
| STRING '(' iexpr ',' sexpr ')' {
     asmcomm("s -> string$(i,s)");
     code[progp++] = "POP R3\nPOP R4\nCALL @#stringS_i_S\nPUSH R5\n";
}
| CHR '(' iexpr ')' {
     asmcomm("s -> chr$(i)");
     code[progp++] = "POP R3\nMOV @#strdcurre,R2\nMOV R2,R5\nMOVB #1,(R2)+\n";
     code[progp++] = "MOVB R3,(R2)+\nMOV R2,@#strdcurre\nCALL @#gc\nPUSH R5\n";
}
| HEX '(' iexpr ')' {
     asmcomm("s -> hex$(i)");
     code[progp++] = "POP R3\nMOV @#strdcurre,R2\nMOV R2,R5\nMOVB #4,(R2)+\n";
     code[progp++] = "MOV R3,R4\nCLC\nSWAB R4\nRORB R4\nASRB R4\nASRB R4\nASRB R4\nCALL @#hexconv\n";
     code[progp++] = "MOV R3,R4\nSWAB R4\nBIC #240,R4\nCALL @#hexconv\n";
     code[progp++] = "MOV R3,R4\nRORB R4\nASRB R4\nASRB R4\nASRB R4\nCALL @#hexconv\n";
     code[progp++] = "BIC #240,R3\nMOV R3,R4\nCALL @#hexconv\n";
     code[progp++] = "MOV R2,@#strdcurre\nCALL @#gc\nPUSH R5\n";
}
| BIN '(' iexpr ')' {
     asmcomm("s -> bin$(i)");
     code[progp++] = "POP R3\nMOV @#strdcurre,R2\nMOV R2,R5\nMOV #16,R4\nMOVB R4,(R2)+\n";
     code[progp++] = tostr(locals) + "$:MOV #'0,R0\nASL R3\nBCC " + tostr(locals + 1);
     code[progp++] = "$\nINC R0\n" + tostr(locals + 1) + "$:MOVB R0,(R2)+\nSOB R4," + tostr(locals);
     code[progp++] = "$\nMOV R2,@#strdcurre\nCALL @#gc\nPUSH R5\n";
     locals += 2;
}
| UINT '(' iexpr ')' {
     asmcomm("s -> uint$(i)");
     code[progp++] = "POP R3\nMOV @#strdcurre,R5\nINC R5\nPUSH R5\nCALL @#todec0\nMOV @#strdcurre,R3\nMOV R5,R4\nSUB (SP)+,R4\n";
     code[progp++] = "MOV R5,@#strdcurre\nMOVB R4,@R3\nMOV R3,R5\nCALL @#gc\nPUSH R5\n";
}
| sexpr '+' sexpr {
     asmcomm("s -> s+s");
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_PLUS_s\nPUSH R5\n";
}
| USR '(' sexpr ')' {
     asmcomm("s -> USR(s)");
     code[progp++] = "POP R5\nMOV @#512+" + tostr($1*2) + ",R1\nCALL @R1\nPUSH R5\n";  //linker!
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
//   yydebug = 1;
   try {
      initcode();
      yyparse();
   }
   catch (string s) {
      cerr << s << endl;
   }
   catch (int) {
      relocate(); 
      printcode();
   }
}

