#include <iostream>
#include <sstream>
#include <string>
#include <cstring>
#include <map>
using namespace std;
struct Symbol {
  string *name;
  short type; //IVAR, SVAR, STRING
  int addr, len, used;
};
int yylex(), yyparse(), yyerror(const string &), toint(string);
void initcode(), printcode(), relocate(), breakpoint(), asmcomm(const string&), optimizer(string&);
string tostr(int);
extern int progp, ivarp, svarp, strconstp, stringp, locals, strdatap, datalines_count;
extern string code[], data[], datalines[], lexdimname;
extern int comm_on, deffn, callfn;
extern map<int,Symbol*> realloca, reallocs;
extern map<string,Symbol> names;
extern map<int,int> reallocl, labels, datalabels, dataprogp;
extern map<string,int> used_code;
