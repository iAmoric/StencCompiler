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

void quad_list_free(struct quad_list* list){
	struct quad_list* parcours = list;
	struct quad_list* before;
	while(parcours != NULL){
		before = parcours;
		parcours = parcours->next;
		free(before);
	}
}
