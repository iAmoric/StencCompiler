#include "assembly_generator.h"

void generator(struct symbol* symbol, struct quad* quad) {
    FILE* file = NULL;
    file = fopen("assembly/test.s", "w");

    if (file != NULL) {
        fprintf(file, "\t.text\n");
        fprintf(file, "main:\n");
        //.text


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
