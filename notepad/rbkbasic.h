#include <iostream>
#include <sstream>
#include <string>
#include <map>
using namespace std;
struct Symbol {
  string *name;
  short type; //IVAR, SVAR, STRING
  int addr, len, used;
};
int yylex(), yyparse(), yyerror(const string &), toint(string);
void initcode(), printcode(), relocate(), breakpoint(), lexaddsym(string&, int = 2), asmcomm(const string&), optimizer(string&);
string tostr(int);
extern int progp, ivarp, svarp, strconstp, stringp, locals, strdatap;
extern string code[], data[], lexdimname;
extern int lexdimst, comm_on;
extern map<int,Symbol*> realloca, reallocs;
extern map<string,Symbol> names;
extern map<int,int> reallocl, labels;

