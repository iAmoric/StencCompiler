#include "assembly_generator.h"

void generator(struct symbol* symbol_list, struct quad* quad) {
    FILE* file = NULL;
    file = fopen("assembly/out.s", "w");

    if (file != NULL) {
        struct symbol* result;
    	struct symbol* arg1;
    	struct symbol* arg2;
        struct symbol* gotoLabel;

        GotoList* listHead = NULL;

        fprintf(file, ".text\n");
        fprintf(file, "main:\n");

        //.text
        while(quad != NULL){
    		result = quad->result;
    		arg1 = quad->arg1;
    		arg2 = quad->arg2;
            int index = quad->number;
            if (isInList(&listHead, index) || quad->need_label){
                fprintf(file, "\tlabel%d:\n", index);
            }

    		switch(quad->operator){
    			case E_ASSIGN:
                    fprintf(file, "\t\t# %s = %s\n", result->identifier, arg1->identifier);
                    if (arg1 != NULL && arg2 == NULL) {
                        fprintf(file, "\t\tlw $t0, _%s\n", arg1->identifier);
                        fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
    				break;
    			case E_PLUS:
                    if (arg2->is_array){
                        fprintf(file, "\t\t# %s = %s + @%s\n", result->identifier, arg1->identifier, arg2->identifier);
                    }
                    else {
                        fprintf(file, "\t\t# %s = %s + %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    }
                    if (arg1 != NULL && arg2 != NULL) {
                        fprintf(file, "\t\tlw $t0, _%s\n", arg1->identifier);
                        if (arg2->is_array){
                            fprintf(file, "\t\tla $t1, _%s\n", arg2->identifier);
                        }
                        else {
                            fprintf(file, "\t\tlw $t1, _%s\n", arg2->identifier);
                        }
                        fprintf(file, "\t\tadd $t0, $t0, $t1\n");
                        fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
                    break;
    			case E_MINUS:
                    fprintf(file, "\t\t# %s = %s - %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    if (arg1 != NULL && arg2 != NULL) {
                        fprintf(file, "\t\tlw $t0, _%s\n", arg1->identifier);
                        fprintf(file, "\t\tlw $t1, _%s\n", arg2->identifier);
                        fprintf(file, "\t\tsub $t0, $t0, $t1\n");
                        fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
    				break;
    			case E_MULT:
                    fprintf(file, "\t\t# %s = %s * %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    if (arg1 != NULL && arg2 != NULL) {
                        fprintf(file, "\t\tlw $t0, _%s\n", arg1->identifier);
                        fprintf(file, "\t\tlw $t1, _%s\n", arg2->identifier);
                        fprintf(file, "\t\tmul $t0, $t0, $t1\n");
                        fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
    				break;
    			case E_DIV:
                    fprintf(file, "\t\t# %s = %s / %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    if (arg1 != NULL && arg2 != NULL) {
                        fprintf(file, "\t\tlw $t0, _%s\n", arg1->identifier);
                        fprintf(file, "\t\tlw $t1, _%s\n", arg2->identifier);
                        fprintf(file, "\t\tdiv $t0, $t0, $t1\n");
                        fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
                    break;
                case E_PRINTI:
                    fprintf(file, "\t\t# printi %s\n", result->identifier);
                    fprintf(file, "\t\tli $v0, 1\n");
                    fprintf(file, "\t\tlw $a0, _%s\n", result->identifier);
                    fprintf(file, "\t\tsyscall\n");
                    fprintf(file, "\n");
                    break;
                case E_PRINTF:
                    fprintf(file, "\t\t# printf %s\n", result->identifier);
                    fprintf(file, "\t\tli $v0, 4\n");
                    fprintf(file, "\t\tla $a0, _%s\n", result->identifier);
                    fprintf(file, "\t\tsyscall\n");
                    fprintf(file, "\n");
                    break;
                case E_EQUAL:
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s == %s\n", result->value, arg1->identifier, arg2->identifier);
                    fprintf(file, "\t\tlw $t0 _%s\n", arg1->identifier);
                    fprintf(file, "\t\tlw $t1 _%s\n", arg2->identifier);
                    fprintf(file, "\t\tbeq $t0, $t1, label%d\n",result->value);
                    fprintf(file, "\n");
                    break;
                case E_DIFFERENT:
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s != %s\n", result->value, arg1->identifier, arg2->identifier);
                    fprintf(file, "\t\tlw $t0 _%s\n", arg1->identifier);
                    fprintf(file, "\t\tlw $t1 _%s\n", arg2->identifier);
                    fprintf(file, "\t\tbne $t0, $t1, label%d\n",result->value);
                    fprintf(file, "\n");
                    break;
                case E_INFEQUAL:
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s <= %s\n", result->value, arg1->identifier, arg2->identifier);
                    fprintf(file, "\t\tlw $t0 _%s\n", arg1->identifier);
                    fprintf(file, "\t\tlw $t1 _%s\n", arg2->identifier);
                    fprintf(file, "\t\tble $t0, $t1, label%d\n",result->value);
                    fprintf(file, "\n");
                    break;
                case E_SUPEQUAL:
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s >= %s\n", result->value, arg1->identifier, arg2->identifier);
                    fprintf(file, "\t\tlw $t0 _%s\n", arg1->identifier);
                    fprintf(file, "\t\tlw $t1 _%s\n", arg2->identifier);
                    fprintf(file, "\t\tbge $t0, $t1, label%d\n",result->value);
                    fprintf(file, "\n");
                    break;
                case E_SUPERIOR:
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s > %s\n", result->value, arg1->identifier, arg2->identifier);
                    fprintf(file, "\t\tlw $t0 _%s\n", arg1->identifier);
                    fprintf(file, "\t\tlw $t1 _%s\n", arg2->identifier);
                    fprintf(file, "\t\tbgt $t0, $t1, label%d\n",result->value);
                    fprintf(file, "\n");
                    break;
                case E_INFERIOR:
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s < %s\n", result->value, arg1->identifier, arg2->identifier);
                    fprintf(file, "\t\tlw $t0 _%s\n", arg1->identifier);
                    fprintf(file, "\t\tlw $t1 _%s\n", arg2->identifier);
                    fprintf(file, "\t\tblt $t0, $t1, label%d\n",result->value);
                    fprintf(file, "\n");
                    break;
                case E_GOTO:
                    //add goto label in list
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d\n", result->value);
                    fprintf(file, "\t\tj label%d\n", result->value);
                    fprintf(file, "\n");
                    break;
                case E_TAB:
                    fprintf(file, "\t\t# valeur à l'adresse %s\n", arg1->identifier);
                    if (arg1 != NULL && arg2 == NULL) {
                        fprintf(file, "\t\tlw $t0, _%s\n", arg1->identifier);
                        fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
                    break;
    			default:
    				break;
    		}
            quad = quad->next;
    	}

        fprintf(file, "\t\t# exit\n");
        fprintf(file, "\t\tli $v0,10\n");
        fprintf(file, "\t\tsyscall\n");

        //.data
        fprintf(file, "\n");
        fprintf(file, ".data\n");
        while (symbol_list != NULL) {
            fprintf(file, "\t_%s: ", symbol_list->identifier);

            if (symbol_list->is_array) {
                fprintf(file, ".space %d\n", symbol_list->value);
            }
            else if (symbol_list->isconstant) {
                if (symbol_list->string == NULL)
                    fprintf(file, ".word %d\n", symbol_list->value);
                else
                    fprintf(file, ".asciiz %s\n", symbol_list->string);
            }
            else
                fprintf(file, ".word 0\n");

            symbol_list = symbol_list->next;
        }

        fclose(file);
        gotoList_free(listHead);
    }
}

void addLabel(GotoList** listHead, int value) {
    if (*listHead == NULL) {
        GotoList* gotoLabel = malloc(sizeof(GotoList));
        gotoLabel->index = value;
        gotoLabel->next = NULL;
        *listHead = gotoLabel;
    }
    else {
        GotoList* gotoLabel = *listHead;
        GotoList* newLabel = malloc(sizeof(GotoList));
        newLabel->next = NULL;
        newLabel->index = value;
        while (gotoLabel->next != NULL) {
            gotoLabel = gotoLabel->next;
        }
        gotoLabel->next = newLabel;
    }
}

bool isInList(GotoList** listHead, int index) {
    GotoList* gotoLabel = *listHead;
    while (gotoLabel != NULL) {
        if (gotoLabel->index == index) {
            return true;
        }
        gotoLabel = gotoLabel->next;
    }
    return false;
}


void gotoList_free(GotoList* listHead){
    GotoList* gotoLabel = listHead;
    GotoList* prev;
    while(gotoLabel != NULL){
        prev = gotoLabel;
        gotoLabel = gotoLabel->next;
        free(prev);
    }
}
