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
(?i:THEN)  yylval.num = progp; return THEN;
(?i:NEXT)  return NEXT;
>=	   return GE;
=>	   return GE;
\<= 	   return LE;
=\< 	   return LE;
\<> 	   return NE;
>\< 	   return NE;
> 	   return GT;
\< 	   return LT;
(?i:GET)   return GET;
(?i:ABS)   return ABS;
(?i:SGN)   return SGN;
(?i:CSRLIN)(\(.*\))? return CSRLIN;
(?i:POS)(\(.*\))? return POS;
(?i:FRE)   return FRE;
(?i:LET)   return LET;
(?i:MID)\$ return MID;
(?i:STR)\$ return STR;
(?i:HEX)\$ return HEX;
(?i:STRING)\$ return STRING;
(?i:INKEY)\$ return INKEY;
(?i:UINT)\$ return UINT;
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
\?         return PRINT;
(?i:LOCATE) return LOCATE;
(?i:POKE)  return POKE;
(?i:CHR)\$ return CHR;
(?i:PEEK)  return PEEK;
(?i:ASC)   return ASC;
(?i:AND)   return AND;
(?i:OR)    return OR;
(?i:ON)    return ON;
(?i:LEN)   return LEN;
(?i:OPEN)  return OPEN;
(?i:CLOSE) return CLOSE;
(?i:FIND)  return FIND;
(?i:OUTPUT) return OUTPUT;
(?i:EOF)   return BEOF;
(?i:VAL)   return VAL;
(?i:NOT)   return NOT;
(?i:DIM)   lexdimst = 1;
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

