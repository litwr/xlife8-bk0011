%option    noyywrap
number	   [0-9]+
symbol     [a-zA-Z][a-zA-Z0-9]*(\$|\%)?
string     \"[^"]*\"
space      [ \t]+
%%
{space}
(?i:REM).*$ 
(?i:THEN)  yylval.num = progp; return THEN;
[0-9]+[ ]*(?i:NEXT)  return NEXT;
>=	   return GE;
=>	   return GE;
\<= 	   return LE;
=\< 	   return LE;
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
(?i:STEP)  return STEP;
(?i:RETURN) return RETURN;
(?i:GOSUB) return GOSUB;
(?i:CLS)   return CLS;
(?i:IF)    return IF;
(?i:ELSE)  return ELSE;
(?i:PRINT) return PRINT;
(?i:LOCATE) return LOCATE;
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
(?i:DIM)   lexdimst = 1;
{number}   {
              istringstream iss(yytext);
              iss >> yylval.num;
              if (lexdimst == 2)
                 lexaddsym(lexdimname, yylval.num*2);
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
\(         {
              if (lexdimst == 0) return '(';
           }
\)         {
              if (lexdimst)
                 lexdimst = 0;
              else
                 return ')';
           }
{string}   {
              string istr(yytext + 1);
              istr.erase(istr.length() - 1);
breakpoint();
              if (strings.find(istr) == strings.end()) {
                 strings[istr].addr = strconstp;
                 strconstp += (strings[istr].len = istr.length()) + 1;
                 strings[istr].name = &(string&)strings.find(istr)->first;
                 strings[istr].used = 0;
              }
              yylval.sym = &strings[istr];
              return yylval.sym->type = STRING;
           }
\n	   ++lineno; return '\n';
.          return yytext[0];

