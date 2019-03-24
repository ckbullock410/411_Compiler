#include "stack.h"



 STRING_STACK *init_string_stack (void) {
   STRING_STACK *stack = malloc(sizeof(STRING_STACK));
  stack->data = malloc(sizeof(char *) * STACK_MAX);
  for (int i = 0; i < STACK_MAX; i++) {
    *(stack->data + i) = malloc(STRING_SIZE * sizeof(char));
  }   
  stack->size = 0;
  if (stack == NULL) {
    perror("malloc failed\n");
    return NULL;
  }
  return stack;
}

void display_string_stack(STRING_STACK *stack){
      if(stack->size != 0){	
	for (int i=0;i<stack->size;i++){
		printf("Stack element %d: %s\n",i,(stack->data)[i]);
	}
      }

}

int empty_string_stack( STRING_STACK *stack) {
  return (stack->size == 0);
}

int empty_int_stack(INT_STACK stack) {
  return (si.size == 0);
}

void push_string_stack( STRING_STACK *stack, char *name) {
  if (stack->size == STACK_MAX) {
    perror("Stack is full\n");
    exit(0);
  }
  else {
    //printf("pushing %s into stack\n",name);
    strcpy((stack->data)[stack->size++], name);
    //printf("read data from stack:%s\n",(stack->data)[stack->size-1]);
  }
}

void push_int_stack(int num) {
  if (si.size == STACK_MAX) {
    perror("Stack is full\n");
    exit(0);
  }
  else {
    //printf("pushing %d into stack\n",num);
    //printf("stack size:%ld\n",si.size);
    si.data[si.size] = num;
    si.size = si.size + 1;
    //printf("data inserted into  stack:%d\n",si.data[si.size-1]);
    //printf("stack size:%ld\n",si.size);
  }
}


char *pop_string_stack( STRING_STACK *stack) {
  if (stack->size == 0) {
    printf("size == 0\n");
    return NULL;
  }
  else {
    char * st;
    //printf("poping from stack\n");
    //printf("stack size:%ld\n",stack->size);
    //printf("read data before poping: %s \n", (stack->data)[stack->size-1]);
    stack->size = stack->size - 1;
    //printf("stack size:%ld\n",stack->size);
    //strncpy(st,(stack->data)[stack->size],STRING_SIZE);
    //printf("read data after poping: %s \n",st);
    //stack->size -= 1;
    
    return (stack->data)[stack->size];
  }
}

int pop_int_stack() {
  if (si.size == 0) {
    printf("size = 0\n");
    return 0;
  }
  else {
    
    //printf("poping from stack\n");
    //printf("stack size:%ld\n",si.size);
    //printf("read data before poping: %d \n", (si.data)[si.size-1]);
    si.size = si.size - 1;
    //printf("stack size:%ld\n",si.size);
    //strncpy(st,(stack.data)[stack.size],STRING_SIZE);
    //printf("read data after poping: %s \n",st);
    //stack.size -= 1;
    
    return (si.data)[si.size];
  }
}

int delete_string_stack( STRING_STACK *stack) {
  for (int i = 0; i < STACK_MAX; i++) {
    free(*(stack->data + i));
  }   
  free(stack->data);
  free(stack);   
}

//int delete_int_stack(INT_STACK stack) {
  //for (int i = 0; i < STACK_MAX; i++) {
    //free(*(stack.data + i));
  //}   
  //free(stack.data);
  //free(stack);   
//}


/*
int main()
{
   STRING_STACK * S = init_string_stack();
  //INT_STACK si;
  si.size = 0;
  //printf("size of stack:%ld\n",sizeof(*(S->data)));
  push_string_stack(S,"hello");
  char * st;
  st= pop_string_stack(S);
  printf("pop up string: %s\n",st);
  //printf("stack size:%ld\n",S->size);
  push_string_stack(S,"bye");
  
  push_string_stack(S,"fatemeh");
  st= pop_string_stack(S);
  printf("pop up string: %s\n",st);

  st= pop_string_stack(S);
  printf("pop up string: %s\n",st);
  
  delete_string_stack(S);

  int out;
  //printf("initiated new stack\n");
  push_int_stack(10);
  //printf("stack size:%ld\n",si.size);
  out = pop_int_stack();
  printf("pop up number: %d\n",out);
  
  push_int_stack(23);
  push_int_stack(100);
  
  out = pop_int_stack();
  printf("pop up number: %d\n",out);

  out = pop_int_stack();
  printf("pop up number: %d\n",out);
  //delete_int_stack(si);

  return 0;
}
*/
