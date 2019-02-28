%{
#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"
#define YYPARSER

/*
----- TODO's -----
need to possibly lable tokens as %left or %right not sure

input all the CFG rules as bison code
*/

%}
%token BOOL IF ELSE WHILE RETURN TRUE FALSE VOID INT NOT
%token ID NUM
%token ASSIGN NQ EQ LT GT LE GE AND OR PLUS MINUS TIMES OVER LPAREN RPAREN SEMI COMMA LBRACK RBRACK LCBRACK RCBRACK
%token ERROR
%%
program				: 	declaration-list
						{savedTree = $1;};
declaration-list	:	declaration-list declaration
					|	declaration;
declaration 		:	var-declaration
					|	fun-declaration;


%%

// 		FILL IN RULES RIGHT ABOVE THESE %%
//*********************************************
//*********************************************
//********************************************


/* ------------ C CODE ----------------- */

int yyerror(char * message)
{ fprintf(output,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(output,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

static int yylex(void){ 
	return getToken(firstTime);
}

TreeNode * parse(void){ 
	yyparse();
  	return savedTree;
}