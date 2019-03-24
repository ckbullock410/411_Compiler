/****************************************************/
/* File: util.c                                     */
/* Utility function implementation                  */
/* for the C- compiler                              */
/* Fatemeh Hosseini                                 */
/****************************************************/

#include "globals.h"
#include "util.h"

/* Procedure printToken prints a token 
 * and its lexeme to the listing file
 */
void printToken( TokenType token, const char* tokenString )
{ switch (token)
  { case IF:
    case WHILE:
    case ELSE:
    case INT:
    case BOOL:
    case NOT:
    case RETURN:
    case TRUE:
    case FALSE:
    case VOID:
      fprintf(listing,
         "%d: reserved word: %s\n",lineno,tokenString);
      break;
    case ASSIGN: fprintf(listing,"%d: special symbol: =\n",lineno); break;
    case LT: fprintf(listing,"%d: special symbol: <\n",lineno); break;
    case LE: fprintf(listing, "%d: special symbol: <=\n",lineno); break;
    case GT: fprintf(listing, "%d: special symbol: >\n",lineno); break;
    case GE: fprintf(listing, "%d: special symbol: >=\n", lineno); break;
    case EQ: fprintf(listing,"%d: special symbol: ==\n",lineno); break;
    case NQ: fprintf(listing,"%d: special symbol: !=\n",lineno); break;
    case AND: fprintf(listing,"%d: special symbol: &&\n",lineno); break;
    case OR: fprintf(listing,"%d: special symbol: ||\n",lineno); break;
    case COMMA: fprintf(listing,"%d: special symbol: ,\n",lineno); break;
    case LPAREN: fprintf(listing,"%d: special symbol: (\n", lineno); break;
    case RPAREN: fprintf(listing,"%d: special symbl: )\n",lineno); break;
    case LBRACK: fprintf(listing,"%d: special symbol: [\n",lineno); break;
    case RBRACK: fprintf(listing,"%d: special symbol: ]\n", lineno); break;
    case LCBRACK: fprintf(listing,"%d: special symbol: {\n",lineno); break;
    case RCBRACK: fprintf(listing,"%d: special symbol: }\n",lineno); break;
    case SEMI: fprintf(listing,"%d: special symbol: ;\n",lineno); break;
    case PLUS: fprintf(listing,"%d: special symbol: +\n",lineno); break;
    case MINUS: fprintf(listing,"%d: special symbol: -\n",lineno); break;
    case TIMES: fprintf(listing,"%d: special symbol: *\n",lineno); break;
    case OVER: fprintf(listing,"%d: special symbol: /\n",lineno); break;
    case ENDFILE: fprintf(listing,"%d: special symbol: EOF\n",lineno); break;
    case NUM:
      fprintf(listing,
          "%d: NUM, val= %s\n",lineno,tokenString);
      break;
    case ID:
      fprintf(listing,
          "%d: ID, name= %s\n",lineno,tokenString);
      break;
    case ERROR:
      fprintf(listing,
          "%d: ERROR: %s\n",lineno,tokenString);
      break;
    default: /* should never happen */
      fprintf(listing,"%d: Unknown token: %d\n",lineno,token);
  }
}

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = StmtK;
    t->kind.stmt = kind;
    t->lineno = lineno;
    //fprintf(listing,"nodekind:%d\n",kind);
  }
  return t;
}

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = ExpK;
    t->kind.exp = kind;
    t->lineno = lineno;
    t->type = Void;
  }
  return t;
}

/* Function newDecNode creates a new declaration
 * node for syntax tree construction
 */
TreeNode * newDecNode(DecKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = DecK;
    t->kind.dec = kind;
    t->lineno = lineno;
    t->type = Void;
  }
  return t;
}

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char * copyString(char * s)
{ int n;
  char * t;
  if (s==NULL) return NULL;
  n = strlen(s)+1;
  t = malloc(n);
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else strcpy(t,s);
  return t;
}

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static int indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/* printSpaces indents by printing spaces */
static void printSpaces(void)
{ int i;
  for (i=0;i<indentno;i++)
    fprintf(listing," ");
}

/* procedure printTree prints a syntax tree to the 
 * listing file using indentation to indicate subtrees
 */
void printTree(TreeNode *tree)
{
    int i;

    INDENT;

    while (tree != NULL)  /* try not to visit null tree children */
    {
        printSpaces();

        /* Examine node type, and base output on that. */
        if (tree->nodekind == DecK)
        {
            switch(tree->kind.dec)
            {
            case VarK:
                fprintf(listing,"[Variable declaration \"%s\" of type \"%s\"]\n"
			, tree->attr.name, tree->type==Integer?"Integer":"Void");
                break;
            case ArrayK:
                fprintf(listing, "[Array declaration \"%s\" of size %d"
                        " and type \"%s\"]\n",
                      tree->attr.name, tree->value, tree->type==Integer?"Integer":"Void");
                break;
            case FunK:
                fprintf(listing, "[Function declaration \"%s()\""
                        " of return type \"%s\"]\n", 
                        tree->attr.name, tree->type==Integer?"Integer":"Void");
                break;
            default:
                fprintf(listing, "<<<unknown declaration type>>>\n");
		break;
            }
        }
        else if (tree->nodekind == ExpK)
        {
            switch(tree->kind.exp)
            {
            case OpK:
                fprintf(listing, "[Operator \"");
		printToken(tree->attr.op, "");
                //fprintf(listing, "\"]\n");
                break;
            case IdK:
                fprintf(listing, "[Identifier \"%s", tree->attr.name);
                if (tree->value != 0) /* array indexing */
                    fprintf(listing, "[%d]", tree->value);
                fprintf(listing, "\"]\n");
                break;
            case ConstK:
                fprintf(listing, "[Literal constant \"%d\"]\n", tree->attr.val);
                break;
            case AssignK:
                fprintf(listing, "[Assignment]\n");
                break;
            default:
                fprintf(listing, "<<<unknown expression type>>>\n");
                break;
            }
        }
	else if (tree->nodekind == StmtK)
	{
	    switch(tree->kind.stmt)
	    {
		case CompoundK:
		    fprintf(listing, "[Compound statement]\n");
		    break;
                case IfK:
                    fprintf(listing, "[IF statement]\n");
                    break;
                case WhileK:
                    fprintf(listing, "[WHILE statement]\n");
                    break;
                case ReturnK:
                    fprintf(listing, "[RETURN statement]\n");
                    break;
                case CallK:
                    fprintf(listing, "[Call to function \"%s() %d\"]\n",
                             tree->attr.name,(tree->child[0])!=NULL?(tree->child[0])->param_size:0);
                    break;
		default:
		    fprintf(listing, "<<<unknown statement type>>>\n");
		    break;
	    }
	}
        else
            fprintf(listing, "<<<unknown node kind>>>\n");

        for (i=0; i<MAXCHILDREN; ++i)
	{
	  //if((tree->child[i])!=NULL)
	   //{
	    //fprintf(listing,"child %d: %d\n",i,(tree->child[i])->nodekind);
	   //}
            printTree(tree->child[i]);
	}
        tree = tree->sibling;
    }

    UNINDENT;
}
