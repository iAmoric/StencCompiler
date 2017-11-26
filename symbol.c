#include "symbol.h"


struct symbol* symbol_alloc(){
  struct symbol* new_symbol;
  new_symbol = malloc(sizeof(struct symbol));
  new_symbol->identifier = NULL;
  new_symbol->isconstant = false;
  new_symbol->value = 0; // seulement si c'est une constante
  new_symbol->next = NULL;
  return new_symbol;
}

struct symbol* symbol_add(struct symbol** table, char* name)
{
  if(*table == NULL){
    *table = symbol_alloc();
    (*table)->identifier = strdup(name);
    return *table;
  } else{
    struct symbol* scan = *table;
    while(scan->next != NULL)
      scan = scan->next;
    scan->next = symbol_alloc();
    scan->next->identifier = strdup(name);
    return scan->next;
  }
}

struct symbol* symbol_newtemp(struct symbol** table){
  static int temporary_number = 0; // plus propre qu'une variable globale
  char temporary_name[SYMBOL_MAX_STRING];
  snprintf(temporary_name, SYMBOL_MAX_STRING, "@temp_%d", temporary_number);
  temporary_number++;
  return symbol_add(table, temporary_name);
}

struct symbol* symbol_lookup(struct symbol* table, char* identifier)
{
  while(table != NULL)
  {
    if(strcmp(table->identifier, identifier) == 0)
      return table;
    table = table->next;
  }
  return NULL;
}

void symbol_print(struct symbol* symbol)
{
  while(symbol != NULL){
    printf("identifier: %7s, is constant:", symbol->identifier);
    if(symbol->isconstant)
      printf("true,  value: %d\n", symbol->value);
    else
      printf("false, value: N/A\n");
    symbol = symbol->next;
  }
}
