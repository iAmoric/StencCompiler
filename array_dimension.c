#include "array_dimension.h"
int	array_dimension_translate(struct array_dimension* arg,struct array_dimension* declared){
	int translation = 0;
	struct array_dimension* parcours_arg = arg;
	struct array_dimension* parcours_declared = declared;
	translation = arg->nb_element;
	if(translation >= parcours_declared->nb_element || translation < 0 ){
		printf("ERROR: invalid array size\n");
		exit(1);
	}
	parcours_arg = parcours_arg->next_dimension;
	parcours_declared = parcours_declared->next_dimension;
	while (parcours_arg != NULL){
		translation = translation + parcours_declared->total * parcours_arg->nb_element;
		if(parcours_arg->nb_element >= parcours_declared->nb_element || translation < 0 ){
			printf("ERROR: invalid array size\n");
			exit(1);
		}
		parcours_arg = parcours_arg->next_dimension;
		parcours_declared = parcours_declared->next_dimension;
	};
	if(parcours_declared != NULL){
		printf("ERROR: invalid numbers of arguments for array\n");
		exit(1);
	}
	return translation + 1;
}