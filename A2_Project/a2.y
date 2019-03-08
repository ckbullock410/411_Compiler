%{

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYPARSER
#define YYSTYPE TreeNode *

static char * savedName; 
static int holdNum;
static char *

static int paramCounter = 0;
static int localCounter = 0;
static int currentlyGlobal = 1; 

/*
---------- TO DO LIST ------------
Figure out how parameters are going to work
Initialize all the semantic variables at the right times
Finish the last couple rule actions
FTP over to linux and figure out how to build
debug
*/

%}
%token BOOL IF ELSE WHILE RETURN TRUE FALSE VOID INT NOT
%token ID NUM
%token ASSIGN NQ EQ LT GT LE GE AND OR PLUS MINUS TIMES OVER LPAREN RPAREN SEMI COMMA LBRACK RBRACK LCBRACK RCBRACK
%token ERROR
%%
program				: 	declaration-list
						{
							savedTree = $1;
						}
					;
declaration-list	:	declaration-list declaration 
					{  
						YYSTYPE t = $1;
                   		if (t != NULL){
                   			while (t->sibling != NULL)
                        		t = t->sibling;
                     		t->sibling = $2;
                     		$$ = $1; }
                     	else $$ = $2;
	            	}
					|	declaration {$$ = $1}
					;
declaration 		:	var-declaration {$$ = $1}
					|	fun-declaration {$$ = $1}
					;
var-declaration		:	type-specifier ID {savedName = copyString(tokenString);} SEMI {
						$$ = newDecNode(VarK);
						$$ -> lineno = lineno;
						$$ -> type = $1
						$$ -> attr.name = savedName;
					}
					|	type-specifier ID {savedName = copyString(tokenString);}
						 LBRACK NUM{holdNum = atoi(tokenString);} RBRACK SEMI 
					{
						$$ = newDecNode(VarK);
						$$ -> isArray = 1;
						$$ -> arraySize = 
						$$ -> lineno = lineno;
						$$ -> type = $1
						$$ -> attr.value = holdNum
						$$ -> attr.name = savedName;
					}
					;
type-specifier		: 	INT {$$ = Integer;}
					| 	VOID {$$ = Void}
					;
fun-declaration 	:	type-specifier ID {savedName = copyString(tokenString);} LPAREN params RPAREN
					{
						$$ = newDecNode(FunK);
						$$ -> name = savedName;
						$$ -> type = $1;
						$$ -> child[0] = $5;
						$$ -> child[1] = $7;
					}
					;
params				:	param-list {$$ = $1}
					|	VOID {$$ = Void}
					;
param-list			:	param-list COMMA param {}
					|	param {}
					;
param 				:	type-specifier ID
					{
						$$ = new
					}
					|	type-specifier ID LBRACK RBRACK
					;
compound-stmt		:	LCBRACK local-declarations statement-list RCBRACK
					{
						$$ = newStmtNode(CompoundK);
						$$ -> child[0] = $2;
						$$ -> child[1] = $3
					}
					|	empty
					;
local-declarations 	:	local-declarations var-declaration 
					{  
						YYSTYPE t = $1;
                   		if (t != NULL){
                   			while (t->sibling != NULL)
                        		t = t->sibling;
                     		t->sibling = $2;
                     		$$ = $1; }
                     	else $$ = $2;
		            }
					|	empty
					;
statement-list		:	statement-list statement
					{  
						YYSTYPE t = $1;
                   		if (t != NULL){
                   			while (t->sibling != NULL)
                        		t = t->sibling;
                     		t->sibling = $2;
                     		$$ = $1; }
                     	else $$ = $2;
		            }
					|	empty
					;
statement 			: 	expression-stmt {$$ = $1;}
					| 	compound-stmt {$$ = $1;}
					|	selection-stmt {$$ = $1;}
					|	iteration-stmt {$$ = $1;}
					|	return-stmt {$$ = $1;}
					;
expression-stmt		:	expression SEMI {$$ = $1;}
					|	SEMI 
					;
selection-stmt		:	IF LPAREN expression RPAREN statement 
					{
						$$ = newStmtNode(IfK);
						$$ -> lineno = lineno;
						$$ -> child[0] = $3;
						$$ -> child[1] = $5;
					}
					|	IF LPAREN expression RPAREN statement ELSE statement
					{
						$$ = newStmtNode(IfK);
						$$ -> lineno = lineno;
						$$ -> child[0] = $3;
						$$ -> child[1] = $5;
						$$ -> child[2] = $7;
					}
					;
iteration-stmt		:	WHILE LPAREN expression RPAREN statement
					{
						$$ = newStmtNode(WhileK);
						$$ -> lineno = lineno;
						$$ -> child[0] = $3;
						$$ -> child[1] = $5;
					}
					;
return-stmt			:	RETURN SEMI
					{
						$$ = newStmtNode(ReturnK);
						$$ -> lineno = lineno;
					}
					| 	RETURN expression SEMI
					{
						$$ = newStmtNode(ReturnK);
						$$ -> lineno = lineno;
						$$ -> child[0] = $2;
					}
					;
expression 			:	var ASSIGN expression
					{
						$$ = newExpNode(AssignK);
						$$ -> child[0] = $1;
						$$ -> child[1] = $3;
					}
					| 	simple-expression {$$ = $1;}
					;
var 				: 	ID 
						{
							$$ = newExpNode(IdK);
							$$ -> lineno = lineno;
							$$ -> name = copyString(tokenString);
						}
					| 	ID {savedName = copyString(tokenString);} LBRACK expression RBRACK
						{
							$$ = newExpNode(IdK);
							$$ -> lineno = lineno;
							$$ -> name = savedName;
							$$ -> child[0] = $4;
						}
					;
simple-expression 	: 	additive-expression relop additive-expression
					{
						$$ = newExpNode(Opk);
						$$ -> attr.op = $2;
						$$ -> lineno = lineno;
						$$ -> child[0] = $1;
						$$ -> child[1] = $3;
					}
					| 	additive-expression {$$ = $1;}
					;				
relop				: 	LE {$$ = LE;}
					|	LT {$$ = LT;}
					|	GT {$$ = GT;}
					|	GE {$$ = GE;}
					|	EQ {$$ = EQ;}
					|	NQ {$$ = NQ;}
					;
additive-expression :	additive-expression addop term
					{
						$$ = newExpNode(OpK);
						$$ -> lineno = lineno;
						$$ -> attr.op = $2;
						$$ -> child[0] = $1;
						$$ -> child[1] = $3;
					}
					|	term {$$ = $1}
					;
addop 				:	PLUS {$$ = PLUS;}
					|	MINUS {$$ = MINUS;}
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
empty				: '' {$$ = NULL};				




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