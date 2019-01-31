%{
/*	Chandler Bullock
	Akal
	CPSC411 Assignment #1	
*/
#include <stdio.h>
FILE *fp;
int lineNumber = 0;
int commentOpen = 0;

%}
WSPACE	[ \t]+
BOOL	bool
INT	int
ELSE	else
NOT	not
RET	return
TRUE	true
FALSE	false
VOID	void
WHILE	while
PLUS	+
MINUS	-
STAR	\*
SLASH	\/
LT	<
GT	>
LTE	<=
GTE	>=
EQ	==
NOTEQ	!=
ASSIGN	=
AND	&&
OR	\|\|
SEMI	;
COMMA	,
OPENP	\(
CLOSEP	\)
OPENB	\[
CLOSEB	\]
OPENBRACE	\{
CLOSEBRACE	\}
DIGIT	[0-9]
NUM	{DIGIT}+
LETTER	[A-Z]|[a-z]
ID	{LETTER}+
NEWLINE	\\n
UNIDENTIFIED	.
COMMENT		\/\*.*\*\/
%%
{WSPACE}	{/*do nothing*/}
{NEWLINE} 	{lineNumber++;}
{VOID}		{fprintf(fp,"%d : Keyword : %s\n", lineNumber, yytext);}
{ID}		{fprintf(fp,"%d : Identifier : %s\n", lineNumber, yytext);}
{NUM}		{fprintf(fp,"%d : Value : %s\n", lineNumber, yytext);}
{OPENBRACE}	{fprintf(fp,"open brace\n");}
{CLOSEBRACE}	{fprintf(fp,"close brace\n");}
{OPENP}		{fprintf(fp,"open parentheses\n");}
{CLOSEP}	{fprintf(fp,"close parentheses\n");}
{UNIDENTIFIED}	{fprintf(fp, "%d : ERROR : %s", lineNumber, yytext);}
{COMMENT}	{/*do nothing*/}
<<EOF>>		{yyterminate();}
%%
int main(){
	fp = fopen("a1out.txt", "w");
	FILE *readFrom;
	readFrom = fopen("test.cm","r");
	yyin = readFrom;
	yylex();
	fclose(fp);
	fclose(readFrom);
	return 0;
}
