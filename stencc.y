%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "symbol.h"
  #include "quad.h"
  #include "quad_list.h"

  void yyerror(char*);
  int yylex();
  void lex_free();

  FILE *yyin;
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
%type <codegen> expression
%token <string> ID
%token <value> NUM
%token INT STENCIL MAIN RETURN VOID
%token IF WHILE ELSE FOR TRUE FALSE
%token CONST PRINTI PRINTF
%token OP_PLUS OP_INC OP_MINUS OP_DEC
%token OP_STEN OP_EQUAL OP_ASSIGN OP_AND
%token OP_OR OP_NOT
%token OP_MULTI OP_DIV OP_SUP OP_INF OP_SUP_EQUAL OP_INF_EQUAL


%left OP_OR
%left OP_AND
%left OP_NOT
%left OP_PLUS
%left OP_MINUS
%left OP_MULTI
%left OP_DIV


%%

axiom:
    programme
    {
      printf("Match !!!\n");
      return 0;
    }
  ;

programme:
    INT MAIN '(' ')' '{' statement_list '}'{

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
  declaration ';' {
    printf("statement: declaration\n");
  }
  |
  affectation ';' {
    printf("statement: affecratsion\n");
  }
  |
  declaration_affectation ';'{
    printf("statement: declare affect\n");
  }
  expression ';' {
    printf("statement: expr\n");
  }
  |
  control_structure {
     printf("statement: control structure\n");
  }
  | RETURN NUM ';' {
     printf("statement: return\n");
  }
  ;

declaration:
   INT ID {

   }
   |
   CONST INT ID {

   }
  ;

affectation:
    ID OP_ASSIGN expression {

    }
    ;

declaration_affectation:
    INT ID OP_ASSIGN expression {

    }
    ;
expression:
    expression OP_PLUS expression {

    }
    |
    expression OP_MINUS expression {

    }
    |
    OP_MINUS expression {

    }
    |
    expression OP_MULTI expression {

    }
    |
    expression OP_DIV expression {

    }
    |
    '(' expression ')'{

    }
    |
    ID {

    }
    |
    NUM {

    }
;

control_structure:
    IF '(' condition ')' '{' statement_list '}' {

    }
    |
    WHILE '(' condition ')' '{' statement_list '}' {

    }
    |
    FOR '(' ')' '{' statement_list '}' {

    }
    ;

condition:
    ID OP_EQUAL NUM {

    }
    |
    TRUE {

    }
    |
    FALSE {

    }
    |
    condition OP_OR condition {

    }
    |
    condition OP_AND condition {

    }
    |
    OP_NOT condition {

    }
    |
    '(' condition ')' {

    }
    ;

%%

void yyerror (char *s) {
    fprintf(stderr, "[Yacc] error: %s\n", s);
}

int main(int argc, char* argv[]) {
  yyin = fopen(argv[1], "r");
  yyparse();
  printf("-----------------\nSymbol table:\n");
  printf("-----------------\nQuad list:\n");

  // Be clean.
  lex_free();
  return 0;
}
