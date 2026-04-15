(*
This is a very simple but a very slow way to calculate Fibonacci number n, the average time of the calculation is proportional to phi^n, e.g. phi is close to 1.618, so for n=25 calculation (should give 75,025) time is proportional to phi^25 which is approximately equal to 167,761.
The best PC can't make Fibonacci number 50 (12,586,269,025) without a big (several minutes) delay, so it will be faster to calculate it without any computer!  Because it will require only 48 manual additions.
*)
function fibonacci(n: byte): longint;
   begin
     if n < 3 then
        fibonacci := 1
     else
        fibonacci := fibonacci(n - 1) + fibonacci(n - 1)
   end;
begin
   writeln(fibonacci(25))
end.
