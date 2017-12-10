#include "assembly_generator.h"

void generator(struct symbol* symbol_list, struct quad* quad) {

    FILE* file = NULL;
    file = fopen("out.s", "w");

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

            //savoir si on doit ajouter un label
            if (isInList(&listHead, index) || quad->need_label){
                fprintf(file, "\tlabel%d:\n", index);
            }

    		switch(quad->operator) {

    			case E_ASSIGN:
                    //result = arg1
                    fprintf(file, "\t\t# %s = %s\n", result->identifier, arg1->identifier);
                    load(file, arg1, "t0");
                    fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
    				break;

    			case E_PLUS:
                    //si tableau :
                    //  result = arg1 + adresse tableau ou result = adresse tableau + arg2
                    //sinon :
                    //  result = arg1 + arg2
                    if (arg2->is_array)
                        fprintf(file, "\t\t# %s = %s + @%s\n", result->identifier, arg1->identifier, arg2->identifier);
                    else if (arg1->is_array)
                        fprintf(file, "\t\t# %s = @%s + %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    else
                        fprintf(file, "\t\t# %s = %s + %s\n", result->identifier, arg1->identifier, arg2->identifier);

                    if (arg1->is_array)
                        fprintf(file, "\t\tla $t0, _%s\n", arg1->identifier);
                    else
                        load(file, arg1, "t0");

                    if (arg2->is_array)
                        fprintf(file, "\t\tla $t1, _%s\n", arg2->identifier);
                    else
                        load(file, arg2, "t1");

                    fprintf(file, "\t\tadd $t0, $t0, $t1\n");
                    fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
                    break;

    			case E_MINUS:
                    //result = arg1 - arg2
                    fprintf(file, "\t\t# %s = %s - %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    load(file, arg1, "t0");
                    load(file, arg2, "t1");
                    fprintf(file, "\t\tsub $t0, $t0, $t1\n");
                    fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
    				break;

    			case E_MULT:
                    //result = arg1 * arg2
                    fprintf(file, "\t\t# %s = %s * %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    load(file, arg1, "t0");
                    load(file, arg2, "t1");
                    fprintf(file, "\t\tmul $t0, $t0, $t1\n");
                    fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
    				break;

    			case E_DIV:
                    //result = arg1 / arg2
                    fprintf(file, "\t\t# %s = %s / %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    load(file, arg1, "t0");
                    load(file, arg2, "t1");
                    fprintf(file, "\t\tdiv $t0, $t0, $t1\n");
                    fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
                    break;

                case E_PRINTI:
                    //printi(result)
                    fprintf(file, "\t\t# printi %s\n", result->identifier);
                    fprintf(file, "\t\tli $v0, 1\n");
                    load(file, result, "a0");
                    fprintf(file, "\t\tsyscall\n");
                    break;

                case E_PRINTF:
                    //printf(result)
                    fprintf(file, "\t\t# printf %s\n", result->identifier);
                    fprintf(file, "\t\tli $v0, 4\n");
                    fprintf(file, "\t\tla $a0, _%s\n", result->identifier);
                    fprintf(file, "\t\tsyscall\n");
                    break;

                case E_EQUAL:
                    //goto result si arg1 == arg2
                    //ajoute le label à la liste si il est supérieur au quad actuel
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s == %s\n", result->value, arg1->identifier, arg2->identifier);
                    load(file, arg1, "t0");
                    load(file, arg2, "t1");
                    fprintf(file, "\t\tbeq $t0, $t1, label%d\n",result->value);
                    break;

                case E_DIFFERENT:
                    //goto result si arg1 != arg2
                    //ajoute le label à la liste si il est supérieur au quad actuel
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s != %s\n", result->value, arg1->identifier, arg2->identifier);
                    load(file, arg1, "t0");
                    load(file, arg2, "t1");
                    fprintf(file, "\t\tbne $t0, $t1, label%d\n",result->value);
                    break;

                case E_INFEQUAL:
                    //goto result si arg1 <= arg2
                    //ajoute le label à la liste si il est supérieur au quad actuel
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s <= %s\n", result->value, arg1->identifier, arg2->identifier);
                    load(file, arg1, "t0");
                    load(file, arg2, "t1");
                    fprintf(file, "\t\tble $t0, $t1, label%d\n",result->value);
                    break;

                case E_SUPEQUAL:
                    //goto result si arg1 >= arg2
                    //ajoute le label à la liste si il est supérieur au quad actuel
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s >= %s\n", result->value, arg1->identifier, arg2->identifier);
                    load(file, arg1, "t0");
                    load(file, arg2, "t1");
                    fprintf(file, "\t\tbge $t0, $t1, label%d\n",result->value);
                    break;

                case E_SUPERIOR:
                    //goto result si arg1 > arg2
                    //ajoute le label à la liste si il est supérieur au quad actuel
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s > %s\n", result->value, arg1->identifier, arg2->identifier);
                    load(file, arg1, "t0");
                    load(file, arg2, "t1");
                    fprintf(file, "\t\tbgt $t0, $t1, label%d\n",result->value);
                    break;

                case E_INFERIOR:
                    //goto result si arg1 < arg2
                    //ajoute le label à la liste si il est supérieur au quad actuel
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d if %s < %s\n", result->value, arg1->identifier, arg2->identifier);
                    load(file, arg1, "t0");
                    load(file, arg2, "t1");
                    fprintf(file, "\t\tblt $t0, $t1, label%d\n",result->value);
                    break;

                case E_GOTO:
                    //goto result
                    //ajoute le label à la liste si il est supérieur au quad actuel
                    gotoLabel = symbol_lookup(symbol_list, result->identifier);
                    if (gotoLabel->value > index) {
                        addLabel(&listHead, gotoLabel->value);
                    }
                    fprintf(file, "\t\t# goto label%d\n", result->value);
                    fprintf(file, "\t\tj label%d\n", result->value);
                    break;

                case E_TAB_LOAD:
                    //charge une valeur d'une case d'un tableau
                    //arg1 est l'adresse, result est la valeur contenu à l'adresse arg1
                    fprintf(file, "\t\t#lire %s et stocker dans %s\n", arg1->identifier, result->identifier);
                    load(file, arg1, "t0");
                    fprintf(file, "\t\tlw $t0, ($t0)\n");
                    fprintf(file, "\t\tsw $t0, _%s\n", result->identifier);
                    break;

                case E_TAB_WRITE:
                    //ecrit dans une case du tableau
                    //arg1 est l'adresse, result est la valeur a écrire dans la case à l'adresse arg1
                    fprintf(file, "\t\t# ecrire %s à l'adresse %s\n",  result->identifier, arg1->identifier);
                    load(file, result, "t0");
                    fprintf(file, "\t\tlw $t1, _%s\n", arg1->identifier);
                    fprintf(file, "\t\tsw $t0, ($t1)\n");
                    break;
    			default:
    				break;
    		}
            fprintf(file, "\n");
            quad = quad->next;
    	}

        //quitte proprement le programme
        fprintf(file, "\t\t# exit\n");
        fprintf(file, "\t\tli $v0, 10\n");
        fprintf(file, "\t\tsyscall\n");

        //.data
        fprintf(file, "\n");
        fprintf(file, ".data\n");


        struct symbol* symbol_tmp;
        symbol_tmp = symbol_list;
        //ajoute d'abord les tableau en haut du .data
        while (symbol_tmp != NULL) {
            if (symbol_tmp->is_array) {
                fprintf(file, "\t_%s: .space %d\n", symbol_tmp->identifier, symbol_tmp->value);
            }
            symbol_tmp = symbol_tmp->next;
        }

        symbol_tmp = symbol_list;
        while (symbol_tmp != NULL) {
            if (symbol_tmp->is_array == false) {
                //ajoute seulement les temp qui sont pas des constantes
                if (symbol_tmp->isconstant) {
                    if (symbol_tmp->string != NULL)
                        fprintf(file, "\t_%s: .asciiz %s\n", symbol_tmp->identifier, symbol_tmp->string);
                    else if (symbol_tmp->value == 0)    //ajoute quand même si la valeur est à 0
                        fprintf(file, "\t_%s: .word %d\n", symbol_tmp->identifier, symbol_tmp->value);
                }
                else
                    fprintf(file, "\t_%s: .word 0\n", symbol_tmp->identifier);
            }

            symbol_tmp = symbol_tmp->next;
        }

        fclose(file);
        gotoList_free(listHead);
    }
    else {
        fprintf(stderr, "unable to generate the assembly file out.s\n");
    }
}

//ecrit dans le fichier le code pour charger les valeur en assembleur
void load(FILE* file, struct symbol* arg, char* rdest){
    if (arg->isconstant)
        fprintf(file, "\t\tli $%s, %d\n", rdest, arg->value);
    else
        fprintf(file, "\t\tlw $%s, _%s\n", rdest, arg->identifier);

    return;
}



//ajoute un label dans la liste des labels
void addLabel(GotoList** listHead, int value) {
    //liste encore vide -> ajoute en tete
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

//cherche un label dans la liste des labels, renvoie vrai si il est trouvé, sinon renvoie faut
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


//free la liste des labels
void gotoList_free(GotoList* listHead){
    GotoList* gotoLabel = listHead;
    GotoList* prev;
    while(gotoLabel != NULL){
        prev = gotoLabel;
        gotoLabel = gotoLabel->next;
        free(prev);
    }
}
