%{
void str2upper(string &sbuf) {
   for (int i = 0; i < sbuf.length(); i++)
      sbuf[i] = toupper(sbuf[i]);
}
void lexaddsym(string& sbuf, int len = 2) {
   if (names.find(sbuf) == names.end()) {
      names[sbuf].len = len;
      if (sbuf[sbuf.length() - 1] == '$') {
         names[sbuf].type = SVAR;
         names[sbuf].addr = svarp;
         svarp += len;
      }
      else {
         names[sbuf].type = IVAR;
         names[sbuf].addr = ivarp;
         ivarp += len;
      }
      names[sbuf].name = &(string&)names.find(sbuf)->first;
   }
}
int lexeol = 1, lexdimst;
string curdeffn;
%}
%option    noyywrap
number	   ([0-9]+[ ]*[0-9]+)+|[0-9]+|&[hH][0-9abcdefABCDEF]+|&[oO][0-7]+
symbol     [a-zA-Z][a-zA-Z0-9]*(\$|\%)?
string     \"[^"]*\"
space      [ \t]+
datasym    [^,:\n]
dataelem   {space}*({string}|{datasym}*)
dataline   (?i:DATA)({dataelem},)*{dataelem}
%%
{space}
(?i:REM).*$
\'.*$ 
>=	   return GE;
=>	   return GE;
\<= 	   return LE;
=\< 	   return LE;
\<> 	   return NE;
>\< 	   return NE;
> 	   return GT;
\< 	   return LT;
\?         return PRINT;
(?i:ABS)   return ABS;
(?i:AND)   return AND;
(?i:ASC)   return ASC;
(?i:AT)    return AT;
(?i:BIN)\$ return BIN;
(?i:BLOAD)  return BLOAD;
(?i:BSAVE)  return BSAVE;
(?i:CHR)\$ return CHR;
(?i:CLEAR) return CLEAR;
(?i:CLOSE) return CLOSE;
(?i:CLS)   return CLS;
(?i:CSRLIN)(\(.*\))? return CSRLIN;
(?i:DEC)   return DEC;
(?i:DEF)   return DEF;
(?i:DIM)   lexdimst = 1;
(?i:ELSE)  return ELSE;
(?i:END)   return END;
(?i:EQV)   return EQV;
(?i:EOF)   return BEOF;
(?i:FILES)  return FIND;
(?i:FIND)  return FIND;
(?i:FN)    return FN;
(?i:FOR)   return FOR;
(?i:FRE)   return FRE;
(?i:GET)   return GET;
(?i:GOTO)  return GOTO;
(?i:GOSUB) return GOSUB;
(?i:HEX)\$ return HEX;
(?i:IF)    return IF;
(?i:INKEY)\$ return INKEY;
(?i:IMP)   return IMP;
(?i:INP)   return INP;
(?i:INPUT) return INPUT;
(?i:INSTR) return INSTR;
(?i:LEN)   return LEN;
(?i:LET)   return LET;
(?i:LOCATE) return LOCATE;
(?i:MID)\$ return MID;
(?i:MOD)   return MOD;
(?i:MONIT) return END;
(?i:NEXT)  return NEXT;
(?i:NOT)   return NOT;
(?i:ON)    return ON;
(?i:OPEN)  return OPEN;
(?i:OR)    return OR;
(?i:OUT)  return OUT;
(?i:OUTPUT) return OUTPUT;
(?i:PEEK)  return PEEK;
(?i:POKE)  return POKE;
(?i:POS)(\(.*\))? return POS;
(?i:PRINT) return PRINT;
(?i:READ) return READ;
(?i:RETURN) return RETURN;
(?i:RESTORE) return RESTORE;
(?i:SGN)   return SGN;
(?i:SPC)   return SPC;
(?i:STEP)  return STEP;
(?i:STR)\$ return STR;
(?i:STRING)\$ return STRING;
(?i:SYSTEM)\$ return END;
(?i:TAB)   return TAB;
(?i:THEN)  yylval.num = progp; return THEN;
(?i:TO)    return TO;
(?i:UINT)\$ return UINT;
(?i:UPPER)\$ return UPPER;
(?i:USR) yylval.num = 0; return USR;
(?i:USR)[0-9] yylval.num = yytext[3] - '0'; return USR;
(?i:VAL)   return VAL;
(?i:VARPTR)   return VARPTR;
(?i:XOR)   return XOR;
\(         if (lexdimst == 0) return '(';
\)         if (lexdimst) lexdimst = 0; else return ')';
{number}   {
              string sbuf(yytext);
              unsigned long p;
              while ((p = sbuf.find(" ")) != string::npos)
                 sbuf.erase(p, 1);
              if (sbuf[0] != '&') {
                 istringstream iss(sbuf);
                 iss >> yylval.num;
              }
              else {
                 char c = toupper(sbuf[1]);
                 sbuf.erase(0, 2);
                 istringstream iss(sbuf);
                 if (c == 'H')
                    iss >> hex >> yylval.num;
                 else
                    iss >> oct >> yylval.num;
              }
              if (lexdimst == 2)
                 lexaddsym(lexdimname, yylval.num*2);
              else if (lexeol)
                 return lexeol = 0, LABEL;
              else
                 return NUMBER;
           }
{symbol}   {
              string sbuf(yytext);
              str2upper(sbuf);
              if (lexdimst == 1) {
                 lexdimname = sbuf;
                 lexdimst++;
              }
              else {
                 if (deffn == 0) {
                    curdeffn = sbuf;
                    sbuf = ":" + sbuf;
                    deffn++;
                    lexaddsym(sbuf, 0);
                    if (names[sbuf].type == SVAR)
                       names[sbuf].type = SFN;
                    else
                       names[sbuf].type = IFN;
                 }
                 else if (deffn > 0) {
                    sbuf = curdeffn + ":" + sbuf;
                    lexaddsym(sbuf, 0);
                    names[sbuf].addr = deffn++;
                    if (names[sbuf].type == SVAR)
                       names[sbuf].type = FSVAR;
                    else
                       names[sbuf].type = FIVAR;
                 }
                 else if (deffn == -2) {
                    if (names.find(curdeffn + ":" + sbuf) != names.end())
                       sbuf = curdeffn + ":" + sbuf;
                 }
                 if (deffn < 0)
                    if (callfn == 0)
                       if (names.find(":" + sbuf) != names.end())
                          callfn++, sbuf = ":" + sbuf;
                       else
                          throw (string) "call to undefined function";
                    else
                       lexaddsym(sbuf);
                 yylval.sym = &names[sbuf];
                 return yylval.sym->type;
              }
           }
{string}   {
              string istr(yytext + 1);
              istr.erase(istr.length() - 1);
              if (strings.find(istr) == strings.end()) {
                 strings[istr].addr = strconstp;
                 strconstp += (strings[istr].len = istr.length()) + 1;
                 strings[istr].name = &(string&)strings.find(istr)->first;
                 strings[istr].used = 0;
              }
              yylval.sym = &strings[istr];
              return yylval.sym->type = STRINGTYPE;
           }
{dataline} {
              yylval.sym = (Symbol*)(yytext + 4);
              return DATAOPER;
           }
\n	   ++lineno; lexeol = 1;
.          return yytext[0];

