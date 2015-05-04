#changes JMP@# to BR if it is possible
#this makes a program about 0.5% faster and smaller
#usage: awk -bf jmp2br.awk FILE.lst >FILE.asm
#this program is for gawk variant of awk
BEGIN {
   w[".ASECT"] =w[".DSABL"] = w[".RADIX"] = 1
}
{
   r = ""
   if (index($0, $2) == 10 && substr($0, 41) != "" || toupper($2) in w) {
      r = substr($0, 41)
      if ($3 == "000137") {
         distance = strtonum("0" $4) - strtonum("0" $2)
         t = $0
         gsub("^.*@#", "", t)
         if (distance < 0 && -distance <= 254 || distance > 0 && distance <= 258)
            r = "BR " t
      }
   }
   else if (index($0, $2) == 41 && $2 ~ /:/)
      r = substr($2, 1, index($2, ":"))
   if (r != "") print r " ;" NR
}
