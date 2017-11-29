%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "symbol.h"
  #include "quad.h"
  #include "quad_list.h"
  #include "operator.h"
  #include "assembly_generator.h"
  //#define DEBUG


  void debug(char*);
  void yyerror(char*);
  int yylex();
  void lex_free();
  struct symbol* symbol_list = NULL;
  struct quad* quad_list = NULL;
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
%type <codegen> expression affectation statement statement_list declaration programme
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
    programme{
      quad_list = $1.code;
      printf("Match !!!\n");
      return 0;
    }
  ;

programme:
    INT MAIN '(' ')' '{' statement_list '}'{
      debug("programme");
      $$.code = $6.code;
    }
  ;

statement_list:
  statement statement_list {
    $$.code = quad_add($1.code,$2.code);
    debug("statement");
  }
  |
  statement {
    $$.code = $1.code;
    debug("statement");
  }
  ;

statement:
  declaration ';' {
    debug("declaration");
    }
  |
  affectation ';' {
    $$.code = $1.code;

    debug("affectation");
  }
  |
  declaration_affectation ';'{
    printf("statement: declare affect\n");
  }
  |
  expression ';' {
    //$$.code = $1.code;

      debug("expression");
  }
  |
  control_structure {

      debug("control_structure");
  }
  | RETURN NUM ';' {
    struct symbol* result = symbol_newtemp(&symbol_list);
    result->isconstant = true;
    result->value = $2;
    $$.result = result;
    $$.code = quad_gen(E_RETURN,result,NULL,NULL);
      debug("return");
  }
  ;

declaration:
   INT ID {
    struct symbol* result = symbol_lookup(symbol_list, $2);
      if(result == NULL){
        result = symbol_add(&symbol_list, $2);
      }else{
        printf("ERROR: already declared variable -> %s",$2);
        exit(1);
      }
      $$.result = result;
      $$.code = NULL;
   }
   |
   CONST INT ID {
    struct symbol* result = symbol_lookup(symbol_list, $3);
      if(result == NULL){
        result = symbol_add(&symbol_list, $3);
      }else{
        printf("ERROR: already declared variable -> %s",$3);
        exit(1);
      }
      $$.result = result;
      $$.code = NULL;
   }
  ;

affectation:
    ID OP_ASSIGN expression {
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s",$1);
        exit(1);
      }
      $$.result = result;
      struct quad* quad = quad_gen(E_ASSIGN,result,$3.result,NULL);
      struct quad* code = quad_add($3.code,quad);
      $$.code = code;
      debug("ID = expr");
    }

    ;

declaration_affectation:
    INT ID OP_ASSIGN expression {
      debug("INT ID = expr");
    }
    ;
expression:
    expression OP_PLUS expression {
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;

      struct quad* quad = quad_gen(E_PLUS,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
      debug("expr + expr");
    }
    |
    expression OP_MINUS expression {
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;
      struct quad* quad = quad_gen(E_MINUS,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
      debug(" expr - expr");
    }
    |
    OP_MINUS expression {

    }
    |
    expression OP_MULTI expression {
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;
      struct quad* quad = quad_gen(E_MULT,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
    }
    |
    expression OP_DIV expression {
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;
      struct quad* quad = quad_gen(E_DIV,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
    }
    |
    '(' expression ')'{
      $$.result = $2.result;
      $$.code = $2.code;
    }
    |
    ID {
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL)result = symbol_add(&symbol_list, $1);
      $$.result = result;
      $$.code = NULL;
      debug("ID");
    }
    |
    NUM {
      struct symbol* result = symbol_newtemp(&symbol_list);
      result->isconstant = true;
      result->value = $1;
      $$.result = result;
      $$.code = NULL;
      debug("NUM");
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

void debug (char* s){
#ifdef DEBUG
fprintf(stderr, "[Yacc] ");
  fprintf(stderr, "%s\n",s);
  #endif
}

int main(int argc, char* argv[]) {
  yyin = fopen(argv[1], "r");
  yyparse();
  printf("-----------------\nSymbol table:\n");
  symbol_print(symbol_list);
  printf("-----------------\nQuad list:\n");
  quad_print(quad_list);

  //generation code assembleur
  generator(symbol_list, quad_list);

  // Be clean.
  lex_free();
  return 0;
}
