OBJS = y.tab.o code.o

rbkbasic: $(OBJS)
	g++ -g $(OBJS) -lpcrecpp -o rbkbasic

y.tab.o: y.tab.c rbkbasic.cpp.l
	lex rbkbasic.cpp.l
	g++ -g -c y.tab.c

code.o: code.cpp rbkbasic.h y.tab.c makefile
	g++ -g -c code.cpp

y.tab.c: rbkbasic.cpp.y rbkbasic.h makefile
	bison -y -d -t -v rbkbasic.cpp.y

clean:
	rm -f y.tab.[ch] lex.yy.c rbkbasic *.o y.output
