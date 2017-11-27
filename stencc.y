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

%token INT STENCIL MAIN RETURN VOID
%token IF WHILE ELSE FOR TRUE FALSE
%token CONST PRINTI PRINTF ID NUM
%token OP_PLUS OP_INC OP_MINUS OP_DEC
%token OP_STEN OP_EQUAL OP_ASSIGN OP_AND
%token OP_OR OP_NOT
%token OP_MULTI OP_DIV OP_SUP OP_INF OP_SUP_EQUAL OP_INF_EQUAL


%left OP_OR
%left OP_AND
%left OP_NOT

%%

axiom:
    programme
    {
      printf("Match !!!\n");
      return 0;
    }
  ;

programme:
    INT MAIN "(){" statement_list "}"{

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
  |
  declaration_affectation {

  }
  expression {

  }
  |
  control_structure {

  }
  | RETURN NUM ";" {

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
    |
    ID OP_ASSIGN expression ";" {

    }
    ;

declaration_affectation:
    INT ID OP_ASSIGN ID ";" {

    }
    |
    INT ID OP_ASSIGN NUM ";" {

    }
    |
    INT ID OP_ASSIGN expression ";" {

    }
    ;

expression:
    ;

control_structure:
    IF "(" ") {" statement_list "}" {

    }
    |
    WHILE "(" ") {" statement_list "}" {

    }
    |
    FOR "(" ") {" statement_list "}" {

    }
    ;

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
