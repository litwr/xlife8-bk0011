#include <iostream>
#include <sstream>
#include <string>
#include <map>
using namespace std;
struct Symbol {
  string *name;
  short type; //IVAR, SVAR, UNDEF
  int addr;
  int len;
};
int yylex(), yyparse(), yyerror(const string &), toint(string);
void initcode(), printcode(), relocate();
string tostr(int);
extern int progp, ivarp, svarp, strconstp, stringp, locals;
extern string code[], data[];
extern map<int,Symbol*> realloca;
extern map<int,int> reallocl, labels;


