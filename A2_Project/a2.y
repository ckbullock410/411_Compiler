%{

#define YYPARSER
#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *

static char * savedName; 
static int holdNum;

static int paramCounter = 0;
static int localCounter = 0;
static int currentlyGlobal = 1; 
static TreeNode * savedTree;
static ExpType savedExpType;
static TokenType savedTokenType;

int yylex();
int yyerror(char * c);
/*
---------- TO DO LIST ------------
Figure out how parameters are going to work / arguments
Initialize all the semantic variables at the right times
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
					|	declaration {$$ = $1;}
					;
declaration 		:	var-declaration {$$ = $1;}
					|	fun-declaration {$$ = $1;}
					;
var-declaration		:	type-specifier ID {savedName = copyString(tokenString);} SEMI
					{
						$$ = newDecNode(VarK);
						$$ -> type = savedExpType;
						$$ -> attr.name = savedName;
					}
					|	type-specifier ID {savedName = copyString(tokenString);}
						 LBRACK NUM{holdNum = atoi(tokenString);} RBRACK SEMI 
					{
						$$ = newDecNode(ArrayK);
						$$ -> isArray = TRUE;
						$$ -> type = savedExpType;
						$$ -> attr.val = holdNum;
						$$ -> attr.name = savedName;
					}
					;
type-specifier		: 	INT {savedExpType =  Integer;}
					| 	VOID {savedExpType =  Void;}
					;
fun-declaration 	:	type-specifier ID {savedName = copyString(tokenString);} LPAREN params RPAREN compound-stmt
					{
						$$ = newDecNode(FunK);
						$$ -> attr.name = savedName;
						$$ -> type = (ExpType) $1;
						$$ -> child[0] = $5;
						$$ -> child[1] = $7;
					}
					;
params				:	param-list {$$ = $1;}
					|	VOID {$$ = Void;}
					;
param-list			:	param-list COMMA param
					{  
						YYSTYPE t = $1;
                   		if (t != NULL){
                   			while (t->sibling != NULL)
                        		t = t->sibling;
                     		t->sibling = $3;
                     		$$ = $1; }
                     	else $$ = $3;
		            }
					|	param {$$ = $1;}
					;
param 				:	type-specifier ID
					{
						$$ = newDecNode(VarK);
						$$ -> type = savedExpType;
					}
					|	type-specifier ID LBRACK RBRACK
					;
compound-stmt		:	LCBRACK local-declarations statement-list RCBRACK
					{
						$$ = newStmtNode(CompoundK);
						$$ -> child[0] = $2;
						$$ -> child[1] = $3;
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
						$$ -> child[0] = $3;
						$$ -> child[1] = $5;
					}
					|	IF LPAREN expression RPAREN statement ELSE statement
					{
						$$ = newStmtNode(IfK);
						$$ -> child[0] = $3;
						$$ -> child[1] = $5;
						$$ -> child[2] = $7;
					}
					;
iteration-stmt		:	WHILE LPAREN expression RPAREN statement
					{
						$$ = newStmtNode(WhileK);
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
							$$ -> attr.name = copyString(tokenString);
						}
					| 	ID {savedName = copyString(tokenString);} LBRACK expression RBRACK
						{
							$$ = newExpNode(IdK);
							$$ -> attr.name = savedName;
							$$ -> child[0] = $4;
						}
					;
simple-expression 	: 	additive-expression relop additive-expression
					{
						$$ = newExpNode(OpK);
						$$ -> attr.op = savedTokenType;
						$$ -> child[0] = $1;
						$$ -> child[1] = $3;
					}
					| 	additive-expression {$$ = $1;}
					;				
relop				: 	LE {savedTokenType = LE;}
					|	LT {savedTokenType = LT;}
					|	GT {savedTokenType = GT;}
					|	GE {savedTokenType = GE;}
					|	EQ {savedTokenType = EQ;}
					|	NQ {savedTokenType = NQ;}
					;
additive-expression :	additive-expression addop term
					{
						$$ = newExpNode(OpK);
						$$ -> attr.op = savedTokenType;
						$$ -> child[0] = $1;
						$$ -> child[1] = $3;
					}
					|	term {$$ = $1;}
					;
addop 				:	PLUS {savedTokenType = PLUS;}
					|	MINUS {savedTokenType = MINUS;}
					;
term				:	term mulop factor
					{
						$$ = newExpNode(OpK);
						$$ -> attr.op = savedTokenType;
						$$ -> child[0] = $1;
						$$ -> child[1] = $3;
					}
					| 	factor {$$ = $1;}
					;
mulop				:	TIMES {savedTokenType = TIMES;}
					| 	OVER {savedTokenType = OVER;}
					;
factor				:	LPAREN expression RPAREN {$$ = $2;}
					|	var {$$ = $1;}
					|	call {$$ = $1;}
					|	NUM 
					{
						$$ = newExpNode(ConstK); 
						$$ -> attr.val = atoi(tokenString);
					}
					;
call				:	ID {savedName = copyString(tokenString);} LPAREN args 						RPAREN
				 	{
				 		$$ = newStmtNode(CallK);
				 		$$ -> attr.name = savedName;
				 		$$ -> child[0] = $4;
				 	}	
					;
args				:	arg-list {$$ = $1;}
					|	empty 
					;
arg-list			:	arg-list COMMA expression
					{  
						YYSTYPE t = $1;
                   		if (t != NULL){
                   			while (t->sibling != NULL)
                        		t = t->sibling;
                     		t->sibling = $3;
                     		$$ = $1; }
                     	else $$ = $3;
		            }					
		            |	expression {$$ = $1;}
					;	
empty				: %empty {$$ = NULL;};	

%%

/* ------------ C CODE ----------------- */

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  return 0;
}


TreeNode * parse(void){ 
	yyparse();
  	return savedTree;
}
