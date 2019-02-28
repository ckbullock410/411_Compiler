%{
#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"
#define YYPARSER
#define YYSTYPE int
%}
%token BOOL INT ELSE NOT RET TRUE FALSE VOID WHILE
%token ID NUM
%token PLUS MINUS STAR SLASH LT GT LTE GTE EQ NOTEQ ASSIGN AND OR SEMI COMMA OPENP CLOSEP OPENB CLOSEB OPENBRACE CLOSEBRACE OPENCOMM CLOSECOMM
%token ERROR
%%
program: declaration-list;
declaration-list: d
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