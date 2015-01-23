%{
int lexeol = 1;
%}
%option    noyywrap
number	   ([0-9]+[ ]*[0-9]+)+|[0-9]+
symbol     [a-zA-Z][a-zA-Z0-9]*(\$|\%)?
string     \"[^"]*\"
space      [ \t]+
%%
{space}    
(?i:REM).*$ 
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
(?i:DEF)   return DEF;
(?i:DIM)   lexdimst = 1;
(?i:ELSE)  return ELSE;
(?i:END)   return END;
(?i:EOF)   return BEOF;
(?i:FIND)  return FIND;
(?i:FOR)   return FOR;
(?i:FRE)   return FRE;
(?i:GET)   return GET;
(?i:GOTO)  return GOTO;
(?i:GOSUB) return GOSUB;
(?i:HEX)\$ return HEX;
(?i:IF)    return IF;
(?i:INKEY)\$ return INKEY;
(?i:INP)   return INP;
(?i:INPUT) return INPUT;
(?i:LEN)   return LEN;
(?i:LET)   return LET;
(?i:LOCATE) return LOCATE;
(?i:MID)\$ return MID;
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
(?i:RETURN) return RETURN;
(?i:SGN)   return SGN;
(?i:SPC)   return SPC;
(?i:STEP)  return STEP;
(?i:STR)\$ return STR;
(?i:STRING)\$ return STRING;
(?i:TAB)   return TAB;
(?i:THEN)  yylval.num = progp; return THEN;
(?i:TO)    return TO;
(?i:UINT)\$ return UINT;
(?i:USR) yylval.num = 0; return USR;
(?i:USR)[0-9] yylval.num = yytext[3] - '0'; return USR;
(?i:VAL)   return VAL;
\(         if (lexdimst == 0) return '(';
\)         if (lexdimst) lexdimst = 0; else return ')';
{number}   {
              string sbuf(yytext);
              unsigned long p;
              while ((p = sbuf.find(" ")) != string::npos)
                 sbuf.erase(p, 1);
              istringstream iss(sbuf);
              iss >> yylval.num;
              if (lexdimst == 2)
                 lexaddsym(lexdimname, yylval.num*2);
              else if (lexeol)
                 return lexeol = 0, LABEL;
              else
                 return NUMBER;
           }
{symbol}   {
              string sbuf(yytext);
              if (lexdimst == 1) {
                 lexdimname = sbuf;
                 lexdimst++;
              }
              else {
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
\n	   ++lineno; lexeol = 1;
.          return yytext[0];

