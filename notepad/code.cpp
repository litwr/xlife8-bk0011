#include <fstream>
#include "rbkbasic.h"
#include "y.tab.h"
#define progstart 512

int progp, ivarp, svarp, strconstp, stringp, locals, comm_on = 1;
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
   int k, l = ivarp + svarp + 2;
   cout << ".radix 10\n.dsabl gbl\n.include notepad/rbkbasic.mac\n.asect\n.="
      << progstart << endl;
   cout << "strsstatic=lib_end+" << ivarp << "\nstrestatic =lib_end+" << l 
      << "\nstrsdyn =lib_end+" << l + strconstp + 1 << "\nstrdmax =" << 48*1024-256 << endl ;
   cout << "TOMAIN\n";
   cout << ".REPT 40\nNOP\n.ENDR\nMOV #startstack,SP\nstartstack:\n";
   for (int i = 0; i < progp; i++)
      cout << code[i];
   cout << "finalfinish:WAIT\nHALT\n.include notepad/rbkbasic.inc\n";
   if (k = ivarp/2) {
      cout << ".word ";
      for (int i = 0; i < k - 1; i++)
         if (i%40 == 0)
            cout << "0\n.word ";
         else
            cout << "0,";
      cout << "0\n";
   }
   if (k = svarp/2 + 1) {
      cout << ".word ";
      for (int i = 0; i < k - 1; i++)
         if (i%20 == 0)
            cout << "lib_end+" << l << "\n.word ";
         else
            cout << "lib_end+" << l << ",";
      cout << "lib_end+" << l << "\n";
   }
   cout << ".byte 0\n";
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
      code[i->first] = tostr(i->second->addr + ivarp + svarp + 3)  + "+lib_end";
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

void asmcomm(const string &s) {
   if (comm_on)
      code[progp++] = ";" + s + "\n";
}

void breakpoint() {
}

