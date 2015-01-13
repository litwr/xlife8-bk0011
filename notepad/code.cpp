#include "rbkbasic.h"
#include "y.tab.h"
#define datastart 16384
#define progstart 512

int progp, ivarp, svarp, strconstp, stringp, locals;
int lexdimst;
string lexdimname;

void initcode() {
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
   cout << ".radix 10\n.dsabl gbl\n.include bk0011m.mac\n.include notepad/rbkbasic.mac\n.asect\n.="
      << progstart << endl;
   cout << "MOV #16384,SP\n";
//   cout << "MOV #12,R0\nEMT ^O16\n";
   if (strconstp) {
      cout << "MOV #lib_end+" << tostr(ivarp + svarp) << ",R1\n";
      cout << "MOV #" << tostr(strconstp) << ",R2\n";
      cout << "MOV #16384,R3\n";
      cout << "TOSTRING\n";
      cout << "inistr:MOVB (R1)+,(R3)+\nSOB R2,inistr\nTOSCREEN\n";
   }
   for (int i = 0; i < progp; i++)
      cout << code[i];
   cout << "finalfinish:WAIT\nHALT\n.include notepad/rbkbasic.inc\n";
   int k = (ivarp + svarp)/2;
   if (k) {
      cout << ".word ";
      for (int i = 0; i < k - 1; i++)
         cout << "0,";
      cout << "0\n";
   }
   for (int i = 0; i < stringp; i++)
      cout << data[i];
}

void relocate() {
   for (map<int,int>::iterator i = reallocl.begin(); i != reallocl.end(); i++)
      code[i->first] = tostr(labels[i->second]) + "$\n";
   for (map<int,Symbol*>::iterator i = realloca.begin(); i != realloca.end(); i++)
      if (i->second->type == IVAR)
         code[i->first] = tostr(i->second->addr) + "+lib_end";
   for (map<int,Symbol*>::iterator i = realloca.begin(); i != realloca.end(); i++)
      if (i->second->type == SVAR)
         code[i->first] = tostr(i->second->addr + ivarp) + "+lib_end";
   for (map<int,Symbol*>::iterator i = reallocs.begin(); i != reallocs.end(); i++)
      code[i->first] = tostr(i->second->addr + 16384);
}

void lexaddsym(string& sbuf, int len) {
   for (int i = 0; i < sbuf.length(); i++)
      sbuf[i] = toupper(sbuf[i]);
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

void breakpoint() {
}

