#ifndef _SYMBOL_H_
#define _SYMBOL_H_
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SYMBOL_MAX_STRING 42

struct symbol {
  char* identifier;
  bool isconstant;
  int value; // seulement si c'est une constante
  char* string;
  struct symbol* next;
};

struct symbol* 	symbol_alloc();
struct symbol* 	symbol_newtemp(struct symbol**);
struct symbol* 	symbol_lookup(struct symbol*, char*);
struct symbol* 	symbol_add(struct symbol**, char*);
void 			symbol_print(struct symbol*);
#endif
