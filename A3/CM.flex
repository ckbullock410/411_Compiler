/****************************************************/
/* File: CM.flex                                    */
/* The lex specification for C-                     */
/*                                                  */
/****************************************************/

%x COMMENT_MULTI_LINE
%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
char previousTokenString[MAXTOKENLEN+1];


%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \n
whitespace  [ \t]+


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
"["		{  return LBRACK;}
"]"		{  return RBRACK;}
"{"             {  return LCBRACK;}
"}"		{  return RCBRACK;}
{number}        {  return NUM;}
{identifier}    {  return ID;}
{newline}       {lineno++;}
{whitespace}    {/* skip whitespace */}
<INITIAL>"/*"   {
		  BEGIN(COMMENT_MULTI_LINE);

		}
<COMMENT_MULTI_LINE>"*/"	{
				  BEGIN(INITIAL);
				}
<COMMENT_MULTI_LINE><<EOF>>	{
				  printToken(ERROR,"EOF in comment");
				  yyterminate();

				}

<COMMENT_MULTI_LINE>.		{
}
<COMMENT_MULTI_LINE>\n		{
}

.               {// printToken(ERROR,yytext);
		  return ERROR;}

%%

TokenType getToken(int firstTime)
{ 
  TokenType currentToken;
  
  if (firstTime)
  {//fprintf(listing,"Flex has strated working!\n");  
   firstTime = FALSE;
   lineno++;
   yyin = source;
   yyout = listing;
  }
  currentToken = yylex();
  strncpy(previousTokenString,tokenString,MAXTOKENLEN);
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    fprintf(listing,"\t");
    printToken(currentToken,tokenString);
  }
  return currentToken;
}
