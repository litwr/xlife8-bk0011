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
   int k;
   cout << ".radix 10\n.dsabl gbl\n.include notepad/rbkbasic.mac\n.asect\n.="
      << progstart << endl;
   cout << "MOV #" + tostr(datastart) +",R3\nMOV R3,SP\nTOSTRINGCO\nCLRB (R3)+\n";
   cout << "MOV #lib_end+" + tostr(ivarp) + ",@#strsstatic\n";
   cout << "MOV #lib_end+" << tostr(ivarp + svarp) << ",R1\n";
   cout << "MOV R1,@#strestatic\n";
   if (strconstp) {
      cout << "MOV #" << tostr(strconstp) << ",R2\n";
      cout << "inistr:MOVB (R1)+,(R3)+\nSOB R2,inistr\n";  //R1,R3 are set above
      cout << "MOV R3,@#strdstart\nMOV R3,@#strdcurre\n";
   }
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
   if (k = svarp/2) {
      cout << ".word ";
      for (int i = 0; i < k - 1; i++)
         if (i%20 == 0)
            cout << "16384\n.word ";
         else
            cout << "16384,";
      cout << "16384\n";
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
      code[i->first] = tostr(i->second->addr + 16385);
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

