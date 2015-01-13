%option    noyywrap
number	   [0-9]+
symbol     [a-zA-Z][a-zA-Z0-9]*(\$|\%)?
string     (\"[^"]*\"[ ]*)+
%%
[ ]
(?i:REM).*$ 
>= 	   return GE;
\<= 	   return LE;
== 	   return EQ;
\<> 	   return NE;
>\< 	   return NE;
> 	   return GT;
\< 	   return LT;
(?i:MID)\$ return MID;
(?i:STR)\$ return STR;
(?i:STRING)\$ return STRING;
(?i:INKEY)\$ return INKEY;
(?i:GOTO)  return GOTO;
(?i:INPUT) return INPUT;
(?i:FOR)   return FOR;
(?i:END)   return END;
(?i:TO)    return TO;
[0-9]+[ ]*(?i:NEXT)  return NEXT;
(?i:STEP)  return STEP;
(?i:RETURN) return RETURN;
(?i:GOSUB) return GOSUB;
(?i:CLS)   return CLS;
(?i:IF)    return IF;
(?i:THEN)  yylval.num = progp; return THEN;
(?i:ELSE)  return ELSE;
(?i:PRINT) return PRINT;
(?i:LOCATE) return LOCATE;
(?i:DIM)   return DIM;
(?i:POKE)  return POKE;
(?i:CHR)\$ return CHR;
(?i:FRE)   return FRE;
(?i:PEEK)  return PEEK;
(?i:POS)   return POS;
(?i:ASC)   return ASC;
(?i:AND)   return AND;
(?i:OR)    return OR;
(?i:LEN)   return LEN;
(?i:VAL)   return VAL; /*READ,DATA,CSRLIN*/
{number}   {
              istringstream iss(yytext);
              iss >> yylval.num;
              return NUMBER;
           }
{symbol}   {
              string sbuf(yytext);
              for (int i = 0; i < sbuf.length(); i++)
                 sbuf[i] = toupper(sbuf[i]);
              if (names.find(sbuf) == names.end()) {
                 names[sbuf].len = 2;
                 if (sbuf[sbuf.length() - 1] == '$') {
                    names[sbuf].type = SVAR;
                    names[sbuf].addr = svarp;
                    svarp += 2;
                 }
                 else {
                    names[sbuf].type = IVAR;
                    names[sbuf].addr = ivarp;
                    ivarp += 2;
                 }
                 names[sbuf].name = &(string&)names.find(sbuf)->first;
              }
              yylval.sym = &names[sbuf];
              return yylval.sym->type;
           }
{string}   {
              string istr(yytext + 1);
              unsigned long p;
              while ((p = istr.find("\"")) != string::npos)
                 istr.erase(p, 1);
              if (strings.find(istr) == strings.end()) {
                 strings[istr].addr = strconstp;
                 strconstp += (strings[istr].len = istr.length()) + 1;
                 strings[istr].name = &(string&)strings.find(istr)->first;
              }
              yylval.sym = &strings[istr];
              return yylval.sym->type = STRING;
           }
\n	   ++lineno; return '\n';
.          return yytext[0];

