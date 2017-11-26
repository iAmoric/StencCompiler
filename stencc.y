%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "symbol.h"
  #include "quad.h"
  #include "quad_list.h"

  void yyerror(char*);
  int yylex();
  void lex_free();
%}
%union {
  char* string;
  int value;
  struct {
    struct symbol* result;
    struct quad* code;
    struct quad_list* true_list;
    struct quad_list* false_list;
  }codegen;
}



%left OR
%left AND
%left NOT

%%

axiom:
    programme
    {
      printf("Match !!!\n");
      return 0;
    }
  ;

programme:
    INT MAIN "{" statement_list RETURN NUM"}"{

    }
  ;

statement_list:
  statement statement_list {


  }
  | 
  statement {

  }
  ;

statement:
  declaration {

  }
  |
  affectation {

  }
  ;

declaration:
   INT ID ";" {

   }
  ;
affectation:
    ID OP_ASSIGN ID ";" {

    }
    |
    ID OP_ASSIGN NUM ";" {

    }
%%

void yyerror (char *s) {
    fprintf(stderr, "[Yacc] error: %s\n", s);
}

int main() {
  printf("Enter your code:\n");
  yyparse();
  printf("-----------------\nSymbol table:\n");
  printf("-----------------\nQuad list:\n");

  // Be clean.
  lex_free();
  return 0;
}