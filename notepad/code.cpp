#include <fstream>
#include <pcrecpp.h>
#include "rbkbasic.h"
#include "y.tab.h"
#define progstart 512

int progp, ivarp, svarp, strconstp, stringp, locals, comm_on = 0;
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
   ostringstream ostr;
   string wholecode;
   ostr << ".radix 10\n.dsabl gbl\n.include notepad/rbkbasic.mac\n.asect\n.="
      << progstart << endl;
   ostr << "strdmax =" << 48*1024-256 << endl ;
   ostr << "MOV #240*256+240,@#^O120140\n";
   ostr << "TOMAIN\n";
   ostr << "MOV #keyirq,@#^O60\nMOV #key2irq,@#^O274\n";
   ostr << "MOV #512,SP\n";
   for (int i = 0; i < progp; i++)
      ostr << code[i];
   ostr << "finalfinish:WAIT\nHALT\n.include notepad/rbkbasic.inc\n";
   if (k = ivarp/2)
      ostr << ".REPT " << k << "\n.word 0\n.ENDR\n";
   ostr << "strsstatic:\n";
   if (k = svarp/2 + 1)
      ostr << ".REPT " << k << "\n.word strestatic\n.ENDR\n";
   ostr << "strestatic:\n";
   ostr << ".byte 0\n";
   for (int i = 0; i < stringp; i++)
      ostr << data[i];
   ostr << "strsdyn:\n";
   wholecode = ostr.str();
   optimizer(wholecode);
   cout << wholecode;
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
   if (comm_on == 1)
      code[progp++] = ";" + s + "\n";
   else if (comm_on == 2)
      cerr << "-- " + s + "\n";
}

void breakpoint() {
}

using namespace pcrecpp;
void optimizer(string &code) {
    RE_Options opts(PCRE_MULTILINE | PCRE_DOLLAR_ENDONLY | PCRE_CASELESS | PCRE_DOTALL);
    RE("PUSH([^\n]+)\nPUSH([^\n]+)\nPUSH([^\n]+)\nPOP ([^\n]+)\nPOP ([^\n]+)\nPOP ([^\n]+)\n", opts)
         .GlobalReplace("MOV\\1,\\6\nMOV\\2,\\5\nMOV\\3,\\4\n", &code);
    RE("PUSH([^\n]+)\nPUSH([^\n]+)\nPOP ([^\n]+)\nPOP ([^\n]+)\n", opts).GlobalReplace("MOV\\1,\\4\nMOV\\2,\\3\n", &code);
    RE("PUSH([^\n]+)\nPOP ([^\n]+)\n", opts).GlobalReplace("MOV\\1,\\2\n", &code);
    RE("MOV #([^,]+),R4\nMOV @R4,R4\n", opts).GlobalReplace("MOV @#\\1,R4\n", &code);
    RE("MOV R([0-9]),R\\1\n", opts).GlobalReplace("", &code);
    //RE("MOV ([^,]+),R4\nMOV R4,(R[0-5])\n", opts).GlobalReplace("MOV \\1,\\2\n", &code);
}

