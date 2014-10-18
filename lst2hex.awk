length($0) >= 40 {
   s = substr($0, 8, 32)
   r = "[^0-7][0-7]{6}[^0-7]"
   p = match(s, r)
   while (p) {
      t = sprintf(" %04x  ", strtonum("0" substr(s, p + 1, 6)))
      s = substr(s, 1, p) t substr(s, p + 7)
      p = match(s, r)
   }
   r = "[^0-9a-f][0-7]{3}[^0-9a-f]"
   s1 = substr(s, 1, 7)
   s = substr(s, 8)
   p = match(s, r)
   while (p) {
      t = sprintf(" %02x ", strtonum("0" substr(s, p + 1, 3)))
      s = substr(s, 1, p) t substr(s, p + 4)
      p = match(s, r)
   }
   print substr($0, 1, 7) s1 s substr($0, 40)
}
