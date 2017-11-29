#ifndef _ASSEMBLY_GENERATOR_H_
#define _ASSEMBLY_GENERATOR_H_

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"
#include "quad_list.h"
#include "quad.h"

void generator(struct symbol*, struct quad*);

#endif
