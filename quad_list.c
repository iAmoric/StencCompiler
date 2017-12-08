#include "quad_list.h"

struct quad_list* quad_list_new(struct quad* quad){
	struct quad_list* new_list = malloc(sizeof(struct quad_list));
	new_list->elt = quad;
	new_list->next = NULL;
	return new_list;
}

struct quad_list* quad_list_concat(struct quad_list* a_list, struct quad_list* b_list){
	struct quad_list* parcour = a_list;
	if(parcour == NULL)return b_list;
	while(parcour->next != NULL)parcour = parcour->next;
	parcour->next = b_list;
	return a_list;
}

void quad_list_complete(struct quad_list* list, struct symbol* goto_){
	struct quad_list* parcour = list;
	while(parcour != NULL){
		parcour->elt->result = goto_;
		parcour = parcour->next;
	}
	quad_list_free(list);
}

void quad_list_array_complete(struct quad_list* to_complete,struct array_dimension* dimensions){
	dimensions = dimensions->next_dimension;
	/*int i = 0;
	while(to_complete != NULL){
		printf("%d\n",to_complete->elt->number);
		i++;
		to_complete = to_complete->next;
	}*/
	if(to_complete == NULL && dimensions == NULL)return;
	if(to_complete == NULL){
		//ERREUR le tableau a plus qu'une dimension
		printf("ERROR: array has more then 1 dimension\n");
		exit(1);
	}
	if(dimensions == NULL){
		//ERREUR le tableau est une dimension
		printf("ERROR: array has only 1 dimension\n");
		exit(1);
	}

	to_complete->elt->arg2 = dimensions->size;
	to_complete = to_complete->next;
	dimensions = dimensions->next_dimension;
	while(to_complete != NULL){
		if(dimensions == NULL){
			printf("ERROR: too much index for array\n");
			//ERREUR trop d'argument pour le tableau
			exit(1);
		}else{
			to_complete->elt->arg2 = dimensions->size;
			dimensions = dimensions->next_dimension;
		}
		to_complete = to_complete->next;
	}
	if(dimensions != NULL){
		printf("ERROR: not enough argument for array\n");
		//ERREUR pas assez d'argument pour le tableau
		exit(1);
	}

}

void quad_list_free(struct quad_list* list){
	struct quad_list* parcours = list;
	struct quad_list* before;
	while(parcours != NULL){
		before = parcours;
		parcours = parcours->next;
		free(before);
	}
}
