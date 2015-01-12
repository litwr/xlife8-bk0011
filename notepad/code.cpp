#include "rbkbasic.h"
#include "y.tab.h"
#define datastart 16384
#define progstart 512

int progp, ivarp, svarp, strconstp, stringp, locals;

void initcode() {
   progp = ivarp = svarp = strconstp = locals = stringp = 0;
}

string tostr(int i) {
   ostringstream ostr;
   ostr << i;
   return ostr.str();
}

int toint(string s) {
   int i;
   istringstream istr(s);
   istr >> i;
   return i;
}

void printcode() {
   cout << ".radix 10\n.dsabl gbl\n.include bk0011m.mac\n.asect\n.="
      << progstart << endl;
   cout << "MOV #16384,SP\n";
//   cout << "MOV #12,R0\nEMT ^O16\n";
   for (int i = 0; i < progp; i++)
      cout << code[i];
   cout << "finalfinish:WAIT\n.include notepad/rbkbasic.inc\n";
   int k = (ivarp + svarp + strconstp)/2;
   if (k) {
      cout << ".word ";
      for (int i = 0; i < k - 1; i++)
         cout << "0,";
      cout << "0\n";
   }
   cout << ".=" << datastart << endl;
   for (int i = 0; i < stringp; i++)
      cout << data[i];
}

void relocate() {
   for (map<int,int>::iterator i = reallocl.begin(); i != reallocl.end(); i++)
      code[i->first] = tostr(labels[i->second]) + "$\n";
   for (map<int,Symbol*>::iterator i = realloca.begin(); i != realloca.end(); i++)
      if (i->second->type = IVAR)
         code[i->first] = tostr(i->second->addr) + "+lib_end";
}

