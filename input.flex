%{
/*	Chandler Bullock
	Akal
	CPSC411 Assignment #1	
*/
#include <stdio.h>

int lineNumber = 0;
int parenthOpen = 0;
int braceOpen = 0;
int bracketOpen = 0;
bool commentOpen = 0;

%}
BOOL	"bool"
INT	"int"
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
OPENCOMM	\/\*
CLOSECOMM	\*\/
DIGIT	[0-9]
NUM	{DIGIT}+
LETTER	[A-Z]|[a-z]
ID	{LETTER}+
NEWLINE	\\n
%%
NEWLINE	\\n
UNIDENTIFIED	.*
%%
{NEWLINE} {lineNumber++;}
<<EOF>>	{yyterminate();}
%%
int main(){
	yylex();
	return 0;
}
