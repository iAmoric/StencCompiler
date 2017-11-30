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
	new_quad->number =  quad_number;
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
	char* operator_string;
	while(list != NULL){
		result = list->result;
		arg1 = list->arg1;
		arg2 = list->arg2;
		printf("%s ",result->identifier);
		switch(list->operator){
			case E_RETURN:
				operator_string = "RETURN";
				break;
			case E_ASSIGN:
				operator_string = "ASSIGN";
				break;
			case E_PLUS:
				operator_string = "PLUS";
				break;
			case E_MINUS:
				operator_string = "MINUS";
				break;
			case E_MULT:
				operator_string = "MULT";
				break;
			case E_DIV:
				operator_string = "DIV";
				break;
			case E_PRINTI:
				operator_string = "PRINTI";
				break;
			case E_PRINTF:
				operator_string = "PRINTF";
				break;
			default:
				operator_string = "NOT_DEFINED";
				break;
		}
		if(arg2 != NULL && arg1 != NULL){
			printf(" <- %s %s %s\n",arg1->identifier,operator_string,arg2->identifier);
		}else if (arg1 != NULL){
			printf(" %s %s\n",operator_string,arg1->identifier);
		}else{
			printf(" %s\n",operator_string);
		}
		list = list->next;
	}
}
