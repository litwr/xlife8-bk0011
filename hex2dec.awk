{
   p = match($0, "\\$[0-9a-fA-F]+")
   while (p) {
      $0 = substr($0, 1, p - 1) strtonum("0x" substr($0, p + 1, RLENGTH - 1)) substr($0, p + RLENGTH)
      p = match($0, "\\$[0-9a-fA-F]+")
   }
   print $0
}
