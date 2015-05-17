OBJS = y.tab.o code.o
#COPTS = -g -c
COPTS = -O3 -s -c
#YOPTS = -y -d -t -v
YOPTS = -y -d

rbkbasic: $(OBJS)
	g++ -g $(OBJS) -lpcrecpp -o rbkbasic

y.tab.o: y.tab.c rbkbasic.cpp.l
	lex rbkbasic.cpp.l
	g++ $(COPTS) y.tab.c

code.o: code.cpp rbkbasic.h y.tab.c makefile
	g++ $(COPTS) code.cpp

y.tab.c: rbkbasic.cpp.y rbkbasic.h makefile
	bison $(YOPTS) rbkbasic.cpp.y

clean:
	rm -f y.tab.[ch] lex.yy.c rbkbasic *.o y.output *~
