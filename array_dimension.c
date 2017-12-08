#include "array_dimension.h"
int	array_dimension_translate(struct array_dimension* arg,struct array_dimension* declared){
	int translation = 0;
	/*struct array_dimension* parcours_arg = arg;
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
	}*/
	return translation;
}
 
void array_dimension_total(struct array_dimension* list,struct symbol** symbol_list){
	struct symbol* ref;
	struct array_dimension* parcours = list;
	while(parcours->next_dimension != NULL){
		parcours = parcours->next_dimension;
	}
	while(parcours != NULL){
		ref = parcours->ref;
		if(ref->isconstant == false){
			printf("ERROR: try to declare array with not constant\n");
			exit(1);
		}
		parcours->total = symbol_newtemp_init(symbol_list,ref->value);
		if(parcours->next_dimension != NULL){
			parcours->total->value *= parcours->next_dimension->total->value; 
		}
		parcours = parcours->prev_dimension;
	}
}