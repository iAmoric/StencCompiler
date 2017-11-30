#include "assembly_generator.h"

void generator(struct symbol* symbol, struct quad* quad) {
    FILE* file = NULL;
    file = fopen("assembly/test.s", "w");

    if (file != NULL) {
        struct symbol* result;
    	struct symbol* arg1;
    	struct symbol* arg2;

        fprintf(file, "\t.text\n");
        fprintf(file, "main:\n");

        //.text
        while(quad != NULL){
    		result = quad->result;
    		arg1 = quad->arg1;
    		arg2 = quad->arg2;
    		switch(quad->operator){
    			case E_RETURN:
    				break;
    			case E_ASSIGN:
                    fprintf(file, "# %s = %s\n", result->identifier, arg1->identifier);
                    if (arg1 != NULL && arg2 == NULL) {
                        if (arg1->identifier[0] == '_')
                            fprintf(file, "lw $t0, %s\n", arg1->identifier);
                        else
                            fprintf(file, "lw $t0, _%s\n", arg1->identifier);

                        if (result->identifier[0] == '_')
                            fprintf(file, "sw $t0, %s\n", result->identifier);
                        else
                            fprintf(file, "sw $t0, _%s\n", result->identifier);

                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
    				break;
    			case E_PLUS:
                    fprintf(file, "# %s = %s + %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    if (arg1 != NULL && arg2 != NULL) {
                        if (arg1->identifier[0] == '_')
                            fprintf(file, "lw $t0, %s\n", arg1->identifier);
                        else
                            fprintf(file, "lw $t0, _%s\n", arg1->identifier);

                        if (arg2->identifier[0] == '_')
                            fprintf(file, "lw $t1, %s\n", arg2->identifier);
                        else
                            fprintf(file, "lw $t1, _%s\n", arg2->identifier);

                        fprintf(file, "add $t0, $t0, $t1\n");

                        if (result->identifier[0] == '_')
                            fprintf(file, "sw $t0, %s\n", result->identifier);
                        else
                            fprintf(file, "sw $t0, _%s\n", result->identifier);

                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
                    break;
    			case E_MINUS:
                    fprintf(file, "# %s = %s - %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    if (arg1 != NULL && arg2 != NULL) {
                        if (arg1->identifier[0] == '_')
                            fprintf(file, "lw $t0, %s\n", arg1->identifier);
                        else
                            fprintf(file, "lw $t0, _%s\n", arg1->identifier);

                        if (arg2->identifier[0] == '_')
                            fprintf(file, "lw $t1, %s\n", arg2->identifier);
                        else
                            fprintf(file, "lw $t1, _%s\n", arg2->identifier);

                        fprintf(file, "sub $t0, $t0, $t1\n");

                        if (result->identifier[0] == '_')
                            fprintf(file, "sw $t0, %s\n", result->identifier);
                        else
                            fprintf(file, "sw $t0, _%s\n", result->identifier);

                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
    				break;
    			case E_MULT:
                    fprintf(file, "# %s = %s * %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    if (arg1 != NULL && arg2 != NULL) {
                        if (arg1->identifier[0] == '_')
                            fprintf(file, "lw $t0, %s\n", arg1->identifier);
                        else
                            fprintf(file, "lw $t0, _%s\n", arg1->identifier);

                        if (arg2->identifier[0] == '_')
                            fprintf(file, "lw $t1, %s\n", arg2->identifier);
                        else
                            fprintf(file, "lw $t1, _%s\n", arg2->identifier);

                        fprintf(file, "mul $t0, $t0, $t1\n");

                        if (result->identifier[0] == '_')
                            fprintf(file, "sw $t0, %s\n", result->identifier);
                        else
                            fprintf(file, "sw $t0, _%s\n", result->identifier);

                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
    				break;
    			case E_DIV:
                    fprintf(file, "# %s = %s / %s\n", result->identifier, arg1->identifier, arg2->identifier);
                    if (arg1 != NULL && arg2 != NULL) {
                        if (arg1->identifier[0] == '_')
                            fprintf(file, "lw $t0, %s\n", arg1->identifier);
                        else
                            fprintf(file, "lw $t0, _%s\n", arg1->identifier);

                        if (arg2->identifier[0] == '_')
                            fprintf(file, "lw $t1, %s\n", arg2->identifier);
                        else
                            fprintf(file, "lw $t1, _%s\n", arg2->identifier);

                        fprintf(file, "div $t0, $t0, $t1\n");

                        if (result->identifier[0] == '_')
                            fprintf(file, "sw $t0, %s\n", result->identifier);
                        else
                            fprintf(file, "sw $t0, _%s\n", result->identifier);

                        fprintf(file, "\n");
                    }
                    else {
                        fprintf(stderr, "Error quad\n");
                        exit(1);
                    }
                    break;
                case E_PRINTI:
                    fprintf(file, "print %s\n", result->identifier);
                    fprintf(file, "li $v0,1\n");

                    if (result->identifier[0] == '_')
                        fprintf(file, "lw $a0, %s\n", result->identifier);
                    else
                        fprintf(file, "lw $a0, _%s\n", result->identifier);

                    fprintf(file, "syscall\n");
                    break;
    			default:
    				break;
    		}
            quad = quad->next;
    	}


        fprintf(file, "# exit\n");
        fprintf(file, "li $v0,10\n");
        fprintf(file, "syscall\n");
        //.data
        fprintf(file, "\n");
        fprintf(file, "\t.data\n");
        while (symbol != NULL) {
            if (symbol->identifier[0] == '_')
                fprintf(file, "%s: .word ", symbol->identifier);
            else
                fprintf(file, "_%s: .word ", symbol->identifier);

            if (symbol->isconstant)
                fprintf(file, "%d\n", symbol->value);
            else
                fprintf(file, "0\n");
            symbol = symbol->next;
        }
    }
}
