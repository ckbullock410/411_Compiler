/****************************************************/
/* File: analyze.c                                  */
/* Semantic analyzer                                */
/*                                                  */
/*                                                  */
/*                                                  */
/****************************************************/

#include "globals.h"
#include "symtab.h"
#include "analyze.h"


static int scope_a = 0; 
//increment for each function delcaration to seperate their scopes

/* counter for variable memory locations */
static int location[MAX_SCOPE] = {0,0,0}; 
//first element for global vars, second for function scope

static int No_change = 0; 
/* Procedure traverse is a generic recursive 
 * syntax tree traversal routine:
 * it applies preProc in preorder and postProc 
 * in postorder to tree pointed to by t
 */
static void traverse( TreeNode * t,
               void (* preProc) (TreeNode *),
               void (* postProc) (TreeNode *) )
{ if (t != NULL)
  { preProc(t);
    int i;
    for (i=0; i < MAXCHILDREN; i++)
        traverse(t->child[i],preProc,postProc);
    
    postProc(t);
    traverse(t->sibling,preProc,postProc);
  }
}

/* nullProc is a do-nothing procedure to 
 * generate preorder-only or postorder-only
 * traversals from traverse
 */
static void nullProc(TreeNode * t)
{ if (t==NULL) return;
  else return;
}

/* Procedure insertNode inserts 
 * identifiers stored in t into 
 * the symbol table 
 */
static void insertNode( TreeNode * t)
{ 

  //GO THROUGH AND USE GLOBAL_SIZE AND LOCAL_SIZE TO INCREMENT LOCATION

    int mem_loc st_lookup(t->name, scope_a);
    int is_global_declared = st_lookup(t->name, 0);

    if(t->nodekind == DecKind){
      if(t->kind == VarK){
        if(mem_loc != -1){
          //not encountered yet in this scope
          st_insert(t->attr.name, t->lineno, location[0], scope_a, t->isParameter);
          t->scope = scope_a;

          if (scope_a == 0){
            location[0]++;
          } else {
            location[1]++;
          }

        } else {
          // has been declared already in this scope, throw an error?

        }
      } 

      else if (t->kin == ArrayK){
        if(mem_loc != -1){
            //if it's an array declaration and hasn't happened in this scope
            st_insert(t->attr.name, t->lineno, location[0], scope_a, t->isParameter)
            t->scope = scope_a;
            if(scope_a != 0){
              location [1] += t->value;
            } else {
              location[0] += t-> value;
            } 
        } else {
          //aray has been declared in this scope throw erro

        }
      } 

      else if (t->kind == FunkK){
        //function declaration happening so increase the scope
        if(mem_loc != -1){
          scope_a++;
          location[1] = 0; //reset the location for the new function
          st_insert(t->attr.name, t->lineno, -1, scope_a, FALSE);
          t->scope = scope_a;
        } else {
          //function already previously declared throw erro

        }
      }
    }

    else if (t->nodekind == ExpKind && t->kind == AssignK){
      if(t->kind == AssignK){
      //this is an assignment need to check that ID is in symbol table
        if(mem_loc != -1){
          //id is in there so just pass the same memory location
          st_insert(t->name, t->lineno, mem_loc, scope_a, t->child[0]->isParameter);
          t->scope = scope_a;
        } else if(is_global_declared == -1) {
          //trying to assign to an ID that has not been declared, throw error

        }
      } else if(t->kind == IdK){
        //must check if the ID is existing alre1ady in either this scope or global
        if(mem_loc != -1){
          //it has been declared in this scope insert the identifier
          insert(t->name, t->lineno, mem_loc, scope_a, t->isParameter);
        } else if (is_global_declared != -1){
          //if it's a global variable insert it into this scope
          insert(t->name, t->lineno, location, scope_a, FALSE);
        }
      }
    } 

    else if (t->nodekind == StmtKind && t->kind == CallK){
      //make sure the function name being called is in the symbol table
      //must check every prior scope for the function declaration

      int i = scope_a;
      int result = fun_lookup(t->name, i);

      while(result == NULL && i != 0){
        i--;
        result = fun_lookup(t->name, i);       
      }
      if (i == 0){
        //declaration not found in any scope throw an error

      } else {
        // declaration found can insert the call identifier into symbol table
        st_insert(t->name, t->lineno, location[1],scope_a, FALSE );
        t->scope = scope_a;
      }
    }
}

/* Function buildSymtab constructs the symbol 
 * table by preorder traversal of the syntax tree
 */
void buildSymtab(TreeNode * syntaxTree)
{ traverse(syntaxTree,insertNode,nullProc);
  //if (TraceAnalyze)
   fprintf(listing,"\nSymbol table:\n\n");
    printSymTab(listing);
}

static void typeError(TreeNode * t, char * message)
{ fprintf(listing,"Type error at line %d: %s\n",t->lineno,message);
  Error = TRUE;
}

/* Procedure checkNode performs
 * type checking at a single tree node
 */
static void checkNode(TreeNode * t)
{ 
  switch(NodeKind){
      case StmtKind:
        switch(kind){
            case IfK:
              if(t->child[0]->type != Boolean){
                //throw error
                typeError(t, "The expression in if doesn't evaluate to a boolean.");
              } 

            case WhileK:
              if(t->child[0]->type != Boolean){
                //throw error
                typeError(t, "The expression for 'while' doesn't evealute to a boolean.");
              }

            case CallK:
              //parameters must be integer types, loop through child siblings
              ExpType x = t->child[0]->type;
              int flag = 1;

              while(x != NULL){
                if (x != Void || x != Integer){
                  flag = 0;
                  break;
                }
              }

              if(!flag) {
                //argument type isn't integer or void throw error
                typeError(t, "Argument type isn't and int or void");
              }
             
            case ReturnK:
              //return type must be an integer or null
              if(t->child[0]->type != NULL || t->child[0]->type != Integer){
                //throw error
                typeError(t, "Return type must be void or an int");
              }

        }

      case ExpKind:
        switch(kind){
            case OpK:
              if(t->child[0] != Integer || t->child[1] != Integer){
                  //throw an error
                  typeError(t, "Numbers need to be on both sides of this operation.");
              }

              if(t->attr.op == LT ||
                t->attr.op == LE ||
                t->attr.op == GT ||
                t->attr.op == GE ||
                t->attr.op == EQ ||
                t->attr.op == NQ){

                t->type = Boolean;
              }
            case ConstK:
                t->type = Integer;

            case AssignK:
              if(t->child[1]->type != Integer){
                //throw error
                typeError(t, "Must assign an integer to this variable");
              }
        }
  }
}

/* Procedure typeCheck performs type checking 
 * by a postorder syntax tree traversal
 */
void typeCheck(TreeNode * syntaxTree)
{ traverse(syntaxTree,nullProc,checkNode);
}
