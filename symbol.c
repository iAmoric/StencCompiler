#include "symbol.h"


struct symbol* symbol_alloc(){
    struct symbol* new_symbol;
    new_symbol = malloc(sizeof(struct symbol));
    new_symbol->identifier = NULL;
    new_symbol->isconstant = false;
    new_symbol->is_initialised = false;
    new_symbol->is_array = false;
    new_symbol->is_copy = false;
    new_symbol->is_never_used = false;
    new_symbol->value = 0; // seulement si c'est une constante
    new_symbol->string = NULL;
    new_symbol->next = NULL;
    return new_symbol;
}

struct symbol* symbol_add(struct symbol** table, char* name)
{
    if(*table == NULL){
        *table = symbol_alloc();
        (*table)->identifier = strdup(name);
        (*table)->is_initialised = false;
        //(*table)->identifier = name;
        return *table;
    } else{
        struct symbol* scan = *table;
        while(scan->next != NULL)
            scan = scan->next;
        scan->next = symbol_alloc();
        scan->next->identifier = strdup(name);
        scan->next->is_initialised = false;
        //scan->next->identifier = na;
        return scan->next;
    }
}

struct symbol* symbol_newtemp(struct symbol** table){
    static int temporary_number = 0; // plus propre qu'une variable globale
    char temporary_name[SYMBOL_MAX_STRING];
    snprintf(temporary_name, SYMBOL_MAX_STRING, "_temp_%d", temporary_number);
    temporary_number++;
    return symbol_add(table, temporary_name);
}


struct symbol*  symbol_newtemp_init(struct symbol** table,int num){
  struct symbol* temp = symbol_newtemp(table);
  temp->isconstant = true;
  temp->is_initialised = true;
  temp->value = num;
  return temp;
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
        if(symbol->isconstant) {
            if (symbol->string == NULL)
                printf("true,  value: %d", symbol->value);
            else
                printf("true,  value: %s", symbol->string);
        }
        else{
            printf("false, value: N/A");
        }
        if(symbol->is_array == true){
            printf(" est un tableau de %d octets",symbol->value);
        }
        printf("\n");
        symbol = symbol->next;
    }
}

void symbol_free(struct symbol* list){
    struct symbol* parcours = list;
    struct symbol* before;
    struct array_dimension* parcours_dimension;
    struct array_dimension* before_dimension;
    while(parcours != NULL){
        before = parcours;
        parcours = parcours->next;
        free(before->identifier);
        if(before->string != NULL){
            free(before->string);
        }
        if(before->array_dimension != NULL){
            parcours_dimension = before->array_dimension;
            while(parcours_dimension != NULL){
                before_dimension = parcours_dimension;
                parcours_dimension = parcours_dimension->next_dimension;
                free(before_dimension);

            }
        }
        free(before);
    }
}
