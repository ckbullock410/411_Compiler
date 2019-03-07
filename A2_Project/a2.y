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
						{savedTree = $1;}
					;
declaration-list	:	declaration-list declaration
					|	declaration
					;
declaration 		:	var-declaration
					|	fun-declaration
					;
var-declaration		:	type-specifier ID SEMI
					|	type-specifier ID LBRACK NUM RBRACK SEMI
					;
type-specifier		: 	INT 
					| 	VOID
					;
fun-declaration 	:	type-specifier ID LPAREN params RPAREN compound-stmt;
params				:	param-list
					|	VOID
					;
param-list			:	param-list COMMA param
					|	param
					;
param 				:	type-specifier ID
					|	type-specifier ID LBRACK RBRACK
					;
compound-stmt		:	LCBRACK local-declarations var-declaration
					|	empty
					;
local-declarations 	:	local-declarations var-declaration
					|	empty
					;
statement-list		:	statement-list statement
					|	empty
					;
statement 			: 	expression-stmt
					| 	compound-stmt
					|	selection-stmt
					|	iteration-stmt
					|	return-stmt
					;
expression-stmt		:	expression SEMI
					|	SEMI
					;
selection-stmt		:	IF LPAREN expression RPAREN statement
					|	IF LPAREN expression RPAREN statement ELSE statement
					;
iteration-stmt		:	WHILE LPAREN expression RPAREN statement
					;
return-stmt			:	RETURN SEMI
					| 	RETURN expression SEMI
					;
expression 			:	var ASSIGN expression
					| 	simple-expression
					;
var 				: 	ID
					| 	ID LBRACK expression RBRACK
					;
simple-expression 	: 	additive-expression relop additive-expression
					| 	additive-expression
					;				
relop				: 	LE
					|	LT
					|	GT
					|	GE
					|	EQ
					|	NQ
					;
additive-expression :	additive-expression addop term
					|	term
					;
addop 				:	PLUS
					|	MINUS
					;
term				:	term mulop factor
					| 	factor
					;
mulop				:	TIMES
					| 	OVER
					;
factor				:	LPAREN expression RPAREN
					|	var
					|	call
					|	NUM
					;
call				:	ID LPAREN args RPAREN
					;
args				:	arg-list
					|	empty
					;
args-list			:	arg-list COMMA expression
					|	expression
					;					




%%

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