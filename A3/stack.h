#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>

#define STACK_MAX 100
#define STRING_SIZE 40


typedef struct{
  size_t size;
  char **data;
} STRING_STACK;

typedef struct{
  size_t size;
  int  data[STACK_MAX];
} INT_STACK;

INT_STACK si;

 STRING_STACK *init_string_stack(void);
int empty_string_stack( STRING_STACK *stack);
void push_string_stack( STRING_STACK *stack, char *name);
char *pop_string_stack( STRING_STACK *stack);
int delete_string_stack( STRING_STACK *stack);
void display_string_stack( STRING_STACK *stack);

int empty_int_stack();
void push_int_stack(int num);
int pop_int_stack();
//int delete_int_stack(INT_STACK stack);
