%{
/*	Chandler Bullock
	Akal
	CPSC411 Assignment #1	
*/

#include "globals.h"
#include "util.h"
#include "scan.h"

int commentOpen = 0;
%}
digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \n
whitespace  [ \t]+
OPENCOMM	"/*"
CLOSECOMM	"*/"
UNIDENTIFIED	.
%%
"bool"          {  return BOOL;}
"if"            {  return IF;}
"else"          {  return ELSE;}
"while"         {  return WHILE;}
"return"        {  return RETURN;}
"true"          {  return TRUE;}
"false"         {  return FALSE;}
"void"          {  return VOID;}
"int"           {  return INT;}
"not"           {  return NOT;}
"="             {  return ASSIGN;}
"!="            {  return NQ;}
"=="            {  return EQ;}
"<"             {  return LT;}
">"             {  return GT;}
"<="            {  return LE;}
">="            {  return GE;}
"&&"            {  return AND;}
"||"            {  return OR;}
"+"             {  return PLUS;}
"-"             {  return MINUS;}
"*"             {  return TIMES;}
"/"             {  return OVER;}
"("             {  return LPAREN;}
")"             {  return RPAREN;}
";"             {  return SEMI;}
","             {  return COMMA;}
"["		        {  return LBRACK;}
"]"		        {  return RBRACK;}
"{"             {  return LCBRACK;}
"}"		        {  return RCBRACK;}
{number}        {  return NUM;}
{identifier}    {  return ID;}
{newline}       {lineno++;}
{OPENCOMM}		{commentOpen = 1;}
{CLOSECOMM}		{if (commentOpen == 1){commentOpen = 0;} else {printToken(ERROR,"Unmatched '*/'"); exit(1)}}
{UNIDENTIFIED}	{printToken(ERROR, "Unidentified Symbol"); exit(1)}
{whitespace}    {/* skip whitespace */}
<<EOF>>			{if(commentOpen == 0) {return ENDFILE;} else {printToken(ERROR, "EOF in comment"); exit(1)}}
%%


TokenType getToken(int firstTime){
	if (firstTime){
	   firstTime = FALSE;
	   lineno++;
	   yyin = source;
	   yyout = listing;
	}
	tokenString = yytext;	//might cause an error, but export attr value to global var
	//IF EOF encountered see if comment is open and pass error if so
	return yylex();
}