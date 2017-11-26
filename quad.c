#include "quad.h"
#include "symbol.h"
#include "operator.h"


struct quad* quad_gen(enum operator op,struct symbol* result,struct symbol* arg1,struct symbol* arg2){
	static int quad_number = 0;
	struct quad* new_quad;
	new_quad = malloc(sizeof(struct quad));
	new_quad->operator = op;
	new_quad->result = result;
	new_quad->arg1 = arg1;
	new_quad->arg2 = arg2;
	new_quad = quad_number;
	quad_number++;
	return new_quad;
}

struct quad* quad_add(struct quad* quad_one,struct quad* quad_two){
	struct quad* result = NULL;
	if(quad_one != NULL){
		result = quad_one;
		while(quad_one->next != NULL){
			quad_one = quad_one->next;
		}
		quad_one->next = quad_two;
	}else if(quad_two != NULL){
		result = quad_two;
	}
	return result;
}

void quad_print(struct quad* list){
	struct symbol* result;
	struct symbol* arg1;
	struct symbol* arg2;
	while(list != NULL){	
		result = list->result;
		arg1 = list->arg1;
		arg2 = list->arg2;
		printf("%s <- ",result->identifier);
		if(arg2 != NULL){
			printf("%s %c %s\n",arg1->identifier,list->operator,arg2->identifier);
		}else{
			printf("%c %s\n",list->operator,arg1->identifier);
		}
		list = list->next;
	}
}