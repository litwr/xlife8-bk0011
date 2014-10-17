length($0) >= 40 {
   s = substr($0, 8, 32)
   r = "[^0-7][0-7]{6}[^0-7]"
   p = match(s, r)
   while (p) {
      t = sprintf(" %04x ", strtonum("0" substr(s, p + 1, 6)))
      s = substr(s, 1, p) t substr(s, p + 7)
      p = match(s, r)
   }
   print substr($0, 1, 7) s substr($0, 40)
}
