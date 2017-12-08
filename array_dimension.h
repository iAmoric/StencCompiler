#ifndef _ARRAY_DIMENSION_H_
#define _ARRAY_DIMENSION_H_
#include <stdio.h>
#include <stdlib.h>
struct array_dimension {
    int nb_element;
    int total;
    struct array_dimension* next_dimension;
};

int	array_dimension_translate(struct array_dimension*,struct array_dimension*);
#endif