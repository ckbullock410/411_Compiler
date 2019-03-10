objects = main.o util.o lex.yy.o a2.tab.o 
          

parser : $(objects)
	gcc -Wall -o parser $(objects) -lfl

main.o :  globals.h util.h parse.h scan.h a2.tab.h
lex.yy.o : globals.h util.h scan.h a2.tab.h
a2.tab.o : globals.h util.h scan.h parse.h 
util.o : globals.h a2.tab.h


.PHONY : clean
clean :
	-rm parser $(objects)
