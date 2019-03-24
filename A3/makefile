objects = main.o util.o lex.yy.o CM.tab.o stack.o  
          

parser : $(objects)
	gcc -Wall -o parser $(objects) -ll

main.o : globals.h util.h parse.h scan.h y.tab.h
lex.yy.o : globals.h util.h scan.h y.tab.h
CM.tab.o : globals.h util.h scan.h parse.h stack.h
util.o : globals.h y.tab.h
stack.o : stack.h

.PHONY : clean
clean :
	-rm parser $(objects)
