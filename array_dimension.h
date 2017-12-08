#ifndef _ARRAY_DIMENSION_H_
#define _ARRAY_DIMENSION_H_
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "symbol.h"
struct array_dimension {
    struct symbol* ref;
    struct symbol* total;
    struct array_dimension* next_dimension;
    struct array_dimension* prev_dimension;
};

int	array_dimension_translate(struct array_dimension*,struct array_dimension*);

void array_dimension_total(struct array_dimension*,struct symbol**);
#endif