#ifndef _ASSEMBLY_GENERATOR_H_
#define _ASSEMBLY_GENERATOR_H_

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"
#include "quad_list.h"
#include "quad.h"

typedef struct GotoList GotoList;
struct GotoList
{
	int index;
    GotoList *next;
};

void generator(struct symbol*, struct quad*);
void load(FILE*, struct symbol*, char*);
void addLabel(GotoList** listHead, int value);
bool isInList(GotoList** listHead, int index);
void gotoList_free(GotoList* listHead);

#endif
