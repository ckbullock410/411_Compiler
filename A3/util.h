/****************************************************/
/* File: util.h                                     */
/* Utility functions for the C- compiler            */
/* Fatemeh Hosseini                                 */
/****************************************************/

#ifndef _UTIL_H_
#define _UTIL_H_
#include "globals.h"
/* Procedure printToken prints a token 
 * and its lexeme to the listing file
 */
void printToken( TokenType token, const char* tokenString);



/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind);

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind);

TreeNode *newDecNode(DecKind);

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char * copyString( char * );

/* procedure printTree prints a syntax tree to the 
 * listing file using indentation to indicate subtrees
 */
void printTree( TreeNode * );

#endif
