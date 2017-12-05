#ifndef _ASSEMBLY_GENERATOR_H_
#define _ASSEMBLY_GENERATOR_H_

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"
#include "quad_list.h"
#include "quad.h"

typedef struct Goto Goto;
struct Goto
{
	int index;
    Goto *next;
};

typedef struct GotoList GotoList;
struct GotoList
{
    Goto *first;
};

void generator(struct symbol*, struct quad*);
void addLabel(GotoList* gotoList, int value);
bool isInList(GotoList* gotoList, int index);

#endif
