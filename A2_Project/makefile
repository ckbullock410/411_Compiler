objects = main.o util.o lex.yy.o CM.tab.o 
          

parser : $(objects)
	gcc -Wall -lfl -o parser $(objects)

main.o : globals.h util.h parse.h scan.h y.tab.h
lex.yy.o : globals.h util.h scan.h y.tab.h
CM.tab.o : globals.h util.h scan.h parse.h 
util.o : globals.h y.tab.h


.PHONY : clean
clean :
	-rm parser $(objects)
