#ifndef _SYMBOL_H_
#define _SYMBOL_H_
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "array_dimension.h"
#define SYMBOL_MAX_STRING 42

struct symbol {
  char* identifier;
  bool isconstant;
  bool is_initialised;
  bool is_define;
  bool is_array;
  bool is_copy;
  int value; // seulement si c'est une constante
  char* string; //pour le print
  struct array_dimension* array_dimension;//pour les tableaux
  struct symbol* next;
};



struct symbol* 	symbol_alloc();
struct symbol* 	symbol_newtemp(struct symbol**);
struct symbol* 	symbol_newtemp_init(struct symbol**,int);
struct symbol* 	symbol_lookup(struct symbol*, char*);
struct symbol* 	symbol_add(struct symbol**, char*);
struct symbol*	symbol_get(struct symbol*,int);
struct symbol*	symbol_create_copy(struct symbol**,struct symbol*);
void 			symbol_print(struct symbol*);
void 			symbol_free(struct symbol*);


#endif
