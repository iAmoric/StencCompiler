#ifndef _QUAD_H_
#define _QUAD_H_
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "operator.h"
struct quad{
	enum operator operator;
	int number;
	bool need_label;
	struct symbol* result;
	struct symbol* arg1;
	struct symbol* arg2;
	struct quad* next;
};

struct quad* quad_gen(enum operator,struct symbol*,struct symbol*,struct symbol*);

struct quad* quad_add(struct quad*,struct quad*);

struct quad* quad_last(struct quad*);

void quad_print(struct quad*);

void quad_free(struct quad*);
#endif
