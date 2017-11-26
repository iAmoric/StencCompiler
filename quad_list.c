#include "quad_list.c"

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

struct quad_list* quad_list_complete(struct quad_list* list, struct symbol* goto_){
	struct quad_list* parcour = list;
	while(parcour != NULL){
		parcour->result = goto_;
	}
	return list;
}