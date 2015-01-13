#include <iostream>
#include <sstream>
#include <string>
#include <map>
using namespace std;
struct Symbol {
  string *name;
  short type; //IVAR, SVAR, STRING
  int addr, len;
};
int yylex(), yyparse(), yyerror(const string &), toint(string);
void initcode(), printcode(), relocate(), breakpoint();
string tostr(int);
extern int progp, ivarp, svarp, strconstp, stringp, locals, strdatap;
extern string code[], data[];
extern map<int,Symbol*> realloca, reallocs;
extern map<int,int> reallocl, labels;

