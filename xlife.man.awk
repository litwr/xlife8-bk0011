BEGIN {
   for (i = 32; i < 255; i++)
      t[sprintf("%c", i)] = i
   ci = sprintf("%c", 156)
   cu = sprintf("%c", 159)
   r = ""
}
length($0) == 0 {printf ".byte 10\n"}
length($0) > 0 {
    b = ""
    x = e = $0
    gsub("\\\\.", "", x)
    len = length(x)
    while (p = index(e, "\\")) {
      m = substr(e, p + 1, 1)
      b = b substr(e, 1, p - 1)
      if (m == "x") {
         if (rev) {b = b ci; rev = 0}
         if (und) {b = b cu; und = 0}
         b = b ci substr(e, p + 2, 1) ci
         e = substr(e, p + 3)
      }
      else if (rev && und) {
         if (m == "g") {
            b = b ci cu
            rev = und = 0
         } else if (m == "r") {
            b = b cu
            und = 0
         } else if (m == "p") {
            b = b ci
            rev = 0
         }
         e = substr(e, p + 2)
      } else if (rev) {
         if (m == "g") {
            b = b ci
            rev = 0
         } else if (m == "p") {
            b = b ci cu
            rev = 0
            und = 1
         } else if (m == "b") {
            b = b cu
            und = 1
         }
         e = substr(e, p + 2)
      } else if (und) {
         if (m == "g") {
            b = b cu
            und = 0
         } else if (m == "r") {
            b = b cu ci
            rev = 1
            und = 0
         } else if (m == "b") {
            b = b ci
            rev = 1
         }
         e = substr(e, p + 2)
      }
      else {
         if (m == "b") {
            b = b ci cu
            und = rev = 1
         } else if (m == "r") {
            b = b ci
            rev = 1
         } else if (m == "p") {
            b = b cu
            und = 1
         }
         e = substr(e, p + 2)
      }
   }
   printf ".byte "
   s = b e
   for (i = 1; i < length(s); i++)
      printf "%d,",t[substr(s,i,1)]
   printf "%d",t[substr(s,i,1)]
   if (length(x) < 64) printf(",10")
   printf("\n")
}

