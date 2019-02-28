/*
Chandler Bullock 10160618
Akaljot Sangha 10106725
CPSC 411 Assignment #2
*/


#include "util.h"
#include "scan.h"
#include "parse.h"
#include "globals.h"

//Global variables
int lineno = 0;
FILE * source;
FILE * listing;

int main( int argc, char ** argv){
	//initialize output file
	listing = fopen("out.txt", "w");
	TreeNode * syntaxTree;

	//open source file to read from / error check
  	if (argc != 2)
    { printf("Incorrect usage, enter an input filename.\n");
      exit(1);
    } else {
    	source = fopen(argv[1], "r");
    }
    if (source==NULL){ 
    	fprintf(stderr,"File %s not found\n",pgm);
    	exit(1);
 	}
 	fprintf(output, "C- COMPILATION: %s\n", argv[1]);

 	//Scan the input file and get the tokens
 	int firstTime = 1;
 	getToken(firstTime);
    firstTime = 0;    
    while (getToken(firstTime)!=ENDFILE){
    	//possibly some code here
    }

    //parse the file and then print it out
    syntaxTree = parse();
    fprintf(listing,"\nSyntax tree:\n");
    printTree(syntaxTree);

    fclose(listing);
    fclose(source);
    return 0;
}