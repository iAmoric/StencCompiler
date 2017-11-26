#ifndef _QUAD_LIST_H_
#define _QUAD_LIST_H_
#include <stdio.h>
#include "quad.h"
#include "symbol.h"
#include <stdlib.h>

struct quad_list{
	struct quad* elt;
	struct quad_list* next;
};

struct quad_list* quad_list_new(struct quad*);

struct quad_list* quad_list_concat(struct quad_list*, struct quad_list*);

struct quad_list* quad_list_complete(struct quad_list*, struct quad_list*);

#endif