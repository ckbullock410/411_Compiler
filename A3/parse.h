/****************************************************/
/* File: parse.h                                    */
/* The parser interface for the C- compiler         */
/* Fatemeh Hosseini                                 */
/****************************************************/

#ifndef _PARSE_H_
#define _PARSE_H_
#include "globals.h"
/* Function parse returns the newly 
 * constructed syntax tree
 */
TreeNode * parse(void);

#endif
