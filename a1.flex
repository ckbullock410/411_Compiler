%{
/*	Chandler Bullock
	Akal
	CPSC411 Assignment #1	
*/
#include <stdio.h>
FILE *output;
int lineNumber = 1;
int commentOpen = 0;

enum TokenType{
NUM,ID,KEYWORD,ERROR,END,SYMBOL, NEWLINE
}token;

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
PLUS	\+
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
OR	"||"
SEMI	;
COMMA	,
OPENP	\(
CLOSEP	\)
OPENB	\[
CLOSEB	\]
OPENBRACE	\{
CLOSEBRACE	\}
OPENCOMM	"/*"
CLOSECOMM	"*/"
DIGIT	[0-9]
NUM	{DIGIT}+
LETTER	[A-Z]|[a-z]
ID	{LETTER}+
NEWLINE	"\n"
UNIDENTIFIED	.
%%
{BOOL}		{return KEYWORD;}
{INT}		{return KEYWORD;}
{ELSE}		{return KEYWORD;}
{NOT}		{return KEYWORD;}
{RET}		{return KEYWORD;}
{TRUE}		{return KEYWORD;}
{FALSE}		{return KEYWORD;}
{VOID}		{return KEYWORD;}
{WHILE}		{return KEYWORD;}
{PLUS}		{return SYMBOL;}
{MINUS}		{return SYMBOL;}
{STAR}		{return SYMBOL;}
{SLASH}		{return SYMBOL;}
{LT}		{return SYMBOL;}
{GT}		{return SYMBOL;}
{LTE}		{return SYMBOL;}
{GTE}		{return SYMBOL;}
{EQ}		{return SYMBOL;}
{NOTEQ}		{return SYMBOL;}
{ASSIGN}	{return SYMBOL;}
{AND}		{return SYMBOL;}
{OR}		{return SYMBOL;}
{SEMI}		{return SYMBOL;}
{COMMA}		{return SYMBOL;}
{OPENP}		{return SYMBOL;}
{CLOSEP}	{return SYMBOL;}
{OPENB}		{return SYMBOL;}
{CLOSEB}	{return SYMBOL;}
{OPENBRACE}	{return SYMBOL;}
{CLOSEBRACE}	{return SYMBOL;}
{NUM}		{return NUM;}
{ID}		{return ID;}
{WSPACE}	{/*do nothing*/}
{NEWLINE} 	{lineNumber++;}
{OPENCOMM}	{commentOpen = 1;}
{CLOSECOMM}	{if (commentOpen == 1){commentOpen = 0;} else {fprintf(output,"%d: Unmatched */\n", lineNumber);}}
{UNIDENTIFIED}	{return ERROR;}
<<EOF>>		{return END;}
%%

void printToken(enum TokenType token){
	/*get a string for what will print after line number and before the lexeme*/
	char* text;
	switch(token){
		case NUM:
			text = " NUM: ";
			break;
		case ID:
			text = " ID, name = ";
			break;
		case KEYWORD:
			text = " reserved word: ";
			break;
		case SYMBOL:
			text = " special symbol: ";
			break;
		case ERROR:
			text = " ERROR: ";
			break;
		default:
			text = " Something went wrong, unclassified token";
	}
	fprintf(output, "%d:%s%s\n", lineNumber, text, yytext);
}

int main(int argc, char** argv){
	output = fopen("out.txt", "w");
	FILE *readFrom;
	if (argc == 2){
		readFrom = fopen(argv[1],"r");
		fprintf(output, "C- COMPILATION: %s\n", argv[1]);
	} else{
		readFrom = fopen("input.cm", "r");
		fprintf(output, "C- COMPILATION: input.cm\n");
	}
	yyin = readFrom;

	token = yylex();
	while (token != END){
		if (token != NEWLINE && commentOpen != 1) {printToken(token);}
		token = yylex();
	}
	if (commentOpen == 1){fprintf(output, "%d: ERROR: EOF in comment", lineNumber);}

	fclose(output);
	fclose(readFrom);
	return 0;
}

