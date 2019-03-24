/****************************************************/
/* File: CM.y                                       */
/* The C-   Yacc/Bison specification file           */
/* Fatemeh Hosseini                                 */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */
#define YYDEBUG 1 
#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"
#include "stack.h"

#define YYSTYPE TreeNode * /*return type by yyparse procedure, enbale us to create syntax tree*/

//static char * savedName; /* for use in assignments, temporarily stores identifier string to be inserted in TreeNode that is not created yet */
static char * savedNUM;
//static int savedLineNo;  /* proper source code line number will be accosiated with identifiers */

static int global_size = 0;

STRING_STACK * ss;
extern INT_STACK si;

static TreeNode * savedTree; /* temporarily stores syntax tree for later return */
static int yylex();
int yyerror(char * s);

static int firstTime = 1; //only at the first time, yyin and yyout are getting values in getToken

%}

%token    ENDFILE ERROR
%token    IF ELSE WHILE RETURN VOID BOOL TRUE FALSE INT NOT
%token    ID NUM
%token    ASSIGN EQ NQ LT GT LE GE PLUS MINUS TIMES OVER LPAREN RPAREN SEMI COMMA LBRACK RBRACK LCBRACK RCBRACK AND OR
%%
program : declaration_list
		{ 
		  if($1->kind.dec != FunK)
 		    	$1->param_size = global_size;
		  savedTree = $1;
		} 
        ;
declaration_list : declaration_list declaration
			{
			 YYSTYPE t = $1;
			 if ($2->kind.dec == VarK)
				{       $2->isGlobal = 1; //True
					global_size++;
				}
			 else if ($2->kind.dec == ArrayK)
				{	$2->isGlobal = 1; //True
					global_size = global_size + ($2->value);
				}

                         if (t != NULL)
                          { 
			    while (t->sibling != NULL)
				{  t = t->sibling;

				}
                            t->sibling = $2;
                            $$ = $1; }
                         else $$ = $2;
			}
		 | declaration {$$ = $1;
				if ($$->kind.dec == VarK)
				   {    $$->isGlobal = 1; //True
					global_size++;
				   }
				else if ($$->kind.dec == ArrayK)
				   {    $$->isGlobal = 1; //True
					global_size = global_size + ($$->value);
				   }
				}
                 ;
declaration : var_declaration {$$ = $1;}
	    | fun_declaration {$$ = $1;}
	    ;
var_declaration : INT ID  { push_string_stack(ss,previousTokenString); push_int_stack(lineno);
			    //fprintf(listing,"VAR ID tokenstring:%s\n",previousTokenString);	
			    //display_string_stack(ss);
			  } 
                  SEMI 
		   {
		    $$ = newDecNode(VarK);
                    $$->attr.name = copyString(pop_string_stack(ss));
                    $$->type = Integer;
		    $$->local_size = 1;			    
		    $$->lineno = pop_int_stack();
		   }
		| INT ID {push_string_stack(ss,previousTokenString); push_int_stack(lineno);
			  //display_string_stack(ss);
			 }
		  LBRACK NUM { savedNUM = copyString(tokenString);}
                  RBRACK SEMI
		   {
		    $$ = newDecNode(ArrayK);
		    $$->attr.name = copyString(pop_string_stack(ss));
		    $$->type = Integer;
		    $$->lineno = pop_int_stack();
		    $$->isArray = 1; //True
		    $$->value = atoi(savedNUM);
		    $$->local_size = $$->value;			    
		   }
		;

fun_declaration : INT ID {
			  push_string_stack(ss,previousTokenString); push_int_stack(lineno);
			  //fprintf(listing,"funcName:%s\n",savedName);
			  //display_string_stack(ss);
			  }
	          LPAREN params RPAREN compound_stmt
	  	   {
		    $$ = newDecNode(FunK);
		    $$->attr.name = copyString(pop_string_stack(ss));
		    $$->type = Integer;
		    $$->lineno = pop_int_stack();
		    $$->child[0] = $5;
		    $$->child[1] = $7;
		    
		   }
		| VOID ID
			   {push_string_stack(ss,tokenString); push_int_stack(lineno);
			    //fprintf(listing,"funcName:%s\n",tokenString);
			    //display_string_stack(ss);
			    }
	          LPAREN params RPAREN compound_stmt
	  	   {//fprintf(listing,"func:%s\n",savedName);
		    $$ = newDecNode(FunK);
		    $$->attr.name = copyString(pop_string_stack(ss));
		    $$->type = Void;
		    $$->lineno = pop_int_stack();
		    $$->child[0] = $5;
		    $$->child[1] = $7;
		    //if ($$->child[1] == NULL) fprintf(listing,"no compound_stmt\n");
		    //else fprintf(listing,"compound_stmt is not NULL\n");
		   }
		;
params : param_list {$$ = $1;}
       | VOID {$$ = NULL;}
       ;
param_list : param_list COMMA param
		{
		 YYSTYPE t = $1;
		 int param_count = 0;
                 if (t != NULL)
                  { param_count++;
		    while (t->sibling != NULL)
		    {	   param_count++;
                           t = t->sibling;
		    }
                    t->sibling = $3;
		    param_count++;
		    t->param_size = param_count;
                    $$ = $1; }
                    else {$$ = $3; $$->param_size = 1;}
		}
           | param {$$ = $1; $$->param_size = 1;}
	   ;
param : INT ID
	{
	 $$ = newDecNode(VarK);
	 $$->attr.name = copyString(previousTokenString);
         $$->type = Integer;
	 $$->lineno = lineno;
         $$->isParameter = 1; //True
	 
	}
      | INT ID {push_string_stack(ss,previousTokenString); push_int_stack(lineno);
		//display_string_stack(ss);
	       }
	LBRACK RBRACK
	{
	 $$ = newDecNode(ArrayK);
	 $$->attr.name = copyString(pop_string_stack(ss));
	 $$->type = Integer;
	 $$->lineno = pop_int_stack();
	 $$->isParameter = 1; //True
	 $$->value = 0;
	 $$->isArray = 1; //True
        }
      ;
compound_stmt : LCBRACK local_declarations statement_list RCBRACK
		 {//fprintf(listing,"compound_statement\n");
		  $$ = newStmtNode(CompoundK);
		  $$->child[0] = $2;
		  $$->child[1] = $3;
		  $$->lineno = lineno;
		 }
	      ;
local_declarations : local_declarations var_declaration
			{ //fprintf(listing,"local_declarations\n");
			  YYSTYPE t = $1;
			  YYSTYPE temp;
			  int local_var = 0;
                   	  if (t != NULL)
                           { 
			     while (t->sibling != NULL)
			      { 
                       	        t = t->sibling;
			      }
                    	     t->sibling = $2;
			     temp = $1;
			     while(temp != NULL){
			    	local_var = local_var + temp->local_size;
			    	temp = temp->sibling;
   			      }	
                    	     $$ = $1;
			     $$->local_size = local_var; }
                    	   else {$$ = $2; $$->local_size = $2->local_size;}
                        }
                   | %empty {$$ = NULL;}
		   ;
statement_list : statement_list statement
		 { //fprintf(listing,"statement_list\n ");
		   YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $2;
                     $$ = $1; }
                   else $$ = $2;
                 }
               | %empty {$$ = NULL;}
	       ;
statement : expression_stmt {$$ = $1;}
          | compound_stmt {$$ = $1;}
          | selection_stmt {$$ = $1;}
          | iteration_stmt {$$ = $1;}
          | return_stmt {$$ = $1;}
	  ;
expression_stmt : expression SEMI {$$ = $1;}
                | SEMI {$$ = NULL;}
		;
selection_stmt  : IF LPAREN expression RPAREN statement
		   { $$ = newStmtNode(IfK);
                     $$->child[0] = $3;
                     $$->child[1] = $5;
		     $$->lineno = lineno;
                   }
                | IF LPAREN expression RPAREN statement ELSE statement
		   { $$ = newStmtNode(IfK);
                     $$->child[0] = $3;
                     $$->child[1] = $5;
                     $$->child[2] = $7;
		     $$->lineno = lineno;
                   }
                ;
iteration_stmt : WHILE LPAREN expression RPAREN statement
		  { $$ = newStmtNode(WhileK);
                    $$->child[0] = $3;
                    $$->child[1] = $5;
		    $$->lineno = lineno;
                  }
               ;
return_stmt : RETURN SEMI
	       { $$ = newStmtNode(ReturnK);
                 $$->child[0] = NULL;
                 $$->lineno = lineno;
               }
            | RETURN expression SEMI
	       {  $$ = newStmtNode(ReturnK);
                  $$->child[0] = $2;
		  $$->lineno = lineno;
               }
            ;
expression : var ASSIGN expression
		{//fprintf(listing,"assigned value:%d\n",$3->attr.val);
		 $$ = newExpNode(AssignK);
                 $$->child[0] = $1;
                 $$->child[1] = $3;
                 $$->attr.val = $3->attr.val;
		 $$->lineno = lineno;
		}
	   
           | simple_expression {$$ = $1;}
           ;
var : ID {$$ = newExpNode(IdK);
          $$->attr.name = copyString(previousTokenString);
	  $$->lineno = lineno;
	  $$->type = Integer;
	 }
    | ID {push_string_stack(ss,previousTokenString); push_int_stack(lineno);
	  //display_string_stack(ss);
	 }
      LBRACK expression RBRACK
	{
	 $$ = newDecNode(ArrayK);
	 $$->attr.name = copyString(pop_string_stack(ss));
	 $$->isArray = 1; //True
	 $$->type = Integer;
	 $$->lineno = pop_int_stack();
	}
    ;
simple_expression : additive_expression LE additive_expression
			{
		   	 $$ = newExpNode(OpK);
                  	 $$->child[0] = $1;
                  	 $$->child[1] = $3;
                  	 $$->attr.op = LE;
			 $$->lineno = lineno;
			}
		  | additive_expression LT additive_expression 
                	 { $$ = newExpNode(OpK);
                  	   $$->child[0] = $1;
                  	   $$->child[1] = $3;
                  	   $$->attr.op = LT;
			   $$->lineno = lineno;
                	 }
		  | additive_expression GT additive_expression 
                	 { $$ = newExpNode(OpK);
                  	   $$->child[0] = $1;
	                   $$->child[1] = $3;
        	           $$->attr.op = GT;
			   $$->lineno = lineno;
                 	}
		  | additive_expression GE additive_expression 
                	 { $$ = newExpNode(OpK);
	                   $$->child[0] = $1;
        	           $$->child[1] = $3;
                	   $$->attr.op = GE;
			   $$->lineno = lineno;
                 	}
		  | additive_expression EQ additive_expression 
	                 { $$ = newExpNode(OpK);
        	           $$->child[0] = $1;
                	   $$->child[1] = $3;
                   	   $$->attr.op = EQ;
			   $$->lineno = lineno;
                 	}
		  | additive_expression NQ additive_expression 
	                 { $$ = newExpNode(OpK);
        	           $$->child[0] = $1;
                	   $$->child[1] = $3;
                 	   $$->attr.op = NQ;
			   $$->lineno = lineno;
                 	 }
                  | additive_expression {$$ = $1;}
		  ;

additive_expression : additive_expression PLUS term 
			{
			  $$ = newExpNode(OpK);
          	          $$->child[0] = $1;
	                  $$->child[1] = $3;
                  	  $$->attr.op = PLUS;
			  $$->lineno = lineno;
			 }
		    | additive_expression MINUS term
			{
			 $$ = newExpNode(OpK);
			 $$->child[0] = $1;
			 $$->child[1] = $3;
			 $$->attr.op = MINUS;
			 $$->lineno = lineno;
			}
                    | term {$$ = $1;}
		    ;
term : term TIMES factor
	{
	 $$ = newExpNode(OpK);
         $$->child[0] = $1;
         $$->child[1] = $3;
         $$->attr.op = TIMES;
	 $$->lineno = lineno;
	}
     | term OVER factor
	{
	 $$ = newExpNode(OpK);
	 $$->child[0] = $1;
	 $$->child[1] = $3;
	 $$->attr.op = OVER;
	 $$->lineno = lineno;
	}
     | factor {$$ = $1;}
     ;

factor : LPAREN expression RPAREN
	     {$$ = $2;}
       | var {$$ = $1;}
       | call {$$ = $1;}
       | NUM {$$ = newExpNode(ConstK);
              $$->attr.val = atoi(tokenString);}
       | error {$$ = NULL;}
       ;
call : ID {push_string_stack(ss,previousTokenString); push_int_stack(lineno);
	   //display_string_stack(ss);
	  } 
       LPAREN args RPAREN
	{
	 $$ = newStmtNode(CallK);
         $$->child[0] = $4;
	 if($4 != NULL)
            	$$->param_size = $4->param_size;
         else
            	$$->param_size = 0;
         $$->attr.name = copyString(pop_string_stack(ss));
	 $$->lineno = pop_int_stack();
	}
     ;
args : arg_list {$$ = $1;}
     | %empty {$$ = NULL;}
     ;
arg_list : arg_list COMMA expression 
	   {
	    YYSTYPE t = $1;
	    int arg_count = 0;
            if (t != NULL)
             { arg_count++;
	       while (t->sibling != NULL)
                     {   arg_count++;
			 t = t->sibling;
		     }
               t->sibling = $3;
   	       arg_count++; //for new expression
	       t->param_size = arg_count;
               $$ = $1; }
            else {$$ = $3; $$->param_size = 1;}
	   }
         | expression {$$ = $1; $$->param_size = 1;}
	 ;

%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the C- scanner
 */
static int yylex(void)
{
 
 TokenType t = getToken(firstTime);
 firstTime = 0;
 if(t != EOF)
  {//printf("not EOF\n");
    return t;
  }
 return 0;
}

TreeNode * parse(void)
{ yydebug = 1;
  ss = init_string_stack();
  yyparse();
  printf("global_size:%d\n",global_size);
  return savedTree;
}
