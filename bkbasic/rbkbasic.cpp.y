%{
#include <cctype>
#include "rbkbasic.h"
map<int, Symbol*> realloca, reallocs;
map<string, Symbol> names, strings;
map<int, int> reallocl, labels, datalabels, dataprogp;
map<string,int> used_code;
int argcount, datalines_count, dataline, dataoffset, fnep, deffn = -1, callfn = -1;
string code[100000], data[100000], datalines[10000];
Symbol *ptempsymb;
%}
%union {
  Symbol *sym;
  int num;
}
%token <sym> SVAR IVAR FSVAR FIVAR SFN IFN STRINGTYPE DATAOPER
%token <num> NUMBER ASC CLS ELSE FRE GOSUB GOTO LEN PRINT NEXT TO STRING
%token <num> FOR IF INPUT LOCATE PEEK POKE RETURN STEP VAL THEN POS END
%token <num> CLOSE OUTPUT BEOF OPEN FIND GET LET LABEL ABS SGN CSRLIN FN
%token <num> UINT ON STR CHR INKEY MID HEX BIN CLEAR BLOAD BSAVE DEF USR
%token <num> SPC TAB AT INP OUT XOR READ RESTORE DEC INSTR IMP EQV UPPER
%token <num> VARPTR DIM OCT BEEP COLOR
%type <num> then
%left IMP EQV
%left OR XOR
%left AND
%left '=' GT GE LT LE NE
%left '+' '-'
%left '*' '\\' MOD
%right '^'
%left NOT
%%
prog: linenumber operlist {
   cerr << endl;  //finishes translated line numbers
   throw 1;
}
;
operlist: oper {asmcomm("oper");}
| oper operend operlist {asmcomm("oper operend operlist");}
;
linenumber: LABEL {
    asmcomm("NUMBER");
    code[progp++] = tostr(locals) + "$:\n";
cerr << $1 << " "; //shows translated line numbers
    labels[dataline = $1] = locals++;
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
| def fnihead fnibody
| def fnshead fnsbody
| DIM arraylist
| DATAOPER {
    char *p = (char*)$1, *q;
    if (datalabels.find(dataline) == datalabels.end()) datalabels[dataline] = dataoffset;
    for (;*p != 0;) {
       while (*p == ' ' || *p == '\t') p++;
       if (*p == '"') {
          q = strchr(++p, '"');
          dataoffset += q - p + 1;
          datalines[datalines_count++].assign(p, q - p);
          p = q + 1;
          while (*p == ' ' || *p == '\t' || *p == ',') p++;
       }
       else
          if (q = strchr(p, ',')) {
             dataoffset += q - p + 1;
             datalines[datalines_count++].assign(p, q - p);
             p = q + 1;
          }
          else {
             dataoffset += strlen(p) + 1;
             datalines[datalines_count++] = p;
             break;
          }
    }
}
| RESTORE {
     asmcomm("oper -> RESTORE");
     code[progp++] = "MOV #datastart,@#datapos\n";
}
| RESTORE NUMBER {
     asmcomm("oper -> RESTORE NUMBER");
     dataprogp[progp++] = $2;
}
| DEF USR '=' iexpr {
     asmcomm("oper -> DEF USR0 = i");
     code[progp++] = "POP @#512+" + tostr(2*$2) + "\n";
}
| CLOSE {
     asmcomm("oper -> CLOSE");
     used_code["emt36"] = 1;
     code[progp++] = "CMPB #2,@#io_op\n";
     code[progp++] = "BNE " + tostr(locals) + "$\n";
     code[progp++] = "MOV @#filepos,R2\nSUB #16384,R2\nMOV R2,@#io_len\n";
     code[progp++] = "CALL @#emt36\n";
     code[progp++] = tostr(locals++) + "$:CLR @#filepos\n";
}
| GOSUB NUMBER {
     asmcomm("oper -> GOSUB NUMBER");
     code[progp++] = "CALL @#";
     reallocl[progp++] = $2;
}
| RETURN {asmcomm("oper -> RETURN"); code[progp++] = "RETURN\n";}
| GOTO NUMBER {
      asmcomm("oper -> GOTO NUMBER");
      code[progp++] = "JMP @#";
      reallocl[progp++] = $2;
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
| BEEP {asmcomm("oper -> BEEP"); code[progp++] = "MOV #7,R0\nCALL @#charout\n";}
| CLEAR iexpr ',' iexpr {
     asmcomm("oper -> CLEAR i,i");
     used_code["gc"] = 1;
     code[progp++] = "CLR R5\nCALL @#gc0\nPOP R1\nPOP R2\nSUB #256,R1\nMOV R1,@#strdmax\n";
}
| input {argcount = 0;}
| read {argcount = 0;}
| GET '#' svar {
     asmcomm("oper -> GET# s");
     used_code["dogetf"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R5\nCALL @#dogetf\n";
}
| FIND sexpr {
     asmcomm("oper -> FIND s");
     used_code["cat"] = 1;
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
| COLOR iexpr ',' iexpr {
      asmcomm("oper -> COLOR i,i");
      code[progp++] = "POP R3\nPOP R4\nASL R3\nMOV COLORS(R3),@#138\nASL R4\nMOV COLORS(R4),R4\nBNE " + tostr(locals) + "$\n";
      code[progp++] = "MOV @#138,R4\n" + tostr(locals++) + "$:MOV R4,@#140\n";
}
| COLOR iexpr {
      asmcomm("oper -> COLOR i");
      code[progp++] = "POP R4\nASL R4\nMOV COLORS(R4),R4\nBNE " + tostr(locals) + "$\n";
      code[progp++] = "MOV @#138,R4\n" + tostr(locals) + "$:MOV R4,@#140\n";
}
| COLOR ',' iexpr {
      asmcomm("oper -> COLOR ,i");
      code[progp++] = "POP R3\nASL R3\nMOV COLORS(R3),@#138\n";
}
| END {code[progp++] = "JMP @#finalfinish\n";}
;
labellist: lablistel
| lablistel ',' labellist
;
lablistel: NUMBER {code[progp++] = ".WORD "; reallocl[progp++] = $1;}
;
arraylist: array
| array ',' arraylist
;
array: IVAR '(' NUMBER ')' {
   ivarp += 2*($3 - 1);
}
| SVAR '(' NUMBER ')' {
   svarp += 2*($3 - 1);
}
assign: ivar '=' iexpr {
     asmcomm("ivar ASSIGN i");
     code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
}
| svar '=' svar {
     asmcomm("svar ASSIGN svar");
     used_code["string"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nPOP R4\nMOV @R3,R3\nCALL @#s_ASSIGN_s\n";
}
| svar '=' sexpr {
     asmcomm("svar ASSIGN s");
     code[progp++] = "POP R3\nPOP R4\nMOV R3,@R4\n";
}
| MID '(' svar ',' iexpr ',' iexpr ')' '=' sexpr {
     asmcomm("MID$(s,i,i,s)");
     used_code["midS_s_i_i_s"] = 1;
     code[progp++] = "POP R1\nPOP R2\nPOP R3\nPOP R4\nCALL @#midS_s_i_i_s\n";
}
| MID '(' svar ',' iexpr ')' '=' sexpr {
     asmcomm("MID$(s,i,s)");
     used_code["midS_s_i_s"] = 1;
     code[progp++] = "POP R1\nPOP R3\nPOP R4\nCALL @#midS_s_i_s\n";
}
;
def: DEF FN {deffn = 0;}
;
fnihead: IFN fnheadmain
;
fnshead: SFN fnheadmain
;
fnheadmain: fnparams '=' {
    deffn = -2;
    code[progp++] = "BR " + tostr(fnep = locals++) + "$\n";
    code[progp++] = tostr(locals) + "$:\n";
    $<sym>0->addr = locals++;
}
;
fnibody: iexpr fnbodymain
;
fnsbody: sexpr fnbodymain
;
fnbodymain: {
    code[progp++] = "POP R5\nRETURN\n";
    deffn = -1;
    code[progp++] = tostr(fnep) + "$:\n";
}
;
fnparams:
| '(' fnparlist ')'
;
fnparlist: fnvar
| fnvar ',' fnparlist
;
fnvar: FSVAR | FIVAR
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
     used_code["getcrsr"] = 1;
     code[progp++] = "POP R3\nCALL @#getcrsr\nSUB R1,R3\nBLOS " + tostr(locals + 1) + "$\nMOV #32,R0\n";
     code[progp++] = tostr(locals) + "$:CALL @#charout\nSOB R3," + tostr(locals) + "$\n" + tostr(locals + 1) + "$:\n";
     locals += 2;
}
| AT '(' iexpr ',' iexpr ')' {
     used_code["setcrsr"] = 1;
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
     used_code["nstringout"] = 1;
     code[progp++] = "POP R3\nCALL @#nstringout\n";
}
;
print2tab: {
     used_code["getcrsr"] = 1;
     code[progp++] = "CALL @#getcrsr\nMOV #16,R2\nSUB R1,R2\nBIC #65520,R2\nBNE " + tostr(locals) + "$\n";
     code[progp++] = "MOV #16,R2\n" + tostr(locals++) + "$:MOVB #32,R0\n";
     code[progp++] = tostr(locals) + "$:CALL @#charout\nSOB R2," + tostr(locals) + "$\n";
     locals++;
}
;
printstring: {
     code[progp++] = "POP R1\nCALL @#xstringout\n";
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
     used_code["fcharout"] = 1;
     code[progp++] = "POP R3\nMOV #32,R0\n";
     code[progp++] = tostr(locals) + "$:CALL @#fcharout\nSOB R3," + tostr(locals) + "$\n";
     locals++;
}
| TAB '(' iexpr ')' {
     used_code["fcharout"] = 1;
     code[progp++] = "POP R3\nADD @#eolpos,R3\nSUB @#filepos,R3\nBLOS " + tostr(locals + 1) + "$\nMOV #32,R0\n";
     code[progp++] = tostr(locals) + "$:CALL @#fcharout\nSOB R3," + tostr(locals) + "$\n" + tostr(locals + 1) + "$:\n";
     locals += 2;
}
;
fprintnl: {
     used_code["fcharout"] = 1;
     code[progp++] = "MOV #10,R0\nCALL @#fcharout\n";
}
;
fprintint: {
     used_code["fnstringout"] = 1;
     used_code["todec"] = 1;
     code[progp++] = "POP R3\nCALL @#fnstringout\n";
}
;
fprintspc: {
     used_code["fcharout"] = 1;
     code[progp++] = "MOV #32,R0\nCALL @#fcharout\n";
}
;
fprint2tab: {
     used_code["fcharout"] = 1;
     code[progp++] = "MOV @#filepos,R1\nSUB @#eolpos,R1\nMOV R1,R2\nBIC #15,R1\nADD #16,R1\nSUB R2,R1\n";
     code[progp++] = "BLOS " + tostr(locals) + "$\n";
     code[progp++] = "MOV #32,R0\n" + tostr(locals + 1) + "$:CALL @#fcharout\nSOB R1," + tostr(locals + 1) + "$:\n";
     code[progp++] = tostr(locals) + "$:\n";
     locals += 2;
}
;
fprintstring: {
     used_code["fcharout"] = 1;
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
     used_code["togglecrsr"] = 1;
     code[progp++] = "MOV SP,R3\nCALL @#togglecrsr\n";
     code[progp++] = "PUSH #" + tostr(argcount*4 + 4) + "\nCALL @#doinput\n";
     code[progp++] = "ADD #" + tostr(argcount*4 + 2) + ",SP\n";
}
| INPUT sexpr ';' {
     asmcomm("input -> INPUT s; varlist");
     used_code["togglecrsr"] = 1;
     code[progp++] = "POP R1\nCALL @#xstringout\n";
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
svarf: svar {
     used_code["strfromfile"] = 1;
     used_code["gc"] = 1;
     argcount++;
     code[progp++] = "PUSH #strfromfile\n";}
;
ivarf: ivar {
     used_code["intfromfile"] = 1;
     argcount++;
     code[progp++] = "PUSH #intfromfile\n";
}
;
varlist: svark
| svark ',' varlist
| ivark
| ivark ',' varlist
;
svark: svar {
     used_code["strfromkbd"] = 1;
     used_code["gc"] = 1;
     argcount++;
     code[progp++] = "PUSH #strfromkbd\n";
}
;
ivark: ivar {
     used_code["intfromkbd"] = 1;
     argcount++;
     code[progp++] = "PUSH #intfromkbd\n";}
;
varlistd: svard
| svard ',' varlistd
| ivard
| ivard ',' varlistd
;
svard: svar {
     used_code["strfromdata"] = 1;
     used_code["gc"] = 1;
     argcount++;
     code[progp++] = "PUSH #strfromdata\n";
}
;
ivard: ivar {
     used_code["intfromdata"] = 1;
     argcount++; code[progp++] = "PUSH #intfromdata\n";
}
;
bload: BLOAD sexpr ',' IVAR ',' iexpr {
     asmcomm("oper -> BLOAD s,r,i");
     used_code["openread"] = 1;
     used_code["emt36"] = 1;
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
     used_code["openread"] = 1;
     used_code["emt36"] = 1;
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
     used_code["openwrite"] = 1;
     used_code["emt36"] = 1;
     code[progp++] = "POP R5\nPOP R4\nPOP R3\nPUSH R5\nPUSH R4\nCALL @#openwrite0\n";
     code[progp++] = "POP R4\nPOP R2\nSUB R4,R2\nMOV #16384,R1\nMOV R2,@#io_len\n";
     code[progp++] = tostr(locals) + "$:MOVB (R4)+,R0\nTOIO\nMOVB R0,(R1)+\nTOMAIN\nSOB R2," + tostr(locals) + "$\n";
     code[progp++] = "CALL @#emt36\nCLR @#filepos\n";
     locals++;
}
;
for: FOR IVAR '=' iexpr {
     asmcomm("oper -> FOR IVAR = i TO iexpr ...");
     code[progp++] = "POP @#";
     realloca[progp++] = $2;
     code[progp++] = "\n";
} TO iexpr step {
     asmcomm("TO of FOR");
     code[progp++] = "POP @#";
     reallocl[progp++] = -$1 - 1;
     code[progp++] = "POP @#";
     reallocl[progp++] = -$1 - 2;
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1] = locals++;
} operend operlist next {
     asmcomm("NEXT of FOR");
     code[progp++] = ".WORD 26079\n"; //ADD #step,@#IVAR
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1 - 1] = locals;
     code[progp++] = ".WORD 0,";
     realloca[progp++] = $2;
     code[progp++] = "\n";

     code[progp++] = "MOV @#"; //
     realloca[progp++] = $2;
     code[progp++] = ",R3\n";

     code[progp++] = ".WORD 58819\n"; //SUB #limit,R3
     code[progp++] = tostr(locals + 1) + "$:\n";
     labels[-$1 - 2] = locals + 1;
     code[progp++] = ".WORD 0\n";
     code[progp++] = "BEQ " + tostr(locals + 2) + "$\n";

     code[progp++] = "MOV @#";
     code[progp++] = tostr(locals) + "$,R4\n";
     code[progp++] = "XOR R3,R4\n";
     code[progp++] = "BPL " + tostr(locals + 3) + "$\n";
     code[progp++] = tostr(locals + 2) + "$:\n";
     code[progp++] = "JMP @#" + tostr(labels[-$1]) + "$\n";
     code[progp++] = tostr(locals + 3) + "$:\n";
     locals += 4;
}
;
next: NEXT IVAR
| NEXT
;
step: {code[progp++] = "PUSH #1\n";}
| STEP iexpr
;
if: IF iexpr then thenoper {
     asmcomm("IF THEN thenoper");
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$3] = locals++;
}
| IF iexpr then thenoper ELSE {
     asmcomm("IF THEN thenoper ELSE");
     code[progp++] = "BR ";
     reallocl[progp++] = -$1;
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$3] = locals++;
} elseoper {
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1] = locals++;
}
| IF iexpr GOTO NUMBER {
     asmcomm("IF GOTO NUMBER");
     code[progp++] = "POP R3\nTST R3\n";
     code[progp++] = "BEQ ";
     reallocl[progp++] = -$1;
     code[progp++] = "JMP @#";
     reallocl[progp++] = $4;
     code[progp++] = tostr(locals) + "$:\n";
     labels[-$1] = locals++;
}
| IF iexpr GOTO NUMBER ELSE {
     asmcomm("IF GOTO NUMBER ELSE");
     code[progp++] = "POP R3\nTST R3\n";
     code[progp++] = "BEQ ";
     reallocl[progp++] = -$1;
     code[progp++] = "JMP @#";
     reallocl[progp++] = $4;
     code[progp++] = "BR ";
     reallocl[progp++] = -$1 - 10000;
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
     reallocl[progp++] = -$1;
}
;
thenoper: ioperlist
| NUMBER {
     asmcomm("then NUMBER");
     code[progp++] = "JMP @#";
     reallocl[progp++] = $1;
}
;
elseoper: ioperlist
| NUMBER {
     asmcomm("else NUMBER");
     code[progp++] = "JMP @#";
     reallocl[progp++] = $1;
}
;
ioperlist: oper
| oper ':' ioperlist
;
locate: LOCATE iexpr ',' iexpr ',' iexpr {
     asmcomm("LOCATE i,i,i");
     used_code["togglecrsr"] = 1;
     used_code["setcrsr"] = 1;
     code[progp++] = "POP R3\nPOP R2\nPOP R1\n";
     code[progp++] = "CALL @#togglecrsr\nCALL @#setcrsr\n";
}
| LOCATE iexpr ',' iexpr {
     asmcomm("LOCATE i,i");
     used_code["setcrsr"] = 1;
     code[progp++] = "POP R2\nPOP R1\nCALL @#setcrsr\n";
}
;
open: OPEN sexpr {
     asmcomm("OPEN s");
     used_code["emt36"] = 1;
     used_code["openread"] = 1;
     code[progp++] = "POP R3\nCALL @#openread\nCALL @#emt36\nADD #16384,@#loaded_sz\n";
}
| OPEN sexpr FOR INPUT {
     asmcomm("OPEN s FOR INPUT");
     used_code["emt36"] = 1;
     used_code["openread"] = 1;
     code[progp++] = "POP R3\nCALL @#openread\nCALL @#emt36\nADD #16384,@#loaded_sz\n";
}
| OPEN sexpr FOR OUTPUT {
     asmcomm("OPEN s FOR OUTPUT");
     used_code["openwrite"] = 1;
     code[progp++] = "POP R3\nCALL @#openwrite\n";
}
;
ivar: ivar1
| IVAR '(' iexpr ')' {
     asmcomm("IVAR(i)");
     code[progp++] = "POP R3\nASL R3\nADD #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = ",R3\nPUSH R3\n";
}
;
ivar1: IVAR var1body
| FIVAR fvar1body
;
var1body: {
     asmcomm("var1body");
     code[progp++] = "PUSH #";
     realloca[progp] = $<sym>0;
     code[progp++] = tostr($<sym>0->addr);
     code[progp++] = "\n";
}
;
fvar1body: {
     code[progp++] = "MOV @#baseptr,R4\nSUB #" + tostr($<sym>0->addr*2) + ",R4\nPUSH R4\n";
}
;
svar: svar1
| SVAR '(' iexpr ')' {
     asmcomm("SVAR(i)");
     code[progp++] = "POP R3\nASL R3\nADD #";
     realloca[progp] = $1;
     code[progp++] = tostr($1->addr);
     code[progp++] = ",R3\nPUSH R3\n";
}
;
svar1: SVAR var1body
| FSVAR fvar1body
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
     used_code["gc"] = 1;
     code[progp++] = "POP R5\nCLR R5\nCALL @#gc0\nMOV @#strdmax,R3\nSUB @#strdcurre,R3\nPUSH R3\n";
}
| PEEK '(' iexpr ')' {
     asmcomm("i -> PEEK(i)");
     code[progp++] = "POP R4\nPUSH @R4\n";
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
     used_code["getcrsr"] = 1;
     code[progp++] = "CALL @#getcrsr\nPUSH R2\n";
}
| POS {
     asmcomm("i -> POS");
     used_code["getcrsr"] = 1;
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
     used_code["str2dec"] = 1;
     code[progp++] = "POP R4\nCALL @#str2dec\nPUSH R3\n";
}
| DEC '(' sexpr ')' {
     asmcomm("i -> DEC(s)");
     used_code["hex2dec"] = 1;
     code[progp++] = "POP R4\nCALL @#hex2dec\nPUSH R1\n";
}
| INSTR '(' sexpr ',' sexpr ')' {
     asmcomm("i -> INSTR(s,s)");
     used_code["instr"] = 1;
     code[progp++] = "POP R3\nPOP R4\nMOV #1,R2\nCALL @#instr\nPUSH R0\n";
}
| INSTR '(' iexpr ',' sexpr ',' sexpr ')' {
     asmcomm("i -> INSTR(i,s,s)");
     used_code["instr"] = 1;
     code[progp++] = "POP R3\nPOP R4\nPOP R2\nCALL @#instr\nPUSH R0\n";
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
     used_code["mul16"] = 1;
     code[progp++] = "POP R1\nPOP R2\nCALL @#mul16\nPUSH R0\n";
}
| iexpr '\\' iexpr {
     asmcomm("i -> i\\i");
     used_code["div16"] = 1;
     code[progp++] = "POP R1\nPOP R2\nCALL @#div16\nPUSH R4\n";
}
| iexpr MOD iexpr {
     asmcomm("i -> i MOD i");
     used_code["div16"] = 1;
     code[progp++] = "POP R1\nPOP R2\nCALL @#div16\nPUSH R2\n";
}
| iexpr '^' iexpr {
     asmcomm("i -> i^i");
     used_code["power16"] = 1;
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
        + "$\nCOM R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr GE iexpr {
     asmcomm("i -> i>=i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBLT " + tostr(locals)
        + "$\nCOM R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr LT iexpr {
     asmcomm("i -> i<i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBGE " + tostr(locals)
        + "$\nCOM R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr LE iexpr {
     asmcomm("i -> i<=i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R4,R3\nBGT " + tostr(locals)
        + "$\nCOM R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr '=' iexpr {
     asmcomm("i -> i EQ i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBNE " + tostr(locals)
        + "$\nCOM R5\n" + tostr(locals) + "$:PUSH R5\n";
     locals++;
}
| iexpr NE iexpr {
     asmcomm("i -> i<>i");
     code[progp++] = "POP R3\nPOP R4\nCLR R5\nCMP R3,R4\nBEQ " + tostr(locals)
        + "$\nCOM R5\n" + tostr(locals) + "$:PUSH R5\n";
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
| iexpr IMP iexpr {
     asmcomm("i -> i IMP i");
     code[progp++] = "POP R3\nPOP R4\nCOM R4\nBIS R3,R4\nPUSH R4\n";
}
| iexpr EQV iexpr {
     asmcomm("i -> i IMP i");
     code[progp++] = "POP R3\nPOP R4\nXOR R3,R4\nCOM R4\nPUSH R4\n";
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
     used_code["s_GT_s"] = 1;
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_GT_s\nPUSH R5\n";
}
| sexpr GE sexpr {
     asmcomm("i -> s>=s");
     used_code["s_GE_s"] = 1;
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_GE_S\nPUSH R5\n";
}
| sexpr LT sexpr {
     asmcomm("i -> s<s");
     used_code["s_LT_s"] = 1;
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_LT_s\nPUSH R5\n";
}
| sexpr LE sexpr {
     asmcomm("i -> s<=s");
     used_code["s_LE_s"] = 1;
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_LE_s\nPUSH R5\n";
}
| sexpr '=' sexpr {
     asmcomm("i -> s=s");
     used_code["s_EQ_s"] = 1;
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_EQ_s\nPUSH R5\n";
}
| sexpr NE sexpr {
     asmcomm("i -> s<>s");
     used_code["s_NE_s"] = 1;
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_NE_s\nPUSH R5\n";
}
| VARPTR '(' ivar1 ')'
| VARPTR '(' svar1 ')'
| fn IFN fncmain
;
fn: FN {callfn = 0;}
;
fncmain: fncparams {
     asmcomm("i -> fn IFN()");
     if (deffn == -2)
        code[progp++] = "PUSH @#baseptr\nMOV SP,R4\nADD #" + tostr(callfn*2) + ",R4\n";
     else
        code[progp++] = "MOV SP,R4\nADD #" + tostr(callfn*2 - 2) + ",R4\n";
     code[progp++] = "MOV R4,@#baseptr\n";
     code[progp++] = "CALL @#" + tostr($<sym>0->addr) + "$\n";
     if (deffn == -2)
        code[progp++] = "POP @#baseptr\n";
     if (callfn > 1)
        code[progp++] = "ADD #" + tostr(callfn*2 - 2) + ",SP\n";
     code[progp++] = "PUSH R5\n";
     callfn = -1;
}
;
fncparams:
| '(' fncparlist ')'
;
fncparlist: fncpar {callfn++;}
| fncpar ',' fncparlist {callfn++;}
;
fncpar: iexpr | sexpr
;
sexpr: STRINGTYPE {
     asmcomm("s");
     if ($1->len > 0) {
        if ($1->used == 0) {
           $1->used++;
           data[stringp++] = ".byte " + tostr($1->len);
           data[stringp++] = "\n.ascii \"" + *$1->name + "\"\n";
        }
        code[progp++] = "PUSH #";
        reallocs[progp] = $1;
        code[progp++] = tostr($1->addr);
        code[progp++] = "\n";
     }
     else
        code[progp++] = "PUSH #strestatic\n";
}
| svar {
     asmcomm("s -> sv");
     code[progp++] = "POP R3\nPUSH @R3\n";
}
| MID '(' sexpr ',' iexpr ')' {
     asmcomm("s -> mid$(s,i)");
     used_code["midS_s_i"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R4\nPOP R2\nCALL @#midS_s_i\nPUSH R5\n";
}
| MID '(' sexpr ',' iexpr ',' iexpr ')' {
     asmcomm("s -> mid$(s,i,i)");
     used_code["midS_s_i_i"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nPOP R4\nPOP R2\nCALL @#midS_s_i_i\nPUSH R5\n";
}
| STR '(' iexpr ')' {
     asmcomm("s -> str$(i)");
     used_code["strS_i"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nCALL @#strS_i\nPUSH R5\n";
}
| INKEY {
     asmcomm("s -> inkey$");
     used_code["inkeyS"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "CALL @#inkeyS\nPUSH R5\n";
}
| STRING '(' iexpr ',' iexpr ')' {
     asmcomm("s -> string$(i,i)");
     used_code["string"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nPOP R4\nCALL @#stringS_i_i\nPUSH R5\n";
}
| STRING '(' iexpr ',' sexpr ')' {
     asmcomm("s -> string$(i,s)");
     used_code["string"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nPOP R4\nCALL @#stringS_i_S\nPUSH R5\n";
}
| CHR '(' iexpr ')' {
     asmcomm("s -> chr$(i)");
     used_code["gc"] = 1;
     used_code["exitstring"] = 1;
     code[progp++] = "POP R3\nMOV @#strdcurre,R2\nMOV r2,R5\nMOVB #1,(R2)+\n"; //r2!!
     code[progp++] = "MOVB R3,(R2)+\nCALL @#exitstr0\nPUSH R5\n";
}
| HEX '(' iexpr ')' {
     asmcomm("s -> hex$(i)");
     used_code["hexconv"] = 1;
     used_code["exitstring"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nCALL @#hexmain\nPUSH R5\n";
}
| OCT '(' iexpr ')' {
     asmcomm("s -> oct$(i)");
     used_code["octconv"] = 1;
     used_code["exitstring"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nCALL @#octmain\nPUSH R5\n";
}
| UPPER '(' sexpr ')' {
     asmcomm("s -> upper$(s)");
     used_code["gc"] = 1;
     used_code["exitstring"] = 1;
     code[progp++] = "POP R3\nMOV @#strdcurre,R2\nMOV r2,R5\nCLR R4\nBISB (R3)+,R4\nMOVB R4,(R2)+\n";//r2!!
     code[progp++] = tostr(locals + 1) + "$:MOVB (R3)+,R1\nCMPB R1,#'a\nBCS " + tostr(locals) + "$\nCMPB R1,#'z+1\n";
     code[progp++] = "BCC " + tostr(locals) + "$\nSUB #32,R1\n" + tostr(locals) + "$:MOVB R1,(R2)+\n";
     code[progp++] = "SOB R4," + tostr(locals + 1) + "$\nCALL @#exitstr0\nPUSH R5\n";
     locals += 2;
}
| BIN '(' iexpr ')' {
     asmcomm("s -> bin$(i)");
     used_code["binconv"] = 1;
     used_code["exitstring"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nCALL @#binmain\nPUSH R5\n";
}
| UINT '(' iexpr ')' {
     asmcomm("s -> uint$(i)");
     used_code["todec0"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nMOV @#strdcurre,R5\nINC R5\nPUSH R5\nCALL @#todec0\nMOV @#strdcurre,R3\nMOV R5,R4\nSUB (SP)+,R4\n";
     code[progp++] = "MOV R5,@#strdcurre\nMOVB R4,@R3\nMOV R3,R5\nCALL @#gc\nPUSH R5\n";
}
| sexpr '+' sexpr {
     asmcomm("s -> s+s");
     used_code["string"] = 1;
     used_code["gc"] = 1;
     code[progp++] = "POP R3\nPOP R4\nCALL @#s_PLUS_s\nPUSH R5\n";
}
| USR '(' sexpr ')' {
     asmcomm("s -> USR(s)");
     code[progp++] = "POP R5\nMOV @#512+" + tostr($1*2) + ",R1\nCALL @R1\nPUSH R5\n";  //linker!
}
| fn SFN fncmain
;
%%
int lineno = 1;

#include "lex.yy.c"

int yyerror(const string &s) {
   ostringstream oss;
   oss << s << " in " << lineno << endl;
   throw oss.str();
}

int main (int argc, char **argv) {
   if (argc > 1) {
      cout << "Reduced Basic cross-compiler for BK0011 v0.02 (C) 2015 GNU GPL\n";
      cout << "USAGE: rbkbasic <INFILE >OUTFILE\n";
      return 0;
   }
   //yydebug = 1;
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
   return 0;
}
